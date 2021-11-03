package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import Note;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;

	private var player:Int;

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + skin));
			width = width / 9;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + skin), true, Math.floor(width), Math.floor(height));
			var color:String = "";
			for (e in Type.allEnums(Color)) {
				var i:Int = NoteGraphic.ColorToInt(e);
				color = NoteGraphic.fromColor(e);
				animation.add(color, [9 + i]);
			}

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			var laData = NoteGraphic.convertForKeys(leData);

			animation.add('static', [laData]);
			animation.add('pressed', [9 + laData, 18 + laData], 12, false);
			animation.add('confirm', [27 + laData, 36 + laData], 24, false);
		}
		else
		{
			frames = Paths.getSparrowAtlas(skin);
			var direction = NoteGraphic.getDirection(leData);
			animation.addByPrefix(NoteGraphic.fromIndex(leData), 'arrow' + direction);
			if(NoteGraphic.convertForKeys(leData) == 4) animation.addByPrefix('static', 'arrowSPACE');
			else animation.addByPrefix('static', 'arrow' + direction);

			antialiasing = ClientPrefs.globalAntialiasing;
			setGraphicSize(Std.int(width * NoteGraphic.getScale()));

			animation.addByPrefix('pressed', NoteGraphic.fromIndex(leData) + ' press', 24, false);
			animation.addByPrefix('confirm', NoteGraphic.fromIndex(leData) + ' confirm', 24, false);
		}

		updateHitbox();
		scrollFactor.set();
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		x -= NoteGraphic.getOffset();
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		
		/*if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
			updateConfirmOffset();
		}*/

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % PlayState.SONG.songKeys][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % PlayState.SONG.songKeys][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % PlayState.SONG.songKeys][2] / 100;

			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				updateConfirmOffset();
			}
		}
	}

	function updateConfirmOffset() { //TO DO: Find a calc to make the offset work fine on other angles
		centerOffsets();
		offset.x -= 13;
		offset.y -= 13;
	}
}
