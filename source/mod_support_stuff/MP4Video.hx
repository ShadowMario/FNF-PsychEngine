package mod_support_stuff;

import flixel.FlxSprite;

class MP4Video {
    public static function playMP4(path:String, callback:Void->Void, repeat:Bool = false, ?canvasWidth:Int, ?canvasHeight:Int, fillScreen:Bool = false):FlxSprite {
        
		#if X64_BITS
            #if windows
            var video = new MP4Handler();
            video.finishCallback = callback;
            video.canvasWidth = canvasWidth;
            video.canvasHeight = canvasHeight;
            video.fillScreen = fillScreen;
            var sprite = new FlxSprite(0,0);
            sprite.antialiasing = Settings.engineSettings.data.videoAntialiasing;
            video.playMP4(path, repeat, sprite, null, null, true);
            return sprite;
            #else
            callback();
            return new FlxSprite(0,0);
            #end
        #else
            callback();
            return new FlxSprite(0,0);
        #end
    }
}