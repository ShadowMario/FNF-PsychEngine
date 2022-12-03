@echo off
color 0a
cd ..
@echo on
echo BUILDING GAME
haxelib run lime test html5 -release
pause