package grig.audio.lime;

#if lime

class UInt8ArrayTools
{
	 public static inline function getInt16(data:lime.utils.UInt8Array, pos:Int):Int {
        var val = data[pos] | (data[pos+1] << 8);
        if (val & 0x8000 != 0)
            return val - 0x10000;
        return val;
    }

    public static inline function getInt24(data:lime.utils.UInt8Array, pos:Int):Int {
        var val = data[pos] | (data[pos+1] << 8) | (data[pos+2] << 0x10);
        if (val & 0x800000 != 0)
			return val - 0x1000000;
        return val;
    }

	public static inline function getInt32(data:lime.utils.UInt8Array, pos:Int):Int {
        return data[pos] | (data[pos+1] << 8) | (data[pos+2] << 0x10) | (data[pos+3] << 0x18);
    }

    public static function toInterleaved(data:lime.utils.UInt8Array, bitsPerSample:Int):Array<Float> {
        var newBuffer = new Array<Float>();
        if (bitsPerSample == 8) {    
            newBuffer.resize(data.length);
			for (i in 0...data.length) {
				newBuffer[i] = data[i] / 128.0;
			}	
		}
		else if (bitsPerSample == 16) {
            newBuffer.resize(Std.int(data.length / 2));
			var bytes = data.toBytes();
			for (i in 0...newBuffer.length) {
				// trace('${i}: ${bytes.get(i * 2)} ${bytes.get(i * 2 + 1)} ${bytes.getInt16(i * 2)} ${bytes.getInt16(i * 2) / 32767.0}');
    			newBuffer[i] = getInt16(data, i * 2) / 32767.0;
			}
		}
        else if (bitsPerSample == 24) {
			var bytes = data.toBytes();
            newBuffer.resize(Std.int(data.length / 3));
			for (i in 0...newBuffer.length) {
    			newBuffer[i] = getInt24(data, i * 3) / 8388607.0;
			}
		}
        else if (bitsPerSample == 32) {
            newBuffer.resize(Std.int(data.length / 4));
			for (i in 0...newBuffer.length) {
    			newBuffer[i] = getInt32(data, i * 4) / 2147483647.0;
			}
		}
        else {
            trace('Unknown integer audio format');
        }
        return newBuffer;
    }
}

#end