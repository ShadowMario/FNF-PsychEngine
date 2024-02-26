#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
#
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download/version/4.3.3/

echo "Installing dependencies."
haxelib install hmm
haxelib run hmm install
echo "Finished!"