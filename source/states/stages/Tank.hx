package states.stages;

import states.stages.objects.*;
import cutscenes.CutsceneHandler;
import substates.GameOverSubstate;
import objects.Character;

class Tank extends BaseStage
{
	var tankWatchtower:BGSprite;
	var tankGround:BackgroundTank;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	override function create()
	{
		var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
		add(sky);

		if(!ClientPrefs.data.lowQuality)
		{
			var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
			clouds.active = true;
			clouds.velocity.x = FlxG.random.float(5, 15);
			add(clouds);

			var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
			mountains.setGraphicSize(Std.int(1.2 * mountains.width));
			mountains.updateHitbox();
			add(mountains);

			var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
			buildings.setGraphicSize(Std.int(1.1 * buildings.width));
			buildings.updateHitbox();
			add(buildings);
		}

		var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
		ruins.setGraphicSize(Std.int(1.1 * ruins.width));
		ruins.updateHitbox();
		add(ruins);

		if(!ClientPrefs.data.lowQuality)
		{
			var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
			add(smokeLeft);
			var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
			add(smokeRight);

			tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
			add(tankWatchtower);
		}

		tankGround = new BackgroundTank();
		add(tankGround);

		tankmanRun = new FlxTypedGroup<TankmenBG>();
		add(tankmanRun);

		var ground:BGSprite = new BGSprite('tankGround', -420, -150);
		ground.setGraphicSize(Std.int(1.15 * ground.width));
		ground.updateHitbox();
		add(ground);

		foregroundSprites = new FlxTypedGroup<BGSprite>();
		foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
		if(!ClientPrefs.data.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
		foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
		if(!ClientPrefs.data.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
		foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
		if(!ClientPrefs.data.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));

		// Default GFs
		if(songName == 'stress') setDefaultGF('pico-speaker');
		else setDefaultGF('gf-tankmen');
		
		if (isStoryMode && !seenCutscene)
		{
			switch (songName)
			{
				case 'ugh':
					setStartCallback(ughIntro);
				case 'guns':
					setStartCallback(gunsIntro);
				case 'stress':
					setStartCallback(stressIntro);
			}
		}
	}
	override function createPost()
	{
		add(foregroundSprites);

		if(!ClientPrefs.data.lowQuality)
		{
			for (daGf in gfGroup)
			{
				var gf:Character = cast daGf;
				if(gf.curCharacter == 'pico-speaker')
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 1500, true);
					firstTank.strumTime = 10;
					firstTank.visible = false;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
					break;
				}
			}
		}
	}

	override function countdownTick(count:Countdown, num:Int) if(num % 2 == 0) everyoneDance();
	override function beatHit() everyoneDance();
	function everyoneDance()
	{
		if(!ClientPrefs.data.lowQuality) tankWatchtower.dance();
		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});
	}

	// Cutscenes
	var cutsceneHandler:CutsceneHandler;
	var tankman:FlxAnimate;
	var pico:FlxAnimate;
	var boyfriendCutscene:FlxSprite;
	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();

		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		tankman = new FlxAnimate(dad.x + 419, dad.y + 225);
		tankman.showPivot = false;
		Paths.loadAnimateAtlas(tankman, 'cutscenes/tankman');
		tankman.antialiasing = ClientPrefs.data.antialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};
		camFollow.setPosition(dad.x + 280, dad.y + 170);
	}

	function ughIntro()
	{
		prepareCutscene();
		cutsceneHandler.endTime = 12;
		cutsceneHandler.music = 'DISTORTO';
		Paths.sound('wellWellWell');
		Paths.sound('killYou');
		Paths.sound('bfBeep');

		var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
		FlxG.sound.list.add(wellWellWell);

		tankman.anim.addBySymbol('wellWell', 'TANK TALK 1 P1', 24, false);
		tankman.anim.addBySymbol('killYou', 'TANK TALK 1 P2', 24, false);
		tankman.anim.play('wellWell', true);
		FlxG.camera.zoom *= 1.2;

		// Well well well, what do we got here?
		cutsceneHandler.timer(0.1, function()
		{
			wellWellWell.play(true);
		});

		// Move camera to BF
		cutsceneHandler.timer(3, function()
		{
			camFollow.x += 750;
			camFollow.y += 100;
		});

		// Beep!
		cutsceneHandler.timer(4.5, function()
		{
			boyfriend.playAnim('singUP', true);
			boyfriend.specialAnim = true;
			FlxG.sound.play(Paths.sound('bfBeep'));
		});

		// Move camera to Tankman
		cutsceneHandler.timer(6, function()
		{
			camFollow.x -= 750;
			camFollow.y -= 100;

			// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
			tankman.anim.play('killYou', true);
			FlxG.sound.play(Paths.sound('killYou'));
		});
	}
	function gunsIntro()
	{
		prepareCutscene();
		cutsceneHandler.endTime = 11.5;
		cutsceneHandler.music = 'DISTORTO';
		Paths.sound('tankSong2');

		var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
		FlxG.sound.list.add(tightBars);

		tankman.anim.addBySymbol('tightBars', 'TANK TALK 2', 24, false);
		tankman.anim.play('tightBars', true);
		boyfriend.animation.curAnim.finish();

		cutsceneHandler.onStart = function()
		{
			tightBars.play(true);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
		};

		cutsceneHandler.timer(4, function()
		{
			gf.playAnim('sad', true);
			gf.animation.finishCallback = function(name:String)
			{
				gf.playAnim('sad', true);
			};
		});
	}
	var dualWieldAnimPlayed = 0;
	function stressIntro()
	{
		prepareCutscene();
		
		cutsceneHandler.endTime = 35.5;
		gfGroup.alpha = 0.00001;
		boyfriendGroup.alpha = 0.00001;
		camFollow.setPosition(dad.x + 400, dad.y + 170);
		FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.y += 100;
		});
		Paths.sound('stressCutscene');

		pico = new FlxAnimate(gf.x + 150, gf.y + 450);
		pico.showPivot = false;
		Paths.loadAnimateAtlas(pico, 'cutscenes/picoAppears');
		pico.antialiasing = ClientPrefs.data.antialiasing;
		pico.anim.addBySymbol('dance', 'GF Dancing at Gunpoint', 24, true);
		pico.anim.addBySymbol('dieBitch', 'GF Time to Die sequence', 24, false);
		pico.anim.addBySymbol('picoAppears', 'Pico Saves them sequence', 24, false);
		pico.anim.addBySymbol('picoEnd', 'Pico Dual Wield on Speaker idle', 24, false);
		pico.anim.play('dance', true);
		addBehindGF(pico);
		cutsceneHandler.push(pico);

		boyfriendCutscene = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.data.antialiasing;
		boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
		boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		boyfriendCutscene.animation.play('idle', true);
		boyfriendCutscene.animation.curAnim.finish();
		addBehindBF(boyfriendCutscene);
		cutsceneHandler.push(boyfriendCutscene);

		var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
		FlxG.sound.list.add(cutsceneSnd);

		tankman.anim.addBySymbol('godEffingDamnIt', 'TANK TALK 3 P1 UNCUT', 24, false);
		tankman.anim.addBySymbol('lookWhoItIs', 'TANK TALK 3 P2 UNCUT', 24, false);
		tankman.anim.play('godEffingDamnIt', true);

		cutsceneHandler.onStart = function()
		{
			cutsceneSnd.play(true);
		};

		cutsceneHandler.timer(15.2, function()
		{
			FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

			pico.anim.play('dieBitch', true);
			pico.anim.onComplete = function()
			{
				pico.anim.play('picoAppears', true);
				pico.anim.onComplete = function()
				{
					pico.anim.play('picoEnd', true);
					pico.anim.onComplete = function()
					{
						gfGroup.alpha = 1;
						pico.visible = false;
						pico.anim.onComplete = null;
					}
				};

				boyfriendGroup.alpha = 1;
				boyfriendCutscene.visible = false;
				boyfriend.playAnim('bfCatch', true);

				boyfriend.animation.finishCallback = function(name:String)
				{
					if(name != 'idle')
					{
						boyfriend.playAnim('idle', true);
						boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
					}
				};
			};
		});

		cutsceneHandler.timer(17.5, function()
		{
			zoomBack();
		});

		cutsceneHandler.timer(19.5, function()
		{
			tankman.anim.play('lookWhoItIs', true);
		});

		cutsceneHandler.timer(20, function()
		{
			camFollow.setPosition(dad.x + 500, dad.y + 170);
		});

		cutsceneHandler.timer(31.2, function()
		{
			boyfriend.playAnim('singUPmiss', true);
			boyfriend.animation.finishCallback = function(name:String)
			{
				if (name == 'singUPmiss')
				{
					boyfriend.playAnim('idle', true);
					boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
				}
			};

			camFollow.setPosition(boyfriend.x + 280, boyfriend.y + 200);
			FlxG.camera.snapToTarget();
			game.cameraSpeed = 12;
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
		});

		cutsceneHandler.timer(32.2, function()
		{
			zoomBack();
		});
	}

	function zoomBack()
	{
		var calledTimes:Int = 0;
		camFollow.setPosition(630, 425);
		FlxG.camera.snapToTarget();
		FlxG.camera.zoom = 0.8;
		game.cameraSpeed = 1;

		calledTimes++;
		if (calledTimes > 1)
		{
			foregroundSprites.forEach(function(spr:BGSprite)
			{
				spr.y -= 100;
			});
		}
	}
}