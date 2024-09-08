package grig.audio.python; #if python

import grig.audio.AudioBuffer;
import grig.audio.AudioCallback;
import grig.audio.AudioChannel;
import grig.audio.NumericTypes;
import grig.audio.python.numpy.Ndarray;
import python.Dict;
import python.Exceptions;
import python.KwArgs;
import python.Tuple;
import python.VarArgs;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

using grig.audio.AudioBufferTools;

typedef NInt = Null<Int>;

@:pythonImport('pyaudio', 'PyAudio')
@:native('PyAudio')
extern class PyAudio
{
    public function new();
    public function get_host_api_count():Int;
    public function get_host_api_info_by_index(host_api_index:Int):Dict<String, Dynamic>;
    public function get_device_info_by_host_api_device_index(host_api_index:Int, host_api_device_index:Int):Dict<String, Dynamic>;
    public function is_format_supported(rate:Float, inputDevice:NInt, inputChannels:NInt, inputFormat:NInt, outputDevice:NInt, outputChannels:NInt, outputFormat:NInt):Bool;
    public function open(args:VarArgs<Dynamic>, kwargs:KwArgs<Dynamic>):Stream;
}

@:pythonImport('pyaudio', 'Stream')
extern class Stream
{
    public function start_stream():Void;
    public function stop_stream():Void;
}

@:pythonImport('pyaudio')
@:native('pyaudio')
extern class PyAudioGlobal
{
    public static var paFloat32:Int;
    public static var paInputOverflow:Int;
    public static var paInputUnderflow:Int;
    public static var paOutputOverflow:Int;
    public static var paOutputUnderflow:Int;
    public static var paPrimingOutput:Int;
}

class AudioInterface
{
    public var isOpen(default, null):Bool = false;
    public var audioCallback(default, null):AudioCallback;
    private var pyAudio:PyAudio;
    private var api:grig.audio.Api;
    private static var sampleFormat:Int = PyAudioGlobal.paFloat32;
    private var stream:Stream;

    private var inputNumChannels:Int;
    private var outputNumChannels:Int;
    private var sampleRate:Float;
    private var bufferSize:Int;
    private var inputPort:Null<Int>;
    private var outputPort:Null<Int>;
    private var inputLatency:Float;
    private var outputLatency:Float;

    private var inputBuffer:AudioBuffer<Float32> = null;
    private var outputBuffer:AudioBuffer<Float32> = null;

    private function callbackHandler(input:python.Bytes, frameCount:Int, timeInfo:Dict<String, Float>, statusFlags:Int):Tuple2<python.Bytearray, Int>
    {
        if (input != null) {
            // Gotta deinterleave because pyAudio only supports interleaved
            var kwargs = new Dict<String, Dynamic>();
            kwargs.set('dtype', grig.audio.python.numpy.Numpy.float32);
            var inputDataInterleaved = grig.audio.python.numpy.Numpy.frombuffer(input, kwargs);
            var inputData:Ndarray = python.Syntax.code('[{0}[idx::{1}] for idx in range({1})]', inputDataInterleaved, outputNumChannels);
            // var inputData:Ndarray = grig.audio.python.numpy.Numpy.zeros(python.Tuple2.make(outputNumChannels, Std.int(frameCount)));
            inputBuffer = AudioBuffer.ofNativeArray(inputData, sampleRate);
        }
        else if (inputBuffer == null) {
            inputBuffer = new AudioBuffer(0, 0, sampleRate);
        }
        else {
            inputBuffer.clear();
        }

        if (outputBuffer == null) {
            // Don't forget to switch to looking at numInputChannels whenever the problem with pyAudio only supporting one number to rule them all is fixed
            outputBuffer = new AudioBuffer(outputNumChannels, Std.int(frameCount), sampleRate);
        }
        else {
            outputBuffer.clear();
        }

        var streamInfo = new grig.audio.AudioStreamInfo();
        streamInfo.inputUnderflow = statusFlags & PyAudioGlobal.paInputUnderflow != 0;
        streamInfo.inputOverflow = statusFlags & PyAudioGlobal.paInputOverflow != 0;
        streamInfo.outputUnderflow = statusFlags & PyAudioGlobal.paOutputUnderflow != 0;
        streamInfo.outputOverflow = statusFlags & PyAudioGlobal.paOutputOverflow != 0;
        streamInfo.primingOutput = statusFlags & PyAudioGlobal.paPrimingOutput != 0;
        streamInfo.inputTime = new AudioTime(timeInfo.get('inputBufferAdcTime'));
        streamInfo.outputTime = new AudioTime(timeInfo.get('outputBufferDacTime'));
        streamInfo.callbackTime = new AudioTime(timeInfo.get('currentTime'));

        audioCallback(inputBuffer, outputBuffer, sampleRate, streamInfo);

        var outputArrayArgs = new Tuple<Ndarray>(cast [for (i in 0...outputBuffer.numChannels) outputBuffer[i]]);
        var output = grig.audio.python.numpy.Numpy.dstack(outputArrayArgs).flatten().astype('float32').tobytes();
        return new Tuple2([python.Syntax.code('bytes({0})', output), 0]);
    }

    public function new(_api:grig.audio.Api = grig.audio.Api.Unspecified)
    {
        api = _api;
        pyAudio = new PyAudio();
    }

    public static function getApis():Array<grig.audio.Api>
    {
        var pyAudio = new PyAudio();
        var apiCount = pyAudio.get_host_api_count();
        var apis = new Array<grig.audio.Api>();
        for (i in 0...apiCount) {
            var apiInfo = pyAudio.get_host_api_info_by_index(i);
            var api = grig.audio.PortAudioHelper.apiFromName(apiInfo.get('name'));
            apis.push(api);
        }
        return apis;
    }

    private function addSampleRatesToPortInfo(portInfo:PortInfo):Void
    {
        var inputPort:NInt = null;
        var outputPort:NInt = null;

        // Base our estimate on full duplex (if available), all channels
        if (portInfo.maxInputChannels > 0) {
            inputPort = portInfo.portID;
        }
        if (portInfo.maxOutputChannels > 0) {
            outputPort = portInfo.portID;
        }

        for (sampleRate in grig.audio.SampleRate.commonSampleRates) {
            try {
                var ret = pyAudio.is_format_supported(sampleRate, inputPort, portInfo.maxInputChannels, sampleFormat,
                                                    outputPort, portInfo.maxOutputChannels, sampleFormat);
                if (ret) portInfo.sampleRates.push(sampleRate);
            }
            catch (exception:python.Exception) {
            }
        }

    }

    public function getPorts():Array<PortInfo>
    {
        var portInfos = new Array<PortInfo>();
        var apiCount = pyAudio.get_host_api_count();
        var apiName = grig.audio.PortAudioHelper.nameFromApi(api);
        for (i in 0...apiCount) {
            var apiInfo = pyAudio.get_host_api_info_by_index(i);
            if (apiInfo.get('name') == apiName || api == grig.audio.Api.Unspecified) {
                var deviceCount:Int = apiInfo.get('deviceCount');
                for (j in 0...deviceCount) {
                    var deviceInfo = pyAudio.get_device_info_by_host_api_device_index(i, j);
                    var deviceIndex:Int = deviceInfo.get('index');
                    var portInfo:PortInfo = {
                        portID: deviceIndex,
                        portName: deviceInfo.get('name'),
                        maxInputChannels: deviceInfo.get('maxInputChannels'),
                        maxOutputChannels: deviceInfo.get('maxOutputChannels'),
                        defaultSampleRate: deviceInfo.get('defaultSampleRate'),
                        isDefaultInput: deviceIndex == apiInfo.get('defaultInputDevice'),
                        isDefaultOutput: deviceIndex == apiInfo.get('defaultOutputDevice'),
                        defaultLowInputLatency: deviceInfo.get('defaultLowInputLatency'),
                        defaultLowOutputLatency: deviceInfo.get('defaultLowOutputLatency'),
                        defaultHighInputLatency: deviceInfo.get('defaultHighInputLatency'),
                        defaultHighOutputLatency: deviceInfo.get('defaultHighOutputLatency'),
                        sampleRates: new Array<Float>(),
                    };
                    addSampleRatesToPortInfo(portInfo);
                    portInfos.push(portInfo);
                }
                break;
            }
        }
        return portInfos;
    }

    private function processOptions(options:AudioInterfaceOptions)
    {
        if (options.inputNumChannels != null) inputNumChannels = options.inputNumChannels;
        else inputNumChannels = 0;
        if (options.outputNumChannels != null) outputNumChannels = options.outputNumChannels;
        else outputNumChannels = 2;
        if (options.sampleRate != null) sampleRate = options.sampleRate;
        else sampleRate = 44100.0;
        if (options.bufferSize != null) bufferSize = options.bufferSize;
        else bufferSize = 256;
        if (options.inputLatency != null) inputLatency = options.inputLatency;
        else inputLatency = 0.01;
        if (options.outputLatency != null) outputLatency = options.outputLatency;
        else outputLatency = 0.01;
        inputPort = options.inputPort;
        outputPort = options.outputPort;
    }

    public function openPort(options:AudioInterfaceOptions):Surprise<AudioInterface, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                if (isOpen) throw 'Already opened port';
                processOptions(options);
                var args = [Std.int(sampleRate), outputNumChannels, sampleFormat]; // pyaudio doesn't let you specify input/output channels separately so we're hoping for the best..
                var kwargs = new Dict<String, Dynamic>();
                if (inputNumChannels > 0) kwargs.set('input', true);
                if (outputNumChannels > 0) kwargs.set('output', true);
                kwargs.set('input_device_index', inputPort);
                kwargs.set('output_device_index', outputPort);
                kwargs.set('frames_per_buffer', bufferSize);
                kwargs.set('stream_callback', callbackHandler);
                stream = pyAudio.open(args, kwargs);
                isOpen = true;
                _callback(Success(this));
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open port. ${error.message}')));
            }
        });
    }

    public function closePort():Void
    {
        if (!isOpen) return;
        stream.stop_stream();
        stream = null;
        isOpen = false;
    }

    public function setCallback(_audioCallback:AudioCallback):Void
    {
        audioCallback = _audioCallback;
    }

    public function cancelCallback():Void
    {
        audioCallback = null;
    }
}

#end