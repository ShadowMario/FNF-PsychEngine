package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var sbLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('SBEngineEngineLogo'));
		sbLogo.scale.y = 0.3;
		sbLogo.scale.x = 0.3;
		sbLogo.x -= kadeLogo.frameHeight;
		sbLogo.y -= 180;
		sbLogo.alpha = 0.8;
		sbLogo.antialiasing = FlxG.save.data.antialiasing;
		add(kadeLogo);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		#if android
		warnText = new FlxText(0, 0, FlxG.width,
			"Sup bro, looks like you're running an   \n
			outdated version of Psych Engine With Android Support (" + MainMenuState.psychEngineVersion + "),\n
			please update to " + TitleState.updateVersion + "!\n
			Press B to proceed anyway.\n
			\n
			Thank you for using the Port of the Engine!",
			32);
		#else
		warnText = new FlxText(0, 0, FlxG.width,
			"Sup bro, looks like you're running an   \n
			outdated version of Psych Engine (" + MainMenuState.psychEngineVersion + "),\n
			please update to " + TitleState.updateVersion + "!\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using the Engine!",
			32);
		#end
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		#if android
		addVirtualPad(NONE, A);
		#end

		FlxTween.angle(sbLogo, sbLogo.angle, -10, 2, (ease: FlxEase);

		new FlxTimer().start(2, function(tmr:FlxTimer);
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if (colorRotation < (bgColors.length - 1))
				colorRotation++;
			else
				colorRotation = 0;
		}, 0);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (sbLogo.angle == -10)
				FlxTween.angle(sbLogo, sbLogo.angle, 10, 2, {ease: FlxEase});
			else
				FlxTween.angle(sbLogo, sbLogo.angle, -10, 2, {ease: FlxEase});
		}, 0);

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if (sbLogo.alpha == 0.8)
				FlxTween.tween(sbLogo, {alpha: 1}, 0.8, {ease: FlxEase.});
			else
				FlxTween.tween(sbLogo, {alpha: 0.8}, 0.8, {ease: FlxEase});
		}, 0);

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/jigsaw-4277821/FNF-PsychEngine-Android-Support/actions");
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
