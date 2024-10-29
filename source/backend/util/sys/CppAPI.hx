package backend.util.sys;

import backend.util.sys.windows.Transparency;
import backend.util.sys.windows.Wallpaper;
import backend.util.sys.windows.WindowsData;
import backend.util.sys.windows.WindowsSystem;
import backend.util.sys.mac.MacData;
import backend.util.sys.linux.LinuxData;
class CppAPI
{	
	#if cpp
	#if windows
	public static function obtainRAM():Int
	{
		return WindowsData.obtainRAM();
	}

	public static function darkMode()
	{
		WindowsData.setWindowColorMode(DARK);
		flixel.FlxG.stage.window.borderless = true;
		flixel.FlxG.stage.window.borderless = false;
	}

	public static function lightMode()
	{
		WindowsData.setWindowColorMode(LIGHT);
		flixel.FlxG.stage.window.borderless = true;
		flixel.FlxG.stage.window.borderless = false;
	}

	public static function setWindowOppacity(a:Float)
	{
		WindowsData.setWindowAlpha(a);
	}

	public static function _setWindowLayered()
	{
		WindowsData._setWindowLayered();
	}

	public static function setWallpaper(path:String)
	{
		if(path == 'old') {
			if(Wallpaper.oldWallpaper != null) {
			path = Wallpaper.oldWallpaper;
			}else{
				return;
			}}
		Wallpaper.setWallpaper(path);
	}

	public static function setOld()
	{
		Wallpaper.setOld();
	}

	public static function hideTaskbar()
	{
		WindowsData.hideTaskbar();
	}

	public static function restoreTaskbar()
	{
		WindowsData.restoreTaskbar();
	}

	public static function hideWindows()
	{
		WindowsData.hideWindows();
	}

	public static function restoreWindows()
	{
		WindowsData.restoreWindows();
	}

	public static function setTransparency(winName:String, color:Int)
	{
		Transparency.setTransparency(winName, color);
	}
	
	public static function removeWindowIcon()
	{
		WindowsData.removeWindowIcon();
	}

	public static function reset()
	{
		Transparency.reset();
	}

	public static function allowHighDPI() {
		WindowsData.registerHighDpi();
	}
	#end
	#if mac
	public static function getTotalRam():Float
	{
		return MacData.getTotalRam();
	}
	#end
	#if linux
	public static function getTotalRam():Float
	{
		return LinuxData.getTotalRam();
	}
	#end
	#end
}