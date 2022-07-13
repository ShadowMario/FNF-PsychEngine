package;

#if android
import android.Tools;
#end
import flixel.FlxG;
import openfl.events.Event;
import vlc.VLCBitmap;

/**
 * Play a video using cpp.
 * Use bitmap to connect to a graphic or use `VideoSprite`.
 */
class VideoHandler extends VLCBitmap {
	public var readyCallback:Void->Void = null;
	public var finishCallback:Void->Void = null;

	public var canSkip:Bool = true;
	public var canUseSound:Bool = true;
	public var canUseAutoResize:Bool = true;

	private var pauseMusic:Bool = false;

	public function new() {
		super();

		onReady = onVLCReady;
		onComplete = onVLCComplete;
		onError = onVLCError;

		FlxG.addChildBelowMouse(this);
	}

	private function update(?e:Event):Void {
		if (canSkip
			&& ((FlxG.keys.justPressed.ENTER && !FlxG.keys.pressed.ALT)
				|| FlxG.keys.justPressed.SPACE #if android || FlxG.android.justReleased.BACK #end)
			&& initComplete)
			onVLCComplete();

		if (FlxG.sound.muted || FlxG.sound.volume <= 0)
			volume = 0;
		else if (canUseSound)
			volume = FlxG.sound.volume;
	}

	private function resize(?e:Event):Void {
		if (canUseAutoResize) {
			set_width(calc(0));
			set_height(calc(1));
		}
	}

	private function createUrl(fileName:String):String {
		#if android
		var filePath:String = Tools.getFileUrl(fileName);
		return filePath;
		#elseif linux
		var filePath:String = 'file://' + Sys.getCwd() + fileName;
		return filePath;
		#elseif (windows || mac)
		var filePath:String = 'file:///' + Sys.getCwd() + fileName;
		return filePath;
		#end
	}

	private function onVLCReady():Void {
		if (readyCallback != null)
			readyCallback();
	}

	private function onVLCError(e:String):Void {
		throw "VLC caught an error: " + e;
	}

	private function onVLCComplete() {
		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.resume();

		if (FlxG.stage.hasEventListener(Event.ENTER_FRAME))
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);

		if (FlxG.stage.hasEventListener(Event.RESIZE))
			FlxG.stage.removeEventListener(Event.RESIZE, resize);

		if (FlxG.signals.focusGained.has(resume))
			FlxG.signals.focusGained.remove(resume);

		if (FlxG.signals.focusLost.has(pause))
			FlxG.signals.focusLost.remove(pause);

		dispose();

		if (FlxG.game.contains(this)) {
			FlxG.game.removeChild(this);

			if (finishCallback != null)
				finishCallback();
		}
	}

	/**
	 * Native video support for Flixel & OpenFL
	 * @param path Example: `your/video/here.mp4`
	 * @param loop Loop the video.
	 * @param haccelerated if you want the hardware to accelerated for the video.
	 * @param pauseMusic Pause music until done video.
	 */
	public function playVideo(path:String, loop:Bool = false, haccelerated:Bool = true, pauseMusic:Bool = false):Void {
		this.pauseMusic = pauseMusic;

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.pause();

		resize();
		playFile(createUrl(path), loop, haccelerated);

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);
		FlxG.stage.addEventListener(Event.RESIZE, resize);

		FlxG.signals.focusGained.add(resume);
		FlxG.signals.focusLost.add(pause);
	}

	private function calc(ind:Int):Float {
		var appliedWidth:Float = FlxG.stage.stageHeight * (FlxG.width / FlxG.height);
		var appliedHeight:Float = FlxG.stage.stageWidth * (FlxG.height / FlxG.width);

		if (appliedHeight > FlxG.stage.stageHeight)
			appliedHeight = FlxG.stage.stageHeight;

		if (appliedWidth > FlxG.stage.stageWidth)
			appliedWidth = FlxG.stage.stageWidth;

		switch (ind) {
			case 0:
				return appliedWidth;
			case 1:
				return appliedHeight;
		}

		return 0;
	}
}
