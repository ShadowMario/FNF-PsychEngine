package mobile.flixel;

import mobile.flixel.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup;
import openfl.utils.Assets;

/**
 * A zone with 4 buttons (A hitbox).
 * It's easy to customize the layout.
 *
 * @author: Saw (M.A. Jigsaw)
 */
class FlxHitbox extends FlxSpriteGroup
{
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);

	/**
	 * Create the zone.
	 */
	public function new()
	{
		super();

		scrollFactor.set();

		add(buttonLeft = createHint(0, 0, 'left', 0xFF00FF));
		add(buttonDown = createHint(FlxG.width / 4, 0, 'down', 0x00FFFF));
		add(buttonUp = createHint(FlxG.width / 2, 0, 'up', 0x00FF00));
		add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, 'right', 0xFF0000));
	}

	/**
	 * Clean up memory.
	 */
	override function destroy()
	{
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
	}

	private function createHint(X:Float, Y:Float, Graphic:String, Color:Int = 0xFFFFFF):FlxButton
	{
		var hintTween:FlxTween = null;
		var hint:FlxButton = new FlxButton(X, Y);
		hint.loadGraphic(FlxGraphic.fromFrame(FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/mobile/hitbox.png'),
			Assets.getText('assets/mobile/hitbox.xml'))
			.getByName(Graphic)));
		hint.setGraphicSize(Std.int(FlxG.width / 4), FlxG.height);
		hint.updateHitbox();
		hint.solid = false;
		hint.multiTouch = true;
		hint.immovable = true;
		hint.moves = false;
		hint.scrollFactor.set();
		hint.color = Color;
		hint.alpha = 0.00001;
		hint.onDown.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: MobileControls.getOpacity()}, 0.001, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
			{
				hintTween = null;
			}});
		}
		hint.onUp.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: 0.00001}, 0.001, {ease: FlxEase.circInOut,	onComplete: function(twn:FlxTween)
			{
				hintTween = null;
			}});
		}
		hint.onOver.callback = hint.onDown.callback;
		hint.onOut.callback = hint.onUp.callback;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}

	/*
	* Checks if the hitbox is pressed, if yes returns true.
	*/
	public function mobileControlsPressed(buttonID:FlxMobileControlsID):Bool
		{
			switch (buttonID)
			{
				case FlxMobileControlsID.hitboxLEFT:
					return buttonLeft.pressed;
				case FlxMobileControlsID.hitboxUP:
					return buttonUp.pressed;
				case FlxMobileControlsID.hitboxRIGHT:
					return buttonRight.pressed;
				case FlxMobileControlsID.hitboxDOWN:
					return buttonDown.pressed;
				case FlxMobileControlsID.NONE:
					return false;
				default:
					return false;
			}
		}

		/*
		* Checks if the hitbox is justPressed, if yes returns true.
		*/
		public function mobileControlsJustPressed(buttonID:FlxMobileControlsID):Bool
			{
				switch (buttonID)
				{
				case FlxMobileControlsID.hitboxLEFT:
					return buttonLeft.justPressed;
					trace("left was justpressed on the hitbox!");
				case FlxMobileControlsID.hitboxUP:
					return buttonUp.justPressed;
				case FlxMobileControlsID.hitboxRIGHT:
					return buttonRight.justPressed;
				case FlxMobileControlsID.hitboxDOWN:
					return buttonDown.justPressed;
				case FlxMobileControlsID.NONE:
					return false;
				default:
					return false;
				}
			}

	/*
	* Checks if the hitbox is justReleased, if yes returns true.
	*/
	public function mobileControlsJustReleased(buttonID:FlxMobileControlsID):Bool
		{
			switch (buttonID)
			{
				case FlxMobileControlsID.hitboxLEFT:
					return buttonLeft.justReleased;
				case FlxMobileControlsID.hitboxUP:
					return buttonUp.justReleased;
				case FlxMobileControlsID.hitboxRIGHT:
					return buttonRight.justReleased;
				case FlxMobileControlsID.hitboxDOWN:
					return buttonDown.justReleased;
				case FlxMobileControlsID.NONE:
					return false;
				default:
					return false;
					}
				}
}
