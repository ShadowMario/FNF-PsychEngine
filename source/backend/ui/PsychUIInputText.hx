package backend.ui;

import flixel.FlxObject;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDestroyUtil;
import flash.events.KeyboardEvent;
import lime.system.Clipboard;

enum abstract AccentCode(Int) from Int from UInt to Int to UInt
{
	var NONE = -1;
	var GRAVE = 0;
	var ACUTE = 1;
	var CIRCUMFLEX = 2;
	var TILDE = 3;
}

enum abstract FilterMode(Int) from Int from UInt to Int to UInt
{
	var NO_FILTER:Int = 0;
	var ONLY_ALPHA:Int = 1;
	var ONLY_NUMERIC:Int = 2;
	var ONLY_ALPHANUMERIC:Int = 3;
	var ONLY_HEXADECIMAL:Int = 4;
	var CUSTOM_FILTER:Int = 5;
}

enum abstract CaseMode(Int) from Int from UInt to Int to UInt
{
	var ALL_CASES:Int = 0;
	var UPPER_CASE:Int = 1;
	var LOWER_CASE:Int = 2;
}

class PsychUIInputText extends FlxSpriteGroup
{
	public static final CHANGE_EVENT = "inputtext_change";

	static final KEY_TILDE = 126;
	static final KEY_ACUTE = 180;

	public static var focusOn(default, set):PsychUIInputText = null;

	public var name:String;
	public var bg:FlxSprite;
	public var behindText:FlxSprite;
	public var selection:FlxSprite;
	public var textObj:FlxText;
	public var caret:FlxSprite;
	public var onChange:String->String->Void;

	public var fieldWidth(default, set):Int = 0;
	public var maxLength(default, set):Int = 0;
	public var passwordMask(default, set):Bool = false;
	public var text(default, set):String = null;
	
	public var forceCase(default, set):CaseMode = ALL_CASES;
	public var filterMode(default, set):FilterMode = NO_FILTER;
	public var customFilterPattern(default, set):EReg;

	public var selectedFormat:FlxTextFormat = new FlxTextFormat(FlxColor.WHITE);

	public function new(x:Float = 0, y:Float = 0, wid:Int = 100, ?text:String = '', size:Int = 8)
	{
		super(x, y);
		this.bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		this.behindText = new FlxSprite(1, 1).makeGraphic(1, 1, FlxColor.WHITE);
		this.selection = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		this.textObj = new FlxText(1, 1, Math.max(1, wid - 2), '', size);
		this.caret = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		add(this.bg);
		add(this.behindText);
		add(this.selection);
		add(this.textObj);
		add(this.caret);

		this.textObj.color = FlxColor.BLACK;
		this.textObj.textField.selectable = false;
		this.textObj.textField.wordWrap = false;
		this.textObj.textField.multiline = false;
		this.selection.color = FlxColor.BLUE;

		@:bypassAccessor fieldWidth = wid;
		setGraphicSize(wid + 2, this.textObj.height + 2);
		updateHitbox();
		this.text = text;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	public var selectIndex:Int = -1;
	public var caretIndex(default, set):Int = -1;
	var _caretTime:Float = 0;

	var _nextAccent:AccentCode = NONE;
	public var inInsertMode:Bool = false;
	function onKeyDown(e:KeyboardEvent)
	{
		if(focusOn != this) return;

		var keyCode:Int = e.keyCode;
		var charCode:Int = e.charCode;
		var flxKey:FlxKey = cast keyCode;

		// Fix missing cedilla
		switch(keyCode)
		{
			case 231: //ç and Ç
				charCode = e.shiftKey ? 0xC7 : 0xE7;
		}

		// Control key actions
		if(e.controlKey)
		{
			switch(flxKey)
			{
				case A: //select all text
					selectIndex = Std.int(Math.min(0, text.length - 1));
					caretIndex = text.length;

				case X, C: //cut/copy selected text to clipboard
					if(caretIndex >= 0 && selectIndex != 0 && caretIndex != selectIndex)
					{
						Clipboard.text = text.substring(caretIndex, selectIndex);
						if(flxKey == X)
							deleteSelection();
					}

				case V: //paste from clipboard
					if(Clipboard.text == null) return;

					if(selectIndex > -1 && selectIndex != caretIndex)
						deleteSelection();

					var lastText = text;
					text = text.substring(0, caretIndex) + Clipboard.text + text.substring(caretIndex);
					caretIndex += Clipboard.text.length;
					if(onChange != null) onChange(lastText, text);
					if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);

				case BACKSPACE:
					if(selectIndex < 0 || selectIndex == caretIndex)
					{
						var lastText = text;
						var deletedText:String = text.substr(0, Std.int(Math.max(0, caretIndex-1)));
						var space:Int = deletedText.lastIndexOf(' ');
						if(space > -1 && space != caretIndex-1)
						{
							var start:String = deletedText.substring(0, space+1);
							var end:String = text.substring(caretIndex);
							caretIndex -= Std.int(Math.max(0, text.length - (start.length + end.length)));
							text = start + end;
						}
						else
						{
							text = text.substring(caretIndex);
							caretIndex = 0;
						}
						selectIndex = -1;
						if(onChange != null) onChange(lastText, text);
						if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
					}
					else deleteSelection();

				case DELETE:
					if(selectIndex < 0 || selectIndex == caretIndex)
					{
						// This is| a test
						// This is test
						var deletedText:String = text.substring(caretIndex);
						var spc:Int = 0;
						var space:Int = deletedText.indexOf(' ');
						while(deletedText.substr(spc, 1) == ' ')
						{
							spc++;
							space = deletedText.substr(spc).indexOf(' ');
						}

						var lastText = text;
						if(space > -1)
						{
							text = text.substr(0, caretIndex) + text.substring(caretIndex + space + spc);
						}
						else text = text.substr(0, caretIndex);
						if(onChange != null) onChange(lastText, text);
						if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
					}
					else deleteSelection();

				case LEFT:
					if(caretIndex > 0)
					{
						do
						{
							caretIndex--;
							var a:String = text.substr(caretIndex-1, 1);
							var b:String = text.substr(caretIndex, 1);
							//trace(a, b);
							if(a == ' ' && b != ' ') break;
						}
						while(caretIndex > 0);
					}

				case RIGHT:
					if(caretIndex < text.length)
					{
						do
						{
							caretIndex++;
							var a:String = text.substr(caretIndex-1, 1);
							var b:String = text.substr(caretIndex, 1);
							//trace(a, b);
							if(a != ' ' && b == ' ') break;
						}
						while(caretIndex < text.length);
					}

				default:
			}
			updateCaret();
			return;
		}

		static final ignored:Array<FlxKey> = [SHIFT, CONTROL, ESCAPE];
		if(ignored.contains(flxKey)) return;

		var lastAccent = _nextAccent;
		switch(keyCode)
		{
			case KEY_TILDE:
				_nextAccent = !e.shiftKey ? TILDE : CIRCUMFLEX;
				if(lastAccent == NONE) return;
			case KEY_ACUTE:
				_nextAccent = !e.shiftKey ? ACUTE : GRAVE;
				if(lastAccent == NONE) return;
			default:
				lastAccent = NONE;
		}

		//trace(keyCode, charCode, flxKey);
		switch(flxKey)
		{
			case LEFT: //move caret to left
				if(!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if(selectIndex == -1) selectIndex = caretIndex;
				caretIndex = Std.int(Math.max(0, caretIndex - 1));

			case RIGHT: //move caret to right
				if(!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if(selectIndex == -1) selectIndex = caretIndex;
				caretIndex = Std.int(Math.min(text.length, caretIndex + 1));

			case HOME: //move caret to the begin
				if(!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if(selectIndex == -1) selectIndex = caretIndex;
				caretIndex = 0;

			case END: //move caret to the end
				if(!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if(selectIndex == -1) selectIndex = caretIndex;
				caretIndex = text.length;

			case INSERT: //change to insert mode
				inInsertMode = !inInsertMode;

			case BACKSPACE: //Delete letter to the left of caret
				if(caretIndex <= 0) return;

				if(selectIndex > -1 && selectIndex != caretIndex)
					deleteSelection();
				else
				{
					var lastText = text;
					text = text.substring(0, caretIndex-1) + text.substring(caretIndex);
					caretIndex--;
					if(onChange != null) onChange(lastText, text);
					if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
				}
				_nextAccent = NONE;

			case DELETE: //Delete letter to the right of caret
				if(selectIndex > -1 && selectIndex != caretIndex)
				{
					deleteSelection();
					updateCaret();
					return;
				}

				if(caretIndex >= text.length) return;

				var lastText = text;
				if(caretIndex < 1)
					text = text.substr(1);
				else
					text = text.substring(0, caretIndex) + text.substring(caretIndex+1);

				if(caretIndex >= text.length) caretIndex = text.length;
				
				if(onChange != null) onChange(lastText, text);
				if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
			
			case SPACE: //space or last accent pressed
				if(_nextAccent != NONE) _typeLetter(getAccentCharCode(_nextAccent));
				else _typeLetter(charCode);
				_nextAccent = NONE;

			case A, O: //these support all accents
				var grave:Int = 0x0;
				var capital:Int = 0x0;
				switch(flxKey)
				{
					case A:
						grave = 0xC0;
						capital = 0x41;
					case O:
						grave = 0xD2;
						capital = 0x4f;
					default:
				}
				if(_nextAccent != NONE)
					charCode += grave - capital + _nextAccent;

				_typeLetter(charCode);
				_nextAccent = NONE;

			case E, I, U: //these support grave, acute and circumflex
				var grave:Int = 0x0;
				var capital:Int = 0x0;
				switch(flxKey)
				{
					case E:
						grave = 0xC8;
						capital = 0x45;
					case I:
						grave = 0xCC;
						capital = 0x49;
					case U:
						grave = 0xD9;
						capital = 0x55;
					default:
				}
				if(_nextAccent == GRAVE || _nextAccent == ACUTE || _nextAccent == CIRCUMFLEX) //Supported accents
					charCode += grave - capital + _nextAccent;
				else if(_nextAccent == TILDE) //Unsupported accent
					_typeLetter(getAccentCharCode(_nextAccent));

				_typeLetter(charCode);
				_nextAccent = NONE;

			case N: //it only supports tilde
				if(_nextAccent == TILDE)
					charCode += 0xD1 - 0x4E;
				else
					_typeLetter(getAccentCharCode(_nextAccent));

				_typeLetter(charCode);
				_nextAccent = NONE;

			case ESCAPE:
				focusOn = null;

			case ENTER:
				onPressEnter(e);

			default:
				if(charCode < 1)
					if((charCode = getAccentCharCode(_nextAccent)) < 1)
						return;

				if(lastAccent != NONE) _typeLetter(getAccentCharCode(lastAccent));
				else if(_nextAccent != NONE) _typeLetter(getAccentCharCode(_nextAccent));
				_typeLetter(charCode);
				_nextAccent = NONE;
		}
		updateCaret();
	}

	public dynamic function onPressEnter(e:KeyboardEvent)
		focusOn = null;

	public var unfocus:Void->Void;
	public static function set_focusOn(v:PsychUIInputText)
	{
		if(focusOn != null && focusOn != v && focusOn.exists)
		{
			if(focusOn.unfocus != null) focusOn.unfocus();
			focusOn.resetCaret();
		}
		return (focusOn = v);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.mouse.justPressed)
		{
			if(FlxG.mouse.overlaps(behindText, camera))
			{
				if(!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if(selectIndex == -1) selectIndex = caretIndex;
				focusOn = this;
				caretIndex = 0;
				var lastBound:Float = 0;
				var textObjX:Float = textObj.getScreenPosition(camera).x;
				var mousePosX:Float = FlxG.mouse.getScreenPosition(camera).x;
				var txtX:Float = textObjX - textObj.textField.scrollH;

				for (i => bound in _boundaries)
				{
					if(mousePosX >= txtX + (bound - lastBound)/2)
					{
						caretIndex = i+1;
						txtX += bound - lastBound;
						lastBound = bound;
					}
					else break;
				}
				updateCaret();
			}
			else if(focusOn == this)
				focusOn = null;

			//trace('changed focus to: ' + this);
		}

		if(focusOn == this)
		{
			_caretTime = (_caretTime + elapsed) % 1;
			if(textObj != null && textObj.exists)
			{
				var drewSelection:Bool = false;
				if(selection != null && selection.exists)
				{
					if(selectIndex != -1 && selectIndex != caretIndex)
					{
						selection.visible = true;
						drewSelection = true;
					}
					else selection.visible = false;
				}
	
				if(caret != null && caret.exists)
				{
					if(!drewSelection && _caretTime < 0.5 && caret.x >= textObj.x)
					{
						caret.visible = true;
						caret.color = textObj.color;
					}
					else caret.visible = false;
				}
			}
		}
		else
		{
			_caretTime = 0;
			inInsertMode = false;
			if(selection != null && selection.exists) selection.visible = false;
			if(caret != null && caret.exists) caret.visible = false;
		}
	}

	public function resetCaret()
	{
		selectIndex = -1;
		caretIndex = 0;
		updateCaret();
	}

	public function updateCaret()
	{
		if(textObj == null || !textObj.exists) return;

		var textField = textObj.textField;
		textField.setSelection(caretIndex, caretIndex);
		_caretTime = 0;
		if(caret != null && caret.exists)
		{
			caret.y = textObj.y + 2;
			caret.x = textObj.x + 1 - textObj.textField.scrollH;
			if(caretIndex > 0)
				caret.x += _boundaries[Std.int(Math.max(0, Math.min(_boundaries.length-1, caretIndex-1)))];
		}
		
		if(selection != null && selection.exists)
		{
			selection.y = textObj.y + 2;
			selection.x = textObj.x + 1 - textObj.textField.scrollH;
			if(selectIndex > 0)
				selection.x += _boundaries[Std.int(Math.max(0, Math.min(_boundaries.length-1, selectIndex-1)))];

			selection.scale.y = textField.textHeight;
			selection.scale.x = caret.x - selection.x;
			if(selection.scale.x < 0)
			{
				selection.scale.x = Math.abs(selection.scale.x);
				selection.x -= selection.scale.x;
			}

			if(selection.x < textObj.x)
			{
				var diff:Float = textObj.x - selection.x;
				selection.x += diff;
				selection.scale.x -= diff;
			}
			if(selection.x + selection.scale.x > textObj.x + textObj.width)
				selection.scale.x += (textObj.x + textObj.width - selection.x - selection.scale.x);

			selection.updateHitbox();

			if(text.length > 0)
			{
				textObj.removeFormat(selectedFormat);
				if(selectIndex != -1 && selectIndex != caretIndex)
				{
					textObj.addFormat(selectedFormat, caretIndex < selectIndex ? caretIndex : selectIndex, caretIndex < selectIndex ? selectIndex : caretIndex);
				}
			}
		}
		else if(text.length > 0) textObj.removeFormat(selectedFormat);
	}

	function deleteSelection()
	{
		var lastText:String = text;
		if(selectIndex > caretIndex)
		{
			text = text.substring(0, caretIndex) + text.substring(selectIndex);
		}
		else
		{
			text = text.substring(0, selectIndex) + text.substring(caretIndex);
			caretIndex = selectIndex;
		}
		selectIndex = -1;
		if(onChange != null) onChange(lastText, text);
		if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
	}

	override public function destroy()
	{
		_boundaries = null;
		if(focusOn == this) focusOn = null;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		super.destroy();
	}

	function set_caretIndex(v:Int)
	{
		caretIndex = v;
		updateCaret();
		return v;
	}

	override public function setGraphicSize(width:Float = 0, height:Float = 0)
	{
		super.setGraphicSize(width, height);
		bg.setGraphicSize(width, height);
		behindText.setGraphicSize(width - 2, height - 2);
		if(textObj != null && textObj.exists)
		{
			textObj.scale.x = 1;
			textObj.scale.y = 1;
			if(caret != null && caret.exists) caret.setGraphicSize(1, textObj.height - 4);
		}
	}
	
	override public function updateHitbox()
	{
		super.updateHitbox();
		bg.updateHitbox();
		behindText.updateHitbox();
		if(textObj != null && textObj.exists)
		{
			textObj.updateHitbox();
			if(caret != null && caret.exists) caret.updateHitbox();
		}
	}

	function set_fieldWidth(v:Int)
	{
		textObj.fieldWidth = Math.max(1, v - 2);
		textObj.textField.selectable = false;
		textObj.textField.wordWrap = false;
		textObj.textField.multiline = false;
		return (fieldWidth = v);
	}

	function set_maxLength(v:Int)
	{
		var lastText = text;
		v = Std.int(Math.max(0, v));
		if(v > 0 && text.length > v) text = text.substr(0, v);
		if(onChange != null) onChange(lastText, text);
		if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
		return (maxLength = v);
	}

	function set_passwordMask(v:Bool)
	{
		passwordMask = v;
		text = text;
		return passwordMask;
	}

	var _boundaries:Array<Float> = [];
	function set_text(v:String)
	{
		for (i in 0..._boundaries.length) _boundaries.pop();
		v = filter(v);

		textObj.text = '';
		if(v != null && v.length > 0)
		{
			if(v.length > 1)
			{
				for (i in 0...v.length)
				{
					var toPrint:String = v.substr(i, 1);
					if(toPrint == '\n') toPrint = ' ';
					textObj.textField.appendText(!passwordMask ? toPrint : '*');
					_boundaries.push(textObj.textField.textWidth);
				}
			}
			else
			{
				textObj.text = !passwordMask ? v : '*';
				_boundaries.push(textObj.textField.textWidth);
			}
		}
		text = v;
		updateCaret();
		return v;
	}

	public static function getAccentCharCode(accent:AccentCode)
	{
		switch(accent)
		{
			case TILDE:
				return 0x7E;
			case CIRCUMFLEX:
				return 0x5E;
			case ACUTE:
				return 0xB4;
			case GRAVE:
				return 0x60;
			default:
				return 0x0;
		}
	}

	public var broadcastInputTextEvent:Bool = true;
	function _typeLetter(charCode:Int)
	{
		if(charCode < 1) return;
		
		if(selectIndex > -1 && selectIndex != caretIndex)
			deleteSelection();

		var letter:String = String.fromCharCode(charCode);
		letter = filter(letter);
		if(letter.length > 0 && (maxLength == 0 || (text.length + letter.length) <= maxLength))
		{
			var lastText = text;
			//trace('Drawing character: $letter');
			if(!inInsertMode)
				text = text.substring(0, caretIndex) + letter + text.substring(caretIndex);
			else
				text = text.substring(0, caretIndex) + letter + text.substring(caretIndex+1);

			caretIndex += letter.length;
			if(onChange != null) onChange(lastText, text);
			if(broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
		}
		_caretTime = 0;
	}

	// from FlxInputText
	function set_forceCase(v:CaseMode)
	{
		forceCase = v;
		text = filter(text);
		return forceCase;
	}

	function set_filterMode(v:FilterMode)
	{
		filterMode = v;
		text = filter(text);
		return filterMode;
	}

	function set_customFilterPattern(cfp:EReg)
	{
		customFilterPattern = cfp;
		filterMode = CUSTOM_FILTER;
		return customFilterPattern;
	}
	
	private function filter(text:String):String
	{
		switch(forceCase)
		{
			case UPPER_CASE:
				text = text.toUpperCase();
			case LOWER_CASE:
				text = text.toLowerCase();
			default:
		}
		if (forceCase == UPPER_CASE)
			text = text.toUpperCase();
		else if (forceCase == LOWER_CASE)
			text = text.toLowerCase();

		if (filterMode != NO_FILTER)
		{
			var pattern:EReg;
			switch (filterMode)
			{
				case ONLY_ALPHA:
					pattern = ~/[^a-zA-Z]*/g;
				case ONLY_NUMERIC:
					pattern = ~/[^0-9]*/g;
				case ONLY_ALPHANUMERIC:
					pattern = ~/[^a-zA-Z0-9]*/g;
				case ONLY_HEXADECIMAL:
					pattern = ~/[^a-fA-F0-9]*/g;
				case CUSTOM_FILTER:
					pattern = customFilterPattern;
				default:
					throw new flash.errors.Error("FlxInputText: Unknown filterMode (" + filterMode + ")");
			}
			text = pattern.replace(text, "");
		}
		return text;
	}
}