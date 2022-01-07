package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BGGirlsSad extends FlxSprite
{
	var isPissed:Bool = true;
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('weeb/bgFreaks');

		swapDanceType();

		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function swapDanceType():Void
	{
		isPissed = !isPissed;
		if(!isPissed) { //Gets angy
			animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
			animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		} else { //Sad
			animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
			animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		}
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
