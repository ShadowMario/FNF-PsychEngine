package backend.util.sys.windows;

#if windows
@:headerCode('
    #include <windows.h>
    #include <iostream>
    #include <string>
    #include <hxcpp.h>
')
class Wallpaper
{
	@:noCompletion
	public static var oldWallpaper(default, null):String;

	@:noCompletion
	public static function setOld():Void
	{
		oldWallpaper = _setOld();
	}

	@:functionCode('
        wchar_t* wallpath = const_cast<wchar_t*>(path.wchar_str());
        SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, reinterpret_cast<void*>(wallpath), SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    ')
	@:noCompletion
	public static function setWallpaper(path:String):Void
		return;

	@:functionCode('
        WCHAR buffer[1024] = {0};
        SystemParametersInfoW(SPI_GETDESKWALLPAPER, 256, &buffer, NULL);
        return String(buffer);
    ')
	@:noCompletion
	private static function _setOld():String
		return "";
}
#end
