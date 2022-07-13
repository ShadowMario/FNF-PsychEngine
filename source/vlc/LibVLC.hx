package vlc;

#if !(desktop || android)
#error "The current target platform isn't supported by hxCodec. If you are targeting Windows/Mac/Linux/Android and you are getting this message, please contact us.";
#end
import cpp.Pointer;
import cpp.UInt8;

/**
 * ...
 * @author Tommy Svensson
 */
/**
 * This class lets you to use the c++ code of libvlc as a extern class which you can use in HaxeFlixel
 */
@:buildXml("<include name='${haxelib:hxCodec}/src/vlc/LibVLCBuild.xml' />")
@:include("LibVLC.h")
@:unreflective
@:keep
@:native("LibVLC*")
extern class LibVLC {
	@:native("LibVLC::create")
	public static function create():LibVLC;

	@:native("playFile")
	public function playFile(path:String, loop:Bool, haccelerated:Bool):Void;

	@:native("play")
	public function play():Void;

	@:native("stop")
	public function stop():Void;

	@:native("pause")
	public function pause():Void;

	@:native("resume")
	public function resume():Void;

	@:native("togglePause")
	public function togglePause():Void;

	@:native("getLength")
	public function getLength():Float;

	@:native("getDuration")
	public function getDuration():Float;

	@:native("getFPS")
	public function getFPS():Float;

	@:native("getWidth")
	public function getWidth():Int;

	@:native("getHeight")
	public function getHeight():Int;

	@:native("isPlaying")
	public function isPlaying():Bool;

	@:native("isSeekable")
	public function isSeekable():Bool;

	@:native("getLastError")
	public function getLastError():String;

	@:native("setVolume")
	public function setVolume(volume:Float):Void;

	@:native("getVolume")
	public function getVolume():Float;

	@:native("setTime")
	public function setTime(time:Int):Void;

	@:native("getTime")
	public function getTime():Int;

	@:native("setPosition")
	public function setPosition(pos:Float):Void;

	@:native("getPosition")
	public function getPosition():Float;

	@:native("getPixelData")
	public function getPixelData():Pointer<UInt8>;

	@:native("flags")
	public var flags:Array<Int>;
}
