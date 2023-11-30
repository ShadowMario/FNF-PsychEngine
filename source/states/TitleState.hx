package states;

import tjson.TJSON as Json;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import shaders.ColorSwap;

@:structInit
class TitleData {
	public var titlex:Float = -150;
	public var titley:Float = -100;
	public var startx:Float = 100;
	public var starty:Float = 576;
	public var gfx:Float = 512;
	public var gfy:Float = 40;
	public var backgroundSprite:String = '';
	public var bpm:Float = 102;
}

class TitleState extends MusicBeatState {
	public static var skippedIntro:Bool = false;

	var pressedEnter:Bool = false;

	var gf:FlxSprite;
	var logo:FlxSprite;
	var titleText:FlxSprite;

	var ngSpr:FlxSprite;

	var titleJson:TitleData;

	// whether the "press enter to begin" sprite is the old atlas or the new atlas
	var newTitle:Bool;

	final titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	final titleTextAlphas:Array<Float> = [1, .64];

	var titleTextTimer:Float;

	var randomPhrase:Array<String> = [];

	var textGroup:FlxSpriteGroup;

	var psychSecrets:Array<String> = ['SHADOW', 'BBPANZU', 'RIVER'];
	var easterEggName:String;
	var easterEggNameBuffer:String = '';

	var colourSwap:ColorSwap = null;

	public static var updateVersion:String;
	var mustUpdate:Bool = false;

	override function create():Void {
		Paths.clearStoredMemory();
		FlxTransitionableState.skipNextTransOut = false;
		persistentUpdate = true;

		super.create();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.data.checkForUpdates && !skippedIntro) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String) {
				updateVersion = data.split('\n')[0].trim();
				final curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function(error) {
				trace('error: $error');
			}

			http.request();
		}
		#end
		
		final balls = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		titleJson = {
			titlex: balls.titlex,
			titley: balls.titley,
			startx: balls.startx,
			starty: balls.starty,
			gfx: balls.gfx,
			gfy: balls.gfy,
			backgroundSprite: balls.backgroundSprite,
			bpm: balls.bpm,
		}

		Conductor.bpm = titleJson.bpm;

		if (titleJson.backgroundSprite != null && titleJson.backgroundSprite.length > 0 && titleJson.backgroundSprite != "none") {
			final bg:FlxSprite = new FlxSprite(0, 0, Paths.image(titleJson.backgroundSprite));
			bg.antialiasing = ClientPrefs.data.antialiasing;
			bg.active = false;
			add(bg);
		}

		if (ClientPrefs.data.shaders) colourSwap = new ColorSwap();

		gf = new FlxSprite(titleJson.gfx, titleJson.gfy);
		gf.antialiasing = ClientPrefs.data.antialiasing;

		easterEggName = FlxG.save.data.psychDevsEasterEgg;

		switch(easterEggName) {
			//case 'SHADOW':
			//	gf.frames = Paths.getSparrowAtlas('ShadowBump');
			//	gf.animation.addByPrefix('left', 'Shadow Title Bump', 24);
			//	gf.animation.addByPrefix('danceRight', 'Shadow Title Bump', 24);
			//case 'RIVER':
			//	gf.frames = Paths.getSparrowAtlas('RiverBump');
			//	gf.animation.addByIndices('left', 'River Title Bump', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			//	gf.animation.addByIndices('right', 'River Title Bump', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			//case 'BBPANZU':
			//	gf.frames = Paths.getSparrowAtlas('BBBump');
			//	gf.animation.addByIndices('left', 'BB Title Bump', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
			//	gf.animation.addByIndices('right', 'BB Title Bump', [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);

			default:
				gf.frames = Paths.getSparrowAtlas('gfDanceTitle');
				gf.animation.addByIndices('left', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gf.animation.addByIndices('right', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}

		gf.animation.play('right');
		gf.alpha = 0.0001;
		add(gf);

		logo = new FlxSprite(titleJson.titlex, titleJson.titley);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.animation.play('bump');
		logo.alpha = 0.0001;
		add(logo);

		if(colourSwap != null) {
			gf.shader = colourSwap.shader;
			logo.shader = colourSwap.shader;
		}

		titleText = new FlxSprite(titleJson.startx, titleJson.starty);
		titleText.visible = false;
		titleText.frames = Paths.getSparrowAtlas('titleEnter');

		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		} else {
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.active = false;
		titleText.animation.play('idle');
		add(titleText);

		textGroup = new FlxSpriteGroup();
		add(textGroup);

		randomPhrase = FlxG.random.getObject(getIntroTextShit());

		if (!skippedIntro) {
			add(ngSpr = new FlxSprite(0, FlxG.height * 0.52, Paths.image('newgrounds_logo')));
			ngSpr.visible = false;
			ngSpr.active = false;
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
			ngSpr.updateHitbox();
			ngSpr.screenCenter(X);
			ngSpr.antialiasing = ClientPrefs.data.antialiasing;
			
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		} else skipIntro();

		Paths.clearUnusedMemory();
	}

	function getIntroTextShit():Array<Array<String>> {
		#if MODS_ALLOWED
		final firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getSharedPath());
		#else
		final fullText:String = Assets.getText(Paths.txt('introText'));
		final firstArray:Array<String> = fullText.split('\n');
		#end
		final swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray) swagGoodArray.push(i.split('--'));
		return swagGoodArray;
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		if (controls.ACCEPT) {
			if (skippedIntro) {
				if (!pressedEnter) {
					pressedEnter = true;

					if (ClientPrefs.data.flashing) titleText.active = true;
					titleText.animation.play('press');
					titleText.color = FlxColor.WHITE;
					titleText.alpha = 1;

					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

					new FlxTimer().start(1.5, function(okFlixel:FlxTimer) {
						FlxTransitionableState.skipNextTransIn = false;

						if (mustUpdate) MusicBeatState.switchState(new OutdatedState());
						else MusicBeatState.switchState(new MainMenuState());
					});
				}
			} else skipIntro();
		}

		if (newTitle && !pressedEnter) {
			titleTextTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTextTimer > 2) titleTextTimer -= 2;

			var timer:Float = titleTextTimer;
			if (timer >= 1) timer = (-timer) + 2;
				
			timer = FlxEase.quadInOut(timer);
				
			titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
			titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
		}

		if(colourSwap != null) {
			if(controls.UI_LEFT) colourSwap.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) colourSwap.hue += elapsed * 0.1;
		}

		//if (FlxG.keys.firstJustPressed() != FlxKey.NONE) {
		//	final keyPressed:FlxKey = FlxG.keys.firstJustPressed();
		//	final keyName:String = Std.string(keyPressed);

		//	easterEggNameBuffer += keyName;

		//	if (easterEggNameBuffer.contains(easterEggName) && easterEggName != null) {
		//		FlxG.save.data.psychDevsEasterEgg = null;
		//		easterEggName = null;

		//		MusicBeatState.switchState(new TitleState());
		//	} else {
		//		for (i in psychSecrets) {
		//			if (easterEggNameBuffer.contains(i)) {
		//				FlxG.save.data.psychDevsEasterEgg = i;
		//				FlxG.save.flush();
		//				MusicBeatState.switchState(new TitleState());
		//				break;
		//			}
		//		}
		//	}
		//}
	}

	override function beatHit():Void {
		gf.animation.play(curBeat % 2 == 0 ? 'left' : 'right', true);
		logo.animation.play('bump', true);

		if (!skippedIntro) {
			switch (curBeat) {
				case 2:
					#if PSYCH_WATERMARKS
					createText(['Psych Engine by'], 40);
					#else
					createText(['ninjamuffin99', 'PhantomArcade', 'Kawai Sprite', 'evilsk8er']);
					#end
				// credTextShit.visible = true;
				case 4:
					#if PSYCH_WATERMARKS
					addMoreText('Shadow Mario', 40);
					addMoreText('Riveren', 40);
					#else
					addMoreText('present');
					#end
				case 5:
					deleteText();
				case 6:
					#if PSYCH_WATERMARKS
					createText(['Not associated', 'with'], -40);
					#else
					createText(['In association', 'with'], -40);
					#end
				case 8:
					addMoreText('Newgrounds', -40);
					ngSpr.visible = true;
				case 9:
					deleteText();
					ngSpr.visible = false;
				case 10:
					createText([randomPhrase[0]]);
				case 12:
					addMoreText(randomPhrase[1]);
				case 13:
					deleteText();
				case 14:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 15:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 16:
					addMoreText('Funkin');
				case 17:
					skipIntro();
			}
	}
	}

	function skipIntro() {
		FlxG.camera.flash(FlxColor.WHITE, 2);
		skippedIntro = true;

		gf.alpha = 1;
		logo.alpha = 1;
		titleText.visible = true;

		deleteText();
	}

	function createText(textArray:Array<String>, ?offset:Float = 0) {
		if (textGroup != null) {
			for (i in 0...textArray.length) {
				final txt:Alphabet = new Alphabet(0, 0, textArray[i], true);
				txt.screenCenter(X);
				txt.y += (i * 60) + 200 + offset;
				textGroup.add(txt);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0) {
		if(textGroup != null) {
			final txt:Alphabet = new Alphabet(0, 0, text, true);
			txt.screenCenter(X);
			txt.y += (textGroup.length * 60) + 200 + offset;
			textGroup.add(txt);
		}
	}

	inline function deleteText() while (textGroup.members.length > 0) textGroup.remove(textGroup.members[0], true);
}