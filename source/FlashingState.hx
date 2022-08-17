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

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		#if android
		warnText = new FlxText(0, 0, FlxG.width,
			"Hej, Pazite!\n
			Pazite Kako Stiskate Na Hitboks!\n
			Mozete Da Ekstremno Porazbijete Ekran ,Ali\n
			SB Engine Sadrzi Osvetljenje Ekrana!\n
			Pritisnite A Da Odmah Iskljucite Sada.\n
			Ovo Je Psych Engine, Ali Modifikovani.\n
			Vi Ste Upozoreni! Vas SB Engine",
			32);
		#else
		warnText = new FlxText(0, 0, FlxG.width,
			"Hej, Pazite!\n
			SB Engine Zadrzi Osvetljenje Ekrana!\n
			Pritisnite ENTER Da Odmah Iskljucite Sada.\n
			Ovo Je Psych Engine, Ali Modifikovani.\n
			Vi Ste Upozoreni! Vas SB Engine",
			32);
		#end
		warnText.setFormat("_Sans", 32, FlxColor.ORANGE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		#if android
		addVirtualPad(NONE, A);
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						#if android
						virtualPad.alpha = 0;
						#end
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					#if android
					FlxTween.tween(virtualPad, {alpha: 0}, 1);
					#end
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}
