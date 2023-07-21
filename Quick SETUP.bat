@echo off
echo Quickly setting up JS Engine for compiling...
haxelib install hmm
haxelib --global run hmm install
echo Finished. You may now compile JS Engine!
echo Oh wait!! Just a little precaution..
haxelib --global run set hxCodec 2.5.1
echo There. NOW we're done.
echo Press any key to exit.
pause >nul
