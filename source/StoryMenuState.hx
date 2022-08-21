package;

import Script.DummyScript;
import dev_toolbox.week_editor.WeekEditor;
import WeeksJson.FNFWeek;
import haxe.io.Path;
import Script.HScript;
import mod_support_stuff.SwitchModSubstate;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxTileFrames;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.tweens.FlxEase;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;


class StoryMenuState extends MusicBeatState
{
	var colorTween:FlxTween;
	var scoreText:FlxText;

	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<FlxSprite>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var yellowBG:FlxSprite;
	var blackBG:FlxSprite;

	var switchMod:FlxText;

	var menuScript:Script;

	public var weekData:Array<FNFWeek> = null;
	public var weekButtons:Array<String> = null;

	var dads:Map<String, FlxSprite> = [];
	var gfs:Map<String, FlxSprite> = [];
	var bfs:Map<String, FlxSprite> = [];
	var bgs:Map<String, FlxSprite> = [];

	public function loadWeeks() {
		weekData = [];
		weekButtons = [];
		
		var mod = Settings.engineSettings.data.selectedMod;
		var jsonPath = Paths.getPath('weeks.json', TEXT, 'mods/$mod');
		if (Assets.exists(jsonPath)) {
			var json:WeeksJson = null;
			try {
				json = Json.parse(Assets.getText(jsonPath));
			} catch(e) {
				LogsOverlay.error('$e');
			}
			if (json == null) return;
			if (json.weeks == null) {
				LogsOverlay.error('"week" value for $mod\'s weeks.json is null. Skipping...');
				return;
			};
			for(week in json.weeks) {
				week.mod = mod;
				if (week.difficulties == null) week.difficulties = [
					{"name" : "Easy", "sprite" : "storymenu/easy"},
					{"name" : "Normal", "sprite" : "storymenu/normal"},
					{"name" : "Hard", "sprite" : "storymenu/hard"}
				];
				weekData.push(week);
				

				var weekButton = Paths.image(CoolUtil.getCleanupImagesPath(week.buttonSprite), 'mods/$mod');
				weekButtons.push(weekButton);
			}
		}
	}

	var difficultySprites:Map<String, FlxSprite> = [];
	override function create()
	{
		FlxG.cameras.reset();
		reloadModsState = true;
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		
		CoolUtil.playMenuMusic();

		menuScript = Script.create('${Paths.getModsPath()}/${Settings.engineSettings.data.selectedMod}/ui/StoryMenuState');
		var validated = true;
		if (menuScript == null) {
			menuScript = new DummyScript();
			validated = false;
		}
		ModSupport.setScriptDefaultVars(menuScript, '${Settings.engineSettings.data.selectedMod}', {});
		menuScript.setVariable("state", this);
		if (validated) {
			menuScript.setScriptObject(this);
			menuScript.loadFile('${Paths.getModsPath()}/${Settings.engineSettings.data.selectedMod}/ui/StoryMenuState');
		}
		
		
		menuScript.setVariable("setWeekLocked", function(weekName:String, lock:Bool) {
			if (weekName == null) LogsOverlay.error("Week Name is null");
			for (w in weekData) {
				if (w.name == weekName) {
					w.locked = lock;
					return;
				}
			}
			LogsOverlay.error('Week "${weekName}" does not exist.');
		});

		menuScript.executeFunc("create", []);

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: -", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, FlxColor.WHITE, true);
		yellowBG.color = 0xFFF9CF51;
		blackBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, 56, FlxColor.BLACK, true);
		blackBG.color = 0xFFF9CF51;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK, true);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<FlxSprite>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var invalid = false;

		loadWeeks();

		var currentWeekButtons = [];

		var height:Float = 0;
		menuScript.executeFunc("createWeeks");

		for (i in 0...weekData.length)
		{
			var w:FNFWeek = weekData[i];

			if (w.bg != null && w.bg.trim() != "") {
				if (bgs[w.bg] == null) {
					var bg = new FlxSprite(yellowBG.x + (yellowBG.width / 2), yellowBG.y + (yellowBG.height / 2));
					if (Assets.exists(Paths.getPath('images/${w.bg}.xml', TEXT))) {
						bg.frames = Paths.getSparrowAtlas(w.bg);
					} else {
						bg.loadGraphic(Paths.image(w.bg));
					}
					bg.antialiasing = true;
					bg.visible = false;
					bgs[w.bg] = bg;
					grpWeekCharacters.add(bg);
				}
				if (w.bgAnim != null && w.bgAnim.trim() != "")
					bgs[w.bg].animation.addByPrefix(w.bgAnim, w.bgAnim, 24, true);
			}
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, w.buttonSprite);
			weekThing.y += height;
			weekThing.targetY = grpWeekText.length; //big brain
			weekThing.antialiasing = true;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			height += weekThing.height + 20;

			if (w.locked == true)
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 266");

		var vi = true;
		for (week in weekData) {
			var mod = week.mod;
			if (week.dad == null) {
				week.dad = {
					file: "storymenu/campaign_menu_UI_characters",
					animation: "Dad idle dance BLACK LINE",
					scale: 0.5,
					flipX: false,
					offset: [
						120,
						200
					],
					confirmAnim: ""
				}
			}
			if (week.gf == null) {
				week.gf = {
					flipX: false,
					file: "storymenu/campaign_menu_UI_characters",
					animation: "GF Dancing Beat WHITE",
					offset: [
						150,
						159
					],
					scale: 0.5,
					confirmAnim: ""
				}
			}
			if (week.bf == null) {
				week.bf = {
					flipX: false,
					file: "storymenu/campaign_menu_UI_characters",
					animation: "BF idle dance white",
					offset: [
						100,
						20
					],
					scale: 0.9,
					confirmAnim: "BF HEY!!"
				}
			}
			if (week.dad.file.trim() != "") {
				var dadPath = CoolUtil.getCleanupImagesPath(week.dad.file);
				if (dads[dadPath] == null) {
					var menuCharacter = new FlxSprite((FlxG.width * 0.25) - 150, 70);
					menuCharacter.frames = Paths.getSparrowAtlas(dadPath);
					menuCharacter.antialiasing = true;
					menuCharacter.visible = false;
					grpWeekCharacters.add(menuCharacter);
					dads[dadPath] = menuCharacter;
				}
				if (dadPath.trim() != "" && week.dad.confirmAnim != null && week.dad.confirmAnim.trim() != "")
					dads[dadPath].animation.addByPrefix(week.dad.confirmAnim, week.dad.confirmAnim, 24, false);
				dads[dadPath].animation.addByPrefix(week.dad.animation, week.dad.animation, 24);
				dads[dadPath].animation.play(week.dad.animation);
			}


			if (week.bf.file.trim() != "") {
				var bfPath = CoolUtil.getCleanupImagesPath(week.bf.file);
				if (bfs[bfPath] == null) {
					var menuCharacter = new FlxSprite((FlxG.width * 0.5) - 150, 70);
					menuCharacter.frames = Paths.getSparrowAtlas(bfPath);
					menuCharacter.antialiasing = true;
					menuCharacter.visible = false;
					grpWeekCharacters.add(menuCharacter);
					bfs[bfPath] = menuCharacter;
				}
				if (week.bf.confirmAnim != null && week.bf.confirmAnim.trim() != "")
					bfs[bfPath].animation.addByPrefix(week.bf.confirmAnim, week.bf.confirmAnim, 24, false);
				bfs[bfPath].animation.addByPrefix(week.bf.animation, week.bf.animation, 24);
				bfs[bfPath].animation.play(week.bf.animation);
			}

			
			if (week.gf.file.trim() != "") {
				var gfPath = CoolUtil.getCleanupImagesPath(week.gf.file);
				if (gfs[gfPath] == null) {
					var menuCharacter = new FlxSprite((FlxG.width * 0.75) - 150, 70);
					if (gfPath.trim() != "") {
						menuCharacter.frames = Paths.getSparrowAtlas(gfPath);
					} else {
						menuCharacter.alpha = 0;
					}
					menuCharacter.antialiasing = true;
					grpWeekCharacters.add(menuCharacter);
					gfs[gfPath] = menuCharacter;
				}
				if (week.gf.confirmAnim != null && week.gf.confirmAnim.trim() != "")
					gfs[gfPath].animation.addByPrefix(week.gf.confirmAnim, week.gf.confirmAnim, 24, false);
				gfs[gfPath].animation.addByPrefix(week.gf.animation, week.gf.animation, 24);
				gfs[gfPath].animation.play(week.gf.animation);
			}
		}
		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		for(week in weekData) {
			if (week.mod == Settings.engineSettings.data.selectedMod) {
				for (diff in week.difficulties) {
					
					var p = Paths.image(diff.sprite);
					if (!Assets.exists(p)) {
						var bitmapMod = week.mod;
						var bitmapPath = "";
						var bitmapSplit:Array<String> = diff.sprite.split(":");
						if (bitmapSplit[0].toLowerCase() == "yoshiengine") bitmapSplit[0] = "YoshiCrafterEngine";
						if (bitmapSplit.length < 2) {
							bitmapPath = diff.sprite;
						} else {
							bitmapMod = bitmapSplit[0];
							bitmapPath = bitmapSplit[1];
						}
						p = Paths.image(bitmapPath);
					}

					if (difficultySprites[p] == null) {
						var modsPath = Paths.modsPath;
						sprDifficulty = new FlxSprite(1070, grpWeekText.members[0].y + 10);
						
						sprDifficulty.loadGraphic(p);
						if (sprDifficulty.width > 290) sprDifficulty.setGraphicSize(290);
						sprDifficulty.x -= (sprDifficulty.width / 2);
						difficultySelectors.add(sprDifficulty);
						sprDifficulty.antialiasing = true;
						difficultySprites[p] = sprDifficulty;
					}
					diff.sprite = p;
				}
			}
		}


		switchMod = new FlxText(10, 10, 0, '${ModSupport.getModName(Settings.engineSettings.data.selectedMod)}\n[Tab] to switch\n', 24);
		switchMod.alignment = CENTER;
		switchMod.font = rankText.font;
		switchMod.color = 0xFFFFFFFF;
		switchMod.alpha = 2 / 3;
		switchMod.y = FlxG.height + 14 - switchMod.height;
		switchMod.x = FlxG.width - 10 - switchMod.width;
		add(switchMod);

		if (weekData.length <= 0) {
			add(blackBG);
			add(yellowBG);
			add(grpWeekCharacters);
			add(txtTracklist);
			add(scoreText);
			add(txtWeekTitle);
			
			var text = new FlxText(10, yellowBG.y + yellowBG.height + 10, FlxG.width - 20, "This mod does not contain any Story Mode weeks.", 18);
			text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.alpha = 0.66;
			add(text);
			super.create();
			return;
		}
		leftArrow = new FlxSprite(FlxG.width - (FlxG.width - (FlxG.width - 90 - 175 + 48)), grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = true;
		leftArrow.x -= leftArrow.width;
		difficultySelectors.add(leftArrow);

		rightArrow = new FlxSprite(FlxG.width - (1280 - 1222), leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = true;
		difficultySelectors.add(rightArrow);

		changeDifficulty();

		trace("Line 150");

		add(blackBG);
		add(yellowBG);
		add(grpWeekCharacters);
		grpWeekCharacters.visible = true;

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);
		updateText();

		trace("Line 165");

		super.create();

		var co = 0xFFF9CF51;
		if (weekData[0].color != null) {
			var c = FlxColor.fromString(weekData[0].color);
			if (c != null) co = c;
		}
		yellowBG.color = co;
		menuScript.executeFunc("createPost");
	}

	override function update(elapsed:Float)
	{
		menuScript.executeFunc("preUpdate", [elapsed]);
		
		if (FlxControls.justPressed.F5) FlxG.resetState();
		if (FlxControls.justPressed.TAB) {
			persistentUpdate = false;
			openSubState(new SwitchModSubstate());
		}
		
		if (weekData.length <= 0) {
			if (controls.BACK) FlxG.switchState(new MainMenuState());
			super.update(elapsed);
			return;
		}
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5 * 60 * elapsed));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekData[curWeek].name;
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		
		menuScript.executeFunc("update", [elapsed]);
		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			CoolUtil.playMenuSFX(2);
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (CoolUtil.isDevMode() && FlxG.keys.justPressed.SEVEN) {
			WeekEditor.fromStory = true;
			FlxG.switchState(new WeekEditor(curWeek));
		}
		menuScript.executeFunc("postUpdate", [elapsed]);
		menuScript.executeFunc("updatePost", [elapsed]);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		var week:FNFWeek;
		if ((week = weekData[curWeek]).locked != true)
		{
			if (stopspamming == false)
			{
				if (week.selectSFX == null || week.selectSFX.trim() == "")
					CoolUtil.playMenuSFX(1);
				else
					FlxG.sound.play(Paths.sound(week.selectSFX));
				grpWeekText.members[curWeek].startFlashing();

				if (week.dad != null)
					if (week.dad.confirmAnim != null && week.dad.confirmAnim.trim() != "")
						for(e in dads)
							if (e.visible)
								e.animation.play(week.dad.confirmAnim);

				if (week.bf != null)
					if (week.bf.confirmAnim != null && week.bf.confirmAnim.trim() != "")
						for(e in bfs)
							if (e.visible)
								e.animation.play(week.bf.confirmAnim);

				if (week.gf != null)
					if (week.gf.confirmAnim != null && week.gf.confirmAnim.trim() != "")
						for(e in gfs)
							if (e.visible)
								e.animation.play(week.gf.confirmAnim);
			}

			PlayState.actualModWeek = weekData[curWeek];
			PlayState.songMod = weekData[curWeek].mod;
			PlayState.storyPlaylist = weekData[curWeek].songs;
			PlayState.isStoryMode = true;
			PlayState.startTime = 0;
			selectedWeek = true;

			PlayState.storyDifficulty = weekData[curWeek].difficulties[curDifficulty].name;

			PlayState._SONG = Song.loadModFromJson(Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), weekData[curWeek].difficulties[curDifficulty].name), PlayState.songMod, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.jsonSongName = PlayState.storyPlaylist[0].toLowerCase();
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.fromCharter = false;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		} else {
			CoolUtil.playMenuSFX(3);
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		var oldDiff = curDifficulty;
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = weekData[curWeek].difficulties.length - 1;
		if (curDifficulty >= weekData[curWeek].difficulties.length)
			curDifficulty = 0;

		if (menuScript.executeFunc("onChangeDifficulty", [curDifficulty]) == false) {
			curDifficulty = oldDiff;
			CoolUtil.playMenuSFX(3);
			return;
		}

		var sprDifficulty = difficultySprites[weekData[curWeek].difficulties[curDifficulty].sprite];
		sprDifficulty.offset.x = 0;
		for(diffSprite in difficultySprites) {
			diffSprite.visible = false;
		}
		sprDifficulty.visible = true;

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getModWeekScore(weekData[curWeek].mod, weekData[curWeek].name, weekData[curWeek].difficulties[curDifficulty].name);

		#if !switch
		intendedScore = Highscore.getModWeekScore(weekData[curWeek].mod, weekData[curWeek].name, weekData[curWeek].difficulties[curDifficulty].name);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);

		menuScript.executeFunc("onChangeDifficultyPost", [curDifficulty]);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		var diffName = weekData[curWeek].difficulties[curDifficulty].name;
		var oldWeek = curWeek;
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		if (menuScript.executeFunc("onChangeWeek", [curWeek]) == false) {
			curWeek = oldWeek;
			CoolUtil.playMenuSFX(3);
			return;
		}
		var bullShit:Int = 0;

		var diffIndex = 0;
		for(i in 0...weekData[curWeek].difficulties.length) {
			if (weekData[curWeek].difficulties[i].name == diffName) {
				diffIndex = i;
				break;
			}
		}
		curDifficulty = diffIndex;
		changeDifficulty();
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		CoolUtil.playMenuSFX(0);

		updateText();
		menuScript.executeFunc("onChangeWeekPost", [curWeek]);
	}

	function updateText()
	{

		for(e in [dads, bfs, gfs, bgs])
			for(e2 in e)
				e2.visible = false;
		
		var week = weekData[curWeek];

		var dad = dads[CoolUtil.getCleanupImagesPath(week.dad.file)];
		if (dad != null) {
			dad.visible = true;
			dad.animation.play(week.dad.animation);
			dad.flipX = week.dad.flipX;
			dad.scale.set(week.dad.scale, week.dad.scale);
			dad.updateHitbox();
			if (week.dad.offset != null) {
				dad.offset.set(week.dad.offset[0], week.dad.offset[1]);
			}
		}

		var bf = bfs[CoolUtil.getCleanupImagesPath(week.bf.file)];
		if (bf != null) {
			bf.visible = true;
			bf.animation.play(week.bf.animation);
			bf.flipX = week.bf.flipX;
			bf.scale.set(week.bf.scale, week.bf.scale);
			bf.updateHitbox();
			if (week.bf.offset != null) {
				bf.offset.set(week.bf.offset[0], week.bf.offset[1]);
			}
		}

		var gf = gfs[CoolUtil.getCleanupImagesPath(week.gf.file)];
		if (gf != null) {
			gf.visible = true;
			gf.animation.play(week.gf.animation);
			gf.flipX = week.gf.flipX;
			gf.scale.set(week.gf.scale, week.gf.scale);
			gf.updateHitbox();
			if (week.gf.offset != null) {
				gf.offset.set(week.gf.offset[0], week.gf.offset[1]);
			}
		}

		var bg = bgs[week.bg];
		if (bg != null) {
			bg.visible = true;
			if (week.bgAnim != null && week.bgAnim.trim() != "") {
				bg.animation.play(week.bgAnim);
			}
			bg.setPosition(
				yellowBG.x + ((yellowBG.width - bg.width) / 2),
				yellowBG.y + ((yellowBG.height - bg.height) / 2));
		}
		
		if (colorTween != null) colorTween.cancel();
		var co = 0xFFF9CF51;
		if (week.color != null) {
			var c = FlxColor.fromString(week.color);
			if (c != null) co = c;
		}
		colorTween = FlxTween.color(yellowBG, 0.25, yellowBG.color, co, {ease : FlxEase.smoothStepInOut});
		
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = week.songs;

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text += "\n";
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getModWeekScore(week.mod, week.name, week.difficulties[curDifficulty].name);
		#end
	}
}
