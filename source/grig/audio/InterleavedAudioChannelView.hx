package grig.audio; #if (!js && !python)

/**
    Represents a floating-point based signal
**/
@:forward
abstract InterleavedAudioChannelView<T:Float>(InterleavedAudioChannelViewImpl<T>)
from InterleavedAudioChannelViewImpl<T> to InterleavedAudioChannelViewImpl<T>
{
    public inline function new(channels:AudioChannel<T>, numChannels:Int, channel:Int) {
        this = new InterleavedAudioChannelViewImpl<T>(channels, numChannels, channel);
    }

    @:arrayAccess
    public inline function get(i:Int):T {
        return this.get(i);
    }

    @:arrayAccess
    public inline function set(i:Int, sample:T):T {
        return this.set(i, sample);
    }
}

#end