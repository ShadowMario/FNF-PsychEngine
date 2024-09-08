package grig.audio; #if heaps

import grig.audio.AudioChannel;
import grig.audio.AudioTime;
import haxe.Timer;
import hxd.snd.NativeChannel;
import hxd.snd.Manager;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class CallbackNativeChannel extends NativeChannel
{
    private var audioInterface:NativeChannelAudioInterface;
    private var startTime:Float;

    override function onSample(buf:haxe.io.Float32Array)
    {
        var streamInfo = new grig.audio.AudioStreamInfo();
        var currentTime = new AudioTime(Timer.stamp() - startTime);
        streamInfo.inputTime = currentTime;
        streamInfo.outputTime = currentTime;
        streamInfo.callbackTime = currentTime;
        
        audioInterface.audioCallback(new AudioBuffer([], audioInterface.sampleRate),
                                     new AudioBuffer([new AudioChannel(buf)], audioInterface.sampleRate),
                                     audioInterface.sampleRate, streamInfo);
    }

    public function new(bufferSize:Int, _audioInterface:NativeChannelAudioInterface)
    {
        audioInterface = _audioInterface;
        startTime = Timer.stamp();
        super(bufferSize);
    }
}

class NativeChannelAudioInterface
{
    public var audioCallback(default, null):AudioCallback;
    public var sampleRate(default, null):Float;
    public var isOpen(default, null):Bool = false;
    private var nativeChannel:CallbackNativeChannel;

    public function new(api:grig.audio.Api = grig.audio.Api.Unspecified)
    {
        if (api != grig.audio.Api.Unspecified) {
            throw new Error(InternalError, 'In NativeChannel interface, specifying api not supported');
        }

        // Surely there's a better way to get the current sample rate than this...
        #if (!usesys && !hlopenal)
        sampleRate = hxd.snd.openal.Emulator.NATIVE_FREQ;
        #else
        sampleRate = hxd.snd.Data.samplingRate;
        #end
    }

    public static function getApis():Array<Api>
    {
        return [];
    }

    public function getPorts():Array<PortInfo>
    {
        return [
            {
                portID: 0, // ignored
                portName: 'Default port',
                isDefaultInput: false,
                isDefaultOutput: true,
                maxInputChannels: 0,
                maxOutputChannels: 1,
                defaultSampleRate: sampleRate,
                sampleRates: [sampleRate],
            }
        ];
    }

    private function fillMissingOptions(options:AudioInterfaceOptions)
    {
        if (options.bufferSize == null) options.bufferSize = 1024;
        if (options.inputNumChannels != null && options.inputNumChannels > 0) throw 'No input support in NativeChannelAudioInterface';
        if (options.outputNumChannels != null && options.outputNumChannels > 1) throw 'Only support for one channel in NativeChannelAudioInterface';
        if (options.sampleRate != null && options.sampleRate != sampleRate) throw 'Unsupported sampleRate: ${options.sampleRate}';
    }

    public function openPort(options:AudioInterfaceOptions):Surprise<AudioInterface, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                if (isOpen) throw 'Already opened channel';
                fillMissingOptions(options);
                nativeChannel = new CallbackNativeChannel(options.bufferSize, this);
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
        nativeChannel.stop();
        nativeChannel = null;
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