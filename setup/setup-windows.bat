@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install lime
haxelib install openfl
haxelib install flixel 5.6.2
haxelib set flixel 5.6.2
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install flixel-tools
haxelib install hxCodec
haxelib install tjson
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc
haxelib git SScript https://github.com/Oren-LuckyJackpots/SScript-For-Psych 8.1.6
echo Finished!
pause
