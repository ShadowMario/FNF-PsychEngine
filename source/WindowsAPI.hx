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
')
#end
class WindowsAPI {
    // i have now learned the power of the windows api, FEAR ME!!!

    #if windows
    @:functionCode('
    // https://stackoverflow.com/questions/15543571/allocconsole-not-displaying-cout

    if (!AllocConsole())
        return;

    FILE* fDummy;
    freopen_s(&fDummy, "CONOUT$", "w", stdout);
    freopen_s(&fDummy, "CONOUT$", "w", stderr);
    freopen_s(&fDummy, "CONIN$", "r", stdin);
    std::cout.clear();
    std::clog.clear();
    std::cerr.clear();
    std::cin.clear();

    // std::wcout, std::wclog, std::wcerr, std::wcin
    HANDLE hConOut = CreateFile(_T("CONOUT$"), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    HANDLE hConIn = CreateFile(_T("CONIN$"), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    SetStdHandle(STD_OUTPUT_HANDLE, hConOut);
    SetStdHandle(STD_ERROR_HANDLE, hConOut);
    SetStdHandle(STD_INPUT_HANDLE, hConIn);
    std::wcout.clear();
    std::wclog.clear();
    std::wcerr.clear();
    std::wcin.clear();
    ')
    public static function allocConsole() {
        LogsOverlay.consoleOpened = LogsOverlay.consoleVisible = true;
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            // nothing here so that it keeps shit clean
        }
    }
    #else
    public static function allocConsole() {}
    #end


    #if windows
    @:functionCode('
        ShowWindow(GetConsoleWindow(), show ? 5 : 0);
    ')
    #end
    public static function showConsole(show:Bool) {
        haxe.Log.trace = show ? function(v:Dynamic, ?infos:haxe.PosInfos) {} : Main.baseTrace;
        LogsOverlay.consoleVisible = show;
    }
    #if windows
    @:functionCode('
        int darkMode = 1;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
    #end
    public static function setWindowToDarkMode() {}


    #if windows
    @:functionCode('
        HWND window = GetActiveWindow();

        // make window layered
        alpha = SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        SetLayeredWindowAttributes(window, RGB(red, green, blue), 0, LWA_COLORKEY);
    ')
    #end
    public static function setWindowTransparencyColor(red:Int, green:Int, blue:Int, alpha:Int) {
        return alpha;
    }

    @:functionCode('
        HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE); 
        SetConsoleTextAttribute(console, color);
    ')
    public static function __setConsoleColors(color:Int) {

    }

    public static function setConsoleColors(foregroundColor:ConsoleColor = LIGHTGRAY, ?backgroundColor:ConsoleColor = BLACK) {
        var fg = cast(foregroundColor, Int);
        var bg = cast(backgroundColor, Int);
        __setConsoleColors((bg * 16) + fg);
    }

    @:functionCode('
        system("CLS");
        std::cout<< "" <<std::flush;
    ')
    public static function clearScreen() {

    }
}

@:enum abstract ConsoleColor(Int) {
    var BLACK:ConsoleColor = 0;
    var DARKBLUE:ConsoleColor = 1;
    var DARKGREEN:ConsoleColor = 2;
    var DARKCYAN:ConsoleColor = 3;
    var DARKRED:ConsoleColor = 4;
    var DARKMAGENTA:ConsoleColor = 5;
    var DARKYELLOW:ConsoleColor = 6;
    var LIGHTGRAY:ConsoleColor = 7;
    var GRAY:ConsoleColor = 8;
    var BLUE:ConsoleColor = 9;
    var GREEN:ConsoleColor = 10;
    var CYAN:ConsoleColor = 11;
    var RED:ConsoleColor = 12;
    var MAGENTA:ConsoleColor = 13;
    var YELLOW:ConsoleColor = 14;
    var WHITE:ConsoleColor = 15;
}