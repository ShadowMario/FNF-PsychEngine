# Friday Night Funkin': Psych Engine

Engine that was originally used on [Mind Games Mod](https://gamebanana.com/mods/301107), intended to be a fix for vanilla's many issues while keeping the casual play aspect of it, while also aiming to be an easier alternative to newbie coders.

# Source Compiling
## Dependencies (you can just use a script to compile these libraries for you, just make sure you have haxe and git installed)
Haxe (4.2.5 recommended, latest works too) `https://haxe.org`

Git `https://git-scm.com/download`

Visual Studio Community 
`curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe`
`vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p`

Flixel `haxelib install flixel`

Lime
`haxelib install lime`
`haxelib run lime setup`

OpenFL `haxelib install openfl`

Flixel Addons `haxelib install flixel-addons`

Flixel Tools `haxelib install flixel-tools`

HXCPP `haxelib install hxcpp`

TJSON `haxelib install tjson`

HXJSONAST `haxelib install hxjsonast`

HXCodec `haxelib install hxCodec`

SScript (sscript is deleted, will push a change when new script library is added)

HXCPP Debug Server `haxelib install hxcpp-debug-server`

Discord RPC `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc`

LINC LuaJIT `haxelib git linc_luajit https://github.com/superpowers04/linc_luajit`

## Customization
If you want to, you can disable Lua scripts running or just disable videos all together. All you have to do is go over to `Project.xml` and delete the defines that you don't want, or you can just comment it out (`!-- THE LINE -->` is xml syntax for commenting).

# Credits:
* Shadow Mario - Main Programmer
* RiverOaken - Main Artist

## Special Thanks
* bbpanzu - Ex-Programmer
* Yoshubs - Ex-Assistant Programmer/New and current input system
* SqirraRNG - Crash Handler and Base code for Chart Editor's Waveform
* KadeDev - Fixed some cool stuff on Chart Editor and other PRs
* iFlicky - Composer of Psync and Tea Time, also made the Dialogue Sounds
* PolybiusProxy - .MP4 Video Loader Library (hxCodec)
* Keoiki - Ex-Assistant Artist and Note Splash Animations
* Smokey - Sprite Atlas Support
* superpowers04 - LuaJIT Fork of Nebula the Zorua's LuaJIT fork and some QOL changes/additions

# Features

## Attractive animated dialogue boxes
![](https://user-images.githubusercontent.com/44785097/127706669-71cd5cdb-5c2a-4ecc-871b-98a276ae8070.gif)

## Mod Folder Support
![](https://github.com/ShadowMario/FNF-PsychEngine/assets/73214127/02d4920f-7203-41e5-8d04-dea677f4017a)

## Atleast one change to every week
### Week 1:
  * New Dad Left sing sprite
  * Unused stage lights are now used
  * Dad Battle has a spotlight effect for the breakdown
### Week 2:
  * Skid & Pump does a "Hey!" animation, just like BF
  * Thunder does a quick light flash and zooms the camera in slightly
  * Added a quick transition/cutscene to Monster
### Week 3:
  * BF does "Hey!" during Philly Nice
  * Blammed has a cool colour flash along with particles that fly in the air
### Week 4:
  * Better hair physics for Mom/BF (Maybe even slightly better than Week 7's :eyes:)
  * Henchmen die during all songs. Yeah :(
### Week 5:
  * Bottom Boppers and GF do "Hey!" animations during Cocoa and Eggnog
  * On Winter Horrorland, GF bops her head slower in some parts of the song.
### Week 6:
  * On Thorns, the HUD is hidden during the intro cutscene
  * Also there's the Background girls being spooky during the "Hey!" parts of the instrumental

## Massive Chart Editor changes
![](https://github.com/ShadowMario/FNF-PsychEngine/assets/73214127/605e8694-8407-4999-8b70-366bcccc338b)
* Change the pitch/speed while charting, to hear patterns more clearly
* Change the snap of the strumlime, all the way from 4th snap to 192nd
* Events, which work as a bookmark in-game to run a script at that certain time
* Chart playtester built into the chart editor, so you can test certain parts of a chart without having to go into PlayState
* Decimal BPM Support
* You can manually adjust a note's strumtime, if you want millisecond precision
* Custom notetypes, it comes with 5 default examples:
* You can change a note's type on the editor, it comes with five example types:
  * Alt Animation: Forces an alt animation to play, useful for songs like Ugh/Stress
  * Hey: Forces a "Hey" animation instead of the base Sing animation, if Boyfriend hits this note, Girlfriend will do a "Hey!" too.
  * Hurt Notes: If Boyfriend hits this note, he plays a miss animation and loses some health.
  * GF Sing: Rather than the character hitting the note and singing, Girlfriend sings instead.
  * No Animation: Character just hits the note, no animation plays.

## Several editors to assist you in your own mod
![](https://github.com/ShadowMario/FNF-PsychEngine/assets/73214127/1194b178-9ddf-44c8-b320-d60d3dbc0813)

## Story Mode Menu rework
![](https://github.com/ShadowMario/FNF-PsychEngine/assets/73214127/711e316b-0fab-430c-8dba-bd8d142d7c2a)
* Added a background to every week (except for Tutorial)
* All menu characters are now in individual spritesheets, making modding the Story Mode menu way easier

## Credits Menu
![](https://github.com/ShadowMario/FNF-PsychEngine/assets/73214127/7589f510-b6df-4c22-9d4b-135e83cee3d7)
* You can add your credits to your mod here through a .txt file in `mods/data`

## Awards/Achievements
* The engine comes with 15 example achievements that you can mess with and learn how it works (Check Achievements.hx and search for "checkForAchievement" on PlayState.hx)

## Options menu:
* You can change note colours, audio offset and combo/rating positions, controls and other sorts of settings there.
* You can also toggle Downscroll, Middlescroll, Anti-Aliasing, Framerate, Low Quality, Note Splashes, Flashing Lights, etc.

## Other gameplay features:
* When the enemy hits a note, their strum note also glows.
* Lag doesn't impact the camera movement and player icon scaling anymore.
* Some stuff based on Week 7's changes has been put in (Background colors on Freeplay, Note Splashes)
* You can reset your Score on Freeplay/Story Mode by pressing the Reset button.
* You can listen to a song in Freeplay by pressing Space, or you can adjust Scroll Speed/Damage taken/etc. in Freeplay/Story Mode by pressing Control.
* You can enable "Combo Stacking" in Gameplay Options. This causes the combo sprites to just be one sprite with an animation rather than sprites spawning each note hit.
