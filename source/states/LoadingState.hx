package states;

import haxe.Json;
import sys.thread.Thread;
import lime.utils.Assets;
import openfl.utils.AssetType;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;

import backend.StageData;
import objects.Character;

class LoadingState extends MusicBeatState
{
	var target:FlxState = null;
	var stopMusic = false;
	var directory:String = null;

	public static var loaded:Int = 0;
	public static var loadMax:Int = 0;
	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}
	
	var bar:FlxSprite;
	var barWidth:Int = 0;
	var intendedPercent:Float = 0;
	var curPercent:Float = 0;
	var canChangeState:Bool = true;

	#if PSYCH_WATERMARKS
	var logo:FlxSprite;
	var pessy:FlxSprite;
	var loadingText:FlxText;

	var timePassed:Float;
	var shakeFl:Float;
	var shakeMult:Float = 0;
	
	var isSpinning:Bool = false;
	var spawnedPessy:Bool = false;
	var pressedTimes:Int = 0;
	#else
	var funkay:FlxSprite;
	var defaultScale:Float = 1;
	#end

	override function create()
	{
		if(checkLoaded(true))
		{
			super.create();
			skipUpdate = true;
			return;
		}

		#if PSYCH_WATERMARKS
		// PSYCH LOADING SCREEN

		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(FlxG.width));
		bg.color = 0xFFD16FFF;
		bg.updateHitbox();
		add(bg);
	
		loadingText = new FlxText(520, 600, 400, 'Now Loading...', 32);
		loadingText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
		loadingText.borderSize = 2;
		add(loadingText);
	
		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('loading_screen/icon'));
		logo.scale.set(0.75, 0.75);
		logo.updateHitbox();
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();
		logo.x -= 50;
		logo.y -= 40;
		add(logo);

		#else
		// BASE GAME LOADING SCREEN

		var bg = new FlxSprite().makeGraphic(1, 1, 0xFFCAFF4D);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		funkay = new FlxSprite(0, 0).loadGraphic(Paths.image('funkay'));
		funkay.antialiasing = ClientPrefs.data.antialiasing;
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		defaultScale = funkay.scale.x;
		add(funkay);
		#end

		var bg:FlxSprite = new FlxSprite(0, 660).makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width - 300, 25);
		bg.updateHitbox();
		bg.screenCenter(X);
		add(bg);

		bar = new FlxSprite(bg.x + 5, bg.y + 5).makeGraphic(1, 1, FlxColor.WHITE);
		bar.scale.set(0, 15);
		bar.updateHitbox();
		add(bar);
		barWidth = Std.int(bg.width - 10);

		persistentUpdate = true;
		super.create();
	}
	
	var skipUpdate:Bool = false;
	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(skipUpdate) return;

		if(!transitioning)
		{
			if(canChangeState && checkLoaded())
			{
				FlxG.camera.visible = false;
				FlxTransitionableState.skipNextTransIn = true;
				transitioning = true;
				onLoad();
			}
			intendedPercent = loaded / loadMax;
		}

		if(curPercent != intendedPercent)
		{
			if(Math.abs(curPercent - intendedPercent) < 0.001) curPercent = intendedPercent;
			else curPercent = FlxMath.lerp(curPercent, intendedPercent, FlxMath.bound(0, 1, elapsed * 15));

			bar.scale.x = barWidth * curPercent;
			bar.updateHitbox();
		}

		#if PSYCH_WATERMARKS
		// PSYCH LOADING SCREEN
		timePassed += elapsed;
		shakeFl += elapsed * 3000;
		var txt:String = 'Now Loading.';
		switch(Math.floor(timePassed % 1 * 3))
		{
			case 1:
				txt += '.';
			case 2:
				txt += '..';
		}
		loadingText.text = txt;

		if(!spawnedPessy)
		{
			if(!transitioning && controls.ACCEPT)
			{
				shakeMult = 1;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				pressedTimes++;
			}
			shakeMult = Math.max(0, shakeMult - elapsed * 5);
			logo.offset.x = Math.sin(shakeFl * Math.PI / 180) * shakeMult * 100;

			if(pressedTimes >= 5)
			{
				FlxG.camera.fade(0xAAFFFFFF, 0.5, true);
				logo.visible = false;
				spawnedPessy = true;
				canChangeState = false;
				FlxG.sound.play(Paths.sound('secret'));

				pessy = new FlxSprite(700, 140);
				new FlxTimer().start(0.01, function(tmr:FlxTimer) {
					pessy.frames = Paths.getSparrowAtlas('loading_screen/pessy');
					pessy.antialiasing = ClientPrefs.data.antialiasing;
					pessy.flipX = (logo.offset.x > 0);
					pessy.x = FlxG.width + 200;
					pessy.velocity.x = -1100;
					if(pessy.flipX)
					{
						pessy.x = -pessy.width - 200;
						pessy.velocity.x = 1100;
					}
		
					pessy.animation.addByPrefix('run', 'run', 24, true);
					pessy.animation.addByPrefix('spin', 'spin', 24, true);
					pessy.animation.play('run', true);
					
					insert(members.indexOf(loadingText), pessy);
					new FlxTimer().start(5, function(tmr:FlxTimer) canChangeState = true);
				});
			}
		}
		else if(!isSpinning && (pessy.flipX && pessy.x > FlxG.width) || (!pessy.flipX && pessy.x < -pessy.width))
		{
			isSpinning = true;
			pessy.animation.play('spin', true);
			pessy.flipX = false;
			pessy.x = 500;
			pessy.y = FlxG.height + 500;
			pessy.velocity.x = 0;
			FlxTween.tween(pessy, {y: 10}, 0.65, {ease: FlxEase.quadOut});
		}
		#else
		// BASE GAME LOADING SCREEN

		var scale:Float = FlxMath.lerp(funkay.scale.x, defaultScale, FlxMath.bound(0, 1, elapsed * 8));
		if(!transitioning && controls.ACCEPT)
			scale += 0.15;
		
		funkay.scale.set(scale, scale);
		#end
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		MusicBeatState.switchState(target);
		imagesToPrepare = [];
		soundsToPrepare = [];
		musicToPrepare = [];
		songsToPrepare = [];
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		if(ClientPrefs.data.loadingScreen)
		{
			clearInvalids();
			if(imagesToPrepare.length > 0 || soundsToPrepare.length > 0 || musicToPrepare.length > 0 || songsToPrepare.length > 0)
			{
				startThreads();
				return new LoadingState(target, stopMusic, directory);
			}
		}

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}

	function checkLoaded(isOnCreate:Bool = false)
	{
		if(loaded == loadMax)
		{
			if(isOnCreate)
			{
				FlxG.camera.visible = false;
				FlxTransitionableState.skipNextTransIn = true;
			}
			onLoad();
		}
		return (loaded == loadMax);
	}

	static var imagesToPrepare:Array<String> = [];
	static var soundsToPrepare:Array<String> = [];
	static var musicToPrepare:Array<String> = [];
	static var songsToPrepare:Array<String> = [];
	public static function prepare(images:Array<String> = null, sounds:Array<String> = null, music:Array<String> = null)
	{
		if(images != null)
			imagesToPrepare = imagesToPrepare.concat(images);
		if(sounds != null)
			soundsToPrepare = soundsToPrepare.concat(sounds);
		if(music != null)
			musicToPrepare = musicToPrepare.concat(music);
	}

	public static function prepareToSong()
	{
		if(!ClientPrefs.data.loadingScreen) return;

		var folder:String = Paths.formatToSongPath(PlayState.SONG.song);
		try
		{
			var path:String = Paths.json('$folder/preload');
			var json:Dynamic = null;

			#if MODS_ALLOWED
			var moddyFile:String = Paths.modsJson('$folder/preload');
			if(FileSystem.exists(moddyFile)) json = Json.parse(File.getContent(moddyFile));
			else json = Json.parse(File.getContent(path));
			#else
			json = Json.parse(Assets.getText(path));
			#end

			if(json != null)
				prepare((!ClientPrefs.data.lowQuality || json.images_low) ? json.images : json.images_low, json.sounds, json.music);
		}
		catch(e:Dynamic) {}

		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			PlayState.SONG.stage = StageData.vanillaSongStage(folder);
		}

		var stageData:StageFile = StageData.getStageFile(PlayState.SONG.stage);
		if(stageData != null && stageData.preload != null)
			prepare((!ClientPrefs.data.lowQuality || stageData.preload.images_low) ? stageData.preload.images : stageData.preload.images_low, stageData.preload.sounds, stageData.preload.music);

		songsToPrepare.push(folder + '/Inst'); //load Inst
		//if(PlayState.SONG.needsVoices) songsToPrepare.push(Paths.voices(PlayState.SONG.song)); //load Voices

		var player1:String = PlayState.SONG.player1;
		var player2:String = PlayState.SONG.player2;
		var gfVersion:String = PlayState.SONG.gfVersion;
		if(gfVersion == null) gfVersion = 'gf';

		preloadCharacter(player1, PlayState.SONG.needsVoices);
		if(player2 != player1) preloadCharacter(player2, PlayState.SONG.needsVoices);

		if(!stageData.hide_girlfriend && gfVersion != player2 && gfVersion != player1)
			preloadCharacter(gfVersion, false);
	}

	public static function clearInvalids()
	{
		clearInvalidFrom(imagesToPrepare, 'images', '.png', IMAGE);
		clearInvalidFrom(soundsToPrepare, 'sounds', '.${Paths.SOUND_EXT}', SOUND);
		clearInvalidFrom(musicToPrepare, 'music',' .${Paths.SOUND_EXT}', SOUND);
		clearInvalidFrom(songsToPrepare, 'songs', '.${Paths.SOUND_EXT}', SOUND);

		for (arr in [imagesToPrepare, soundsToPrepare, musicToPrepare, songsToPrepare])
			while (arr.contains(null))
				arr.remove(null);
	}

	static function clearInvalidFrom(arr:Array<String>, prefix:String, ext:String, type:AssetType)
	{
		for (i in 0...arr.length)
		{
			var folder:String = arr[i];
			if(folder.trim().endsWith('/'))
			{
				for (subfolder in Mods.directoriesWithFile(Paths.getSharedPath(), '$prefix/$folder'))
					for (file in FileSystem.readDirectory(subfolder))
						if(file.endsWith(ext))
							arr.push(folder + file.substr(0, file.length - ext.length));

				//trace('Folder detected! ' + folder);
			}
		}

		var i:Int = arr.length-1;
		while(i > 0)
		{
			var member:String = arr[i];
			if(member.endsWith('/') || !Paths.fileExists('$prefix/$member$ext', type))
			{
				arr.remove(member);
				trace('Removed invalid $prefix: $member');
			}
			--i;
		}
	}

	public static function startThreads()
	{
		loaded = 0;
		loadMax = imagesToPrepare.length + soundsToPrepare.length + musicToPrepare.length + songsToPrepare.length;

		//then start threads
		for (image in imagesToPrepare)
			initThread(() -> Paths.image(image), 'image $image');
		for (sound in soundsToPrepare)
			initThread(() -> Paths.sound(sound), 'sound $sound');
		for (music in musicToPrepare)
			initThread(() -> Paths.music(music), 'music $music');
		for (song in songsToPrepare)
			initThread(() -> Paths.returnSound(null, song, 'songs'), 'song $song');
	}

	static function initThread(func:Void->Dynamic, traceData:String)
	{
		Thread.create(() -> {
			var ret:Dynamic = func();
			if(ret != null) trace('finished preloading $traceData');
			else trace('ERROR! fail on preloading $traceData');
			loaded++;
		});
	}

	inline private static function preloadCharacter(char:String, loadSong:Bool = true)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT, null, true);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			
			imagesToPrepare.push(character.image);
			//if(loadSong) songsToPrepare.push(character.vocals_file);
		}
		catch(e:Dynamic) {}
	}
}