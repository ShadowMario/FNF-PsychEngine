package;

import flixel.FlxSprite;

class VideoSprite extends FlxSprite {
	public var readyCallback:Void->Void = null;
	public var finishCallback:Void->Void = null;

	public var bitmap:VideoHandler;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);

		bitmap = new VideoHandler();
		bitmap.visible = false;

		bitmap.readyCallback = function() {
			loadGraphic(bitmap.bitmapData);

			if (readyCallback != null)
				readyCallback();
		}

		bitmap.finishCallback = function() {
			if (finishCallback != null)
				finishCallback();

			kill();
		};
	}

	/**
	 * Native video support for Flixel & OpenFL
	 * @param path Example: `your/video/here.mp4`
	 * @param loop Loop the video.
	 * @param haccelerated if you want the hardware to accelerated for the video.
	 * @param pauseMusic Pause music until done video.
	 */
	public function playVideo(path:String, loop:Bool = false, haccelerated:Bool = true, pauseMusic:Bool = false):Void {
		bitmap.playVideo(path, loop, haccelerated, pauseMusic);
	}
}
