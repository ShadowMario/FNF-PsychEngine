package grig.audio;

class AudioBufferTools
{
    // public static function copyFrom(self:AudioBuffer, other:AudioBuffer, length:Int, otherStart:Int = 0, start:Int = 0):Void {
    //     #if cpp
    //     if (Std.isOfType(self, InterleavedAudioBuffer) && Std.isOfType(other, InterleavedAudioBuffer) && self.numChannels == other.numChannels) {
    //         var otherInterleaved:InterleavedAudioBuffer = cast other;
    //         cpp.NativeArray.blit(cast otherInterleaved.channels, start * self.numChannels, cast otherInterleaved.channels,
    //                              otherStart * self.numChannels, length * self.numChannels);
    //         return;
    //     }
    //     #end
    //     var channelsToCopy = Ints.min(self.numChannels, other.numChannels);
    //     for (c in 0...channelsToCopy) {
    //         AudioChannelTools.copyFrom(self[c], other[c], length, otherStart, start);
    //     }
    // }

    @:generic
    public static function resample<T:Float>(input:AudioBuffer<T>, ratio:Float, repitch:Bool = false):AudioBuffer<T> {
        var length = Math.ceil(input.numSamples * ratio);
        var sampleRate = repitch ? input.sampleRate : input.sampleRate * ratio;
        var output = new AudioBuffer<T>(input.numChannels, length, sampleRate);
        if (ratio == 0) return output;
        var interpolator = new LinearInterpolator<T>();
        for (channel in 0...input.numChannels) {
            interpolator.resampleIntoChannel(input[channel], output[channel], ratio);
        }
        return output;
    }

    @:generic
    public static function clear<T:Float>(input:AudioBuffer<T>):Void {
        for (i in 0...input.numChannels) AudioChannelTools.clear(input[i]);
    }
}