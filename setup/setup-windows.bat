@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install hmm
haxelib run hmm install
echo Finished!
pause
