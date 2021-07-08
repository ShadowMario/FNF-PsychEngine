package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;

	public function new(x:Float, y:Float, leData:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		colorSwap.update(0);
		noteData = leData;
		super(x, y);
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		if(animation.curAnim.name == 'static') {
			for (i in 0...3) {
				colorSwap.update(0, i);
			}
		} else {
			for (i in 0...3) {
				colorSwap.update(ClientPrefs.arrowHSV[noteData][i], i);
			}
			if(animation.curAnim.name == 'confirm' && !PlayState.curStage.startsWith('school')) {
				offset.x -= 13;
				offset.y -= 13;
			}
		}
	}
}
