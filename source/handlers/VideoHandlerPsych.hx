package handlers;

import flixel.FlxCamera;
import flixel.FlxG;
import openfl.Assets as OpenFlAssets;
#if sys
import sys.FileSystem;
#end

#if VIDEOS_ALLOWED
import VideoHandler;
import VideoSprite;

/**
    Handles the execution of Video Cutscenes and Video Sprites with hxCodec
**/
class VideoHandlerPsych {
    public var endFunc:Void->Void;
    public var sprite:VideoSprite;

    public var respectRate:Bool = false;

    public function new(?endFunc:Void->Void):Void {
        this.endFunc = endFunc;
    }

    public function exists(name:String):Bool {
        var filepath:String = Paths.video(name);
		if(#if sys !FileSystem.exists(filepath) #else !OpenFlAssets.exists(filepath) #end)
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
            if (endFunc != null)
                endFunc();
			return false;
		}
        return true;
    }

    public function loadCutscene(name:String) {
        var loader:VideoSprite = new VideoSprite(0, 0);
        loader.playVideo(Paths.video(name));

        // stop it immediately
        loader.bitmap.stop();
        loader.destroy();
    }

    public function startVideo(name:String):Void {
        var video:VideoHandler = new VideoHandler();
        video.playVideo(Paths.video(name));
        if (endFunc != null)
            video.finishCallback = endFunc;
    }

    public function startVideoSprite(x:Float = 0, y:Float = 0, op:Float = 1, name:String, ?cam:FlxCamera, ?loop:Bool = false, ?pauseMusic:Bool = false):Void {
        sprite = new VideoSprite(x, y);
        sprite.playVideo(Paths.video(name), loop, pauseMusic);

        sprite.bitmap.canSkip = false;

        // set up sprite functions
        if (PlayState.instance != null) {
            sprite.bitmap.onPlaying = function() {
                if (respectRate)
                    sprite.bitmap.rate = PlayState.instance.playbackRate;

                if (PlayState.instance.paused)
                    sprite.bitmap.pause();
            }
            sprite.bitmap.onPaused = function() {
                if (!PlayState.instance.paused)
                    sprite.bitmap.resume();
            }
        }

        if (cam != null)
            sprite.cameras = [cam];
        sprite.bitmap.alpha = op;
    }
}
#else
/**
    Handles the execution of Video Cutscenes and Video Sprites with hxCodec

    however, your current platform target is unsupported, thus videos cannot
    be initialized
**/
class VideoHandlerPsych {
    public function new(?endFunc:Void->Void):Void {
        if (endFunc != null)
            this.endFunc = endFunc;
        trace('Something went wrong, platform unsupported!');
    }

    public function loadCutscene(name:String) {
        return trace('Cutscenes cannot be started on this platform');
    }

    public function exists():Bool {
        return false;
    }

    public function playCutscene(name:String):Void {
        return trace('Cutscenes cannot be started on this platform');
    }

    public function playSpriteCutscene(x:Float = 0, y:Float = 0, name:String, ?cam:FlxCamera, ?loop:Bool = false, ?pauseMusic:Bool = false):Void {
        return trace('Cutscenes cannot be started on this platform');
    }
}
#end