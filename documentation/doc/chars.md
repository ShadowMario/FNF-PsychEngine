# Yoshi Engine's documentation - Characters
In each mod, every characters is located under `/mods/(Your Mod)/characters/`. Each character is represented by a folder, which contains these files :
- **`Character.hx` (Character script)**
- `icon.png` (Character Icon File, 300x150 (Grid of 150x150 icons))
- `spritesheet.png` (Character's Spritesheet)
- `spritesheet.xml` (Character's Sparrow XML)
---
## `Character.hx` - Documentation

---
**`create():Void`**

Fired during the character initialisation.

Available variables :
- `character:Character` - The character's FlxSprite.
- `curCharacter:String` - The character's name (ex : `Friday Night Funkin':bf`)
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
function create() {
    //Loads Daddy Dearest's spritesheet
    character.frames = Paths.getCharacter("Friday Night Funkin':dad");

    // Configures default animations
    character.animation.addByPrefix('idle', 'Dad idle dance', 24, false);
    character.animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
    character.animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
    character.animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
    character.animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

    // Configure offests
    character.addOffset('idle');
    character.addOffset("singUP", -6, 50);
    character.addOffset("singRIGHT", 0, 27);
    character.addOffset("singLEFT", -10, 10);
    character.addOffset("singDOWN", 0, -30);

    // Makes Daddy Dearest do his first animation.
    character.dance();
}
```

---
**`dance():Void`**

This function is fired whenever `character.dance()` is fired. Handles your character's dancing animations.

Defaults to :
```haxe
function dance() {
    character.playAnim("idle");
}
```

Available variables :
- `character:Character` - The character's FlxSprite.
- `curCharacter:String` - The character's name (ex : `Friday Night Funkin':bf`)
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
// If the spooky kids did the danceRight animation
danced = false; 

function dance() {
    // Checks if the spooky kids did the danceRight animation
    if (danced) 
        // Plays the danceLeft animation
        character.playAnim("danceLeft");
    else
        // Plays the danceRight animation
        character.playAnim("danceRight");

    // Inverts the danced variable (true -> false or false -> true) so that the other dancing animation will be played.
    danced = !danced;
}
```

---
**`update(elapsed:Float):Void`**

This function is fired every frame.

Defaults to :
```haxe
function dance(elapsed) {
    // Do nothing
}
```

Available variables :
- `elapsed:Float` (function parameter) - The amount of time between this frame and the last one in seconds.
- `character:Character` - The character's FlxSprite.
- `curCharacter:String` - The character's name (ex : `Friday Night Funkin':bf`)
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
// This code will make your character levitate.

// Original character Y position
var ogY:Null<Int> = null;

// Angle of levitation (in radians)
var levitatingVariable = 0;
function update(elapsed:Float) {
    
    // Updates the variable by adding 180° per second.
    levitatingVariable += (elapsed * Math.PI);

    // If the original Y position is null, set it to the character's actual Y position.
    if (ogY == null) ogY = character.y;
    
    // Sets the character's Y position
    character.y = ogY - 200 + (Math.sin(levitatingVariable) * 100);
    
    // Set the character's angle.
    character.angle = Math.sin(levitatingVariable / 4) * 10;
}
```

---
**`onAnim(animName:String):Void`**

This function is fired everytime the character will play an animation using `character.playAnim(animName)`;

Defaults to :
```haxe
function onAnim(animName:String) {
    // Do nothing
}
```

Available variables :
- `animName:String` (function parameter) - The amount of time between this frame and the last one in seconds.
- `character:Character` - The character's FlxSprite.
- `curCharacter:String` - The character's name (ex : `Friday Night Funkin':bf`)
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
function onAnim(animName:String) {
    // Checks if the animation name is "idle".
    if (animName == "idle") {
        // Switches character's color to white
        character.color = 0xFFFFFFFF;
    } else {
        // Switches character's color to red
        character.color = 0xFF880000;
    }
}
```
---
**`getColors(altAnim:Bool):Array<Int>`**

This function is called whenever the engine needs your character's arrow colors or your character's health bar color.

Returns an `Array<Int>` which contains :
- The health bar color as the first element (0)
- The note colors

Defaults to:
```haxe
function getColors(altAnim:Bool) {
    return [
        // Returns the green color if the character is the player, or else returns the red color.
        (character.isPlayer ? 0xFF66FF33 : 0xFFFF0000),

        // Returns the player's arrow colors.
        EngineSettings.arrowColor0,
        EngineSettings.arrowColor1,
        EngineSettings.arrowColor2,
        EngineSettings.arrowColor3
    ];   
}
```

Available variables :
- `altAnim:Bool` (function parameter) - Whenever the note is using an alt animation.
- `character:Character` - The character's FlxSprite.
- `curCharacter:String` - The character's name (ex : `Friday Night Funkin':bf`)
- [Every other default variables](defaultVars.md)

Example Usage :
```haxe
function getColors(altAnim:Bool) {
    return [
        // Skid & Pump's health bar color
        0xFFAF66CE, 

        // Skid & Pump's arrow colors
        0xFFAF66CE,
        0xFFAF66CE,
        0xFFAF66CE,
        0xFFAF66CE
    ];
}
```