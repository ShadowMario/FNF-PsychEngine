package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		if(PlayState.isPixelStage) {
			setPosition(x + 30, (y + Note.swagWidth) / 2);
		} else {
			setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		}
		alpha = 0.6;

		if(texture == null) {
			texture = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		if(PlayState.isPixelStage) {
			loadGraphic(Paths.image('pixelUI/' + skin));
			width = width / 8;
			height = height / 4;
			loadGraphic(Paths.image('pixelUI/' + skin), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add("note0-1", [0, 1, 2, 3], 12, false);
			animation.add("note0-2", [4, 5, 6, 7], 12, false);
			animation.add("note1-1", [8, 9, 10, 11], 12, false);
			animation.add("note1-2", [12, 13, 14, 15], 12, false);
			animation.add("note2-1", [16, 17, 18, 19], 12, false);
			animation.add("note2-2", [20, 21, 22, 23], 12, false);
			animation.add("note3-1", [24, 25, 26, 27], 12, false);
			animation.add("note3-2", [28, 29, 30, 31], 12, false);
		} else {
			frames = Paths.getSparrowAtlas(skin);
			setGraphicSize(Std.int(1, 1));
			for (i in 1...3) {
				animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
				animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
				animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
				animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
			}
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}
