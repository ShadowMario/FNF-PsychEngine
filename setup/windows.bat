@echo off
color 0a
cd ..
@echo on
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install lime 8.1.2
haxelib install openfl 9.3.3
haxelib install flixel 5.6.1
haxelib install flixel-addons 3.2.2
haxelib install flixel-tools 1.5.1
haxelib install hscript-iris 1.0.2
haxelib install tjson 1.4.0
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 633fcc051399afed6781dd60cbf30ed8c3fe2c5a
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc 3538a1c2bb07b04208cd014220207f8173acdb21
haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc 70e7f5f3e76d526ac6fb8f0e6665efe7dfda589d
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis d5361037efa3a02c4ab20b5bd14ca11e7d00f519
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
echo Finished!
pause
