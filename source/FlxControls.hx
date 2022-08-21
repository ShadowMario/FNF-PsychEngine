

import flixel.FlxSubState;
import flixel.FlxState;
import flixel.input.keyboard.FlxKeyList;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

using haxe.EnumTools;

enum FlxControlType {
	JustPressed;
	JustReleased;
	Pressed;
}
class FlxControls {
	//
	// PRESSED
	//
    public static var pressed(get, null):Dynamic;
    private static function get_pressed() {
        var list = getAndroidInput(Pressed);
		var map = FlxKey.toStringMap;
        var keys = map.keys();
        while(keys.hasNext()) {
            var id = keys.next();
            var name = map[id];
			if (!Reflect.hasField(list, map[id])) {
				Reflect.setField(list, name, FlxG.keys.anyPressed([id]));
			}
			
        }
        return list;
        
    }
    public static function anyPressed(keys:Array<FlxKey>) {
		#if MOBILE_UI
			// android stuff
			var input = getAndroidInput(Pressed);
			var map = FlxKey.toStringMap;
			for (k in keys) {
				if (Reflect.hasField(input, map[k])) {
					return true;
				}
			}
			return FlxG.keys.anyPressed(keys);
		#else
			return FlxG.keys.anyPressed(keys);
		#end
    }

    public static var justPressed(get, null):Dynamic;
    private static function get_justPressed() {
        var list = getAndroidInput(JustPressed);
		var map = FlxKey.toStringMap;
        var keys = map.keys();
        while(keys.hasNext()) {
            var id = keys.next();
            var name = map[id];
			if (!Reflect.hasField(list, map[id])) {
				Reflect.setField(list, name, FlxG.keys.anyJustPressed([id]));
			}
			
        }
        return list;
        
    }
    public static function anyJustPressed(keys:Array<FlxKey>) {
		#if MOBILE_UI
			// android stuff
			var input = getAndroidInput(JustPressed);
			var map = FlxKey.toStringMap;
			for (k in keys) {
				if (Reflect.hasField(input, map[k])) {
					return true;
				}
			}
			return FlxG.keys.anyJustPressed(keys);
		#else
			return FlxG.keys.anyJustPressed(keys);
		#end
    }

    public static var justReleased(get, null):Dynamic;
    private static function get_justReleased() {
        var list = getAndroidInput(JustReleased);
		var map = FlxKey.toStringMap;
        var keys = map.keys();
        while(keys.hasNext()) {
            var id = keys.next();
            var name = map[id];
			if (!Reflect.hasField(list, map[id])) {
				Reflect.setField(list, name, FlxG.keys.anyJustReleased([id]));
			}
			
        }
        return list;
        
    }
    public static function anyJustReleased(keys:Array<FlxKey>) {
		#if MOBILE_UI
			// android stuff
			var input = getAndroidInput(JustReleased);
			var map = FlxKey.toStringMap;
			for (k in keys) {
				if (Reflect.hasField(input, map[k])) {
					return true;
				}
			}
			return FlxG.keys.anyJustReleased(keys);
		#else
			return FlxG.keys.anyJustReleased(keys);
		#end
    }

	public static function firstJustPressed() {
		#if MOBILE_UI
			var currentState = FlxG.state;
			var map = FlxKey.toStringMap;
			for(c in currentState.members) {
				if (Std.isOfType(c, FlxClickableSprite)) {
					var sprite = cast(c, FlxClickableSprite);
					if (sprite.key != null && sprite.justPressed) {
						return sprite.key;
					}
				}
			}
			return FlxG.keys.firstJustPressed();
		#else
			return FlxG.keys.firstJustPressed();
		#end
	}

	public static function firstPressed() {
		#if MOBILE_UI
			var currentState = FlxG.state;
			var map = FlxKey.toStringMap;
			for(c in currentState.members) {
				if (Std.isOfType(c, FlxClickableSprite)) {
					var sprite = cast(c, FlxClickableSprite);
					if (sprite.key != null && sprite.pressed) {
						return sprite.key;
					}
				}
			}
			return FlxG.keys.firstPressed();
		#else
			return FlxG.keys.firstPressed();
		#end
	}

	public static function firstJustReleased() {
		#if MOBILE_UI
			var currentState = FlxG.state;
			var map = FlxKey.toStringMap;
			for(c in currentState.members) {
				if (Std.isOfType(c, FlxClickableSprite)) {
					var sprite = cast(c, FlxClickableSprite);
					if (sprite.key != null && sprite.justReleased) {
						return sprite.key;
					}
				}
			}
			return FlxG.keys.firstJustReleased();
		#else
			return FlxG.keys.firstJustReleased();
		#end
	}
	private static function lolAndroidShit(currentState:FlxState, result:Dynamic, type:FlxControlType) {
		var map = FlxKey.toStringMap;
		if (currentState.subState != null) {
			lolAndroidShit(currentState.subState, result, type);
			return;
		}
		for(c in currentState.members) {
			if (Std.isOfType(c, FlxClickableSprite)) {
				var sprite = cast(c, FlxClickableSprite);
				if (sprite.key != null) {
					switch (type) {
						case Pressed:
							if (sprite.pressed) {
								Reflect.setField(result, map[sprite.key], true);
							}
						case JustPressed:
							if (sprite.justPressed) {
								Reflect.setField(result, map[sprite.key], true);
							}
						case JustReleased:
							if (sprite.justReleased) {
								Reflect.setField(result, map[sprite.key], true);
							}
					}
				}
			}
		}
	}
    public static function getAndroidInput(type:FlxControlType):Dynamic {
		#if MOBILE_UI
			var result = {};
			var currentState = FlxG.state;
			lolAndroidShit(currentState, result, type);
			return result;
		#else
			return {};
		#end
    }
}