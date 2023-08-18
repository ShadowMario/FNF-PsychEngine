package mobile.flixel;

import openfl.display.Shape;
import openfl.display.BitmapData;
import mobile.flixel.FlxButton;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author: Saw (M.A. Jigsaw)
 */
class FlxHitbox extends FlxSpriteGroup
{
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);
	public var buttonExtra:FlxButton = new FlxButton(0, 0);
	public var buttonExtra1:FlxButton = new FlxButton(0, 0);

	/**
	 * Create the zone.
	 */
	 
	public function new(mode:Modes)
	{
		super();
		#if mobileC

		final offsetFir:Int = (ClientPrefs.data.hitbox2 ? Std.int(FlxG.height / 4) * 3 : 0);
		final offsetSec:Int = (ClientPrefs.data.hitbox2 ? 0 : Std.int(FlxG.height / 4));
		var buttonLeftColor:Array<FlxColor>;
		var buttonDownColor:Array<FlxColor>;
		var buttonUpColor:Array<FlxColor>;
		var buttonRightColor:Array<FlxColor>;
		if (ClientPrefs.data.dynamicColors && MusicBeatState.instance.mobileControls != null){
			buttonLeftColor = ClientPrefs.data.arrowRGB[0];
			buttonDownColor = ClientPrefs.data.arrowRGB[1];
			buttonUpColor = ClientPrefs.data.arrowRGB[2];
			buttonRightColor = ClientPrefs.data.arrowRGB[3];
		} else{
			buttonLeftColor = ClientPrefs.defaultData.arrowRGB[0];
			buttonDownColor = ClientPrefs.defaultData.arrowRGB[1];
			buttonUpColor = ClientPrefs.defaultData.arrowRGB[2];
			buttonRightColor = ClientPrefs.defaultData.arrowRGB[3];
		}

		switch (mode)
		{
			case DEFAULT:
				add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, buttonLeftColor[0]));
				add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, buttonDownColor[0]));
				add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, buttonUpColor[0]));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, buttonRightColor[0]));
			case SINGLE:
				add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonLeftColor[0]));
				add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonDownColor[0]));
				add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonUpColor[0]));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonRightColor[0]));
				add(buttonExtra = createHint(0, offsetFir, FlxG.width, Std.int(FlxG.height / 4), 0xFF0066FF));
			case DOUBLE:
				add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonLeftColor[0]));
				add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonDownColor[0]));
				add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonUpColor[0]));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, buttonRightColor[0]));
				add(buttonExtra = createHint(Std.int(FlxG.width / 2), offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xFF0066FF));
				add(buttonExtra1 = createHint(0, offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0x00FFF7));
			
		}

		scrollFactor.set();
		#end
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
		buttonExtra = null;
		buttonExtra1 = null;
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF):BitmapData
	{
		var shape:Shape = new Shape();

			shape.graphics.beginFill(Color);
			shape.graphics.lineStyle(3, Color, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [0.6, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):FlxButton
	{
		var hintTween:FlxTween = null;
		var hint:FlxButton = new FlxButton(X, Y);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));
		hint.solid = false;
		hint.immovable = true;
		hint.multiTouch = true;
		hint.moves = false;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.onDown.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: MobileControls.getOpacity()}, MobileControls.getOpacity() / 100, {
				ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					hintTween = null;
				}
			});
		}
		hint.onUp.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: 0.00001}, MobileControls.getOpacity() / 10, {
				ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					hintTween = null;
				}
			});
		}
		hint.onOut.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: 0.00001}, MobileControls.getOpacity() / 10, {
				ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					hintTween = null;
				}
			});
		}
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
enum Modes
{
	DEFAULT;
	SINGLE;
	DOUBLE;
}
