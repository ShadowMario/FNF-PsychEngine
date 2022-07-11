package android.flixel;

import android.flixel.FlxButton;
import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;

/**
 * A gamepad.
 * It's easy to set the callbacks and to customize the layout.
 *
 * @original author Ka Wing Chin
 * @modification's author: Saw (M.A. Jigsaw)
 */
class FlxVirtualPad extends FlxSpriteGroup
{
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

	/**
	 * Group of directions buttons.
	 */
	public var dPad:FlxSpriteGroup;

	/**
	 * Group of action buttons.
	 */
	public var actions:FlxSpriteGroup;

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:FlxDPadMode, Action:FlxActionMode)
	{
		super();

		scrollFactor.set();

		dPad = new FlxSpriteGroup();
		dPad.scrollFactor.set();

		switch (DPad)
		{
			case UP_DOWN:
				dPad.add(add(buttonUp = createButton(0, FlxG.height - 255, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonDown = createButton(0, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF)));
			case LEFT_RIGHT:
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(127, FlxG.height - 135, 132, 127, 'right', 0xFFFF0000)));
			case UP_LEFT_RIGHT:
				dPad.add(add(buttonUp = createButton(105, FlxG.height - 243, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(207, FlxG.height - 135, 132, 127, 'right', 0xFFFF0000)));
			case LEFT_FULL:
				dPad.add(add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF)));
			case RIGHT_FULL:
				dPad.add(add(buttonUp = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF)));
			case BOTH_FULL:
				dPad.add(add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF)));
				dPad.add(add(buttonUp2 = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF00FF00)));
				dPad.add(add(buttonLeft2 = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFFF00FF)));
				dPad.add(add(buttonRight2 = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFFF0000)));
				dPad.add(add(buttonDown2 = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF)));
			case NONE: // do nothing
		}

		actions = new FlxSpriteGroup();
		actions.scrollFactor.set();

		switch (Action)
		{
			case A:
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case B:
				actions.add(add(buttonB = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'b')));
			case A_B:
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
			case A_B_C:
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_E:
				actions.add(add(buttonE = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'e')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_X_Y:
				actions.add(add(buttonX = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'x')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonY = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'y')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_C_X_Y:
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonX = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'x')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonY = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'y')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_C_X_Y_Z:
				actions.add(add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x')));
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case A_B_C_D_V_X_Y_Z:
				actions.add(add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v')));
				actions.add(add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd')));
				actions.add(add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x')));
				actions.add(add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c')));
				actions.add(add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y')));
				actions.add(add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b')));
				actions.add(add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z')));
				actions.add(add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a')));
			case NONE: // do nothing
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		dPad = FlxDestroyUtil.destroy(dPad);
		dPad = null;

		actions = FlxDestroyUtil.destroy(actions);
		actions = null;

		buttonLeft = null;
		buttonUp = null;
		buttonDown = null;
		buttonRight = null;
		buttonLeft2 = null;
		buttonUp2 = null;
		buttonDown2 = null;
		buttonRight2 = null;
		buttonA = null;
		buttonB = null;
		buttonC = null;
		buttonD = null;
		buttonE = null;
		buttonV = null;
		buttonX = null;
		buttonY = null;
		buttonZ = null;
	}

	/**
	 * @param   X          The x-position of the button.
	 * @param   Y          The y-position of the button.
	 * @param   Width      The width of the button.
	 * @param   Height     The height of the button.
	 * @param   Graphic    The image of the button. It must contains 3 frames (`NORMAL`, `HIGHLIGHT`, `PRESSED`).
	 * @param   Color      The color of the button.
	 * @return  The button
	 */
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, ?Color:Int = 0xFFFFFF):FlxButton
	{
		var button:FlxButton = new FlxButton(X, Y);
		button.frames = FlxTileFrames.fromFrame(FlxAtlasFrames.fromSparrow('assets/android/virtualpad.png', 'assets/android/virtualpad.xml').getByName(Graphic), FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.set();
		button.color = Color;
		button.alpha = 0.6;
		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end
		return button;
	}
}

enum FlxDPadMode
{
	UP_DOWN;
	LEFT_RIGHT;
	UP_LEFT_RIGHT;
	LEFT_FULL;
	RIGHT_FULL;
	BOTH_FULL;
	NONE;
}

enum FlxActionMode
{
	A;
	B;
	A_B;
	A_B_C;
	A_B_E;
	A_B_X_Y;
	A_B_C_X_Y;
	A_B_C_X_Y_Z;
	A_B_C_D_V_X_Y_Z;
	NONE;
}
