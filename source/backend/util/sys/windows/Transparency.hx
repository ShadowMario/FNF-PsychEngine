package backend.util.sys.windows;

import backend.util.*;

#if windows

@:native("HWND__") extern class HWNDStruct {}
typedef HWND = cpp.Pointer<HWNDStruct>;
typedef BOOL = Int;
typedef BYTE = Int;
typedef LONG = Int;
typedef DWORD = LONG;
typedef COLORREF = DWORD;

@:headerCode("
    #include <windows.h>
    #include <hxcpp.h>
    #include <iostream>
")
class Transparency
{
	public static var win:HWND;
	private static var winStyle:LONG;
	private static var winExStyle:LONG;

	@:native("FindWindowA") @:extern
	private static function findWindow(className:cpp.ConstCharStar, windowName:cpp.ConstCharStar):HWND
		return null;

	@:native("SetWindowLongA") @:extern
	private static function setWindowLong(hWnd:HWND, nIndex:Int, dwNewLong:LONG):LONG
		return null;

	@:native("GetWindowLongA") @:extern
	private static function getWindowLong(hWnd:HWND, nIndex:Int):LONG
		return null;

	@:native("SetLayeredWindowAttributes") @:extern
	private static function setLayeredWindowAttributes(hwnd:HWND, crKey:COLORREF, bAlpha:BYTE, dwFlags:DWORD):BOOL
		return null;

	@:native("GetLastError") @:extern
	private static function getLastError():DWORD
		return null;

	public static function setTransparency(winName:String, color:Int):Void
	{
		win = findWindow(null, winName);
		if (win == null)
		{
			trace("Error finding window!");
			trace("Code: " + Std.string(getLastError()));
		}
		winStyle = getWindowLong(win, -16);
		if (winStyle == 0)
		{
			trace("Error getting window style!");
			trace("Code: " + Std.string(getLastError()));
		}
		/*if (setWindowLong(win, -16, winStyle & ~(0x00C00000 | 0x00040000 | 0x00010000 | 0x00020000 | 0x00080000)) == 0) {
			trace("Error removing window borders!");
			trace("Code: " + Std.string(getLastError()));
		}*/
		winExStyle = getWindowLong(win, -20);
		if (winExStyle == 0)
		{
			trace("Error getting extended window style!");
			trace("Code: " + Std.string(getLastError()));
		}
		if (setWindowLong(win, -20, 0x00080000) == 0)
		{
			trace("Error setting window to be layered!");
			trace("Code: " + Std.string(getLastError()));
		}
		if (setLayeredWindowAttributes(win, color, 0, 0x00000001) == 0)
		{
			trace("Error setting color key on window!");
			trace("Code: " + Std.string(getLastError()));
		}
	}

	public static function reset():Void
	{
		/*if (setWindowLong(win, -20, winExStyle) == 0) {
				trace("Error restoring extended window style!");
				trace("Code: " + Std.string(getLastError()));
			}
			if (setWindowLong(win, -16, winStyle) == 0) {
				trace("Error restoring window borders!");
				trace("Code: " + Std.string(getLastError()));
		}*/
	}
}
#end
