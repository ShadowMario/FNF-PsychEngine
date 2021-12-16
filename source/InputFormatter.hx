import flixel.input.gamepad.FlxGamepadInputID;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

using StringTools;

class InputFormatter {
	public static function getKeyName(key:FlxKey):String {
		switch (key) {
			case BACKSPACE:
				return "BckSpc";
			case CONTROL:
				return "Ctrl";
			case ALT:
				return "Alt";
			case CAPSLOCK:
				return "Caps";
			case PAGEUP:
				return "PgUp";
			case PAGEDOWN:
				return "PgDown";
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
			case SEMICOLON:
				return ";";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			//case SLASH:
			//	return "/";
			case GRAVEACCENT:
				return "`";
			case LBRACKET:
				return "[";
			//case BACKSLASH:
			//	return "\\";
			case RBRACKET:
				return "]";
			case QUOTE:
				return "'";
			case PRINTSCREEN:
				return "PrtScrn";
			case NONE:
				return '---';
			default:
				var label:String = '' + key;
				if(label.toLowerCase() == 'null') return '---';
				return '' + label.charAt(0).toUpperCase() + label.substr(1).toLowerCase();
		}
	}

	public static function getGamepadButton(button:FlxGamepadInputID)
	{
		return switch (button) {
			case A:
				"A";
			case B:
				"B";
			case X:
				"X";
			case Y:
				"Y";
			case LEFT_SHOULDER:
				"LB";
			case RIGHT_SHOULDER:
				"RB";
			case LEFT_TRIGGER:
				"LT";
			case RIGHT_TRIGGER:
				"RT";
			case LEFT_STICK_CLICK:
				"LStick Click";
			case RIGHT_STICK_CLICK:
				"RStick Click";
			case LEFT_STICK_DIGITAL_DOWN:
				"LStick Down";
			case LEFT_STICK_DIGITAL_LEFT:
				"LStick Left";
			case LEFT_STICK_DIGITAL_RIGHT:
				"LStick Right";
			case LEFT_STICK_DIGITAL_UP:
				"LStick Up";
			case RIGHT_STICK_DIGITAL_DOWN:
				"RStick Down";
			case RIGHT_STICK_DIGITAL_LEFT:
				"RStick Left";
			case RIGHT_STICK_DIGITAL_RIGHT:
				"RStick Right";
			case RIGHT_STICK_DIGITAL_UP:
				"RStick Up";
			case DPAD_LEFT:
				"D-Pad Left";
			case DPAD_DOWN:
				"D-Pad Down";
			case DPAD_UP:
				"D-Pad Up";
			case DPAD_RIGHT:
				"D-Pad Right";
			case NONE:
				"---";
			default:
				var label:String = '' + button;
				if(label.toLowerCase() == 'null') '---';
				'' + label.charAt(0).toUpperCase() + label.substr(1).toLowerCase();
		}
	}
}