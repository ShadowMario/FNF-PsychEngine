# Friday Night Funkin' - YoshiCrafter Engine
![Yoshi Engine's logo](art/banner_new.png)

This is the repository of Yoshi Engine, a modification of Friday Night Funkin' which allows full modding without source code access.

The documentation is [here](documentation/index.md) (in construction), feel free to download it for offline use !

Thanks to PolybiusProxy for the [MP4 Cutscene Support](https://github.com/brightfyregit/Friday-Night-Funkin-Mp4-Video-Support) !

Also, if you're going to mod it, do NOT include the executable with it, only your mod in the "mods" folder. The goal of this engine is to have one instance of FNF with every mods in it

## Here's a full list of Yoshi Engine's functionnalities :
- **Full mod support**
	- Songs
	- Characters
	- Stages
	- Modcharts
	- Custom notes
	- Cutscenes
	- Weeks
	- Credits
- **Customization**
	- Custom keybinds
	- Downscroll
	- Custom scroll speed
	- GUI scale
	- **GUI Options**
		- Accuracy mode
		- Text quality level
		- Timer
		- Press delay
		- Accuracy
		- Number of misses
		- Average hit delay
		- Rating
		- Animated info bar
	- Custom note colors
	- Custom note skins
	- Custom Boyfriend skins
	- Custom Girlfriend skins
- Botplay
- Green Screen Mode
- New charter
- Freeplay Statistics
- **Developer Mode**
	- In game logs
	- Disables cache
	- Character debug mode

## People who helped me
- **AbnormalPoof** for the pretty printing of chart jsons.

## How to install a mod
1. Download an Yoshi Engine mod
2. Get the mod folder (in the root or in a "mods" folder, or see instructions)
3. Copy over to the "mods" folder
4. Restart the engine
5. Enjoy !

---
# Friday Night Funkin

This is the repository for Friday Night Funkin, a game originally made for Ludum Dare 47 "Stuck In a Loop".

Play the Ludum Dare prototype here: https://ninja-muffin24.itch.io/friday-night-funkin
Play the Newgrounds one here: https://www.newgrounds.com/portal/view/770371
Support the project on the itch.io page: https://ninja-muffin24.itch.io/funkin

IF YOU MAKE A MOD AND DISTRIBUTE A MODIFIED / RECOMPILED VERSION, YOU MUST OPEN SOURCE YOUR MOD AS WELL

## Credits / shoutouts

- [ninjamuffin99 (me!)](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Kawaisprite](https://twitter.com/kawaisprite) - Musician

This game was made with love to Newgrounds and its community. Extra love to Tom Fulp.

## Build instructions

THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD AND INSTALL AND PLAY THE GAME NORMALLY, GO TO ITCH.IO TO DOWNLOAD THE GAME FOR PC, MAC, AND LINUX!!

https://ninja-muffin24.itch.io/funkin

IF YOU WANT TO COMPILE THE GAME YOURSELF, CONTINUE READING!!!

### Installing the Required Programs

First, you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple). 
1. [Install Haxe 4.1.5](https://haxe.org/download/version/4.1.5/) (Download 4.1.5 instead of 4.2.0 because 4.2.0 is broken and is not working with gits properly...)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need are the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
newgrounds
```
So for each of those type `haxelib install [library]` so shit like `haxelib install newgrounds`

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
4. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.
5. Run `haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit` to install hxvm-luajit.
6. Run `haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit` to install linc_luajit.
6. Run `haxelib git flixel-textureatlas-yoshiengine https://github.com/YoshiCrafter29/Flixel-TextureAtlas-YoshiCrafterEngine` to install texture atlas support.

You should have everything ready for compiling the game! Follow the guide below to continue!

At the moment, you can optionally fix the transition bug in songs with zoomed-out cameras.
- Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` in the terminal/command-prompt.

### Ignored files

I gitignore the API keys for the game so that no one can nab them and post fake high scores on the leaderboards. But because of that the game
doesn't compile without it.

Just make a file in `/source` and call it `APIStuff.hx`, and copy & paste this into it

```haxe
package;

class APIStuff
{
	public static var API:String = "";
	public static var EncKey:String = "";
}

```

and you should be good to go there.

### Compiling game
NOTE: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling

Once you have all those installed, it's pretty easy to compile the game. You just need to run `lime test html5 -debug` in the root of the project to build and run the HTML5 version. (command prompt navigation guide can be found here: [https://ninjamuffin99.newgrounds.com/news/post/1090480](https://ninjamuffin99.newgrounds.com/news/post/1090480))
To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run `lime test linux -debug` and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Once that is done you can open up a command line in the project's directory and run `lime test windows -debug`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

### Additional guides

- [Command line basics](https://ninjamuffin99.newgrounds.com/news/post/1090480)
