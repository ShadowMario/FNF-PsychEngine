package;

import ModConfig.ConfIntro;
import mod_support_stuff.SwitchModSubstate;
import flixel.addons.plugin.control.FlxControl;
import flixel.group.FlxSpriteGroup;
import sys.io.File;
import sys.FileSystem;
import haxe.Exception;
import haxe.Json;
import haxe.Http;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if newgrounds
import io.newgrounds.NG;
#end
import lime.app.Application;
import openfl.Assets;

using StringTools;

typedef TitleScreen = {
	var script:Script;
	var grp:FlxSpriteGroup;
}
class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var updateAlphabet:Alphabet;
	var updateIcon:FlxSprite;
	var updateRibbon:FlxSprite;

	var script:Script = null;
	var titleSpriteGrp:FlxSpriteGroup = null;

	var introConf:ConfIntro = null;

	var thrd:Thread;

	public static var startMod:String = null;

	public function new() {
		// do stuff
		if (startMod != null && startMod.trim() != "") {
			Settings.engineSettings.data.selectedMod = startMod;
			startMod = null;
		}
		super();
	}
	override public function create():Void
	{
		if (!initialized) FlxTransitionableState.skipNextTransIn = true;
		reloadModsState = true;
		
		Application.current.onExit.add (function (exitCode) {
			Settings.engineSettings.data.volume = FlxG.sound.volume;
			Settings.engineSettings.flush();
		});

		trace("PlayerSettings");
		PlayerSettings.init();

		trace("curWacky");
		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		trace("super.create()");
		super.create();
		
		trace("Highscore.load");
		Highscore.load();
		#if web
			trace("Loading characters library");
			Assets.loadLibrary("characters");
		#end

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState_New());
		#else
		startIntro();
		#end

		#if desktop
		trace("DiscordClient");
		DiscordClient.initialize();
		
		trace("Application.current.onExit");
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		});
		
		#end
		FlxG.autoPause = Settings.engineSettings.data.autopause == true;
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	var isInTransition = false;

	function startIntro()
	{
		if (!initialized)
		{
			FlxG.sound.volume = Settings.engineSettings.data.volume;
			CoolUtil.playMenuMusic(true);
		}

		var conf = null;
		if ((conf = ModSupport.modConfig[Settings.engineSettings.data.selectedMod]) != null && conf.intro != null) {
			introConf = conf.intro;
			if (introConf.bpm == null) introConf.bpm = 102;
			if (introConf.authors == null) introConf.authors = ['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er'];
			if (introConf.present == null) introConf.present = 'present';
			if (introConf.assoc == null) introConf.assoc = ['In association', 'with'];
			if (introConf.newgrounds == null) introConf.newgrounds = 'newgrounds';
			if (introConf.gameName == null) introConf.gameName = ['Friday Night Funkin\'', 'YoshiCrafter', 'Engine'];
		} else {
			introConf = {
				bpm: 102,
				authors: ['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er'],
				present: 'present',
				assoc: ['In association', 'with'],
				newgrounds: 'newgrounds',
				gameName: ['Friday Night Funkin\'', 'YoshiCrafter', 'Engine']
			};
		}

		Conductor.changeBPM(introConf.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, true);
		add(bg);
		
		var path = '${Paths.modsPath}/${Settings.engineSettings.data.selectedMod}/data';
		
		script = Script.create('$path/titlescreen');
		var mod = Settings.engineSettings.data.selectedMod;
		if (script == null) {
			path = '${Paths.modsPath}/${Settings.engineSettings.data.selectedMod}/ui';
			mod = 'Friday Night Funkin\'';
			script = Script.create('$path/titlescreen');
			if (script == null) {
				path = '${Paths.modsPath}/Friday Night Funkin\'/data';
				mod = 'Friday Night Funkin\'';
				script = Script.create('$path/titlescreen');
			}
		}
		if (script != null) {
			titleSpriteGrp = new FlxSpriteGroup(0, 0);
			script.setVariable("state", this);
			script.setVariable("create", function() {});
			script.setVariable("beatHit", function(curBeat:Int) {});
			script.setVariable("stepHit", function(curStep:Int) {});
			script.setVariable("update", function(elapsed:Float) {});
			script.setVariable("add", titleSpriteGrp.add);
			ModSupport.setScriptDefaultVars(script, mod, {});
			script.setScriptObject(this);
			script.loadFile('$path/titlescreen');
			script.executeFunc("create");
			add(titleSpriteGrp);
		}

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#if android
			titleText.animation.addByPrefix('idle', "Android_Idle", 24);
			titleText.animation.addByPrefix('press', "Android_Press", 24);
		#else
			titleText.animation.addByPrefix('idle', "Windows_Idle", 24);
			titleText.animation.addByPrefix('press', "Windows_Press", 24);
		#end
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(X);
		#if shitTest
			titleText.shader = new CustomShader("Friday Night Funkin':blammed", null, null);
		#end
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		
		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, true);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = true;
		
		updateRibbon = new FlxSprite(0, FlxG.height - 75).makeGraphic(FlxG.width, 75, 0x88000000, true);
		updateRibbon.visible = false;
		updateRibbon.alpha = 0;
		add(updateRibbon);

		updateIcon = new FlxSprite(FlxG.width - 75, FlxG.height - 75);
		updateIcon.frames = Paths.getSparrowAtlas("pauseAlt/bfLol", "shared");
		updateIcon.animation.addByPrefix("dance", "funnyThing instance 1", 20, true);
		updateIcon.animation.play("dance");
		updateIcon.setGraphicSize(65);
		updateIcon.updateHitbox();
		updateIcon.antialiasing = true;
		updateIcon.visible = false;
		add(updateIcon);

		updateAlphabet = new Alphabet(0, 0, "Checking for updates...", false, false, FlxColor.WHITE);
		for(c in updateAlphabet.members) {
			c.scale.x /= 2;
			c.scale.y /= 2;
			c.updateHitbox();
			c.x /= 2;
			c.y /= 2;
		}
		updateAlphabet.visible = false;
		updateAlphabet.x = updateIcon.x - updateAlphabet.width - 10;
		updateAlphabet.y = updateIcon.y;
		add(updateAlphabet);
		updateIcon.y += 15;
		

		if (initialized)
			skipIntro();
		else
			initialized = true;

		script.executeFunc("createPost");
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var introText:Array<Array<String>> = [];

		var e = Paths.txt("introText");
		if (Assets.exists(e)) {
			var text = Assets.getText(e).replace("\r", "");
			for(l in text.split("\n")) if (l.trim() != "" && l.indexOf("--") != -1) introText.push(l.split("--"));
		}
		if (introText.length == 0) introText = [["the intro text", "where did it go"]];

		return introText;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (script != null) script.executeFunc("update", [elapsed]);
		#if secretCharter
			if (FlxG.keys.justPressed.F2) {
				CoolUtil.loadSong("Friday Night Funkin'", "MILF", "Hard");
				charter.ChartingState_New._song = PlayState._SONG;
				FlxG.switchState(new charter.YoshiCrafterCharter());
			}
		#end
		if (FlxG.keys.justPressed.TAB && skippedIntro) {
			persistentUpdate = false;
			openSubState(new SwitchModSubstate());
		}
		if (updateRibbon != null) {
			updateRibbon.alpha = Math.min(1, updateRibbon.alpha + (elapsed / 0.2));
		}
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxControls.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxControls.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			script.executeFunc("onPressEnter", []);

			if (titleText != null) titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			CoolUtil.playMenuSFX(1);

			transitioning = true;

			var tmr = new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				script.executeFunc("onUpdateCheck", []);
				if (Settings.engineSettings.data.checkForUpdates) {
					thrd = Thread.create(function() {
						try {
							var data = Http.requestUrl("https://raw.githubusercontent.com/YoshiCrafter29/YC29Engine-Latest/main/_changes/list.txt");
							
							onUpdateData(data);
						} catch(e) {
							trace(e);
							FlxG.switchState(new MainMenuState());
						}
					});
					updateIcon.visible = true;
					updateAlphabet.visible = true;
					updateRibbon.visible = true;
					updateRibbon.alpha = 0;
				} else {
					FlxG.switchState(new MainMenuState());
				}
				
			});
			script.executeFunc("onPressEnterPost", [tmr]);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		try {
			super.update(elapsed);
		} catch(e) {
			
		}
		if (script != null) script.executeFunc("postUpdate", [elapsed]);
		if (script != null) script.executeFunc("updatePost", [elapsed]);
	}

	function onUpdateData(data:String) {
		script.executeFunc("onUpdateData", [data]);
		var versions = [for(e in data.split("\n")) if (e.trim() != "") e];
		var currentVerPos = versions.indexOf(Main.engineVer);
		var files:Array<String> = [];
		for(i in currentVerPos+1...versions.length) {
			var data:String = "";
			try {
				data = Http.requestUrl('https://raw.githubusercontent.com/YoshiCrafter29/YC29Engine-Latest/main/_changes/${versions[i]}.txt');
			} catch(e) {
				trace(versions[i] + " data is incorrect");
			}
			var parsedFiles = [for(e in data.split("\n")) if (e.trim() != "") e];
			for(f in parsedFiles) {
				if (!files.contains(f)) {
					files.push(f);
				}
			}
		}

		var changeLog:String = Http.requestUrl('https://raw.githubusercontent.com/YoshiCrafter29/YC29Engine-Latest/main/_changes/changelog.txt');
		#if enable_updates
		trace(currentVerPos);
		trace(versions.length);
		
		updateIcon.visible = false;
		updateAlphabet.visible = false;
		updateRibbon.visible = false;
		
		if (currentVerPos+1 < versions.length)
		{
			trace("OLD VER!!!");
			FlxG.switchState(new OutdatedSubState(files, versions[versions.length - 1], changeLog));
		}
		else
		{
		#end
		FlxG.switchState(new MainMenuState());
		#if enable_updates
		}
		#end
	}
	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	override function stepHit() {
		super.stepHit();
		if (script != null) script.executeFunc("stepHit", [curStep]);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var skipBeat:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		if (script != null) script.executeFunc("beatHit", [curBeat]);

		if (script.executeFunc("textShit", [curBeat]) != false) {
			switch (curBeat)
			{
				case 1:
					createCoolText(introConf.authors);
				case 3:
					addMoreText(introConf.present);
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(introConf.assoc);
				case 7:
					addMoreText(introConf.newgrounds);
					ngSpr.visible = true;
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText(introConf.gameName[0]);
				case 14:
					addMoreText(introConf.gameName[1]);
				case 15:
					addMoreText(introConf.gameName[2]);
				case 16:
					skipBeat = 16;
					skipIntro();
			}
		}
		
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (script != null) script.executeFunc("onSkipIntro");

		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
		if (Settings.engineSettings != null) {
			FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
			FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
		}
		if (script != null) script.executeFunc("onSkipIntroPost");
	}
}
