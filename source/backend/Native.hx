package backend;

import lime.app.Application;
import lime.system.Display;
import lime.system.System;

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

const DWMWINDOWATTRIBUTE darkModeAttribute = (DWMWINDOWATTRIBUTE)20;
const DWMWINDOWATTRIBUTE darkModeAttributeFallback = (DWMWINDOWATTRIBUTE)19; // Pre-20H1

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
			BOOL success = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
			if (!success) success = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE);
			if (!success) success = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_SYSTEM_AWARE);
			if (!success) SetProcessDPIAware();
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
	 * 
	 * @param enable Whether to enable or disable dark mode support.
	 * @param instant Whether to skip the transition tween.
	 */
	public static function setWindowDarkMode(enable:Bool = true, instant:Bool = false):Void
	{
		#if (cpp && windows)
		untyped __cpp__('
			const BOOL darkMode = enable ? TRUE : FALSE;

			getHandle();
			if (curHandle != (HWND)0) {
				if (S_OK != DwmSetWindowAttribute(curHandle, darkModeAttribute, (LPCVOID)&darkMode, (DWORD)sizeof(darkMode))) {
					DwmSetWindowAttribute(curHandle, darkModeAttributeFallback, (LPCVOID)&darkMode, (DWORD)sizeof(darkMode));
				}

				UpdateWindow(curHandle);
			}
		');
		
		if (instant)
		{
			setWindowColors(0xff000000);
			setWindowColors();
		}
		#end
	}

	/**
	 * Sets window colors.
	 * 
	 * If any of the parameters are not provided, the corresponding color is reset to the system default.
	 * 
	 * @param bar The color to use for the title bar.
	 * @param text The color to use for the title bar text.
	 * @param border The color to use for the window border.
	 */
	public static function setWindowColors(?bar:FlxColor, ?text:FlxColor, ?border:FlxColor):Void
	{
		#if (cpp && windows)
		var intBar:Int = 0xffffffff;
		var intText:Int = 0xffffffff;
		var intBorder:Int = 0xffffffff;
		if (Std.isOfType(bar, Int)) intBar = cast FlxColor.fromRGB(bar.blue, bar.green, bar.red, 0);
		if (Std.isOfType(text, Int)) intText = cast FlxColor.fromRGB(text.blue, text.green, text.red, 0);
		if (Std.isOfType(border, Int)) intBorder = cast FlxColor.fromRGB(border.blue, border.green, border.red, 0);

		untyped __cpp__('
			COLORREF targetBar = (COLORREF)intBar;
			COLORREF targetText = (COLORREF)intText;
			COLORREF targetBorder = (COLORREF)intBorder;

			getHandle();
			DwmSetWindowAttribute(curHandle, DWMWINDOWATTRIBUTE::DWMWA_CAPTION_COLOR, (LPCVOID)&targetBar, (DWORD)sizeof(targetBar));
			DwmSetWindowAttribute(curHandle, DWMWINDOWATTRIBUTE::DWMWA_TEXT_COLOR, (LPCVOID)&targetText, (DWORD)sizeof(targetText));
			DwmSetWindowAttribute(curHandle, DWMWINDOWATTRIBUTE::DWMWA_BORDER_COLOR, (LPCVOID)&targetBorder, (DWORD)sizeof(targetBorder));
			UpdateWindow(curHandle);
		');
		#end
	}
}