package android.flixel;

import android.flixel.FlxButton;
import android.flixel.FlxHitbox;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class FlxHitboxHint extends FlxButton
{
	var orgHitbox:FlxHitbox;

	public function new(x:Float = 0, y:Float = 0, frames:String)
	{
		super(x, y);

		if (ClientPrefs.visibleHints)
		{
			loadGraphic(FlxGraphic.fromFrame(getFrames().getByName(frames + '_hint')));
			alpha = 0.75;

			#if FLX_DEBUG
			ignoreDrawDebug = true;
			#end
		}
		else
		{
			loadGraphic(FlxGraphic.fromFrame(getFrames().getByName(frames)));

			setGraphicSize(orgHitbox.sizex, orgHitbox.sizey);
			updateHitbox();

			alpha = 0.00001;

			var tween:FlxTween = null;

			button.onDown.callback = function()
			{
				if (tween != null)
					tween.cancel();

				tween = FlxTween.num(alpha, 0.75, 0.075, {ease: FlxEase.circInOut}, function(value:Float)
				{
					alpha = value;
				});
			}

			button.onUp.callback = function()
			{
				if (tween != null)
					tween.cancel();

				tween = FlxTween.num(alpha, 0.00001, 0.15, {ease: FlxEase.circInOut}, function(value:Float)
				{
					alpha = value;
				});
			}

			button.onOut.callback = function()
			{
				if (tween != null)
					tween.cancel();

				tween = FlxTween.num(alpha, 0.00001, 0.15, {ease: FlxEase.circInOut}, function(value:Float)
				{
					alpha = value;
				});
			}

			#if FLX_DEBUG
			ignoreDrawDebug = true;
			#end
		}
	}

	public function getFrames():FlxAtlasFrames
	{
		return Paths.getSparrowAtlas('android/hitbox');
	}
}