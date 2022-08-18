package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class NSFWState extends MusicBeatState
{
	public static var wasThere:Bool = false;
	var bg:FlxSprite;

	override function create()
	{
		super.create();

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('message'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.screenCenter();
		add(bg);

		#if android
		addVirtualPad(NONE, A_B);
		#end
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.N #if android || _virtualpad.buttonA.justPressed #end) {
			wasThere = true;	
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxTween.tween(bg, {alpha: 0}, 1, {
				onComplete: function (twn:FlxTween) {
					MusicBeatState.switchState(new TitleState());
				}
			});
		}

		if (FlxG.keys.justPressed.Y #if android || _virtualpad.buttonB.justPressed #end) {
			CoolUtil.browserLoad('https://www.patreon.com/Goobler');
		}

		super.update(elapsed);
	}
}
