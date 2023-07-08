#Linux Setup
sudo apt-get install libvlc-dev libvlccore-dev libvlc-bin vlc-bin haxe g++
mkdir ~/haxelib && haxelib setup ~/haxelib
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc.git
haxelib install flixel-addons 3.0.2
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.5.0
haxelib install flixel 5.2.2
haxelib install hscript 2.5.0
haxelib install hxCodec 2.5.1
haxelib install lime 8.0.1
haxelib run lime setup
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git
haxelib install openfl 9.2.1
haxelib git FNF-PyschEngine https://github.com/12abz/FNF-PsychEngine.git
cd ~/haxelib/FNF*/git/
lime build linux
#Script For Psych Engine
