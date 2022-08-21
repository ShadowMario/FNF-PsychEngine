package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

/**
* Simple class for the background dancers of Week 4.
*/
class BackgroundDancer extends FlxSprite
{
	public static var shrek:Bool = false;
	/**
	 * Creates a new Background Dancer at the specified location.
	 * @param   x              The x position of the dancer
	 * @param   y              The y position of the dancer
	 */
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas(shrek ? "limo/shrekDancer" : "limo/limoDancer");
		animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.play('danceLeft');
		antialiasing = true;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
