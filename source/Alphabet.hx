package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

using StringTools;

/**
 * *Loosley based on FlxTypeText lolol*
 * Used to generate in game animated text, such as those seen in the Freeplay Menu, and in the Pause Menu.
 */
class Alphabet extends FlxSpriteGroup
{
	/**
	 * Delay between letters (in seconds). Only works if created with the `typed` parameter set to `true`.
	 * Default value is `0.05`, or `1 / 0.05` = `20` letters per second.
	 */
	public var delay:Float = 0.05;
	/**
	 * Whenever the text being typed in is paused. Set to true to pause, set to false to resume.
	 */
	public var paused:Bool = false;

	// for menu shit
	/**
	 * Menu selection position. In states such as `FreeplayState`, this value is always equal to `id - curSelected`, where `id` is the position of the setting in the menu.
	 */
	public var targetY:Float = 0;
	/**
	 * Whenever the Alphabet should reposition itself like an option menu. If set to true, will position itself like in `FreeplayState`, raccording to `targetY`.
	**/
	public var isMenuItem:Bool = false;
	/**
	 * If false, the Alphabet will go to the target Y without any lerp and set this to true.
	**/
	public var wentToTargetY:Bool = false;

	/**
	 * Alphabet's text. Does not have any effect when changed.
	 */
	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";


	/**
	 * Maximum width that a alphabet can have. Defaults to `FlxG.width` (1280)
	 */
	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;
	var textColor:FlxColor;

		/**
	 * Creates a new `Alphabet` object, used to create text from the `Alphabet.png` and `Alphabet.xml` files.
	 *
	 * @param   x              The x offset of the text (for some reason)
	 * @param   y              The y position of the text.
	 * @param   bold		   Whenever it should use the bold text (with outline), or the normal text
	 * @param   typed          Whenever the text should be typed like in Week 6's dialogue box.
	 * @param   color		   The color to be used. Only works on non bold text
	 */
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, color:FlxColor = FlxColor.BLACK)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;
		textColor = color;
		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
	}

	public function addText()
	{
		doSplitWords();

		
		var xPos:Float = 0;
		for (character in splitWords)
		{
			if (character == " " || character == "-")
			{
				lastWasSpace = true;
			}

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1 || AlphaCharacter.numbers.indexOf(character.toLowerCase()) != -1)
			{
				if (lastSprite != null)
				{
					xPos = lastSprite.x + lastSprite.width;
				}

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0, textColor);

				if (isBold) {
					letter.createBold(character);
				}
				else
				{
					letter.letterColor = FlxColor.WHITE;
					if (AlphaCharacter.numbers.contains(character)) {
						letter.createNumber(character);
					} else {
						letter.createLetter(character);
					}
				}
				add(letter);

				lastSprite = letter;
			}
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	/**
	 * Unused, but may be useful for your own scripts.	
	 */
	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti, textColor);
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createLetter(splitWords[loopNum]);
					}

					letter.x += 90;
				}

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var h:Float = FlxG.height;
			var w:Float = FlxG.width;

			if (wentToTargetY) {
				y = FlxMath.lerp(y, (scaledY * 120) + (h * 0.48), 0.16 * 60 * elapsed);
				x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16 * 60 * elapsed);
			} else {
				x = (targetY * 20) + 90 - w;
				// y = (targetY * 20) + 90;
				y = (scaledY * 120) + (h * 0.48);
				wentToTargetY = true;
			}
			
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var letterColor:FlxColor;

	public var row:Int = 0;
	
	public static var widths:Map<String, Int> = [
		"a" => 36,
		"b" => 32,
		"c" => 32,
		"d" => 31,
		"e" => 33,
		"f" => 27,
		"g" => 32,
		"h" => 29,
		"i" => 12,
		"j" => 27,
		"k" => 35,
		"l" => 11,
		"m" => 41,
		"n" => 27,
		"o" => 30,
		"p" => 27,
		"q" => 35,
		"r" => 24,
		"s" => 27,
		"t" => 28,
		"u" => 31,
		"v" => 32,
		"w" => 42,
		"x" => 33,
		"y" => 24,
		"z" => 37,
		// "A" => 44,
		// "B" => 44,
		// "C" => 44,
		// "D" => 44,
		// "E" => 44,
		// "F" => 44,
		// "G" => 44,
		// "H" => 44,
		// "I" => 44,
		// "J" => 44,
		// "K" => 44,
		// "L" => 44,
		// "M" => 44,
		// "N" => 44,
		// "O" => 44,
		// "P" => 44,
		// "Q" => 44,
		// "R" => 44,
		// "S" => 44,
		// "T" => 44,
		// "U" => 44,
		// "V" => 44,
		// "W" => 44,
		// "X" => 44,
		// "Y" => 44,
		// "Z" => 44
	];

	public function new(x:Float, y:Float, color:FlxColor)
	{
		super(x, y);
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;

		this.letterColor = color;
		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		if (numbers.contains(letter)) {
			this.color = FlxColor.WHITE;
			// trace(letter);
			this.letterColor = FlxColor.WHITE;
			createNumber(letter, true);
			offset.y = -10;
			y -= height;
			return;
		}
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		y = (110 - height);
		y += row * 60;
		
		
		colorTransform.redMultiplier = 0;
		colorTransform.greenMultiplier = 0;
		colorTransform.blueMultiplier = 0;

		colorTransform.redOffset = letterColor.red;
		colorTransform.greenOffset = letterColor.green;
		colorTransform.blueOffset = letterColor.blue;
	}

	public function createNumber(letter:String, autoPos:Bool = true):Void
	{
		animation.addByPrefix('$letter', '$letter', 24);
		animation.play('$letter');
		
		updateHitbox();

		if (autoPos) {
			y = (110 - height);
			y += row * 60;
		}

		colorTransform.redMultiplier = 0;
		colorTransform.greenMultiplier = 0;
		colorTransform.blueMultiplier = 0;

		colorTransform.redOffset = letterColor.red;
		colorTransform.greenOffset = letterColor.green;
		colorTransform.blueOffset = letterColor.blue;

		this.color = letterColor;
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
		}

		colorTransform.redMultiplier = 0;
		colorTransform.greenMultiplier = 0;
		colorTransform.blueMultiplier = 0;

		colorTransform.redOffset = letterColor.red;
		colorTransform.greenOffset = letterColor.green;
		colorTransform.blueOffset = letterColor.blue;

		updateHitbox();
	}
}
