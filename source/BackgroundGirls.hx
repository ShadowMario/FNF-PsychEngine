package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

/**
* Simple class for the Background Girls in Week 6
*/
class BackgroundGirls extends FlxSprite
{
	/**
	 * Creates the background girls at the specified location (not upscaled automatically)
	 * @param   x              Background Girls's x position
	 * @param   y              Background Girls's y position
	 */
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/bgFreaks');

		animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);

		animation.play('danceLeft');
	}

	var danceDir:Bool = false;
	/**	
	 * Override the default animations by the scared ones, making the girls scared.
	 */
	public function getScared():Void
	{
		animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		dance();
	}
	/**
	 * Make the background girls dance
	 */
	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
