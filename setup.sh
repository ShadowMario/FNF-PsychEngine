#!/bin/bash
# FOR LINUX, based off of setup.bat
# go to https://haxe.org/download/linux/ to install the latest version of Haxe
# you may or may not need to run "haxelib setup"
# you may also need to run "chmod +x setup" to mark this file as an executable
haxelib install hxcpp > nul
haxelib install lime
haxelib install openfl
haxelib --never install flixel
haxelib install flixel-tools
haxelib install flixel-ui
haxelib install flixel-addons
haxelib install tjson
haxelib install hxjsonast
haxelib install hscript
haxelib install hxcpp-debug-server
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
haxelib git hscript-ex https://github.com/ianharrigan/hscript-ex
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec
haxelib run flixel-tools setup
haxelib run lime setup flixel
haxelib run lime setup