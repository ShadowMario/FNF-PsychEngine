package backend;

import lime.app.Application;
import lime.system.Display;
import lime.system.System;

import flixel.util.FlxColor;

#if (cpp && windows)
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows"/>
	<lib name="gdi32.lib" if="windows"/>
</target>
')
@:cppFileCode('
#include <windows.h>
#include <dwmapi.h>
#include <winuser.h>
#include <wingdi.h>

#define attributeDarkMode 20
#define attributeDarkModeFallback 19

#define attributeCaptionColor 34
#define attributeTextColor 35
#define attributeBorderColor 36

struct HandleData {
	DWORD pid = 0;
	HWND handle = 0;
};

BOOL CALLBACK findByPID(HWND handle, LPARAM lParam) {
	DWORD targetPID = ((HandleData*)lParam)->pid;
	DWORD curPID = 0;

	GetWindowThreadProcessId(handle, &curPID);
	if (targetPID != curPID || GetWindow(handle, GW_OWNER) != (HWND)0 || !IsWindowVisible(handle)) {
		return TRUE;
	}

	((HandleData*)lParam)->handle = handle;
	return FALSE;
}

HWND curHandle = 0;
void getHandle() {
	if (curHandle == (HWND)0) {
		HandleData data;
		data.pid = GetCurrentProcessId();
		EnumWindows(findByPID, (LPARAM)&data);
		curHandle = data.handle;
	}
}
')
#end
class Native
{
	public static function __init__():Void
	{
		registerDPIAware();
	}

	public static function registerDPIAware():Void
	{
		#if (cpp && windows)
		// DPI Scaling fix for windows 
		// this shouldn't be needed for other systems
		// Credit to YoshiCrafter29 for finding this function
		untyped __cpp__('
			SetProcessDPIAware();	
			#ifdef DPI_AWARENESS_CONTEXT
			SetProcessDpiAwarenessContext(
				#ifdef DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
				DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
				#else
				DPI_AWARENESS_CONTEXT_SYSTEM_AWARE
				#endif
			);
			#endif
		');
		#end
	}

	private static var fixedScaling:Bool = false;
	public static function fixScaling():Void
	{
		if (fixedScaling) return;
		fixedScaling = true;

		#if (cpp && windows)
		final display:Null<Display> = System.getDisplay(0);
		if (display != null)
		{
			final dpiScale:Float = display.dpi / 96;
			@:privateAccess Application.current.window.width = Std.int(Main.game.width * dpiScale);
			@:privateAccess Application.current.window.height = Std.int(Main.game.height * dpiScale);

			Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
			Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		}

		untyped __cpp__('
			getHandle();
			if (curHandle != (HWND)0) {
				HDC curHDC = GetDC(curHandle);
				RECT curRect;
				GetClientRect(curHandle, &curRect);
				FillRect(curHDC, &curRect, (HBRUSH)GetStockObject(BLACK_BRUSH));
				ReleaseDC(curHandle, curHDC);
			}
		');
		#end
	}

	/**
	 * Enables or disables dark mode support for the title bar.
	 * Only works on Windows.
	 * 
	 * @param enable Whether to enable or disable dark mode support.
	 * @param instant Whether to skip the transition tween.
	 */
	public static function setWindowDarkMode(enable:Bool = true, instant:Bool = false):Void
	{
		#if (cpp && windows)
		var success:Bool = false;
		untyped __cpp__('
			getHandle();
			if (curHandle != (HWND)0) {
				const BOOL darkMode = enable ? TRUE : FALSE;
				if (
					S_OK == DwmSetWindowAttribute(curHandle, attributeDarkMode, (LPCVOID)&darkMode, (DWORD)sizeof(darkMode)) ||
					S_OK == DwmSetWindowAttribute(curHandle, attributeDarkModeFallback, (LPCVOID)&darkMode, (DWORD)sizeof(darkMode))
				) {
					success = true;
				}

				UpdateWindow(curHandle);
			}
		');

		if (instant && success)
		{
			final curBarColor:Null<FlxColor> = windowBarColor;
			windowBarColor = FlxColor.BLACK;
			windowBarColor = curBarColor;
		}
		#end
	}

	/**
	 * The color of the window title bar. If `null`, the default is used.
	 * Only works on Windows.
	 */
	public static var windowBarColor(default, set):Null<FlxColor> = null;
	public static function set_windowBarColor(value:Null<FlxColor>):Null<FlxColor>
	{
		#if (cpp && windows)
		final intColor:Int = Std.isOfType(value, Int) ? cast FlxColor.fromRGB(value.blue, value.green, value.red, value.alpha) : 0xffffffff;
		untyped __cpp__('
			getHandle();
			if (curHandle != (HWND)0) {
				const COLORREF targetColor = (COLORREF)intColor;
				DwmSetWindowAttribute(curHandle, attributeCaptionColor, (LPCVOID)&targetColor, (DWORD)sizeof(targetColor));
				UpdateWindow(curHandle);
			}
		');
		#end
	
		return windowBarColor = value;
	}

	/**
	 * The color of the window title bar text. If `null`, the default is used.
	 * Only works on Windows.
	 */
	public static var windowTextColor(default, set):Null<FlxColor> = null;
	public static function set_windowTextColor(value:Null<FlxColor>):Null<FlxColor>
	{
		#if (cpp && windows)
		final intColor:Int = Std.isOfType(value, Int) ? cast FlxColor.fromRGB(value.blue, value.green, value.red, value.alpha) : 0xffffffff;
		untyped __cpp__('
			getHandle();
			if (curHandle != (HWND)0) {
				const COLORREF targetColor = (COLORREF)intColor;
				DwmSetWindowAttribute(curHandle, attributeTextColor, (LPCVOID)&targetColor, (DWORD)sizeof(targetColor));
				UpdateWindow(curHandle);
			}
		');
		#end

		return windowTextColor = value;
	}

	/**
	 * The color of the window border. If `null`, the default is used.
	 * Only works on Windows.
	 */
	public static var windowBorderColor(default, set):Null<FlxColor> = null;
	public static function set_windowBorderColor(value:Null<FlxColor>):Null<FlxColor>
	{
		#if (cpp && windows)
		final intColor:Int = Std.isOfType(value, Int) ? cast FlxColor.fromRGB(value.blue, value.green, value.red, value.alpha) : 0xffffffff;
		untyped __cpp__('
			getHandle();
			if (curHandle != (HWND)0) {
				const COLORREF targetColor = (COLORREF)intColor;
				DwmSetWindowAttribute(curHandle, attributeBorderColor, (LPCVOID)&targetColor, (DWORD)sizeof(targetColor));
				UpdateWindow(curHandle);
			}
		');
		#end
	
		return windowBorderColor = value;
	}
}