package flixel.addons.ui;

import lime.system.Clipboard;
import flash.errors.Error;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flixel.addons.ui.FlxUI.NamedString;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

/**
 * FlxInputText v1.11, ported to Haxe
 * @author larsiusprime, (Lars Doucet)
 * @link http://github.com/haxeflixel/flixel-ui
 *
 * FlxInputText v1.10, Input text field extension for Flixel
 * @author Gama11, Mr_Walrus, nitram_cero (Martín Sebastián Wain)
 * @link http://forums.flixel.org/index.php/topic,272.0.html
 *
 * Copyright (c) 2009 Martín Sebastián Wain
 * License: Creative Commons Attribution 3.0 United States
 * @link http://creativecommons.org/licenses/by/3.0/us/
 * 
 */
class FlxInputText extends FlxText
{
	public static inline var NO_FILTER:Int = 0;
	public static inline var ONLY_ALPHA:Int = 1;
	public static inline var ONLY_NUMERIC:Int = 2;
	public static inline var ONLY_ALPHANUMERIC:Int = 3;
	public static inline var CUSTOM_FILTER:Int = 4;

	public static inline var ALL_CASES:Int = 0;
	public static inline var UPPER_CASE:Int = 1;
	public static inline var LOWER_CASE:Int = 2;

	public static inline var BACKSPACE_ACTION:String = "backspace"; // press backspace
	public static inline var DELETE_ACTION:String = "delete"; // press delete
	public static inline var ENTER_ACTION:String = "enter"; // press enter
	public static inline var INPUT_ACTION:String = "input"; // manually edit
	public static inline var PASTE_ACTION:String = "paste"; // text paste
	public static inline var COPY_ACTION:String = "copy"; // text copy
	public static inline var CUT_ACTION:String = "cut"; // text copy

	/**
	 * This regular expression will filter out (remove) everything that matches.
	 * Automatically sets filterMode = FlxInputText.CUSTOM_FILTER.
	 */
	public var customFilterPattern(default, set):EReg;

	function set_customFilterPattern(cfp:EReg)
	{
		customFilterPattern = cfp;
		filterMode = CUSTOM_FILTER;
		return customFilterPattern;
	}

	/**
	 * A function called whenever the value changes from user input, or enter is pressed
	 */
	public var callback:String->String->Void;

	/**
	 * Whether or not the textbox has a background
	 */
	public var background:Bool = false;

	/**
	 * The caret's color. Has the same color as the text by default.
	 */
	public var caretColor(default, set):Int;

	function set_caretColor(i:Int):Int
	{
		caretColor = i;
		dirty = true;
		return caretColor;
	}

	public var caretWidth(default, set):Int = 1;

	function set_caretWidth(i:Int):Int
	{
		caretWidth = i;
		dirty = true;
		return caretWidth;
	}

	public var params(default, set):Array<Dynamic>;

	/**
	 * Whether or not the textfield is a password textfield
	 */
	public var passwordMode(get, set):Bool;

	/**
	 * Whether or not the text box is the active object on the screen.
	 */
	public var hasFocus(default, set):Bool = false;

	/**
	 * The position of the selection cursor. An index of 0 means the carat is before the character at index 0.
	 */
	public var caretIndex(default, set):Int = 0;

	/**
	 * callback that is triggered when this text field gets focus
	 * @since 2.2.0
	 */
	public var focusGained:Void->Void;

	/**
	 * callback that is triggered when this text field loses focus
	 * @since 2.2.0
	 */
	public var focusLost:Void->Void;

	/**
	 * The Case that's being enforced. Either ALL_CASES, UPPER_CASE or LOWER_CASE.
	 */
	public var forceCase(default, set):Int = ALL_CASES;

	/**
	 * Set the maximum length for the field (e.g. "3"
	 * for Arcade type hi-score initials). 0 means unlimited.
	 */
	public var maxLength(default, set):Int = 0;

	/**
	 * Change the amount of lines that are allowed.
	 */
	public var lines(default, set):Int;

	/**
	 * Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
	 * (Remember to append "FlxInputText." as a prefix to those constants)
	 */
	public var filterMode(default, set):Int = NO_FILTER;

	/**
	 * The color of the fieldBorders
	 */
	public var fieldBorderColor(default, set):Int = FlxColor.BLACK;

	/**
	 * The thickness of the fieldBorders
	 */
	public var fieldBorderThickness(default, set):Int = 1;

	/**
	 * The color of the background of the textbox.
	 */
	public var backgroundColor(default, set):Int = FlxColor.WHITE;

	/**
	 * A FlxSprite representing the background sprite
	 */
	private var backgroundSprite:FlxSprite;

	/**
	 * A timer for the flashing caret effect.
	 */
	private var _caretTimer:FlxTimer;

	/**
	 * A FlxSprite representing the flashing caret when editing text.
	 */
	private var caret:FlxSprite;

	/**
	 * A FlxSprite representing the fieldBorders.
	 */
	private var fieldBorderSprite:FlxSprite;

	/**
	 * The left- and right- most fully visible character indeces
	 */
	private var _scrollBoundIndeces:{left:Int, right:Int} = {left: 0, right: 0};

	// workaround to deal with non-availability of getCharIndexAtPoint or getCharBoundaries on cpp/neko targets
	private var _charBoundaries:Array<FlxRect>;

	/**
	 * Stores last input text scroll.
	 */
	private var lastScroll:Int;

	/**
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param   size			Initial size of the font
	 * @param	TextColor		The color of the text
	 * @param	BackgroundColor	The color of the background (FlxColor.TRANSPARENT for no background color)
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 */
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 150, ?Text:String, size:Int = 8, TextColor:Int = FlxColor.BLACK,
			BackgroundColor:Int = FlxColor.WHITE, EmbeddedFont:Bool = true)
	{
		super(X, Y, Width, Text, size, EmbeddedFont);
		backgroundColor = BackgroundColor;

		if (BackgroundColor != FlxColor.TRANSPARENT)
		{
			background = true;
		}

		color = TextColor;
		caretColor = TextColor;

		caret = new FlxSprite();
		caret.makeGraphic(caretWidth, Std.int(size + 2));
		_caretTimer = new FlxTimer();

		caretIndex = 0;
		hasFocus = false;
		if (background)
		{
			fieldBorderSprite = new FlxSprite(X, Y);
			backgroundSprite = new FlxSprite(X, Y);
		}

		lines = 1;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		if (Text == null)
		{
			Text = "";
		}

		text = Text; // ensure set_text is called to avoid bugs (like not preparing _charBoundaries on sys target, making it impossible to click)

		calcFrame();
	}

	/**
	 * Clean up memory
	 */
	override public function destroy():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		backgroundSprite = FlxDestroyUtil.destroy(backgroundSprite);
		fieldBorderSprite = FlxDestroyUtil.destroy(fieldBorderSprite);
		callback = null;

		#if sys
		if (_charBoundaries != null)
		{
			while (_charBoundaries.length > 0)
			{
				_charBoundaries.pop();
			}
			_charBoundaries = null;
		}
		#end

		super.destroy();
	}

	/**
	 * Draw the caret in addition to the text.
	 */
	override public function draw():Void
	{
		drawSprite(fieldBorderSprite);
		drawSprite(backgroundSprite);

		super.draw();

		// In case caretColor was changed
		if (caretColor != caret.color || caret.height != size + 2)
		{
			caret.color = caretColor;
		}

		drawSprite(caret);
	}

	/**
	 * Helper function that makes sure sprites are drawn up even though they haven't been added.
	 * @param	Sprite		The Sprite to be drawn.
	 */
	private function drawSprite(Sprite:FlxSprite):Void
	{
		if (Sprite != null && Sprite.visible)
		{
			Sprite.scrollFactor = scrollFactor;
			Sprite.cameras = cameras;
			Sprite.draw();
		}
	}

	/**
	 * Check for mouse input every tick.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if FLX_MOUSE
		// Set focus and caretIndex as a response to mouse press
		if (FlxG.mouse.justPressed)
		{
			var hadFocus:Bool = hasFocus;
			if (FlxG.mouse.overlaps(this,camera))
			{
				caretIndex = getCaretIndex();
				hasFocus = true;
				if (!hadFocus && focusGained != null)
					focusGained();
			}
			else
			{
				hasFocus = false;
				if (hadFocus && focusLost != null)
					focusLost();
			}
		}
		#end
	}
	

	/**
	 * Handles keypresses generated on the stage.
	 */
	private function onKeyDown(e:KeyboardEvent):Void
	{
		var key:Int = e.keyCode;

		if (hasFocus)
		{

			  //// Crtl/Cmd + C to copy text to the clipboard
			  // This copies the entire input, because i'm too lazy to do caret selection, and if i did it i whoud probabbly make it a pr in flixel-ui.

			  #if (macos)
			  if (key == 67 && e.commandKey) {
			  #else
			  if (key == 67 && e.ctrlKey) {
		 	  #end
				Clipboard.text = text;

				onChange(COPY_ACTION);

				// Stops the function to go further, because it whoud type in a c to the input
				return;
			  }

			  //// Crtl/Cmd + V to paste in the clipboard text to the input
			  #if (macos)
			  if (key == 86 && e.commandKey) {
			  #else
			  if (key == 86 && e.ctrlKey) {
			  #end
				var newText:String = filter(Clipboard.text);

				if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength)) {
					text = insertSubstring(text, newText, caretIndex);
					caretIndex += newText.length;
					onChange(INPUT_ACTION);
					onChange(PASTE_ACTION);
				}

				// Same as before, but prevents typing out a v
				return;
			}

			//// Crtl/Cmd + X to cut the text from the input to the clipboard
			// Again, this copies the entire input text because there is no caret selection.
			#if (macos)
			if (key == 88 && e.commandKey) {
			#else
			if (key == 88 && e.ctrlKey) {
			#end
				Clipboard.text = text;
				text = '';
				caretIndex = 0;

				onChange(INPUT_ACTION);
				onChange(CUT_ACTION);

				// Same as before, but prevents typing out a x
				return;
			}

			// Do nothing for Shift, Ctrl, Esc, and flixel console hotkey
			if (key == 16 || key == 17 || key == 220 || key == 27)
			{
				return;
			}
			// Left arrow
			else if (key == 37)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text; // forces scroll update
				}
			}
			// Right arrow
			else if (key == 39)
			{
				if (caretIndex < text.length)
				{
					caretIndex++;
					text = text; // forces scroll update
				}
			}
			// End key
			else if (key == 35)
			{
				caretIndex = text.length;
				text = text; // forces scroll update
			}
			// Home key
			else if (key == 36)
			{
				caretIndex = 0;
				text = text;
			}
			// Backspace
			else if (key == 8)
			{
				if (caretIndex > 0)
				{
					caretIndex--;
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(BACKSPACE_ACTION);
				}
			}
			// Delete
			else if (key == 46)
			{
				if (text.length > 0 && caretIndex < text.length)
				{
					text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
					onChange(DELETE_ACTION);
				}
			}
			// Enter
			else if (key == 13)
			{
				onChange(ENTER_ACTION);
			}
			// Actually add some text
			else
			{
				if (e.charCode == 0) // non-printable characters crash String.fromCharCode
				{
					return;
				}
				var newText:String = filter(String.fromCharCode(e.charCode));

				if (newText.length > 0 && (maxLength == 0 || (text.length + newText.length) < maxLength))
				{
					text = insertSubstring(text, newText, caretIndex);
					caretIndex++;
					onChange(INPUT_ACTION);
				}
			}
		}
	}

	private function onChange(action:String):Void
	{
		if (callback != null)
		{
			callback(text, action);
		}
	}

	/**
	 * Inserts a substring into a string at a specific index
	 *
	 * @param	Insert			The string to have something inserted into
	 * @param	Insert			The string to insert
	 * @param	Index			The index to insert at
	 * @return					Returns the joined string for chaining.
	 */
	private function insertSubstring(Original:String, Insert:String, Index:Int):String
	{
		if (Index != Original.length)
		{
			Original = Original.substring(0, Index) + (Insert) + (Original.substring(Index));
		}
		else
		{
			Original = Original + (Insert);
		}
		return Original;
	}

	/**
	 * Gets the index of the character in this box under the mouse cursor
	 * @return The index of the character.
	 *         between 0 and the length of the text
	 */
	private function getCaretIndex():Int
	{
		#if FLX_MOUSE
		var hit = FlxPoint.get(FlxG.mouse.x - x, FlxG.mouse.y - y);
		return getCharIndexAtPoint(hit.x, hit.y);
		#else
		return 0;
		#end
	}

	private function getCharBoundaries(charIndex:Int):Rectangle
	{
		if (_charBoundaries != null && charIndex >= 0 && _charBoundaries.length > 0)
		{
			var r:Rectangle = new Rectangle();
			if (charIndex >= _charBoundaries.length)
			{
				_charBoundaries[_charBoundaries.length - 1].copyToFlash(r);
			}
			else
			{
				_charBoundaries[charIndex].copyToFlash(r);
			}
			return r;
		}
		return null;
	}

	private override function set_text(Text:String):String
	{
		#if !js
		if (textField != null)
		{
			lastScroll = textField.scrollH;
		}
		#end
		var return_text:String = super.set_text(Text);

		if (textField == null)
		{
			return return_text;
		}

		var numChars:Int = Text.length;
		prepareCharBoundaries(numChars);
		textField.text = "";
		var textH:Float = 0;
		var textW:Float = 0;
		var lastW:Float = 0;

		// Flash textFields have a "magic number" 2 pixel gutter all around
		// It does not seem to vary with font, size, border, etc, and does not seem to be customizable.
		// We simply reproduce this behavior here
		var magicX:Float = 2;
		var magicY:Float = 2;

		for (i in 0...numChars)
		{
			textField.appendText(Text.substr(i, 1)); // add a character
			textW = textField.textWidth; // count up total text width
			if (i == 0)
			{
				textH = textField.textHeight; // count height after first char
			}
			_charBoundaries[i].x = magicX + lastW; // place x at end of last character
			_charBoundaries[i].y = magicY; // place y at zero
			_charBoundaries[i].width = (textW - lastW); // place width at (width so far) minus (last char's end point)
			_charBoundaries[i].height = textH;
			lastW = textW;
		}
		textField.text = Text;
		onSetTextCheck();
		return return_text;
	}

	private function getCharIndexAtPoint(X:Float, Y:Float):Int
	{
		var i:Int = 0;
		#if !js
		X += textField.scrollH + 2;
		#end

		// offset X according to text alignment when there is no scroll.
		if (_charBoundaries != null && _charBoundaries.length > 0)
		{
			if (textField.textWidth <= textField.width)
			{
				switch (getAlignStr())
				{
					case RIGHT:
						X = X - textField.width + textField.textWidth
							;
					case CENTER:
						X = X - textField.width / 2 + textField.textWidth / 2
							;
					default:
				}
			}
		}

		// place caret at matching char position
		if (_charBoundaries != null)
		{
			for (r in _charBoundaries)
			{
				if (X >= r.left && X <= r.right)
				{
					return i;
				}
				i++;
			}
		}

		// place caret at rightmost position
		if (_charBoundaries != null && _charBoundaries.length > 0)
		{
			if (X > textField.textWidth)
			{
				return _charBoundaries.length;
			}
		}

		// place caret at leftmost position
		return 0;
	}

	private function prepareCharBoundaries(numChars:Int):Void
	{
		if (_charBoundaries == null)
		{
			_charBoundaries = [];
		}

		if (_charBoundaries.length > numChars)
		{
			var diff:Int = _charBoundaries.length - numChars;
			for (i in 0...diff)
			{
				_charBoundaries.pop();
			}
		}

		for (i in 0...numChars)
		{
			if (_charBoundaries.length - 1 < i)
			{
				_charBoundaries.push(FlxRect.get(0, 0, 0, 0));
			}
		}
	}

	/**
	 * Called every time the text is changed (for both flash/cpp) to update scrolling, etc
	 */
	private function onSetTextCheck():Void
	{
		#if !js
		var boundary:Rectangle = null;
		if (caretIndex == -1)
		{
			boundary = getCharBoundaries(text.length - 1);
		}
		else
		{
			boundary = getCharBoundaries(caretIndex);
		}

		if (boundary != null)
		{
			// Checks if carret is out of textfield bounds
			// if it is update scroll, otherwise maintain the same scroll as last check.
			var diffW:Int = 0;
			if (boundary.right > lastScroll + textField.width - 2)
			{
				diffW = -Std.int((textField.width - 2) - boundary.right); // caret to the right of textfield.
			}
			else if (boundary.left < lastScroll)
			{
				diffW = Std.int(boundary.left) - 2; // caret to the left of textfield
			}
			else
			{
				diffW = lastScroll; // no scroll change
			}

			#if !js
			textField.scrollH = diffW;
			#end
			calcFrame();
		}
		#end
	}

	/**
	 * Draws the frame of animation for the input text.
	 *
	 * @param	RunOnCpp	Whether the frame should also be recalculated if we're on a non-flash target
	 */
	private override function calcFrame(RunOnCpp:Bool = false):Void
	{
		super.calcFrame(RunOnCpp);

		if (fieldBorderSprite != null)
		{
			if (fieldBorderThickness > 0)
			{
				fieldBorderSprite.makeGraphic(Std.int(width + fieldBorderThickness * 2), Std.int(height + fieldBorderThickness * 2), fieldBorderColor);
				fieldBorderSprite.x = x - fieldBorderThickness;
				fieldBorderSprite.y = y - fieldBorderThickness;
			}
			else if (fieldBorderThickness == 0)
			{
				fieldBorderSprite.visible = false;
			}
		}

		if (backgroundSprite != null)
		{
			if (background)
			{
				backgroundSprite.makeGraphic(Std.int(width), Std.int(height), backgroundColor);
				backgroundSprite.x = x;
				backgroundSprite.y = y;
			}
			else
			{
				backgroundSprite.visible = false;
			}
		}

		if (caret != null)
		{
			// Generate the properly sized caret and also draw a border that matches that of the textfield (if a border style is set)
			// borderQuality can be safely ignored since the caret is always a rectangle

			var cw:Int = caretWidth; // Basic size of the caret
			var ch:Int = Std.int(size + 2);

			// Make sure alpha channels are correctly set
			var borderC:Int = (0xff000000 | (borderColor & 0x00ffffff));
			var caretC:Int = (0xff000000 | (caretColor & 0x00ffffff));

			// Generate unique key for the caret so we don't cause weird bugs if someone makes some random flxsprite of this size and color
			var caretKey:String = "caret" + cw + "x" + ch + "c:" + caretC + "b:" + borderStyle + "," + borderSize + "," + borderC;
			switch (borderStyle)
			{
				case NONE:
					// No border, just make the caret
					caret.makeGraphic(cw, ch, caretC, false, caretKey);
					caret.offset.x = caret.offset.y = 0;

				case SHADOW:
					// Shadow offset to the lower-right
					cw += Std.int(borderSize);
					ch += Std.int(borderSize); // expand canvas on one side for shadow
					caret.makeGraphic(cw, ch, FlxColor.TRANSPARENT, false, caretKey); // start with transparent canvas
					var r:Rectangle = new Rectangle(borderSize, borderSize, caretWidth, Std.int(size + 2));
					caret.pixels.fillRect(r, borderC); // draw shadow
					r.x = r.y = 0;
					caret.pixels.fillRect(r, caretC); // draw caret
					caret.offset.x = caret.offset.y = 0;

				case OUTLINE_FAST, OUTLINE:
					// Border all around it
					cw += Std.int(borderSize * 2);
					ch += Std.int(borderSize * 2); // expand canvas on both sides
					caret.makeGraphic(cw, ch, borderC, false, caretKey); // start with borderColor canvas
					var r = new Rectangle(borderSize, borderSize, caretWidth, Std.int(size + 2));
					caret.pixels.fillRect(r, caretC); // draw caret
					// we need to offset caret's drawing position since the caret is now larger than normal
					caret.offset.x = caret.offset.y = borderSize;
			}
			// Update width/height so caret's dimensions match its pixels
			caret.width = cw;
			caret.height = ch;

			caretIndex = caretIndex; // force this to update
		}
	}

	/**
	 * Turns the caret on/off for the caret flashing animation.
	 */
	private function toggleCaret(timer:FlxTimer):Void
	{
		caret.visible = !caret.visible;
	}

	/**
	 * Checks an input string against the current
	 * filter and returns a filtered string
	 */
	private function filter(text:String):String
	{
		if (forceCase == UPPER_CASE)
		{
			text = text.toUpperCase();
		}
		else if (forceCase == LOWER_CASE)
		{
			text = text.toLowerCase();
		}

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
				case CUSTOM_FILTER:
					pattern = customFilterPattern;
				default:
					throw new Error("FlxInputText: Unknown filterMode (" + filterMode + ")");
			}
			text = pattern.replace(text, "");
		}
		return text;
	}

	private function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		params = p;
		if (params == null)
		{
			params = [];
		}
		var namedValue:NamedString = {name: "value", value: text};
		params.push(namedValue);
		return p;
	}

	private override function set_x(X:Float):Float
	{
		if ((fieldBorderSprite != null) && fieldBorderThickness > 0)
		{
			fieldBorderSprite.x = X - fieldBorderThickness;
		}
		if ((backgroundSprite != null) && background)
		{
			backgroundSprite.x = X;
		}
		return super.set_x(X);
	}

	private override function set_y(Y:Float):Float
	{
		if ((fieldBorderSprite != null) && fieldBorderThickness > 0)
		{
			fieldBorderSprite.y = Y - fieldBorderThickness;
		}
		if ((backgroundSprite != null) && background)
		{
			backgroundSprite.y = Y;
		}
		return super.set_y(Y);
	}

	private function set_hasFocus(newFocus:Bool):Bool
	{
		if (newFocus)
		{
			if (hasFocus != newFocus)
			{
				_caretTimer = new FlxTimer().start(0.5, toggleCaret, 0);
				caret.visible = true;
				caretIndex = text.length;
			}
		}
		else
		{
			// Graphics
			caret.visible = false;
			if (_caretTimer != null)
			{
				_caretTimer.cancel();
			}
		}

		if (newFocus != hasFocus)
		{
			calcFrame();
		}
		return hasFocus = newFocus;
	}

	private function getAlignStr():FlxTextAlign
	{
		var alignStr:FlxTextAlign = LEFT;
		if (_defaultFormat != null && _defaultFormat.align != null)
		{
			alignStr = alignment;
		}
		return alignStr;
	}

	private function set_caretIndex(newCaretIndex:Int):Int
	{
		var offx:Float = 0;

		var alignStr:FlxTextAlign = getAlignStr();

		switch (alignStr)
		{
			case RIGHT:
				offx = textField.width - 2 - textField.textWidth - 2;
				if (offx < 0)
					offx = 0; // hack, fix negative offset.

			case CENTER:
				#if !js
				offx = (textField.width - 2 - textField.textWidth) / 2 + textField.scrollH / 2;
				#end
				if (offx <= 1)
					offx = 0; // hack, fix ofset rounding alignment.

			default:
				offx = 0;
		}

		caretIndex = newCaretIndex;

		// If caret is too far to the right something is wrong
		if (caretIndex > (text.length + 1))
		{
			caretIndex = -1;
		}

		// Caret is OK, proceed to position
		if (caretIndex != -1)
		{
			var boundaries:Rectangle = null;

			// Caret is not to the right of text
			if (caretIndex < text.length)
			{
				boundaries = getCharBoundaries(caretIndex);
				if (boundaries != null)
				{
					caret.x = offx + boundaries.left + x;
					caret.y = boundaries.top + y;
				}
			}
			// Caret is to the right of text
			else
			{
				boundaries = getCharBoundaries(caretIndex - 1);
				if (boundaries != null)
				{
					caret.x = offx + boundaries.right + x;
					caret.y = boundaries.top + y;
				}
				// Text box is empty
				else if (text.length == 0)
				{
					// 2 px gutters
					caret.x = x + offx + 2;
					caret.y = y + 2;
				}
			}
		}

		#if !js
		caret.x -= textField.scrollH;
		#end

		// Make sure the caret doesn't leave the textfield on single-line input texts
		if ((lines == 1) && (caret.x + caret.width) > (x + width))
		{
			caret.x = x + width - 2;
		}

		return caretIndex;
	}

	private function set_forceCase(Value:Int):Int
	{
		forceCase = Value;
		text = filter(text);
		return forceCase;
	}

	override private function set_size(Value:Int):Int
	{
		super.size = Value;
		caret.makeGraphic(1, Std.int(size + 2));
		return Value;
	}

	private function set_maxLength(Value:Int):Int
	{
		maxLength = Value;
		if (text.length > maxLength)
		{
			text = text.substring(0, maxLength);
		}
		return maxLength;
	}

	private function set_lines(Value:Int):Int
	{
		if (Value == 0)
			return 0;

		if (Value > 1)
		{
			textField.wordWrap = true;
			textField.multiline = true;
		}
		else
		{
			textField.wordWrap = false;
			textField.multiline = false;
		}

		lines = Value;
		calcFrame();
		return lines;
	}

	private function get_passwordMode():Bool
	{
		return textField.displayAsPassword;
	}

	private function set_passwordMode(value:Bool):Bool
	{
		textField.displayAsPassword = value;
		calcFrame();
		return value;
	}

	private function set_filterMode(Value:Int):Int
	{
		filterMode = Value;
		text = filter(text);
		return filterMode;
	}

	private function set_fieldBorderColor(Value:Int):Int
	{
		fieldBorderColor = Value;
		calcFrame();
		return fieldBorderColor;
	}

	private function set_fieldBorderThickness(Value:Int):Int
	{
		fieldBorderThickness = Value;
		calcFrame();
		return fieldBorderThickness;
	}

	private function set_backgroundColor(Value:Int):Int
	{
		backgroundColor = Value;
		calcFrame();
		return backgroundColor;
	}
}
