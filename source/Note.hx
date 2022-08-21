package;

import flixel.math.FlxRect;
import NoteShader.ColoredNoteShader;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.display.BitmapData;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

enum NoteType {
	Normal;
}

enum abstract NoteDirection(Int) {
	var Left = 0;
	var Down = 1;
	var Up = 2;
	var Right = 3;
}

enum abstract NoteAppearance(Int) {
	var Left = 0;
	var Down = 1;
	var Up = 2;
	var Right = 3;
	var DoubleLeft = 4;
	var DoubleRight = 5;
	var Square = 6;
	var Plus = 7;
}
class Note extends FlxSprite
{
	@:allow(PlayState)
	private var __renderAlpha:Float = 1;
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var hitOnBotplay:Bool = true;

	public var noteScore:Float = 1;

	public var maxEarlyDiff:Float = 125; //ms
	public var maxLateDiff:Float = 90; //ms
	public var missDiff:Float = 250; //ms

	public var noteType:Int = 0;

	public var colored:Bool = false;
	public var prevSusNote:Note = null;

	public var sustainHealth:Float = 0.008;

	public var cpuLightStrum:Bool = true;
	public var cpuIgnore:Bool = false;

	public var splash:String = Paths.splashes('splashes', "shared");
	public var coloredSplash:Null<Bool> = null;

	public var section:Int = -1;

	public static var swagWidth(get, null):Float;
	public static function get_swagWidth():Float {
		return _swagWidth * widthRatio;
	}
	public static var widthRatio(get, null):Float;
	static function get_widthRatio():Float {
		var nScale = 1;
		var middlescroll = false;
		if (PlayState.current != null) {
			middlescroll = PlayState.current.engineSettings.middleScroll;
		}
		return Math.min(1, (middlescroll ? 10 : 5) / ((PlayState.SONG.keyNumber == null ? (middlescroll ? 10 : 5) : PlayState.SONG.keyNumber) * nScale));
	}
	public static var _swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public static var noteTypes:Array<hscript.Expr> = [];
	public var script(get, null):Script;
	public function get_script():Script {
		return PlayState.current.noteScripts[noteType % PlayState.current.noteScripts.length];
	}

	public static var noteNumberSchemes:Map<Int, Array<NoteDirection>> = [
		1 => [Up],
		2 => [Left, Right],
		3 => [Left, Up, Right],
		4 => [Left, Down, Up, Right],
		5 => [Left, Down, Up, Up, Right],
		6 => [Left, Up, Right, Left, Down, Right], // shaggy
		7 => [Left, Up, Right, Up, Left, Down, Right],
		8 => [Left, Down, Up, Right, Left, Down, Up, Right],
		9 => [Left, Down, Up, Right, Up, Left, Down, Up, Right],
		10 => [Left, Down, Up, Right, Up, Up, Left, Down, Up, Right]
	];

	public static var noteAppearanceSchemes:Map<Int, Array<NoteAppearance>> = [
		1 => [Up],
		2 => [Left, Right],
		3 => [Left, Up, Right],
		4 => [Left, Down, Up, Right],
		5 => [Left, Down, Square, Up, Right],
		6 => [Left, Up, Right, Left, Down, Right], // shaggy
		7 => [Left, Up, Right, Square, Left, Down, Right],
		8 => [Left, Down, Up, Right, Left, Down, Up, Right],
		9 => [Left, Down, Up, Right, Square, Left, Down, Up, Right],
		10 => [Left, Down, Up, Right, DoubleLeft, DoubleRight, Left, Down, Up, Right],
		11 => [Left, Down, Up, Right, DoubleLeft, Square, DoubleRight, Left, Down, Up, Right]
	];

	public static var noteNumberScheme(get, null):Array<NoteDirection>;
	public static var noteAppearanceScheme(get, null):Array<NoteAppearance>;

	public var noteDirection(get, null):Int;
	public function get_noteDirection():Int {
		var e = noteNumberSchemes[PlayState.SONG.keyNumber];
		if (e != null) {
			return cast e[noteData % PlayState.SONG.keyNumber];
		} else {
			return noteData % 4;
		}
	}

	public var appearance(get, null):NoteAppearance;
	public function get_appearance():NoteAppearance {
		var e = noteAppearanceSchemes[PlayState.SONG.keyNumber];
		if (e != null) {
			return cast e[noteData % PlayState.SONG.keyNumber];
		} else {
			return cast noteData % 4;
		}
	}
	public static function get_noteNumberScheme():Array<NoteDirection> {
		var noteNumberScheme:Array<NoteDirection> = noteNumberSchemes[PlayState.SONG.keyNumber];
		if (noteNumberScheme == null) noteNumberScheme = noteNumberSchemes[4];
		return noteNumberScheme;
	}
	public static function get_noteAppearanceScheme():Array<NoteAppearance> {
		var noteAppearanceScheme:Array<NoteAppearance> = noteAppearanceSchemes[PlayState.SONG.keyNumber];
		if (noteAppearanceScheme == null) noteAppearanceScheme = noteAppearanceSchemes[4];
		return noteAppearanceScheme;
	}

	public override function destroy() {
		super.destroy();
	}
	public function createNote() {
		scale.x *= swagWidth / _swagWidth;
		if (!isSustainNote) {
			scale.y *= swagWidth / _swagWidth;
		}
	}
	public var noteOffset:FlxPoint = new FlxPoint(0,0);
	public var enableRating:Bool = true;
	public var altAnim:Bool = false;
	public var engineSettings:Dynamic;
	public var splashColor:FlxColor = 0xFFFFFFFF;
	public var isLongSustain:Bool = false;

	public var stepLength:Float = 0;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?mustHit = true, ?altAnim = false, ?stepLength:Float)
	{
		super();
		if (stepLength == null) stepLength = Conductor.stepCrochet;
		this.stepLength = stepLength;
		
		this.altAnim = altAnim;
		engineSettings = Settings.engineSettings.data;
		if (PlayState.current != null) engineSettings = PlayState.current.engineSettings;

		var noteNumberScheme:Array<NoteDirection> = noteNumberSchemes[PlayState.SONG.keyNumber];
		if (noteNumberScheme == null) noteNumberScheme = noteNumberSchemes[4];

		this.mustPress = mustHit;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		if 		  (PlayState.SONG.keyNumber <= 4) {
			x += 50;
		} else if (PlayState.SONG.keyNumber == 5) {
			x += 30;
		} else if (PlayState.SONG.keyNumber >= 6) {
			x += 10;
		}
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;
		noteType = Math.floor(noteData / (PlayState.SONG.keyNumber * 2));

		var daStage:String = PlayState.curStage;

		script.setVariable("note", this);
		script.executeFunc("create");
		if (isSustainNote) {
			if (prevNote != null)
				if (prevNote.animation.curAnim != null)
					if (prevNote.animation.curAnim.name == "holdend")
						prevNote.animation.play("holdpiece");
			animation.play("holdend");
		} else {
			animation.play("scroll");
		}

		if (colored) {
			if (Settings.engineSettings.data.rainbowNotes == true) {
				var superCoolColor = new FlxColor(0xFFFF0000);
				superCoolColor.hue = (strumTime / 5000 * 360) % 360;
				this.shader = new ColoredNoteShader(superCoolColor.red, superCoolColor.green, superCoolColor.blue);
				this.splashColor = superCoolColor;
				

			} else {
				var charColors = (mustPress || engineSettings.customArrowColors_allChars) ? PlayState.current.boyfriend : PlayState.current.dad;
				var customColors:Array<FlxColor> = charColors == null ? [0, PlayState.current.engineSettings.arrowColor0, PlayState.current.engineSettings.arrowColor1, PlayState.current.engineSettings.arrowColor2, PlayState.current.engineSettings.arrowColor3] : charColors.getColors(altAnim);
				var c = customColors[((noteData % PlayState.SONG.keyNumber) % (customColors.length - 1)) + 1];
				this.shader = new ColoredNoteShader(c.red, c.green, c.blue);
				this.splashColor = c;
			}
		} else {
			this.shader = new ColoredNoteShader(255, 255, 255);
			cast(this.shader, ColoredNoteShader).enabled.value = [false];
		}

		scale.x *= swagWidth / _swagWidth;
		if (!isSustainNote) {
			scale.y *= swagWidth / _swagWidth;
		}

		x += swagWidth * (noteData % PlayState.SONG.keyNumber);

		if (isSustainNote)
		{
			noteScore * 0.2;
			alpha = 0.6;
			noteOffset.x += width / 2;
			updateHitbox();
			
			flipY = engineSettings.downscroll;
			if (prevNote != null) {
				if (prevNote.isSustainNote)
				{
					prevNote.flipY = false;

					prevNote.scale.y *= stepLength / 100 * 1.5 * (engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : PlayState.SONG.speed);
					prevNote.updateHitbox();
					prevNote.isLongSustain = true;	

					if (engineSettings.downscroll) {
						prevNote.offset.y = prevNote.height / 2;
					}
				}
			}
			offset.y += height / 4 * (engineSettings.downscroll ? 1 : -1);
		}
	}

	override function draw() {
		if (shader is ColoredNoteShader) {
			var shader:ColoredNoteShader = cast this.shader;
			shader.frameOffset.value = [frame.frame.left, frame.frame.top];
		}

		var oldAlpha = alpha;
		alpha *= __renderAlpha;
		super.draw();
		alpha = oldAlpha;
	}

	public function setClipRect(rect:FlxRect) {
		if (shader is ColoredNoteShader) {
			var shader:ColoredNoteShader = cast this.shader;
			shader.clipRect.value = [rect.x, rect.y, rect.width, rect.height];
		} else {
			clipRect = rect;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		script.setVariable("note", this);
		script.executeFunc("update", [elapsed]);
		if (mustPress)
		{
			
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
