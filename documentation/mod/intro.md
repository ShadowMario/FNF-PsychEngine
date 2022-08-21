# Yoshi Engine's documentation - Mod Creation
## Create your first mod

To create your first mod, it's easy. Go in the `mods` folder and create a folder, and it's done.

Technically, it's a mod, but it requires many files to work correctly.

`/song_conf.hx` is needed to load specific stages for specific songs.

# **1.** `song_conf.hx`

### `song_conf.hx` is used by the engine to get specific stages and modcharts for songs.

**Example usage :**

`song_conf.hx`
```haxe
switch(song) {
    case "sunshine":
        stage = "mountain";
        modchart = "sunshine_events";
        cutscene = "sunshine_cutscene";
}
```
In this case, the following files will be required :

- `/stages/mountain.hx` (Stage)
- `/modcharts/sunshine_events.hx` (Modchart)
- `/cutscenes/sunshine_cutscene.hx` (Cutscene)

We'll come back to stage, modcharts and cutscene creation later.

# **2.** Songs and `freeplaysonglist.json`

Like on the original game source code, the songs are added this way :
- Charts in `/data/(your song)/`
- `Inst.ogg` and `Voices.ogg` in `/songs/(your song)/`

**What is different however, is the `freeplaySonglist.json` file.**

Unlike the original Friday Night Funkin' game, the freeplay song list is in JSON format.

The file is located `/data/freeplaySonglist.json`.

The JSON works this way :
```json
{
    "songs" : [
        // Insert songs here
    ]
}
```

Every songs are represented by a structure :
```json
{
    // Must-needed values
    "name" : "Song name",
    "char" : "Character Name",

    // Optional values
    "displayName" : "Name showed in the Freeplay Menu",
    "difficulties" : ["Array", "Of", "Difficulties", "Names"],
    "color" : "Color in #FFFFFFFF or #FFFFFF format."
}
```

For example :
```json
{
    "songs" : [
        {
            "name" : "Nyawpurgation",
            "char" : "kapi"
        }
    ]
}
```
Adds "Nyawpurgation" in the Freeplay Menu with Kapi's icon.

Icons are located in `/characters/char/icon.png`

`/!\ Warning` The character MUST HAVE a `Character.hx` file in the same directory as the icon, or else it's NOT going to work.

# **3.** Characters
Characters are all located in the `/characters/` folder. Each character is represented by a folder that contains 4 files :
- `Character.hx` : Main Character code, see documentation [**here**](../doc/chars.md).
- `icon.png` : Icon grid of 150x150 per tile representing your character's icons.
- `spritesheet.png` : Spritesheet bitmap of your character
- `spritesheet.xml` : Spritesheet Sparrow XML

**How to create your own character ?**
***
## **a.** The Icon
To create your first character's icon, you'll need to create a bitmap of 300x150 (or larger as long as it is a multiple of 150).

The first two tiles (left and right in this case) will be your character's icons :
- The first tile will represent your character's normal icon.
- The second tile will represent your character's losing icon.

When you have finished designing it, save it under `/characters/(Your Character)/icon.png`.
***
## **b.** The spritesheet
To create a spritesheet, you'll need
- Adobe Animate (that supports Sparrow)
- The FLA file of your character
- A little bit of knowledge
- A brain

If you already have a spritesheet for your character, you can copy it over, rename it to `spritesheet.png` and `spritesheet.xml` and skip this section.

**1.** Open animate

**2.** Open your FLA file

**3.** Select the animations you want to export (idle, sing up, sing down, sing left, sing right)

**4.** Write the animation names on a piece of paper (or notepad, do however you want.)

**5.** Right click and select "Generate Sprite Sheet"

**6.** On the Data Format dropdown, select "Starling"

**7.** Set the Border Padding and Shape Padding to 5px (or more) to prevent smoothing problems and annoying lines appearing at the edges of sprites.

**8.** Export in `/characters/(Your Character)/spritesheet.png`.

***
## **c.** `Character.hx` - Loading Sprites
The Character.hx file contains all of the code necessary for the character to work. It includes :
- Loading the sprites
- Creating the animations
- Adding offsets
- Much more...

Full documentation [here](../doc/chars.md).

To begin, lets create a `Character.hx` (and not `Character.hx.txt` or anything else), and add a `create()` function in it.

Your document should look like this :
```haxe
function create() {

}
```

To start, we'll load our character.

To do so, add `var tex = Paths.getCharacter("mod:char")`.

If you're unsure of the mod's name, type in `var tex = Paths.getCharacter(mod + ':char')`.

Next, we'll apply the loaded frames to the sprite. To do so, type `character.frames = tex;`

Your code should look like this :
```haxe
function create() {
    var tex = Paths.getCharacter("mod:char");
    character.frames = tex;
}
```
***
## **d.** `Character.hx` - Adding animations
Next, we'll add the animations. To add an animation, type in :
```haxe
character.animation.addByPrefix('PlayAnim name', 'XML (Animate) name', framerate, loop);
```
Please note that a character needs an `idle` animation (for his idle dance), along :
- `singUP` - The animation when he hits a up note.
- `singDOWN` - The animation when he hits a down note.
- `singLEFT` - The animation when he hits a left note.
- `singRIGHT` - The animation when he hits a right note.

For example : 
```haxe
character.animation.addByPrefix('idle', 'Idle Dance', 24, false);
```
If the game (or any of your modchart/stages) tries to run an animation that doesnt exist on your character, a message will be logged in the Logs, accessible via the pause menu.
***
## **e.** `Character.hx` - Adding Offsets
Adding Offsets is by far, the simplest.

To add an offset, do this :
```haxe
character.addOffset('XML (Animate) name', x, y);
```
For example :
```haxe
character.addOffset('idle', 50, 0);
```
***
## **f.** `Character.hx` - Finishing touches
If you completed the steps above correctly, your `Character.hx` file should look like this :
```haxe
function create() {
    // Loading sprites
    var tex = Paths.getCharacter("mod:char");
    character.frames = tex;

    // Setting up animations
    character.animation.addByPrefix('idle', "Idle Dance", 24, false);
    character.animation.addByPrefix('singLEFT', "Sing Left", 24, false);
    character.animation.addByPrefix('singDOWN', "Sing Down", 24, false);
    character.animation.addByPrefix('singUP', "Sing Up", 24, false);
    character.animation.addByPrefix('singRIGHT', "Sing Right", 24, false);

    // Setting up offsets
    character.addOffset("idle", 0, 0);
    character.addOffset("singLEFT", 0, 0);
    character.addOffset("singDOWN", 12, 50);
    character.addOffset("singUP", 25, 0);
    character.addOffset("singRIGHT", 0, 25);

    // Make the character dance (optional)
    character.dance();
}
```

`/!\` Please note that the last line is optional. If you want to create your character with a different animation, you can using `character.playAnim('XML (Animate) name')` instead of `character.dance()`.

Your character's done. To test it in game :
- Go to any song
- Press 7
- Go to song
- Select your mod in the drop down list below "Player 2 (them)" (or "Player 1 (you)" if you made a bf)
- Select your character in the drop down list below the mod drop down list
- Press Enter and try it out.

If you want to go deeper in Character programming, I recommend checking the documentation [**here**](../doc/chars.md).

# **4.** Stages
Wow ! You made a mod ! You added a song, you added a character. But it's the default stage. So you may be wondering : How do we make a stage ?

Actually it's pretty easy :

All stages are contained in the `/stages` folder (if it doesnt exist, create it) as individual hscripts.
For example :
- The stage `mountain` will be represented in the `/stages/mountain.hx` file.

To begin, start with creating the `/stages` folder, then inside it, create a `(stage name).hx` file.

To add sprites in the stage, we'll first need to define the `create()` function.

Open your file and make a `create()` function.
```haxe
function create() {

}
```

Next, we'll create a FlxSprite and add it in the stage.

```haxe
var sprite = new FlxSprite(100, 100);
var s = Paths.image("sprite");
sprite.loadGraphic(s);
PlayState.add(sprite);
```
How does it works ?

- On the first line, the game will create a sprite at coordinates X : 100, Y : 100.
- On the second line, the game will load an image from `/images/`. In this case, it'll be `/images/sprite.png`.
- On the third line, the sprite will apply the image we previously loaded.
- On the fouth line, the sprite will be added to the PlayState (the stage).

However, if you want an animated sprite/background, it almost works the same way as a character.
```haxe
var sprite = new FlxSprite(100, 100);
var tex = Paths.getSparrowAtlas("sprite");
sprite.frames = tex;
sprite.animation.add("animation name", "XML (Animate) name", 24, true);
sprite.animation.play("animation name");
PlayState.add(sprite);
```
How does it works ?
- On the first line, it creates the sprite
- On the second line, it loads the spritesheet from `/images/sprite.png` and `/images/sprite.xml`.
- On the third line, it applies the frames from the sparrow atlas on the FlxSprite
- On the fourth line, it adds an animation from the spritesheet (looped)
- On the sixth line, it starts the animation
- On the seventh line, it adds the sprite to the stage.

You can however go further and add a sprite that dances to the music :
```haxe
var sprite = null;
function create() {
    sprite = new FlxSprite(100, 100);
    var tex = Paths.getSparrowAtlas("sprite");
    sprite.frames = tex;
    sprite.animation.add("animation name", "XML (Animate) name", 24, true);
    sprite.animation.play("animation name");
    PlayState.add(sprite);
}

function beatHit(curBeat) {
    sprite.animation.play("animation name", true);
}
```
How does it works ?
- On the first line, it makes the sprite value accessible to every functions
- In the `create()` function, it creates and adds the sprite
- In the `beatHit()` function, it forces the animation to restart on every beat (second parameter).

You can also mess with other events. For further information, check the [Stage Documentation](../doc/stages.hx).

