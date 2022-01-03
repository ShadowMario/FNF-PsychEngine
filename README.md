# Table of Contents
- [Introduction](#introduction)
    - [Friday Night Funkin' - The Fat-Ass Mod Compilation](#introduction)
    - [What is this mod?](#what-is-this-mod)
    - [Our goals](#our-goals)
    - [The Fatass client features](#the-fatass-client-features)
- [Spreadsheet with Timing Window values](#spreadsheet-with-timing-window-values)
- [Song List](#song-list)
- [Known Bugs](#known-bugs)
    - [On V1.2 - Psych Engine 0.5.1](#known-bugs)
    - [On V1.1 - Psych Engine 0.5.1](#known-bugs)
    - [On V1.0 - Psych Engine 0.5](#known-bugs)
- [Other Info, kinda like a FAQ](#other-info-kinda-like-a-faq)

# Introduction

## Friday Night Funkin' - The Fat-Ass Mod Compilation
****Not intended to replace the original mods but instead do "generic" ports of them, leaving some stuff out.****

Example of a "generic" port: **VS Tricky - Expurgation** is missing the annoying Signs and HP Gremlins.
* _In some cases, like with old mods, the quality may be better here than the original however due to recharting and adding custom events._

## What is this mod?
This isn't your typical mods ported into one single FNF.exe.

We aim to make it better one way or another wheter it's by re-timing, recharting or even just change one note in the chart!.

### Our goals
 * Clean sources, renamed assets to be found easier and make more sense. _(Also to prevent conflicts while the collection grows!)_
 * Recharting of some _poorly_ done charts, like _Sarvente's Mid-Fight Masses_.
 * Retiming any out of sync charts.
 * Resurrect dead/removed mods from super early kade engine or other custom engines.

### The Fatass client features
 * Renamed **accuracy ratings** to crush your dreams and tell you the truth about your shitty 80% accuracy.
 * Added **Insane** and **Expert** difficulty options. 
 * Scoring has been improved. (These scores won't replace your scores in other clients.)
   * Added "Perfect Sicks", they give you 320 score. Works like Marvelous in Etterna/Stepmania. They are light blue.
   * "Sicks" now gives 300 score (still counts as 100% acc)
   * "Goods" now gives 200 score
   * "Bads" now gives 100 score
   * "Shits" now gives 50 score and had their impact on accuracy modified a little bit.
   * "Miss" well gives 0 score 😜
* Timing windows can be tightened up to Etterna/Stepmania's "Judge 7" if desired. (See ingame tooltip for more information or scroll down a bit)
* Gameplay Modifier: Play Opponents Chart. You can access it by pressing CTRL in freeplay menu.
* Gameplay Options: Hitsounds
* Gameplay Options: Disable Anti-Mash Protection
* Gameplay Options: Lane Underlay Opacity

# Spreadsheet with Timing Window values
These values are taken from StepManias "Judge" system, as this is an old and proven method.

Judge 4 is fairly lenient and is the default, Psych Engine uses this as default too.

So try playing with Judge 5 values for a bit sometime. If that still feels too easy, then try Judge 6!

[![Spreadsheet](https://i.imgur.com/YrcV0jm.png)](https://i.imgur.com/YrcV0jm.png)
---
# Song List
[![Watch the video](https://img.youtube.com/vi/HaUv50bt7Xk/hqdefault.jpg)](https://youtu.be/HaUv50bt7Xk) [![Watch the video](https://img.youtube.com/vi/gFZJzazrJ3E/hqdefault.jpg)](https://youtu.be/gFZJzazrJ3E)

### Current full week songlists 
- Week 1-6
- B-Sides Week 1-6
- The Full-Ass Tricky Mod
- Camellia Week 1-2
- Smoke 'Em Out Struggle (Garcello)
- Sarvente's Mid Fight Masses
- Tabi Ex-Boyfriend
- Starecrown
- Sonic.exe V1.0
- Whitty
- High Effort Finn and Jake
- Sky
### Current songs not including full weeks
- Bob - Run
- Zardy - Foolhardy
- Hatsune Miku - Popipo
- Hatsune Miku - Ievan Polkka
- Hatsune Miku - Aishite
- Hatsune Miku - Disappearance
- Friday Night Madness - Jebus - 1corekiller
- Friday Night Madness - Jebus - The Anger of God
- Holofunk - Rushia - Killer Scream
- Impostor - Sussy Bussy
- Impostor - Reactor
### Current Bonus songs
- Mike Geno - Ruv/Sarvente - Glazomer 
- Mike Geno - Ruv/Sarvente - Crescendo
- A handful of songs from osu!mania ported.
- & Many of the songs has extra difficulties that are harder than their original mods if you like a challenge!


# Known Bugs
### On V1.2 - Psych Engine 0.5.1
- Lua Scripts that changes camera behavior sometimes stop working, haven't figured out under what conditions/settings it does this yet. But I've confirmed it isn't random atleast, so you maybe won't have this issue at all :)
- Having events.json and chart.json with change character events causes characters not deloading properly. Worked around by deleting events.json on songs using this.
- Setting the game to 960 FPS and closing it, causes menu animations to be super slow next time you start the game. Doesn't affect gameplay however.
Workaround: 
Use values under 480fps
- Character Editor: Tends to crash.
- VS Tabi - Genocide [Hard] has ONE note coming on BFs playfield during one of Tabis parts. Opening this chart in the chart editor crashes the game and if deleted manually from .json the chart won't even load?? Will be fixed in an upcoming patch (no ETA).

### On V1.1 - Psych Engine 0.5.1
- Lua Scripts that changes camera behavior stop working around 2-3 minutes into songs.
- Having events.json and chart.json with change character events causes characters not deloading properly. Workaround: delete events.json
- Setting the game to 960 FPS and closing it, causes menu animations to be super slow next time you start the game.
Workaround: 
Use values under 480fps
- Character Editor: Tends to crash.

### On V1.0 - Psych Engine 0.5
- Setting the game to 960 FPS and closing it, causes menu animations to be super slow next time you start the game.
Workaround: 
Use values under 480fps
- Character Editor: Tends to crash
- Chart Editor: Copy Section causes crash.

# Other Info, kinda like a FAQ
## "Songs doesn't have the right characters/stage applied!"
    To be completely honest, I've only bothered fixing this mostly on Hard for B-Sides songs.
    You'll have to do it manually for now or wait until I'm not lazy. Everything but B-Sides should have correct stages applied on all diffs.
    
## "Why aren't you using the new method of Psych Engine 0.5 to load mods?
    It's still very new but very easy and fast to move to that system once I feel it's mature enough,
    but in the meantime feel free to load your own mods here
    
## "Where are the credits?
    Everyone who has worked on the original mods have been added to the Credits menu inside the game. 

## "I can port stages/characters for you!!"

    If you want to port stages and anything else, feel free to do a pull request, but some rules apply.

      1: Follow the same name pattern as the other files in example_mods.

      2: Do NOT touch any files outside the example_mods folder, you don't need to do anything outside this folder.

## "I can make/port more options to configure!!"

    Anything that allows you to customize your gameplay experience more is welcome. 

    Same rule apply here though, if you need to add/edit asset files, do it INSIDE THE EXAMPLE_MODS FOLDER!
    
## "Why have you added 'X' mod, the creator doesn't want it public!!"

    Depends on the reason they don't want it up. 

    If there's no reasons given, I will add it anyways.
    
    If it's because of hate or troll comments, I will add it anyways, if it's easily accessible with a 5 second google search, then it shouldn't matter, it's been on the internet for too long. 
    I do not condone harrassment of these people and never will.
    
    If I were the only one on the internet to have the mod available for download, in those cases I wouldn't add their mods to this compilation.
    
    And finally, stop being such butthurt drama queens.

## "Why have you added 'X' mod, the creator is accused of 'X'!!"
    
    I don't care if they're accused, what matters to me is if it's actually true or not.
    
    If you can provide CONCLUSIVE PROOF that it's a fact they have done something terrible and you want it removed, feel free to send it to me.
    
    If I decide to keep their work in the mod, that doesn't mean I support their actions. 
    
    And finally, stop being such butthurt drama queens.
    
## "Your mod causes 'X' person to be harassed, please remove their work!!"
    
    If they start getting harassed again for something that happened half a year ago because of my mod compilation, I'll be disappointed in humanity.

    Just because their work is available here now doesn't mean it's ok to start attacking them again, for fuck sakes.

    If the creator wants it removed, they can contact me personally.
    
    And finally, stop being such butthurt drama queens.
    
    

