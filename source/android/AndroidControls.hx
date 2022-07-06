package android;

import android.flixel.FlxHitbox;
import android.flixel.FlxVirtualPad;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;

using StringTools;

class AndroidControls extends FlxSpriteGroup
{
	public var virtualPad:FlxVirtualPad;
	public var hitbox:FlxHitbox;

	public function new()
	{
		super();

		switch (AndroidControls.getMode())
		{
			case 0: // RIGHT_FULL
				initControler(0);
			case 1: // LEFT_FULL
				initControler(1);
			case 2: // CUSTOM
				initControler(2);
			case 3: // BOTH_FULL
				initControler(3);
			case 4: // HITBOX
				initControler(4);
			case 5: // KEYBOARD
		}
	}

	private function initControler(virtualPadMode:Int = 0):Void
	{
		switch (virtualPadMode)
		{
			case 0:
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case 1:
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case 2:
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				virtualPad = AndroidControls.getCustom(virtualPad);
				add(virtualPad);
			case 3:
				virtualPad = new FlxVirtualPad(BOTH_FULL, NONE);
				add(virtualPad);
			case 4:
				hitbox = new FlxHitbox();
				add(hitbox);
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
		{
			remove(virtualPad);
			virtualPad = null;
		}

		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = null;
		}
	}

	public function resetColors():Void
	{
		if (virtualPad != null)
		{
			if (virtualPad.buttonUp != null)
				virtualPad.buttonUp.color = 0xFF00FF00;

			if (virtualPad.buttonLeft != null)
				virtualPad.buttonLeft.color = 0xFFFF00FF;

			if (virtualPad.buttonRight != null)
				virtualPad.buttonRight.color = 0xFFFF0000;

			if (virtualPad.buttonDown != null)
				virtualPad.buttonDown.color = 0xFF00FFFF;

			if (virtualPad.buttonUp2 != null)
				virtualPad.buttonUp2.color = 0xFF00FF00;

			if (virtualPad.buttonLeft2 != null)
				virtualPad.buttonLeft2.color = 0xFFFF00FF;

			if (virtualPad.buttonRight2 != null)
				virtualPad.buttonRight2.color = 0xFFFF0000;

			if (virtualPad.buttonDown2 != null)
				virtualPad.buttonDown2.color = 0xFF00FFFF;
		}
		else if (hitbox != null)
		{
			if (hitbox.buttonLeft != null)
				hitbox.buttonLeft.color = 0xFFFF00FF;

			if (hitbox.buttonDown != null)
				hitbox.buttonDown.color = 0xFF00FFFF;

			if (hitbox.buttonLeft != null)
				hitbox.buttonUp.color = 0xFF00FF00;

			if (hitbox.buttonRight != null)
				hitbox.buttonRight.color = 0xFFFF0000;
		}
	}

	public static function setMode(mode:Int = 0)
	{
		FlxG.save.data.buttonsmode = mode;
		FlxG.save.flush();
	}

	public static function getMode():Int
	{
		if (FlxG.save.data.buttonsmode != null)
			return FlxG.save.data.buttonsmode;

		return 0;
	}

	public static function setCustom(virtualPad:FlxVirtualPad)
	{
		if (FlxG.save.data.buttons == null)
		{
			FlxG.save.data.buttons = new Array();
			for (buttons in virtualPad)
				FlxG.save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		}
		else
		{
			var tempCount:Int = 0;

			for (buttons in virtualPad)
			{
				FlxG.save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		FlxG.save.flush();
	}

	public static function getCustom(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		var tempCount:Int = 0;

		if (FlxG.save.data.buttons == null)
			return virtualPad;

		for (buttons in virtualPad)
		{
			buttons.x = FlxG.save.data.buttons[tempCount].x;
			buttons.y = FlxG.save.data.buttons[tempCount].y;
			tempCount++;
		}

		return virtualPad;
	}
}
