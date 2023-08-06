package mobile.flixel;

import mobile.flixel.FlxButton;
import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets;

/**
 * A gamepad.
 * It's easy to customize the layout.
 *
 * @original author Ka Wing Chin
 * @modification's author: Saw (M.A. Jigsaw) & Karim Akra (UTFan)
 */
class FlxVirtualPad extends FlxSpriteGroup
{
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonLeft2:FlxButton = new FlxButton(0, 0);
	public var buttonUp2:FlxButton = new FlxButton(0, 0);
	public var buttonRight2:FlxButton = new FlxButton(0, 0);
	public var buttonDown2:FlxButton = new FlxButton(0, 0);
	public var buttonA:FlxButton = new FlxButton(0, 0);
	public var buttonB:FlxButton = new FlxButton(0, 0);
	public var buttonC:FlxButton = new FlxButton(0, 0);
	public var buttonD:FlxButton = new FlxButton(0, 0);
	public var buttonE:FlxButton = new FlxButton(0, 0);
	public var buttonV:FlxButton = new FlxButton(0, 0);
	public var buttonX:FlxButton = new FlxButton(0, 0);
	public var buttonY:FlxButton = new FlxButton(0, 0);
	public var buttonZ:FlxButton = new FlxButton(0, 0);
	public var buttonP:FlxButton = new FlxButton(0, 0);

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

		switch (DPad)
		{
			case UP_DOWN:
				add(buttonUp = createButton(0, FlxG.height - 255, 132, 127, 'up', 0xFF00FF00));
				add(buttonDown = createButton(0, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
			case LEFT_RIGHT:
				add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(127, FlxG.height - 135, 132, 127, 'right', 0xFFFF0000));
			case UP_LEFT_RIGHT:
				add(buttonUp = createButton(105, FlxG.height - 243, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft = createButton(0, FlxG.height - 135, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(207, FlxG.height - 135, 132, 127, 'right', 0xFFFF0000));
			case LEFT_FULL:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
			case RIGHT_FULL:
				add(buttonUp = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF));
			case BOTH_FULL:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
				add(buttonUp2 = createButton(FlxG.width - 258, FlxG.height - 408, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft2 = createButton(FlxG.width - 384, FlxG.height - 309, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight2 = createButton(FlxG.width - 132, FlxG.height - 309, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown2 = createButton(FlxG.width - 258, FlxG.height - 201, 132, 127, 'down', 0xFF00FFFF));
			case DIALOGUE_PORTRAIT_EDITOR:
				add(buttonUp = createButton(105, FlxG.height - 345, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft = createButton(0, FlxG.height - 243, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(207, FlxG.height - 243, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown = createButton(105, FlxG.height - 135, 132, 127, 'down', 0xFF00FFFF));
				add(buttonUp2 = createButton(105, 0, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft2 = createButton(0, 82, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight2 = createButton(207, 82, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown2 = createButton(105, 190, 132, 127, 'down', 0xFF00FFFF));
			case MENU_CHARACTER:
				add(buttonUp = createButton(105, 0, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft = createButton(0, 82, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(207, 82, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown = createButton(105, 190, 132, 127, 'down', 0xFF00FFFF));
			case NOTE_SPLASH_DEBUG:
				add(buttonLeft = createButton(0, 0, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight = createButton(127, 0, 132, 127, 'right', 0xFFFF0000));
				add(buttonUp = createButton(0, 125, 132, 127, 'up', 0xFF00FF00));
				add(buttonDown = createButton(127, 125, 132, 127, 'down', 0xFF00FFFF));
				add(buttonUp2 = createButton(127, 393, 132, 127, 'up', 0xFF00FF00));
				add(buttonLeft2 = createButton(0, 393, 132, 127, 'left', 0xFFFF00FF));
				add(buttonRight2 = createButton(1145, 393, 132, 127, 'right', 0xFFFF0000));
				add(buttonDown2 = createButton(1015, 393, 132, 127, 'down', 0xFF00FFFF));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case B:
				add(buttonB = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
			case A_B:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_E:
				add(buttonE = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'e', 0xFF7D00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_X_Y:
				add(buttonX = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C_X_Y:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonX = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C_X_Y_Z:
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case A_B_C_D_V_X_Y_Z:
				add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 132, 127, 'v', 0x49A9B2));
				add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 132, 127, 'd', 0x0078FF));
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
			case DIALOGUE_PORTRAIT_EDITOR:
				add(buttonX = createButton(FlxG.width - 384, 0, 132, 127, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, 125, 132, 127, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, 0, 132, 127, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, 125, 132, 127, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, 0, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, 125, 132, 127, 'a', 0xFF0000));
			case MENU_CHARACTER:
				add(buttonC = createButton(FlxG.width - 384, 0, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, 0, 132, 127, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, 0, 132, 127, 'a', 0xFF0000));
			case NOTE_SPLASH_DEBUG:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
				add(buttonE = createButton(FlxG.width - 132, 0, 132, 127, 'e', 0xFF7D00));
				add(buttonX = createButton(FlxG.width - 258, 0, 132, 127, 'x', 0x99062D));
				add(buttonY = createButton(FlxG.width - 132, 250, 132, 127, 'y', 0x4A35B9));
				add(buttonZ = createButton(FlxG.width - 258, 250, 132, 127, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'a', 0xFF0000));
				add(buttonC = createButton(FlxG.width - 132, 125, 132, 127, 'c', 0x44FF00));
				add(buttonV = createButton(FlxG.width - 258, 125, 132, 127, 'v', 0x49A9B2));
			case P:
				add(buttonP = createButton(FlxG.width - 132, 0, 132, 127, 'x', 0x99062D));
			case B_C:
				add(buttonC = createButton(FlxG.width - 258, FlxG.height - 135, 132, 127, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 132, FlxG.height - 135, 132, 127, 'b', 0xFFCB00));
			case NONE: // do nothing
		}
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();

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
		buttonP = null;
	}

	private function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, ?Color:Int = 0xFFFFFF):FlxButton
	{
		var button:FlxButton = new FlxButton(X, Y);
		button.frames = FlxTileFrames.fromFrame(FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/mobile/virtualpad.png'),
			Assets.getText('assets/mobile/virtualpad.xml'))
			.getByName(Graphic),
			FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.moves = false;
		button.scrollFactor.set();
		button.color = Color;
		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end
		return button;
	}
		/*
		* Checks if the virtualpad button is pressed, if yes returns true.
		*/
	public function mobileControlsPressed(buttonID:FlxMobileControlsID):Bool
		{
			switch (buttonID)
			{
				case FlxMobileControlsID.LEFT:
					return buttonLeft.pressed;
				case FlxMobileControlsID.UP:
					return buttonUp.pressed;
				case FlxMobileControlsID.RIGHT:
					return buttonRight.pressed;
				case FlxMobileControlsID.DOWN:
					return buttonDown.pressed;
				case FlxMobileControlsID.LEFT2:
					return buttonLeft2.pressed;
				case FlxMobileControlsID.UP2:
					return buttonUp2.pressed;
				case FlxMobileControlsID.RIGHT2:
					return buttonRight2.pressed;
				case FlxMobileControlsID.DOWN2:
					return buttonDown2.pressed;
				case FlxMobileControlsID.A:
					return buttonA.pressed;
				case FlxMobileControlsID.B:
					return buttonB.pressed;
				case FlxMobileControlsID.C:
					return buttonC.pressed;
				case FlxMobileControlsID.D:
					return buttonD.pressed;
				case FlxMobileControlsID.E:
					return buttonE.pressed;
				case FlxMobileControlsID.V:
					return buttonV.pressed;
				case FlxMobileControlsID.X:
					return buttonX.pressed;
				case FlxMobileControlsID.Y:
					return buttonY.pressed;
				case FlxMobileControlsID.Z:
					return buttonZ.pressed;
				case FlxMobileControlsID.NONE:
					return false;
				default:
					return false;
			}
		}

		/*
		* Checks if the virtualpad button justPressed, if yes returns true.
		*/
		public function mobileControlsJustPressed(buttonID:FlxMobileControlsID):Bool
			{
				switch (buttonID)
				{
				case FlxMobileControlsID.LEFT:
					return buttonLeft.justPressed;
				case FlxMobileControlsID.UP:
					return buttonUp.justPressed;
				case FlxMobileControlsID.RIGHT:
					return buttonRight.justPressed;
				case FlxMobileControlsID.DOWN:
					return buttonDown.justPressed;
				case FlxMobileControlsID.LEFT2:
					return buttonLeft2.justPressed;
				case FlxMobileControlsID.UP2:
					return buttonUp2.justPressed;
				case FlxMobileControlsID.RIGHT2:
					return buttonRight2.justPressed;
				case FlxMobileControlsID.DOWN2:
					return buttonDown2.justPressed;
				case FlxMobileControlsID.A:
					return buttonA.justPressed;
				case FlxMobileControlsID.B:
					return buttonB.justPressed;
				case FlxMobileControlsID.C:
					return buttonC.justPressed;
				case FlxMobileControlsID.D:
					return buttonD.justPressed;
				case FlxMobileControlsID.E:
					return buttonE.justPressed;
				case FlxMobileControlsID.V:
					return buttonV.justPressed;
				case FlxMobileControlsID.X:
					return buttonX.justPressed;
				case FlxMobileControlsID.Y:
					return buttonY.justPressed;
				case FlxMobileControlsID.Z:
					return buttonZ.justPressed;
				case FlxMobileControlsID.NONE:
					return false;
				default:
					return false;
				}
			}

		/*
		* Checks if the virtualpad button is justReleased, if yes returns true.
		*/
	public function mobileControlsJustReleased(buttonID:FlxMobileControlsID):Bool
		{
			switch (buttonID)
			{
				case FlxMobileControlsID.LEFT:
					return buttonLeft.justReleased;
				case FlxMobileControlsID.UP:
					return buttonUp.justReleased;
				case FlxMobileControlsID.RIGHT:
					return buttonRight.justReleased;
				case FlxMobileControlsID.DOWN:
					return buttonDown.justReleased;
				case FlxMobileControlsID.LEFT2:
					return buttonLeft2.justReleased;
				case FlxMobileControlsID.UP2:
					return buttonUp2.justReleased;
				case FlxMobileControlsID.RIGHT2:
					return buttonRight2.justReleased;
				case FlxMobileControlsID.DOWN2:
					return buttonDown2.justReleased;
				case FlxMobileControlsID.A:
					return buttonA.justReleased;
				case FlxMobileControlsID.B:
					return buttonB.justReleased;
				case FlxMobileControlsID.C:
					return buttonC.justReleased;
				case FlxMobileControlsID.D:
					return buttonD.justReleased;
				case FlxMobileControlsID.E:
					return buttonE.justReleased;
				case FlxMobileControlsID.V:
					return buttonV.justReleased;
				case FlxMobileControlsID.X:
					return buttonX.justReleased;
				case FlxMobileControlsID.Y:
					return buttonY.justReleased;
				case FlxMobileControlsID.Z:
					return buttonZ.justReleased;
				case FlxMobileControlsID.NONE:
					return false;
				default:
					return false;
					}
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
	DIALOGUE_PORTRAIT_EDITOR;
	MENU_CHARACTER;
	NOTE_SPLASH_DEBUG;
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
	DIALOGUE_PORTRAIT_EDITOR;
	MENU_CHARACTER;
	NOTE_SPLASH_DEBUG;
	P;
	B_C;
	NONE;
}
