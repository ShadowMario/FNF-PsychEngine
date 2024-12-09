package states.stages;

class Spooky extends BaseStage
{
	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;
	override function create()
	{
		if(!ClientPrefs.data.lowQuality) {
			halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
		} else {
			halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
		}
		add(halloweenBG);

		//PRECACHE SOUNDS
		Paths.sound('thunder_1');
		Paths.sound('thunder_2');

		//Monster cutscene
		if (isStoryMode && !seenCutscene)
		{
			switch(songName)
			{
				case 'monster':
					setStartCallback(monsterCutscene);
			}
		}
	}
	override function createPost()
	{
		halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
		halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
		halloweenWhite.alpha = 0;
		halloweenWhite.blend = ADD;
		add(halloweenWhite);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	override function beatHit()
	{
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.data.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.hasAnimation('scared'))
			boyfriend.playAnim('scared', true);

		if(dad.hasAnimation('scared'))
			dad.playAnim('scared', true);

		if(gf != null && gf.hasAnimation('scared'))
			gf.playAnim('scared', true);

		if(ClientPrefs.data.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!game.camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.data.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function monsterCutscene()
	{
		inCutscene = true;
		camHUD.visible = false;

		FlxG.camera.focusOn(new FlxPoint(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100));

		// character anims
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(gf != null) gf.playAnim('scared', true);
		boyfriend.playAnim('scared', true);

		// white flash
		var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
		whiteScreen.scrollFactor.set();
		whiteScreen.blend = ADD;
		add(whiteScreen);
		FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
			startDelay: 0.1,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				remove(whiteScreen);
				whiteScreen.destroy();

				camHUD.visible = true;
				startCountdown();
			}
		});
	}
}