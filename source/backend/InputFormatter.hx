package backend;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class InputFormatter {
	public static function getKeyName(key:FlxKey):String {
		switch (key) {
			case BACKSPACE:
				return Language.getPhrase('flxkey_backspace', 'BckSpc');
			case CONTROL:
				return Language.getPhrase('flxkey_control', 'Ctrl');
			case ALT:
				return Language.getPhrase('flxkey_alt', 'Alt');
			case CAPSLOCK:
				return Language.getPhrase('flxkey_capslock', 'Caps');
			case PAGEUP:
				return Language.getPhrase('flxkey_pageup', 'PgUp');
			case PAGEDOWN:
				return Language.getPhrase('flxkey_pagedown', 'PgDown');
			case BREAK:
				return Language.getPhrase('flxkey_break', 'Pause Brk');
			case SCROLL_LOCK:
				return Language.getPhrase('flxkey_scroll_lock', 'ScrLk');
			case HOME:
				return Language.getPhrase('flxkey_home', 'Home');
			case END:
				return Language.getPhrase('flxkey_end', 'End');
			case INSERT:
				return Language.getPhrase('flxkey_insert', 'Ins');
			case ESCAPE:
				return Language.getPhrase('flxkey_escape', 'Esc');
			case DELETE:
				return Language.getPhrase('flxkey_delete', 'Delete');
			case BACKSLASH:
				return Language.getPhrase('flxkey_backslash', 'Backslash');
			case SLASH:
				return Language.getPhrase('flxkey_slash', 'Slash');
			case PRINTSCREEN:
				return Language.getPhrase('flxkey_printscreen', 'PrtSrcn');
			case GRAVEACCENT:
				return Language.getPhrase('flxkey_graveaccent', 'Backtick');
			case LEFT:
				return Language.getPhrase('flxkey_left', 'Left');
			case DOWN:
				return Language.getPhrase('flxkey_down', 'Down');
			case UP:
				return Language.getPhrase('flxkey_up', 'Up');
			case RIGHT:
				return Language.getPhrase('flxkey_right', 'Right');
			case SPACE:
				return Language.getPhrase('flxkey_space', 'Space');
			case MENU:
				return Language.getPhrase('flxkey_menu', 'Menu');
			case TAB:
				return Language.getPhrase('flxkey_tab', 'Tab');
			case SHIFT:
				return Language.getPhrase('flxkey_shift', 'Shift');
			case ENTER:
				return Language.getPhrase('flxkey_enter', 'Enter');
			case NUMLOCK:
				return Language.getPhrase('flxkey_numlock', 'NumLk');
			
			// keys which dont need translation
			case ZERO:
				return "0";
			case ONE:
				return "1";
			case TWO:
				return "2";
			case THREE:
				return "3";
			case FOUR:
				return "4";
			case FIVE:
				return "5";
			case SIX:
				return "6";
			case SEVEN:
				return "7";
			case EIGHT:
				return "8";
			case NINE:
				return "9";
			case NUMPADZERO:
				return "#0";
			case NUMPADONE:
				return "#1";
			case NUMPADTWO:
				return "#2";
			case NUMPADTHREE:
				return "#3";
			case NUMPADFOUR:
				return "#4";
			case NUMPADFIVE:
				return "#5";
			case NUMPADSIX:
				return "#6";
			case NUMPADSEVEN:
				return "#7";
			case NUMPADEIGHT:
				return "#8";
			case NUMPADNINE:
				return "#9";
			case NUMPADMULTIPLY:
				return "#*";
			case NUMPADPLUS:
				return "#+";
			case NUMPADMINUS:
				return "#-";
			case NUMPADPERIOD:
				return "#.";
			case NUMPADSLASH:
				return "#/";
			case MINUS:
				return "-";
			case PLUS:
				return "+";
			case SEMICOLON:
				return ";";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			case LBRACKET:
				return "[";
			case RBRACKET:
				return "]";
			case QUOTE:
				return "'";
			case NONE:
				return '---';
			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}

	public static function getGamepadName(key:FlxGamepadInputID)
	{
		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;

		switch(key)
		{
			// Analogs
			case LEFT_STICK_DIGITAL_LEFT:
				return "Left";
			case LEFT_STICK_DIGITAL_RIGHT:
				return "Right";
			case LEFT_STICK_DIGITAL_UP:
				return "Up";
			case LEFT_STICK_DIGITAL_DOWN:
				return "Down";
			case LEFT_STICK_CLICK:
				switch (model) {
					case PS4: return "L3";
					case XINPUT: return "LS";
					default: return "Analog Click";
				}

			case RIGHT_STICK_DIGITAL_LEFT:
				return "C. Left";
			case RIGHT_STICK_DIGITAL_RIGHT:
				return "C. Right";
			case RIGHT_STICK_DIGITAL_UP:
				return "C. Up";
			case RIGHT_STICK_DIGITAL_DOWN:
				return "C. Down";
			case RIGHT_STICK_CLICK:
				switch (model) {
					case PS4: return "R3";
					case XINPUT: return "RS";
					default: return "C. Click";
				}

			// Directional
			case DPAD_LEFT:
				return "D. Left";
			case DPAD_RIGHT:
				return "D. Right";
			case DPAD_UP:
				return "D. Up";
			case DPAD_DOWN:
				return "D. Down";

			// Top buttons
			case LEFT_SHOULDER:
				switch(model) {
					case PS4: return "L1";
					case XINPUT: return "LB";
					default: return "L. Bumper";
				}
			case RIGHT_SHOULDER:
				switch(model) {
					case PS4: return "R1";
					case XINPUT: return "RB";
					default: return "R. Bumper";
				}
			case LEFT_TRIGGER, LEFT_TRIGGER_BUTTON:
				switch(model) {
					case PS4: return "L2";
					case XINPUT: return "LT";
					default: return "L. Trigger";
				}
			case RIGHT_TRIGGER, RIGHT_TRIGGER_BUTTON:
				switch(model) {
					case PS4: return "R2";
					case XINPUT: return "RT";
					default: return "R. Trigger";
				}

			// Buttons
			case A:
				switch (model) {
					case PS4: return "X";
					case XINPUT: return "A";
					default: return "Action Down";
				}
			case B:
				switch (model) {
					case PS4: return "O";
					case XINPUT: return "B";
					default: return "Action Right";
				}
			case X:
				switch (model) {
					case PS4: return "["; //This gets its image changed through code
					case XINPUT: return "X";
					default: return "Action Left";
				}
			case Y:
				switch (model) { 
					case PS4: return "]"; //This gets its image changed through code
					case XINPUT: return "Y";
					default: return "Action Up";
				}

			case BACK:
				switch(model) {
					case PS4: return "Share";
					case XINPUT: return "Back";
					default: return "Select";
				}
			case START:
				switch(model) {
					case PS4: return "Options";
					default: return "Start";
				}

			case NONE:
				return '---';

			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}
}