package backend;
#if mobileC
import mobile.flixel.FlxMobileControlsID;
import mobile.flixel.FlxButton;
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import backend.MusicBeatSubstate;
import mobile.MobileControls;
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
	public var mobileBinds:Map<String, Array<FlxMobileControlsID>>;
	#end
	public function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true #if mobileC || mobileCJustPressed(mobileBinds[key]) == true || virtualPadJustPressed(mobileBinds[key]) == true #end;
	}

	public function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadPressed(gamepadBinds[key]) == true #if mobileC || mobileCPressed(mobileBinds[key]) == true || virtualPadPressed(mobileBinds[key]) == true  #end;
	}

	public function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true #if mobileC || mobileCJustReleased(mobileBinds[key]) == true || virtualPadJustReleased(mobileBinds[key]) == true #end;
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
	public var isInSubstate:Bool = false; //just make this true when adding virtualPad into a substate and false while exiting/destroying the VirtualPad
	private function virtualPadPressed(keys:Array<FlxMobileControlsID>):Bool
		{
			// configure the virtualpad input in classes that extends MusicBeatState
			if(keys != null && MusicBeatState.instance.virtualPad != null && !isInSubstate)
			{
				for (key in keys)
				{
					if (MusicBeatState.instance.virtualPad.mobileControlsPressed(key) == true)
					{
						controllerMode = true; //!!DO NOT DISABLE THIS IF YOU DONT WANT TO KILL THE INPUT FOR MOBILE!!
						return true;
					}
				}
			}
			// configure the virtualpad input in classes that extends MusicBeatSubState
			if(keys != null && MusicBeatSubstate.virtualPad != null && isInSubstate)
				{
					for (key in keys)
					{
						if (MusicBeatSubstate.virtualPad.mobileControlsPressed(key) == true)
						{
							controllerMode = true;
							return true;
						}
					}
				}
			return false;
		}

		private function virtualPadJustPressed(keys:Array<FlxMobileControlsID>):Bool
			{
				if(keys != null && MusicBeatState.instance.virtualPad != null && !isInSubstate)
				{
					for (key in keys)
					{
						if (MusicBeatState.instance.virtualPad.mobileControlsJustPressed(key) == true)
						{
							controllerMode = true;
							return true;
						}
					}
				}

				if(keys != null && MusicBeatSubstate.virtualPad != null && isInSubstate)
					{
						for (key in keys)
						{
							if (MusicBeatSubstate.virtualPad.mobileControlsJustPressed(key) == true)
							{
								controllerMode = true;
								return true;
							}
						}
					}
				return false;
			}

			private function virtualPadJustReleased(keys:Array<FlxMobileControlsID>):Bool
				{
					if(keys != null && MusicBeatState.instance.virtualPad != null && !isInSubstate)
					{
						for (key in keys)
						{
							if (MusicBeatState.instance.virtualPad.mobileControlsJustReleased(key) == true)
							{
								controllerMode = true;
								return true;
							}
						}
					}
					if(keys != null && MusicBeatSubstate.virtualPad != null && isInSubstate)
						{
							for (key in keys)
							{
								if (MusicBeatSubstate.virtualPad.mobileControlsJustReleased(key) == true)
								{
									controllerMode = true;
									return true;
								}
							}
						}
					return false;
				}
				//these functions are used for playstate controls, just ignore them
				private function mobileCPressed(keys:Array<FlxMobileControlsID>):Bool {
					if (!isInSubstate){
				if(keys != null && MusicBeatState.instance.mobileControls != null){
					switch (MobileControls.getMode())
				{
					case 0 | 1 | 2 | 3: // RIGHT_FULL, LEFT_FULL, CUSTOM and BOTH
					for (key in keys) {
						if (MusicBeatState.instance.mobileControls.virtualPad.mobileControlsPressed(key) == true)
								{
									controllerMode = true;
									return true;
								}
							}
					case 4: // HITBOX
					for (key in keys)
								{
									if (MusicBeatState.instance.mobileControls.hitbox.mobileControlsPressed(key) == true)
									{
										controllerMode = true;
										return true;
									}
								}
					case 5: // KEYBOARD
					return false;
				}
			}
		}
		if (isInSubstate){
			if(keys != null && MusicBeatSubstate.mobileControls != null){
				switch (MobileControls.getMode())
			{
				case 0 | 1 | 2 | 3: // RIGHT_FULL, LEFT_FULL, CUSTOM and BOTH
				for (key in keys) {
					if (MusicBeatSubstate.mobileControls.virtualPad.mobileControlsPressed(key) == true)
							{
								controllerMode = true;
								return true;
							}
						}
				case 4: // HITBOX
				for (key in keys)
							{
								if (MusicBeatSubstate.mobileControls.hitbox.mobileControlsPressed(key) == true)
								{
									controllerMode = true;
									return true;
								}
							}
				case 5: // KEYBOARD
				return false;
			}
		}
	}
		return false;
		}
				private function mobileCJustPressed(keys:Array<FlxMobileControlsID>):Bool {
				if (!isInSubstate){
				if(keys != null && MusicBeatState.instance.mobileControls != null){
					switch (MobileControls.getMode())
				{
					case 0 | 1 | 2 | 3: // RIGHT_FULL, LEFT_FULL, CUSTOM and BOTH
					for (key in keys)
							{
								if (MusicBeatState.instance.mobileControls.virtualPad.mobileControlsJustPressed(key) == true)
								{
									controllerMode = true;
									return true;
								}
							}
					case 4: // HITBOX
					for (key in keys)
									{
										if (MusicBeatState.instance.mobileControls.hitbox.mobileControlsJustPressed(key) == true)
										{
											controllerMode = true;
											return true;
										}
									}
					case 5: // KEYBOARD
					return false;
				}
			}
			}
			if (isInSubstate){
				if(keys != null && MusicBeatSubstate.mobileControls != null){
					switch (MobileControls.getMode())
				{
					case 0 | 1 | 2 | 3: // RIGHT_FULL, LEFT_FULL, CUSTOM and BOTH
					for (key in keys)
							{
								if (MusicBeatSubstate.mobileControls.virtualPad.mobileControlsJustPressed(key) == true)
								{
									controllerMode = true;
									return true;
								}
							}
					case 4: // HITBOX
					for (key in keys)
									{
										if (MusicBeatSubstate.mobileControls.hitbox.mobileControlsJustPressed(key) == true)
										{
											controllerMode = true;
											return true;
										}
									}
					case 5: // KEYBOARD
					return false;
					}
				}
			}
		return false;
		}
				private function mobileCJustReleased(keys:Array<FlxMobileControlsID>):Bool {
				if (!isInSubstate) {
				if(keys != null && MusicBeatState.instance.mobileControls != null){
					switch (MobileControls.getMode())
				{
					case 0 | 1 | 2 | 3: // RIGHT_FULL, LEFT_FULL, CUSTOM and BOTH
					for (key in keys)
							{
								if (MusicBeatState.instance.mobileControls.virtualPad.mobileControlsJustReleased(key) == true)
								{
									controllerMode = true;
									return true;
								}
							}
					case 4: // HITBOX
					for (key in keys)
									{
										if (MusicBeatState.instance.mobileControls.hitbox.mobileControlsJustReleased(key) == true)
										{
											controllerMode = true;
											return true;
										}
									}
					case 5: // KEYBOARD
					return false;
				}
			}
			}
			if (isInSubstate) {
				if(keys != null && MusicBeatSubstate.mobileControls != null){
					switch (MobileControls.getMode())
				{
					case 0 | 1 | 2 | 3: // RIGHT_FULL, LEFT_FULL, CUSTOM and BOTH
					for (key in keys)
							{
								if (MusicBeatSubstate.mobileControls.virtualPad.mobileControlsJustReleased(key) == true)
								{
									controllerMode = true;
									return true;
								}
							}
					case 4: // HITBOX
					for (key in keys)
									{
										if (MusicBeatSubstate.mobileControls.hitbox.mobileControlsJustReleased(key) == true)
										{
											controllerMode = true;
											return true;
										}
									}
					case 5: // KEYBOARD
					return false;
					}
				}
			}
		return false;
		}
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
