package grig.audio;

class AudioChannelTools
{
    static private var sumOfSquaresThreshold:Float = 0.1;

    /** Sum of squares of the data. A quick and dirty way to check energy level **/
    @:generic
    public static function sumOfSquares<T:Float>(channel:AudioChannel<T>):Float
    {
        var sum:Float = 0.0;
        for (i in 0...channel.length) {
            sum += channel[i];
        }
        var avg:Float = sum / channel.length;
        var squaresSum:Float = 0.0;
        for (i in 0...channel.length) {
            squaresSum += Math.pow(channel[i] - avg, 2.0);
        }
        return squaresSum;
    }

    /** Uses sum of squares to determine sufficiently low energy **/
    @:generic
    public static function isSilent<T:Float>(input:AudioChannel<T>):Bool
    {
        return sumOfSquares(input) < sumOfSquaresThreshold;
    }

    /**
        Copies from `other` into `self`
        warning: does no bounds checking!
    **/
    @:generic
    public static function copyFrom<T:Float>(self:AudioChannel<T>, other:AudioChannel<T>, length:Int,
                                             otherStart:Int = 0, start:Int = 0):Void
    {
        #if cpp
        cpp.NativeArray.blit(cast self, start,
                             cast other, otherStart, length);
        #end
        for (i in 0...length) {
            self[start + i] = other[otherStart + i];
        }
    }

    /**
        Adds from `other` into `self`
        warning: does no bounds checking!
    **/
    @:generic
    public static function addFrom<T:Float>(self:AudioChannel<T>, other:AudioChannel<T>, length:Int,
                                             otherStart:Int = 0, start:Int = 0):Void
    {
        // Definitely gotta optimize this in C++
        for (i in 0...length) {
            self[start + i] += other[otherStart + i];
        }
    }

    /** Returns a resampled version of the channel **/
    @:generic
    public static function resample<T:Float>(input:AudioChannel<T>, ratio:Float):AudioChannel<T> {
        var newNumSamples = Math.ceil(input.length * ratio);
        var newAudioChannel = new AudioChannel<T>(newNumSamples);
        var interpolator = new LinearInterpolator<T>();
        interpolator.resampleIntoChannel(input, newAudioChannel, ratio);
        return newAudioChannel;
    }

    /** Set all values in the signal to `value` **/
    @:generic
    public static function setAll<T:Float>(input:AudioChannel<T>, value:T) {
        for (i in 0...input.length) {
            input[i] = value;
        }
    }

    /** Resets the buffer to silence (all `0.0`) **/
    @:generic
    public static function clear<T:Float>(input:AudioChannel<T>) {
        #if cpp
        cpp.NativeArray.zero(cast input, 0, input.length);
        #elseif (js && !nodejs)
        input.clear();
        #else
        setAll(input, cast 0);
        #end
    }

    /** Multiply all values in the signal by gain **/
    @:generic
    public static function applyGain<T:Float>(input:AudioChannel<T>, gain:Float) {
        // This is ripe for optimization...
        for (i in 0...input.length) {
            input[i] = cast input[i] * gain;
        }
    }
}