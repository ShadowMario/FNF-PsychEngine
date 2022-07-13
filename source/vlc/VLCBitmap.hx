package vlc;

#if !(desktop || android)
#error "The current target platform isn't supported by hxCodec. If you're targeting Windows/Mac/Linux/Android and getting this message, please contact us.";
#end
import cpp.NativeArray;
import cpp.UInt8;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.utils.ByteArray;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.geom.Rectangle;
import haxe.io.Bytes;
import vlc.LibVLC;

/**
 * ...
 * @author Tommy Svensson
 */
/** 
	This class lets you to use libvlc as a bitmap then you can displaylist along other items.
	`Bitmap` extend this class. Because without it we cant display the video.
**/
/**
	We need to inject the cpp code to the bitmap
**/
@:cppFileCode("#include <LibVLC.cpp>")
class VLCBitmap extends Bitmap {
	public var videoHeight(get, never):Int;
	public var videoWidth(get, never):Int;

	public var volume(default, set):Float;

	public var initComplete:Bool = false;
	public var isDisposed:Bool = false;

	public var onReady:Void->Void = null;
	public var onPlay:Void->Void = null;
	public var onStop:Void->Void = null;
	public var onPause:Void->Void = null;
	public var onResume:Void->Void = null;
	public var onBuffer:Void->Void = null;
	public var onOpening:Void->Void = null;
	public var onComplete:Void->Void = null;
	public var onError:String->Void = null;
	public var onTimeChanged:Int->Void = null;
	public var onPositionChanged:Int->Void = null;
	public var onSeekableChanged:Int->Void = null;
	public var onForward:Void->Void = null;
	public var onBackward:Void->Void = null;

	private var bufferMemory:Array<UInt8>;
	private var libvlc:LibVLC;

	private var _width:Null<Float>;
	private var _height:Null<Float>;

	public function new():Void {
		super(bitmapData, PixelSnapping.AUTO, true);

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	/**
		Play's the video file you put.

		@param	path	The video path (where the video is located in the files).
		@param	loop	If you want to loop the video.
		@param	haccelerated	If you want to have hardware accelerated enable for the video.
	**/
	public function playFile(path:String, loop:Bool = false, haccelerated:Bool = true):Void {
		if (libvlc != null && path != null) {
			#if HXC_DEBUG_TRACE
			trace("Video path: " + path);
			#end

			libvlc.playFile(path, loop, haccelerated);
		}
	}

	/**
		Play the video.
	**/
	public function play():Void {
		if (libvlc != null && !libvlc.isPlaying())
			libvlc.play();
	}

	/**
		Stop the video.
	**/
	public function stop():Void {
		if (libvlc != null && libvlc.isPlaying())
			libvlc.stop();
	}

	/**
		Pause the video.
	**/
	public function pause():Void {
		if (libvlc != null && libvlc.isPlaying()) {
			libvlc.pause();

			if (onPause != null)
				onPause();
		}
	}

	/**
		Resume the video.
	**/
	public function resume():Void {
		if (libvlc != null && !libvlc.isPlaying()) {
			libvlc.resume();

			if (onResume != null)
				onResume();
		}
	}

	/**
		Pause / Resume the video.
	**/
	public function togglePause():Void {
		if (libvlc != null && !libvlc.isPlaying())
			libvlc.togglePause();
	}

	/**
		Seeking the procent of the video.

		@param	seekProcen  The procent you want to seek the video.
	**/
	public function seek(seekProcent:Float):Void {
		if (libvlc != null && (libvlc.isPlaying() && libvlc.isSeekable()))
			libvlc.setPosition(seekProcent);
	}

	/**
		Setting the time of the video.

		@param	time The video time you want to set.
	**/
	public function setTime(time:Int):Void {
		if (libvlc != null && libvlc.isPlaying())
			libvlc.setTime(time);
	}

	/**
		Returns the time of the video.
	**/
	public function getTime():Int {
		if (libvlc != null && libvlc.isPlaying())
			return libvlc.getTime();
		else
			return 0;
	}

	/**
		Setting the volume of the video.

		@param	vol	 The video volume you want to set.
	**/
	public function setVolume(vol:Float):Void {
		if (libvlc != null && libvlc.isPlaying())
			libvlc.setVolume(vol * 100);
	}

	/**
		Returns the volume of the video.
	**/
	public function getVolume():Float {
		if (libvlc != null && libvlc.isPlaying())
			return libvlc.getVolume();
		else
			return 0;
	}

	/**
		Returns the duration of the video.
	**/
	public function getDuration():Float {
		if (libvlc != null && libvlc.isPlaying())
			return libvlc.getDuration();
		else
			return 0;
	}

	/**
		Returns the length of the video.
	**/
	public function getLength():Float {
		if (libvlc != null && libvlc.isPlaying())
			return libvlc.getLength();
		else
			return 0;
	}

	private function checkFlags():Void {
		if (untyped __cpp__('libvlc -> flags[1]') == 1) {
			untyped __cpp__('libvlc -> flags[1] = -1');

			if (!initComplete)
				videoInitComplete();

			if (onPlay != null)
				onPlay();
		}
		if (untyped __cpp__('libvlc -> flags[2]') == 1) {
			untyped __cpp__('libvlc -> flags[2] = -1');
			if (onStop != null)
				onStop();
		}
		if (untyped __cpp__('libvlc -> flags[3]') == 1) {
			untyped __cpp__('libvlc -> flags[3] = -1');

			#if HXC_DEBUG_TRACE
			trace("The Video got done!");
			#end

			if (onComplete != null)
				onComplete();
		}
		if (untyped __cpp__('libvlc -> flags[4]') != -1) {
			var newTime:Int = untyped __cpp__('libvlc -> flags[4]');

			#if HXC_DEBUG_TRACE
			trace("video time now is: " + newTime);
			#end

			if (onTimeChanged != null)
				onTimeChanged(newTime);
		}
		if (untyped __cpp__('libvlc -> flags[5]') != -1) {
			var newPos:Int = untyped __cpp__('libvlc -> flags[5]');

			#if HXC_DEBUG_TRACE
			trace("the position of the video now is: " + newPos);
			#end

			if (onPositionChanged != null)
				onPositionChanged(newPos);
		}
		if (untyped __cpp__('libvlc -> flags[6]') != -1) {
			var newPos:Int = untyped __cpp__('libvlc -> flags[6]');

			#if HXC_DEBUG_TRACE
			trace("the seeked pos of the video now is: " + newPos);
			#end

			if (onSeekableChanged != null)
				onSeekableChanged(newPos);
		}
		if (untyped __cpp__('libvlc -> flags[7]') == 1) {
			untyped __cpp__('libvlc -> flags[7] = -1');
			if (onError != null)
				onError(libvlc.getLastError());
		}
		if (untyped __cpp__('libvlc -> flags[8]') == 1) {
			untyped __cpp__('libvlc -> flags[8] = -1');
			if (onOpening != null)
				onOpening();
		}
		if (untyped __cpp__('libvlc -> flags[9]') == 1) {
			untyped __cpp__('libvlc -> flags[9] = -1');
			if (onBuffer != null)
				onBuffer();
		}
		if (untyped __cpp__('libvlc -> flags[10]') == 1) {
			untyped __cpp__('libvlc -> flags[10] = -1');
			if (onForward != null)
				onForward();
		}
		if (untyped __cpp__('libvlc -> flags[11]') == 1) {
			untyped __cpp__('libvlc -> flags[11] = -1');
			if (onBackward != null)
				onBackward();
		}
	}

	private function videoInitComplete():Void {
		if (bitmapData != null)
			bitmapData.dispose();

		bitmapData = new BitmapData(libvlc.getWidth(), libvlc.getHeight(), true, 0);

		smoothing = true;

		if (_width != null)
			width = _width;
		else
			width = libvlc.getWidth();

		if (_height != null)
			height = _height;
		else
			height = libvlc.getHeight();

		bufferMemory = [];

		initComplete = true;

		if (onReady != null)
			onReady();

		#if HXC_DEBUG_TRACE
		trace("Video Loaded!");
		#end
	}

	private function init(?e:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		libvlc = LibVLC.create();

		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function onEnterFrame(?e:Event):Void {
		render();
		checkFlags();
	}

	private var oldTime:Int = 0;

	private function render():Void {
		if (libvlc.isPlaying() && initComplete && !isDisposed) {
			var cTime = Lib.getTimer();

			if ((cTime - oldTime) > 28) // min 28 ms between renders, but this is not a good way to do it...
			{
				oldTime = cTime;

				#if HXC_DEBUG_TRACE
				trace("rendering...");
				#end

				var width = libvlc.getWidth();
				var height = libvlc.getHeight();
				
				var length = width * height * 4;
				if (libvlc.getPixelData() != null) // libvlc.getPixelData() sometimes is null and the app hangs ...
					NativeArray.setUnmanagedData(bufferMemory, libvlc.getPixelData(), length);

				if (bufferMemory != null && bitmapData != null) {
					var bytes:ByteArray = Bytes.ofData(cast(bufferMemory));
					if (bytes.bytesAvailable >= length)
						bitmapData.setPixels(new Rectangle(0, 0, width, height), bytes);
				}
			}
		}
	}

	/**
		Dispose the hole bitmap.
	**/
	public function dispose():Void {
		#if HXC_DEBUG_TRACE
		trace("Disposing the bitmap!");
		#end

		libvlc.stop();

		if (stage.hasEventListener(Event.ENTER_FRAME))
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

		if (bitmapData != null) {
			bitmapData.dispose();
			bitmapData = null;
		}

		if (bufferMemory != null)
			bufferMemory = null;

		onReady = null;
		onComplete = null;
		onPause = null;
		onOpening = null;
		onPlay = null;
		onResume = null;
		onStop = null;
		onBuffer = null;
		onTimeChanged = null;
		onPositionChanged = null;
		onSeekableChanged = null;
		onForward = null;
		onBackward = null;
		onError = null;

		initComplete = false;
		isDisposed = true;
	}

	@:noCompletion private function get_videoHeight():Int {
		if (libvlc != null && initComplete)
			return libvlc.getHeight();

		return 0;
	}

	@:noCompletion private function get_videoWidth():Int {
		if (libvlc != null && initComplete)
			return libvlc.getWidth();

		return 0;
	}

	private override function get_width():Float {
		return _width;
	}

	public override function set_width(value:Float):Float {
		_width = value;
		return super.set_width(value);
	}

	private override function get_height():Float {
		return _height;
	}

	public override function set_height(value:Float):Float {
		_height = value;
		return super.set_height(value);
	}

	private function get_volume():Float {
		return volume;
	}

	private function set_volume(value:Float):Float {
		setVolume(value);
		return volume = value;
	}
}
