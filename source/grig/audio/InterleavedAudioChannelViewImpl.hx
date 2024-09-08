package grig.audio; #if (!js && !python)

class InterleavedAudioChannelViewImpl<T:Float>
{
    public var length(default, null):Int;
    private var numChannels:Int;
    private var channel:Int;
    private var channels:AudioChannel<T>;

    public function new(channels:AudioChannel<T>, numChannels:Int, channel:Int) {
        this.channels = channels;
        this.channel = channel;
        this.numChannels = numChannels;
        this.length = Std.int(channels.length / numChannels);
    }

    private inline function getInterleavedIndex(index:Int):Int {
        return index * numChannels + channel;
    }

    public inline function get(i:Int):T {
        return channels[getInterleavedIndex(i)];
    }

    public inline function set(i:Int, val:T):T {
        return channels[getInterleavedIndex(i)] = val;
    }
}

#end