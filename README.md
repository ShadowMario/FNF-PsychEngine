<p align="center">
  <img src="https://media.discordapp.net/attachments/922853801835257867/983128071244763176/psychnewlogo.png" width="640" height="312.6" /></a>
</p>

# Friday Night Funkin': Psych Engine

Engine that is intended to fix many of vanilla FNF's issues and aiming to be an easier alternative to new mod-makers, while keeping a casual play ascept. Originally intended for the [Mind Games Mod](https://gamebanana.com/mods/301107).

# Table of Contents:
* [Credits](#credits)
  * [Special Thanks](#special-thanks)
* [Features](#features)
* [Bonus Features](#bonus-features)
* [Building](#building)
  * [Installing Necessary Programs / Prerequisites](#programs-prerequisites)
  * [Compiling (Web and Desktop)](#compiling)
    * [Compiling Web](#compiling-web)
    * [Compiling Desktop](#compile-desktop)
* [A Few Things to Note (Building)](#things-to-note)

## Credits: <a name="credits"></a>
* [Shadow Mario](https://twitter.com/Shadow_Mario_) - Programmer;
* [RiverOaken](https://twitter.com/RiverOaken) - Artist;
* [Yoshubs](https://twitter.com/yoshubs) - Assistant Programmer, New Input System, New Asset Caching System.

### Special Thanks: <a name="special-thanks"></a>
* [bbpanzu](https://twitter.com/bbsub3) - Former Programmer;
* [SqirraRNG](https://twitter.com/gedehari) - Crash Handler, Chart Editor Waveform;
* [KadeDev](https://twitter.com/kade0912) - Constant Scroll Speeds, Accurate Note Quantization;
* [iFlicky](https://twitter.com/flicky_i) - Composer of [Psync](https://youtu.be/mX9sgiSUf5g) and [Tea Time](https://youtu.be/a7ksO5xVJU8), Dialogue Sounds;
* [PolybiusProxy](https://twitter.com/polybiusproxy) - [hxCodec](https:/github.com/polybiusproxy/hxCodec) (.mp4 video loader library);
* [Keoiki](https://twitter.com/Keoiki_) - Note Splash Animations;
* [Smokey](https://twitter.com/Smokey_5_) - Spriteatlas Support;
* [Nebula The Zorua](https:/github.com/nebulazorua) - Lua API Rework, Better Chart Beat Snapping, Workflow Fix;

[and the rest of the Psych Engine's contributors](https://github.com/ShadowMario/FNF-PsychEngine/pulls).

# Features: <a name="features"></a>

## Attractive Dialogue Boxes:
<img src="https://user-images.githubusercontent.com/110774369/184693742-fe3b02cb-3389-4d27-956f-a0357014365c.gif" width="640" height="360"/>

## Mod Support:
* Support for Lua and being able to code in .lua files, giving you the ability to make custom weeks, events, scripts, and a ton more, without tinkering with the source code.
* Psych comes with its own mod management menu, where you can easily enable or disable mods.

## Changes to Each Vanilla Week:
### Week 1:
* Daddy Dearest has a re-animated left pose;
* The unused stage lights make their way back into the week;
* Custom ``Dadbattle Spotlight`` event.
### Week 2:
* An unused ``Hey!`` animation for Skid and Pump makes it way back into ``Spookeez``;
* Thunder now zooms in the camera slightly while also doing a quick flash;
* Transition between ``South`` and ``Monster``.
### Week 3:
* Boyfriend plays a ``Hey!`` animation in ``Philly Nice`` whenever it is heard in the Instrumental.
* ``Philly Glow``, a full-of-color funky event, specifically coded for this Week, plays at the drop of ``Blammed``.
### Week 4:
* Re-animated hair physics for Mom and Boyfriend. ~~(Maybe even better than Week 7's)~~
* Unused event where *all* of Mother Mearest's Henchmen die because of them hitting a street light now makes its way back into the Week.
### Week 5:
* The Bottom Boppers and Girlfriend play a ``Hey!`` animation when one is heard in the Instrumental of ``Cocoa`` and ``Eggnog``.
* ``Winter Horrorland`` has its new transition that was originally implemented in the ``Week 7 update``, after finishing ``Eggnog``.
* Girlfriend's head bop slows down during some parts of ``Winter Horrorland``.
### Week 6:
* The little arrow sprite at the bottom right of the dialogue box is now properly scaled, like in the ``Week 7 Update``.
* The transition from ``Roses`` to ``Thorns`` has the HUD hidden.
* The Background Girls have recieved a **spooky make-over** in ``Thorns``, summoning them during the ``Hey!`` parts of the Instrumental.
### Week 7:
* Cutscenes now play in-game, thanks to Psych's custom Cutscene Handler.
* Some funky camera events at the beginning of ``Ugh``, making the song *pop*.

## Multiple Editors (some reworked, some new):
<img src="https://cdn.discordapp.com/attachments/875771733699883058/1008819926221463592/unknown.png" width="773.3" height="376"/>

* These Editors are accessible through builds that are directly **downloaded from the ``GitHub Releases``** or builds that are **compiled from source code**.

## Chart Editor Rework:
<img src="https://cdn.discordapp.com/attachments/875771733699883058/1008816086319382648/PsychEngine_WWghdNeZaK.png" width="640" height="360"/>

* ``Event`` notes:
  * "bookmarks" that trigger a specific action/event that was originally hardcoded in the base game;
* The engine supports song BPMs that have decimal values;
* The ability to manually adjust a note's strum time, if going for milisecond precision;
* A note's type can be changed within the Editor, that can either play or stop animations.

## Story Mode Menu Rework:
<img src="https://cdn.discordapp.com/attachments/875771733699883058/1008820871110074448/unknown.png" width="640" height="360"/>

* Each Week has its own separate background, except for ``Tutorial`` and ``Week 1`` as they share the same one.
* Each Menu Character is its own individual spritesheet, which makes modifying it easier.

## Credits Menu:
<img src="https://cdn.discordapp.com/attachments/875771733699883058/1008822321936617572/unknown.png" width="640" height="360"/>
                                                                                                                         
* Each item has its own Icon, Name, Description and Redirect Link. 

(Upon pressing ``Enter`` on the currently selected item, it'll open up a browser tab and send you to that link)

## Awards / Achievements:
<img src="https://cdn.discordapp.com/attachments/875771733699883058/1008830226584850452/unknown.png" width="640" height="360"/>

<img src="https://cdn.discordapp.com/attachments/875771733699883058/1008830233023102986/unknown.png" width="640" height="360"/>

* Psych comes with 16 awards/achievements. To name some:
  * ``Debugger``, ``Roadkill Enthusiast``, ``Hyperactive``, ``Just the Two of Us``, etc.
* All of the 16 awards/achievements are *examples* that you can mess with and learn how they work.
  * (Check ``Achievements.hx`` and search for ``"checkForAchievement"`` in ``PlayState.hx``)

## Options Menu:
<img src="https://cdn.discordapp.com/attachments/875771733699883058/1008825275611619498/unknown.png" width="640" height="360"/>

* Pretty self-explanatory, it's a custom and more advanced (in terms of the ``Week 7 Update``) Options Menu, that allows you to modify the game to your liking.

# Bonus Features: <a name="bonus-features"></a>
* Enemy strums now glow just like the players.
* Lag no longer impacts camera movement and player icon scaling.
* Some changes based on the ``Week 7 Update``:
  * Background Colors in ``Freeplay``, Note Splashes, etc.
* Resetting Score in ``Freeplay`` or Story Mode using the Reset key. (default: ``R``)
* Listening to a Song in ``Freeplay`` by pressing ``Space``;
* Gameplay Modifiers (allowing you to adjust Scroll Speed, Damage Taken, etc.) by pressing ``Ctrl`` in either ``Freeplay`` or ``Story Mode``.

# Building: <a name="building"></a>
## Installing Necessary Programs / Prerequisites: <a name="programs-prerequisites"></a>
* Install the **up-to-date version** of [Haxe](https://haxe.org/download/).

* Install [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) using either Command Prompt or Powershell.

* Other installations you'd need are the **additional libraries** that Psych uses. 
  * A fully updated list will be in ``Project.xml`` (starting from [line 124](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/Project.xml#L124) all the way to [line 148](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/Project.xml#L148)), however, here's the current ones you need:
```
haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib install hxCodec
```
* Next up, install [Git](https://git-scm.com/) and follow the instructions to install the application properly.
  * Afterwards, open up Command Prompt or Powershell and run the following commands:
```
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
```

This will install  ``linc/LuaJIT`` (which is used for executing .lua files (scripts)) and ``linc/discord-RPC`` (which is used to display Rich Presence on your Discord profile).

## Compiling (Web and Desktop): <a name="compiling"></a>
### Compiling Web: <a name="compiling-web"></a>
* After installing all the required programs, it's easy to compile the game. 
  * You can run ``lime test html5 -debug`` in the root of the project to build and run the Web / HTML5 version. 
  * ([Command prompt navigation guide here, in case you get lost](https://ninjamuffin99.newgrounds.com/news/post/1090480).)

### Compiling Desktop: <a name="compile-desktop"></a>
To run it from desktop (Windows, Mac or Linux), it's a little more complicated.

* For Linux, you only need to open a terminal in the project directory and run ``lime test linux -debug`` and run the executable file in ``export/release/linux/bin``.

* For Mac, ``lime test mac -debug`` *should* work, if not, the Internet surely has a guide on how to compile Haxe stuff for Mac.

* For Windows, however, you need to install [Visual Studio Community 2019](https://docs.microsoft.com/en-us/visualstudio/releases/2019/release-notes).
  * After Visual Studio finishes installing and launches, switch from the ``Workload`` to ``Individual components`` section in the top left of the window. When you've done that, search for the following dependencies:
```
MSVC v142 - VS 2019 C++ x64/x86 build tools (Latest)
Windows 10 SDK (10.0.20348.0)
```

or if you're running on Windows 11, install this dependency instead of the Windows 10 one: ``Windows 11 SDK (10.0.22000.0)``.

* Once the dependencies download and install, you can open up a command line in the project's directory and run ``lime test windows -debug``.
  * Once it finishes building, you can run Psych Engine from the .exe file under ``export\release\windows\bin``.

## A Few Things to Note (Building): <a name="things-to-note"></a>
* If you don't want your mod to run .lua scripts, [delete the ``"LUA_ALLOWED"`` line on ``Project.xml``](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/Project.xml#L48).
* If you don't want video support for your mod, [delete the ``"VIDEOS_ALLOWED"`` line on ``Project.xml``](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/Project.xml#L50).
* If you're running Visual Studio Community 2022, then install these dependencies:
```
MSVC v143 - VS 2022 - C++ x64/x86 build tools (Latest)
Windows 10 SDK (10.0.20348.0)
```
or if you're on Windows 11 *with* Visual Studio Community 2022, install this one instead of the Windows 10 one: ``Windows 11 SDK (10.0.22621.0)``.
* Regarding the Windows 10/11 SDK dependencies, the number in the parentheses might not be accurate to this guide.
  * Whatever the case might be, just install the **latest version**. (highest number in the parentheses)

<p align="center">
  <img src="https://cdn.discordapp.com/attachments/922853801835257867/983893786885246986/psychservericon.png" width="235.5" height="235.5" /></a>
</p>
