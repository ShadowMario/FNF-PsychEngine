package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	/**
	 * Create a new character at the specified location
	 * @param   x               The x position of the Boyfriend
	 * @param   y               The y position of the Boyfriend
	 * @param   char            The character for BF (ex : `bf`, `bf-christmas`, `bf-car`), default is `bf`
	 * @param   textureOverride Optional, allows you to override the texture. (ex : `bf` as char for Boyfriend's anims and assets, and `blammed` for the Boyfriend blammed appearance)
	 */
	public function new(x:Float, y:Float, ?char:String = 'bf', ?textureOverride:String = "")
	{
		super(x, y, char, true, textureOverride);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				dance();
			}

		}

		super.update(elapsed);
	}
}
