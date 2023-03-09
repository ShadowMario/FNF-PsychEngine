package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var startedDeath:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing')) holdTimer += elapsed;
			else {if (!PlayState.instance.opponentPlay) holdTimer = 0;}
			
			if (PlayState.instance.opponentPlay) {
				if (holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * singDuration) {
					dance();
					holdTimer = 0;
				}
			} else {
				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
				playAnim('deathLoop');
		}

		super.update(elapsed);
	}
}
