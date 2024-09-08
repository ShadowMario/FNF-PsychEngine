package grig.audio; #if (!js && !python)

@:generic
class InterleavedAudioBufferData<T:Float>
{
    private var channels:AudioChannel<T>;
    public var sampleRate(default, null):Float;
    public var numChannels(default, null):Int;
    public var numSamples(get, never):Int;

    private inline function get_numSamples():Int {
        return Std.int(channels.length / numChannels);
    }

    public inline function new(numChannels:Int, numSamples:Int, sampleRate:Float) {
        this.channels = new AudioChannel<T>(numChannels * numSamples);
        this.numChannels = numChannels;
        this.sampleRate = sampleRate;
    }

    public function get(channel:Int):InterleavedAudioChannelView<T> {
        return new InterleavedAudioChannelView<T>(channels, numChannels, channel);
    }
}

#end