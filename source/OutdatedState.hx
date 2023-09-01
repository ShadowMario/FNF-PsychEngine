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


class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var currChanges:String = "dk";

	var warnText:FlxText;
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		#if android
		warnText = new FlxText(0, 0, FlxG.width,
			"Your version of JS Engine is outdated!\nYou are on "
			+ MainMenuState.psychEngineJSVersion
			+ "\nwhile the most recent version is "
			+ TitleState.updateVersion
			+ "."
			+ "\n\nHere's what's new:\n\n"
			+ currChanges
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress A button to view the full changelog and update\nor B button to ignore this",
			32);
		#else
		warnText = new FlxText(0, 0, FlxG.width,
			"Your version of JS Engine is outdated!\nYou are on "
			+ MainMenuState.psychEngineJSVersion
			+ "\nwhile the most recent version is "
			+ TitleState.updateVersion
			+ "."
			+ "\n\nHere's what's new:\n\n"
			+ currChanges
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress Space to view the full changelog and update\nor ESCAPE to ignore this",
			32);
		#end
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		#if android
        addVirtualPad(NONE, A_B);
        #end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/JordanSantiagoYT/FNF-PsychEngine-NoBotplayLag/releases/latest");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
