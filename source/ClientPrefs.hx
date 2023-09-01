package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class ClientPrefs { //default settings if it can't find a save file containing your current settings
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var mobileMidScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var healthDisplay:Bool = true;
	public static var ghostTapAnim:Bool = true;
	public static var spaceVPose:Bool = true;
	public static var cameraPanning:Bool = true;
	public static var colorQuants:Bool = false;
	public static var panIntensity:Float = 1;
	public static var noteSplashes:Bool = true;
	public static var cacheOnGPU:Bool = false;
	public static var communityGameBot:Bool = false;
	public static var noSyncing:Bool = false;
	public static var startingSync:Bool = false;
	public static var playerLightStrum:Bool = true;
	public static var progAudioLoad:Bool = false;
	public static var oppNoteSplashes:Bool = true;
	public static var instaRestart:Bool = false;
	public static var charsAndBG:Bool = true;
	public static var lowQuality:Bool = false;
	public static var fasterChartLoad:Bool = false;
	public static var shaders:Bool = true;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var maxSplashLimit:Int = 16;
	public static var showMaxScore:Bool = true;
	public static var longHPBar:Bool = false;
	public static var moreMaxHP:Bool = false;
	public static var songPercentage:Bool = true;
	public static var autosaveInterval:Float = 5.0;
	public static var comboMultLimit:Float = 5;
	public static var autosaveCharts:Bool = true;
	public static var antiCheatEnable:Bool = false;
	public static var bfIconStyle:String = 'Default';
	public static var noteStyleThing:String = 'Default';
	public static var daMenuMusic:String = 'Mashup';
	public static var ratingIntensity:String = 'Normal';
	public static var autoPause:Bool = true;
	public static var randomBotplayText:Bool = true;
	public static var opponentLightStrum:Bool = true;
	public static var complexAccuracy:Bool = false;
	public static var resyncType:String = 'Psych';
	public static var botLightStrum:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var showNotes:Bool = true;
	public static var doubleGhost:Bool = true;
	public static var songLoading:Bool = true;
	public static var resultsScreen:Bool = true;
	public static var hideHud:Bool = false;
	public static var hideScore:Bool = false;
	public static var maxPerformance:Bool = false;
	public static var voiidTrollMode:Bool = false;
	public static var compactNumbers:Bool = false;
	public static var longFCName:Bool = false;
	public static var holdNoteHits:Bool = false;
	public static var comboScoreEffect:Bool = false;
	public static var comboMultiType:String = 'osu!';
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var ghostTapping:Bool = true;
	public static var communityGameMode:Bool = false;
	public static var wrongCameras:Bool = false;
	public static var shitGivesMiss:Bool = false;
	public static var trollMaxSpeed:String = 'Medium';
	public static var timebarShowSpeed:Bool = false;
	public static var noteSpawnTime:Float = 1;
	public static var dynamicSpawnTime:Bool = false;
	public static var evenLessBotLag:Bool = false;
	public static var progChartLoad:Bool = false;
	public static var oppNoteAlpha:Float = 0.65;
	public static var lessBotLag:Bool = false;
	public static var ratesAndCombo:Bool = false;
	public static var showNPS:Bool = false;
	public static var showMS:Bool = false;
	public static var comboPopup:Bool = false;
	public static var ratingCounter:Bool = false;
	public static var memLeaks:Bool = false;
	public static var noPausing:Bool = false;
	public static var doubleGhostZoom:Bool = true;
	public static var npsWithSpeed:Bool = true;
	public static var moreSpecificSpeed:Bool = true;
	public static var lengthIntro:Bool = true;
	public static var opponentRateCount:Bool = true;
	public static var coolGameplay:Bool = false;
	public static var skipResultsScreen:Bool = false;
	public static var hudType:String = 'Kade Engine';
	public static var smoothHealth:Bool = true;
	public static var smoothHealthType:String = 'Golden Apple 1.5';
	public static var rateNameStuff:String = 'Quotes';
	public static var accuracyMod:String = 'Accurate';
	public static var percentDecimals:Int = 2;
	public static var healthGainType:String = 'Psych Engine';
	public static var hitsoundType:String = 'osu!mania';
	public static var splashType:String = 'Psych Engine';
	public static var iconBounceType:String = 'Golden Apple';
	public static var ratingType:String = 'Base FNF';
	public static var timeBarType:String = 'Time Left';
	public static var marvRateColor:String = 'Golden';
	public static var noMarvJudge:Bool = false;
	public static var zeroHealthLimit:Bool = false;
	public static var scoreZoom:Bool = true;
	public static var goldSickSFC:Bool = true;
	public static var colorRatingFC:Bool = false;
	public static var colorRatingHit:Bool = true;
	public static var missSoundShit:Bool = false;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var laneUnderlayAlpha:Float = 1;
	public static var laneUnderlay:Bool = false;
	public static var controllerMode:Bool = #if android true #else false #end;
	public static var hitsoundVolume:Float = 0;
	public static var pauseMusic:String = 'Tea Time';
	public static var checkForUpdates:Bool = true;
	public static var comboStacking = true;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'onlySicks' => false,
		'practice' => false,
		'botplay' => false,
		'randommode' => false,
		'opponentplay' => false,
		'opponentdrain' => false,
		'drainlevel' => 1,
		'flip' => false,
		'stairmode' => false,
		'wavemode' => false,
		'onekey' => false,
		'jacks' => 0,
		'randomspeed' => false,
		'bothSides' => false,
		'thetrollingever' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var marvWindow:Int = 15;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE],
		'qt_taunt'		=> [SPACE, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	public static function saveSettings() { //changes settings when you exit so that it doesn't reset every time you close the game
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.mobileMidScroll = mobileMidScroll;
		FlxG.save.data.opponentStrums = opponentStrums;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.oppNoteSplashes = oppNoteSplashes;
		FlxG.save.data.songLoading = songLoading;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.evenLessBotLag = evenLessBotLag;
		FlxG.save.data.framerate = framerate;
		//FlxG.save.data.cursing = cursing;
		//FlxG.save.data.violence = violence;
		FlxG.save.data.progAudioLoad = progAudioLoad;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.daMenuMusic = daMenuMusic;
		FlxG.save.data.maxSplashLimit = maxSplashLimit;
		FlxG.save.data.showMaxScore = showMaxScore;
		FlxG.save.data.autosaveInterval = autosaveInterval;
		FlxG.save.data.autosaveCharts = autosaveCharts;
		FlxG.save.data.rateNameStuff = rateNameStuff;
		FlxG.save.data.fasterChartLoad = fasterChartLoad;
		FlxG.save.data.longFCName = longFCName;
		FlxG.save.data.showNotes = showNotes;
		FlxG.save.data.skipResultsScreen = skipResultsScreen;
		FlxG.save.data.accuracyMod = accuracyMod;
		FlxG.save.data.playerLightStrum = playerLightStrum;
		FlxG.save.data.healthDisplay = healthDisplay;
		FlxG.save.data.wrongCameras = wrongCameras;
		FlxG.save.data.autoPause = autoPause;
		FlxG.save.data.holdNoteHits = holdNoteHits;
		FlxG.save.data.comboScoreEffect = comboScoreEffect;
		FlxG.save.data.comboMultiType = comboMultiType;
		FlxG.save.data.charsAndBG = charsAndBG;
		FlxG.save.data.doubleGhost = doubleGhost;
		FlxG.save.data.bfIconStyle = bfIconStyle;
		FlxG.save.data.noteStyleThing = noteStyleThing;
		FlxG.save.data.antiCheatEnable = antiCheatEnable;
		FlxG.save.data.randomBotplayText = randomBotplayText;
		FlxG.save.data.showNPS = showNPS;
		FlxG.save.data.startingSync = startingSync;
		FlxG.save.data.noSyncing = noSyncing;
		FlxG.save.data.resultsScreen = resultsScreen;
		FlxG.save.data.instaRestart = instaRestart;
		FlxG.save.data.percentDecimals = percentDecimals;
		FlxG.save.data.comboMultLimit = comboMultLimit;
		FlxG.save.data.iconBounceType = iconBounceType;
		FlxG.save.data.cameraPanning = cameraPanning;
		FlxG.save.data.panIntensity = panIntensity;
		FlxG.save.data.voiidTrollMode = voiidTrollMode;
		FlxG.save.data.complexAccuracy = complexAccuracy;
		FlxG.save.data.resyncType = resyncType;
		FlxG.save.data.compactNumbers = compactNumbers;
		FlxG.save.data.colorQuants = colorQuants;
		FlxG.save.data.noteSpawnTime = noteSpawnTime;
		FlxG.save.data.cacheOnGPU = cacheOnGPU;
		FlxG.save.data.hideScore = hideScore;
		FlxG.save.data.doubleGhostZoom = doubleGhostZoom;
		FlxG.save.data.memLeaks = memLeaks;
		FlxG.save.data.communityGameBot = communityGameBot;
		FlxG.save.data.dynamicSpawnTime = dynamicSpawnTime;
		FlxG.save.data.botLightStrum = botLightStrum;
		FlxG.save.data.opponentLightStrum = opponentLightStrum;
		FlxG.save.data.opponentRateCount = opponentRateCount;
		FlxG.save.data.zeroHealthLimit = zeroHealthLimit;
		FlxG.save.data.hitsoundType = hitsoundType;
		FlxG.save.data.hudType = hudType;
		FlxG.save.data.ratingCounter = ratingCounter;
		FlxG.save.data.colorRatingHit = colorRatingHit;
		FlxG.save.data.maxPerformance = maxPerformance;
		FlxG.save.data.healthGainType = healthGainType;
		FlxG.save.data.oppNoteAlpha = oppNoteAlpha;
		FlxG.save.data.noPausing = noPausing;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.ratesAndCombo = ratesAndCombo;
		FlxG.save.data.ratingType = ratingType;
		FlxG.save.data.showMS = showMS;
		FlxG.save.data.comboPopup = comboPopup;
		FlxG.save.data.ratingIntensity = ratingIntensity;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.lengthIntro = lengthIntro;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.longHPBar = longHPBar;
		FlxG.save.data.moreMaxHP = moreMaxHP;
		FlxG.save.data.npsWithSpeed = npsWithSpeed;
		FlxG.save.data.timebarShowSpeed = timebarShowSpeed;
		FlxG.save.data.trollMaxSpeed = trollMaxSpeed;
		FlxG.save.data.smoothHealthType = smoothHealthType;
		FlxG.save.data.smoothHealth = smoothHealth;
		FlxG.save.data.moreSpecificSpeed = moreSpecificSpeed;
		FlxG.save.data.spaceVPose = spaceVPose;
		FlxG.save.data.ghostTapAnim = ghostTapAnim;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.communityGameMode = communityGameMode;
		FlxG.save.data.lessBotLag = lessBotLag;
		FlxG.save.data.songPercentage = songPercentage;
		FlxG.save.data.coolGameplay = coolGameplay;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.marvRateColor = marvRateColor;
		FlxG.save.data.noMarvJudge = noMarvJudge;
		FlxG.save.data.goldSickSFC = goldSickSFC;
		FlxG.save.data.colorRatingFC = colorRatingFC;
		FlxG.save.data.missSoundShit = missSoundShit;
		FlxG.save.data.splashType = splashType;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.shitGivesMiss = shitGivesMiss;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.laneUnderlayAlpha = laneUnderlayAlpha;
		FlxG.save.data.laneUnderlay = laneUnderlay;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
		FlxG.save.data.progChartLoad = progChartLoad;
		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.marvWindow = marvWindow;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.checkForUpdates = checkForUpdates;
		FlxG.save.data.comboStacking = comboStacking;
	
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', CoolUtil.getSavePath()); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() { //loads settings if it finds a save file containing the settings
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.mobileMidScroll != null) {
			mobileMidScroll = FlxG.save.data.mobileMidScroll;
		}
		if(FlxG.save.data.opponentStrums != null) {
			opponentStrums = FlxG.save.data.opponentStrums;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.progAudioLoad != null) {
			progAudioLoad = FlxG.save.data.progAudioLoad;
		}
		if(FlxG.save.data.rateNameStuff != null) {
			rateNameStuff = FlxG.save.data.rateNameStuff;
		}
		if(FlxG.save.data.showMaxScore != null) {
			showMaxScore = FlxG.save.data.showMaxScore;
		}
		if(FlxG.save.data.maxSplashLimit != null) {
			maxSplashLimit = FlxG.save.data.maxSplashLimit;
		}
		if(FlxG.save.data.communityGameBot != null) {
			communityGameBot = FlxG.save.data.communityGameBot;
		}
		if(FlxG.save.data.colorQuants != null) {
			colorQuants = FlxG.save.data.colorQuants;
		}
		if(FlxG.save.data.cameraPanning != null) {
			cameraPanning = FlxG.save.data.cameraPanning;
		}
		if(FlxG.save.data.startingSync != null) {
			startingSync = FlxG.save.data.startingSync;
		}
		if(FlxG.save.data.noSyncing != null) {
			noSyncing = FlxG.save.data.noSyncing;
		}
		if(FlxG.save.data.songLoading != null) {
			songLoading = FlxG.save.data.songLoading;
		}
		if(FlxG.save.data.panIntensity != null) {
			panIntensity = FlxG.save.data.panIntensity;
		}
		if(FlxG.save.data.ratingIntensity != null) {
			ratingIntensity = FlxG.save.data.ratingIntensity;
		}
		if(FlxG.save.data.playerLightStrum != null) {
			playerLightStrum = FlxG.save.data.playerLightStrum;
		}
		if(FlxG.save.data.complexAccuracy != null) {
			complexAccuracy = FlxG.save.data.complexAccuracy;
		}
		if(FlxG.save.data.resyncType != null) {
			resyncType = FlxG.save.data.resyncType;
		}
		if(FlxG.save.data.maxPerformance != null) {
			maxPerformance = FlxG.save.data.maxPerformance;
		}
		if(FlxG.save.data.comboMultLimit != null) {
			comboMultLimit = FlxG.save.data.comboMultLimit;
		}
		if(FlxG.save.data.showNPS != null) {
			showNPS = FlxG.save.data.showNPS;
		}
		if(FlxG.save.data.resultsScreen != null) {
			resultsScreen = FlxG.save.data.resultsScreen;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.ratingType != null) {
			ratingType = FlxG.save.data.ratingType;
		}
		if(FlxG.save.data.charsAndBG != null) {
			charsAndBG = FlxG.save.data.charsAndBG;
		}
		if(FlxG.save.data.progChartLoad != null) {
			progChartLoad = FlxG.save.data.progChartLoad;
		}
		if(FlxG.save.data.fasterChartLoad != null) {
			fasterChartLoad = FlxG.save.data.fasterChartLoad;
		}
		if(FlxG.save.data.autoPause != null) {
			autoPause = FlxG.save.data.autoPause;
		}
		if(FlxG.save.data.voiidTrollMode != null) {
			voiidTrollMode = FlxG.save.data.voiidTrollMode;
		}
		if(FlxG.save.data.compactNumbers != null) {
			compactNumbers = FlxG.save.data.compactNumbers;
		}
		if(FlxG.save.data.npsWithSpeed != null) {
			npsWithSpeed = FlxG.save.data.npsWithSpeed;
		}
		if(FlxG.save.data.skipResultsScreen != null) {
			skipResultsScreen = FlxG.save.data.skipResultsScreen;
		}
		if(FlxG.save.data.cacheOnGPU != null) {
			cacheOnGPU = FlxG.save.data.cacheOnGPU;
		}
		if(FlxG.save.data.bfIconStyle != null) {
			bfIconStyle = FlxG.save.data.bfIconStyle;
		}
		if(FlxG.save.data.autosaveInterval != null) {
			autosaveInterval = FlxG.save.data.autosaveInterval;
		}
		if(FlxG.save.data.autosaveCharts != null) {
			autosaveCharts = FlxG.save.data.autosaveCharts;
		}
		if(FlxG.save.data.holdNoteHits != null) {
			holdNoteHits = FlxG.save.data.holdNoteHits;
		}
		if(FlxG.save.data.comboScoreEffect != null) {
			comboScoreEffect = FlxG.save.data.comboScoreEffect;
		}
		if(FlxG.save.data.comboMultiType != null) {
			comboMultiType = FlxG.save.data.comboMultiType;
		}
		if(FlxG.save.data.daMenuMusic != null) {
			daMenuMusic = FlxG.save.data.daMenuMusic;
		}
		if(FlxG.save.data.noteStyleThing != null) {
			noteStyleThing = FlxG.save.data.noteStyleThing;
		}
		if(FlxG.save.data.accuracyMod != null) {
			accuracyMod = FlxG.save.data.accuracyMod;
		}
		if(FlxG.save.data.lengthIntro != null) {
			lengthIntro = FlxG.save.data.lengthIntro;
		}
		if(FlxG.save.data.wrongCameras != null) {
			wrongCameras = FlxG.save.data.wrongCameras;
		}
		if(FlxG.save.data.dynamicSpawnTime != null) {
			dynamicSpawnTime = FlxG.save.data.dynamicSpawnTime;
		}
		if(FlxG.save.data.evenLessBotLag != null) {
			evenLessBotLag = FlxG.save.data.evenLessBotLag;
		}
		if(FlxG.save.data.doubleGhostZoom != null) {
			doubleGhostZoom = FlxG.save.data.doubleGhostZoom;
		}
		if(FlxG.save.data.memLeaks != null) {
			memLeaks = FlxG.save.data.memLeaks;
		}
		if(FlxG.save.data.longFCName != null) {
			longFCName = FlxG.save.data.longFCName;
		}
		if(FlxG.save.data.zeroHealthLimit != null) {
			zeroHealthLimit = FlxG.save.data.zeroHealthLimit;
		}
		if(FlxG.save.data.oppNoteAlpha != null) {
			oppNoteAlpha = FlxG.save.data.oppNoteAlpha;
		}
		if(FlxG.save.data.noPausing != null) {
			noPausing = FlxG.save.data.noPausing;
		}
		if(FlxG.save.data.marvRateColor != null) {
			marvRateColor = FlxG.save.data.marvRateColor;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.oppNoteSplashes != null) {
			oppNoteSplashes = FlxG.save.data.oppNoteSplashes;
		}
		if(FlxG.save.data.colorRatingHit != null) {
			colorRatingHit = FlxG.save.data.colorRatingHit;
		}
		if(FlxG.save.data.randomBotplayText != null) {
			randomBotplayText = FlxG.save.data.randomBotplayText;
		}
		if(FlxG.save.data.splashType != null) {
			splashType = FlxG.save.data.splashType;
		}
		if(FlxG.save.data.percentDecimals != null) {
			percentDecimals = FlxG.save.data.percentDecimals;
		}
		if(FlxG.save.data.songPercentage != null) {
			songPercentage = FlxG.save.data.songPercentage;
		}
		if(FlxG.save.data.antiCheatEnable != null) {
			antiCheatEnable = FlxG.save.data.antiCheatEnable;
		}
		if(FlxG.save.data.noteSpawnTime != null) {
			noteSpawnTime = FlxG.save.data.noteSpawnTime;
		}
		if(FlxG.save.data.timebarShowSpeed != null) {
			timebarShowSpeed = FlxG.save.data.timebarShowSpeed;
		}
		if(FlxG.save.data.opponentRateCount != null) {
			opponentRateCount = FlxG.save.data.opponentRateCount;
		}
		if(FlxG.save.data.trollMaxSpeed != null) {
			trollMaxSpeed = FlxG.save.data.trollMaxSpeed;
		}
		if(FlxG.save.data.instaRestart != null) {
			instaRestart = FlxG.save.data.instaRestart;
		}
		if(FlxG.save.data.healthDisplay != null) {
			healthDisplay = FlxG.save.data.healthDisplay;
		}
		if(FlxG.save.data.hitsoundType != null) {
			hitsoundType = FlxG.save.data.hitsoundType;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.ratingCounter != null) {
			ratingCounter = FlxG.save.data.ratingCounter;
		}
		if(FlxG.save.data.longHPBar != null) {
			longHPBar = FlxG.save.data.longHPBar;
		}
		if(FlxG.save.data.moreMaxHP != null) {
			moreMaxHP = FlxG.save.data.moreMaxHP;
		}
		if(FlxG.save.data.shaders != null) {
			shaders = FlxG.save.data.shaders;
		}
		if(FlxG.save.data.moreSpecificSpeed != null) {
			moreSpecificSpeed = FlxG.save.data.moreSpecificSpeed;
		}
		if(FlxG.save.data.goldSickSFC != null) {
			goldSickSFC = FlxG.save.data.goldSickSFC;
		}
		if(FlxG.save.data.botLightStrum != null) {
			botLightStrum = FlxG.save.data.botLightStrum;
		}
		if(FlxG.save.data.comboPopup != null) {
			comboPopup = FlxG.save.data.comboPopup;
		}
		if(FlxG.save.data.showMS != null) {
			showMS = FlxG.save.data.showMS;
		}
		if(FlxG.save.data.ratesAndCombo != null) {
			ratesAndCombo = FlxG.save.data.ratesAndCombo;
		}
		if(FlxG.save.data.missSoundShit != null) {
			missSoundShit = FlxG.save.data.missSoundShit;
		}
		if(FlxG.save.data.opponentLightStrum != null) {
			opponentLightStrum = FlxG.save.data.opponentLightStrum;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.shitGivesMiss != null) {
			shitGivesMiss = FlxG.save.data.shitGivesMiss;
		}
		if(FlxG.save.data.showNotes != null) {
			showNotes = FlxG.save.data.showNotes;
		}
		if(FlxG.save.data.doubleGhost != null) {
			doubleGhost = FlxG.save.data.doubleGhost;
		}
		if(FlxG.save.data.coolGameplay != null) {
			coolGameplay = FlxG.save.data.coolGameplay;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.hideScore != null) {
			hideScore = FlxG.save.data.hideScore;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.lessBotLag != null) {
			lessBotLag = FlxG.save.data.lessBotLag;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.smoothHealthType != null) {
			smoothHealthType = FlxG.save.data.smoothHealthType;
		}
		if(FlxG.save.data.smoothHealth != null) {
			smoothHealth = FlxG.save.data.smoothHealth;
		}
		if(FlxG.save.data.communityGameMode != null) {
			communityGameMode = FlxG.save.data.communityGameMode;
		}
		if(FlxG.save.data.spaceVPose != null) {
			spaceVPose = FlxG.save.data.spaceVPose;
		}
		if(FlxG.save.data.ghostTapAnim != null) {
			ghostTapAnim = FlxG.save.data.ghostTapAnim;
		}
		if(FlxG.save.data.timeBarType != null) {
			timeBarType = FlxG.save.data.timeBarType;
		}
		if(FlxG.save.data.hudType != null) {
			hudType = FlxG.save.data.hudType;
		}
		if(FlxG.save.data.healthGainType != null) {
			healthGainType = FlxG.save.data.healthGainType;
		}
		if(FlxG.save.data.iconBounceType != null) {
			iconBounceType = FlxG.save.data.iconBounceType;
		}
		if(FlxG.save.data.scoreZoom != null) {
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if(FlxG.save.data.noReset != null) {
			noReset = FlxG.save.data.noReset;
		}
		if(FlxG.save.data.healthBarAlpha != null) {
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if(FlxG.save.data.laneUnderlay != null) {
			laneUnderlay = FlxG.save.data.laneUnderlay;
		}
		if(FlxG.save.data.laneUnderlayAlpha != null) {
			laneUnderlayAlpha = FlxG.save.data.laneUnderlayAlpha;
		}
		if(FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}
		
		if(FlxG.save.data.ratingOffset != null) {
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if(FlxG.save.data.colorRatingFC != null) {
			colorRatingFC = FlxG.save.data.colorRatingFC;
		}
		if(FlxG.save.data.noMarvJudge != null) {
			noMarvJudge = FlxG.save.data.noMarvJudge;
		}
		if(FlxG.save.data.marvWindow != null) {
			marvWindow = FlxG.save.data.marvWindow;
		}
		if(FlxG.save.data.sickWindow != null) {
			sickWindow = FlxG.save.data.sickWindow;
		}
		if(FlxG.save.data.goodWindow != null) {
			goodWindow = FlxG.save.data.goodWindow;
		}
		if(FlxG.save.data.badWindow != null) {
			badWindow = FlxG.save.data.badWindow;
		}
		if(FlxG.save.data.safeFrames != null) {
			safeFrames = FlxG.save.data.safeFrames;
		}
		if(FlxG.save.data.controllerMode != null) {
			controllerMode = FlxG.save.data.controllerMode;
		}
		if(FlxG.save.data.hitsoundVolume != null) {
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		}
		if(FlxG.save.data.pauseMusic != null) {
			pauseMusic = FlxG.save.data.pauseMusic;
		}
		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}
		if (FlxG.save.data.checkForUpdates != null)
		{
			checkForUpdates = FlxG.save.data.checkForUpdates;
		}
		if (FlxG.save.data.comboStacking != null)
			comboStacking = FlxG.save.data.comboStacking;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', CoolUtil.getSavePath());
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
