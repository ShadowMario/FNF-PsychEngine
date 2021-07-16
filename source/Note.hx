package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:Int = 0;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += PlayState.STRUM_X + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('greenScroll', [GREEN_NOTE + 4]);
				animation.add('redScroll', [RED_NOTE + 4]);
				animation.add('blueScroll', [BLUE_NOTE + 4]);
				animation.add('purpleScroll', [PURP_NOTE + 4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [PURP_NOTE + 4]);
					animation.add('greenholdend', [GREEN_NOTE + 4]);
					animation.add('redholdend', [RED_NOTE + 4]);
					animation.add('blueholdend', [BLUE_NOTE + 4]);

					animation.add('purplehold', [PURP_NOTE]);
					animation.add('greenhold', [GREEN_NOTE]);
					animation.add('redhold', [RED_NOTE]);
					animation.add('bluehold', [BLUE_NOTE]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				if (isSustainNote)
				{
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = ClientPrefs.globalAntialiasing;
		}

		if(noteData > -1) {
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
			for (i in 0...3) {
				colorSwap.update(ClientPrefs.arrowHSV[noteData % 4][i], i);
			}

			x += swagWidth * (noteData % 4);
			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			if(ClientPrefs.downScroll) angle = 180;

			x += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
