@echo off
color 0a
cd ..
echo BUILDING GAME
lime build windows -32 -release
echo.
echo done.
pause
pwd
explorer.exe export\release\windows\bin