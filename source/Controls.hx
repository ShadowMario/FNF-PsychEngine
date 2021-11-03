package;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

enum abstract Action(String) to String from String
{
	var UI_UP = "ui_up";
	var UI_LEFT = "ui_left";
	var UI_RIGHT = "ui_right";
	var UI_DOWN = "ui_down";
	var UI_UP_P = "ui_up-press";
	var UI_LEFT_P = "ui_left-press";
	var UI_RIGHT_P = "ui_right-press";
	var UI_DOWN_P = "ui_down-press";
	var UI_UP_R = "ui_up-release";
	var UI_LEFT_R = "ui_left-release";
	var UI_RIGHT_R = "ui_right-release";
	var UI_DOWN_R = "ui_down-release";
	var NOTE_UP = "note_up";
	var NOTE_LEFT = "note_left";
	var NOTE_RIGHT = "note_right";
	var NOTE_DOWN = "note_down";
	var NOTE_UP_P = "note_up-press";
	var NOTE_LEFT_P = "note_left-press";
	var NOTE_RIGHT_P = "note_right-press";
	var NOTE_DOWN_P = "note_down-press";
	var NOTE_UP_R = "note_up-release";
	var NOTE_LEFT_R = "note_left-release";
	var NOTE_RIGHT_R = "note_right-release";
	var NOTE_DOWN_R = "note_down-release";

	var NOTE_CENTER_5k = "NOTE_CENTER_5k";
	var NOTE_CENTER_5k_P = "NOTE_CENTER_5k-press";
	var NOTE_CENTER_5k_R = "NOTE_CENTER_5k-release";
	var NOTE_1_6k = "NOTE_1_6k";
	var NOTE_1_6k_P = "NOTE_1_6k-press";
	var NOTE_1_6k_R = "NOTE_1_6k-release";
	var NOTE_2_6k = "NOTE_2_6k";
	var NOTE_2_6k_P = "NOTE_2_6k-press";
	var NOTE_2_6k_R = "NOTE_2_6k-release";
	var NOTE_3_6k = "NOTE_3_6k";
	var NOTE_3_6k_P = "NOTE_3_6k-press";
	var NOTE_3_6k_R = "NOTE_3_6k-release";
	var NOTE_CENTER_7k = "NOTE_CENTER_7k";
	var NOTE_CENTER_7k_P = "NOTE_CENTER_7k-press";
	var NOTE_CENTER_7k_R = "NOTE_CENTER_7k-release";
	var NOTE_4_6k = "NOTE_4_6k";
	var NOTE_4_6k_P = "NOTE_4_6k-press";
	var NOTE_4_6k_R = "NOTE_4_6k-release";
	var NOTE_5_6k = "NOTE_5_6k";
	var NOTE_5_6k_P = "NOTE_5_6k-press";
	var NOTE_5_6k_R = "NOTE_5_6k-release";
	var NOTE_6_6k = "NOTE_6_6k";
	var NOTE_6_6k_P = "NOTE_6_6k-press";
	var NOTE_6_6k_R = "NOTE_6_6k-release";
	var NOTE_1_8k = "NOTE_1_8k";
	var NOTE_1_8k_P = "NOTE_1_8k-press";
	var NOTE_1_8k_R = "NOTE_1_8k-release";
	var NOTE_2_8k = "NOTE_2_8k";
	var NOTE_2_8k_P = "NOTE_2_8k-press";
	var NOTE_2_8k_R = "NOTE_2_8k-release";
	var NOTE_3_8k = "NOTE_3_8k";
	var NOTE_3_8k_P = "NOTE_3_8k-press";
	var NOTE_3_8k_R = "NOTE_3_8k-release";
	var NOTE_4_8k = "NOTE_4_8k";
	var NOTE_4_8k_P = "NOTE_4_8k-press";
	var NOTE_4_8k_R = "NOTE_4_8k-release";
	var NOTE_CENTER_9k = "NOTE_CENTER_9k";
	var NOTE_CENTER_9k_P = "NOTE_CENTER_9k-press";
	var NOTE_CENTER_9k_R = "NOTE_CENTER_9k-release";
	var NOTE_5_8k = "NOTE_5_8k";
	var NOTE_5_8k_P = "NOTE_5_8k-press";
	var NOTE_5_8k_R = "NOTE_5_8k-release";
	var NOTE_6_8k = "NOTE_6_8k";
	var NOTE_6_8k_P = "NOTE_6_8k-press";
	var NOTE_6_8k_R = "NOTE_6_8k-release";
	var NOTE_7_8k = "NOTE_7_8k";
	var NOTE_7_8k_P = "NOTE_7_8k-press";
	var NOTE_7_8k_R = "NOTE_7_8k-release";
	var NOTE_8_8k = "NOTE_8_8k";
	var NOTE_8_8k_P = "NOTE_8_8k-press";
	var NOTE_8_8k_R = "NOTE_8_8k-release";

	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
}

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	UI_UP;
	UI_LEFT;
	UI_RIGHT;
	UI_DOWN;

	NOTE_UP;
	NOTE_LEFT;
	NOTE_CENTER_5k; // SPACE
	NOTE_RIGHT;
	NOTE_DOWN;

	NOTE_1_6k; // S
	NOTE_2_6k; // D
	NOTE_3_6k; // F
	NOTE_CENTER_7k; // SPACE
	NOTE_4_6k; // H
	NOTE_5_6k; // J
	NOTE_6_6k; // K

	NOTE_1_8k; // A
	NOTE_2_8k; // S
	NOTE_3_8k; // D
	NOTE_4_8k; // F
	NOTE_CENTER_9k; // SPACE
	NOTE_5_8k; // H
	NOTE_6_8k; // J
	NOTE_7_8k; // K
	NOTE_8_8k; // L

	RESET;
	ACCEPT;
	BACK;
	PAUSE;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _ui_up = new FlxActionDigital(Action.UI_UP);
	var _ui_left = new FlxActionDigital(Action.UI_LEFT);
	var _ui_right = new FlxActionDigital(Action.UI_RIGHT);
	var _ui_down = new FlxActionDigital(Action.UI_DOWN);
	var _ui_upP = new FlxActionDigital(Action.UI_UP_P);
	var _ui_leftP = new FlxActionDigital(Action.UI_LEFT_P);
	var _ui_rightP = new FlxActionDigital(Action.UI_RIGHT_P);
	var _ui_downP = new FlxActionDigital(Action.UI_DOWN_P);
	var _ui_upR = new FlxActionDigital(Action.UI_UP_R);
	var _ui_leftR = new FlxActionDigital(Action.UI_LEFT_R);
	var _ui_rightR = new FlxActionDigital(Action.UI_RIGHT_R);
	var _ui_downR = new FlxActionDigital(Action.UI_DOWN_R);
	var _note_up = new FlxActionDigital(Action.NOTE_UP);
	var _note_left = new FlxActionDigital(Action.NOTE_LEFT);
	var _note_right = new FlxActionDigital(Action.NOTE_RIGHT);
	var _note_down = new FlxActionDigital(Action.NOTE_DOWN);
	var _note_upP = new FlxActionDigital(Action.NOTE_UP_P);
	var _note_leftP = new FlxActionDigital(Action.NOTE_LEFT_P);
	var _note_rightP = new FlxActionDigital(Action.NOTE_RIGHT_P);
	var _note_downP = new FlxActionDigital(Action.NOTE_DOWN_P);
	var _note_upR = new FlxActionDigital(Action.NOTE_UP_R);
	var _note_leftR = new FlxActionDigital(Action.NOTE_LEFT_R);
	var _note_rightR = new FlxActionDigital(Action.NOTE_RIGHT_R);
	var _note_downR = new FlxActionDigital(Action.NOTE_DOWN_R);
	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);

	var _NOTE_CENTER_5k = new FlxActionDigital(Action.NOTE_CENTER_5k);
	var _NOTE_CENTER_5k_P = new FlxActionDigital(Action.NOTE_CENTER_5k_P);
	var _NOTE_CENTER_5k_R = new FlxActionDigital(Action.NOTE_CENTER_5k_R);
	var _NOTE_1_6k = new FlxActionDigital(Action.NOTE_1_6k);
	var _NOTE_1_6k_P = new FlxActionDigital(Action.NOTE_1_6k_P);
	var _NOTE_1_6k_R = new FlxActionDigital(Action.NOTE_1_6k_R);
	var _NOTE_2_6k = new FlxActionDigital(Action.NOTE_2_6k);
	var _NOTE_2_6k_P = new FlxActionDigital(Action.NOTE_2_6k_P);
	var _NOTE_2_6k_R = new FlxActionDigital(Action.NOTE_2_6k_R);
	var _NOTE_3_6k = new FlxActionDigital(Action.NOTE_3_6k);
	var _NOTE_3_6k_P = new FlxActionDigital(Action.NOTE_3_6k_P);
	var _NOTE_3_6k_R = new FlxActionDigital(Action.NOTE_3_6k_R);
	var _NOTE_CENTER_7k = new FlxActionDigital(Action.NOTE_CENTER_7k);
	var _NOTE_CENTER_7k_P = new FlxActionDigital(Action.NOTE_CENTER_7k_P);
	var _NOTE_CENTER_7k_R = new FlxActionDigital(Action.NOTE_CENTER_7k_R);
	var _NOTE_4_6k = new FlxActionDigital(Action.NOTE_4_6k);
	var _NOTE_4_6k_P = new FlxActionDigital(Action.NOTE_4_6k_P);
	var _NOTE_4_6k_R = new FlxActionDigital(Action.NOTE_4_6k_R);
	var _NOTE_5_6k = new FlxActionDigital(Action.NOTE_5_6k);
	var _NOTE_5_6k_P = new FlxActionDigital(Action.NOTE_5_6k_P);
	var _NOTE_5_6k_R = new FlxActionDigital(Action.NOTE_5_6k_R);
	var _NOTE_6_6k = new FlxActionDigital(Action.NOTE_6_6k);
	var _NOTE_6_6k_P = new FlxActionDigital(Action.NOTE_6_6k_P);
	var _NOTE_6_6k_R = new FlxActionDigital(Action.NOTE_6_6k_R);
	var _NOTE_1_8k = new FlxActionDigital(Action.NOTE_1_8k);
	var _NOTE_1_8k_P = new FlxActionDigital(Action.NOTE_1_8k_P);
	var _NOTE_1_8k_R = new FlxActionDigital(Action.NOTE_1_8k_R);
	var _NOTE_2_8k = new FlxActionDigital(Action.NOTE_2_8k);
	var _NOTE_2_8k_P = new FlxActionDigital(Action.NOTE_2_8k_P);
	var _NOTE_2_8k_R = new FlxActionDigital(Action.NOTE_2_8k_R);
	var _NOTE_3_8k = new FlxActionDigital(Action.NOTE_3_8k);
	var _NOTE_3_8k_P = new FlxActionDigital(Action.NOTE_3_8k_P);
	var _NOTE_3_8k_R = new FlxActionDigital(Action.NOTE_3_8k_R);
	var _NOTE_4_8k = new FlxActionDigital(Action.NOTE_4_8k);
	var _NOTE_4_8k_P = new FlxActionDigital(Action.NOTE_4_8k_P);
	var _NOTE_4_8k_R = new FlxActionDigital(Action.NOTE_4_8k_R);
	var _NOTE_CENTER_9k = new FlxActionDigital(Action.NOTE_CENTER_9k);
	var _NOTE_CENTER_9k_P = new FlxActionDigital(Action.NOTE_CENTER_9k_P);
	var _NOTE_CENTER_9k_R = new FlxActionDigital(Action.NOTE_CENTER_9k_R);
	var _NOTE_5_8k = new FlxActionDigital(Action.NOTE_5_8k);
	var _NOTE_5_8k_P = new FlxActionDigital(Action.NOTE_5_8k_P);
	var _NOTE_5_8k_R = new FlxActionDigital(Action.NOTE_5_8k_R);
	var _NOTE_6_8k = new FlxActionDigital(Action.NOTE_6_8k);
	var _NOTE_6_8k_P = new FlxActionDigital(Action.NOTE_6_8k_P);
	var _NOTE_6_8k_R = new FlxActionDigital(Action.NOTE_6_8k_R);
	var _NOTE_7_8k = new FlxActionDigital(Action.NOTE_7_8k);
	var _NOTE_7_8k_P = new FlxActionDigital(Action.NOTE_7_8k_P);
	var _NOTE_7_8k_R = new FlxActionDigital(Action.NOTE_7_8k_R);
	var _NOTE_8_8k = new FlxActionDigital(Action.NOTE_8_8k);
	var _NOTE_8_8k_P = new FlxActionDigital(Action.NOTE_8_8k_P);
	var _NOTE_8_8k_R = new FlxActionDigital(Action.NOTE_8_8k_R);


	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public var UI_UP(get, never):Bool;

	inline function get_UI_UP()
		return _ui_up.check();

	public var UI_LEFT(get, never):Bool;

	inline function get_UI_LEFT()
		return _ui_left.check();

	public var UI_RIGHT(get, never):Bool;

	inline function get_UI_RIGHT()
		return _ui_right.check();

	public var UI_DOWN(get, never):Bool;

	inline function get_UI_DOWN()
		return _ui_down.check();

	public var UI_UP_P(get, never):Bool;

	inline function get_UI_UP_P()
		return _ui_upP.check();

	public var UI_LEFT_P(get, never):Bool;

	inline function get_UI_LEFT_P()
		return _ui_leftP.check();

	public var UI_RIGHT_P(get, never):Bool;

	inline function get_UI_RIGHT_P()
		return _ui_rightP.check();

	public var UI_DOWN_P(get, never):Bool;

	inline function get_UI_DOWN_P()
		return _ui_downP.check();

	public var UI_UP_R(get, never):Bool;

	inline function get_UI_UP_R()
		return _ui_upR.check();

	public var UI_LEFT_R(get, never):Bool;

	inline function get_UI_LEFT_R()
		return _ui_leftR.check();

	public var UI_RIGHT_R(get, never):Bool;

	inline function get_UI_RIGHT_R()
		return _ui_rightR.check();

	public var UI_DOWN_R(get, never):Bool;

	inline function get_UI_DOWN_R()
		return _ui_downR.check();

	public var NOTE_UP(get, never):Bool;

	inline function get_NOTE_UP()
		return _note_up.check();

	public var NOTE_LEFT(get, never):Bool;

	inline function get_NOTE_LEFT()
		return _note_left.check();

	public var NOTE_RIGHT(get, never):Bool;

	inline function get_NOTE_RIGHT()
		return _note_right.check();

	public var NOTE_DOWN(get, never):Bool;

	inline function get_NOTE_DOWN()
		return _note_down.check();

	public var NOTE_UP_P(get, never):Bool;

	inline function get_NOTE_UP_P()
		return _note_upP.check();

	public var NOTE_LEFT_P(get, never):Bool;

	inline function get_NOTE_LEFT_P()
		return _note_leftP.check();

	public var NOTE_RIGHT_P(get, never):Bool;

	inline function get_NOTE_RIGHT_P()
		return _note_rightP.check();

	public var NOTE_DOWN_P(get, never):Bool;

	inline function get_NOTE_DOWN_P()
		return _note_downP.check();

	public var NOTE_UP_R(get, never):Bool;

	inline function get_NOTE_UP_R()
		return _note_upR.check();

	public var NOTE_LEFT_R(get, never):Bool;

	inline function get_NOTE_LEFT_R()
		return _note_leftR.check();

	public var NOTE_RIGHT_R(get, never):Bool;

	inline function get_NOTE_RIGHT_R()
		return _note_rightR.check();

	public var NOTE_DOWN_R(get, never):Bool;

	inline function get_NOTE_DOWN_R()
		return _note_downR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var NOTE_CENTER_5k(get, never):Bool;
	inline function get_NOTE_CENTER_5k()
		return _NOTE_CENTER_5k.check();

	public var NOTE_CENTER_5k_P(get, never):Bool;
	inline function get_NOTE_CENTER_5k_P()
		return _NOTE_CENTER_5k_P.check();

	public var NOTE_CENTER_5k_R(get, never):Bool;
	inline function get_NOTE_CENTER_5k_R()
		return _NOTE_CENTER_5k_R.check();

	public var NOTE_1_6k(get, never):Bool;
	inline function get_NOTE_1_6k()
		return _NOTE_1_6k.check();

	public var NOTE_1_6k_P(get, never):Bool;
	inline function get_NOTE_1_6k_P()
		return _NOTE_1_6k_P.check();

	public var NOTE_1_6k_R(get, never):Bool;
	inline function get_NOTE_1_6k_R()
		return _NOTE_1_6k_R.check();

	public var NOTE_2_6k(get, never):Bool;
	inline function get_NOTE_2_6k()
		return _NOTE_2_6k.check();

	public var NOTE_2_6k_P(get, never):Bool;
	inline function get_NOTE_2_6k_P()
		return _NOTE_2_6k_P.check();

	public var NOTE_2_6k_R(get, never):Bool;
	inline function get_NOTE_2_6k_R()
		return _NOTE_2_6k_R.check();

	public var NOTE_3_6k(get, never):Bool;
	inline function get_NOTE_3_6k()
		return _NOTE_3_6k.check();

	public var NOTE_3_6k_P(get, never):Bool;
	inline function get_NOTE_3_6k_P()
		return _NOTE_3_6k_P.check();

	public var NOTE_3_6k_R(get, never):Bool;
	inline function get_NOTE_3_6k_R()
		return _NOTE_3_6k_R.check();

	public var NOTE_CENTER_7k(get, never):Bool;
	inline function get_NOTE_CENTER_7k()
		return _NOTE_CENTER_7k.check();

	public var NOTE_CENTER_7k_P(get, never):Bool;
	inline function get_NOTE_CENTER_7k_P()
		return _NOTE_CENTER_7k_P.check();

	public var NOTE_CENTER_7k_R(get, never):Bool;
	inline function get_NOTE_CENTER_7k_R()
		return _NOTE_CENTER_7k_R.check();

	public var NOTE_4_6k(get, never):Bool;
	inline function get_NOTE_4_6k()
		return _NOTE_4_6k.check();

	public var NOTE_4_6k_P(get, never):Bool;
	inline function get_NOTE_4_6k_P()
		return _NOTE_4_6k_P.check();

	public var NOTE_4_6k_R(get, never):Bool;
	inline function get_NOTE_4_6k_R()
		return _NOTE_4_6k_R.check();

	public var NOTE_5_6k(get, never):Bool;
	inline function get_NOTE_5_6k()
		return _NOTE_5_6k.check();

	public var NOTE_5_6k_P(get, never):Bool;
	inline function get_NOTE_5_6k_P()
		return _NOTE_5_6k_P.check();

	public var NOTE_5_6k_R(get, never):Bool;
	inline function get_NOTE_5_6k_R()
		return _NOTE_5_6k_R.check();

	public var NOTE_6_6k(get, never):Bool;
	inline function get_NOTE_6_6k()
		return _NOTE_6_6k.check();

	public var NOTE_6_6k_P(get, never):Bool;
	inline function get_NOTE_6_6k_P()
		return _NOTE_6_6k_P.check();

	public var NOTE_6_6k_R(get, never):Bool;
	inline function get_NOTE_6_6k_R()
		return _NOTE_6_6k_R.check();

	public var NOTE_1_8k(get, never):Bool;
	inline function get_NOTE_1_8k()
		return _NOTE_1_8k.check();

	public var NOTE_1_8k_P(get, never):Bool;
	inline function get_NOTE_1_8k_P()
		return _NOTE_1_8k_P.check();

	public var NOTE_1_8k_R(get, never):Bool;
	inline function get_NOTE_1_8k_R()
		return _NOTE_1_8k_R.check();

	public var NOTE_2_8k(get, never):Bool;
	inline function get_NOTE_2_8k()
		return _NOTE_2_8k.check();

	public var NOTE_2_8k_P(get, never):Bool;
	inline function get_NOTE_2_8k_P()
		return _NOTE_2_8k_P.check();

	public var NOTE_2_8k_R(get, never):Bool;
	inline function get_NOTE_2_8k_R()
		return _NOTE_2_8k_R.check();

	public var NOTE_3_8k(get, never):Bool;
	inline function get_NOTE_3_8k()
		return _NOTE_3_8k.check();

	public var NOTE_3_8k_P(get, never):Bool;
	inline function get_NOTE_3_8k_P()
		return _NOTE_3_8k_P.check();

	public var NOTE_3_8k_R(get, never):Bool;
	inline function get_NOTE_3_8k_R()
		return _NOTE_3_8k_R.check();

	public var NOTE_4_8k(get, never):Bool;
	inline function get_NOTE_4_8k()
		return _NOTE_4_8k.check();

	public var NOTE_4_8k_P(get, never):Bool;
	inline function get_NOTE_4_8k_P()
		return _NOTE_4_8k_P.check();

	public var NOTE_4_8k_R(get, never):Bool;
	inline function get_NOTE_4_8k_R()
		return _NOTE_4_8k_R.check();

	public var NOTE_CENTER_9k(get, never):Bool;
	inline function get_NOTE_CENTER_9k()
		return _NOTE_CENTER_9k.check();

	public var NOTE_CENTER_9k_P(get, never):Bool;
	inline function get_NOTE_CENTER_9k_P()
		return _NOTE_CENTER_9k_P.check();

	public var NOTE_CENTER_9k_R(get, never):Bool;
	inline function get_NOTE_CENTER_9k_R()
		return _NOTE_CENTER_9k_R.check();

	public var NOTE_5_8k(get, never):Bool;
	inline function get_NOTE_5_8k()
		return _NOTE_5_8k.check();

	public var NOTE_5_8k_P(get, never):Bool;
	inline function get_NOTE_5_8k_P()
		return _NOTE_5_8k_P.check();

	public var NOTE_5_8k_R(get, never):Bool;
	inline function get_NOTE_5_8k_R()
		return _NOTE_5_8k_R.check();

	public var NOTE_6_8k(get, never):Bool;
	inline function get_NOTE_6_8k()
		return _NOTE_6_8k.check();

	public var NOTE_6_8k_P(get, never):Bool;
	inline function get_NOTE_6_8k_P()
		return _NOTE_6_8k_P.check();

	public var NOTE_6_8k_R(get, never):Bool;
	inline function get_NOTE_6_8k_R()
		return _NOTE_6_8k_R.check();

	public var NOTE_7_8k(get, never):Bool;
	inline function get_NOTE_7_8k()
		return _NOTE_7_8k.check();

	public var NOTE_7_8k_P(get, never):Bool;
	inline function get_NOTE_7_8k_P()
		return _NOTE_7_8k_P.check();

	public var NOTE_7_8k_R(get, never):Bool;
	inline function get_NOTE_7_8k_R()
		return _NOTE_7_8k_R.check();

	public var NOTE_8_8k(get, never):Bool;
	inline function get_NOTE_8_8k()
		return _NOTE_8_8k.check();

	public var NOTE_8_8k_P(get, never):Bool;
	inline function get_NOTE_8_8k_P()
		return _NOTE_8_8k_P.check();

	public var NOTE_8_8k_R(get, never):Bool;
	inline function get_NOTE_8_8k_R()
		return _NOTE_8_8k_R.check();


	#if (haxe >= "4.0.0")
	public function new(name, scheme = None)
	{
		super(name);

		add(_ui_up);
		add(_ui_left);
		add(_ui_right);
		add(_ui_down);
		add(_ui_upP);
		add(_ui_leftP);
		add(_ui_rightP);
		add(_ui_downP);
		add(_ui_upR);
		add(_ui_leftR);
		add(_ui_rightR);
		add(_ui_downR);
		add(_note_up);
		add(_note_left);
		add(_note_right);
		add(_note_down);
		add(_note_upP);
		add(_note_leftP);
		add(_note_rightP);
		add(_note_downP);
		add(_note_upR);
		add(_note_leftR);
		add(_note_rightR);
		add(_note_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);

		add(_NOTE_CENTER_5k);
		add(_NOTE_CENTER_5k_P);
		add(_NOTE_CENTER_5k_R);
		add(_NOTE_1_6k);
		add(_NOTE_1_6k_P);
		add(_NOTE_1_6k_R);
		add(_NOTE_2_6k);
		add(_NOTE_2_6k_P);
		add(_NOTE_2_6k_R);
		add(_NOTE_3_6k);
		add(_NOTE_3_6k_P);
		add(_NOTE_3_6k_R);
		add(_NOTE_CENTER_7k);
		add(_NOTE_CENTER_7k_P);
		add(_NOTE_CENTER_7k_R);
		add(_NOTE_4_6k);
		add(_NOTE_4_6k_P);
		add(_NOTE_4_6k_R);
		add(_NOTE_5_6k);
		add(_NOTE_5_6k_P);
		add(_NOTE_5_6k_R);
		add(_NOTE_6_6k);
		add(_NOTE_6_6k_P);
		add(_NOTE_6_6k_R);
		add(_NOTE_1_8k);
		add(_NOTE_1_8k_P);
		add(_NOTE_1_8k_R);
		add(_NOTE_2_8k);
		add(_NOTE_2_8k_P);
		add(_NOTE_2_8k_R);
		add(_NOTE_3_8k);
		add(_NOTE_3_8k_P);
		add(_NOTE_3_8k_R);
		add(_NOTE_4_8k);
		add(_NOTE_4_8k_P);
		add(_NOTE_4_8k_R);
		add(_NOTE_CENTER_9k);
		add(_NOTE_CENTER_9k_P);
		add(_NOTE_CENTER_9k_R);
		add(_NOTE_5_8k);
		add(_NOTE_5_8k_P);
		add(_NOTE_5_8k_R);
		add(_NOTE_6_8k);
		add(_NOTE_6_8k_P);
		add(_NOTE_6_8k_R);
		add(_NOTE_7_8k);
		add(_NOTE_7_8k_P);
		add(_NOTE_7_8k_R);
		add(_NOTE_8_8k);
		add(_NOTE_8_8k_P);
		add(_NOTE_8_8k_R);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}
	#else
	public function new(name, scheme:KeyboardScheme = null)
	{
		super(name);

		add(_ui_up);
		add(_ui_left);
		add(_ui_right);
		add(_ui_down);
		add(_ui_upP);
		add(_ui_leftP);
		add(_ui_rightP);
		add(_ui_downP);
		add(_ui_upR);
		add(_ui_leftR);
		add(_ui_rightR);
		add(_ui_downR);
		add(_note_up);
		add(_note_left);
		add(_note_right);
		add(_note_down);
		add(_note_upP);
		add(_note_leftP);
		add(_note_rightP);
		add(_note_downP);
		add(_note_upR);
		add(_note_leftR);
		add(_note_rightR);
		add(_note_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);

		add(_NOTE_CENTER_5k);
		add(_NOTE_CENTER_5k_P);
		add(_NOTE_CENTER_5k_R);
		add(_NOTE_1_6k);
		add(_NOTE_1_6k_P);
		add(_NOTE_1_6k_R);
		add(_NOTE_2_6k);
		add(_NOTE_2_6k_P);
		add(_NOTE_2_6k_R);
		add(_NOTE_3_6k);
		add(_NOTE_3_6k_P);
		add(_NOTE_3_6k_R);
		add(_NOTE_CENTER_7k);
		add(_NOTE_CENTER_7k_P);
		add(_NOTE_CENTER_7k_R);
		add(_NOTE_4_6k);
		add(_NOTE_4_6k_P);
		add(_NOTE_4_6k_R);
		add(_NOTE_5_6k);
		add(_NOTE_5_6k_P);
		add(_NOTE_5_6k_R);
		add(_NOTE_6_6k);
		add(_NOTE_6_6k_P);
		add(_NOTE_6_6k_R);
		add(_NOTE_1_8k);
		add(_NOTE_1_8k_P);
		add(_NOTE_1_8k_R);
		add(_NOTE_2_8k);
		add(_NOTE_2_8k_P);
		add(_NOTE_2_8k_R);
		add(_NOTE_3_8k);
		add(_NOTE_3_8k_P);
		add(_NOTE_3_8k_R);
		add(_NOTE_4_8k);
		add(_NOTE_4_8k_P);
		add(_NOTE_4_8k_R);
		add(_NOTE_CENTER_9k);
		add(_NOTE_CENTER_9k_P);
		add(_NOTE_CENTER_9k_R);
		add(_NOTE_5_8k);
		add(_NOTE_5_8k_P);
		add(_NOTE_5_8k_R);
		add(_NOTE_6_8k);
		add(_NOTE_6_8k_P);
		add(_NOTE_6_8k_R);
		add(_NOTE_7_8k);
		add(_NOTE_7_8k_P);
		add(_NOTE_7_8k_R);
		add(_NOTE_8_8k);
		add(_NOTE_8_8k_P);
		add(_NOTE_8_8k_R);


		for (action in digitalActions)
			byName[action.name] = action;
			
		if (scheme == null)
			scheme = None;
		setKeyboardScheme(scheme, false);
	}
	#end

	override function update()
	{
		super.update();
	}

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UI_UP: _ui_up;
			case UI_DOWN: _ui_down;
			case UI_LEFT: _ui_left;
			case UI_RIGHT: _ui_right;
			case NOTE_UP: _note_up;
			case NOTE_DOWN: _note_down;
			case NOTE_LEFT: _note_left;
			case NOTE_RIGHT: _note_right;
			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case NOTE_CENTER_5k: _NOTE_CENTER_5k;
			case NOTE_1_6k: _NOTE_1_6k;
			case NOTE_2_6k: _NOTE_2_6k;
			case NOTE_3_6k: _NOTE_3_6k;
			case NOTE_CENTER_7k: _NOTE_CENTER_7k;
			case NOTE_4_6k: _NOTE_4_6k;
			case NOTE_5_6k: _NOTE_5_6k;
			case NOTE_6_6k: _NOTE_6_6k;
			case NOTE_1_8k: _NOTE_1_8k;
			case NOTE_2_8k: _NOTE_2_8k;
			case NOTE_3_8k: _NOTE_3_8k;
			case NOTE_4_8k: _NOTE_4_8k;
			case NOTE_CENTER_9k: _NOTE_CENTER_9k;
			case NOTE_5_8k: _NOTE_5_8k;
			case NOTE_6_8k: _NOTE_6_8k;
			case NOTE_7_8k: _NOTE_7_8k;
			case NOTE_8_8k: _NOTE_8_8k;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
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
			case NOTE_CENTER_5k:
				func(_NOTE_CENTER_5k, PRESSED);
				func(_NOTE_CENTER_5k_P, JUST_PRESSED);
				func(_NOTE_CENTER_5k_R, JUST_RELEASED);
			case NOTE_1_6k:
				func(_NOTE_1_6k, PRESSED);
				func(_NOTE_1_6k_P, JUST_PRESSED);
				func(_NOTE_1_6k_R, JUST_RELEASED);
			case NOTE_2_6k:
				func(_NOTE_2_6k, PRESSED);
				func(_NOTE_2_6k_P, JUST_PRESSED);
				func(_NOTE_2_6k_R, JUST_RELEASED);
			case NOTE_3_6k:
				func(_NOTE_3_6k, PRESSED);
				func(_NOTE_3_6k_P, JUST_PRESSED);
				func(_NOTE_3_6k_R, JUST_RELEASED);
			case NOTE_CENTER_7k:
				func(_NOTE_CENTER_7k, PRESSED);
				func(_NOTE_CENTER_7k_P, JUST_PRESSED);
				func(_NOTE_CENTER_7k_R, JUST_RELEASED);
			case NOTE_4_6k:
				func(_NOTE_4_6k, PRESSED);
				func(_NOTE_4_6k_P, JUST_PRESSED);
				func(_NOTE_4_6k_R, JUST_RELEASED);
			case NOTE_5_6k:
				func(_NOTE_5_6k, PRESSED);
				func(_NOTE_5_6k_P, JUST_PRESSED);
				func(_NOTE_5_6k_R, JUST_RELEASED);
			case NOTE_6_6k:
				func(_NOTE_6_6k, PRESSED);
				func(_NOTE_6_6k_P, JUST_PRESSED);
				func(_NOTE_6_6k_R, JUST_RELEASED);
			case NOTE_1_8k:
				func(_NOTE_1_8k, PRESSED);
				func(_NOTE_1_8k_P, JUST_PRESSED);
				func(_NOTE_1_8k_R, JUST_RELEASED);
			case NOTE_2_8k:
				func(_NOTE_2_8k, PRESSED);
				func(_NOTE_2_8k_P, JUST_PRESSED);
				func(_NOTE_2_8k_R, JUST_RELEASED);
			case NOTE_3_8k:
				func(_NOTE_3_8k, PRESSED);
				func(_NOTE_3_8k_P, JUST_PRESSED);
				func(_NOTE_3_8k_R, JUST_RELEASED);
			case NOTE_4_8k:
				func(_NOTE_4_8k, PRESSED);
				func(_NOTE_4_8k_P, JUST_PRESSED);
				func(_NOTE_4_8k_R, JUST_RELEASED);
			case NOTE_CENTER_9k:
				func(_NOTE_CENTER_9k, PRESSED);
				func(_NOTE_CENTER_9k_P, JUST_PRESSED);
				func(_NOTE_CENTER_9k_R, JUST_RELEASED);
			case NOTE_5_8k:
				func(_NOTE_5_8k, PRESSED);
				func(_NOTE_5_8k_P, JUST_PRESSED);
				func(_NOTE_5_8k_R, JUST_RELEASED);
			case NOTE_6_8k:
				func(_NOTE_6_8k, PRESSED);
				func(_NOTE_6_8k_P, JUST_PRESSED);
				func(_NOTE_6_8k_R, JUST_RELEASED);
			case NOTE_7_8k:
				func(_NOTE_7_8k, PRESSED);
				func(_NOTE_7_8k_P, JUST_PRESSED);
				func(_NOTE_7_8k_R, JUST_RELEASED);
			case NOTE_8_8k:
				func(_NOTE_8_8k, PRESSED);
				func(_NOTE_8_8k_P, JUST_PRESSED);
				func(_NOTE_8_8k_R, JUST_RELEASED);
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

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
				byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
					  gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		var copyKeys:Array<FlxKey> = keys.copy();
		for (i in 0...copyKeys.length) {
			if(i == NONE) copyKeys.remove(i);
		}

		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, copyKeys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, copyKeys, state));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		var copyKeys:Array<FlxKey> = keys.copy();
		for (i in 0...copyKeys.length) {
			if(i == NONE) copyKeys.remove(i);
		}

		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, copyKeys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, copyKeys));
		#end
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			if(key != NONE)
				action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{
		if (reset)
			removeKeyboard();

		keyboardScheme = scheme;
		var keysMap = ClientPrefs.keyBinds;
		
		#if (haxe >= "4.0.0")
		switch (scheme)
		{
			case Solo:
				inline bindKeys(Control.UI_UP, keysMap.get(Control.UI_UP));
				inline bindKeys(Control.UI_DOWN, keysMap.get(Control.UI_DOWN));
				inline bindKeys(Control.UI_LEFT, keysMap.get(Control.UI_LEFT));
				inline bindKeys(Control.UI_RIGHT, keysMap.get(Control.UI_RIGHT));
				inline bindKeys(Control.NOTE_UP, keysMap.get(Control.NOTE_UP));
				inline bindKeys(Control.NOTE_DOWN, keysMap.get(Control.NOTE_DOWN));
				inline bindKeys(Control.NOTE_LEFT, keysMap.get(Control.NOTE_LEFT));
				inline bindKeys(Control.NOTE_RIGHT, keysMap.get(Control.NOTE_RIGHT));

				inline bindKeys(Control.NOTE_CENTER_5k, keysMap.get(Control.NOTE_CENTER_5k));

				inline bindKeys(Control.NOTE_1_6k, keysMap.get(Control.NOTE_1_6k));
				inline bindKeys(Control.NOTE_2_6k, keysMap.get(Control.NOTE_2_6k));
				inline bindKeys(Control.NOTE_3_6k, keysMap.get(Control.NOTE_3_6k));
				inline bindKeys(Control.NOTE_CENTER_7k, keysMap.get(Control.NOTE_CENTER_7k));
				inline bindKeys(Control.NOTE_4_6k, keysMap.get(Control.NOTE_4_6k));
				inline bindKeys(Control.NOTE_5_6k, keysMap.get(Control.NOTE_5_6k));
				inline bindKeys(Control.NOTE_6_6k, keysMap.get(Control.NOTE_6_6k));

				inline bindKeys(Control.NOTE_1_8k, keysMap.get(Control.NOTE_1_8k));
				inline bindKeys(Control.NOTE_2_8k, keysMap.get(Control.NOTE_2_8k));
				inline bindKeys(Control.NOTE_3_8k, keysMap.get(Control.NOTE_3_8k));
				inline bindKeys(Control.NOTE_4_8k, keysMap.get(Control.NOTE_4_8k));
				inline bindKeys(Control.NOTE_CENTER_9k, keysMap.get(Control.NOTE_CENTER_9k));
				inline bindKeys(Control.NOTE_5_8k, keysMap.get(Control.NOTE_5_8k));
				inline bindKeys(Control.NOTE_6_8k, keysMap.get(Control.NOTE_6_8k));
				inline bindKeys(Control.NOTE_7_8k, keysMap.get(Control.NOTE_7_8k));
				inline bindKeys(Control.NOTE_8_8k, keysMap.get(Control.NOTE_8_8k));

				inline bindKeys(Control.ACCEPT, keysMap.get(Control.ACCEPT));
				inline bindKeys(Control.BACK, keysMap.get(Control.BACK));
				inline bindKeys(Control.PAUSE, keysMap.get(Control.PAUSE));
				inline bindKeys(Control.RESET, keysMap.get(Control.RESET));
			case Duo(true):
				inline bindKeys(Control.UI_UP, [W]);
				inline bindKeys(Control.UI_DOWN, [S]);
				inline bindKeys(Control.UI_LEFT, [A]);
				inline bindKeys(Control.UI_RIGHT, [D]);
				inline bindKeys(Control.NOTE_UP, [W]);
				inline bindKeys(Control.NOTE_DOWN, [S]);
				inline bindKeys(Control.NOTE_LEFT, [A]);
				inline bindKeys(Control.NOTE_RIGHT, [D]);
				inline bindKeys(Control.ACCEPT, [G, Z]);
				inline bindKeys(Control.BACK, [H, X]);
				inline bindKeys(Control.PAUSE, [ONE]);
				inline bindKeys(Control.RESET, [R]);
			case Duo(false):
				inline bindKeys(Control.UI_UP, [FlxKey.UP]);
				inline bindKeys(Control.UI_DOWN, [FlxKey.DOWN]);
				inline bindKeys(Control.UI_LEFT, [FlxKey.LEFT]);
				inline bindKeys(Control.UI_RIGHT, [FlxKey.RIGHT]);
				inline bindKeys(Control.NOTE_UP, [FlxKey.UP]);
				inline bindKeys(Control.NOTE_DOWN, [FlxKey.DOWN]);
				inline bindKeys(Control.NOTE_LEFT, [FlxKey.LEFT]);
				inline bindKeys(Control.NOTE_RIGHT, [FlxKey.RIGHT]);
				inline bindKeys(Control.ACCEPT, [O]);
				inline bindKeys(Control.BACK, [P]);
				inline bindKeys(Control.PAUSE, [ENTER]);
				inline bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#else
		switch (scheme)
		{
			case Solo:
				bindKeys(Control.UI_UP, keysMap.get(Control.UI_UP));
				bindKeys(Control.UI_DOWN, keysMap.get(Control.UI_DOWN));
				bindKeys(Control.UI_LEFT, keysMap.get(Control.UI_LEFT));
				bindKeys(Control.UI_RIGHT, keysMap.get(Control.UI_RIGHT));
				bindKeys(Control.NOTE_UP, keysMap.get(Control.NOTE_UP));
				bindKeys(Control.NOTE_DOWN, keysMap.get(Control.NOTE_DOWN));
				bindKeys(Control.NOTE_LEFT, keysMap.get(Control.NOTE_LEFT));
				bindKeys(Control.NOTE_RIGHT, keysMap.get(Control.NOTE_RIGHT));

				bindKeys(Control.NOTE_CENTER_5k, keysMap.get(Control.NOTE_CENTER_5k));

				bindKeys(Control.NOTE_1_6k, keysMap.get(Control.NOTE_1_6k));
				bindKeys(Control.NOTE_2_6k, keysMap.get(Control.NOTE_2_6k));
				bindKeys(Control.NOTE_3_6k, keysMap.get(Control.NOTE_3_6k));
				bindKeys(Control.NOTE_CENTER_7k, keysMap.get(Control.NOTE_CENTER_7k));
				bindKeys(Control.NOTE_4_6k, keysMap.get(Control.NOTE_4_6k));
				bindKeys(Control.NOTE_5_6k, keysMap.get(Control.NOTE_5_6k));
				bindKeys(Control.NOTE_6_6k, keysMap.get(Control.NOTE_6_6k));

				bindKeys(Control.NOTE_1_8k, keysMap.get(Control.NOTE_1_8k));
				bindKeys(Control.NOTE_2_8k, keysMap.get(Control.NOTE_2_8k));
				bindKeys(Control.NOTE_3_8k, keysMap.get(Control.NOTE_3_8k));
				bindKeys(Control.NOTE_4_8k, keysMap.get(Control.NOTE_4_8k));
				bindKeys(Control.NOTE_CENTER_9k, keysMap.get(Control.NOTE_CENTER_9k));
				bindKeys(Control.NOTE_5_8k, keysMap.get(Control.NOTE_5_8k));
				bindKeys(Control.NOTE_6_8k, keysMap.get(Control.NOTE_6_8k));
				bindKeys(Control.NOTE_7_8k, keysMap.get(Control.NOTE_7_8k));
				bindKeys(Control.NOTE_8_8k, keysMap.get(Control.NOTE_8_8k));

				bindKeys(Control.ACCEPT, keysMap.get(Control.ACCEPT));
				bindKeys(Control.BACK, keysMap.get(Control.BACK));
				bindKeys(Control.PAUSE, keysMap.get(Control.PAUSE));
				bindKeys(Control.RESET, keysMap.get(Control.RESET));
			case Duo(true):
				bindKeys(Control.UI_UP, [W]);
				bindKeys(Control.UI_DOWN, [S]);
				bindKeys(Control.UI_LEFT, [A]);
				bindKeys(Control.UI_RIGHT, [D]);
				bindKeys(Control.NOTE_UP, [W]);
				bindKeys(Control.NOTE_DOWN, [S]);
				bindKeys(Control.NOTE_LEFT, [A]);
				bindKeys(Control.NOTE_RIGHT, [D]);
				bindKeys(Control.ACCEPT, [G, Z]);
				bindKeys(Control.BACK, [H, X]);
				bindKeys(Control.PAUSE, [ONE]);
				bindKeys(Control.RESET, [R]);
			case Duo(false):
				bindKeys(Control.UI_UP, [FlxKey.UP]);
				bindKeys(Control.UI_DOWN, [FlxKey.DOWN]);
				bindKeys(Control.UI_LEFT, [FlxKey.LEFT]);
				bindKeys(Control.UI_RIGHT, [FlxKey.RIGHT]);
				bindKeys(Control.NOTE_UP, [FlxKey.UP]);
				bindKeys(Control.NOTE_DOWN, [FlxKey.DOWN]);
				bindKeys(Control.NOTE_LEFT, [FlxKey.LEFT]);
				bindKeys(Control.NOTE_RIGHT, [FlxKey.RIGHT]);
				bindKeys(Control.ACCEPT, [O]);
				bindKeys(Control.BACK, [P]);
				bindKeys(Control.PAUSE, [ENTER]);
				bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#end
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);
		
		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		#if !switch
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.UI_UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.UI_DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.UI_LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.UI_RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.NOTE_UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.NOTE_DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.NOTE_LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.NOTE_RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
		#else
		addGamepadLiteral(id, [
			//Swap A and B for switch
			Control.ACCEPT => [B],
			Control.BACK => [A],
			Control.UI_UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.UI_DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.UI_LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.UI_RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
			Control.NOTE_UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.NOTE_DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.NOTE_LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.NOTE_RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			//Swap Y and X for switch
			Control.RESET => [Y],
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}