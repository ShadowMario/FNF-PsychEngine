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
haxelib run hmm install
#Script For Psych Engine
