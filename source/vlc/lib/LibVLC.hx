package vlc.lib;

#if cpp
import cpp.Pointer;
import cpp.UInt8;
#end

/**
 * ...
 * @author Tommy S
 */
//
@:buildXml('<include name="${haxelib:hxCodec}/vlc/lib/LibVLCBuild.xml" />')

@:include("LibVLC.h")
@:unreflective
@:keep
@:native("LibVLC*")
extern class LibVLC
{
	@:native("LibVLC::create")
	public static function create():LibVLC;

	@:native("setPath")
	public function setPath(path:String):Void;

	@:native("openMedia")
	public function openMedia(path:String):Void;

	@:native("play")
	@:overload(function():Void {})
	public function play(path:String):Void;

	@:native("playInWindow")
	@:overload(function():Void {})
	public function playInWindow(path:String):Void;

	@:native("stop")
	public function stop():Void;

	@:native("pause")
	public function pause():Void;

	@:native("resume")
	public function resume():Void;

	@:native("togglePause")
	public function togglePause():Void;

	@:native("fullscreen")
	public function setWindowFullscreen(fullscreen:Bool):Void;

	@:native("showMainWindow")
	public function showMainWindow(show:Bool):Void;

	@:native("getLength")
	public function getLength():Float;

	@:native("getDuration")
	public function getDuration():Float;

	@:native("getWidth")
	public function getWidth():Int;

	@:native("getHeight")
	public function getHeight():Int;

	@:native("getMeta")
	public function getMeta(meta:Dynamic):String;

	@:native("isPlaying")
	public function isPlaying():Bool;

	@:native("isSeekable")
	public function isSeekable():Bool;

	@:native("setVolume")
	public function setVolume(volume:Float):Void;

	@:native("getVolume")
	public function getVolume():Float;

	@:native("getTime")
	public function getTime():Int;

	@:native("setTime")
	public function setTime(time:Int):Void;

	@:native("getPosition")
	public function getPosition():Float;

	@:native("setPosition")
	public function setPosition(pos:Float):Void;

	@:native("useHWacceleration")
	public function useHWacceleration(hwAcc:Bool):Void;

	@:native("getLastError")
	public function getLastError():String;

	@:native("getRepeat")
	public function getRepeat():Int;

	@:native("setRepeat")
	public function setRepeat(repeat:Int = 1):Void;

	#if cpp
	@:native("getPixelData")
	public function getPixelData():Pointer<UInt8>;
	#end

	@:native("getFPS")
	public function getFPS():Float;

	@:native("flags")
	public var flags:Array<Int>;
}
