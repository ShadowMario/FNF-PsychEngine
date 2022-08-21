package charter;

import Note.NoteDirection;
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

class CharterNote extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;


	public var noteScore:Float = 1;

	public var noteType:Int = 0;
	public var newCharter:Bool = false;

	public static var swagWidth(get, null):Float;
	public static function get_swagWidth():Float {
		return _swagWidth * widthRatio;
	}
	public static var widthRatio(get, null):Float;
	static function get_widthRatio():Float {
		return Math.min(1, 5 / (ChartingState_New._song.keyNumber == null ? 5 : ChartingState_New._song.keyNumber));
	}
	public static var _swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public static var noteTypes:Array<hscript.Expr> = [];
	public var script(get, null):Script;
	public var sustainSprite:FlxSprite;

	public function get_script():Script {
		return PlayState.current.noteScripts[noteType % PlayState.current.noteScripts.length];
	}

	

	public static var noteNumberScheme(get, null):Array<NoteDirection>;
	public static function get_noteNumberScheme():Array<NoteDirection> {
		var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[ChartingState_New._song.keyNumber];
		if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];
		return noteNumberScheme;
	}

	public function createNote() {
		switch(noteType) {
			case -1:
				// PSYCH ENGINE EVENT NOTE!!!!!!!! (lol why are ppl asking this)
                frames = Paths.getSparrowAtlas('events', 'shared');
                animation.addByPrefix('PSYCH EVENT!!!!!', 'psych event');
                animation.addByPrefix('YOSHI ENGINE EVENT!!!!!!', 'event');
                antialiasing = true;

			default:
                frames = Paths.getSparrowAtlas('NOTE_assets_charter', 'shared');

                animation.addByPrefix('greenScroll', 'green0');
                animation.addByPrefix('redScroll', 'red0');
                animation.addByPrefix('blueScroll', 'blue0');
                animation.addByPrefix('purpleScroll', 'purple0');

                animation.addByPrefix('purpleholdend', 'pruple end hold');
                animation.addByPrefix('greenholdend', 'green hold end');
                animation.addByPrefix('redholdend', 'red hold end');
                animation.addByPrefix('blueholdend', 'blue hold end');

                animation.addByPrefix('purplehold', 'purple hold piece');
                animation.addByPrefix('greenhold', 'green hold piece');
                animation.addByPrefix('redhold', 'red hold piece');
                animation.addByPrefix('bluehold', 'blue hold piece');

                setGraphicSize(Std.int(width * 0.7));
                updateHitbox();
                antialiasing = true;
		}
		scale.x *= swagWidth / _swagWidth;
		if (!isSustainNote) {
			scale.y *= swagWidth / _swagWidth;
		}
	}
	public var noteOffset:FlxPoint = new FlxPoint(0,0);
	public var enableRating:Bool = true;
	public var state:YoshiCrafterCharter = null;
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?mustHit = true, ?sustainLength:Float = 0)
	{
		super();

		var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[ChartingState_New._song.keyNumber];
		if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		newCharter = Std.isOfType(FlxG.state, YoshiCrafterCharter);
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		this.noteType = Math.floor(noteData / ChartingState_New._song.keyNumber / 2);

		scale.x *= swagWidth / _swagWidth;
		if (!isSustainNote) {
			scale.y *= swagWidth / _swagWidth;
		}

        createNote();
		
		if (noteType < 0) {
			if (noteData == -1)
				animation.play("PSYCH EVENT!!!!!");
			else
				animation.play("YOSHI ENGINE EVENT!!!!!!");
		} else {
			switch (noteNumberScheme[noteData % noteNumberScheme.length])
			{
				case Left:
					animation.play('purpleScroll');
				case Down:
					animation.play('blueScroll');
				case Up:
					animation.play('greenScroll');
				case Right:
					animation.play('redScroll');
			}
		}

		if (isSustainNote)
		{
			noteScore * 0.2;
			alpha = 0.6;

			noteOffset.x += width / 2;
			switch (noteNumberScheme[noteData % noteNumberScheme.length])
			{
				case Left:
					animation.play('purpleholdend');
				case Down:
					animation.play('blueholdend');
				case Up:
					animation.play('greenholdend');
				case Right:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;
			flipY = Settings.engineSettings.data.downscroll;
			if (prevNote != null) {
				if (prevNote.isSustainNote)
				{
					prevNote.flipY = false;
					switch (noteNumberScheme[prevNote.noteData % noteNumberScheme.length])
					{
						case Left:
							prevNote.animation.play('purplehold');
						case Down:
							prevNote.animation.play('bluehold');
						case Up:
							prevNote.animation.play('greenhold');
						case Right:
							prevNote.animation.play('redhold');
					}

					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * (Settings.engineSettings.data.customScrollSpeed ? Settings.engineSettings.data.scrollSpeed : ChartingState_New._song.speed);
					prevNote.updateHitbox();
			
					if (Settings.engineSettings.data.downscroll) {
						prevNote.offset.y = prevNote.height / 2;
					}
				}
			}
			offset.y = height / 2;
		}

		this.sustainLength = sustainLength;
		if (newCharter) {
			state = cast(FlxG.state, YoshiCrafterCharter);
			sustainSprite = new FlxSprite(0, 0).makeGraphic(10, YoshiCrafterCharter.GRID_SIZE, 0xFFFFFFFF, true);
			state.add(sustainSprite);

			updateSustain();
		}
	}

	public function updateSustain() {
		if (newCharter) {
			sustainSprite.visible = sustainLength > Conductor.stepCrochet;
			sustainSprite.setGraphicSize(10, Std.int(state.getYForTime(strumTime + sustainLength) - state.getYForTime(strumTime)));
			// sustainSprite.setGraphicSize(10, Std.int(Math.max(1, sustainLength / Conductor.stepCrochet * YoshiCrafterCharter.GRID_SIZE) * state.zoom) - YoshiCrafterCharter.GRID_SIZE);
			sustainSprite.updateHitbox();
		}
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sustainSprite != null) {
			sustainSprite.x = x + (width / 2) - (sustainSprite.width / 2);
			// accurate
			sustainSprite.y = y + (YoshiCrafterCharter.GRID_SIZE / 2);
			sustainSprite.alpha = alpha;
		}
		// legacy support
		if (!newCharter) alpha = (strumTime <= Conductor.songPosition) ? 0.3 : 1;
	}

	public override function destroy() {
		if (sustainSprite != null) {
			sustainSprite.destroy();
			state.remove(sustainSprite);
		}
		super.destroy();
	}
}
