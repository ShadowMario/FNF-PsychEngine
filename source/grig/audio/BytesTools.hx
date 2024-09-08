package grig.audio;

import haxe.io.Bytes;

/**
 * Static extension for Bytes
 */

class BytesTools
{
    /**
     * Gets little-endian signed short
     */
    public static inline function getInt16(data:Bytes, pos:Int):Int {
        var val = data.get(pos) | (data.get(pos+1) << 8);
        if (val & 0x8000 != 0)
            return val - 0x10000;
        return val;
    }

    /**
     * Gets little-endian signed 24-bit int
     */
    public static inline function getInt24(data:Bytes, pos:Int):Int {
        var val = data.get(pos) | (data.get(pos+1) << 8) | (data.get(pos+2) << 0x10);
        if (val & 0x800000 != 0)
			return val - 0x1000000;
        return val;
    }
}