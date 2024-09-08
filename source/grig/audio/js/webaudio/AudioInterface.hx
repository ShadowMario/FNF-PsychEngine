package grig.audio.js.webaudio; #if (js && !nodejs)

import grig.audio.AudioCallback;
import grig.audio.NumericTypes;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.AudioWorkletNodeOptions;
import js.html.audio.MediaStreamAudioSourceNode;
import js.html.audio.ScriptProcessorNode;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

typedef WorkletPorts = Array<Array<js.lib.Float32Array>>;

// class CallbackProcessor extends js.lib.audio.AudioWorkletProcessor // Will this fail at runtime upon declaration or instantiation if worklet interface is missing?
// {
//     private var audioInterface:AudioInterface;

//     public function process(input:WorkletPorts, output:WorkletPorts, params:Dynamic):Bool
//     {
//         trace('a');
//         return true;
//     }

//     public function new(_audioInterface:AudioInterface, ?options:AudioWorkletNodeOptions)
//     {
//         audioInterface = _audioInterface;
//         super();
//     }
// }

class AudioInterface
{
    private var audioCallback:AudioCallback;
    public static var audioContext:AudioContext = null;
    public var isOpen(default, null):Bool = false;
    private var sampleRate:Float;
    private var processor:AudioNode;

    private function handleAudioEvent(event:AudioProcessingEvent)
    {
        if (audioCallback == null) return;

        var streamInfo = new grig.audio.AudioStreamInfo();
        var currentTime:Float = js.Syntax.code('{0}.currentTime', audioContext);
        streamInfo.inputTime = new AudioTime(currentTime);
        streamInfo.outputTime = new AudioTime(event.playbackTime);
        streamInfo.callbackTime = new AudioTime(currentTime);
        var inputBuffer:AudioBuffer = event.inputBuffer;
        audioCallback(inputBuffer, event.outputBuffer, event.outputBuffer.sampleRate, streamInfo);
    }

    private function instantiateContext():Void
    {
        if (audioContext == null) {
            audioContext = AudioContextFactory.createAudioContext();
        }

        sampleRate = js.Syntax.code('{0}.sampleRate', audioContext);
    }

    public function new(api:grig.audio.Api = grig.audio.Api.Unspecified)
    {
        if (api != grig.audio.Api.Unspecified && api != grig.audio.Api.Browser) {
            throw new Error(InternalError, 'In webaudio, only "Browser" api supported');
        }

        sampleRate = 44100;
    }

    public static function getApis():Array<Api>
    {
        return [Api.Browser];
    }

    // We should probably make this asynchronous too!
    public function getPorts():Array<PortInfo>
    {
        return [
            {
                portID: 0, // ignored
                portName: 'Default port',
                isDefaultInput: true,
                isDefaultOutput: true,
                maxInputChannels: 2, // Cannot be determined accurately without requesting audio access first, which would be premature here
                maxOutputChannels: 2,
                defaultSampleRate: sampleRate,
                sampleRates: [sampleRate], // Firefox alone supports additional, but it's simply resampling so what's the point?
            }
        ];
    }

    private function requestAudioAccess(options:AudioInterfaceOptions):js.lib.Promise<Null<MediaStreamAudioSourceNode>>
    {
        instantiateContext();
        var promise:js.lib.Promise<js.html.MediaStream> = js.Syntax.code('navigator.mediaDevices.getUserMedia({audio:true})');
        return promise.then(function(mediaStream:js.html.MediaStream) {
            return js.lib.Promise.resolve(audioContext.createMediaStreamSource(mediaStream));
        }).catchError(function(e:js.lib.Error) {
            return js.lib.Promise.reject(e);
        });
    }

    private function fillMissingOptions(options:AudioInterfaceOptions)
    {
        if (options.inputNumChannels == null) options.inputNumChannels = 0; // default to not asking for mic access
        if (options.outputNumChannels == null) options.outputNumChannels = audioContext.destination.channelCount;
        if (options.bufferSize == null) options.bufferSize = 0; // 0 signifies let browser choose for me
    }

    public function openPort(options:AudioInterfaceOptions):Surprise<AudioInterface, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                instantiateContext();
                if (isOpen) throw 'Already opened port';
                fillMissingOptions(options);
                if (options.outputNumChannels > audioContext.destination.channelCount) {
                    _callback(Failure(new Error(InternalError, 'Unsupported number of output channels: ${options.outputNumChannels}')));
                }
                requestAudioAccess(options).then(function(inputNode:Null<MediaStreamAudioSourceNode>) {
                    audioContext.resume();
                    if (inputNode != null) {
                        if (options.inputNumChannels > inputNode.channelCount) {
                            _callback(Failure(new Error(InternalError, 'Unsupported number of input channels: ${options.inputNumChannels}')));
                        }
                    }
                    // // Try to create AudioWorklet, fall back to ScriptProcessor on DOMError
                    // var workletGlobalScope:js.html.audio.AudioWorkletGlobalScope = js.Syntax.code('{0}.audioWorklet', audioContext);

                    var scriptProcessor = audioContext.createScriptProcessor(options.bufferSize, options.inputNumChannels, options.outputNumChannels);
                    scriptProcessor.connect(audioContext.destination);
                    scriptProcessor.onaudioprocess = handleAudioEvent;
                    if (inputNode != null) inputNode.connect(scriptProcessor);
                    processor = scriptProcessor;

                    isOpen = true;
                    _callback(Success(this));
                }).catchError(function(e:js.lib.Error) {
                    _callback(Failure(new Error(InternalError, e.message)));
                });
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failed to open port. ${error.message}')));
            }
        });
    }

    public function closePort():Void
    {
        if (!isOpen) return;
        if (processor != null) {
            processor.disconnect();
            processor = null;
        }
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