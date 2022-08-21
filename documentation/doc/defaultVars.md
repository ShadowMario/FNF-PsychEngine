# Yoshi Engine's documentation - Default Variables
For each hscript (Stages, Characters, Modcharts, etc...), default variables/classes are automatically set/imported. These can be used to interact with the game, and mod it.

## Variables
- [`PlayState`](playstate.md) - Current PlayState instance
- `EngineSettings` - Copy of the engine settings that you can mess with. Will have effect in game (not permanent)
- `global` - `Map<String, Dynamic>` shared between all hscripts. Useful for sharing FlxSprites.
- `Paths` - Instance of the `Paths_Mod` class used to get assets from your mod folder.

## Classes
- `PlayState_` - Workaround to access `PlayState`'s static values.
- [`FlxSprite`](https://api.haxeflixel.com/flixel/FlxSprite.html) - *The main "game object" class.*.
- [`BitmapData`](https://api.haxeflixel.com/flash/display/BitmapData.html) - Bitmap Data used to do real time sprite editing (very slow, not recommended)
- [`FlxG`](https://api.haxeflixel.com/flixel/FlxG.html) - *Global helper class for audio, input, the camera system, the debugger and other global properties.*
- `Paths_` - Workaround to access the default `Paths` class, and get access to the base game's menu assets.
- [`Std`](https://api.haxe.org/Std.html) - *The Std class provides standard methods for manipulating basic types.*
- [`Math`](https://api.haxeflixel.com/Math.html) - *This class defines mathematical functions and constants.*
- [`FlxMath`](https://api.haxeflixel.com/flixel/math/FlxMath.html) - *A class containing a set of math-related functions.*
- [`FlxAssets`](https://api.haxeflixel.com/flixel/system/FlxAssets.html)
- [`Assets`](https://api.haxeflixel.com/openfl/utils/Assets.html) - *The Assets class provides a cross-platform interface to access embedded images, fonts, sounds and other resource files.* (only usable on assets in the assets folder.)
- `ModSupport` - The class used to configure hscripts.
- `Note` - Class for the notes you see in game.
- `Character` - Class used for the characters (Boyfriend, Girlfriend, Daddy Dearest)
- `Conductor` - Everything song and BPM related
- [`StringTools`](https://api.haxeflixel.com/StringTools.html) - *This class provides advanced methods on Strings.* (can't be used as an extension)
- [`FlxSound`](https://api.haxeflixel.com/flixel/system/FlxSound.html) - *This is the universal flixel sound object, used for streaming, music, and sound effects.* (Use `Paths.sound("path")` to load a FlxSound)
- [`FlxEase`](https://api.haxeflixel.com/flixel/tweens/FlxEase.html) - *Static class with useful easer functions that can be used by tweens.*
- [`FlxTween`](https://api.haxeflixel.com/flixel/tweens/FlxTween.html) - Handles tweens

`/!\ WARNING` DUE TO HSCRIPT LIMITATIONS, `FlxColor` IS ACTUALLY A HELPER, THAT MEANS YOU'LL NEED TO USE `new FlxColor(int)` TO USE THE FLXCOLOR FUNCTIONS, AND USE `flxColor.color` TO USE IT AS AN INT. `WARNING /!\`
- [`FlxColor`](https://api.haxeflixel.com/flixel/util/FlxColor.html) - *Class representing a color. Provides a variety of methods for creating and converting colors.*
- `Boyfriend` - Based on the `Character` class, this one handles Boyfriend's additional values.
- `BackgroundDancer` - Week 4's background dancing dancers (lmao)
- `BackgroundGirls` - Week 6's background dancing girls
- [`FlxTypedGroup`](https://api.haxeflixel.com/flixel/group/FlxTypedGroup.html) - *This is an organizational class that can update and render a bunch of `FlxBasics`.*
- [`FlxTimer`](https://api.haxeflixel.com/flixel/util/FlxTimer.html) - *A simple timer class, leveraging the new plugins system. Can be used with callbacks or by polling the finished flag. Not intended to be added to a game state or group; the timer manager is responsible for actually calling update(), not the user.*
- [`Json`](https://api.haxeflixel.com/haxe/Json.html) - *Cross-platform JSON API: it will automatically use the optimized native API if available.*
- `MP4Video` - Handles MP4 Videos (can be used in cutscenes and mid-song)
- `CoolUtil` - Access to ninjamuffin99's `CoolUtil` class, providing... well... cool utils.
- [`FlxTypeText`](https://api.haxeflixel.com/flixel/addons/text/FlxTypeText.html) - *This is loosely based on the TypeText class by Noel Berry, who wrote it for his Ludum Dare 22 game - Abandoned http://www.ludumdare.com/compo/ludum-dare-22/?action=preview&uid=1527*
- [`FlxText`](https://api.haxeflixel.com/flixel/text/FlxText.html) - *Extends FlxSprite to support rendering text. Can tint, fade, rotate and scale just like a sprite. Doesn't really animate though. Also does nice pixel-perfect centering on pixel fonts as long as they are only one-liners.*
- [`FlxAxes`](https://api.haxeflixel.com/flixel/util/FlxAxes.html) - Used for `screenCenter()`
- [`BitmapDataPlus`] - `BitmapData` but better. Used for the Blammed effect.
- [`Rectangle`](https://api.haxeflixel.com/flash/geom/Rectangle.html)
- [`Point`](https://api.haxeflixel.com/flash/geom/Point.html)
- [`Window`](https://api.haxeflixel.com/lime/ui/Window.html) - Current window