package grig.audio;

class AudioBufferData<T:Float>
{
    public var sampleRate(default, null):Float;
    public var numChannels(get, never):Int;
    public var numSamples(get, never):Int;
    private var channels:Array<AudioChannel<T>>;

    private inline function get_numChannels():Int {
        return channels.length;
    }

    private inline function get_numSamples():Int {
        return if (channels.length == 0) 0;
        else channels[0].length;
    }

    public inline function new(numChannels:Int, numSamples:Int, sampleRate:Float) {
        this.sampleRate = sampleRate;
        this.channels = new Array<AudioChannel<T>>();
        for (i in 0...numChannels) {
            channels.push(new AudioChannel<T>(numSamples));
        }
    }

    public inline function get(i:Int):AudioChannel<T> {
        #if cpp
        return cpp.NativeArray.unsafeGet(channels, i);
        #else
        return channels[i];
        #end
    }
}