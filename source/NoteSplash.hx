package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var curStage:String = PlayState.curStage;
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		switch (curStage) {
			case 'arena' | 'temple': {
				frames = Paths.getSparrowAtlas('noteSplashes_violastro');
				animation.addByPrefix("note1-0", "note splash sparkle yellow", 24, false);
				animation.addByPrefix("note2-0", "note splash sparkle red", 24, false);
				animation.addByPrefix("note0-0", "note splash sparkle green", 24, false);
				animation.addByPrefix("note3-0", "note splash sparkle blue", 24, false);
				animation.addByPrefix("note1-1", "note splash sparkle yellow", 24, false);
				animation.addByPrefix("note2-1", "note splash sparkle red", 24, false);
				animation.addByPrefix("note0-1", "note splash sparkle green", 24, false);
				animation.addByPrefix("note3-1", "note splash sparkle blue", 24, false);
			}
			default: {
				frames = Paths.getSparrowAtlas('noteSplashes_default');
				animation.addByPrefix("note1-0", "note splash blue 1", 24, false);
				animation.addByPrefix("note2-0", "note splash green 1", 24, false);
				animation.addByPrefix("note0-0", "note splash purple 1", 24, false);
				animation.addByPrefix("note3-0", "note splash red 1", 24, false);
				animation.addByPrefix("note1-1", "note splash blue 2", 24, false);
				animation.addByPrefix("note2-1", "note splash green 2", 24, false);
				animation.addByPrefix("note0-1", "note splash purple 2", 24, false);
				animation.addByPrefix("note3-1", "note splash red 2", 24, false);
			}
		}

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, ?note:Int = 0) {
		setPosition(x, y);
		alpha = 0.6;
		animation.play('note' + note + '-' + FlxG.random.int(0, 1), true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		updateHitbox();
		offset.set(Std.int(0.3 * width), Std.int(0.35 * height));
		if(colorSwap == null) {
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
		}
		for (i in 0...3) {
			colorSwap.update(ClientPrefs.arrowHSV[note % 4][i], i);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim.finished) kill();
		super.update(elapsed);
	}
}