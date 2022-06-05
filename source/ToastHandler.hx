//Original code from: https://github.com/TentaRJ/GameJolt-FNF-Integration/blob/main/source/GameJolt.hx -saw

package;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;

using StringTools;

class ToastHandler extends Sprite
{
	public static var ENTER_TIME:Float = 0.5;
	public static var DISPLAY_TIME:Float = 3.0;
	public static var LEAVE_TIME:Float = 0.5;
	public static var TOTAL_TIME:Float = ENTER_TIME + DISPLAY_TIME + LEAVE_TIME;
	public var onFinish:Void->Void = null;

	var playTime:FlxTimer = new FlxTimer();

	public function new()
	{
		super();

		FlxG.signals.postStateSwitch.add(onStateSwitch);
		FlxG.signals.gameResized.add(onWindowResized);
	}

	public function createToast(iconPath:String, title:String, description:String, ?sound:Bool = false):Void
	{
		if (sound)
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

		var toast = new Toast(iconPath, title, description);
		addChild(toast);

		playTime.start(TOTAL_TIME);
		playToasts();
	}

	public function playToasts():Void
	{
		for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			FlxTween.cancelTweensOf(child);
			FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME, {ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween)
				{
					FlxTween.cancelTweensOf(child);
					FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut, startDelay: DISPLAY_TIME,
						onComplete: function(tween:FlxTween)
						{
							cast(child, Toast).removeChildren();
							removeChild(child);

							if(onFinish != null)
								onFinish();
						}
					});
				}
			});
		}
	}

	public function collapseToasts():Void
	{
		for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween)
				{
					cast(child, Toast).removeChildren();
					removeChild(child);

					if(onFinish != null)
						onFinish();
				}
			});
		}
	}

	public function onStateSwitch():Void
	{
		if (!playTime.active)
			return;

		var elapsedSec = playTime.elapsedTime / 1000;
		if (elapsedSec < ENTER_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME - elapsedSec, {ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween)
					{
						FlxTween.cancelTweensOf(child);
						FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut, startDelay: DISPLAY_TIME,
							onComplete: function(tween:FlxTween)
							{
								cast(child, Toast).removeChildren();
								removeChild(child);

								if(onFinish != null)
									onFinish();
							}
						});
					}
				});
			}
		}
		else if (elapsedSec < DISPLAY_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut, startDelay: DISPLAY_TIME - (elapsedSec - ENTER_TIME),
					onComplete: function(tween:FlxTween)
					{
						cast(child, Toast).removeChildren();
						removeChild(child);

						if(onFinish != null)
							onFinish();
					}
				});
			}
		}
		else if (elapsedSec < LEAVE_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME -  (elapsedSec - ENTER_TIME - DISPLAY_TIME), {ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween)
					{
						cast(child, Toast).removeChildren();
						removeChild(child);

						if(onFinish != null)
							onFinish();
					}
				});
			}
		}
	}

	public function onWindowResized(x:Int, y:Int):Void
	{
		for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			child.x = Lib.current.stage.stageWidth - child.width;
		}
	}
}

class Toast extends Sprite
{
	var back:Bitmap;
	var icon:Bitmap;
	var title:TextField;
	var desc:TextField;

	public function new(iconPath:String, titleText:String, description:String)
	{
		super();

		back = new Bitmap(new BitmapData(500, 125, true, 0xFF000000));
		back.alpha = 0.9;
		back.x = 0;
		back.y = 0;

		if(iconPath != null){
			icon = new Bitmap(BitmapData.fromFile(iconPath));
			icon.x = back.x + 10;
			icon.y = back.y + 10;
			icon.width = 100;
			icon.height = 100;
		}

		title = new TextField();
		title.text = titleText;
		title.setTextFormat(new TextFormat("VCR OSD Mono", 24, 0xFFFF00, true));
		title.wordWrap = true;
		title.width = 360;
		title.y = 5;

		if(iconPath != null)
			title.x = 120
		else
			title.x = 5;

		desc = new TextField();
		desc.text = description;
		desc.setTextFormat(new TextFormat("VCR OSD Mono", 18, 0xFFFFFF));
		desc.wordWrap = true;
		desc.width = 360;
		desc.height = 95;
		desc.y = 30;

		if(iconPath != null)
			desc.x = 120;
		else
			desc.x = 5;

		if (titleText.length >= 25 || titleText.contains("\n")){   
			desc.y += 25;
			desc.height -= 25;
		}

		addChild(back);

		if(iconPath !=null)
			addChild(icon);

		addChild(title);
		addChild(desc);

		width = back.width;
		height = back.height;
		x = Lib.current.stage.stageWidth - width;
		y = -height;
	}
}