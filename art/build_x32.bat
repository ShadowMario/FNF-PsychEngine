@echo off
color 0a
cd ..
echo BUILDING GAME
lime build windows -release -32
echo.
echo done.
pause
pwd
explorer.exe export\release\windows\bin