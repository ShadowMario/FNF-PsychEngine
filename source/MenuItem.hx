package;

import openfl.utils.Assets;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.display.BitmapData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, spriteData:String)
	{
		super(x, y);

		var spritePath = Paths.image(CoolUtil.getCleanupImagesPath(spriteData));
		week = new FlxSprite().loadGraphic(spritePath);
		week.antialiasing = true;
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	var time:Float = 0;

	override function update(elapsed:Float)
	{
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 * 60 * elapsed);
		super.update(elapsed);

		if (!isFlashing) return;
		time += elapsed;
		time %= 1 / 6;

		week.color = time < 1 / 12 ? 0xFF33ffff : 0xFFFFFFFF;
	}
}
