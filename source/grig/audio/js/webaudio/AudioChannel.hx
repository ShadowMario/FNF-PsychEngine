package grig.audio.js.webaudio; #if js

import js.lib.Float32Array;

@:forward
abstract AudioChannel(Float32Array) from Float32Array to Float32Array
{
    public inline function new(length:Int) {
        this = new Float32Array(length);
    }

    public inline function clear() {
        this.fill(0.0);
    }

    @:arrayAccess
    inline function get(index:Int):Float {
        return this[index];
    }

    @:arrayAccess
    inline function set(index:Int, sample:Float):Float {
        return this[index] = sample;
    }
}

#end