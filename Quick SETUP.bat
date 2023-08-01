@echo off
echo Quickly setting up JS Engine for compiling...
haxelib setup C:/haxelib
haxelib --global install hmm
haxelib --global run hmm install
echo Finished. You may now compile JS Engine!
echo Press any key to exit.
pause >nul
