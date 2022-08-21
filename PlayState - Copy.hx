package;

import flixel.system.macros.FlxMacroUtil;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import LoadSettings.Settings;

using StringTools;

class PlayState extends MusicBeatState
{
	static public var curStage:String = '';
	static public var SONG:SwagSong;
	static public var isStoryMode:Bool = false;
	static public var storyWeek:Int = 0;
	static public var storyPlaylist:Array<String> = [];
	static public var storyDifficulty:Int = 1;
	
	public var halloweenLevel:Bool = false;
	
	public var vocals:FlxSound;
	
	public var dads:Array<Character> = [];
	public var boyfriends:Array<Boyfriend> = [];
	public var currentDad:Int = 0;
	public var currentBoyfriend:Int = 0;

	public var gf:Character;
	@:isVar public var dad(get, set):Character;
	@:isVar public var boyfriend(get, set):Boyfriend;

	function get_boyfriend():Boyfriend 	{return boyfriends[currentBoyfriend];}
	function get_dad():Character 		{return dads[currentDad];}

	function set_boyfriend(bf):Boyfriend {
		boyfriends.push(bf);
		currentBoyfriend = boyfriends.length - 1;
		return bf;
	}

	function set_dad(dad):Character {
		dads.push(dad);
		currentDad = dads.length - 1;
		return dad;
	}
	
	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public static var current:PlayState = null;
	
	public var strumLine:FlxSprite;
	public var curSection:Int = 0;
	
	public var camFollow:FlxObject;
	
	static public var prevCamFollow:FlxObject;
	
	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var cpuStrums:FlxTypedGroup<FlxSprite>;
	
	public var camZooming:Bool = false;
	public var curSong:String = "";
	
	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;
	
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	
	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;
	
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	
	public var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	
	public var talking:Bool = true;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;
	public var scoreTxtTween:FlxTween;
	
	static public var campaignScore:Int = 0;
	
	public var defaultCamZoom:Float = 1.05;
	
	// how big to stretch the pixel art assets
	static public var daPixelZoom:Float = 6;
	
	public var inCutscene:Bool = false;
	
	#if desktop
	// Discord RPC public variables
	public var storyDifficultyText:String = "";
	public var iconRPC:String = "";
	public var songLength:Float = 0;
	public var detailsText:String = "";
	public var detailsPausedText:String = "";
	#end
	
	
	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	public var canPause:Bool = true;
	
	//Score and shit
	public var accuracy:Float = 0;
	public var numberOfNotes:Float = 0;
	public var numberOfArrowNotes:Float = 0;
	public var misses:Int = 0;
	public var accuracy_(get, null):Float;
	function get_accuracy_():Float {
		return accuracy / numberOfNotes;
	}

	public var delayTotal:Float = 0;

	public var msScoreLabel:FlxText;
	public var msScoreLabelTween:FlxTween;

	public var songAltName:String;
	
	public var startTimer:FlxTimer;
	public var perfectMode:Bool = false;
	
	public var previousFrameTime:Int = 0;
	public var lastReportedPlayheadPosition:Int = 0;
	public var songTime:Float = 0;
	
	public var debugNum:Int = 0;
	
	public var endingSong:Bool = false;
	
	public var startedMoving:Bool = false;

	public var guiOffset:FlxPoint = new FlxPoint((1280 - (1280 / Settings.engineSettings.data.noteScale)), (720 - (720 / Settings.engineSettings.data.noteScale)));
	
	public var songEvents:SongEventsManager.SongEventsManager;
	public static var bfList:Array<String> = ["bf", "bf-car", "bf-christmas", "bf-pixel", "bf-pixel-dead"];

	override public function create()
	{
		PlayState.current = this;
		// Assets.loadLibrary("songs");
		#if sys
		if (Settings.engineSettings.data.emptySkinCache) {
			Paths.clearCache();
		}
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		if (Settings.engineSettings.data.greenScreenMode) {
			camHUD.bgColor = new FlxColor(0xFF00FF00);
		} else {
			camHUD.bgColor.alpha = 0;
		}

		camHUD.zoom = Settings.engineSettings.data.noteScale;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
		#end

		songEvents = new SongEventsManager.SongEventsManager();

		var gfVersion:String = 'gf';
		songEvents.create();

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		
		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			// case "spooky":
			// 	dad.y += 200;
			// case "monster":
			// 	dad.y += 100;
			// case 'monster-christmas':
			// 	dad.y += 130;
			// case 'dad':
			// 	camPos.x += 400;
			// case 'pico':
			// 	camPos.x += 600;
			// 	dad.y += 300;
			// case 'parents-christmas':
			// 	dad.x -= 500;
			case 'senpai':
			// 	dad.x += 150;
			// 	dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
			// 	dad.x += 150;
			// 	dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
			// 	dad.x -= 150;
			// 	dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 100, SONG.player1);

		// boyfriend.x += boyfriend.charGlobalOffset.x;
		// boyfriend.y += boyfriend.charGlobalOffset.y;
		// dad.x += dad.charGlobalOffset.x;
		// dad.y += dad.charGlobalOffset.y;
		// gf.x += gf.charGlobalOffset.x;
		// gf.y += gf.charGlobalOffset.y;

		// REPOSITIONING PER STAGE
		// switch (curStage)
		// {
		// 	case 'limo':
		// 		boyfriend.y -= 220;
		// 		boyfriend.x += 260;

		// 	case 'mall':
		// 		boyfriend.x += 200;

		// 	case 'mallEvil':
		// 		boyfriend.x += 320;
		// 		dad.y -= 80;
		// 	case 'school':
		// 		gf.x += 180;
		// 		gf.y += 300;
		// 	case 'schoolEvil':
		// 		var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		// 		add(evilTrail);
		// 		gf.x += 180;
		// 		gf.y += 300;
		// }
		boyfriend.x += songEvents.stage.bfOffset.x;
		boyfriend.y += songEvents.stage.bfOffset.y;
		dad.x += songEvents.stage.dadOffset.x;
		dad.y += songEvents.stage.dadOffset.y;
		gf.x += songEvents.stage.gfOffset.x;
		gf.y += songEvents.stage.gfOffset.y;
		songEvents.createAfterChars();
		add(gf);

		songEvents.createAfterGf();

		add(dad);
		add(boyfriend);
		songEvents.createInFront();

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, (Settings.engineSettings.data.downscroll ? FlxG.height - 150 : 50) * (1 / Settings.engineSettings.data.noteScale) + (guiOffset.y / 2)).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * (Settings.engineSettings.data.downscroll ? 0.075 : 0.9) * (1 / Settings.engineSettings.data.noteScale) + (guiOffset.y / 2)).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt = new FlxText(0, healthBarBG.y + 30, FlxG.width * Settings.engineSettings.data.textQualityLevel, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), Std.int(16 * Settings.engineSettings.data.textQualityLevel), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scale.x = 1 / Settings.engineSettings.data.textQualityLevel;
		scoreTxt.scale.y = 1 / Settings.engineSettings.data.textQualityLevel;
		scoreTxt.antialiasing = true;
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		songAltName = SONG.song;
		switch(SONG.song.toLowerCase()) {
			case "why-do-you-hate-me":
				songAltName = "No nene i'm not playing a camellia song";
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		msScoreLabel = new FlxText(playerStrums.members[0].x, playerStrums.members[0].y - 25, playerStrums.members[3].width + playerStrums.members[3].x - playerStrums.members[0].x, "0ms", 20);
		msScoreLabel.setFormat(Paths.font("vcr.ttf"), Std.int(30 * Settings.engineSettings.data.textQualityLevel), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msScoreLabel.antialiasing = true;
		msScoreLabel.scale.x = 1 / Settings.engineSettings.data.textQualityLevel;
		msScoreLabel.scale.y = 1 / Settings.engineSettings.data.textQualityLevel;
		msScoreLabel.scrollFactor.set();
		msScoreLabel.cameras = [camHUD];
		msScoreLabel.alpha = 0;
		add(msScoreLabel);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			for (i => d in dads) {
				if (d != null) {
					d.playAnim('idle');
				} else {
					#if debug
						trace("Dad at index " + Std.string(i) + " is null.");
					#end
				}
			}
			gf.dance();
			for (i => bf in boyfriends) {
				if (bf != null) {
					bf.playAnim('idle');
				} else {
					#if debug
						trace("Boyfriend at index " + Std.string(i) + " is null.");
					#end
				}
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;
		// if (FlxG.save.data.customArrowSkin) Note.skinBitmap = ;
		// Paths.getSparrowAtlas_Custom("skins/notes/" + FlxG.save.data.customArrowSkin.toLowerCase())

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * (susNote + 0.5)), daNoteData, oldNote, true, gottaHitNote);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image(Settings.engineSettings.data.customArrowColors ? 'weeb/pixelUI/arrows-pixels-colored' : 'weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas(Settings.engineSettings.data.customArrowColors ? 'NOTE_assets_colored' : 'NOTE_assets') : Paths.getSparrowAtlas_Custom("skins/notes/" + Settings.engineSettings.data.customArrowSkin.toLowerCase());
					
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			} else {
				cpuStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if (Settings.engineSettings.data.customArrowColors) {
			var noteColors:Array<FlxColor> = [
				new FlxColor(Settings.engineSettings.data.arrowColor0),
				new FlxColor(Settings.engineSettings.data.arrowColor1),
				new FlxColor(Settings.engineSettings.data.arrowColor2),
				new FlxColor(Settings.engineSettings.data.arrowColor3)
			];
			for (strum in playerStrums) {
				#if secret
					var c:FlxColor = new FlxColor(0xFFFF0000);
					c.hue = (Conductor.songPosition / 100) % 359;
					if (strum.animation.curAnim != null) strum.color = (strum.animation.curAnim.name == "static" ? new FlxColor(0xFFFFFFFF) : c);
				#else
					if (strum.animation.curAnim != null) strum.color = (strum.animation.curAnim.name == "static" ? new FlxColor(0xFFFFFFFF) : noteColors[strum.ID % 4]);
				#end
			}
		}
		songEvents.update(elapsed);
		songEvents.update(elapsed);
		if (FlxControls.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		

		super.update(elapsed);

		// scoreTxt.text = "Score:" + songScore + " | Misses:" + Std.string(misses) + " | Accuracy:" + (numberOfNotes == 0 ? "0%" : Std.string((Math.round(accuracy * 10000 / numberOfNotes) / 10000) * 100) + "%");
		scoreTxt.text = ScoreText.generate(this);

		if (FlxControls.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxControls.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.offset.x = -iconOffset;
		iconP2.offset.x = -iconOffset;
		// iconP1.offset.y = -iconOffset;
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width) - (iconOffset / 2);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxControls.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxControls.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1 * Settings.engineSettings.data.noteScale, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("oh no he died");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height - guiOffset.y)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (Settings.engineSettings.data.downscroll) {
					// daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(Settings.engineSettings.data.customScrollSpeed ? Settings.engineSettings.data.scrollSpeed : SONG.speed, 2)));
					// Code above not modchart proof
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(Settings.engineSettings.data.customScrollSpeed ? Settings.engineSettings.data.scrollSpeed : SONG.speed, 2))) + ((daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % 4].y - strumLine.y);
				} else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(Settings.engineSettings.data.customScrollSpeed ? Settings.engineSettings.data.scrollSpeed : SONG.speed, 2))) + ((daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % 4].y - strumLine.y);
				}

				// i am so fucking sorry for this if condition

				if (Settings.engineSettings.data.downscroll) {
					if (daNote.isSustainNote
						// && (daNote.y + daNote.height - daNote.offset.y >= strumLine.y + Note.swagWidth / 2)
						&& (daNote.y + daNote.height - daNote.offset.y >= (daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % 4].y + Note.swagWidth / 2)
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, (daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % 4].y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;

						var newRect = new FlxRect();
						newRect.x = 0;
						newRect.y = 0;
						newRect.bottom = swagRect.top;
						newRect.right = swagRect.right;

						if (daNote.y + daNote.height > (daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % 4].y + Note.swagWidth / 2) {
							remove(daNote);
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						
						trace(swagRect);
						trace(newRect);
						daNote.clipRect = newRect;
					}
				} else {
					if (daNote.isSustainNote
						&& (daNote.y + daNote.offset.y <= (daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % 4].y + Note.swagWidth / 2)
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, (daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % 4].y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;
	
						daNote.clipRect = swagRect;
					}
				}
				

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((daNote.y - (guiOffset.y / 2) < -daNote.height && !Settings.engineSettings.data.downscroll) || ((FlxG.height + (guiOffset.y)) - daNote.y < -daNote.height && Settings.engineSettings.data.downscroll))
				{
					if ((daNote.tooLate || !daNote.wasGoodHit) && daNote.mustPress)
					{
						noteMiss(daNote.noteData % 4);
						health -= daNote.isSustainNote ? 0.0625 : 0.25;
						vocals.volume = 0;
					}
					
					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxControls.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);


			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					// NGio .unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	private function popUpScore(strumtime:Float):String
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		var good = true;
		var ratingColor:FlxColor = new FlxColor(0xFFFFFFFF);
		if (noteDiff < 50) {
			daRating = 'sick';
			ratingColor = new FlxColor(0xFF24DEFF);
		} else if (noteDiff < 100) {
			daRating = 'good';
			score = 200;
			ratingColor = new FlxColor(0xFF3FD200);
		} else if (noteDiff < 150) {
			daRating = 'bad';
			score = 50;
			ratingColor = new FlxColor(0xFFD70000);
		} else {
			daRating = 'shit';
			score = -150;
			ratingColor = new FlxColor(0xFF804913);
			good = false;
		}
		var accuracyAdd:Float = 0;

		switch(Settings.engineSettings.data.accuracyMode) {
			case 0:
				accuracyAdd = 1 - (FlxMath.wrap(Std.int(noteDiff), 0, Std.int(Conductor.safeZoneOffset)) / Conductor.safeZoneOffset);
			case 1:
				switch(daRating) {
					case 'sick':
						accuracyAdd = 1;
					case 'good':
						accuracyAdd = 2 / 3;
					case 'bad':
						accuracyAdd = 1 / 3;
					default:
						accuracyAdd = 0;
				}
		}
		delayTotal += noteDiff;
		
		numberOfArrowNotes++;

		if (Settings.engineSettings.data.showPressDelay) {
			msScoreLabel.text = Std.string(Math.floor(noteDiff)) + "ms";
			msScoreLabel.alpha = 1;
			if (msScoreLabelTween != null) {
				msScoreLabelTween.cancel();
				msScoreLabelTween.destroy();
			}
			msScoreLabel.color = ratingColor;
			msScoreLabel.scale.x = 1 / Settings.engineSettings.data.textQualityLevel;
			msScoreLabel.scale.y = 1 / Settings.engineSettings.data.textQualityLevel;
			msScoreLabelTween = FlxTween.tween(msScoreLabel, {alpha: 0, "scale.x" : 0.8 / Settings.engineSettings.data.textQualityLevel, "scale.y" : 0.8 / Settings.engineSettings.data.textQualityLevel}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					msScoreLabelTween = null;
				},
				startDelay: 0.75
			});
		}
		// if (noteDiff > Conductor.safeZoneOffset * 0.9)
		// {
		// 	daRating = 'shit';
		// 	score = 50;
		// }
		// else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		// {
		// 	daRating = 'bad';
		// 	score = 100;
		// }
		// else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		// {
		// 	daRating = 'good';
		// 	score = 200;
		// }

		accuracy += accuracyAdd;
		numberOfNotes++;
		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		
		if (Settings.engineSettings.data.animateInfoBar) {
			if (scoreTxtTween != null) {
				scoreTxtTween.cancel();
				scoreTxtTween.destroy();
			}
			scoreTxt.scale.x = 1.15 / Settings.engineSettings.data.textQualityLevel;
			scoreTxt.scale.y = 1.15 / Settings.engineSettings.data.textQualityLevel;
			scoreTxtTween = FlxTween.tween(scoreTxt, {"scale.x" : 1 / Settings.engineSettings.data.textQualityLevel, "scale.y" : 1 / Settings.engineSettings.data.textQualityLevel}, 0.25, {ease : FlxEase.cubeOut, onComplete: function(tween:FlxTween) {
				scoreTxtTween = null;
				tween.destroy();
			}});
		}
		
		curSection += 1;

		return daRating;
	}

	private function keyShit():Void
	{
		// HOLDING
		// var up = controls.UP;
		// var right = controls.RIGHT;
		// var down = controls.DOWN;
		// var left = controls.LEFT;

		// var upP = controls.UP_P;
		// var rightP = controls.RIGHT_P;
		// var downP = controls.DOWN_P;
		// var leftP = controls.LEFT_P;

		// var upR = controls.UP_R;
		// var rightR = controls.RIGHT_R;
		// var downR = controls.DOWN_R;
		// var leftR = controls.LEFT_R;
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		
		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && generatedMusic)
		{
			boyfriend.holdTimer = 0;
			boyfriend.stunned = false;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			var notesToHit:Array<Note> = [null, null, null, null];
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (controlArray[daNote.noteData % 4]) {
						var can = true;
						if (notesToHit[daNote.noteData % 4] != null) if (notesToHit[daNote.noteData % 4].strumTime < daNote.strumTime) can = false;
						if (can) notesToHit[daNote.noteData % 4] = daNote;
					}
				}
			});
			for (note in notesToHit) {
				if (note != null) goodNoteHit(note);
			}
		}

		if ((up || right || down || left) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		// notes.forEachAlive(function(daNote:Note) {
		// 	if (daNote.mustPress && daNote.tooLate && !daNote.wasGoodHit) {
		// 		noteMiss(daNote.noteData % 4);
		// 		daNote.kill();
		// 		notes.remove(daNote);
		// 		daNote.destroy();
		// 	}
		// });

		for (bf in boyfriends) {
				if (bf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && ((!up && !down && !right && !left) || bf != boyfriend))
				{
					if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss'))
					{
						bf.playAnim('idle');
					}
				}
		}
		

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			// health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			misses++;
			numberOfNotes++;
			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			var rating = "";
			if (!note.isSustainNote)
			{
				rating = popUpScore(note.strumTime);
				combo += 1;
			}
			if (rating == "shit") {
				health -= 0.125;
				noteMiss(note.noteData % 4);
				note.kill();
				notes.remove(note, true);
				note.destroy();
				return;
			}
			switch(rating) {
				case "bad" :
				case "good" :
					health += 0.075;
				case "sick" :
					health += 0.15;
			}

			// if (note.noteData >= 0)
			// 	health += 0.023;
			// else
			// 	health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			if (note.isSustainNote) {
				numberOfNotes += 0.25;
				accuracy += 0.25;
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();
		songEvents.stepHit(curStep);
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	override function beatHit()
	{
		super.beatHit();
		songEvents.beatHit(curBeat);
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			
			for (i => d in dads) {
				d.dance();
			}
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		for (bf in boyfriends) {
			if (!bf.animation.curAnim.name.startsWith("sing"))
			{
				bf.playAnim('idle');
			}
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
	}
}
