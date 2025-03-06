package backend;

import lime.app.Application;
import lime.system.Display;
import lime.system.System;

#if (cpp && windows)
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows"/>
</target>
')
@:cppFileCode('
#include <windows.h>
#include <dwmapi.h>
#include <winuser.h>

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
	private static var registeredDPIAware:Bool = false;
	public static function registerDPIAware(width:Int = 1280, height:Int = 720):Void
	{
		if (registeredDPIAware) return;

		#if (cpp && windows)
		// DPI Scaling fix for windows 
		// this shouldn't be needed for other systems
		// Credit to YoshiCrafter29 for finding this function
		untyped __cpp__('SetProcessDPIAware();');

		final display:Null<Display> = System.getDisplay(0);
		if (display != null)
		{
			final dpiScale:Float = display.dpi / 96;
			Application.current.window.width = Std.int(width * dpiScale);
			Application.current.window.height = Std.int(height * dpiScale);

			Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
			Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		}
		#end

		registeredDPIAware = true;
	}

	/**
	 * Enables or disables dark mode support for the title bar.
	 */
	public static function setWindowDarkMode(enable:Bool = true):Void
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
		#end
	}
}