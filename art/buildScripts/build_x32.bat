@echo off
color 0a
cd ..
echo BUILDING GAME
haxelib run lime build windows -32 -release -D 32bits -D HXCPP_M32
echo.
echo done.
pause
pwd
explorer.exe export\32bit\windows\bin