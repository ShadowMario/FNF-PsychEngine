package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flash.media.Sound;

using StringTools;

class TypedAlphabet extends Alphabet
{
	public var onFinish:Void->Void = null;
	public var finishedText:Bool = false;
	public var delay:Float = 0.05;
	public var sound:String = 'dialogue';
	public var volume:Float = 1;

	public function new(x:Float, y:Float, text:String = "", ?delay:Float = 0.05, ?bold:Bool = false)
	{
		super(x, y, text, bold);

		this.delay = delay;
	}

	override private function set_text(newText:String)
	{
		super.set_text(newText);

		resetDialogue();
		return newText;
	}

	private var _curLetter:Int = -1;
	private var _timeToUpdate:Float = 0;
	override function update(elapsed:Float)
	{
		if(!finishedText)
		{
			var playedSound:Bool = false;
			_timeToUpdate += elapsed;
			while(_timeToUpdate >= delay)
			{
				showCharacterUpTo(_curLetter + 1);
				if(!playedSound && sound != '' && (delay > 0.025 || _curLetter % 2 == 0))
				{
					FlxG.sound.play(Paths.sound(sound), volume);
				}
				playedSound = true;

				_curLetter++;
				if(_curLetter >= letters.length - 1)
				{
					finishedText = true;
					if(onFinish != null) onFinish();
					_timeToUpdate = 0;
					break;
				}
				_timeToUpdate = 0;
			}
		}

		super.update(elapsed);
	}

	public function showCharacterUpTo(upTo:Int)
	{
		var start:Int = _curLetter;
		if(start < 0) start = 0;

		for (i in start...(upTo+1))
		{
			if(letters[i] != null) letters[i].visible = true;
			//trace('test, showing: $i');
		}
	}

	public function resetDialogue()
	{
		_curLetter = -1;
		finishedText = false;
		_timeToUpdate = 0;
		for (letter in letters)
		{
			letter.visible = false;
		}
	}

	public function finishText()
	{
		if(finishedText) return;

		showCharacterUpTo(letters.length - 1);
		if(sound != '') FlxG.sound.play(Paths.sound(sound), volume);
		finishedText = true;
		
		if(onFinish != null) onFinish();
		_timeToUpdate = 0;
	}
}