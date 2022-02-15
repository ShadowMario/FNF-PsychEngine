package;

import flixel.util.FlxTimer;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.GraphicsShader;

using StringTools;

class ShaderSprite extends FlxSprite
{
	var hShader:DynamicShaderHandler;

	public function new(type:String, optimize:Bool = false, ?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);

		// codism
		flipY = true;

		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);

		hShader = new DynamicShaderHandler(type, optimize);

		if (hShader.shader != null)
		{
			shader = hShader.shader;
		}

		antialiasing = FlxG.save.data.antialiasing;
	}
}
