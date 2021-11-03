package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;

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
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	private var earlyHitMult:Float = 0.5;

	public static var swagWidth(get, null):Float;

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

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private static function get_swagWidth() {
		return 160 * NoteGraphic.getScale();
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[NoteGraphic.convertForKeys(noteData) % PlayState.SONG.songKeys][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[NoteGraphic.convertForKeys(noteData) % PlayState.SONG.songKeys][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[NoteGraphic.convertForKeys(noteData) % PlayState.SONG.songKeys][2] / 100;

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'No Animation':
					noAnimation = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50 - NoteGraphic.getOffset();
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		var animToPlay:String = NoteGraphic.fromIndex(noteData % PlayState.SONG.songKeys);
		trace(strumTime + "Note: " + animToPlay + " Data: " + noteData);
		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % PlayState.SONG.songKeys);
			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(animToPlay + 'holdend');

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(NoteGraphic.fromIndex(prevNote.noteData % PlayState.SONG.songKeys) + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05 * PlayState.SONG.speed;
				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
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
		}
		x += offsetX;
	}

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
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
		var notePath:String = arraySkin.join('/');
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + notePath + 'ENDS'));
				width = width / 9;
				height = height / 2;
				loadGraphic(Paths.image('pixelUI/' + notePath + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + notePath));
				width = width / 9;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + notePath), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;
		} else {
			frames = Paths.getSparrowAtlas(notePath);
			loadNoteAnims();
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
		var color:String = "";
		for (e in Type.allEnums(Color)) {
			color = NoteGraphic.fromColor(e);
			animation.addByPrefix(color + 'Scroll', color + '0');
			animation.addByPrefix(color + 'hold', color + ' hold piece');
			animation.addByPrefix(color + 'holdend', color + ' hold end');
		}
		setGraphicSize(Std.int(width * NoteGraphic.getScale()));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		var color:String = "";
		var i:Int = 0;
		for (e in Type.allEnums(Color)) {
			i = NoteGraphic.ColorToInt(e);
			color = NoteGraphic.fromColor(e);
			animation.add(color + 'Scroll', [i + 9]);
			animation.add(color + 'holdend', [i + 9]);
			animation.add(color + 'hold', [i]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
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

enum Color {
	purple;
	blue;
	green;
	red;
	grey;
	yellow;
	sapphire;
	crimson;
	violet;
}

class NoteGraphic {

	private static var keySet:Array<Dynamic> = [
		[0, 1, 2, 3],				// 4
		[0, 1, 4, 2, 3],			// 5
		[0, 1, 3, 5, 7, 8],			// 6
		[0, 1, 3, 4, 5, 7, 8],		// 7
		[0, 1, 2, 3, 5, 6, 7, 8],	// 8
		[0, 1, 2, 3, 4, 5, 6, 7, 8]	// 9
	];

	private static var direction:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP'];

	private static var widths:Array<Int> = [
		160,  // 4
		160,  // 5
		120, // 6
		110, // 7
		110, // 8
		90  // 9
	];

	private static var offsets:Array<Int> = [
		0,  // 4
		0,  // 5
		35, // 6
		70, // 7
		80, // 8
		90  // 9
	];

	private static var scales:Array<Float> = [
		0.70, // 4
		0.65, // 5
		0.60, // 6
		0.55, // 7
		0.45, // 8
		0.43  // 9
	];

	public static function getScale() {
		return scales[PlayState.SONG.songKeys - 4];
	}

	public static function getWidth() {
		return widths[PlayState.SONG.songKeys - 4];
	}

	public static function getOffset() {
		return offsets[PlayState.SONG.songKeys - 4];
	}

	public static function getDirection(i: Int) {
		return direction[convertForKeys(i) % 5];
	}

	public static function convertForKeys(i: Int) {
		return keySet[PlayState.SONG.songKeys - 4][i];
	}

	public static function fromIndex(i: Int) {
		return fromColor(IntToColor(convertForKeys(i)));
	}

	public static function fromIndexWithoutConvert(i: Int) {
		return fromColor(IntToColor(i));
	}

	public static function fromColor(c: Color) {
		return switch(c) {
			case Color.purple: 'purple';
			case Color.blue: 'blue';
			case Color.green: 'green';
			case Color.red: 'red';
			case Color.grey: 'grey';
			case Color.yellow: 'yellow';
			case Color.sapphire: 'sapphire';
			case Color.crimson: 'crimson';
			case Color.violet: 'violet';
		}
	}

	public static function ColorToInt(c: Color) {
		return switch(c) {
			case purple: 0;
			case blue: 1;
			case green: 2;
			case red: 3;
			case grey: 4;
			case yellow: 5;
			case sapphire: 6;
			case crimson: 7;
			case violet: 8;
		}
	}

	public static function IntToColor(i: Int) {
		return switch(i) {
			case 0: purple;
			case 1: blue;
			case 2: green;
			case 3: red;
			case 4: grey;
			case 5: yellow;
			case 6: sapphire;
			case 7: crimson;
			case 8: violet;
			default: grey;
		}
	}
}