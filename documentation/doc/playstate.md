# Yoshi Engine's documentation - PlayState
In each script file, the game's current PlayState can be accessed via the `PlayState` and the `PlayState_` variable. 

This page shows every method and variables that can be used in PlayState, and it's uses.

---
# `[Important variables/methods]`


**`song:SwagSong`** - (`PlayState`)

Current song JSON. Can be messed with.

__**Example usage:**__
```haxe
// Changes the key amount to 4
PlayState.song.keyNumber = 4;
```

---

**`dads:Array<Character>`** - (`PlayState`)

List of current __singing__ dads.

__**Example usage:**__
```haxe
var d = new Character(PlayState.dad.x + 300, PlayState.dad.y, "Friday Night Funkin':dad");
add(d);
PlayState.dads.push(d);
```

---
**`boyfriends:Array<Character>`** - (`PlayState`)

List of current __singing__ boyfriends.

__**Example usage:**__
```haxe
var b = new Boyfriend(PlayState.boyfriend.x + 300, PlayState.boyfriend.y, "Friday Night Funkin':bf");
add(b);
PlayState.boyfriends.push(b);
```
---
**`gf:Character`** - (`PlayState`)

Girlfriend sprite

__**Example usage:**__
```haxe
// Moves GF by 300 pixels to the right.
PlayState.gf.x += 300;
```

---
**`dad:Character`** - (`PlayState`)

First dad in the `dads` array.

---
**`notes:FlxTypedGroup<Note>`** - (`PlayState`)

[`FlxTypedGroup`](https://api.haxeflixel.com/flixel/group/FlxTypedGroup.html) of all the note sprites.


---
**`camFollow:FlxObject`** - (`PlayState`)

Camera's target

__**Example usage:**__
```haxe
function update(elapsed) {
    // Focuses camera on Girlfriend
    PlayState.camFollow.x = PlayState.gf.getGraphicMidpoint().x;
    PlayState.camFollow.y = PlayState.gf.getGraphicMidpoint().y;
}
```

---
**`defaultCamZoom:Float`** - (`PlayState`)

Default camera zoom

__**Example usage:**__
```haxe
function create() {
    PlayState.defaultCamZoom = 0.5;
}
```
---

**`autoCamZooming:Bool`** - (`PlayState`)

If `true`, enables automatic camera zooming every 4 beats.
Defaults to `true`
---

**`camZooming:Bool`** - (`PlayState`)

If `true`, enables automatic camera zoom management
Defaults to `true`
---















































# `[Variables]`
**`isStoryMode:Bool`** - (`PlayState_`)

Whenever the game is in Story Mode (`true`) or in Freeplay (`false`).

__**Example usage:**__
```haxe
if (PlayState_.isStoryMode) {
    // Story Mode
} else {
    // Freeplay
}
```
---
**`songMod:String`** - (`PlayState_`)

Song's mod (ex : `Friday Night Funkin'`)

---
**`storyPlaylist:Array<String>`** - (`PlayState_`)

Remaining songs in the current week. Can be messed with to put custom secret songs.

__**Example usage:**__
```haxe
// Adds Bopeebo in the current week
PlayState_.storyPlaylist.push("Bopeebo");
```

---
**`actualModWeek:FNFWeek`** - (`PlayState_`)

Current Story Menu week.

__**Example usage:**__
```haxe
// Traces the current week's name
trace(PlayState_.actualModWeek.name);
```

---
**`validScore:Bool`** - (`PlayState`)

Whenever the score will be validated

---
**`vocals:FlxSound`** - (`PlayState`)

Current vocals

__**Example usage:**__
```haxe
// Mutes the vocals
PlayState.vocals.volume = 0;
```

---
**`songPercentPos:Float`** - (`PlayState`)

Song position in percentage (0 to 1)


---
**`cpuStrums:FlxTypedGroup<FlxSprite>`** - (`PlayState`)

[`FlxTypedGroup`](https://api.haxeflixel.com/flixel/group/FlxTypedGroup.html) of the CPU's **Static Strums**

__**Example usage:**__
```haxe
function update(elapsed) {
    // Inverts the Player's Strums with the CPU's ones
    for (i in 0...PlayState.playerStrums.length) {
        var cpuStrumX = PlayState.cpuStrums.members[i].x;
        PlayState.cpuStrums.members[i].x = PlayState.playerStrums.members[i].x;
        PlayState.playerStrums.members[i].x = cpuStrumX;
    }
}
```

---
**`gfSpeed:Int`** - (`PlayState`)

Girlfriend's dancing speed

---
**`health:Float`** - (`PlayState`)

Player's health (ranges from 0 to maxHealth)

__**Example usages:**__
```haxe
// Kills BF
PlayState.health = 0;
```
```haxe
// Puts the health to the max
PlayState.health = 2;
```

---
**`maxHealth:Float`** - (`PlayState`)

Player's maximum health (defaults to 2).
Setting it to 0 or lower will enable OHKO (not a darkviperau reference)

__**Example usages:**__
```haxe
/*
    Hello and welcome to what is hopefully
    my final attempt at completing Friday
    Night Funkin' without taking any damage.
    I have a max HP of 1 so any damage from
    an source will immediatly kill me. I also
    want this to be a no hit run, so Boyfriend's
    ability to restore health is disabled. I have
    successfully completed every Friday Night Funkin'
    songs without taking any damage. I just yet have
    to do it in one go. My current personal best is
    1 shit rating and therefore 1 blueball.
*/
// Enables OHKO
PlayState.health = 0;
```
```haxe
// Sets BF's maximum health to 0.75, making health draining and gaining faster (like it used to be)
PlayState.health = 0.75;
```

---
**`tapMissHealth:Float`** - (`PlayState`)

Player's health that'll be lost if he randomly taps while ghost tapping is off.

__**Example usages:**__
```haxe
// Instant kill when random tap
PlayState.tapMissHealth = 3;
```

---
**`combo:Int`** - (`PlayState`)

Current combo


---
**`healthBarBG:FlxSprite`** - (`PlayState`)

Health Bar Background


---
**`healthBar:FlxBar`** - (`PlayState`)

Health Bar


---
**`iconP1:HealthIcon`** - (`PlayState`)

Player 1's icon


---
**`iconP2:HealthIcon`** - (`PlayState`)

Player 1's icon


---
**`camHUD:FlxCamera`** - (`PlayState`)

HUD's camera.

__**Example Usage:**__
```haxe
var guiThing = new FlxSprite(0, 360);
guiThing.loadGraphic(Paths.image("guiObject"));
guiThing.cameras = [PlayState.camHUD];
PlayState.add(guiThing);```
```

---
**`songScore:Int`** - (`PlayState`)

Player's score


---
**`scoreTxt:FlxText`** - (`PlayState`)

Score text object at the bottom of the screen.


---
**`campaignScore:Int`** - (`PlayState_`)

Week score

---
**`misses:Int`** - (`PlayState`)

Player's misses count

---
**`isWidescreen:Bool`** - (`PlayState`)

Whenever the game is in Widescreen or not.

__**Example Usage:**__
```haxe
PlayState.isWidescreen = true;
```

---
**`msScoreLabel:FlxText`** - (`PlayState`)

Label above the player's strums showing the milliseconds delay between the press and the note's strum time.

__**Example Usage:**__
```haxe
PlayState.isWidescreen = true;
```

---
**`engineSettings:Dynamic`** - (`PlayState`)

Engine's current settings. Can be modified.

Can be accessed via the `EngineSettings` variable.

__**Example Usage:**__
```haxe
// Forces usage of downscroll
EngineSettings.downscroll = true;

function create() {
    ...
}
```

---
**`modchart:Interp`** - (`PlayState_`)

Modchart's HScript Interpreter.


---
**`stage:Interp`** - (`PlayState_`)

Stage's HScript Interpreter.


---
**`cutscene:Interp`** - (`PlayState_`)

Cutscene's HScript Interpreter.


---
**`noteScripts:Array<Interp>`** - (`PlayState`)

Array of Note Types HScript interpreters.


---
**`timerBG:FlxSprite`** - (`PlayState`)

Timer's Gray Background



---
**`timerBar:FlxBar`** - (`PlayState`)

Timer's Bar





































# `[Methods]`

**`showKeys():Void`** - (`PlayState`)

Shows the keys below the player's strums.

Does not work in Botplay.

__**Example Usage:**__
```haxe
PlayState.showKeys();
```



---
**`setDownscroll(downscroll:Bool, autoPos:Bool):Void`** - (`PlayState`)

[Added via the request of jayden8923](https://github.com/YoshiCrafter29/YoshiEngine/issues/4)

__**Example Usage:**__
```haxe
// Enables downscroll and change the strums' positions automatically
PlayState.setDownscroll(true, true);
```



---
**`startCountdown():Void`** - (`PlayState`)

Starts the countdown. Can only be used in Cutscenes HScripts using `startCountdown();`

__**Example Usage:**__
```haxe
// ONLY USABLE IN CUTSCENES HSCRIPTS
startCountdown();
```





---
**`resyncVocals():Void`** - (`PlayState`)

Syncs the vocals with the instrumental.


---
**`endSong():Void`** - (`PlayState`)

Ends the song


---
**`endSong2():Void`** - (`PlayState`)

Switches to the next song or goes back to the Freeplay menu. Used by ending cutscenes as `end()`. Do not use since it doesn't save the player's score.


---
**`popUpScore(strumTime:Float):Void`** - (`PlayState`)

Creates a rating based on the difference between `strumTime` and `Conductor.songPosition`.




---
**`noteMiss():Void`** - (`PlayState`)

Misses a note.



---
**`goodNoteHit(note:Note):Void`** - (`PlayState`)

Hits a note