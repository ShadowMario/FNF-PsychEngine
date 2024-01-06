package states;

import tjson.TJSON;
import backend.WeekData;
import backend.Highscore;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;
import haxe.Http;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import shaders.ColorSwap;
import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

typedef TitleData =
{
	title:Array<Float>,
	start:Array<Float>,
	gf:Array<Float>,
	backgroundSprite:String,
	bpm:Float
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public static var closedState:Bool = false;
	public static var latestVersion:String = '';

	private static var playJingle:Bool = false;

	private var realBeats:Int = 0; // Skipless curBeat

	var mustUpdate:Bool = false;
	var newTitle:Bool = false;
	var transitioning:Bool = false;
	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	var titleData:TitleData;
	var titleTimer:Float = 0;

	var introTexts:FlxGroup;
	var introImages:FlxGroup;
	var wackyTexts:Array<String> = [];

	var logo:FlxSprite;
	var gf:FlxSprite;
	var titleText:FlxSprite;

	var swagShader:ColorSwap = null;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	#if TITLE_SCREEN_EASTER_EGG
	var easterEggKeys:Array<String> = ['SHADOW', 'RIVER', 'BBPANZU'];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	public override function create():Void
	{
		Paths.clearStoredMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		getWackyText();

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		checkForUpdates();
		#end

		Highscore.load();

		titleData = TJSON.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		#if TITLE_SCREEN_EASTER_EGG
		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		if (easterEgg == null)
			easterEgg = '';
		switch (easterEgg.toUpperCase())
		{
			case 'SHADOW':
				titleData.gf[0] += 210;
				titleData.gf[1] += 40;
			case 'RIVER':
				titleData.gf[0] += 180;
				titleData.gf[1] += 40;
			case 'BBPANZU':
				titleData.gf[0] += 45;
				titleData.gf[1] += 100;
		}
		#end

		if (!initialized && FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		FlxG.mouse.visible = false;
		introTexts = new FlxGroup();
		add(introTexts);
		introImages = new FlxGroup();
		add(introImages);

		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if (FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			startIntro();
		}
		#end
	}

	public override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if (pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;

				if (titleText != null)
					titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate)
						MusicBeatState.switchState(new OutdatedState());
					else
						MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
			}

			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if (allowedKeys.contains(keyName))
				{
					easterEggKeysBuffer += keyName;
					if (easterEggKeysBuffer.length >= 32)
						easterEggKeysBuffer = easterEggKeysBuffer.substring(1);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase();
						if (easterEggKeysBuffer.contains(word))
						{
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('ToggleJingle'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {
								onComplete: function(twn:FlxTween)
								{
									FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							FlxG.sound.music.fadeOut();
							if (FreeplayState.vocals != null)
							{
								FreeplayState.vocals.fadeOut();
							}
							closedState = true;
							transitioning = true;
							playJingle = true;
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
			skipIntro();

		if (swagShader != null)
		{
			if (controls.UI_LEFT)
				swagShader.hue -= elapsed * 0.1;
			if (controls.UI_RIGHT)
				swagShader.hue += elapsed * 0.1;
		}

		if (newTitle)
		{
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}

		super.update(elapsed);
	}

	function checkForUpdates():Void
	{
		if (ClientPrefs.data.checkForUpdates && !closedState)
		{
			trace("Checking for an update.");
			var http = new Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			http.onData = data ->
			{
				latestVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('Latest Version: $latestVersion\nCurrent Version: $curVersion');
				if (latestVersion != curVersion)
				{
					trace("Versions don't match.");
					mustUpdate = true;
				}
			}
			http.onError = error -> trace('Error while getting update: $error');
			http.request();
		}
	}

	function getWackyText():Void
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getSharedPath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		wackyTexts = FlxG.random.getObject(swagGoodArray);
	}

	function startIntro():Void
	{
		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		Conductor.bpm = titleData.bpm;
		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;

		if (titleData.backgroundSprite != null && titleData.backgroundSprite.length > 0 && titleData.backgroundSprite != "none")
		{
			bg.loadGraphic(Paths.image(titleData.backgroundSprite));
			bg.updateHitbox();
			add(bg);
		}

		gf = new FlxSprite(titleData.gf[0], titleData.gf[1]);
		gf.antialiasing = ClientPrefs.data.antialiasing;

		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		if (easterEgg == null)
			easterEgg = '';

		switch (easterEgg.toUpperCase())
		{
			#if TITLE_SCREEN_EASTER_EGG
			case 'SHADOW':
				gf.frames = Paths.getSparrowAtlas('ShadowBump');
				gf.animation.addByPrefix('danceLeft', 'Shadow Title Bump', 24);
				gf.animation.addByPrefix('danceRight', 'Shadow Title Bump', 24);
			case 'RIVER':
				gf.frames = Paths.getSparrowAtlas('RiverBump');
				gf.animation.addByIndices('danceLeft', 'River Title Bump', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				gf.animation.addByIndices('danceRight', 'River Title Bump', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			case 'BBPANZU':
				gf.frames = Paths.getSparrowAtlas('BBBump');
				gf.animation.addByIndices('danceLeft', 'BB Title Bump', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
				gf.animation.addByIndices('danceRight', 'BB Title Bump', [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
			#end

			default: // Edit if you're making a source code mod.
				gf.frames = Paths.getSparrowAtlas('gfDanceTitle');
				gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}

		gf.animation.play('danceLeft');
		gf.updateHitbox();
		gf.visible = false;
		add(gf);

		logo = new FlxSprite(titleData.title[0], titleData.title[1]);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.animation.play('bump');
		logo.updateHitbox();
		logo.visible = false;
		add(logo);

		if (ClientPrefs.data.shaders)
		{
			swagShader = new ColorSwap();
			gf.shader = logo.shader = swagShader.shader;
		}

		titleText = new FlxSprite(titleData.start[0], titleData.start[1]);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0)
		{
			newTitle = true;

			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			newTitle = false;

			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.visible = false;
		add(titleText);

		if (initialized)
			skipIntro();
		else
			initialized = true;

		Paths.clearUnusedMemory();
	}

	function createText(textArray:Array<String>, ?offset:Float = 0):Void
	{
		for (i in 0...textArray.length)
		{
			var tex:Alphabet = new Alphabet(0, 0, textArray[i], true);
			tex.screenCenter(X);
			tex.y += (i * 65) + 200 + offset;
			introTexts.add(tex);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0):Void
	{
		var tex:Alphabet = new Alphabet(0, 0, text, true);
		tex.screenCenter(X);
		tex.y += (introTexts.length * 65) + 200 + offset;
		introTexts.add(tex);
	}

	function deleteTexts():Void
	{
		while (introTexts.members.length > 0)
			introTexts.remove(introTexts.members[0], true);
	}

	function createImage(path:String, y:Float, scale:Float):Void
	{
		var img = new FlxSprite(0, y).loadGraphic(Paths.image(path));
		img.antialiasing = ClientPrefs.data.antialiasing;
		img.setGraphicSize(Std.int(img.width * scale));
		img.updateHitbox();
		img.screenCenter(X);
		introImages.add(img);
	}

	function deleteImages():Void
	{
		while (introImages.members.length > 0)
			introImages.remove(introImages.members[0], true);
	}

	override function beatHit():Void
	{
		super.beatHit();

		if (logo != null)
			logo.animation.play('bump', true);

		if (gf != null)
		{
			if (curBeat % 2 == 0)
				gf.animation.play('danceLeft');
			else
				gf.animation.play('danceRight');
		}

		if (!closedState)
		{
			realBeats++;
			if (!skippedIntro)
			{
				switch (realBeats)
				{
					case 1:
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
					case 2:
						#if PSYCH_WATERMARKS
						createText(['Psych Engine by'], 40);
						#else
						createText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
						#end
					case 4:
						#if PSYCH_WATERMARKS
						addMoreText('Shadow Mario', 40);
						addMoreText('Riveren', 40);
						#else
						addMoreText('present');
						#end
					case 5:
						deleteTexts();
					case 6:
						#if PSYCH_WATERMARKS
						createText(['Not associated', 'with'], -40);
						#else
						createText(['In association', 'with'], -40);
						#end
					case 8:
						addMoreText('newgrounds', -40);
						createImage('newgrounds_logo', FlxG.height * 0.52, 0.8);
					case 9:
						deleteTexts();
						deleteImages();
					case 10:
						createText([wackyTexts[0]]);
					case 12:
						addMoreText(wackyTexts[1]);
					case 13:
						deleteTexts();
					case 14:
						addMoreText('Friday');
					case 15:
						addMoreText('Night');
					case 16:
						addMoreText('Funkin');
					case 17:
						skipIntro();
				}
			}
		}
	}

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (playJingle)
			{
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null)
					easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch (easteregg)
				{
					case 'RIVER':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));

					default:
						deleteTexts();
						deleteImages();
						FlxG.camera.flash(FlxColor.WHITE, 2);
						skippedIntro = true;
						playJingle = false;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						gf.visible = logo.visible = titleText.visible = true;
						return;
				}

				transitioning = true;
				if (easteregg == 'SHADOW')
				{
					gf.visible = logo.visible = titleText.visible = false;
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						deleteTexts();
						deleteImages();
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
						gf.visible = logo.visible = titleText.visible = true;
					});
				}
				else
				{
					deleteTexts();
					deleteImages();
					FlxG.camera.flash(FlxColor.WHITE, 3);
					sound.onComplete = function()
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
					};
					gf.visible = logo.visible = titleText.visible = true;
				}
				playJingle = false;
			}
			else
			{
				deleteTexts();
				deleteImages();
				FlxG.camera.flash(FlxColor.WHITE, 4);

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null)
					easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if (easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
					if (FreeplayState.vocals != null)
					{
						FreeplayState.vocals.fadeOut();
					}
				}
				gf.visible = logo.visible = titleText.visible = true;
				#end
			}
			skippedIntro = true;
		}
	}
}
