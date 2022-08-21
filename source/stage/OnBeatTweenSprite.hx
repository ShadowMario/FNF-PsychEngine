package stage;

import flixel.FlxSprite;

typedef OnBeatTweenSprite = {
	var sprite:FlxSprite;
	var offset:Point;
	var easeFunc:Float->Float;
}