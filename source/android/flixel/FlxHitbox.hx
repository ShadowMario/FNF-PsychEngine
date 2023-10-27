package android.flixel;

import android.flixel.FlxButton;
import openfl.utils.Assets;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

/**
 * A zone with 4 buttons (A hitbox).
 * It's easy to customize the layout.
 *
 * @author: Saw (M.A. Jigsaw)
 */
class FlxHitbox extends FlxSpriteGroup {
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);

	/**
	 * Create the zone.
	 */
	public function new() {
		super();

		var buttonLeftColor:Array<FlxColor>;
		var buttonDownColor:Array<FlxColor>;
		var buttonUpColor:Array<FlxColor>;
		var buttonRightColor:Array<FlxColor>;
		if (ClientPrefs.dynamicColors) { //bri'ish type option
			buttonLeftColor = ClientPrefs.arrowHSV[0];
			buttonDownColor = ClientPrefs.arrowHSV[1];
			buttonUpColor = ClientPrefs.arrowHSV[2];
			buttonRightColor = ClientPrefs.arrowHSV[3];
		} else {
			buttonLeftColor = ClientPrefs.arrowHSV[0];
			buttonDownColor = ClientPrefs.arrowHSV[1];
			buttonUpColor = ClientPrefs.arrowHSV[2];
			buttonRightColor = ClientPrefs.arrowHSV[3];
		}

		scrollFactor.set();

		add(buttonLeft = createHint(0, 0, 'left', buttonLeftColor[0]));
		add(buttonDown = createHint(FlxG.width / 4, 0, 'down', buttonDownColor[0]));
		add(buttonUp = createHint(FlxG.width / 2, 0, 'up', buttonUpColor[0]));
		add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, 'right', buttonRightColor[0]));
	}

	/**
	 * Clean up memory.
	 */
	override function destroy() {
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
	}

	private function createHint(X:Float, Y:Float, Graphic:String, Color:Int = 0xFFFFFF):FlxButton {
		var hintTween:FlxTween = null;
		var hint:FlxButton = new FlxButton(X, Y);
		hint.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/android/hitbox.png'),
			Assets.getText('assets/android/hitbox.xml'))
			.getByName(Graphic)));
		hint.setGraphicSize(Std.int(FlxG.width / 4), FlxG.height);
		hint.updateHitbox();
		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.color = Color;
		hint.alpha = 0.00001;
		hint.onDown.callback = hint.onOver.callback = function() {
			if (hint.alpha != ClientPrefs.hitboxAlpha)
				hint.alpha = ClientPrefs.hitboxAlpha;
		}
		hint.onUp.callback = hint.onOut.callback = function() {
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		hint.onOver.callback = hint.onDown.callback;
		hint.onOut.callback = hint.onUp.callback;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}
