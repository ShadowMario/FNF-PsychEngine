import haxe.io.Bytes;
import lime.utils.ArrayBuffer;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import flixel.system.FlxSound;
import lime.media.AudioBuffer;
import flixel.FlxSprite;

@:keep
class WaveformSprite extends FlxSprite {
    var buffer:AudioBuffer;
    var sound:Sound;
    var peak:Float = 0;
    var valid:Bool = true;
    public function new(x:Float, y:Float, buffer:Dynamic, w:Int, h:Int) {
        super(x,y);
        this.buffer = null;
        if (Std.isOfType(buffer, FlxSound)) {
            @:privateAccess
            this.buffer = cast(buffer, FlxSound)._sound.__buffer;
            @:privateAccess
            this.sound = cast(buffer, FlxSound)._sound;
        } else if (Std.isOfType(buffer, Sound)) {
            @:privateAccess
            this.buffer = cast(buffer, Sound).__buffer;
            this.sound = cast(buffer, Sound);
        } else if (Std.isOfType(buffer, AudioBuffer)) {
            @:privateAccess
            this.buffer = cast(buffer, AudioBuffer);
        } else {
            valid = false;
            return;
        }
        trace(buffer);
        trace(buffer.data);
        for(i in 0...Math.floor(buffer.data.length / buffer.bitsPerSample)) {
            var pos = i * buffer.bitsPerSample;
            var thing = buffer.data.buffer.get(pos) | (buffer.data.buffer.get(pos + 1) << 8);
            if (thing > 256 * 128)
                thing -= 256 * 256;
            var data = 0;
            if ((data = thing) > peak) peak = data;
        }
        trace(buffer.bitsPerSample);
        makeGraphic(w, h, 0x00000000, true); // transparent
    }

    public function generate(startPos:Int, endPos:Int) {
        if (!valid) return;
        startPos -= startPos % buffer.bitsPerSample;
        endPos -= endPos % buffer.bitsPerSample;
        pixels.lock();
        pixels.fillRect(new Rectangle(0, 0, pixels.width, pixels.height), 0); 
        var diff = endPos - startPos;
        var diffRange = Math.floor(diff / pixels.height);
        for(y in 0...pixels.height) {
            var d = Math.floor(diff * (y / pixels.height));
            d -= d % buffer.bitsPerSample;
            var pos = startPos + d;
            var max:Int = 0;
            for(i in 0...Math.floor(diffRange / buffer.bitsPerSample)) {
                var thing = buffer.data.buffer.get(pos + (i * buffer.bitsPerSample)) | (buffer.data.buffer.get(pos + (i * buffer.bitsPerSample) + 1) << 8);
                if (thing > 256 * 128)
                    thing -= 256 * 256;
                if (max < thing) max = thing;
            }
            var thing = max;
            var w = (thing) / peak * pixels.width;
            pixels.fillRect(new Rectangle((pixels.width / 2) - (w / 2), y, w, 1), 0xFFFFFFFF);
        }
        pixels.unlock();
    }

    public function generateFlixel(startPos:Float, endPos:Float) {
        if (!valid) return;
        var rateFrequency = (1 / buffer.sampleRate);
        var multiplicator = 1 / rateFrequency; // 1 hz/s
        multiplicator *= buffer.bitsPerSample;
        multiplicator -= multiplicator % buffer.bitsPerSample;

        generate(Math.floor(startPos * multiplicator / 4000 / buffer.bitsPerSample) * buffer.bitsPerSample, Math.floor(endPos * multiplicator / 4000 / buffer.bitsPerSample) * buffer.bitsPerSample);
    }

    public function getNumberFromBuffer(pos:Int, bytes:Int):Int {
        var am = 0;
        for(i in 0...bytes) {
            var val = buffer.data.buffer.get(pos + i);
            if (val < 0) val += 256;
            for(i2 in 0...(bytes-i)) val *= 256;
            am += val;
        }
        return am;
    }
}