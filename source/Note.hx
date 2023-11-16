package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;
import flixel.util.FlxPool;
import flixel.math.FlxRect;
import openfl.system.System;
import NoteShader.ColoredNoteShader;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{

	public var row:Int = 0;
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false; //For Opponent notes
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	
	public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	private var pixelInt:Array<Int> = [0, 1, 2, 3];
	public static var beats:Array<Int> = [4, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192,256,384,512,768,1024,1536,2048,3072,6144];

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var prevNoteIsSustainNote:Bool = false;

	public static var SUSTAIN_SIZE:Int = 44;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyScale:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var dumbHitboxThing:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;

	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
	{
		if(isSustainNote && animation != null && animation.curAnim != null && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String {
		if(texture != value && ClientPrefs.showNotes) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	function quantCheck():Void 
	{
		if (ClientPrefs.noteColorStyle == 'Quant-Based' && !isSustainNote)
			{
				var time = strumTime;
				var theCurBPM = Conductor.bpm;
				var stepCrochet:Float = (60 / theCurBPM) * 1000;
				for (i in 0...Conductor.bpmChangeMap.length)
				{
					var bpmchange = Conductor.bpmChangeMap[i];
					if (strumTime >= bpmchange.songTime)
					{
						theCurBPM = bpmchange.bpm;
						time -= bpmchange.songTime;
						stepCrochet = (60 / theCurBPM) * 1000;
					}
				}

				var beat = Math.round((time / stepCrochet) * 48);
				for (i in 0...beats.length)
				{
					if (beat % (192 / beats[i]) == 0)
					{
						beat = beats[i];
						break;
					}			
				}
				switch (beat)
				{
					case 4: //red
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 8: //blue
						colorSwap.hue = -0.34;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 12: //purple
						colorSwap.hue = 0.8;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 16: //yellow
						colorSwap.hue = 0.16;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 24: //pink
						colorSwap.hue = 0.91;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 32: //orange
						colorSwap.hue = 0.06;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 48: //cyan
						colorSwap.hue = -0.53;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 64: //green
						colorSwap.hue = -0.7;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					case 96: //salmon lookin ass
						colorSwap.hue = 0;
						colorSwap.saturation = -0.33;
						colorSwap.brightness = 0;
					case 128: //light purple shit
						colorSwap.hue = -0.24;
						colorSwap.saturation = -0.33;
						colorSwap.brightness = 0;
					case 192: //turquioe i cant spell
						colorSwap.hue = 0.44;
						colorSwap.saturation = 0.31;
						colorSwap.brightness = 0;
					case 256: //shit (the color of it)
						colorSwap.hue = 0.03;
						colorSwap.saturation = 0;
						colorSwap.brightness = -0.63;
					case 384: //dark green ugly shit
						colorSwap.hue = 0.29;
						colorSwap.saturation = 1;
						colorSwap.brightness = -0.89;
					case 512: //darj blue
						colorSwap.hue = -0.33;
						colorSwap.saturation = 0.29;
						colorSwap.brightness = -0.7;
					case 768: //gray ok
						colorSwap.hue = 0.04;
						colorSwap.saturation = -0.86;
						colorSwap.brightness = -0.23;
					case 1024: //turqyuarfhiouhifueaig but dark
						colorSwap.hue = 0.46;
						colorSwap.saturation = 0;
						colorSwap.brightness = -0.46;
					case 1536: //pure death
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = -1;
					case 2048: //piss and shit color
						colorSwap.hue = 0.2;
						colorSwap.saturation = -0.36;
						colorSwap.brightness = -0.74;
					case 3072: //boring ass color
						colorSwap.hue = 0.17;
						colorSwap.saturation = -0.57;
						colorSwap.brightness = -0.27;
					case 6144: //why did i do this? idk tbh, it just funni
						colorSwap.hue = 0.23;
						colorSwap.saturation = 0.76;
						colorSwap.brightness = -0.83;
					default: // white/gray
						colorSwap.hue = 0.04;
						colorSwap.saturation = -0.86;
						colorSwap.brightness = -0.23;
				}
			}
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;

		if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length && ClientPrefs.noteColorStyle == 'Normal' && !ClientPrefs.rainbowNotes && ClientPrefs.showNotes && ClientPrefs.enableColorShader)
		{
			colorSwap.hue = ClientPrefs.arrowHSV[noteData][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData][2] / 100;
		}

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;

					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'Behind Note':
					colorSwap.hue = 0;
					colorSwap.saturation = -50;
					colorSwap.brightness = 0;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		if (ClientPrefs.showNotes && ClientPrefs.enableColorShader)
		{
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		}
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?mustPressIt:Bool = false, ?isGfNote:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		mustPress = mustPressIt;
		gfNote = isGfNote;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if (!ClientPrefs.showNotes) loadNoteAnims();

		if(noteData > -1) {
			if (ClientPrefs.showNotes)
			{
			texture = '';
			if(ClientPrefs.noteStyleThing == 'VS Nonsense V2') {
				texture = 'Nonsense_NOTE_assets';
			}
			if(ClientPrefs.noteStyleThing == 'DNB 3D') {
				texture = 'NOTE_assets_3D';
			}
			if(ClientPrefs.noteStyleThing == 'VS AGOTI') {
				texture = 'AGOTINOTE_assets';
			}
			if(ClientPrefs.noteStyleThing == 'Doki Doki+') {
				texture = 'NOTE_assets_doki';
			}
			if(ClientPrefs.noteStyleThing == 'TGT V4') {
				texture = 'TGTNOTE_assets';
			}
			if (ClientPrefs.noteStyleThing != 'VS Nonsense V2' && ClientPrefs.noteStyleThing != 'DNB 3D' && ClientPrefs.noteStyleThing != 'VS AGOTI' && ClientPrefs.noteStyleThing != 'Doki Doki+' && ClientPrefs.noteStyleThing != 'TGT V4' && ClientPrefs.noteStyleThing != 'Default') {
				texture = 'NOTE_assets_' + ClientPrefs.noteStyleThing.toLowerCase();
			}
			if(ClientPrefs.noteColorStyle == 'Quant-Based' || ClientPrefs.rainbowNotes) {
				texture = 'RED_NOTE_assets';
			}
			if(ClientPrefs.noteColorStyle == 'Char-Based') {
				texture = 'NOTE_assets_colored';
			}
			if(ClientPrefs.noteColorStyle == 'Grayscale') {
				texture = 'GRAY_NOTE_assets';
			}
			if (ClientPrefs.enableColorShader)
			{
					colorSwap = new ColorSwap();
					shader = colorSwap.shader;
					if (ClientPrefs.noteColorStyle == 'Normal' && !ClientPrefs.rainbowNotes)
					{
						colorSwap.hue = ClientPrefs.arrowHSV[noteData][0] / 360;
						colorSwap.saturation = ClientPrefs.arrowHSV[noteData][1] / 100;
						colorSwap.brightness = ClientPrefs.arrowHSV[noteData][2] / 100;
					}
					if (ClientPrefs.rainbowNotes)
					{
						colorSwap.hue = ((strumTime / 5000 * 360) / 360) % 1;
					}
				if (ClientPrefs.noteColorStyle == 'Char-Based')
				{
					if (PlayState.instance != null) {
 						if (!mustPress) this.shader = new ColoredNoteShader(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1], PlayState.instance.dad.healthColorArray[2], false, 10);
						if (mustPress) {
						this.shader = new ColoredNoteShader(PlayState.instance.boyfriend.healthColorArray[0], PlayState.instance.boyfriend.healthColorArray[1], PlayState.instance.boyfriend.healthColorArray[2], false, 10);
						}
						if (gfNote) {
						this.shader = new ColoredNoteShader(PlayState.instance.gf.healthColorArray[0], PlayState.instance.gf.healthColorArray[1], PlayState.instance.gf.healthColorArray[2], false, 10);
						}
					}
				}
			}
			}
			x += swagWidth * (noteData);
			if(!isSustainNote && noteData > -1 && noteData < 4) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = colArray[noteData % 4];
				animation.play(animToPlay + 'Scroll');
			}
		}
		// trace(prevNote);

		if(prevNote!=null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.downScroll) flipY = true;
			prevNoteIsSustainNote = prevNote.isSustainNote;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(colArray[noteData % 4] + 'holdend');
			if (ClientPrefs.showNotes)
			{
				if (ClientPrefs.noteColorStyle == 'Quant-Based')
				{
				colorSwap.hue = prevNote.colorSwap.hue;
				colorSwap.saturation = prevNote.colorSwap.saturation;
				colorSwap.brightness = prevNote.colorSwap.brightness;
				}

			updateHitbox();
			}

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(colArray[prevNote.noteData % 4] + 'hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
			centerOffsets();
			centerOrigin();
		}
		x += offsetX;
		if (ClientPrefs.noteColorStyle == 'Quant-Based') quantCheck();
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	public var correctionOffset:Float = 0; //dont mess with this
	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';

		var skin:String = texture;
		if(texture.length < 1) {
			if (PlayState.instance != null) skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;

				/*if(animName != null && !animName.endsWith('end'))
				{
					lastScaleY /= lastNoteScaleToo;
					lastNoteScaleToo = (6 / height);
					lastScaleY *= lastNoteScaleToo;
				}*/
			}
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			if(!isSustainNote)
			{
				centerOffsets();
				centerOrigin();
			}
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims() {
		animation.addByPrefix(colArray[noteData] + 'Scroll', colArray[noteData] + '0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold'); // ?????
			animation.addByPrefix(colArray[noteData] + 'holdend', colArray[noteData] + ' hold end');
			animation.addByPrefix(colArray[noteData] + 'hold', colArray[noteData] + ' hold piece');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			animation.add(colArray[noteData] + 'holdend', [pixelInt[noteData] + 4]);
			animation.add(colArray[noteData] + 'hold', [pixelInt[noteData]]);
		} else {
			animation.add(colArray[noteData] + 'Scroll', [pixelInt[noteData] + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult) || (PlayState.instance != null && PlayState.instance.cpuControlled))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function followStrumNote(myStrum:StrumNote, fakeCrochet:Float, songSpeed:Float = 1)
	{
		var strumX:Float = myStrum.x;
		var strumY:Float = myStrum.y;
		var strumAngle:Float = myStrum.angle;
		var strumAlpha:Float = myStrum.alpha;
		var strumDirection:Float = myStrum.direction;

		distance = (0.45 * (Conductor.songPosition - strumTime) * songSpeed * multSpeed);
		if (!myStrum.downScroll) distance *= -1;

						if(animation != null && animation.curAnim != null && animation.curAnim.name.endsWith('end'))
						{
							y -= height-2;
							if (!prevNoteIsSustainNote) //only for really short sustains that only have an end and no regular parts
							{
								y += height*0.25; //move back down slightly into the note
							}
						}

		if(copyScale && isSustainNote)
			//scale.set(myStrum.scale.x, myStrum.scale.y);
			if (!dumbHitboxThing)
				updateHitbox();

		var angleDir = strumDirection * Math.PI / 180;
		if (copyAngle)
			angle = strumDirection - 90 + strumAngle + offsetAngle;

		if(copyAlpha)
			alpha = strumAlpha * multAlpha;

		if(copyX)
			x = strumX + offsetX + Math.cos(angleDir) * distance;

		if(copyY)
		{
			y = strumY + offsetY + correctionOffset + Math.sin(angleDir) * distance;
			if(myStrum.downScroll && isSustainNote)
			{
				if(PlayState.isPixelStage)
				{
					y -= PlayState.daPixelZoom * 9.5;
				}
				y -= (frameHeight * scale.y) - (Note.swagWidth / 2);
			}
		}
	}

	public function clipToStrumNote(myStrum:StrumNote)
	{
		var center:Float = myStrum.y + offsetY + Note.swagWidth / 2;
		if(isSustainNote && (mustPress || !ignoreNote) &&
			(!mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit))))
		{
			var swagRect:FlxRect = clipRect;
			if(swagRect == null) swagRect = new FlxRect(0, 0, frameWidth, frameHeight);

			if (myStrum.downScroll)
			{
				if(y - offset.y * scale.y + height >= center)
				{
					swagRect.width = frameWidth;
					swagRect.height = (center - y) / scale.y;
					swagRect.y = frameHeight - swagRect.height;
				}
			}
			else if (y + offset.y * scale.y <= center)
			{
				swagRect.y = (center - y) / scale.y;
				swagRect.width = width / scale.x;
				swagRect.height = (height / scale.y) - swagRect.y;
			}
			clipRect = swagRect;
		}
	}
	public function updateRGBColors() {
        	if (Std.isOfType(this.shader, ColoredNoteShader))
		{
			if (mustPress)
	    			cast(this.shader, ColoredNoteShader).setColors(PlayState.instance.boyfriend.healthColorArray[0], PlayState.instance.boyfriend.healthColorArray[1], PlayState.instance.boyfriend.healthColorArray[2]);
	    		else if (!gfNote) cast(this.shader, ColoredNoteShader).setColors(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1], PlayState.instance.dad.healthColorArray[2]);
	    		else if (gfNote) cast(this.shader, ColoredNoteShader).setColors(PlayState.instance.gf.healthColorArray[0], PlayState.instance.gf.healthColorArray[1], PlayState.instance.gf.healthColorArray[2]);
		}
	}
}