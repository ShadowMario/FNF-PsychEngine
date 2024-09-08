#include "portaudio/portaudio/include/portaudio.h"

#include <grig/audio/AudioBufferData.h>
#include <grig/audio/InterleavedAudioBufferData.h>
#include <memory>
#include <string>
#include <vector>

const int STRUCT_API_VERSION = 1;
const PaSampleFormat SAMPLE_FORMAT = paFloat32;

std::string haxe_string_to_std_string(String &str)
{
    return std::string(str.utf8_str());
}

::String std_string_to_haxe_string(const std::string &str)
{
    return String(str.c_str(), str.size()).dup();
}

::Array<::String> get_api_strings()
{
    Pa_Initialize();
    auto apis = Array_obj<::String>::__new();
    auto count = Pa_GetHostApiCount();
    for (PaHostApiIndex i = 0; i < count; ++i) {
        auto info = Pa_GetHostApiInfo(i);
        if (info->structVersion != STRUCT_API_VERSION) continue;
        apis->push(::String::create(info->name));
    }
    Pa_Terminate();
    return apis;
}

const std::vector<double> COMMON_SAMPLE_RATES = {8000, 11025, 16000, 22050, 44100, 48000, 88200, 96000, 176400, 192000, 352800, 384000};

::Array<::Float> get_sample_rates_for_port_info(PaDeviceIndex portID, int inChannels, int outChannels, PaTime inLatency, PaTime outLatency)
{
    PaStreamParameters *inputParameters = nullptr;
    PaStreamParameters *outputParameters = nullptr;

    if (inChannels > 0) {
        inputParameters = new PaStreamParameters();
        inputParameters->device = portID;
        inputParameters->channelCount = inChannels;
        inputParameters->sampleFormat = SAMPLE_FORMAT;
        inputParameters->suggestedLatency = inLatency;
        inputParameters->hostApiSpecificStreamInfo = nullptr;
    }
    if (outChannels > 0) {
        outputParameters = new PaStreamParameters();
        outputParameters->device = portID;
        outputParameters->channelCount = outChannels;
        outputParameters->sampleFormat = SAMPLE_FORMAT;
        outputParameters->suggestedLatency = outLatency;
        outputParameters->hostApiSpecificStreamInfo = nullptr;
    }

    auto sampleRates = Array_obj<::Float>::__new();

    for (size_t i = 0; i < COMMON_SAMPLE_RATES.size(); ++i) {
        auto sampleRate = COMMON_SAMPLE_RATES[i];
        auto ret = Pa_IsFormatSupported(inputParameters, outputParameters, sampleRate);
        if (ret == 0) sampleRates->push(sampleRate);
    }

    delete inputParameters;
    delete outputParameters;

    return sampleRates;
}

::Array<::Dynamic> get_port_infos(::String apiName)
{
    auto apiNameStr = haxe_string_to_std_string(apiName);
    auto portInfos = Array_obj<::Dynamic>::__new();
    auto count = Pa_GetHostApiCount();
    for (PaHostApiIndex i = 0; i < count; ++i) {
        auto apiInfo = Pa_GetHostApiInfo(i);
        if (apiInfo->structVersion != STRUCT_API_VERSION) continue;
        if (apiNameStr != "Unspecified" && apiNameStr != apiInfo->name) continue;
        for (int j = 0; j < apiInfo->deviceCount; ++j) {
            auto deviceIndex = Pa_HostApiDeviceIndexToDeviceIndex(i, j);
            auto deviceInfo = Pa_GetDeviceInfo(deviceIndex);
            auto portInfo = ::hx::Anon_obj::Create();
            auto portName = std_string_to_haxe_string(apiInfo->name);
            portInfo->Add(HX_CSTRING("portID"), deviceIndex);
            portInfo->Add(HX_CSTRING("portName"), portName);
            portInfo->Add(HX_CSTRING("maxInputChannels"), deviceInfo->maxInputChannels);
            portInfo->Add(HX_CSTRING("maxOutputChannels"), deviceInfo->maxOutputChannels);
            portInfo->Add(HX_CSTRING("defaultSampleRate"), deviceInfo->defaultSampleRate);
            portInfo->Add(HX_CSTRING("maxOutputChannels"), deviceInfo->maxOutputChannels);
            portInfo->Add(HX_CSTRING("isDefaultInput"), deviceIndex == apiInfo->defaultInputDevice);
            portInfo->Add(HX_CSTRING("isDefaultOutput"), deviceIndex == apiInfo->defaultOutputDevice);
            portInfo->Add(HX_CSTRING("defaultLowInputLatency"), deviceInfo->defaultLowInputLatency);
            portInfo->Add(HX_CSTRING("defaultLowOutputLatency"), deviceInfo->defaultLowOutputLatency);
            portInfo->Add(HX_CSTRING("defaultHighInputLatency"), deviceInfo->defaultHighInputLatency);
            portInfo->Add(HX_CSTRING("defaultHighOutputLatency"), deviceInfo->defaultHighOutputLatency);
            auto sampleRates = get_sample_rates_for_port_info(deviceIndex, deviceInfo->maxInputChannels, deviceInfo->maxOutputChannels,
                                                              deviceInfo->defaultLowInputLatency, deviceInfo->defaultLowOutputLatency);
            portInfo->Add(HX_CSTRING("sampleRates"), sampleRates);
            portInfos->push(::Dynamic(portInfo));
        }
    }
    return portInfos;
}

#include <iostream>

void fillStreamInfo(::grig::audio::AudioStreamInfo streamInfo, const PaStreamCallbackTimeInfo *timeInfo, PaStreamCallbackFlags statusFlags)
{
    streamInfo->inputUnderflow = statusFlags & paInputUnderflow != 0;
    streamInfo->inputOverflow = statusFlags & paInputOverflow != 0;
    streamInfo->outputUnderflow = statusFlags & paOutputUnderflow != 0;
    streamInfo->outputOverflow = statusFlags & paOutputOverflow != 0;
    streamInfo->primingOutput = statusFlags & paPrimingOutput != 0;
    streamInfo->inputTime = timeInfo->inputBufferAdcTime;
    streamInfo->outputTime = timeInfo->outputBufferDacTime;
    streamInfo->callbackTime = timeInfo->currentTime;
}

int grig_callback(const void *input, void *output, unsigned long frameCount, const PaStreamCallbackTimeInfo *timeInfo,
                  PaStreamCallbackFlags statusFlags, void *userData)
{
    int base = 0;
    // Register thread to hxcpp's gc
    hx::SetTopOfStack(&base, true);

    auto audioInterface = (grig::audio::cpp::AudioInterface_obj*)userData;
    auto inputChannels = (float**)input;
    auto outputChannels = (float**)output;

    auto inputBuffer = (::grig::audio::AudioBufferData)audioInterface->inputBuffer;
    auto outputBuffer = (::grig::audio::AudioBufferData)audioInterface->outputBuffer;

    for (size_t c = 0; c < inputBuffer->channels->size(); ++c) {
        auto channel = inputBuffer->get(c);
        channel->setUnmanagedData(inputChannels[c], frameCount);
    }
    for (size_t c = 0; c < outputBuffer->channels->size(); ++c) {
        auto channel = outputBuffer->get(c);
        channel->setUnmanagedData(outputChannels[c], frameCount);
    }

    fillStreamInfo(audioInterface->streamInfo, timeInfo, statusFlags);

    audioInterface->callAudioCallback();

    hx::SetTopOfStack((int*)0, true);
    return 0;
}

// int grig_callback_interleaved(const void *input, void *output, unsigned long frameCount, const PaStreamCallbackTimeInfo *timeInfo,
//                   PaStreamCallbackFlags statusFlags, void *userData)
// {
//     int base = 0;
//     // Register thread to hxcpp's gc
//     hx::SetTopOfStack(&base, true);

//     auto audioInterface = (grig::audio::cpp::AudioInterface_obj*)userData;
//     auto inputChannels = (float*)input;
//     auto outputChannels = (float*)output;

//     auto inputBuffer = (::grig::audio::InterleavedAudioBuffer)audioInterface->inputBuffer;
//     auto outputBuffer = (::grig::audio::InterleavedAudioBuffer)audioInterface->outputBuffer;

//     inputBuffer->channels->setUnmanagedData(inputChannels, frameCount * inputBuffer->numChannels);
//     outputBuffer->channels->setUnmanagedData(outputChannels, frameCount * outputBuffer->numChannels);

//     fillStreamInfo(audioInterface->streamInfo, timeInfo, statusFlags);

//     audioInterface->callAudioCallback();

//     hx::SetTopOfStack((int*)0, true);
//     return 0;
// }

void pa_check_errors(PaError err, ::Array<::String> errors)
{
    if (err == 0) return;
    auto errorInfo = Pa_GetLastHostErrorInfo();
    errors->push(String(errorInfo->errorText).dup());
}

int open_port(hx::ObjectPtr<grig::audio::cpp::AudioInterface_obj> audioInterface, ::Dynamic options, PaStream **stream, ::Array<::String> errors)
{
    auto inputPortVal = options->__Field(HX_CSTRING("inputPort"), HX_PROP_DYNAMIC);
    auto outputPortVal = options->__Field(HX_CSTRING("outputPort"), HX_PROP_DYNAMIC);
    int numInputChannels = options->__Field(HX_CSTRING("inputNumChannels"), HX_PROP_DYNAMIC).asInt();
    int numOutputChannels = options->__Field(HX_CSTRING("outputNumChannels"), HX_PROP_DYNAMIC).asInt();
    unsigned long framesPerBuffer = options->__Field(HX_CSTRING("bufferSize"), HX_PROP_DYNAMIC).asInt();
    double sampleRate = options->__Field(HX_CSTRING("sampleRate"), HX_PROP_DYNAMIC).asDouble();
    // bool interleaved = options->__Field(HX_CSTRING("interleaved"), HX_PROP_DYNAMIC).asInt();

    PaSampleFormat sampleFormat = SAMPLE_FORMAT;
    // PaStreamCallback *callback = grig_callback_interleaved;
    // if (!interleaved) {
        sampleFormat |= paNonInterleaved;
        PaStreamCallback *callback = grig_callback;
    // }

    if (inputPortVal.isNull() && outputPortVal.isNull()) {
        auto ret = Pa_OpenDefaultStream(stream, numInputChannels, numOutputChannels, sampleFormat, sampleRate, framesPerBuffer,
                                        callback, audioInterface.GetPtr());
        pa_check_errors(ret, errors);
        if (ret != 0) return ret;
        ret = Pa_StartStream(*stream);
        pa_check_errors(ret, errors);
        return ret;
    }
    
    std::unique_ptr<PaStreamParameters> inputParameters(nullptr);
    if (!inputPortVal.isNull()) {
        inputParameters.reset(new PaStreamParameters());
        inputParameters->device = inputPortVal.asInt();
        inputParameters->channelCount = numInputChannels;
        inputParameters->sampleFormat = sampleFormat;
        inputParameters->suggestedLatency = options->__Field(HX_CSTRING("inputLatency"), HX_PROP_DYNAMIC).asDouble();
        inputParameters->hostApiSpecificStreamInfo = nullptr;
    }
    std::unique_ptr<PaStreamParameters> outputParameters(nullptr);
    if (!outputPortVal.isNull()) {
        outputParameters.reset(new PaStreamParameters());
        outputParameters->device = outputPortVal.asInt();
        outputParameters->channelCount = numOutputChannels;
        outputParameters->sampleFormat = sampleFormat;
        outputParameters->suggestedLatency = options->__Field(HX_CSTRING("outputLatency"), HX_PROP_DYNAMIC).asDouble();
        outputParameters->hostApiSpecificStreamInfo = nullptr;
    }

    auto ret = Pa_OpenStream(stream, inputParameters.get(), outputParameters.get(), sampleRate, framesPerBuffer, paNoFlag,
                             callback, audioInterface.GetPtr());
    pa_check_errors(ret, errors);
    if (ret != 0) return ret;
    ret = Pa_StartStream(*stream);
    pa_check_errors(ret, errors);
    return ret;
}

void close_port(PaStream *stream)
{
    Pa_StopStream(stream);
    Pa_CloseStream(stream);
}