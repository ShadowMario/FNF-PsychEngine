# Yoshi Engine's documentation - Stages
In each mod, every stages is located under `/mods/(Your Mod)/stages/`. Each stage is represented by a hx file.

---
## Scripts Documentation

/!\ NOTE : Lua functions that have parameters that Lua does not support will instead send `nil` as the parameter. To access it, use the global `parameter(number)` (ex : `parameter1`) to access it like this :
```lua
function onDadHit(note)
    -- note is nil, use this instead
    local strumTime = get("parameter1.strumTime");
end
```

---
**`create():Void`**
**`createAfterChars():Void`** (runs after create())

Fired first, **after GF, BF and Dad are created**.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- `gfVersion:String` - Girlfriend's sprite version. Only have effect outside of functions (above)
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
gfVersion = "gf-car";
function create() {
    // Creates a sprite, loads a graphica and adds it.
    var sprite = new FlxSprite(100, 100);
    var tex = Paths.getSparrowAtlas("sprite");
    sprite.frames = tex;
    sprite.animation.add("animation name", "XML (Animate) name", 24, true);
    sprite.animation.play("animation name");
    PlayState.add(sprite);
}
```
```haxe
function create() {
    // Layering example
    var sprite = new FlxSprite(100, 100);
    var tex = Paths.getSparrowAtlas("sprite");
    sprite.frames = tex;
    sprite.animation.add("animation name", "XML (Animate) name", 24, true);
    sprite.animation.play("animation name");
    // Adds GF
    PlayState.add(PlayState.gf);
    // Adds the sprite in front of Girlfriend
    PlayState.add(sprite);
}
```

---
**`createPost():Void`**
Runs after the `super.create()` (requested by raf on my discord server)
Example usage:
```haxe
function createPost() {
    // Hides the icons
    PlayState.iconP1.visible = false;
    PlayState.iconP2.visible = false;
}
```

---
**`onGuiPopup():Void`**
Runs after the GUI has been popped up.
Example usage:
```haxe
function onGuiPopup() {
    // Hides the icons (again)
    PlayState.iconP1.visible = false;
    PlayState.iconP2.visible = false;
}
```

---
**`onStartCountdown():Void`**
Runs when `startCountdown()` is called.
Example usage:
```haxe
function onStartCountdown() {
    sprite.animation.play("anim during cooldown");
}
```

---
**`onGenerateStaticArrows():Void`**
Runs after `generateStaticArrows()` was called for all characters..
Example usage:
```haxe
function onGenerateStaticArrows() {
    // Change the arrows position here
}
```

---
**`onCountdown(number:Int):Void`**
Runs when the countdown goes

Params:
- `number:Int`: Current number (goes from 3 to 0, 0 being "Go!")

To prevent the default number appearance, return false.
Example usage:
```haxe
function onCountdown(val:Int) {
    // Hides the icons (again)
    switch(val) {
        case 3:
            sprite.animation.play("3");
        case 2:
            sprite.animation.play("2");
        case 1:
            sprite.animation.play("1");
        case 0:
            sprite.animation.play("GO!");
    }

    return false;
}
```

---
**`onShowCombo(combo:Int, coolText:FlxText):Void`**
Runs when the countdown goes

Params:
- `combo:Int`: Current combo
- `coolText:FlxText`: Text used for placement

To prevent the default number appearance, return false.
Example usage:
```haxe
function onShowCombo(combo:Int, coolText:FlxText) {
    // Show your own combo thingy
    ...

    // Prevent showing default combo
    return false;
}
```

---
**`createInFront():Void`**
Same as `create()` excepts run after GF, BF and Dad are added in stage.

---
**`musicstart():Void`**

Fired when the countdown finished and the music starts

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)

---
**`preUpdate(elapsed:Float):Void`**

Like update, excepts runs at the beginning of PlayState's `update` function.

Params :
- `elapsed:Float` : Time elapsed


---
**`postUpdate(elapsed:Float):Void`**

Like update, excepts runs at the end of PlayState's `update` function.

Params :
- `elapsed:Float` : Time elapsed


---
**`onHealthUpdate(elapsed:Float):Void`**

Runs before health updates. Return false to prevent the engine from updating the health icon position, allowing you to do it yourself.

Params :
- `elapsed:Float` : Time elapsed

---
**`update(elapsed:Float):Void`**

Fired every frames. Does not fire when in cutscene.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)


Example usage :
```haxe
function update(elapsed:Float) {
    // Spins the dad
    PlayState.dad.angle = (PlayState.dad.angle + (180 * elapsed)) % 360;
}
```
---
**`stepHit(curStep:Int):Void`**

Fired every step.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)


Example usage :
```haxe
function stepHit(curStep:Int) {
    // i have no example here lmao
}
```
---
**`beatHit(curBeat:Int):Void`**

Fired every beat.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)


Example usage :
```haxe
function beatHit(curBeat:Int) {
    // Makes a sprite dance.
    sprite.animation.play("dance");
}
```
---
**`onDadHit(note:Note):Void`**

Fired when the opponent (dad) hits a note.

Available variables :
- [All default variables](defaultVars.md)


Example usage :
```haxe
function onDadHit(note:Note) {
    // i have no example here lmao
}
```
---
**`onPlayerHit(note:Note):Void`**

Fired when BF (the player) hits a note.

Available variables :
- [All default variables](defaultVars.md)


Example usage :
```haxe
function onPlayerHit(note:Note) {
    // i have no example here lmao
}
```