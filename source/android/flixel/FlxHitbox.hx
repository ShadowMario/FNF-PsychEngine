package android.flixel;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import android.flixel.FlxButton;

class FlxHitbox extends FlxSpriteGroup 
{
	public var hitbox:FlxSpriteGroup;

	public var buttonLeft:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;

	public function new()
	{
		super();

		hitbox = new FlxSpriteGroup();

		buttonLeft = new FlxButton(0, 0);
		buttonDown = new FlxButton(0, 0);
		buttonUp = new FlxButton(0, 0);
		buttonRight = new FlxButton(0, 0);

		hitbox.add(add(buttonLeft = createHitbox(0, 0, 'left', 0xFFFF00FF)));
		hitbox.add(add(buttonDown = createHitbox(320, 0, 'down', 0xFF00FFFF)));
		hitbox.add(add(buttonUp = createHitbox(640, 0, 'up', 0xFF00FF00)));
		hitbox.add(add(buttonRight = createHitbox(960, 0, 'right', 0xFFFF0000)));

		if (ClientPrefs.hitboxHints)
		{
			hitbox.add(add(createHitboxHint(0, 0, 'left_hint', 0xFFFF00FF)));
			hitbox.add(add(createHitboxHint(320, 0, 'down_hint', 0xFF00FFFF)));
			hitbox.add(add(createHitboxHint(640, 0, 'up_hint', 0xFF00FF00)));
			hitbox.add(add(createHitboxHint(960, 0, 'right_hint', 0xFFFF0000)));
		}
	}

	public function createHitbox(x:Float = 0, y:Float = 0, frames:String, ?color:Int):FlxButton
	{
		var hint:FlxHitboxHint = new FlxHitboxHint(x, y, frames);
		hint.antialiasing = ClientPrefs.globalAntialiasing;
		if (color != null && ClientPrefs.visualColours)
			hint.color = color;
		return hint;
	}

	public function createHitboxHint(x:Float = 0, y:Float = 0, frames:String, ?color:Int):FlxSprite
	{
		var hint:FlxSprite = new FlxSprite(x, y);
		hint.loadGraphic(FlxGraphic.fromFrame(getFrames().getByName(frames)));
		hint.alpha = 0.75;
		hint.antialiasing = ClientPrefs.globalAntialiasing;
		if (color != null && ClientPrefs.visualColours)
			hint.color = color;
		return hint;
	}

	public function getFrames():FlxAtlasFrames
	{
		return Paths.getSparrowAtlas('android/hitbox');
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
