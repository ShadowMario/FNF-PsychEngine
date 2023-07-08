#Linux Setup
sudo apt-get install libvlc-dev libvlccore-dev libvlc-bin vlc-bin haxe g++ git
mkdir ~/hxsetup
cd ~/hxsetup
wget https://github.com/HaxeFoundation/haxe/releases/download/4.2.5/haxe-4.2.5-linux64.tar.gz
tar -xf *
sudo rm /usr/bin/haxe /usr/bin/haxelib
sudo cp */haxe /usr/bin/
sudo cp */haxelib /usr/bin
sudo rm -r /usr/local/haxe/std
sudo cp -r */std /usr/local/haxe
mkdir ~/haxelib && haxelib setup ~/haxelib
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc.git
haxelib --never install flixel-addons 3.0.2
haxelib --never install flixel-tools 1.5.1
haxelib --never install flixel-ui 2.5.0
haxelib --never install flixel 5.2.2
haxelib --never install hscript 2.5.0
haxelib --never install hxCodec 2.5.1
haxelib --never install lime 8.0.1
haxelib run lime setup
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git
haxelib --never install openfl 9.2.1
#Script For Psych Engine
