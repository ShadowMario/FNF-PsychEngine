package;

import flixel.graphics.FlxGraphic;
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
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import Conductor.Rating;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#else import vlc.MP4Handler; #end
#end


using StringTools;

class PlayState extends MusicBeatState
{
	var noteRows:Array<Array<Array<Note>>> = [[],[]];
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public static var instance:PlayState;
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [];


	private var tauntKey:Array<FlxKey>;

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var hitSoundString:String = ClientPrefs.hitsoundType;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	var randomBotplayText:String;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";

	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	var botplayUsed:Bool = false;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 1750; //just enough for the notes to barely inch off the screen

	public var vocals:FlxSound;

	public var dadGhostTween:FlxTween;
	public var bfGhostTween:FlxTween;
	public var gfGhostTween:FlxTween;
	public var dadGhost:FlxSprite;
	public var bfGhost:FlxSprite;
	public var gfGhost:FlxSprite;
	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;
	public static var death:FlxSprite;
	public static var deathanim:Bool = false;
	public static var dead:Bool = false;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;
	public var judgeColours:Map<String, FlxColor> = [
		"marv" => 0xFFE367E5,
		"sick" => FlxColor.CYAN,
		"good" => FlxColor.LIME,
		"bad" => FlxColor.ORANGE,
		"shit" => FlxColor.RED,
		"miss" => 0xFF7F2626
	];
	public var tgtJudgeColours:Map<String, FlxColor> = [
		"marv" => 0xFFE367E5,
		"sick" => 0xFF00A2E8,
		"good" => 0xFFB5E61D,
		"bad" => 0xFFC3C3C3,
		"shit" => 0xFF7F7F7F,
		"miss" => 0xFF7F2626,
		"cb" => 0xFF7F265A
	];

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float;
	private var displayedHealth:Float;
	public var maxHealth:Float = 2;

	public var totalNotesPlayed:Int = 0;
	public var combo:Int = 0;
	public var missCombo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;
	var songPercentThing:Float = 0;
	var playbackRateDecimal:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var marvs:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public var nps:Int = 0;
	public var maxNPS:Int = 0;
	
	private var allSicks:Bool = true;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var hpDrainLevel:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var sickOnly:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var opponentDrain:Bool = false;
	public static var opponentChart:Bool = false;
	var randomMode:Bool = false;
	var flip:Bool = false;
	var stairs:Bool = false;
	var waves:Bool = false;
	var oneK:Bool = false;
	var randomSpeedThing:Bool = false;
	var trollingMode:Bool = false;
	public var jackingtime:Float = 0;


	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var healthShitText:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;
	var hueh231:FlxSprite;
	var secretsong:FlxSprite;
	var SPUNCHBOB:FlxSprite;

	var notesHitArray:Array<Date> = [];

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var EngineWatermark:FlxText;
	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	//ms timing popup shit
	public var msTxt:FlxText;
	public var msTimer:FlxTimer = null;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var comboTxt:FlxText;
	var missTxt:FlxText;
	var accuracyTxt:FlxText;
	var npsTxt:FlxText;
	var timeTxt:FlxText;
	var timePercentTxt:FlxText;

	var scoreTxtTween:FlxTween;
	var judgementCounter:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	
	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	private var ss:Bool = false;
	public var accuracy:Float = 0.00;

	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	//cam panning
	var moveCamTo:HaxeVector<Float> = new HaxeVector(2);

	var getTheBotplayText:Int = 0;

	var theListBotplay:Array<String> = [];

	override public function create()
	{
		theListBotplay = CoolUtil.coolTextFile(Paths.txt('botplayText'));

		randomBotplayText = theListBotplay[FlxG.random.int(0, theListBotplay.length - 1)];
		//trace('Playback Rate: ' + playbackRate);
		//Paths.clearStoredMemory();
			if (!ClientPrefs.memLeaks)
			{
			#if cpp
			cpp.vm.Gc.enable(true);
			#end

			#if sys
			openfl.system.System.gc();
			#end
			}


		// for lua
		instance = this;


	if (ClientPrefs.moreMaxHP)
	{
	maxHealth = 3;
	} else
	{ 
	maxHealth = 2;
	}

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);
		tauntKey = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('qt_taunt'));

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		if (!ClientPrefs.noMarvJudge) 
		{
		ratingsData.push(new Rating('marv')); 
		}

		var rating:Rating = new Rating('sick');
		rating.ratingMod = 1;
		rating.score = 350;
		rating.noteSplash = true;
		ratingsData.push(rating);
		
		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		hpDrainLevel = ClientPrefs.getGameplaySetting('drainlevel', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		sickOnly = ClientPrefs.getGameplaySetting('onlySicks', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		opponentChart = ClientPrefs.getGameplaySetting('opponentplay', false);
		opponentDrain = ClientPrefs.getGameplaySetting('opponentdrain', false);
		randomMode = ClientPrefs.getGameplaySetting('randommode', false);
		flip = ClientPrefs.getGameplaySetting('flip', false);
		stairs = ClientPrefs.getGameplaySetting('stairmode', false);
		waves = ClientPrefs.getGameplaySetting('wavemode', false);
		oneK = ClientPrefs.getGameplaySetting('onekey', false);
		randomSpeedThing = ClientPrefs.getGameplaySetting('randomspeed', false);
		trollingMode = ClientPrefs.getGameplaySetting('thetrollingever', false);
		jackingtime = ClientPrefs.getGameplaySetting('jacks', 0);


		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;
		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
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

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		dadGhost = new FlxSprite();
		bfGhost = new FlxSprite();
		gfGhost = new FlxSprite();
		add(gfGroup); //Needed for blammed lights
		add(bfGhost);
		add(gfGhost);
		add(dadGhost);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		startLuasOnFolder('stages/' + curStage + '.lua');
		#end
			if(ClientPrefs.communityGameMode)
			{
				SONG.gfVersion = 'gf-bent';
				FlxG.log.add('using the suspicious gf skin, horny ass mf.');
			}
		var gfVersion:String = SONG.gfVersion;
		
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}


			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor

		}
		health = maxHealth / 2;	
		displayedHealth = maxHealth / 2;	

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
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
				}
			}
		}

	if (ClientPrefs.rateNameStuff == 'Quotes')
	{
	ratingStuff = [
		['you suck ass lol', 0.2], //From 0% to 19%
		['you aint doin good', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['funny number', 0.7], //69%
		['nice', 0.8], //From 70% to 79%
		['awesome', 0.9], //From 80% to 89%
		['thats amazing', 1], //From 90% to 99%
		['PERFECT!!!!!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	}
	if (ClientPrefs.rateNameStuff == 'Letters')
	{
	ratingStuff = [
		['HOW?', 0.2], //From 0% to 19%
		['F', 0.4], //From 20% to 39%
		['E', 0.5], //From 40% to 49%
		['D', 0.6], //From 50% to 59%
		['C', 0.69], //From 60% to 68%
		['FUNNY', 0.7], //69%
		['B', 0.8], //From 70% to 79%
		['A', 0.9], //From 80% to 89%
		['S', 0.97], //From 90% to 98%
		['S+', 1], //98% to 99%
		['X', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		dadGhost.visible = false;
		dadGhost.antialiasing = true;
		dadGhost.scale.copyFrom(dad.scale);
		dadGhost.updateHitbox();
		bfGhost.visible = false;
		bfGhost.antialiasing = true;
		bfGhost.scale.copyFrom(boyfriend.scale);
		bfGhost.updateHitbox();
		gfGhost.visible = false;
		gfGhost.antialiasing = true;
		gfGhost.scale.copyFrom(gf.scale);
		gfGhost.updateHitbox();

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		laneunderlayOpponent = new FlxSprite(70, 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlayOpponent.alpha = ClientPrefs.laneUnderlayAlpha;
		laneunderlayOpponent.scrollFactor.set();
		laneunderlayOpponent.screenCenter(Y);
		laneunderlayOpponent.visible = ClientPrefs.laneUnderlay;

		laneunderlay = new FlxSprite(70 + (FlxG.width / 2), 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlay.alpha = ClientPrefs.laneUnderlayAlpha;
		laneunderlay.scrollFactor.set();
		laneunderlay.screenCenter(Y);
		laneunderlay.visible = ClientPrefs.laneUnderlay;

		if (ClientPrefs.laneUnderlay)
		{
			add(laneunderlayOpponent);
			add(laneunderlay);
		}

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');

		if (ClientPrefs.hudType == 'Psych Engine') {
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		}
		if (ClientPrefs.hudType == 'Leather Engine') {
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') {
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("calibri.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		}
		if (ClientPrefs.hudType == 'Kade Engine') {
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 18);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 1;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44; 
		}
		if (ClientPrefs.hudType == 'Dave & Bambi') {
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		}
		if (ClientPrefs.hudType == 'Doki Doki+') {
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("Aller_rg.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		}
		if (ClientPrefs.hudType == 'VS Impostor') {
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 585, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 1;
		timeTxt.visible = showTime;
		if (ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;
		}
		if (ClientPrefs.hudType == "Mic'd Up") {
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 16);
			if (ClientPrefs.downScroll)
				timeTxt.y = FlxG.height - 44;
			timeTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.scrollFactor.set();
			timeTxt.screenCenter(X);
			timeTxt.visible = showTime;
		}


		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		if (ClientPrefs.hudType == 'VS Impostor') {
		timeBarBG = new AttachedSprite('impostorTimeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		// timeBarBG.color = FlxColor.BLACK;
		timeBarBG.antialiasing = false;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);
		

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF2e412e, 0xFF44d844);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
		timeTxt.x += 10;
		timeTxt.y += 4;
		}

		if (ClientPrefs.hudType == 'Psych Engine') {
		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
		}
		if (ClientPrefs.hudType == 'Leather Engine') {
		timeBarBG = new AttachedSprite('healthBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 8);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		timeBarBG.screenCenter(X);
		add(timeBarBG);

				timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
					'songPercent', 0, 1);
				timeBar.scrollFactor.set();
				timeBar.createFilledBar(FlxColor.BLACK, FlxColor.CYAN);
				timeBar.numDivisions = 400;
				timeBar.visible = showTime;
				add(timeBar);
				add(timeTxt);
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') {
		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
		}

		if (ClientPrefs.hudType == 'Kade Engine') {
		timeBarBG = new AttachedSprite('healthBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 8);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		timeBarBG.screenCenter(X);
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
		}

		if (ClientPrefs.hudType == "Mic'd Up") {
		timeBarBG = new AttachedSprite('healthBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 8);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		timeBarBG.screenCenter(X);
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		timeBarBG.sprTracker = timeBar;
			add(timeTxt);
		}

		if (ClientPrefs.hudType == 'Dave & Bambi') {
			timeBarBG = new AttachedSprite('DnBTimeBar');
			timeBarBG.screenCenter(X);
			timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
			timeBarBG.antialiasing = true;
			timeBarBG.scrollFactor.set();
			timeBarBG.visible = showTime;
			timeBarBG.xAdd = -4;
			timeBarBG.yAdd = -4;
			add(timeBarBG);
			
			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
			timeBar.alpha = 0;
			timeBar.visible = showTime;
			add(timeTxt);
			timeBarBG.sprTracker = timeBar;
			timeBar.createFilledBar(FlxColor.GRAY, FlxColor.fromRGB(57, 255, 20));
			insert(members.indexOf(timeBarBG), timeBar);
		}
		if (ClientPrefs.hudType == 'Doki Doki+') {
		timeBarBG = new AttachedSprite('dokiTimeBar');
			timeBarBG.screenCenter(X);
			timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
			timeBarBG.antialiasing = true;
			timeBarBG.scrollFactor.set();
			timeBarBG.visible = showTime;
			timeBarBG.xAdd = -4;
			timeBarBG.yAdd = -4;
			add(timeBarBG);

			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
			timeBar.alpha = 0;
			timeBar.visible = showTime;
			timeBarBG.sprTracker = timeBar;
			timeBar.createGradientBar([FlxColor.TRANSPARENT], [FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), 				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2])]);
			add(timeBar);
			add(timeTxt);
		}
		timePercentTxt = new FlxText(timeBarBG.x + 400, 19, 400, "", 32);
		if (ClientPrefs.hudType == 'Doki Doki+') timePercentTxt.setFormat(Paths.font("Aller_rg.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') timePercentTxt.setFormat(Paths.font("calibri.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Dave & Bambi') timePercentTxt.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType != 'Dave & Bambi' && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+') timePercentTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timePercentTxt.scrollFactor.set();
		timePercentTxt.alpha = 0;
		timePercentTxt.borderSize = 2;
		timePercentTxt.visible = ClientPrefs.songPercentage;
		if(ClientPrefs.downScroll) timePercentTxt.y = FlxG.height - 44;
		if (!showTime) timePercentTxt.screenCenter(X);
		if (ClientPrefs.hudType == 'Kade Engine' && ClientPrefs.hudType == 'Dave & Bambi') timePercentTxt.x = timeBarBG.x + 600;
		add(timePercentTxt);

		healthShitText = new FlxText(timeTxt.x, timeBarBG.y + 160, 400, "", 20);
		healthShitText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Doki Doki+') healthShitText.setFormat(Paths.font("Aller_rg.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') healthShitText.setFormat(Paths.font("calibri.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Dave & Bambi') healthShitText.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		healthShitText.scrollFactor.set();
		healthShitText.alpha = 1;
		healthShitText.borderSize = 2;
		healthShitText.visible = ClientPrefs.healthDisplay;
		healthShitText.cameras = [camHUD];
		if(ClientPrefs.downScroll) healthShitText.y = timeBarBG.y - 160;
		add(healthShitText);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}
		if(ClientPrefs.timeBarType == 'Song Name' && ClientPrefs.hudType == 'VS Impostor')
		{
			timeTxt.size = 14;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();
		
		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		//omg its that ms text from earlier
		msTxt = new FlxText(0, 0, 0, "");
		msTxt.cameras = (ClientPrefs.wrongCameras ? [camGame] : [camHUD]);
		msTxt.scrollFactor.set();
		msTxt.setFormat("vcr.ttf", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') msTxt.setFormat("calibri.ttf", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Dave & Bambi') msTxt.setFormat("comic.ttf", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (ClientPrefs.hudType == 'Doki Doki+') msTxt.setFormat("Aller_rg.ttf", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msTxt.x = 408 + 250;
		msTxt.y = 290 - 25;
		if (PlayState.isPixelStage) {
			msTxt.x = 408 + 260;
			msTxt.y = 290 + 20;
		}
		msTxt.x += ClientPrefs.comboOffset[0];
		msTxt.y -= ClientPrefs.comboOffset[1];
		msTxt.active = false;
		msTxt.visible = false;
		insert(members.indexOf(strumLineNotes), msTxt);

		if (ClientPrefs.hudType == 'Dave & Bambi') 
		{
		if (ClientPrefs.longHPBar)
		{
		healthBarBG = new AttachedSprite('longDnBHealthBar');
		} else
		{
		healthBarBG = new AttachedSprite('DnBHealthBar');
		}
		healthBarBG.y = FlxG.height * 0.89;
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		healthBarBG.visible = !ClientPrefs.hideHud;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, (opponentChart ? LEFT_TO_RIGHT : RIGHT_TO_LEFT), Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'displayedHealth', 0, maxHealth);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		healthBarBG.sprTracker = healthBar;
		insert(members.indexOf(healthBarBG), healthBar);
		}
		if (ClientPrefs.hudType == 'Doki Doki+') 
		{
		if (ClientPrefs.longHPBar)
		{
		healthBarBG = new AttachedSprite('longDokiHealthBar');
		} else
		{
		healthBarBG = new AttachedSprite('dokiHealthBar');
		}
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.visible = !ClientPrefs.hideHud;
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, (opponentChart ? LEFT_TO_RIGHT : RIGHT_TO_LEFT), Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'displayedHealth', 0, maxHealth);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		healthBarBG.sprTracker = healthBar;
		add(healthBar);
		} else if (ClientPrefs.hudType != 'Dave & Bambi' && ClientPrefs.hudType != 'Doki Doki+') {
		if (ClientPrefs.longHPBar)
		{
		healthBarBG = new AttachedSprite('longHealthBar');
		} else
		{
		healthBarBG = new AttachedSprite('healthBar');
		}
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, (opponentChart ? LEFT_TO_RIGHT : RIGHT_TO_LEFT), Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'displayedHealth', 0, maxHealth);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;
		}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		if (ClientPrefs.hudType == 'Kade Engine') {
		// Add Engine watermark
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		EngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		EngineWatermark.scrollFactor.set();
		add(EngineWatermark);
		EngineWatermark.text = SONG.song + " " + CoolUtil.difficultyString() + " | JSE " + MainMenuState.psychEngineJSVersion;
		}
		if (ClientPrefs.hudType == 'Dave & Bambi') {
		// Add Engine watermark
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		EngineWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		EngineWatermark.scrollFactor.set();
		add(EngineWatermark);
		EngineWatermark.text = SONG.song;
		}
		if (ClientPrefs.hudType == 'Doki Doki+') {
		// Add Engine watermark
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		add(EngineWatermark);
		}
		if (ClientPrefs.hudType == 'Leather Engine') {
		// Add Engine watermark BECAUSE THE ENGINE THING IS dumb
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		add(EngineWatermark);
		}
		if (ClientPrefs.hudType == 'VS Impostor') { //unfortunately i have to do this because otherwise enginewatermark calls a null object reference
		// Add Engine watermark
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		add(EngineWatermark);
		}
		if (ClientPrefs.hudType == 'Psych Engine') { //unfortunately i have to do this because otherwise enginewatermark calls a null object reference
		// Add Engine watermark
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		add(EngineWatermark);
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') { //unfortunately i have to do this because otherwise enginewatermark calls a null object reference
		// Add Engine watermark
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		add(EngineWatermark);
		}
		if (ClientPrefs.hudType == "Mic'd Up") { //unfortunately i have to do this because otherwise enginewatermark calls a null object reference
		// Add Engine watermark
		EngineWatermark = new FlxText(4,FlxG.height * 0.9 + 50,0,"", 16);
		add(EngineWatermark);
		}
		
		if (ClientPrefs.hudType == 'Kade Engine')
		{ 		
		scoreTxt = new FlxText(0, healthBarBG.y + 50, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		}
		if (ClientPrefs.hudType == "Mic'd Up")
		{ 
		scoreTxt = new FlxText(healthBarBG.x - (healthBarBG.width / 2), healthBarBG.y - 26, 0, "", 20);
		if (ClientPrefs.downScroll)
			scoreTxt.y = healthBarBG.y + 18;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);
		scoreTxt.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);
		scoreTxt.visible = !ClientPrefs.hideHud;

		missTxt = new FlxText(scoreTxt.x, scoreTxt.y - 26, 0, "", 20);
		if (ClientPrefs.downScroll)
			missTxt.y = scoreTxt.y + 26;
		missTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);
		missTxt.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
		missTxt.scrollFactor.set();
		add(missTxt);
		missTxt.visible = !ClientPrefs.hideHud;

		accuracyTxt = new FlxText(missTxt.x, missTxt.y - 26, 0, "", 20);
		if (ClientPrefs.downScroll)
			accuracyTxt.y = missTxt.y + 26;
		accuracyTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);
		accuracyTxt.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
		accuracyTxt.scrollFactor.set();
		add(accuracyTxt);
		accuracyTxt.visible = !ClientPrefs.hideHud;

		comboTxt = new FlxText(scoreTxt.x, scoreTxt.y + 26, 0, "", 21);
		if (ClientPrefs.downScroll)
			comboTxt.y = scoreTxt.y - 26;
		comboTxt.setFormat(Paths.font("vcr.ttf"), 21, FlxColor.WHITE, RIGHT);
		comboTxt.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
		comboTxt.scrollFactor.set();
		add(comboTxt);
		comboTxt.visible = !ClientPrefs.hideHud;

		npsTxt = new FlxText(accuracyTxt.x, accuracyTxt.y - 46, 0, "", 20);
		if (ClientPrefs.downScroll)
			npsTxt.y = accuracyTxt.y + 46;
		npsTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);
		npsTxt.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
		npsTxt.scrollFactor.set();
		add(npsTxt);
		npsTxt.visible = !ClientPrefs.hideHud;
		}
		if (ClientPrefs.hudType == 'Leather Engine')
		{ 		
		scoreTxt = new FlxText(0, healthBarBG.y + 50, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		}
		if (ClientPrefs.hudType == 'Dave & Bambi') 
		{
		scoreTxt = new FlxText(0, healthBarBG.y + 40, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		}
		if (ClientPrefs.hudType == 'Psych Engine') 
		{
		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		}
		if (ClientPrefs.hudType == 'Doki Doki+') 
		{
		scoreTxt = new FlxText(0, healthBarBG.y + 48, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("Aller_rg.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') 
		{
		scoreTxt = new FlxText(0, healthBarBG.y + 48, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("calibri.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		}
		if (ClientPrefs.hudType == 'VS Impostor') 
		{
            	scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
            	scoreTxt.scrollFactor.set();
            	scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		}

		judgementCounter = new FlxText(0, FlxG.height / 2 - 20, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.visible = ClientPrefs.ratingCounter;
		if (!ClientPrefs.noMarvJudge)
		{
		judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed/totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nMarvelous!!!: ' + marvs + '\nSicks!!: ' + sicks + '\nGoods!: ' + goods + '\nBads: ' + bads + '\nShits: ' + shits + '\nMisses: ' + songMisses;
		if (ClientPrefs.hudType == 'Doki Doki+') judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nVery Doki: ' + marvs + '\nDoki: ' + sicks + '\nGood: ' + goods + '\nOK: ' + bads + '\nNO: ' + shits + '\nMiss: ' + songMisses;
		if (ClientPrefs.hudType == 'VS Impostor') judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nSO SUSSY: ' + marvs + '\nSussy: ' + sicks + '\nSus: ' + goods + '\nSad: ' + bads + '\nAss: ' + shits + '\nMiss: ' + songMisses;
		}
		if (ClientPrefs.noMarvJudge)
		{
		judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nSicks!!: ' + sicks + '\nGoods!: ' + goods + '\nBads: ' + bads + '\nShits: ' + shits + '\nMisses: ' + songMisses;
		if (ClientPrefs.hudType == 'Doki Doki+') judgementCounter.text = 'Percent of Notes Hit' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nDoki: ' + sicks + '\nGood: ' + goods + '\nOK: ' + bads + '\nNO: ' + shits + '\nMiss: ' + songMisses;
		if (ClientPrefs.hudType == 'VS Impostor') judgementCounter.text = 'Percent of Notes Hit' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nSussy: ' + sicks + '\nSus: ' + goods + '\nSad: ' + bads + '\nAss: ' + shits + '\nMiss: ' + songMisses;
		}
		add(judgementCounter);


		if (ClientPrefs.hudType == 'Psych Engine')
		{
		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll) 
			botplayTxt.y = timeBarBG.y - 78;
		}
		if (ClientPrefs.hudType == "Mic'd Up")
		{
		botplayTxt = new FlxText((healthBarBG.width / 2), healthBar.y, 0, "AutoPlayCPU", 20);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.screenCenter(X);
		botplayTxt.borderSize = 3;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll) 
			botplayTxt.y = timeBarBG.y - 78;
		}
		if (ClientPrefs.hudType == 'Leather Engine')
		{
		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "", 32); //yeah leather engine has no botplay text soooo
		add(botplayTxt);
		if (ClientPrefs.downScroll) 
			botplayTxt.y = timeBarBG.y - 78;
		botplayTxt.visible = false;
		}
		if (ClientPrefs.hudType == 'Kade Engine')
		{
		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll) 
			botplayTxt.y = timeBarBG.y - 78;
		}
		if (ClientPrefs.hudType == 'Doki Doki+')
		{
		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("Aller_rg.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll) 
			botplayTxt.y = timeBarBG.y - 78;
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4')
		{
		botplayTxt = new FlxText(400, timeBarBG.y + (ClientPrefs.downScroll ? -78 : 55), FlxG.width - 800, "[BUTTPLUG]", 32);
		botplayTxt.setFormat(Paths.font("calibri.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll) 
			botplayTxt.y = timeBarBG.y - 78;
		}
		if (ClientPrefs.hudType == 'Dave & Bambi')
		{
		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("comic.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll) 
			botplayTxt.y = timeBarBG.y - 78;
		}
		if (ClientPrefs.hudType == 'VS Impostor')
		{
		botplayTxt = new FlxText(400, healthBarBG.y - 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll)
		{
			botplayTxt.y = timeBarBG.y - 78;
		}
		}

		laneunderlayOpponent.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		EngineWatermark.cameras = [camHUD];
		judgementCounter.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if(ClientPrefs.hudType == "Mic'd Up")
		{
		missTxt.cameras = [camHUD];
		accuracyTxt.cameras = [camHUD];
		npsTxt.cameras = [camHUD];
		comboTxt.cameras = [camHUD];
		}
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		timePercentTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		// WINDOW TITLE POG
		MusicBeatState.windowNameSuffix = " - " + SONG.song + " " + (isStoryMode ? "(Story Mode)" : "(Freeplay)");
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			startLuasOnFolder('custom_notetypes/' + notetype + '.lua');
		}
		for (event in eventPushedMap.keys())
		{
			startLuasOnFolder('custom_events/' + event + '.lua');
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventNoteEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
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
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if (hitSoundString != "none")
			hitsound = FlxG.sound.load(Paths.sound("hitsounds/" + Std.string(hitSoundString).toLowerCase()));
		if (hitSoundString == 'Randomized')
			{
			hitsound = FlxG.sound.load(Paths.sound("hitsounds/" + 'osu!mania'));
			hitsound2 = FlxG.sound.load(Paths.sound("hitsounds/" + 'dave and bambi'));
			hitsound3 = FlxG.sound.load(Paths.sound("hitsounds/" + 'indie cross'));
			hitsound4 = FlxG.sound.load(Paths.sound("hitsounds/" + 'snap'));
			hitsound5 = FlxG.sound.load(Paths.sound("hitsounds/" + 'clap'));
			hitsound6 = FlxG.sound.load(Paths.sound("hitsounds/" + 'generic click'));
			hitsound7 = FlxG.sound.load(Paths.sound("hitsounds/" + 'keyboard click'));
			hitsound8 = FlxG.sound.load(Paths.sound("hitsounds/" + 'vine boom'));
			hitsound9 = FlxG.sound.load(Paths.sound("hitsounds/" + 'adofai'));
			}
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		if(ClientPrefs.hitsoundVolume > 0 && hitSoundString == 'Randomized') 
			{
			precacheList.set('hitsound', 'sound');
			precacheList.set('hitsound2', 'sound');
			precacheList.set('hitsound3', 'sound');
			precacheList.set('hitsound4', 'sound');
			precacheList.set('hitsound5', 'sound');
			precacheList.set('hitsound6', 'sound');
			precacheList.set('hitsound7', 'sound');
			precacheList.set('hitsound8', 'sound');
			precacheList.set('hitsound9', 'sound');
			hitsound.volume = ClientPrefs.hitsoundVolume;
			hitsound.pitch = playbackRate;
			hitsound2.volume = ClientPrefs.hitsoundVolume;
			hitsound2.pitch = playbackRate;
			hitsound3.volume = ClientPrefs.hitsoundVolume;
			hitsound3.pitch = playbackRate;
			hitsound4.volume = ClientPrefs.hitsoundVolume;
			hitsound4.pitch = playbackRate;
			hitsound5.volume = ClientPrefs.hitsoundVolume;
			hitsound5.pitch = playbackRate;
			hitsound6.volume = ClientPrefs.hitsoundVolume;
			hitsound6.pitch = playbackRate;
			hitsound7.volume = ClientPrefs.hitsoundVolume;
			hitsound7.pitch = playbackRate;
			hitsound8.volume = ClientPrefs.hitsoundVolume;
			hitsound8.pitch = playbackRate;
			hitsound9.volume = ClientPrefs.hitsoundVolume;
			hitsound9.pitch = playbackRate;
			}
		hitsound.volume = ClientPrefs.hitsoundVolume;
		hitsound.pitch = playbackRate;
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end


		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		callOnLuas('onCreatePost', []);

		super.create();

		if(cpuControlled && ClientPrefs.randomBotplayText && ClientPrefs.hudType != 'Leather Engine')
			{
				botplayTxt.text = theListBotplay[FlxG.random.int(0, theListBotplay.length - 1)];
			}

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		//Paths.clearUnusedMemory();
		
		CustomFadeTransition.nextCamera = camOther;
		if(eventNotes.length < 1) checkEventNote();
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		if (ClientPrefs.ogHP) {
		if (opponentChart) healthBar.createFilledBar(0xFF66FF33, 0xFFFF0000);
		else healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		} else {
		if (!opponentChart) healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		else healthBar.createFilledBar(FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]),
			FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
		}

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
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
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
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
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
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
										camHUD.visible = true;
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

	function camPanRoutine(anim:String = 'singUP', who:String = 'bf'):Void {
		var fps:Float = FlxG.updateFramerate;
		final bfCanPan:Bool = SONG.notes[curSection].mustHitSection;
		final dadCanPan:Bool = !SONG.notes[curSection].mustHitSection;
		var clear:Bool = false;
		switch (who) {
			case 'bf': clear = bfCanPan;
			case 'oppt': clear = dadCanPan;
		}
		//FlxG.elapsed is stinky poo poo for this, it just makes it look jank as fuck
		if (clear) {
			if (fps == 0) fps = 1;
			switch (anim.split('-')[0])
			{
				case 'singUP': moveCamTo[1] = -40*ClientPrefs.panIntensity*240/fps;
				case 'singDOWN': moveCamTo[1] = 40*ClientPrefs.panIntensity*240/fps;
				case 'singLEFT': moveCamTo[0] = -40*ClientPrefs.panIntensity*240/fps;
				case 'singRIGHT': moveCamTo[0] = 40*ClientPrefs.panIntensity*240/fps;
			}
		}
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
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
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
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

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

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

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
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

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);

	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);

		if (ClientPrefs.coolGameplay)
		{
			hueh231 = new FlxSprite();
			hueh231.frames = Paths.getSparrowAtlas('dokistuff/coolgameplay');
			hueh231.animation.addByPrefix('idle', 'Symbol', 24, true);
			hueh231.animation.play('idle');
			hueh231.antialiasing = ClientPrefs.globalAntialiasing;
			hueh231.scrollFactor.set();
			hueh231.setGraphicSize(Std.int(hueh231.width / FlxG.camera.zoom));
			hueh231.updateHitbox();
			hueh231.screenCenter();
			hueh231.cameras = [camGame];
			add(hueh231);
		}
		if (SONG.song.toLowerCase() == 'anti-cheat-song')
		{
			secretsong = new FlxSprite().loadGraphic(Paths.image('secretSong'));
			secretsong.antialiasing = ClientPrefs.globalAntialiasing;
			secretsong.scrollFactor.set();
			secretsong.setGraphicSize(Std.int(secretsong.width / FlxG.camera.zoom));
			secretsong.updateHitbox();
			secretsong.screenCenter();
			secretsong.cameras = [camGame];
			add(secretsong);
		}
		if (ClientPrefs.middleScroll || ClientPrefs.mobileMidScroll)
		{
			laneunderlayOpponent.alpha = 0;
			laneunderlay.screenCenter(X);
		}

		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			/*for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}
			*/

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.cameras = [camHUD];
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						insert(members.indexOf(notes), countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000 / playbackRate, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.cameras = [camHUD];
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						insert(members.indexOf(notes), countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000 / playbackRate, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.cameras = [camHUD];
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000 / playbackRate, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || !ClientPrefs.opponentStrums && ClientPrefs.mobileMidScroll || ClientPrefs.middleScroll || !note.mustPress)
					{
							note.alpha *= 0.35;
					}
					if(ClientPrefs.opponentStrums || !ClientPrefs.opponentStrums && ClientPrefs.mobileMidScroll || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
						if(ClientPrefs.mobileMidScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		if (SONG.song.toLowerCase() == 'anti-cheat-song') 
		{
		FlxG.sound.music.onComplete = infiniteLoop.bind();
		}
		if (!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song' && SONG.song.toLowerCase() != 'desert bus') 
		{
		FlxG.sound.music.onComplete = finishSong.bind();
		}
		if (trollingMode) 
		{
		FlxG.sound.music.onComplete = loopSong.bind();
		}
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}
		var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
		songPercent = (curTime / songLength);


		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		timeBar.scale.x = 0.01;
		timeBarBG.scale.x = 0.01;
		FlxTween.tween(timeBar, {alpha: 1, "scale.x": 1}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(timeBarBG, {alpha: 1, "scale.x": 1}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timePercentTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});



		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}
	public function lerpSongSpeed(num:Float, time:Float):Void
	{
		FlxTween.num(playbackRate, num, time, {onUpdate: function(tween:FlxTween){
			var ting = FlxMath.lerp(playbackRate, num, tween.percent);
			if (ting != 0) //divide by 0 is a verry bad
				playbackRate = ting; //why cant i just tween a variable

			FlxG.sound.music.time = Conductor.songPosition;
			resyncVocals();
		}});
	}

	var debugNum:Int = 0;
	var stair:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);
		notes.visible = ClientPrefs.showNotes; //that was easier than expected

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					if (!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song') {
					eventNotes.push(subEvent);
					eventPushed(subEvent);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = 0;
				if (!randomMode && !flip && !stairs	&& !waves)
				{
				daNoteData = Std.int(songNotes[1] % 4);
				}
				if (oneK)
				{
				daNoteData = 2;
				}
				if (randomMode || randomMode && flip || randomMode && flip && stairs || randomMode && flip && stairs && waves) { //gotta specify that random mode must at least be turned on for this to work
				daNoteData = FlxG.random.int(0, 3);
				}
				if (flip && !stairs && !waves) {
				daNoteData = Std.int(Math.abs((songNotes[1] % 4) - 3));
				}
				if (stairs && !waves) {
				daNoteData = stair % 4;
				stair++;
				}
				if (waves) {
						switch (stair % 6)
							{
								case 0 | 1 | 2 | 3:
									daNoteData = stair % 6;
								case 4:
									daNoteData = 2;
								case 5:
									daNoteData = 1;
							}
				stair++;
				}
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3 && !opponentChart)
				{
					gottaHitNote = !section.mustHitSection;
				}
				else if (songNotes[1] <= 3 && opponentChart)
				{
					gottaHitNote = !section.mustHitSection;
				}

				if (!gottaHitNote && ClientPrefs.mobileMidScroll)
				{
					songNotes[3] = 'Behind Note';
				}
				if (gottaHitNote)
				{
					totalNotes += 1;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				if (ClientPrefs.doubleGhost)
					{
					swagNote.row = Conductor.secsToRow(daStrumTime);
					if(noteRows[gottaHitNote?0:1][swagNote.row]==null)
						noteRows[gottaHitNote?0:1][swagNote.row]=[];
					noteRows[gottaHitNote ? 0 : 1][swagNote.row].push(swagNote);
					}
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(swagNote.sustainLength / Conductor.stepCrochet);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
					}
				}
				if (!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song')
				{
				if(!noteTypeMap.exists(swagNote.noteType) && !trollingMode) {
					noteTypeMap.set(swagNote.noteType, true);
				}
				}
				var jackNote:Note;

				if (jackingtime > 0)
				{
					for (i in 0...Std.int(jackingtime))
					{
						jackNote = new Note(swagNote.strumTime + (15000/SONG.bpm) * (i + 1), swagNote.noteData, oldNote);
						jackNote.scrollFactor.set();

				jackNote.mustPress = swagNote.mustPress;
				jackNote.sustainLength = swagNote.sustainLength;
				jackNote.gfNote = swagNote.gfNote;
				jackNote.noteType = swagNote.noteType;
				if (ClientPrefs.doubleGhost)
					{
					jackNote.row = Conductor.secsToRow(daStrumTime);
					if(noteRows[gottaHitNote?0:1][jackNote.row]==null)
						noteRows[gottaHitNote?0:1][jackNote.row]=[];
					noteRows[gottaHitNote ? 0 : 1][jackNote.row].push(jackNote);
					}

						unspawnNotes.push(jackNote);

						jackNote.mustPress = swagNote.mustPress;

						if (jackNote.mustPress)
						{
							jackNote.x += FlxG.width / 2; // general offset
							totalNotes += 1;
						}
						if (!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song')
						{
						if(!noteTypeMap.exists(jackNote.noteType)) {
							noteTypeMap.set(jackNote.noteType, true);
						}
						}
					}
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				eventNotes.push(subEvent);
				if(!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song')
				{
				eventPushed(subEvent);
				}
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	private function generateTrollSongShit(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		/*
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));
		*/ //don't load the audio again, that just takes up more memory
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		notes = new FlxTypedGroup<Note>();
		add(notes);
		notes.visible = ClientPrefs.showNotes; //that was easier than expected

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					if (!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song')
					{
					eventNotes.push(subEvent);
					eventPushed(subEvent);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = 0;
				if (!randomMode && !flip && !stairs	&& !waves)
				{
				daNoteData = Std.int(songNotes[1] % 4);
				}
				if (oneK)
				{
				daNoteData = 2;
				}
				if (randomMode || randomMode && flip || randomMode && flip && stairs || randomMode && flip && stairs && waves) { //gotta specify that random mode must at least be turned on for this to work
				daNoteData = FlxG.random.int(0, 3);
				}
				if (flip && !stairs && !waves) {
				daNoteData = Std.int(Math.abs((songNotes[1] % 4) - 3));
				}
				if (stairs && !waves) {
				daNoteData = stair % 4;
				stair++;
				}
				if (waves) {
						switch (stair % 6)
							{
								case 0 | 1 | 2 | 3:
									daNoteData = stair % 6;
								case 4:
									daNoteData = 2;
								case 5:
									daNoteData = 1;
							}
				stair++;
				}
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3 && !opponentChart)
				{
					gottaHitNote = !section.mustHitSection;
				}
				else if (songNotes[1] <= 3 && opponentChart)
				{
					gottaHitNote = !section.mustHitSection;
				}

				if (!gottaHitNote && ClientPrefs.mobileMidScroll)
				{
					songNotes[3] = 'Behind Note';
				}

				if (gottaHitNote)
				{
					totalNotes += 1;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				if (ClientPrefs.doubleGhost)
					{
					swagNote.row = Conductor.secsToRow(daStrumTime);
					if(noteRows[gottaHitNote?0:1][swagNote.row]==null)
						noteRows[gottaHitNote?0:1][swagNote.row]=[];
					noteRows[gottaHitNote ? 0 : 1][swagNote.row].push(swagNote);
					}
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(swagNote.sustainLength / Conductor.stepCrochet);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
					}
				}
				if (!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song') {
				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
				} //uhh
				var jackNote:Note;

				if (jackingtime > 0)
				{
					for (i in 0...Std.int(jackingtime))
					{
						jackNote = new Note(swagNote.strumTime + 70 * (i + 1), swagNote.noteData, oldNote);
						jackNote.scrollFactor.set();

				jackNote.mustPress = swagNote.mustPress;
				jackNote.sustainLength = swagNote.sustainLength;
				jackNote.gfNote = swagNote.gfNote;
				jackNote.noteType = swagNote.noteType;
				if (ClientPrefs.doubleGhost)
					{
					jackNote.row = Conductor.secsToRow(daStrumTime);
					if(noteRows[gottaHitNote?0:1][jackNote.row]==null)
						noteRows[gottaHitNote?0:1][jackNote.row]=[];
					noteRows[gottaHitNote ? 0 : 1][jackNote.row].push(jackNote);
					}

						unspawnNotes.push(jackNote);

						jackNote.mustPress = swagNote.mustPress;
						if (!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song')
						{
						if(!noteTypeMap.exists(jackNote.noteType)) {
							noteTypeMap.set(jackNote.noteType, true);
						}
						}
					}
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				eventNotes.push(subEvent);
				if(!trollingMode && SONG.song.toLowerCase() != 'anti-cheat-song')
				{
				eventPushed(subEvent);
				}
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByTime);
	}
	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event) && SONG.song.toLowerCase() != 'anti-cheat-song') {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnLuas('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != FunkinLua.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll || ClientPrefs.mobileMidScroll) targetAlpha = ClientPrefs.oppNoteAlpha;
				if (ClientPrefs.mobileMidScroll) opponentStrums.members[i].x == FlxG.width - 2; //make it so that you're unable to see the opponent's strums if you have mobile styled middlescroll on
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll || ClientPrefs.mobileMidScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				if (!opponentChart || opponentChart && ClientPrefs.middleScroll || opponentChart && ClientPrefs.mobileMidScroll || !opponentChart && ClientPrefs.mobileMidScroll) playerStrums.add(babyArrow);
			else if (ClientPrefs.mobileMidScroll) insert(members.indexOf(playerStrums), babyArrow);
			else opponentStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				if(ClientPrefs.mobileMidScroll)
				{
					babyArrow.x += FlxG.width / 2;
				}
				if (!opponentChart || opponentChart && ClientPrefs.mobileMidScroll || opponentChart && ClientPrefs.mobileMidScroll || !opponentChart && ClientPrefs.mobileMidScroll) opponentStrums.add(babyArrow);
			else if (ClientPrefs.mobileMidScroll) insert(members.indexOf(playerStrums), babyArrow);
				else playerStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
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

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
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

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
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
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
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
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		healthShitText.text = 'HP Remaining: ' + FlxMath.roundDecimal(health * 50, 2) + '%';
				healthBar.setRange(0, maxHealth);

		callOnLuas('onUpdate', [elapsed]);

		if (goods > 0 || bads > 0 || shits > 0 || songMisses > 0 && sickOnly)
		{
			// if it isn't a sick, and sick only mode is on YOU DIE
			if (sickOnly)
			{
				health = -2;
			}
		}
		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x + moveCamTo[0]/102, camFollow.x + moveCamTo[0]/102, lerpVal), FlxMath.lerp(camFollowPos.y + moveCamTo[1]/102, camFollow.y + moveCamTo[1]/102, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
			var panLerpVal:Float = CoolUtil.clamp(elapsed * 4.4 * cameraSpeed, 0, 1);
			moveCamTo[0] = FlxMath.lerp(moveCamTo[0], 0, panLerpVal);
			moveCamTo[1] = FlxMath.lerp(moveCamTo[1], 0, panLerpVal);
		}

		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 / playbackRate < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		super.update(elapsed);

		if (ClientPrefs.smoothHealth && ClientPrefs.smoothHealthType == 'Indie Cross')
		{
		if (ClientPrefs.framerate > 60)
		{
		displayedHealth = FlxMath.lerp(displayedHealth, health, .1);
		} else if (ClientPrefs.framerate == 60) 
		{
		displayedHealth = FlxMath.lerp(displayedHealth, health, .4);
		}
		}
		if (ClientPrefs.smoothHealth && ClientPrefs.smoothHealthType == 'Golden Apple 1.5')
		{
		displayedHealth = FlxMath.lerp(displayedHealth, health, CoolUtil.boundTo(elapsed * 20, 0, 1));
		}
		if (!ClientPrefs.smoothHealth) //so basically don't make the health smooth if you have that off
		{
		displayedHealth = health;
		}

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);
		if (ClientPrefs.hudType == 'Kade Engine') {
		scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Combo: ' + combo + ' | NPS: ' + nps + ' | Accuracy: ';
		if(cpuControlled) 
			scoreTxt.text = 'Bot Score: ' + songScore + ' | Combo: ' + combo + ' | Bot NPS: ' + nps + ' | Botplay Mode';
		if(ratingName != '?' && !cpuControlled)
			scoreTxt.text += Highscore.floorDecimal(ratingPercent * 100, 2) + '% | ' + ratingFC + ratingCool;
			else if (!cpuControlled)
			scoreTxt.text += '0% | N/A';
		}
		if (ClientPrefs.hudType == "Mic'd Up") {
		if (!cpuControlled)
		{
		comboTxt.text = "Combo: " + combo;
		scoreTxt.text = "Score: " + songScore;
		missTxt.text = "Misses: " + songMisses;
		accuracyTxt.text = "Accuracy: " + Highscore.floorDecimal(ratingPercent * 100, 2) + "% | " + ratingFC + " | " + ratingCool;
		npsTxt.text = "\nNPS: " + nps;
		}
		
		if(cpuControlled) 
		{
		scoreTxt.text = "Bot Score: " + songScore;
		missTxt.text = "Bot Combo: " + combo;
		accuracyTxt.text = "Bot NPS: " + nps;
		npsTxt.text = "Botplay Mode";
		}
		}
		if (ClientPrefs.hudType == 'Doki Doki+') {
		scoreTxt.text = 'Score: ' + songScore + ' | Breaks: ' + songMisses + ' | Combo: ' + combo + ' | NPS: ' + nps + ' | Accuracy: ';
		if(cpuControlled) 
			scoreTxt.text = 'Bot Score: ' + songScore + ' | Combo: ' + combo + ' | Bot NPS: ' + nps + ' | Botplay Mode';
		if(ratingName != '?' && !cpuControlled)
			scoreTxt.text += Highscore.floorDecimal(ratingPercent * 100, 2) + '% | ' + ratingFC + ratingCool;
			else if (!cpuControlled)
			scoreTxt.text += '0% | N/A';
		}
		if (ClientPrefs.hudType == 'Dave & Bambi') {
		scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Combo: ' + combo + ' | NPS: ' + nps + ' | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% | ' + ratingFC;
		if(cpuControlled) 
			scoreTxt.text = 'Bot Score: ' + songScore + ' | Combo: ' + combo + ' | Bot NPS: ' + nps + ' | Botplay Mode';
		}
		if (ClientPrefs.hudType == 'Psych Engine') {
		scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Combo: ' + combo + ' | NPS: ' + nps + ' | Rating: ' + ratingName;
		if(cpuControlled) 
			scoreTxt.text = 'Botplay Score: ' + songScore + ' | Combo: ' + combo + ' | Bot NPS: ' + nps + ' | funny botplay mode!!!!!';
		if(ratingName != '?')
			scoreTxt.text += ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;
		}
		if (ClientPrefs.hudType == 'Leather Engine') {
		scoreTxt.text = '< Score: ' + songScore + ' ~ Misses: ' + songMisses + ' ~ Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ~ ' + ratingName + ' (' + ratingFC + ') >';
		if(cpuControlled) 
			scoreTxt.text = 'Bot Score: ' + songScore + ' | Combo: ' + combo + ' | Bot NPS: ' + nps + ' | Botplay Mode';
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4') {
		scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Combo: ' + combo + ' | Rating: ' + ratingName + ' | NPS: ' + nps;
		if(cpuControlled) 
			scoreTxt.text = 'Botplay Score: ' + songScore + ' | Combo: ' + combo + ' | Bot NPS: ' + nps + ' | Rating: funny botplay mode!!!!!';
		if(ratingName != '?')
			scoreTxt.text += ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;
		}
		if (ClientPrefs.hudType == 'VS Impostor') {
				scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Combo: ' + combo + ' | NPS: ' + nps;
				
				scoreTxt.text += ' | Accuracy: ';
				//
				if (ratingName != '?')
					scoreTxt.text += '' + ((Math.floor(ratingPercent * 10000) / 100)) + '%';
				if (!cpuControlled) // why would it ever be less than im stupid
					scoreTxt.text += ratingFC;
		if(cpuControlled) 
			scoreTxt.text = 'Bot Score: ' + songScore + ' | Combo: ' + combo + ' | Bot NPS: ' + nps + '';
		}

		if(botplayTxt.visible && ClientPrefs.hudType != "Mic'd Up" && ClientPrefs.hudType != 'Kade Engine') {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180 * playbackRate);
		}
		if(cpuControlled && ClientPrefs.randomBotplayText) {
			if(botplayTxt.text == "this text is gonna kick you out of botplay in 10 seconds" && !botplayUsed || botplayTxt.text == "Your Botplay Free Trial will end in 10 seconds." && !botplayUsed)
				{
					botplayUsed = true;
					new FlxTimer().start(10, function(tmr:FlxTimer)
						{
							cpuControlled = false;
							botplayUsed = false;
							botplayTxt.visible = false;
						});
				}
			if(botplayTxt.text == "you have 10 seconds to run." && !botplayUsed)
				{
					botplayUsed = true;
					new FlxTimer().start(10, function(tmr:FlxTimer)
						{
							var vidSpr:FlxSprite;
							var videoDone:Bool = true;
							var video:MP4Handler = new MP4Handler(); // it plays but it doesn't show???
							vidSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
							add(vidSpr);
							video.playVideo(Paths.video('scary'), false, false);
							video.finishCallback = function()
							{
								videoDone = true;
								vidSpr.visible = false;
								Sys.exit(0);
							};
						});
				}
			if(botplayTxt.text == "you're about to die in 30 seconds" && !botplayUsed)
				{
					botplayUsed = true;
					new FlxTimer().start(30, function(tmr:FlxTimer)
						{
							health = 0;
						});
				}
			if(botplayTxt.text == "3 minutes until Boyfriend steals your liver." && !botplayUsed)
				{
				var title:String = 'Incoming Alert from Boyfriend';
				var message:String = '3 minutes until Boyfriend steals your liver!';
				FlxG.sound.music.pause();
				vocals.pause();

				lime.app.Application.current.window.alert(message, title);
				FlxG.sound.music.resume();
				vocals.resume();
					botplayUsed = true;
					new FlxTimer().start(180, function(tmr:FlxTimer)
						{
							Sys.exit(0);
						});
				}
			if(botplayTxt.text == "3 minutes until I steal your liver." && !botplayUsed)
				{
				var title:String = 'Incoming Alert from Jordan';
				var message:String = '3 minutes until I steal your liver.';
				FlxG.sound.music.pause();
				vocals.pause();

				lime.app.Application.current.window.alert(message, title);
				FlxG.sound.music.resume();
				vocals.resume();
					botplayUsed = true;
					new FlxTimer().start(180, function(tmr:FlxTimer)
						{
							Sys.exit(0);
						});
				}
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			if (!ClientPrefs.antiCheatEnable)
			{
			openChartEditor();
			}
			if (ClientPrefs.antiCheatEnable)
			{
			PlayState.SONG = Song.loadFromJson('Anti-cheat-song', 'Anti-cheat-song');
			LoadingState.loadAndSwitchState(new PlayState());
			} 
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (ClientPrefs.iconBounceType == 'Old Psych') {
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		}
		if (ClientPrefs.iconBounceType == 'Dave and Bambi') {
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.9 / playbackRate)),Std.int(FlxMath.lerp(150, iconP1.height, 0.9 / playbackRate)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.9 / playbackRate)),Std.int(FlxMath.lerp(150, iconP2.height, 0.9 / playbackRate)));
		}
		if (ClientPrefs.iconBounceType == 'New Psych') {
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();
		}
		if (ClientPrefs.iconBounceType == 'VS Steve') {
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();
		}

		if (ClientPrefs.iconBounceType == 'Golden Apple') {
		iconP1.centerOffsets();
		iconP2.centerOffsets();
		}
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		
		if (ClientPrefs.smoothHealth && ClientPrefs.smoothHealthType != 'Golden Apple 1.5' || !ClientPrefs.smoothHealth) //checks if you're using smooth health. if you are, but are not using the indie cross one then you know what that means
		{
		iconP1.x = (opponentChart ? -593 : 0) + healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentChart ? -100 : 100), 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = (opponentChart ? -593 : 0) + healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentChart ? -100 : 100), 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		}
		if (ClientPrefs.smoothHealth && ClientPrefs.smoothHealthType == 'Golden Apple 1.5') //really makes it feel like the gapple 1.5 build's health tween
		{
		var percent:Float = 1 - (opponentChart ? displayedHealth / maxHealth * -1 : displayedHealth / maxHealth); //checks if you're playing as the opponent. if so, uses the negative percent, otherwise uses the normal one
		iconP1.x = (opponentChart ? -593 : 0) + healthBar.x + (healthBar.width * percent) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = (opponentChart ? -593 : 0) + healthBar.x + (healthBar.width * percent) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		}

		if (generatedMusic) {
			if (startedCountdown && canPause && !endingSong) {
				var endingTimeLimit:Int = (playbackRate > 2 ? 100 : 20);
				if (playbackRate > 8) endingTimeLimit = 200;
				if (playbackRate > 12) endingTimeLimit = 300;
				if (playbackRate > 20) endingTimeLimit = 500;
				if (playbackRate > 40) endingTimeLimit = 800;
				if (playbackRate > 50) endingTimeLimit = 1000;
				if (playbackRate > 60) endingTimeLimit = 2000;
				if (playbackRate > 80) endingTimeLimit = 4000;
				if (playbackRate > 125) endingTimeLimit = 5000;
				if (playbackRate > 140) endingTimeLimit = 6000;
				if (playbackRate > 250) endingTimeLimit = 10000;
				if (playbackRate > 500) endingTimeLimit = 5000;
				if (playbackRate > 750) endingTimeLimit = 2500;
				if (playbackRate > 1000) endingTimeLimit = 1000;

				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (FlxG.sound.music.length - Conductor.songPosition <= endingTimeLimit && trollingMode) { //stop crashes when playing normally
					Conductor.songPosition = FlxG.sound.music.length;
					loopSong();
				}
			}
		}

				if (Conductor.songPosition >= 8000 && SONG.song.toLowerCase() == 'desert bus') { //stop crashes when playing normally
					FlxG.sound.music.volume = 0;
				}

				if (28820000 - Conductor.songPosition <= 20 && SONG.song.toLowerCase() == 'desert bus') { //stop crashes when playing normally
					endSong();
				}

		if (health > maxHealth)
			health = maxHealth;

		if (iconP1.animation.frames == 3) {
			if (healthBar.percent < 20)
			(opponentChart ? iconP2 : iconP1).animation.curAnim.curFrame = 1;
			else if (healthBar.percent > 80)
			(opponentChart ? iconP2 : iconP1).animation.curAnim.curFrame = 2;
			else
			(opponentChart ? iconP2 : iconP1).animation.curAnim.curFrame = 0;
		} else {
			if (healthBar.percent < 20)
			(opponentChart ? iconP2 : iconP1).animation.curAnim.curFrame = 1;
		else
			(opponentChart ? iconP2 : iconP1).animation.curAnim.curFrame = 0;
		}
		if (iconP2.animation.frames == 3) {
			if (healthBar.percent > 80)
			(opponentChart ? iconP1 : iconP2).animation.curAnim.curFrame = 1;
			else if (healthBar.percent < 20)
			(opponentChart ? iconP1 : iconP2).animation.curAnim.curFrame = 2;
		else
			(opponentChart ? iconP1 : iconP2).animation.curAnim.curFrame = 0;
		} else {
			if (healthBar.percent > 80)
			(opponentChart ? iconP1 : iconP2).animation.curAnim.curFrame = 1;
		else
			(opponentChart ? iconP1 : iconP2).animation.curAnim.curFrame = 0;
		}
		
		/*
		if (healthBar.percent < 20)
			(opponentChart ? iconP2 : iconP1).animation.curAnim.curFrame = 1;
		else
			(opponentChart ? iconP2 : iconP1).animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			(opponentChart ? iconP1 : iconP2).animation.curAnim.curFrame = 1;
		else
			(opponentChart ? iconP1 : iconP2).animation.curAnim.curFrame = 0;
		*/

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				//Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);
					var songDurationSeconds:Float = FlxMath.roundDecimal(songLength / 1000, 0);
					songPercentThing = FlxMath.roundDecimal(curTime / songLength * 100, ClientPrefs.percentDecimals);
					playbackRateDecimal = FlxMath.roundDecimal(playbackRate, 2);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed' || ClientPrefs.timeBarType == 'Modern Time' || ClientPrefs.timeBarType == 'Song Name + Time') songCalc = curTime;

					var secondsTotal:Int = 0;

					secondsTotal = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;


					var hoursRemaining:Int = Math.floor(secondsTotal / 3600);
					var minutesRemaining:Int = Math.floor(secondsTotal / 60) % 60;
					var minutesRemainingShit:String = '' + minutesRemaining;
					var secondsRemaining:String = '' + secondsTotal % 60;

					if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //let's see if the old time format works actually
					//if (minutesRemaining == 60) minutesRemaining = 0; //reset the minutes to 0 every time it counts another hour
					if (minutesRemainingShit.length < 2) minutesRemainingShit = '0' + minutesRemaining; 
					//also, i wont add a day thing because there's no way someone can mod a song that's over 24 hours long into this engine

					var hoursShown:Int = Math.floor(songDurationSeconds / 3600);
					var minutesShown:Int = Math.floor(songDurationSeconds / 60) % 60;
					var minutesShownShit:String = '' + minutesShown;
					var secondsShown:String = '' + songDurationSeconds % 60;
					if(secondsShown.length < 2) secondsShown = '0' + secondsShown; //let's see if the old time format works actually
					if (minutesShownShit.length < 2) minutesShownShit = '0' + minutesShown;


					if(ClientPrefs.timeBarType != 'Song Name' && songLength <= 3600000)
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

					if(ClientPrefs.timeBarType != 'Song Name' && songLength >= 3600000)
					timeTxt.text = hoursRemaining + ':' + minutesRemainingShit + ':' + secondsRemaining;

					if(ClientPrefs.timeBarType == 'Modern Time' && songLength <= 3600000)
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false) + ' / ' + FlxStringUtil.formatTime(songLength / 1000, false);

					if(ClientPrefs.timeBarType == 'Modern Time' && songLength >= 3600000)
						timeTxt.text = hoursRemaining + ':' + minutesRemainingShit + ':' + secondsRemaining + ' / ' + hoursShown + ':' + minutesShownShit + ':' + secondsShown;

					if(ClientPrefs.timeBarType == 'Song Name + Time' && songLength <= 3600000)
						timeTxt.text = SONG.song + ' (' + FlxStringUtil.formatTime(secondsTotal, false) + ' / ' + FlxStringUtil.formatTime(songLength / 1000, false) + ')';

					if(ClientPrefs.timeBarType == 'Song Name + Time' && songLength >= 3600000)
						timeTxt.text = SONG.song + ' (' + hoursRemaining + ':' + minutesRemainingShit + ':' + secondsRemaining + ' / ' + hoursShown + ':' + minutesShownShit + ':' + secondsShown + ')';
					
					if(randomSpeedThing)
						timeTxt.text += ' (' + playbackRateDecimal + 'x)';
					
					if (ClientPrefs.hudType != 'Kade Engine' && ClientPrefs.hudType != 'Dave & Bambi')
					{
					timePercentTxt.text = songPercentThing  + '% Completed';
					}
					else
					timePercentTxt.text = songPercentThing  + '%';
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}
		if (curBeat % 32 == 0 && randomSpeedThing)
		{
			var randomShit = FlxMath.roundDecimal(FlxG.random.float(0.4, 3), 2);
			lerpSongSpeed(randomShit, 1);
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 0;
			if (!ClientPrefs.dynamicSpawnTime) 
			{
			time = spawnTime * ClientPrefs.noteSpawnTime;
			}
			if (ClientPrefs.dynamicSpawnTime) 
			{
			time = spawnTime / songSpeed;
			}
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				if (dunceNote.noteData < 4 && ClientPrefs.mobileMidScroll)
				{
				index = unspawnNotes.indexOf(dunceNote) - 3;
				unspawnNotes.splice(index, 0);
				}
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
          				if(cpuControlled && opponentChart && dad.holdTimer > Conductor.stepCrochet * 0.001 / playbackRate * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss')) {
					dad.dance();
				}

				if(startedCountdown)
				{
					var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
					notes.forEachAlive(function(daNote:Note)
					{
						var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
						if(!daNote.mustPress) strumGroup = opponentStrums;

						var strumX:Float = strumGroup.members[daNote.noteData].x;
						var strumY:Float = strumGroup.members[daNote.noteData].y;
						var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
						var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
						var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
						var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

						strumX += daNote.offsetX;
						strumY += daNote.offsetY;
						strumAngle += daNote.offsetAngle;
						strumAlpha *= daNote.multAlpha;

						if (strumScroll) //Downscroll
						{
							//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}
						else //Upscroll
						{
							//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}

						var angleDir = strumDirection * Math.PI / 180;
						if (daNote.copyAngle)
							daNote.angle = strumDirection - 90 + strumAngle;

						if(daNote.copyAlpha)
							daNote.alpha = strumAlpha;

						if(daNote.copyX)
							daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

						if(daNote.copyY)
						{
							daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if(strumScroll && daNote.isSustainNote)
							{
								if (daNote.animation.curAnim.name.endsWith('end')) {
									daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
									daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
									if(PlayState.isPixelStage) {
										daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
									} else {
										daNote.y -= 19;
									}
								}
								daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
								daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
							}
						}

						if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
						{
							opponentNoteHit(daNote);
						}

						if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
							if(daNote.isSustainNote) {
								if(daNote.canBeHit) {
									goodNoteHit(daNote);
								}
							} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
								goodNoteHit(daNote);
							}
						}

						var center:Float = strumY + Note.swagWidth / 2;
						if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
							(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							if (strumScroll)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}

						// Kill extremely late notes and cause misses
						if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
						{
							if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
								noteMiss(daNote);
								if (ClientPrefs.missSoundShit)
								{
								FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
								}
							}

							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				}
				else
				{
					notes.forEachAlive(function(daNote:Note)
					{
						daNote.canBeHit = false;
						daNote.wasGoodHit = false;
					});
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
			if(FlxG.keys.justPressed.THREE) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition - 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
		if (ClientPrefs.instaRestart)
		{
		restartSong(true);
		}
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}
			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
							if (ClientPrefs.hudType == 'VS Impostor') {
								botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
								scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							}
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.
		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}
	public function no(?ignoreNoteOffset:Bool = false):Void
	{
		var loopedSong:Int = 1;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		Conductor.songPosition = 8000 * loopedSong;
		loopedSong++;
	}

	public function loopSong(?ignoreNoteOffset:Bool = false):Void
	{	
				FlxG.sound.music.stop();
				vocals.stop();	
				FlxG.sound.music.volume = 1;
				vocals.volume = 1;
		timeBarBG.visible = true;
		timeBar.visible = true;
		timeTxt.visible = true;
		canPause = true;
		endingSong = false;
		camZooming = true;
		inCutscene = false;
		updateTime = true;
		startingSong = false;
				/*
				var difficulty:String = CoolUtil.getDifficultyFilePath();
				if (difficulty != 'Normal')
				{
				PlayState.SONG = Song.loadFromJson(SONG.song.toLowerCase() + difficulty, SONG.song.toLowerCase());
				} else
				{
				PlayState.SONG = Song.loadFromJson(SONG.song.toLowerCase(), SONG.song.toLowerCase());
				}
				*/ //no need to change the song if you're already playing it!
			
				/*
				if (playbackRate >= 8192) playbackRate += 204.8;
				if (playbackRate >= 4096) playbackRate += 102.4;
				if (playbackRate >= 2048) playbackRate += 51.2;
				if (playbackRate >= 1024) playbackRate += 25.6;
				if (playbackRate >= 512) playbackRate += 12.8;
				if (playbackRate >= 256) playbackRate += 6.4;
				*/
				if (playbackRate >= 128) playbackRate += 6.4;
				if (playbackRate >= 64 && playbackRate <= 128) playbackRate += 3.2;
				if (playbackRate >= 32 && playbackRate <= 64) playbackRate += 1.6;
				if (playbackRate >= 16 && playbackRate <= 32) playbackRate += 0.8;
				if (playbackRate >= 8 && playbackRate <= 16) playbackRate += 0.4;
				if (playbackRate >= 4 && playbackRate <= 8) playbackRate += 0.2;
				if (playbackRate >= 2 && playbackRate <= 4) playbackRate += 0.1;
				if (playbackRate <= 2) playbackRate += 0.05;
				//optimized the speed increase code
				Conductor.songPosition = 0;
				KillNotes();
				generateTrollSongShit(SONG.song);

				vocals.play();
				FlxG.sound.music.play();
				callOnLuas('onLoopSong', []);
	}

	public function infiniteLoop(?ignoreNoteOffset:Bool = false):Void
	{	
				FlxG.sound.music.stop();
				vocals.stop();	
				FlxG.sound.music.volume = 1;
				vocals.volume = 1;
		timeBarBG.visible = true;
		timeBar.visible = true;
		timeTxt.visible = true;
		canPause = true;
		endingSong = false;
		camZooming = true;
		inCutscene = false;
		updateTime = true;
		startingSong = false;
				Conductor.songPosition = 0;
				KillNotes();
				generateTrollSongShit(SONG.song);

				vocals.play();
				FlxG.sound.music.play();
				callOnLuas('onLoopSong', []);
	}


	public var transitioning = false;
	public function endSong():Void
	{		
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
		{
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}
		}
			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore && !cpuControlled)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
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
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public static function restartSong(noTrans:Bool = true)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var totalNotes:Int = 0;

	public var showCombo:Bool = true;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		if (ClientPrefs.hudType == 'Doki Doki+')
		{
			pixelShitPart1 = 'dokistuff/';
			pixelShitPart2 = '';
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4')
		{
			pixelShitPart1 = 'tgtstuff/';
			pixelShitPart2 = '';
		}
		if (allSicks)
		{
			pixelShitPart1 = 'goldstuff/';
			pixelShitPart2 = '';
		}
		if (allSicks || !allSicks && ClientPrefs.marvRateColor == 'Golden' && !ClientPrefs.noMarvJudge)
		{
		Paths.image(pixelShitPart1 + "marv" + pixelShitPart2);
		}
		if (!allSicks && ClientPrefs.marvRateColor == 'Rainbow' && !ClientPrefs.noMarvJudge)
		{
		Paths.image(pixelShitPart1 + "marv" + pixelShitPart2);
		}
		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	function doGhostAnim(char:String, animToPlay:String)
		{
			var ghost:FlxSprite = dadGhost;
			var player:Character = dad;
	
			switch(char.toLowerCase().trim())
			{
				case 'bf':
					ghost = bfGhost;
					player = boyfriend;
				case 'dad':
					ghost = dadGhost;
					player = dad;
				case 'gf':
					ghost = gfGhost;
					player = gf;
			}
	
									
			ghost.frames = player.frames;
			ghost.animation.copyFrom(player.animation);
			ghost.x = player.x;
			ghost.y = player.y;
			ghost.animation.play(animToPlay, true);
			ghost.offset.set(player.animOffsets.get(animToPlay)[0], player.animOffsets.get(animToPlay)[1]);
			ghost.flipX = player.flipX;
			ghost.flipY = player.flipY;
			ghost.blend = HARDLIGHT;
			ghost.alpha = 0.8;
			ghost.visible = true;

			if (FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && camZooming && ClientPrefs.doubleGhostZoom)
			{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
			}
	
			switch (char.toLowerCase().trim())
			{
				case 'bf':
					if (bfGhostTween != null)
						bfGhostTween.cancel();
					ghost.color = FlxColor.fromRGB(boyfriend.healthColorArray[0] + 50, boyfriend.healthColorArray[1] + 50, boyfriend.healthColorArray[2] + 50);
					bfGhostTween = FlxTween.tween(bfGhost, {alpha: 0}, 0.75, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							bfGhostTween = null;
						}
					});
	
				case 'dad':
					if (dadGhostTween != null)
						dadGhostTween.cancel();
					ghost.color = FlxColor.fromRGB(dad.healthColorArray[0] + 50, dad.healthColorArray[1] + 50, dad.healthColorArray[2] + 50);
					dadGhostTween = FlxTween.tween(dadGhost, {alpha: 0}, 0.75, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							dadGhostTween = null;
						}
					});
				case 'gf':
					if (gfGhostTween != null)
						gfGhostTween.cancel();
					ghost.color = FlxColor.fromRGB(gf.healthColorArray[0] + 50, gf.healthColorArray[1] + 50, gf.healthColorArray[2] + 50);
					gfGhostTween = FlxTween.tween(gfGhost, {alpha: 0}, 0.75, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							gfGhostTween = null;
						}
					});
			}
		}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 500;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if (goods > 0 || bads > 0 || shits > 0 || songMisses > 0 && ClientPrefs.goldSickSFC || !ClientPrefs.goldSickSFC)
		{
			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		}
		if (noteDiff > ClientPrefs.badWindow && ClientPrefs.shitGivesMiss)
		{	
			noteMiss(note);
		}
		if (ClientPrefs.healthGainType == 'VS Impostor') {
		if (noteDiff < ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge)
		{
			health += note.hitHealth * healthGain;
		}
		if (noteDiff > ClientPrefs.marvWindow || noteDiff < ClientPrefs.sickWindow && ClientPrefs.noMarvJudge)
		{
			health += note.hitHealth * healthGain;
		}
		if (note.isSustainNote)
		{
			health += note.hitHealth * healthGain;
		}
		if (noteDiff > ClientPrefs.sickWindow)
		{
			health += note.hitHealth * 0.5 * healthGain;
		}
		if (noteDiff > ClientPrefs.goodWindow)
		{
			health += note.hitHealth * 0.25 * healthGain;
		}
		if (noteDiff > ClientPrefs.badWindow)
		{
			health += note.hitHealth * 0.1 * healthGain;
		}
		}
		if (ClientPrefs.healthGainType == 'Leather Engine') {
		if (noteDiff < ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge) //you hit a marvelous!!
		{
			health += 0.012 * healthGain;
		}
		if (noteDiff > ClientPrefs.marvWindow || noteDiff < ClientPrefs.sickWindow && ClientPrefs.noMarvJudge)
		{
			health += 0.012 * healthGain; //you hit a sick!
		}
		if (noteDiff > ClientPrefs.sickWindow) //you hit a good rating
		{
			health += -0.008 * healthGain;
		}
		if (noteDiff > ClientPrefs.goodWindow) //you hit a bad rating
		{
			health += -0.018 * healthGain;
		}
		if (noteDiff > ClientPrefs.badWindow) //you hit a shit rating
		{
			health += -0.23;
		}
		}
		if (ClientPrefs.healthGainType == 'Kade (1.4.2 to 1.6)') {
		if (noteDiff < ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge)
		{
			health += 0.1 * healthGain;
		}
		if (noteDiff > ClientPrefs.marvWindow || noteDiff < ClientPrefs.sickWindow && ClientPrefs.noMarvJudge)
		{
			health += 0.1 * healthGain;
		}
		if (noteDiff > ClientPrefs.sickWindow)
		{
			health += 0.04 * healthGain;
		}
		if (noteDiff > ClientPrefs.goodWindow)
		{
			health -= 0.06 * healthLoss;
		}
		if (noteDiff > ClientPrefs.badWindow)
		{
			health -= 0.2 * healthLoss;
		}
		}
		if (ClientPrefs.healthGainType == 'Doki Doki+') {
		if (noteDiff < ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge)
		{
			health += 0.077 * healthGain;
		}
		if (noteDiff > ClientPrefs.marvWindow || noteDiff < ClientPrefs.sickWindow && ClientPrefs.noMarvJudge)
		{
			health += 0.077 * healthGain;
		}
		if (noteDiff > ClientPrefs.sickWindow)
		{
			health += 0.04 * healthGain;
		}
		if (noteDiff > ClientPrefs.goodWindow)
		{
			health -= 0.06 * healthLoss;
		}
		if (noteDiff > ClientPrefs.badWindow)
		{
			health -= 0.1 * healthLoss;
		}
		}
		if (ClientPrefs.healthGainType == 'Kade (1.6+)') {
		if (noteDiff < ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge)
		{
			health += 0.017 * healthGain;
		}
		if (noteDiff > ClientPrefs.marvWindow || noteDiff < ClientPrefs.sickWindow && ClientPrefs.noMarvJudge)
		{
			health += 0.017 * healthGain;
		}
		if (noteDiff > ClientPrefs.sickWindow)
		{
			health += 0;
		}
		if (noteDiff > ClientPrefs.goodWindow)
		{
			health -= 0.03 * healthLoss;
		}
		if (noteDiff > ClientPrefs.badWindow)
		{
			health -= 0.06 * healthLoss;
		}
		}
		if (ClientPrefs.healthGainType == 'Kade (1.2)') {
		if (noteDiff < ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge)
		{
			health += 0.023 * healthGain;
		}
		if (noteDiff > ClientPrefs.marvWindow || noteDiff < ClientPrefs.sickWindow && ClientPrefs.noMarvJudge)
		{
			health += 0.023 * healthGain;
		}
		if (noteDiff > ClientPrefs.sickWindow)
		{
			health += 0.004 * healthGain;
		}
		if (noteDiff > ClientPrefs.goodWindow)
		{
			health -= 0;
		}
		if (noteDiff > ClientPrefs.badWindow)
		{
			health -= 0;
		}
		}

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(false, note);
		}

		if(!practiceMode) {
			songScore += score;
			if(!note.ratingDisabled || cpuControlled && !ClientPrefs.lessBotLag)
			{
				songHits++;
				totalPlayed++;
				if(ClientPrefs.ratingCounter)
				{
				updateRatingCounter();
				}
				if(!cpuControlled) {
				RecalculateRating(false);
				}
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		if (ClientPrefs.hudType == 'Doki Doki+')
		{
			pixelShitPart1 = 'dokistuff/';
			pixelShitPart2 = '';
		}
		if (ClientPrefs.hudType == 'Tails Gets Trolled V4')
		{
			pixelShitPart1 = 'tgtstuff/';
			pixelShitPart2 = '';
		}
		if (allSicks && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.goldSickSFC)
		{
			pixelShitPart1 = 'goldstuff/';
			pixelShitPart2 = '';
		}
		if (!allSicks && ClientPrefs.marvRateColor == 'Golden' && noteDiff < ClientPrefs.marvWindow && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+' && !ClientPrefs.noMarvJudge)
		{
			pixelShitPart1 = 'goldstuff/';
			pixelShitPart2 = '';
		}
		if (!allSicks && ClientPrefs.marvRateColor == 'Rainbow' && noteDiff < ClientPrefs.marvWindow && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+' && !ClientPrefs.noMarvJudge)
		{
			pixelShitPart1 = '';
			pixelShitPart2 = '';
		}
		if (ClientPrefs.ratesAndCombo) {
		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = (ClientPrefs.wrongCameras ? [camGame] : [camHUD]);
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];
if (!allSicks && ClientPrefs.colorRatingFC && marvs > 0 && noteDiff > ClientPrefs.marvWindow && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.noMarvJudge) 
		{
		rating.color = judgeColours.get('marv');
		}
if (!allSicks && ClientPrefs.colorRatingFC && sicks > 0 && noteDiff > ClientPrefs.marvWindow && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.marvRateColor != 'Golden' && !ClientPrefs.noMarvJudge) 
		{
		rating.color = judgeColours.get('sick');
		}
if (!allSicks && ClientPrefs.colorRatingFC && goods > 0 && noteDiff > ClientPrefs.marvWindow && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+') 
		{
		rating.color = judgeColours.get('good');
		}
if (!allSicks && ClientPrefs.colorRatingFC && bads > 0 && noteDiff > ClientPrefs.marvWindow && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+') 
		{
		rating.color = judgeColours.get('bad');
		}
if (!allSicks && ClientPrefs.colorRatingFC && shits > 0 && noteDiff > ClientPrefs.marvWindow && ClientPrefs.hudType != 'Tails Gets Trolled V4' && ClientPrefs.hudType != 'Doki Doki+') 
		{
		rating.color = judgeColours.get('shit');
		}
if (!allSicks && ClientPrefs.colorRatingFC && songMisses > 0) 
		{
		rating.color = FlxColor.WHITE;
		}
		insert(members.indexOf(strumLineNotes), rating);

		if (ClientPrefs.showMS && !ClientPrefs.hideHud) {
			FlxTween.cancelTweensOf(msTxt);
			FlxTween.cancelTweensOf(msTxt.scale);
			var msTiming:Float = note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset;
			var time = (Conductor.stepCrochet * 0.001); //ms popup shit
			msTxt.cameras = (ClientPrefs.wrongCameras ? [camGame] : [camHUD]);
			msTxt.visible = true;
			msTxt.screenCenter();
			msTxt.x = (ClientPrefs.comboPopup ? coolText.x + 280 : coolText.x + 80);
			msTxt.alpha = 1;
			msTxt.text = FlxMath.roundDecimal(-msTiming, 3) + " MS";
			msTxt.x += ClientPrefs.comboOffset[0];
			msTxt.y -= ClientPrefs.comboOffset[1];
			if (combo >= 1000000) msTxt.x += 30;
			if (combo >= 100000) msTxt.x += 30;
			if (combo >= 10000) msTxt.x += 30;
			FlxTween.tween(msTxt, 
				{y: msTxt.y + 8}, 
				0.1 / playbackRate,
				{onComplete: function(_){

						FlxTween.tween(msTxt, {alpha: 0}, time, {
							// ease: FlxEase.circOut,
							onComplete: function(_){msTxt.visible = false;},
							startDelay: time * 5 / playbackRate
						});
					}
				});
			if (noteDiff <= ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge) msTxt.color = FlxColor.YELLOW;
			if (noteDiff <= ClientPrefs.sickWindow && ClientPrefs.noMarvJudge) msTxt.color = FlxColor.CYAN;
			if (noteDiff <= ClientPrefs.sickWindow && noteDiff >= ClientPrefs.marvWindow && !ClientPrefs.noMarvJudge) msTxt.color = FlxColor.CYAN;
			if (noteDiff >= ClientPrefs.sickWindow) msTxt.color = FlxColor.LIME;
			if (noteDiff >= ClientPrefs.goodWindow) msTxt.color = FlxColor.ORANGE;
			if (noteDiff >= ClientPrefs.badWindow) msTxt.color = FlxColor.RED;
			if (!msTxt.visible) msTxt.color = FlxColor.WHITE;
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = (ClientPrefs.wrongCameras ? [camGame] : [camHUD]);
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.color = rating.color;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		if (ClientPrefs.comboPopup && !cpuControlled)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000000) {
			seperatedScore.push(Math.floor(combo / 1000000) % 10);
		}
		if(combo >= 100000) {
			seperatedScore.push(Math.floor(combo / 100000) % 10);
		}
		if(combo >= 10000) {
			seperatedScore.push(Math.floor(combo / 10000) % 10);
		}
		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		if(combo >= 100) {
		seperatedScore.push(Math.floor(combo / 100) % 10);
		}
		if(combo >= 10) {
		seperatedScore.push(Math.floor(combo / 10) % 10);
		}
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (ClientPrefs.comboPopup && !cpuControlled)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = (ClientPrefs.wrongCameras ? [camGame] : [camHUD]);
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
if (!allSicks && !ClientPrefs.goldSickSFC && ClientPrefs.colorRatingFC && marvs > 0 && ClientPrefs.hudType != 'Doki Doki+' && !ClientPrefs.noMarvJudge && ClientPrefs.marvRateColor != 'Golden') 
		{
		numScore.color = judgeColours.get('marv');
		}
if (!allSicks && !ClientPrefs.goldSickSFC && ClientPrefs.colorRatingFC && sicks > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff > ClientPrefs.marvWindow || !allSicks && !ClientPrefs.goldSickSFC && ClientPrefs.colorRatingFC && sicks > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff < ClientPrefs.sickWindow && noteDiff > ClientPrefs.sickWindow) 
		{
		numScore.color = judgeColours.get('sick');
		}
if (!allSicks && ClientPrefs.colorRatingFC && goods > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff > ClientPrefs.marvWindow || !allSicks && !ClientPrefs.goldSickSFC && ClientPrefs.colorRatingFC && sicks > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff < ClientPrefs.sickWindow && noteDiff > ClientPrefs.sickWindow) 
		{
		numScore.color = judgeColours.get('good');
		}
if (!allSicks && ClientPrefs.colorRatingFC && bads > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff > ClientPrefs.marvWindow || !allSicks && !ClientPrefs.goldSickSFC && ClientPrefs.colorRatingFC && sicks > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff < ClientPrefs.sickWindow && noteDiff > ClientPrefs.sickWindow) 
		{
		numScore.color = judgeColours.get('bad');
		}
if (!allSicks && ClientPrefs.colorRatingFC && shits > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff > ClientPrefs.marvWindow || !allSicks && !ClientPrefs.goldSickSFC && ClientPrefs.colorRatingFC && sicks > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff < ClientPrefs.sickWindow && noteDiff > ClientPrefs.sickWindow) 
		{
		numScore.color = judgeColours.get('shit');
		}
if (!allSicks && ClientPrefs.colorRatingFC && songMisses > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff > ClientPrefs.marvWindow || !allSicks && !ClientPrefs.goldSickSFC && ClientPrefs.colorRatingFC && sicks > 0 && ClientPrefs.hudType != 'Doki Doki+' && noteDiff < ClientPrefs.sickWindow && noteDiff > ClientPrefs.sickWindow) 
		{
		numScore.color = FlxColor.WHITE;
		}
if (!allSicks && ClientPrefs.colorRatingFC && marvs > 0 && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.hudType == 'Tails Gets Trolled V4') 
		{
		numScore.color = tgtJudgeColours.get('marv');
		}
if (!allSicks && ClientPrefs.colorRatingFC && sicks > 0 && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.hudType == 'Tails Gets Trolled V4') 
		{
		numScore.color = tgtJudgeColours.get('sick');
		}
if (!allSicks && ClientPrefs.colorRatingFC && goods > 0 && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.hudType == 'Tails Gets Trolled V4') 
		{
		numScore.color = tgtJudgeColours.get('good');
		}
if (!allSicks && ClientPrefs.colorRatingFC && bads > 0 && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.hudType == 'Tails Gets Trolled V4') 
		{
		numScore.color = tgtJudgeColours.get('bad');
		}
if (!allSicks && ClientPrefs.colorRatingFC && shits > 0 && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.hudType == 'Tails Gets Trolled V4') 
		{
		numScore.color = tgtJudgeColours.get('shit');
		}
if (!allSicks && ClientPrefs.colorRatingFC && songMisses > 0 && ClientPrefs.hudType != 'Doki Doki+' && ClientPrefs.hudType == 'Tails Gets Trolled V4') 
		{
		numScore.color = FlxColor.WHITE;
		}
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
		}
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
				if (!opponentChart && ClientPrefs.ghostTapAnim)
				{
					boyfriend.playAnim(singAnimations[Std.int(Math.abs(key))], true);
					if (ClientPrefs.cameraPanning) camPanRoutine(singAnimations[Std.int(Math.abs(key))], 'bf');
					boyfriend.holdTimer = 0;
				}
				if (opponentChart && ClientPrefs.ghostTapAnim)
				{
					dad.playAnim(singAnimations[Std.int(Math.abs(key))], true);
					if (ClientPrefs.cameraPanning) camPanRoutine(singAnimations[Std.int(Math.abs(key))], 'oppt'); //thanks denpa engine
					dad.holdTimer = 0;
				}
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		var char:Character = boyfriend;
		if (opponentChart) char = dad;
		if (startedCountdown && !char.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if(FlxG.keys.anyJustPressed(tauntKey) && !char.animation.curAnim.name.endsWith('miss') && char.specialAnim == false && ClientPrefs.spaceVPose){
				char.playAnim('hey', true);
				char.specialAnim = true;
				char.heyTimer = 0.59;
				FlxG.sound.play(Paths.sound('hey'));
				trace("HEY!!");
				}

			if (parsedHoldArray.contains(true) && !endingSong && !opponentChart) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
			if (dad.holdTimer > Conductor.stepCrochet * 0.001 * dad.singDuration 
			&& dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
				dad.dance();
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		if (ClientPrefs.healthGainType == 'Psych Engine') {
		health -= daNote.missHealth * healthLoss;
		}
		if (ClientPrefs.healthGainType == 'Kade (1.2)') {
		health -= daNote.missHealth * healthLoss;
		}
		if (ClientPrefs.healthGainType == 'Leather Engine') {
		health -= 0.07 * healthLoss;
		}
		if (ClientPrefs.healthGainType == 'Kade (1.4.2 to 1.6)') {
		health -= 0.075 * healthLoss;
		}
		if (ClientPrefs.healthGainType == 'Kade (1.6+)') {
		health -= 0.1 * healthLoss;
		}
		if (ClientPrefs.healthGainType == 'Doki Doki+') {
		health -= 0.04 * healthLoss;
		}
		if (ClientPrefs.healthGainType == 'VS Impostor') {
		missCombo += 1;
		health -= daNote.missHealth * missCombo;
		}


		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}
		if (opponentChart) char = dad;

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			var char:Character = boyfriend;
			if (opponentChart) char = dad;
			if(char.hasMissAnimations) {
				char.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (!opponentChart) {
			if (Paths.formatToSongPath(SONG.song) != 'tutorial')
				camZooming = true;
		}

		var char:Character = dad;
		if(opponentChart) char = boyfriend;
		if(note.noteType == 'Hey!' && char.animOffsets.exists('hey')) {
			char.playAnim('hey', true);
			char.specialAnim = true;
			char.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection && !opponentChart) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
					if (ClientPrefs.doubleGhost)
					{
					if (!note.isSustainNote && noteRows[note.mustPress?0:1][note.row].length > 1)
						{
							// potentially have jump anims?
							var chord = noteRows[note.mustPress?0:1][note.row];
							var animNote = chord[0];
							var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))];
							if (gf.mostRecentRow != note.row)
							{
								gf.playAnim(realAnim, true);
							}
		
							// if (daNote != animNote)
							// dad.playGhostAnim(chord.indexOf(daNote)-1, animToPlay, true);

		
							gf.mostRecentRow = note.row;
							// dad.angle += 15; lmaooooo
							doGhostAnim('gf', animToPlay);
							}
						}
			}
			if(opponentChart) {
				boyfriend.playAnim(animToPlay, true);
				boyfriend.holdTimer = 0;
			}
			else if(char != null && !opponentChart)
			{
					char.playAnim(animToPlay, true);
					char.holdTimer = 0;
					if (ClientPrefs.cameraPanning) camPanRoutine(animToPlay, 'oppt');
					if (ClientPrefs.doubleGhost)
					{
					if (!note.isSustainNote && noteRows[note.mustPress?0:1][note.row].length > 1)
						{
							// potentially have jump anims?
							var chord = noteRows[note.mustPress?0:1][note.row];
							var animNote = chord[0];
							var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))];
							if (char.mostRecentRow != note.row)
							{
								char.playAnim(realAnim, true);
							}
		
							// if (daNote != animNote)
							// dad.playGhostAnim(chord.indexOf(daNote)-1, animToPlay, true);
		
							// dad.angle += 15; lmaooooo
									if (!note.noAnimation && !note.gfNote)
									{
										if(char.mostRecentRow != note.row)
											doGhostAnim('char', animToPlay + altAnim);
											dadGhost.color = FlxColor.fromRGB(dad.healthColorArray[0] + 50, dad.healthColorArray[1] + 50, dad.healthColorArray[2] + 50);
											dadGhostTween = FlxTween.tween(dadGhost, {alpha: 0}, 0.75, {
												ease: FlxEase.linear,
												onComplete: function(twn:FlxTween)
												{
													dadGhostTween = null;
												}
											});
									}
									char.mostRecentRow = note.row;
						}
						}
						else{
							char.playAnim(animToPlay + note.animSuffix, true);
							// dad.angle = 0;
						}
			}
				if (opponentChart)
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
					if (ClientPrefs.cameraPanning) camPanRoutine(animToPlay, 'bf');
					if (ClientPrefs.doubleGhost)
					{
					if (!note.isSustainNote && noteRows[note.mustPress?0:1][note.row].length > 1)
						{
							// potentially have jump anims?
							var chord = noteRows[note.mustPress?0:1][note.row];
							var animNote = chord[0];
							var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))];
							if (boyfriend.mostRecentRow != note.row)
							{
								boyfriend.playAnim(realAnim, true);
							}
		
							// if (daNote != animNote)
							// dad.playGhostAnim(chord.indexOf(daNote)-1, animToPlay, true);
		
							boyfriend.mostRecentRow = note.row;
							// dad.angle += 15; lmaooooo
							doGhostAnim('bf', animToPlay);
						}
						else{
							boyfriend.playAnim(animToPlay + note.animSuffix, true);
							// dad.angle = 0;
						}
					}
				}
		}

		if(ClientPrefs.oppNoteSplashes && !note.isSustainNote)
		{
			spawnNoteSplashOnNote(true, note);
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15 / playbackRate;
		if (ClientPrefs.opponentLightStrum)
		{
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		}
		note.hitByOpponent = true;

		if (opponentDrain && health > 0.1) health -= note.hitHealth * hpDrainLevel;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		callOnLuas((opponentChart ? 'goodNoteHitFix' : 'opponentNoteHitFix'), [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	var hitsound:FlxSound;
	var hitsound2:FlxSound;
	var hitsound3:FlxSound;
	var hitsound4:FlxSound;
	var hitsound5:FlxSound;
	var hitsound6:FlxSound;
	var hitsound7:FlxSound;
	var hitsound8:FlxSound;
	var hitsound9:FlxSound;

	function goodNoteHit(note:Note):Void
	{
		if (opponentChart) {
			if (Paths.formatToSongPath(SONG.song) != 'tutorial')
				camZooming = true;
		}
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				if (hitSoundString != 'Randomized')
				{
				hitsound.play(true);
				hitsound.pitch = playbackRate;
				}
				if (hitSoundString == 'Randomized')
				{
				hitsound.pitch = playbackRate;
				hitsound2.pitch = playbackRate;
				hitsound3.pitch = playbackRate;
				hitsound4.pitch = playbackRate;
				hitsound5.pitch = playbackRate;
				hitsound6.pitch = playbackRate;
				hitsound7.pitch = playbackRate;
				hitsound8.pitch = playbackRate;
				hitsound9.pitch = playbackRate;
				}
				if (hitSoundString == 'vine boom')
				{
					SPUNCHBOB = new FlxSprite().loadGraphic(Paths.image('sadsponge'));
					SPUNCHBOB.antialiasing = ClientPrefs.globalAntialiasing;
					SPUNCHBOB.scrollFactor.set();
					SPUNCHBOB.setGraphicSize(Std.int(SPUNCHBOB.width / FlxG.camera.zoom));
					SPUNCHBOB.updateHitbox();
					SPUNCHBOB.screenCenter();
					SPUNCHBOB.alpha = 1;
					SPUNCHBOB.cameras = [camGame];
					add(SPUNCHBOB);
					FlxTween.tween(SPUNCHBOB, {alpha: 0}, 1 / (SONG.bpm/100) / playbackRate, {
						onComplete: function(tween:FlxTween)
						{
							SPUNCHBOB.destroy();
						}
					});
				}
				if (ClientPrefs.hitsoundType == 'Randomized') {
					var randomHitSoundType:Int = FlxG.random.int(1, 9);
						switch (randomHitSoundType)
							{
								case 1:
									hitsound.play(true);
									hitsound.pitch = playbackRate;
								case 2:
									hitsound2.play(true);
									hitsound2.pitch = playbackRate;
								case 3:
									hitsound3.play(true);
									hitsound3.pitch = playbackRate;
								case 4:
									hitsound4.play(true);
									hitsound4.pitch = playbackRate;
								case 5:
									hitsound5.play(true);
									hitsound5.pitch = playbackRate;
								case 6:
									hitsound6.play(true);
									hitsound6.pitch = playbackRate;
								case 7:
									hitsound7.play(true);
									hitsound7.pitch = playbackRate;
								case 8:
									hitsound8.play(true);
									hitsound8.pitch = playbackRate;
									{
										SPUNCHBOB = new FlxSprite().loadGraphic(Paths.image('sadsponge'));
										SPUNCHBOB.antialiasing = ClientPrefs.globalAntialiasing;
										SPUNCHBOB.scrollFactor.set();
										SPUNCHBOB.setGraphicSize(Std.int(SPUNCHBOB.width / FlxG.camera.zoom));
										SPUNCHBOB.updateHitbox();
										SPUNCHBOB.screenCenter();
										SPUNCHBOB.alpha = 1;
										SPUNCHBOB.cameras = [camGame];
										add(SPUNCHBOB);
										FlxTween.tween(SPUNCHBOB, {alpha: 0}, 1 / (SONG.bpm/100) / playbackRate, {
											onComplete: function(tween:FlxTween)
											{
												SPUNCHBOB.destroy();
											}
										});
									}
								case 9:
									hitsound9.play(true);
									hitsound9.pitch = playbackRate;
							}
				}
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(false, note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote && !cpuControlled)
			{
				combo += 1;
				totalNotesPlayed += 1;
				missCombo = 0;
				notesHitArray.unshift(Date.now());
				popUpScore(note);
			}
			if (!note.isSustainNote && cpuControlled && ClientPrefs.lessBotLag)
			{
				if (!ClientPrefs.noMarvJudge)
				{
				songScore += 500;
				}
				else if (ClientPrefs.noMarvJudge)
				{
				songScore += 350;
				}
				updateRatingCounter();
				combo += 1;
				totalNotesPlayed += 1;
				notesHitArray.unshift(Date.now());
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(false, note);
				}
			}
			if (!note.isSustainNote && cpuControlled && !ClientPrefs.lessBotLag)
			{
				combo += 1;
				totalNotesPlayed += 1;
				missCombo = 0;
				notesHitArray.unshift(Date.now());
				popUpScore(note);
			}
			if (ClientPrefs.healthGainType == 'Psych Engine') {
			health += note.hitHealth * healthGain;
			}
			if (ClientPrefs.healthGainType == 'Leather Engine') {
			health += note.hitHealth * healthGain;
			}
			if (ClientPrefs.healthGainType == 'Kade (1.2)') {
			health += note.hitHealth * healthGain;
			}
			if (ClientPrefs.healthGainType == 'Kade (1.6+)') {
			health += note.hitHealth * healthGain;
			}
			if (ClientPrefs.healthGainType == 'Doki Doki+') {
			health += note.hitHealth * healthGain;
			}
			if (ClientPrefs.healthGainType == 'VS Impostor') {
			health += note.hitHealth * healthGain;
			}
			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
       			
				var char:Character = boyfriend;
				if(opponentChart) char = dad;
				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					if (!note.isSustainNote && noteRows[note.mustPress?0:1][note.row].length > 1 && ClientPrefs.doubleGhost)
						{
							// potentially have jump anims?
							var chord = noteRows[note.mustPress?0:1][note.row];
							var animNote = chord[0];
							var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))];
							if (gf.mostRecentRow != note.row)
							{
								gf.playAnim(realAnim, true);
							}
		
							// if (daNote != animNote)
							// dad.playGhostAnim(chord.indexOf(daNote)-1, animToPlay, true);

		
							gf.mostRecentRow = note.row;
							// dad.angle += 15; lmaooooo
							doGhostAnim('gf', animToPlay);
					gfGhost.color = FlxColor.fromRGB(gf.healthColorArray[0] + 50, gf.healthColorArray[1] + 50, gf.healthColorArray[2] + 50);
					gfGhostTween = FlxTween.tween(gfGhost, {alpha: 0}, 0.75, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							gfGhostTween = null;
						}
					});
						}
						else{
							gf.playAnim(animToPlay + note.animSuffix, true);
							// dad.angle = 0;
						}
					}
				}
				if (!opponentChart && !note.gfNote)
				{
					if (!ClientPrefs.doubleGhost) {
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					}
					if (ClientPrefs.cameraPanning) camPanRoutine(animToPlay, 'bf');
					boyfriend.holdTimer = 0;
					if (ClientPrefs.doubleGhost)
					{
					if (!note.isSustainNote && noteRows[note.mustPress?0:1][note.row].length > 1)
						{
							// potentially have jump anims?
							var chord = noteRows[note.mustPress?0:1][note.row];
							var animNote = chord[0];
							var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))];
							if (boyfriend.mostRecentRow != note.row)
							{
								boyfriend.playAnim(realAnim, true);
							}
		
							// if (daNote != animNote)
							// dad.playGhostAnim(chord.indexOf(daNote)-1, animToPlay, true);
		
							boyfriend.mostRecentRow = note.row;
							// dad.angle += 15; lmaooooo
							doGhostAnim('bf', animToPlay);
						}
						else{
							boyfriend.playAnim(animToPlay + note.animSuffix, true);
							// dad.angle = 0;
						}
					}
				}
				if (opponentChart && !note.gfNote)
				{
					if (!ClientPrefs.doubleGhost) {
					dad.playAnim(animToPlay, true);
					}
				dad.holdTimer = 0;
				if (ClientPrefs.cameraPanning) camPanRoutine(animToPlay, 'oppt');
				if (ClientPrefs.doubleGhost)
					{
					if (!note.isSustainNote && noteRows[note.mustPress?0:1][note.row].length > 1)
						{
							// potentially have jump anims?
							var chord = noteRows[note.mustPress?0:1][note.row];
							var animNote = chord[0];
							var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))];
							if (dad.mostRecentRow != note.row)
							{
								dad.playAnim(realAnim, true);
							}
		
							// if (daNote != animNote)
							// dad.playGhostAnim(chord.indexOf(daNote)-1, animToPlay, true);
		
							// dad.angle += 15; lmaooooo
									if (!note.noAnimation && !note.gfNote)
									{
										if(dad.mostRecentRow != note.row)
											doGhostAnim('dad', animToPlay);
											dadGhost.color = FlxColor.fromRGB(dad.healthColorArray[0] + 50, dad.healthColorArray[1] + 50, dad.healthColorArray[2] + 50);
											dadGhostTween = FlxTween.tween(dadGhost, {alpha: 0}, 0.75, {
												ease: FlxEase.linear,
												onComplete: function(twn:FlxTween)
												{
													dadGhostTween = null;
												}
											});
									}
									dad.mostRecentRow = note.row;
						}
						else{
							dad.playAnim(animToPlay + note.animSuffix, true);
							// dad.angle = 0;
						}
					}
				}

				if(note.noteType == 'Hey!') {
					if(char.animOffsets.exists('hey')) {
						char.playAnim('hey', true);
						char.specialAnim = true;
						char.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				if (ClientPrefs.botLightStrum)
				{
				var time:Float = 0.15 / playbackRate;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
				}
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			callOnLuas('goodNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
			callOnLuas((opponentChart ? 'opponentNoteHitFix' : 'goodNoteHitFix'), [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(isDad:Bool, note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (isDad) {
			strum = opponentStrums.members[note.noteData];
			} else {
			strum = playerStrums.members[note.noteData];
			}
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		//if (ClientPrefs.splashType == 'VS Impostor') PlayState.SONG.splashSkin = 'impostorNoteSplashes';
		//if (ClientPrefs.splashType == 'Tails Gets Trolled V4') PlayState.SONG.splashSkin = 'tgtNoteSplashes';

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		#if cpp
		cpp.vm.Gc.enable(true);
		#end
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}
		if (ClientPrefs.iconBounceType == 'Dave and Bambi') {
		var funny:Float = Math.max(Math.min(healthBar.value,1.9),0.01);

		iconP2.setGraphicSize(Std.int(iconP2.width + (50 / funny)),Std.int(iconP2.height - (25 * funny)));
		iconP1.setGraphicSize(Std.int(iconP1.width + (50 / ((2 - funny) + 0.1))),Std.int(iconP1.height - (25 * ((2 - funny) + 0.1))));
		}
		if (ClientPrefs.iconBounceType == 'Old Psych') {
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		}
		if (ClientPrefs.iconBounceType == 'New Psych') {
		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % gfSpeed == 0 && ClientPrefs.iconBounceType == 'Golden Apple') {
		curBeat % (gfSpeed * 2) == 0 * playbackRate ? {
		iconP1.scale.set(1.1, 0.8);
		iconP2.scale.set(1.1, 1.3);

		FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 / playbackRate, {ease: FlxEase.quadOut});
		FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 / playbackRate, {ease: FlxEase.quadOut});
		} : {
		iconP1.scale.set(1.1, 1.3);
		iconP2.scale.set(1.1, 0.8);

		FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 / playbackRate, {ease: FlxEase.quadOut});
		FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 / playbackRate, {ease: FlxEase.quadOut});
		}

		FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 / playbackRate * gfSpeed, {ease: FlxEase.quadOut});
		FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 / playbackRate * gfSpeed, {ease: FlxEase.quadOut});

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		} 
		if (ClientPrefs.iconBounceType == 'VS Steve') {
		if (curBeat % gfSpeed == 0) 
			{
			curBeat % (gfSpeed * 2) == 0 ? 
			{
				iconP1.scale.set(1.1, 0.8);
				iconP2.scale.set(1.1, 1.3);
				//FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				//FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			} 
			: 
			{
				iconP1.scale.set(1.1, 1.3);
				iconP2.scale.set(1.1, 0.8);
				FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				
			}

			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		}

		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	#if LUA_ALLOWED
	public function startLuasOnFolder(luaFile:String)
	{
		for (script in luaArray)
		{
			if(script.scriptName == luaFile) return false;
		}

		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(luaToLoad))
		{
			luaArray.push(new FunkinLua(luaToLoad));
			return true;
		}
		else
		{
			luaToLoad = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
				return true;
			}
		}
		#elseif sys
		var luaToLoad:String = Paths.getPreloadPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		{
			luaArray.push(new FunkinLua(luaToLoad));
			return true;
		}
		#end
		return false;
	}
	#end

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [];

		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var myValue = script.call(event, args);
			if(myValue == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if(myValue != null && myValue != FunkinLua.Function_Continue) {
				returnVal = myValue;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if (isDad && opponentChart) {
			spr = opponentStrums.members[id];
		}
		else if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public function updateRatingCounter() {
		if (!ClientPrefs.noMarvJudge)
		{
		judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed/totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nMarvelous!!!: ' + marvs + '\nSicks!!: ' + sicks + '\nGoods!: ' + goods + '\nBads: ' + bads + '\nShits: ' + shits + '\nMisses: ' + songMisses;
		if (ClientPrefs.hudType == 'Doki Doki+') judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nVery Doki: ' + marvs + '\nDoki: ' + sicks + '\nGood: ' + goods + '\nOK: ' + bads + '\nNO: ' + shits + '\nMiss: ' + songMisses;
		if (ClientPrefs.hudType == 'VS Impostor') judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nSO SUSSY: ' + marvs + '\nSussy: ' + sicks + '\nSus: ' + goods + '\nSad: ' + bads + '\nAss: ' + shits + '\nMiss: ' + songMisses;
		}
		if (ClientPrefs.noMarvJudge)
		{
		judgementCounter.text = 'Percent of Notes Hit: ' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nSicks!!: ' + sicks + '\nGoods!: ' + goods + '\nBads: ' + bads + '\nShits: ' + shits + '\nMisses: ' + songMisses;
		if (ClientPrefs.hudType == 'Doki Doki+') judgementCounter.text = 'Percent of Notes Hit' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nDoki: ' + sicks + '\nGood: ' + goods + '\nOK: ' + bads + '\nNO: ' + shits + '\nMiss: ' + songMisses;
		if (ClientPrefs.hudType == 'VS Impostor') judgementCounter.text = 'Percent of Notes Hit' + FlxMath.roundDecimal((totalNotesPlayed / totalNotes) * 100, 2) + '%\nTotal Notes Hit: ' + totalNotesPlayed + ' / ' + totalNotes + '\nSussy: ' + sicks + '\nSus: ' + goods + '\nSad: ' + bads + '\nAss: ' + shits + '\nMiss: ' + songMisses;
		}
	}


	public var ratingName:String = '?';
	public var ratingString:String;
	public var ratingPercent:Float;
	public var ratingFC:String;
	public var ratingCool:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

			if (Math.isNaN(ratingPercent))
				ratingString = '?';

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (marvs > 0) ratingFC = "MFC";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0) ratingFC = "BFC";
			if (shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			if (songMisses >= 10) ratingFC = "Clear";
			if (songMisses >= 100) ratingFC = "TDSB";
			if (songMisses >= 1000) ratingFC = "QDSB";
			if (songMisses >= 100000) ratingFC = "STDCB";
			else if (songMisses >= 10000000) ratingFC = "SPDCB"; //i have no idea how you'd get a million misses but oh well



		if (ClientPrefs.hudType == "VS Impostor")
		{
			if (marvs > 0) ratingFC = " [MFC]";
			if (sicks > 0) ratingFC = " [SFC]";
			if (goods > 0) ratingFC = " [GFC]";
			if (bads > 0) ratingFC = " [BFC]";
			if (shits > 0) ratingFC = " [FC]";
			if (songMisses > 0 && songMisses < 10) ratingFC = " [SDCB]";
			if (songMisses >= 10) ratingFC = " [Clear]";
			if (songMisses >= 100) ratingFC = " [TDSB]";
			if (songMisses >= 1000) ratingFC = " [QDSB]";
			if (songMisses >= 100000) ratingFC = " [STDCB]";
			else if (songMisses >= 10000000) ratingFC = " [SPDCB]"; //i have no idea how you'd get a million misses but oh well
		}

		if (ClientPrefs.hudType == "Tails Gets Trolled V4")
		{
			if (marvs > 0) ratingFC = "KFC";
			if (sicks > 0) ratingFC = "AFC";
			if (goods > 0) ratingFC = "CFC";
			if (bads > 0) ratingFC = "SDC";
			if (shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			if (songMisses >= 10) ratingFC = "Clear";
			if (songMisses >= 100) ratingFC = "TDSB";
			if (songMisses >= 1000) ratingFC = "QDSB";
			if (songMisses >= 100000) ratingFC = "STDCB";
			else if (songMisses >= 10000000) ratingFC = "SPDCB"; //i have no idea how you'd get a million misses but oh well
		}

			// Rating FC
			if (ClientPrefs.hudType == 'Kade Engine' || ClientPrefs.hudType == 'Doki Doki+') {
			ratingFC = "?";
			if (marvs > 0) ratingFC = "(MFC)";
			if (sicks > 0) ratingFC = "(SFC)";
			if (goods > 0) ratingFC = "(GFC)";
			if (bads > 0) ratingFC = "(BFC)";
			if (shits > 0) ratingFC = "(FC)";
			if (songMisses > 0 && songMisses < 10) ratingFC = "(SDCB)";
			if (songMisses >= 10) ratingFC = "(Clear)";
			if (songMisses >= 100) ratingFC = "(TDSB)";
			if (songMisses >= 1000) ratingFC = "(QDSB)";
			if (songMisses >= 100000) ratingFC = "(STDCB)";
			else if (songMisses >= 10000000) ratingFC = "(SPDCB)"; //i have no idea how you'd get a million misses but oh well
			}

			ratingCool = "";
            if (ratingPercent*100 <= 60) ratingCool = " F";
            if (ratingPercent*100 >= 60) ratingCool = " D";
            if (ratingPercent*100 >= 60) ratingCool = " C";
            if (ratingPercent*100 >= 70) ratingCool = " B";
            if (ratingPercent*100 >= 80) ratingCool = " A";
            if (ratingPercent*100 >= 85) ratingCool = " A.";
            if (ratingPercent*100 >= 90) ratingCool = " A:";
            if (ratingPercent*100 >= 93) ratingCool = " AA";
			if (ratingPercent*100 >= 96.50) ratingCool = " AA.";
			if (ratingPercent*100 >= 99) ratingCool = " AA:";
			if (ratingPercent*100 >= 99.70) ratingCool = " AAA";
			if (ratingPercent*100 >= 99.80) ratingCool = " AAA.";
			if (ratingPercent*100 >= 99.90) ratingCool = " AAA:";
			if (ratingPercent*100 >= 99.955) ratingCool = " AAAA";
			if (ratingPercent*100 >= 99.970) ratingCool = " AAAA.";
			if (ratingPercent*100 >= 99.980) ratingCool = " AAAA:";
			if (ratingPercent*100 >= 99.9935) ratingCool = " AAAAA";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
		setOnLuas('ratingCool', ratingCool);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ !ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
