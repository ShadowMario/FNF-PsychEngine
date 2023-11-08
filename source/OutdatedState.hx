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

		MusicBeatState.windowNameSuffix2 = " (Outdated!)";

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
		warnText = new FlxText(0, 10, FlxG.width,
			"HEY! Your JS Engine is outdated!\n"
			+ 'v$MainMenuState.psychEngineJSVersion < v$TitleState.updateVersion\n'
			,32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.screenCenter(X);
		add(warnText);

		var changelog = new FlxText(100, txt.y + txt.height + 20, 1080, currChanges, 16);
		changelog.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(changelog);

		#if android
        addVirtualPad(NONE, A_B);
        #end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (FlxG.keys.justPressed.ENTER) {
				leftState = true;
				#if windows MusicBeatState.switchState(new UpdateState());
				#else
				CoolUtil.browserLoad("https://github.com/JordanSantiagoYT/FNF-PsychEngine-NoBotplayLag/releases/latest");
				#end
			}
			if (FlxG.keys.justPressed.SPACE) {
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
