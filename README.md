# Friday Night Funkin' - Psych Engine
Engine originally used on [Mind Games Mod](https://gamebanana.com/mods/301107), intended to be a fix for the vanilla version's many issues while keeping the casual play aspect of it. Also aiming to be an easier alternative to newbie coders.

# Installation:

If you just want to play Friday Night Funkin': Psych Engine, just download and play here: (put updated gamebanana hyperlink thingie here)

## Visual Studio
`windows` To install the software needed to compile: install [Visual Studio 19](https://visualstudio.microsoft.com/vs/older-downloads/#visual-studio-2019-and-other-products) and ONLY these components:
```
MSVC v142 - VS 2019 C++ x64/x86 build tools
Windows SDK (10.0.17763.0)
```
`Other Platforms` Do nothing.

## Command Prompt/Terminal
`windows` any of these methods should send you to a terminal, where you can run commands needed to compile the game.
```
Ctrl + Shift + p, and set directory.

open your directory, select Project.xml, and click "file" > "Open Windows Powershell".
```

`mac` any of these methods should send you to a terminal, where you can run commands needed to compile the game.
```
Open Terminal in Launchpad's Utillities folder.

Spotlight Search for Terminal.
```

## Haxe
You must have [the most up-to-date version of Haxe](https://haxe.org/download/) (4.2.4+) in order to compile.

## HaxeFlixel
To install the latest stable version of HaxeFlixel needed to compile, run the following commands:

```
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
```
You can update HaxeFlixel anytime by running this command:
```
haxelib update flixel
```
## Funkin' Addons
To install additonal libraries needed to compile, run the following commands:
```
haxelib install flixel
haxelib install flixel addons
haxelib install flixel-ui
haxelib install hscript
haxelib install newgrounds
```
## GIT-scm
To make installing packages from GitHub repositories easier, [install GIT-scm](https://git-scm.com/downloads)
 
After installing GIT-scm, run the following commands:
```
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```
Don't use discord??? Ignore these, and delete the text on line 133 of Project.xml: `<haxelib name="discord_rpc" if="desktop"/>`
## Funkin' Lua
To instal the LuaScript API for Friday Night Funkin', run the following command:
```
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
```
...Or don't. To play without the luascript API, delete the text on line 47 of Project.xml: `<define name="LUA_ALLOWED" if="desktop" />`

## Compilation
Run the correlating commands in the Terminal that match your build target to compile.

Note: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling.

`windows`
```
lime test windows
lime test windows -debug
```

`linux`
```
lime test linux
lime test linux debug
```

`html5`
``` 
lime test html5
lime test html5 -debug
```

`mac`
```
lime test mac
lime test mac -debug
```

## Credits:
* Shadow Mario - Coding
* RiverOaken - Arts and Animations
* bbpanzu - Assistant Coding

### Special Thanks
* shubs - New Input System
* SqirraRNG - Chart Editor's Sound Waveform base code
* iFlicky - Delay/Combo Menu Song Composer + Dialogue Sounds
* PolybiusProxy - .MP4 Loader Extension
* Keoiki - Note Splash Animations
* Smokey - Spritemap Texture Atlas support
* Cary - OG Resolution code
* Nebula_Zorua - VCR Shader code
_____________________________________

# Features

## Attractive animated dialogue boxes:

![](https://user-images.githubusercontent.com/44785097/127706669-71cd5cdb-5c2a-4ecc-871b-98a276ae8070.gif)


## Mod Support
* Probably one of the main points of this engine, you can code in .lua files outside of the source code, making your own weeks without even messing with the source!
* Comes with a Mod Organizing/Disabling Menu. 


## Atleast one change to every week:
### Week 1:
  * New Dad Left sing sprite 
  * Unused stage lights are now used
### Week 2:
  * Both BF and Skid & Pump does "Hey!" animations
  * Thunders does a quick light flash and zooms the camera in slightly
  * Added a quick transition/cutscene to Monster
### Week 3:
  * BF does "Hey!" during Philly Nice
  * Blammed has a cool new colors flash during that sick part of the song
### Week 4:
  * Better hair physics for Mom/Boyfriend (Maybe even slightly better than Week 7's :eyes:)
  * Henchmen die during all songs. Yeah :(
### Week 5:
  * Bottom Boppers and GF does "Hey!" animations during Cocoa and Eggnog
  * On Winter Horrorland, GF bops her head slower in some parts of the song.
### Week 6:
  * On Thorns, the HUD is hidden during the cutscene
  * Also there's the Background girls being spooky during the "Hey!" parts of the Instrumental

## Cool new Chart Editor changes and countless bug fixes
![](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/docs/img/chart.png?raw=true)
* You can now chart "Event" notes, which are bookmarks that trigger specific actions that usually were hardcoded on the vanilla version of the game.
* Your song's BPM can now have decimal values
* You can manually adjust a Note's strum time if you're really going for milisecond precision
* You can change a note's type on the Editor, it comes with two example types:
  * Alt Animation: Forces an alt animation to play, useful for songs like Ugh/Stress
  * Hey: Forces a "Hey" animation instead of the base Sing animation, if Boyfriend hits this note, Girlfriend will do a "Hey!" too.

## Multiple editors to assist you in making your own Mod
![Screenshot_3](https://user-images.githubusercontent.com/44785097/144629914-1fe55999-2f18-4cc1-bc70-afe616d74ae5.png)
* Working both for Source code modding and Downloaded builds!

## Story mode menu rework:
![](https://i.imgur.com/UB2EKpV.png)
* Added a different BG to every song (less Tutorial)
* All menu characters are now in individual spritesheets, makes modding it easier.

## Credits menu
![Screenshot_1](https://user-images.githubusercontent.com/44785097/144632635-f263fb22-b879-4d6b-96d6-865e9562b907.png)
* You can add a head icon, name, description and a Redirect link for when the player presses Enter while the item is currently selected.

## Awards/Achievements
* The engine comes with 16 example achievements that you can mess with and learn how it works (Check Achievements.hx and search for "checkForAchievement" on PlayState.hx)

## Options menu:
* You can change Note colors, Delay and Combo Offset, Controls and Preferences there.
 * On Preferences you can toggle Downscroll, Middlescroll, Anti-Aliasing, Framerate, Low Quality, Note Splashes, Flashing Lights, etc.

## Other gameplay features:
* When the enemy hits a note, their strum note also glows.
* Lag doesn't impact the camera movement and player icon scaling anymore.
* Some stuff based on Week 7's changes has been put in (Background colors on Freeplay, Note splashes)
* You can reset your Score on Freeplay/Story Mode by pressing Reset button.
* You can listen to a song or adjust Scroll Speed/Damage taken/etc. on Freeplay by pressing Space.
