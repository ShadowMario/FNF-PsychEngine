package android.flixel;

import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxSpriteGroup;
import android.flixel.FlxButton;

class FlxHitbox extends FlxSpriteGroup 
{
	public var hitbox:FlxSpriteGroup;

	public var buttonLeft:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;

	public var sizeX:Float = 320;
	public var sizeY:Float = 720;

	public function new()
	{
		super();

		hitbox = new FlxSpriteGroup();

		buttonLeft = new FlxButton(0, 0);
		buttonDown = new FlxButton(0, 0);
		buttonUp = new FlxButton(0, 0);
		buttonRight = new FlxButton(0, 0);

		sizeX = FlxG.width / 4;
		sizeY = FlxG.height;

		hitbox.add(add(buttonLeft = createHitbox(0, 0, 'left', 0xFFFF00FF)));
		hitbox.add(add(buttonDown = createHitbox(sizeX, 0, 'down', 0xFF00FFFF)));
		hitbox.add(add(buttonUp = createHitbox(sizeX * 2, 0, 'up', 0xFF00FF00)));
		hitbox.add(add(buttonRight = createHitbox(sizeX * 3, 0, 'right', 0xFFFF0000)));
	}

	public function createHitbox(x:Float = 0, y:Float = 0, frames:String, ?color:Int):FlxButton
	{
		var hint:FlxHitboxHint = new FlxHitboxHint(x, y, frames);
		hint.antialiasing = ClientPrefs.globalAntialiasing;
		if (color != null && ClientPrefs.visualColours)
			hint.color = color;
		return hint;
	}

	override function destroy()
	{
		super.destroy();

		hitbox = FlxDestroyUtil.destroy(hitbox);
		hitbox = null;

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
	}
}
