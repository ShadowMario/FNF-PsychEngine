package backend;
#if mobileC
import mobile.flixel.FlxVirtualPadButtonID;
import mobile.flixel.FlxButton;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import MusicBeatState; //because this class dosent extends anything ig
#end
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.keyboard.FlxKey;

class Controls
{
	//Keeping same use cases on stuff for it to be easier to understand/use
	//I'd have removed it but this makes it a lot less annoying to use in my opinion

	//You do NOT have to create these variables/getters for adding new keys,
	//but you will instead have to use:
	//   controls.justPressed("ui_up")   instead of   controls.UI_UP

	//Dumb but easily usable code, or Smart but complicated? Your choice.
	//Also idk how to use macros they're weird as fuck lol

	// Pressed buttons (directions)
	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	private function get_UI_UP_P() return justPressed('ui_up');
	private function get_UI_DOWN_P() return justPressed('ui_down');
	private function get_UI_LEFT_P() return justPressed('ui_left');
	private function get_UI_RIGHT_P() return justPressed('ui_right');
	private function get_NOTE_UP_P() return justPressed('note_up');
	private function get_NOTE_DOWN_P() return justPressed('note_down');
	private function get_NOTE_LEFT_P() return justPressed('note_left');
	private function get_NOTE_RIGHT_P() return justPressed('note_right');

	// Held buttons (directions)
	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;
	private function get_UI_UP() return pressed('ui_up');
	private function get_UI_DOWN() return pressed('ui_down');
	private function get_UI_LEFT() return pressed('ui_left');
	private function get_UI_RIGHT() return pressed('ui_right');
	private function get_NOTE_UP() return pressed('note_up');
	private function get_NOTE_DOWN() return pressed('note_down');
	private function get_NOTE_LEFT() return pressed('note_left');
	private function get_NOTE_RIGHT() return pressed('note_right');

	// Released buttons (directions)
	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;
	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;
	private function get_UI_UP_R() return justReleased('ui_up');
	private function get_UI_DOWN_R() return justReleased('ui_down');
	private function get_UI_LEFT_R() return justReleased('ui_left');
	private function get_UI_RIGHT_R() return justReleased('ui_right');
	private function get_NOTE_UP_R() return justReleased('note_up');
	private function get_NOTE_DOWN_R() return justReleased('note_down');
	private function get_NOTE_LEFT_R() return justReleased('note_left');
	private function get_NOTE_RIGHT_R() return justReleased('note_right');


	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	private function get_ACCEPT() return justPressed('accept');
	private function get_BACK() return justPressed('back');
	private function get_PAUSE() return justPressed('pause');
	private function get_RESET() return justPressed('reset');

	//Gamepad, Keyboard & mobile stuff
	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;
	#if mobileC
	public var mobileBinds:Map<String, Array<FlxVirtualPadButtonID>>;
	#end
	public function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true #if mobileC || dpadJustPressed(mobileBinds[key]) == true #end;
	}

	public function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadPressed(gamepadBinds[key]) == true #if mobileC || dpadPressed(mobileBinds[key]) == true #end;
	}

	public function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true #if mobileC || dpadJustReleased(mobileBinds[key]) == true #end;
	}

	public var controllerMode:Bool = false;
	private function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustReleased(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	#if mobileC
	private function dpadPressed(keys:Array<FlxVirtualPadButtonID>):Bool
		{
			if(keys != null && MusicBeatState.virtualPad != null)
			{
				for (key in keys)
				{
					if (MusicBeatState.instance.virtualPad.isButtonPressed(key) == true)
					{
						//controllerMode = true;
						return true;
					}
				}
			}
			return false;
		}

		private function dpadJustPressed(keys:Array<FlxVirtualPadButtonID>):Bool
			{
				if(keys != null && MusicBeatState.virtualPad != null)
				{
					for (key in keys)
					{
						if (MusicBeatState.instance.virtualPad.isButtonJustPressed(key) == true)
						{
							//controllerMode = true;
							return true;
						}
					}
				}
				return false;
			}

			private function dpadJustReleased(keys:Array<FlxVirtualPadButtonID>):Bool
				{
					if(keys != null && MusicBeatState.virtualPad != null)
					{
						for (key in keys)
						{
							if (MusicBeatState.instance.virtualPad.isButtonJustReleased(key) == true)
							{
								//controllerMode = true;
								return true;
							}
						}
					}
					return false;
				}

	/*public var trackedinputsUI:Array<FlxActionInput> = [];
	public var trackedinputsNOTES:Array<FlxActionInput> = [];

	public function addbuttonNOTES(action:FlxActionDigital, button:FlxButton, state:FlxInputState)
	{
		var input:FlxActionInputDigitalIFlxInput = new FlxActionInputDigitalIFlxInput(button, state);
		trackedinputsNOTES.push(input);
		action.add(input);
	}

	public function addbuttonUI(action:FlxActionDigital, button:FlxButton, state:FlxInputState)
	{
		var input:FlxActionInputDigitalIFlxInput = new FlxActionInputDigitalIFlxInput(button, state);
		trackedinputsUI.push(input);
		action.add(input);
	}
	

	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
		{
			switch (control)
			{
				case UI_UP:
					func(_ui_up, PRESSED);
					func(_ui_upP, JUST_PRESSED);
					func(_ui_upR, JUST_RELEASED);
				case UI_LEFT:
					func(_ui_left, PRESSED);
					func(_ui_leftP, JUST_PRESSED);
					func(_ui_leftR, JUST_RELEASED);
				case UI_RIGHT:
					func(_ui_right, PRESSED);
					func(_ui_rightP, JUST_PRESSED);
					func(_ui_rightR, JUST_RELEASED);
				case UI_DOWN:
					func(_ui_down, PRESSED);
					func(_ui_downP, JUST_PRESSED);
					func(_ui_downR, JUST_RELEASED);
				case NOTE_UP:
					func(_note_up, PRESSED);
					func(_note_upP, JUST_PRESSED);
					func(_note_upR, JUST_RELEASED);
				case NOTE_LEFT:
					func(_note_left, PRESSED);
					func(_note_leftP, JUST_PRESSED);
					func(_note_leftR, JUST_RELEASED);
				case NOTE_RIGHT:
					func(_note_right, PRESSED);
					func(_note_rightP, JUST_PRESSED);
					func(_note_rightR, JUST_RELEASED);
				case NOTE_DOWN:
					func(_note_down, PRESSED);
					func(_note_downP, JUST_PRESSED);
					func(_note_downR, JUST_RELEASED);
				case ACCEPT:
					func(_accept, JUST_PRESSED);
				case BACK:
					func(_back, JUST_PRESSED);
				case PAUSE:
					func(_pause, JUST_PRESSED);
				case RESET:
					func(_reset, JUST_PRESSED);
			}
		}

	public function setHitBox(Hitbox:FlxHitbox) 
	{
		inline forEachBound(Control.NOTE_UP, (action, state) -> addbuttonNOTES(action, Hitbox.buttonUp, state));
		inline forEachBound(Control.NOTE_DOWN, (action, state) -> addbuttonNOTES(action, Hitbox.buttonDown, state));
		inline forEachBound(Control.NOTE_LEFT, (action, state) -> addbuttonNOTES(action, Hitbox.buttonLeft, state));
		inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addbuttonNOTES(action, Hitbox.buttonRight, state));
	}

	public static function setVirtualPadUI(VirtualPad:FlxVirtualPad, DPad:FlxDPadMode, Action:FlxActionMode)
	{
		switch (DPad)
		{
			case UP_DOWN:
				inline forEachBound(Control.UI_UP, (action, state) -> addbuttonUI(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.UI_DOWN, (action, state) -> addbuttonUI(action, VirtualPad.buttonDown, state));
			case LEFT_RIGHT:
				inline forEachBound(Control.UI_LEFT, (action, state) -> addbuttonUI(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addbuttonUI(action, VirtualPad.buttonRight, state));
			case UP_LEFT_RIGHT:
				inline forEachBound(Control.UI_UP, (action, state) -> addbuttonUI(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.UI_LEFT, (action, state) -> addbuttonUI(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addbuttonUI(action, VirtualPad.buttonRight, state));
			case LEFT_FULL | RIGHT_FULL:
				inline forEachBound(Control.UI_UP, (action, state) -> addbuttonUI(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.UI_DOWN, (action, state) -> addbuttonUI(action, VirtualPad.buttonDown, state));
				inline forEachBound(Control.UI_LEFT, (action, state) -> addbuttonUI(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addbuttonUI(action, VirtualPad.buttonRight, state));
			case BOTH_FULL:
				inline forEachBound(Control.UI_UP, (action, state) -> addbuttonUI(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.UI_DOWN, (action, state) -> addbuttonUI(action, VirtualPad.buttonDown, state));
				inline forEachBound(Control.UI_LEFT, (action, state) -> addbuttonUI(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addbuttonUI(action, VirtualPad.buttonRight, state));
				inline forEachBound(Control.UI_UP, (action, state) -> addbuttonUI(action, VirtualPad.buttonUp2, state));
				inline forEachBound(Control.UI_DOWN, (action, state) -> addbuttonUI(action, VirtualPad.buttonDown2, state));
				inline forEachBound(Control.UI_LEFT, (action, state) -> addbuttonUI(action, VirtualPad.buttonLeft2, state));
				inline forEachBound(Control.UI_RIGHT, (action, state) -> addbuttonUI(action, VirtualPad.buttonRight2, state));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbuttonUI(action, VirtualPad.buttonA, state));
			case B:
				inline forEachBound(Control.BACK, (action, state) -> addbuttonUI(action, VirtualPad.buttonB, state));
			case A_B | A_B_C | A_B_E | A_B_X_Y | A_B_C_X_Y | A_B_C_X_Y_Z | A_B_C_D_V_X_Y_Z:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbuttonUI(action, VirtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> addbuttonUI(action, VirtualPad.buttonB, state));
			case NONE: // do nothing
		}
	}

	public static function setVirtualPadNOTES(VirtualPad:FlxVirtualPad, DPad:FlxDPadMode, Action:FlxActionMode) 
	{
		switch (DPad)
		{
			case UP_DOWN:
				inline forEachBound(Control.NOTE_UP, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.NOTE_DOWN, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonDown, state));
			case LEFT_RIGHT:
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonRight, state));
			case UP_LEFT_RIGHT:
				inline forEachBound(Control.NOTE_UP, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonRight, state));
			case LEFT_FULL | RIGHT_FULL:
				inline forEachBound(Control.NOTE_UP, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.NOTE_DOWN, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonDown, state));
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonRight, state));
			case BOTH_FULL:
				inline forEachBound(Control.NOTE_UP, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonUp, state));
				inline forEachBound(Control.NOTE_DOWN, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonDown, state));
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonLeft, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonRight, state));
				inline forEachBound(Control.NOTE_UP, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonUp2, state));
				inline forEachBound(Control.NOTE_DOWN, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonDown2, state));
				inline forEachBound(Control.NOTE_LEFT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonLeft2, state));
				inline forEachBound(Control.NOTE_RIGHT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonRight2, state));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonA, state));
			case B:
				inline forEachBound(Control.BACK, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonB, state));
			case A_B | A_B_C | A_B_E | A_B_X_Y | A_B_C_X_Y | A_B_C_X_Y_Z | A_B_C_D_V_X_Y_Z:
				inline forEachBound(Control.ACCEPT, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> addbuttonNOTES(action, VirtualPad.buttonB, state));
			case NONE: // do nothing
		}
	}

	public function removeFlxInput(Tinputs:Array<FlxActionInput>)
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var x = Tinputs.length;
				while (x-- > 0)
				{
					if (Tinputs[x] == action.inputs[i])
						action.remove(action.inputs[i]);
				}
			}
		}
	}*/
	#end

	// IGNORE THESE/ karim: no.
	public static var instance:Controls;
	public function new()
	{
		#if mobileC
		mobileBinds = ClientPrefs.mobileBinds;
		#end
		gamepadBinds = ClientPrefs.gamepadBinds;
		keyboardBinds = ClientPrefs.keyBinds;
	}
}
