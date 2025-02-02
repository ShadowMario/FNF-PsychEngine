@echo off
color 0a
cd ..
cd ..
echo BUILDING GAME
haxelib run lime test windows -debug
echo.
echo done.
pause