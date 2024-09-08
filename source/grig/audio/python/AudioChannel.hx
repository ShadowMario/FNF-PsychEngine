package grig.audio.python; #if python

import grig.audio.python.numpy.Ndarray;
import python.Tuple;

@:forward
abstract AudioChannel(Ndarray)
{
    public var length(get, never):Int;

    static private var sumOfSquaresThreshold:Float = 0.1;

    public function new(length:Int) {
        this = grig.audio.python.numpy.Numpy.zerosLength(length);
    }

    @:arrayAccess
    public inline function get(key:Int):Float {
        return this.__getitem__(key);
    }

    @:arrayAccess
    public inline function set(key:Int, value:Float):Float {
        this.__setitem__(key, value);
        return value;
    }

    private inline function get_length():Int {
        return python.Syntax.code('len({0})', this);
    }


    // public function resample(ratio:Float):AudioChannel {
    //     if (ratio == 0) return new AudioChannel(0);
    //     var newNumSamples = Math.ceil(length * ratio);
    //     var outputData = new AudioChannel(newNumSamples);
    //     var inputIndices = grig.audio.python.numpy.Numpy.zeros(python.Tuple2.make(1, newNumSamples));
    //     for (i in 0...newNumSamples) {
    //         var newValue = i / ratio;
    //         if (newValue > length - 1) newValue = length - 1;
    //         inputIndices.__getitem__(0).__setitem__(i, newValue);
    //     }
    //     var indices:Ndarray = python.Syntax.code('{0}.arange(0, {1}.shape[0])', grig.audio.python.numpy.Numpy, this);
    //     var int = grig.audio.python.scipy.Interpolate.interp1d(indices, cast this, 'linear');
    //     outputData.__setitem__(c, int(inputIndices));
    //     return outputData;
    // }

    // public function copyInto(other:AudioChannelData, sourceStart:Int = 0, length:Null<Int> = null, otherStart:Int = 0) {
    //     var minLength = (get_length() - sourceStart) > (other.length - otherStart) ? (other.length - otherStart) : (get_length() - sourceStart);
    //     if (sourceStart < 0) sourceStart = 0;
    //     if (otherStart < 0) otherStart = 0;
    //     if (length == null || length > minLength) {
    //         length = minLength;
    //     }
    //     for (i in 0...length) {
    //         other[otherStart + i] = get(sourceStart + i);
    //     }
    // }

    public function applyGain(gain:Float) {
        python.Syntax.code('{0} *= {1}', this, gain);
    }
}

#end