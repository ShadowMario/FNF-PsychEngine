package android.flixel;

import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import android.flixel.FlxButton;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

/**
 * ...
 * @original author Ka Wing Chin
 * @modification's author: Saw (M.A. Jigsaw)
 */

class FlxVirtualPad extends FlxSpriteGroup 
{
	public var dPad:FlxSpriteGroup;
	public var actions:FlxSpriteGroup;
	public var buttonLeft:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonLeft2:FlxButton;
	public var buttonUp2:FlxButton;
	public var buttonRight2:FlxButton;
	public var buttonDown2:FlxButton;
	public var buttonA:FlxButton;
	public var buttonB:FlxButton;
	public var buttonC:FlxButton;
	public var buttonD:FlxButton;
	public var buttonE:FlxButton;
	public var buttonV:FlxButton;
	public var buttonX:FlxButton;
	public var buttonY:FlxButton;
	public var buttonZ:FlxButton;

	public function new(DPad:FlxDPadMode, Action:FlxActionMode)
	{
		super();

		switch (DPad)
		{
			case UP_DOWN:
				dPad = new FlxSpriteGroup();
				dPad.scrollFactor.set();
				dPad.add(add(buttonUp = createButton(0, FlxG.height - 255, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonDown = createButton(0, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF)));
			case LEFT_RIGHT:
				dPad = new FlxSpriteGroup();
				dPad.scrollFactor.set();
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(127, FlxG.height - 135, 132, 127, 'right', 0xFFFF0000)));
			case UP_LEFT_RIGHT:
				dPad = new FlxSpriteGroup();
				dPad.scrollFactor.set();
				dPad.add(add(buttonUp = createButton(105, FlxG.height - 243, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(207, FlxG.height - 135, 132, 127, 'right', 0xFFFF0000)));
			case FULL:
				dPad = new FlxSpriteGroup();
				dPad.scrollFactor.set();
				dPad.add(add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF)));
			case RIGHT_FULL:
				dPad = new FlxSpriteGroup();
				dPad.scrollFactor.set();
				dPad.add(add(buttonUp = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF)));
			case DUO:
				dPad = new FlxSpriteGroup();
				dPad.scrollFactor.set();
				dPad.add(add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF)));
				dPad.add(add(buttonUp2 = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft2 = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight2 = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown2 = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF)));
			default:
		}

		switch (Action)
		{
			case A:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case B:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonB = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'b')));
			case D:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonD = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'd')));
			case A_B:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
			case A_B_C:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_E:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonE = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'e')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
 			case A_B_X_Y:
 				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonX = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'x')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonY = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'y')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_C_X_Y:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonX = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'x')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonY = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'y')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_C_X_Y_Z:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x')));
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case FULL:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v')));
				actions.add(add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd')));
				actions.add(add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x')));
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case FULL_UP_DOWN:
				actions = new FlxSpriteGroup();
				actions.scrollFactor.set();
				actions.add(add(buttonUp2 = createButton(FlxG.width - 636, FlxG.height - 255, 132, 127, 'up')));
				actions.add(add(buttonDown2 = createButton(FlxG.width - 636, FlxG.height - 135, 132, 127, 'down')));
				actions.add(add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v')));
				actions.add(add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd')));
				actions.add(add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x')));
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			default:
		}
	}

	public function createButton(x:Float, y:Float, width:Int, height:Int, frames:String, ?color:Int):FlxButton
	{
		var button:FlxButton = new FlxButton(x, y);
		button.frames = FlxTileFrames.fromFrame(getFrames().getByName(frames), FlxPoint.get(width, height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end
		button.scrollFactor.set();
		button.alpha = 0.6;
		button.antialiasing = ClientPrefs.globalAntialiasing;
		if (color != null)
			button.color = color;

		return button;
	}

	public static function getFrames():FlxAtlasFrames
	{
		return Paths.getSparrowAtlas('android/virtualpad');
	}

	override public function destroy():Void
	{
		super.destroy();

		if (dPad != null)
		{
			dPad = FlxDestroyUtil.destroy(dPad);
			dPad = null;
		}

		if (actions != null)
		{
			actions = FlxDestroyUtil.destroy(actions);
			actions = null;
		}

		if (buttonLeft != null)
			buttonLeft = null;

		if (buttonUp != null)
			buttonUp = null;

		if (buttonDown != null)
			buttonDown = null;

		if (buttonRight != null)
			buttonRight = null;

		if (buttonLeft2 != null)
			buttonLeft2 = null;

		if (buttonUp2 != null)
			buttonUp2 = null;

		if (buttonDown2 != null)
			buttonDown2 = null;

		if (buttonRight2 != null)
			buttonRight2 = null;

		if (buttonA != null)
			buttonA = null;

		if (buttonB != null)
			buttonB = null;

		if (buttonC != null)
			buttonC = null;

		if (buttonD != null)
			buttonD = null;

		if (buttonE != null)
			buttonE = null;

		if (buttonV != null)
			buttonV = null;

		if (buttonX != null)
			buttonX = null;

		if (buttonY != null)
			buttonY = null;

		if (buttonZ != null)
			buttonZ = null;
	}
}

enum FlxDPadMode
{
	UP_DOWN;
	LEFT_RIGHT;
	UP_LEFT_RIGHT;
	FULL;
	RIGHT_FULL;
	DUO;
	NONE;
}

enum FlxActionMode
{
	A;
	B;
	D;
	A_B;
	A_B_C;
	A_B_E;
	A_B_X_Y;	
	A_B_C_X_Y;
	A_B_C_X_Y_Z;
	FULL;
	FULL_UP_DOWN;
	NONE;
}
