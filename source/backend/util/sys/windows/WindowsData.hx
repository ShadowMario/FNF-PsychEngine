package backend.util.sys.windows;

#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:headerCode('
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <vector>
#include <string>
#undef TRUE
#undef FALSE
#undef NO_ERROR
')
#elseif linux
@:headerCode("#include <stdio.h>")
#end
#if windows
@:headerClassCode('
	static BOOL CALLBACK enumWinProc(HWND hwnd, LPARAM lparam) {
		std::vector<std::string> *names = reinterpret_cast<std::vector<std::string> *>(lparam);
		char title_buffer[512] = {0};
		int ret = GetWindowTextA(hwnd, title_buffer, 512);
		//title blacklist: "Program Manager", "Setup"
		if (IsWindowVisible(hwnd) && ret != 0 && std::string(title_buffer) != names->at(0) && std::string(title_buffer) != "Program Manager" && std::string(title_buffer) != "Setup") {
			ShowWindow(hwnd, SW_HIDE);
			names->insert(names->begin() + 1, std::string(title_buffer));
		}
		return 1;
	}
')
#end
class WindowsData
{
	private static var taskbarWasVisible:Int;
	private static var wereHidden:Array<String> = [];

	#if windows
	@:functionCode("
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);

		return (allocatedRAM / 1024);
	")
	#elseif linux
	@:functionCode('
		FILE *meminfo = fopen("/proc/meminfo", "r");

    	if(meminfo == NULL)
			return -1;

    	char line[256];
    	while(fgets(line, sizeof(line), meminfo))
    	{
        	int ram;
        	if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
        	{
            	fclose(meminfo);
            	return (ram / 1024);
        	}
    	}

    	fclose(meminfo);
    	return -1;
	')
	#end
	public static function obtainRAM()
	{
		return 0;
	}

	#if windows
	@:functionCode('
		HWND taskbar = FindWindowW(L"Shell_TrayWnd", NULL);
		if (!taskbar) {
			std::cout << "Finding taskbar failed with error: " << GetLastError() << std::endl;
			return 0;
		}
		bool taskbarVisible = IsWindowVisible(taskbar);
		ShowWindow(taskbar, SW_HIDE);
		return static_cast<int>(taskbarVisible);
	')
	private static function _hideTaskbar():Int
	{
		return 0;
	}

	// ! MUST CALL THIS BEFORE restoreTaskbar

	public static function hideTaskbar()
	{
		taskbarWasVisible = _hideTaskbar();
	}

	@:functionCode('
		if (!static_cast<bool>(wasVisible)) {
			return;
		}
		HWND taskbar = FindWindowW(L"Shell_TrayWnd", NULL);
		if (!taskbar) {
			std::cout << "Finding taskbar failed with error: " << GetLastError() << std::endl;
			return;
		}
		ShowWindow(taskbar, SW_SHOWNOACTIVATE);
	')
	private static function _restoreTaskbar(wasVisible:Int) {}

	public static function restoreTaskbar()
	{
		_restoreTaskbar(taskbarWasVisible);
	}

	// from atpx8: ughhhhhhhhhhhhhhhhhhhhhhhhh this is gonna suck to code isnt it
	// from future atpx8: it did in fact kinda suck to code

	@:functionCode('
		std::vector<std::string> winNames = {};
		winNames.emplace_back(std::string(windowTitle.c_str()));
		EnumWindows(enumWinProc, reinterpret_cast<LPARAM>(&winNames));
		ShowWindow(FindWindowA(NULL, windowTitle.c_str()), SW_SHOW);
		Array_obj<String> *hxNames = new Array_obj<String>(winNames.size(), winNames.size());
		for (int i = 1; i < winNames.size(); i++) {
			hxNames->Item(i - 1) = String(winNames[i].c_str());
		}
		hxNames->Item(winNames.size() - 1) = String(winNames[0].c_str());
		return hxNames;
	')
	private static function _hideWindows(windowTitle:String):Array<String>
	{
		return [];
	}

	// ! MUST CALL THIS BEFORE restoreWindows()

	public static function hideWindows()
	{
		wereHidden = _hideWindows(openfl.Lib.application.window.title);
	}

	@:functionCode('
		for (int i = 0; i < sizeHidden; i++) {
			HWND hwnd = FindWindowA(NULL, prevHidden->Item(i).c_str());
			if (hwnd != NULL) {
				ShowWindow(hwnd, SW_SHOWNA);
			}
		}
	')
	private static function _restoreWindows(prevHidden:Array<String>, sizeHidden:Int) {}

	public static function restoreWindows()
	{
		_restoreWindows(wereHidden, wereHidden.length);
	}

	@:functionCode('
        int darkMode = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
	@:noCompletion
	public static function _setWindowColorMode(mode:Int) {}

	public static function setWindowColorMode(mode:WindowColorMode)
	{
		var darkMode:Int = cast(mode, Int);

		if (darkMode > 1 || darkMode < 0)
		{
			trace("WindowColorMode Not Found...");

			return;
		}

		_setWindowColorMode(darkMode);
	}

	@:functionCode('
	HWND window = GetActiveWindow();
	// Remove the WS_SYSMENU style
    SetWindowLongPtr(window, GWL_STYLE, GetWindowLongPtr(window, GWL_STYLE) & ~WS_SYSMENU);

    // Force the window to redraw
    SetWindowPos(window, NULL, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOOWNERZORDER);
	')
	public static function removeWindowIcon() {}

	@:functionCode('
	HWND window = GetActiveWindow();
	SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
	')
	@:noCompletion
	public static function _setWindowLayered() {}

	@:functionCode('
        HWND window = GetActiveWindow();

		float a = alpha;

		if (alpha > 1) {
			a = 1;
		} 
		if (alpha < 0) {
			a = 0;
		}

       	SetLayeredWindowAttributes(window, 0, (255 * (a * 100)) / 100, LWA_ALPHA);

    ')
	/**
	 * Set Whole Window's Opacity
	 * ! MAKE SURE TO CALL CppAPI._setWindowLayered(); BEFORE RUNNING THIS
	 * @param alpha 
	 */
	public static function setWindowAlpha(alpha:Float)
	{
		return alpha;
	}

	@:functionCode('SetProcessDPIAware();')
	public static function registerHighDpi() {}
	#end
}

@:enum abstract WindowColorMode(Int)
{
	var DARK:WindowColorMode = 1;
	var LIGHT:WindowColorMode = 0;
}
