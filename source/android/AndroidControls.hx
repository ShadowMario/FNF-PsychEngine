package android;

import android.flixel.FlxNewHitbox;
import android.flixel.FlxHitbox;
import android.flixel.FlxVirtualPad;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.math.FlxPoint;



class AndroidControls extends FlxSpriteGroup {
	public var virtualPad:FlxVirtualPad;
	public var hitbox:FlxHitbox;
	public var newHitbox:FlxNewHitbox;

	public function new() {
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

		switch (AndroidControls.getMode()) {
			case 0: // RIGHT_FULL
				initControler(0);
			case 1: // LEFT_FULL
				initControler(1);
			case 2: // CUSTOM
				initControler(2);
			case 3: // BOTH_FULL
				initControler(3);
			case 4: // HITBOX
				if (ClientPrefs.hitboxSelection != 'New') {
					initControler(5);
				} else {
					initControler(4);
				}
			case 5: // KEYBOARD
		}
	}

	private function initControler(virtualPadMode:Int = 0):Void {
		switch (virtualPadMode) {
			case 0:
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case 1:
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case 2:
				virtualPad = AndroidControls.getCustomMode(new FlxVirtualPad(RIGHT_FULL, NONE));
				add(virtualPad);
			case 3:
				virtualPad = new FlxVirtualPad(BOTH_FULL, NONE);
				add(virtualPad);
			case 4:
				newHitbox = new FlxNewHitbox();
				add(newHitbox);
			case 5:
				hitbox = new FlxHitbox();
				add(hitbox);
		}
	}

	override public function destroy():Void {
		super.destroy();

		if (virtualPad != null) {
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (newHitbox != null) {
			newHitbox = FlxDestroyUtil.destroy(newHitbox);
			newHitbox = null;
		}

		if (hitbox != null) {
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}
	}

	public static function setMode(mode:Int = 0):Void {
		FlxG.save.data.androidControlsMode = mode;
		FlxG.save.flush();
	}

	public static function getMode():Int {
		if (FlxG.save.data.androidControlsMode == null) {
			FlxG.save.data.androidControlsMode = 0;
			FlxG.save.flush();
		}

		return FlxG.save.data.androidControlsMode;
	}

	public static function setCustomMode(virtualPad:FlxVirtualPad):Void {
		if (FlxG.save.data.buttons == null) {
			FlxG.save.data.buttons = new Array();
			for (buttons in virtualPad)
				FlxG.save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		} else {
			var tempCount:Int = 0;
			for (buttons in virtualPad) {
				FlxG.save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		FlxG.save.flush();
	}

	public static function getCustomMode(virtualPad:FlxVirtualPad):FlxVirtualPad {
		var tempCount:Int = 0;

		if (FlxG.save.data.buttons == null)
			return virtualPad;

		for (buttons in virtualPad) {
			buttons.x = FlxG.save.data.buttons[tempCount].x;
			buttons.y = FlxG.save.data.buttons[tempCount].y;
			tempCount++;
		}

		return virtualPad;
	}
}
