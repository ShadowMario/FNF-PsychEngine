package objects;

import haxe.Json;
import openfl.utils.Assets;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxSpriteGroup
{
	public var text(default, set):String;

	public var bold:Bool = false;
	public var letters:Array<AlphaCharacter> = [];

	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var alignment(default, set):Alignment = LEFT;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;
	public var rows:Int = 0;

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); //for the calculations

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y);

		this.startPosition.x = x;
		this.startPosition.y = y;
		this.bold = bold;
		this.text = text;
	}

	public function setAlignmentFromString(align:String)
	{
		switch(align.toLowerCase().trim())
		{
			case 'right':
				alignment = RIGHT;
			case 'center' | 'centered':
				alignment = CENTERED;
			default:
				alignment = LEFT;
		}
	}

	private function set_alignment(align:Alignment)
	{
		alignment = align;
		updateAlignment();
		return align;
	}

	private function updateAlignment()
	{
		for (letter in letters)
		{
			var newOffset:Float = 0;
			switch(alignment)
			{
				case CENTERED:
					newOffset = letter.rowWidth / 2;
				case RIGHT:
					newOffset = letter.rowWidth;
				default:
					newOffset = 0;
			}
	
			letter.offset.x -= letter.alignOffset;
			letter.alignOffset = newOffset * scale.x;
			letter.offset.x += letter.alignOffset;
		}
	}

	private function set_text(newText:String)
	{
		newText = newText.replace('\\n', '\n');
		clearLetters();
		createLetters(newText);
		updateAlignment();
		this.text = newText;
		return newText;
	}

	public function clearLetters()
	{
		var i:Int = letters.length;
		while (i > 0)
		{
			--i;
			var letter:AlphaCharacter = letters[i];
			if(letter != null)
			{
				letter.kill();
				letters.remove(letter);
				remove(letter);
			}
		}
		letters = [];
		rows = 0;
	}

	public function setScale(newX:Float, newY:Null<Float> = null)
	{
		var lastX:Float = scale.x;
		var lastY:Float = scale.y;
		if(newY == null) newY = newX;
		@:bypassAccessor
			scaleX = newX;
		@:bypassAccessor
			scaleY = newY;

		scale.x = newX;
		scale.y = newY;
		softReloadLetters(newX / lastX, newY / lastY);
	}

	private function set_scaleX(value:Float)
	{
		if (value == scaleX) return value;

		var ratio:Float = value / scale.x;
		scale.x = value;
		scaleX = value;
		softReloadLetters(ratio, 1);
		return value;
	}

	private function set_scaleY(value:Float)
	{
		if (value == scaleY) return value;

		var ratio:Float = value / scale.y;
		scale.y = value;
		scaleY = value;
		softReloadLetters(1, ratio);
		return value;
	}

	public function softReloadLetters(ratioX:Float = 1, ratioY:Null<Float> = null)
	{
		if(ratioY == null) ratioY = ratioX;

		for (letter in letters)
		{
			if(letter != null)
			{
				letter.setupAlphaCharacter(
					(letter.x - x) * ratioX + x,
					(letter.y - y) * ratioY + y
				);
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var lerpVal:Float = Math.exp(-elapsed * 9.6);
			if(changeX)
				x = FlxMath.lerp((targetY * distancePerItem.x) + startPosition.x, x, lerpVal);
			if(changeY)
				y = FlxMath.lerp((targetY * 1.3 * distancePerItem.y) + startPosition.y, y, lerpVal);
		}
		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if(changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if(changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}

	private static var Y_PER_ROW:Float = 85;

	private function createLetters(newText:String)
	{
		var consecutiveSpaces:Int = 0;

		var xPos:Float = 0;
		var rowData:Array<Float> = [];
		rows = 0;
		for (i in 0...newText.length)
		{
			var character:String = newText.charAt(i);
			if(character != '\n')
			{
				var spaceChar:Bool = (character == " " || (bold && character == "_"));
				if (spaceChar) consecutiveSpaces++;

				var isAlphabet:Bool = AlphaCharacter.isTypeAlphabet(character.toLowerCase());
				if (AlphaCharacter.allLetters.exists(character.toLowerCase()) && (!bold || !spaceChar))
				{
					if (consecutiveSpaces > 0)
					{
						xPos += 28 * consecutiveSpaces * scaleX;
						rowData[rows] = xPos;
						if(!bold && xPos >= FlxG.width * 0.65)
						{
							xPos = 0;
							rows++;
						}
					}
					consecutiveSpaces = 0;

					var letter:AlphaCharacter = cast recycle(AlphaCharacter, true);
					letter.scale.x = scaleX;
					letter.scale.y = scaleY;
					letter.rowWidth = 0;

					letter.setupAlphaCharacter(xPos, rows * Y_PER_ROW * scale.y, character, bold);
					@:privateAccess letter.parent = this;

					letter.row = rows;
					var off:Float = 0;
					if(!bold) off = 2;
					xPos += letter.width + (letter.letterOffset[0] + off) * scale.x;
					rowData[rows] = xPos;

					add(letter);
					letters.push(letter);
				}
			}
			else
			{
				xPos = 0;
				rows++;
			}
		}

		for (letter in letters)
		{
			letter.rowWidth = rowData[letter.row] / scale.x;
		}

		if(letters.length > 0) rows++;
	}
}


///////////////////////////////////////////
// ALPHABET LETTERS, SYMBOLS AND NUMBERS //
///////////////////////////////////////////

/*enum LetterType
{
	ALPHABET;
	NUMBER_OR_SYMBOL;
}*/

typedef Letter = {
	?anim:Null<String>,
	?offsets:Array<Float>,
	?offsetsBold:Array<Float>
}

class AlphaCharacter extends FlxSprite
{
	//public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	//public static var numbers:String = "1234567890";
	//public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var image(default, set):String;

	public static var allLetters:Map<String, Null<Letter>>;

	public static function loadAlphabetData(request:String = 'alphabet')
	{
		var path:String = Paths.getPath('images/$request.json');
		#if MODS_ALLOWED
		if(!FileSystem.exists(path))
		#else
		if(!Assets.exists(path, TEXT))
		#end
			path = Paths.getPath('images/alphabet.json');

		allLetters = new Map<String, Null<Letter>>();
		try
		{
			#if MODS_ALLOWED
			var data:Dynamic = Json.parse(File.getContent(path));
			#else
			var data:Dynamic = Json.parse(Assets.getText(path));
			#end

			if(data.allowed != null && data.allowed.length > 0)
			{
				for (i in 0...data.allowed.length)
				{
					var char:String = data.allowed.charAt(i);
					if(char == ' ') continue;
					
					allLetters.set(char.toLowerCase(), null); //Allows character to be used in Alphabet
				}
			}

			if(data.characters != null)
			{
				for (char in Reflect.fields(data.characters))
				{
					var letterData = Reflect.field(data.characters, char);
					var character:String = char.toLowerCase().substr(0, 1);
					if((letterData.animation != null || letterData.normal != null || letterData.bold != null) && allLetters.exists(character))
						allLetters.set(character, {anim: letterData.animation, offsets: letterData.normal, offsetsBold: letterData.bold});
				}
			}
			trace('Reloaded letters successfully ($path)!');
		}
		catch(e:Dynamic)
		{
			FlxG.log.error('Error on loading alphabet data: $e');
			trace('Error on loading alphabet data: $e');
		}

		if(!allLetters.exists('?'))
			allLetters.set('?', {anim: 'question'});
	}

	var parent:Alphabet;
	public var alignOffset:Float = 0; //Don't change this
	public var letterOffset:Array<Float> = [0, 0];

	public var row:Int = 0;
	public var rowWidth:Float = 0;
	public var character:String = '?';
	public function new()
	{
		super(x, y);
		image = 'alphabet';
		antialiasing = ClientPrefs.data.antialiasing;
	}
	
	public var curLetter:Letter = null;
	public function setupAlphaCharacter(x:Float, y:Float, ?character:String = null, ?bold:Null<Bool> = null)
	{
		this.x = x;
		this.y = y;

		if(parent != null)
		{
			if(bold == null)
				bold = parent.bold;
			this.scale.x = parent.scaleX;
			this.scale.y = parent.scaleY;
		}
		
		if(character != null)
		{
			this.character = character;
			curLetter = null;
			var lowercase:String = this.character.toLowerCase();
			if(allLetters.exists(lowercase)) curLetter = allLetters.get(lowercase);
			else curLetter = allLetters.get('?');

			var postfix:String = '';
			if(!bold)
			{
				if(isTypeAlphabet(lowercase))
				{
					if(lowercase != this.character)
						postfix = ' uppercase';
					else
						postfix = ' lowercase';
				}
				else postfix = ' normal';
			}
			else postfix = ' bold';

			var alphaAnim:String = lowercase;
			if(curLetter != null && curLetter.anim != null) alphaAnim = curLetter.anim;

			var anim:String = alphaAnim + postfix;
			animation.addByPrefix(anim, anim, 24);
			animation.play(anim, true);
			if(animation.curAnim == null)
			{
				if(postfix != ' bold') postfix = ' normal';
				anim = 'question' + postfix;
				animation.addByPrefix(anim, anim, 24);
				animation.play(anim, true);
			}
		}
		updateHitbox();
	}

	public static function isTypeAlphabet(c:String) // thanks kade
	{
		var ascii = StringTools.fastCodeAt(c, 0);
		return (ascii >= 65 && ascii <= 90)
			|| (ascii >= 97 && ascii <= 122)
			|| (ascii >= 192 && ascii <= 214)
			|| (ascii >= 216 && ascii <= 246)
			|| (ascii >= 248 && ascii <= 255);
	}

	private function set_image(name:String)
	{
		if(frames == null) //first setup
		{
			image = name;
			frames = Paths.getSparrowAtlas(name);
			return name;
		}

		var lastAnim:String = null;
		if (animation != null)
		{
			lastAnim = animation.name;
		}
		image = name;
		frames = Paths.getSparrowAtlas(name);
		this.scale.x = parent.scaleX;
		this.scale.y = parent.scaleY;
		alignOffset = 0;
		
		if (lastAnim != null)
		{
			animation.addByPrefix(lastAnim, lastAnim, 24);
			animation.play(lastAnim, true);
			
			updateHitbox();
		}
		return name;
	}

	public function updateLetterOffset()
	{
		if (animation.curAnim == null)
		{
			trace(character);
			return;
		}

		var add:Float = 110;
		if(animation.curAnim.name.endsWith('bold'))
		{
			if(curLetter != null && curLetter.offsetsBold != null)
			{
				letterOffset[0] = curLetter.offsetsBold[0];
				letterOffset[1] = curLetter.offsetsBold[1];
			}
			add = 70;
		}
		else
		{
			if(curLetter != null && curLetter.offsets != null)
			{
				letterOffset[0] = curLetter.offsets[0];
				letterOffset[1] = curLetter.offsets[1];
			}
		}
		add *= scale.y;
		offset.x += letterOffset[0] * scale.x;
		offset.y += letterOffset[1] * scale.y - (add - height);
	}

	override public function updateHitbox()
	{
		super.updateHitbox();
		updateLetterOffset();
	}
}
