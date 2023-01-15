package handlers;

import flixel.FlxSprite;
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
	https://github.com/polybiusproxy/hxCodec
**/
class PsychVideo {
	public var endFunc:Void->Void;

	public static var videos:Array<VideoHandler> = [];
	public static var sprites:Array<VideoSprite> = [];

	public function new(?endFunc:Void->Void):Void {
		this.endFunc = endFunc;
	}

	public function exists(name:String):Bool {
		var filepath:String = Paths.video(name);
		if (#if sys !FileSystem.exists(filepath) #else !OpenFlAssets.exists(filepath) #end) {
			FlxG.log.warn('Couldnt find video file: ' + name);
			if (endFunc != null)
				endFunc();
			return false;
		}
		return true;
	}

	public function loadCutscene(name:String):Void {
		var path:String = Paths.video(name);
		if (!exists(name))
			return;

		var loader:VideoSprite = new VideoSprite(0, 0);
		loader.playVideo(path);

		// stop it immediately
		loader.bitmap.stop();
		loader.destroy();
	}

	public function startVideo(name:String):VideoHandler {
		var path:String = Paths.video(name);
		if (!exists(name))
			return null;

		var video:VideoHandler = new VideoHandler();
		if (endFunc != null)
			video.finishCallback = endFunc;
		video.canSkip = true;

		video.playVideo(path);
		videos.push(video);
		return video;
	}

	public function startVideoSprite(x:Float = 0, y:Float = 0, op:Float = 1, name:String, ?cam:FlxCamera, ?loop:Bool = false,
		?pauseMusic:Bool = false):FlxSprite {
		//
		var path:String = Paths.video(name);
		if (!exists(name))
			return null;

		var newSprite:VideoSprite = new VideoSprite(x, y);
		newSprite.bitmap.canSkip = false;

		if (cam != null)
			newSprite.cameras = [cam];
		newSprite.alpha = op;
		newSprite.playVideo(path, loop, pauseMusic);
		//
		sprites.push(newSprite);
		return newSprite;
	}

	/* // hacky methods to pause videos and such // */

	public static function isActive(?resume:Bool):Void {
		for (v in 0...videos.length) { // all videos
			for (s in 0...sprites.length) { // all video sprites
				if (resume) {
					videos[v].resume();
					sprites[s].bitmap.resume();
				}
				else {
					videos[v].pause();
					sprites[s].bitmap.pause();
				}
			}
		}
	}

	public static function clearAll():Void {
		for (v in 0...videos.length) {
			for (s in 0...sprites.length) {
				videos[v].dispose();
				sprites[s].bitmap.dispose();
				sprites[s].kill();
				//
				videos = [];
				sprites = [];
			}
		}
	}
}
#else

/**
	Handles the execution of Video Cutscenes and Video Sprites with hxCodec

	however, your current platform target is unsupported, thus videos cannot
	be initialized
**/
class PsychVideo {
	public function new(?endFunc:Void->Void):Void {
		trace('Something went wrong, platform unsupported!');
	}

	public function exists(name:String):Bool
		return false;

	public function loadCutscene(name:String):Void
		return;

	public function startVideo(name:String):VideoHandler
		return null;

	public function startVideoSprite(x:Float = 0, y:Float = 0, op:Float = 1, name:String, ?cam:FlxCamera, ?loop:Bool = false,
			?pauseMusic:Bool = false):FlxSprite {
		return null;
	}

	public static function isActive(?resume:Bool):Void
		return;

	public static function clearAll():Void
		return;
}
#end
