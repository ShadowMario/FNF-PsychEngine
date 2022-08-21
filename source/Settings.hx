
import flixel.util.FlxColor;
import openfl.display.StageQuality;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

@:keep class SuperCoolSettings {
	// Left arrow color
	@:keep public static final arrowColor0:Int = 0xFFC24B99;

	// Down arrow color
	@:keep public static final arrowColor1:Int = 0xFF00FFFF;

	// Up arrow color
	@:keep public static final arrowColor2:Int = 0xFF12FA05;

	// Right arrow color
	@:keep public static final arrowColor3:Int = 0xFFF9393F;

	// Whenever the engine will apply your arrow colors to every character, or only you.
	@:keep public static final customArrowColors_allChars:Bool = false;

	// Unused for now
	@:keep public static final smoothHealthbar:Bool = true;

	// If true, will set camHUD's bgColor to #FF00FF00
	@:keep public static final greenScreenMode:Bool = false;

	// If true, will show rating in the bottom score bar.
	@:keep public static final showRating:Bool = true;

	// If true, will show player's press delay above the strums.
	@:keep public static final showPressDelay:Bool = false;

	// If true, will do the little bumping animation on the press delay label above the strums.
	@:keep public static final animateMsLabel:Bool = true;

	// If true, will show player's average delay in the info bar. (Average: 15ms)
	@:keep public static final showAverageDelay:Bool = false;

	// If true, will show player's accuracy in the info bar. (Accuracy: 100%)
	@:keep public static final showAccuracy:Bool = true;

	// If true, will show player's misses in the info bar. (Misses: 2)
	@:keep public static final showMisses:Bool = true;

	// If true, the info bar will do an animation whenever you hit a note.
	@:keep public static final animateInfoBar:Bool = true;
	
	// If true, player's custom scroll speed will be used instead of the chart's scroll speed.
	@:keep public static final customScrollSpeed:Bool = false;
	
	// Self explanatory
	@:keep public static final ghostTapping:Bool = true;
	
	// Player's custom scroll speed
	@:keep public static final scrollSpeed:Float = 2.5;
	
	// If true, will show the timer at the top of the screen.
	@:keep public static final showTimer:Bool = true;
	
	// If true, will show the timer at the top of the screen.
	@:keep public static final watermark:Bool = false;
	
	// Player's custom arrow skin. Set to "default" to disable it.
	@:keep public static final customArrowSkin:String = "default";
	
	// If true, downscroll is enabled.
	// Setting this in the middle of a song wont change the strums position.
	// Use PlayState.setDownscroll(true, true) to enable downscroll and reposition the strums.
	@:keep public static final downscroll:Bool = false;
	
	// If true, middlescroll is enabled. Doesn't have an effect after the song started.
	@:keep public static final middleScroll:Bool = false;
	
	// If true, the classic healthbar colors are used.
	@:keep public static final classicHealthbar:Bool = false;
	
	// If true, outlines will be generated on bold alphabets that are using non bold letters.
	@:keep public static final alphabetOutline:Bool = true;
	
	// Whenever the song name should be shown on the timer. Setting it to false will show "/" instead.
	@:keep public static final timerSongName:Bool = false;
	
	
	// Current accuracy mode.
	// 0 : Complex (C)
	// 1 : Simple (S)
	@:keep public static final accuracyMode:Int = 1;
	
	// Player's custom Boyfriend skin. Set to "default" to disable it.
	@:keep public static final customBFSkin:String = "default";
	
	// Player's custom Girlfriend skin. Set to "default" to disable it.
	@:keep public static final customGFSkin:String = "default";
	
	// If true, botplay is on. Can be enabled mid song without disabling saving score.
	@:keep public static final botplay:Bool = false;
	
	// If true, video will have an antialiasing effect applied.
	@:keep public static final videoAntialiasing:Bool = true;
	
	// If true, player will be able to press R to reset.
	@:keep public static final resetButton:Bool = true;
	
	// Note offset
	@:keep public static final noteOffset:Float = 0;

	// Enable Motion Blur on notes.
	@:keep public static final noteMotionBlurEnabled:Bool = false;

	// Note motion blur multiplier
	@:keep public static final noteMotionBlurMultiplier:Float = 1;

	// Center the strums instead of keeping them like the original game.
	@:keep public static final centerStrums:Bool = true;

	
	// If true, will show the ratings at the bottom left of the screen like this :
	// Sick: 0
	// Good: 0
	// Bad: 0
	// Shit: 0
	@:keep public static final showRatingTotal:Bool = false;

	// Whenever the score text is minimized, check options for more info
	@:keep public static final minimizedMode:Bool = false;


	// If true, will glow CPU strums like the player's strums when they press a note.
	@:keep public static final glowCPUStrums:Bool = true;
	
	// String that separates, for example, Accuracy: 100% from Misses: 0
	@:keep public static final scoreJoinString:String = " • ";

	// Score text size, use scoreTxt.size instead of this, since it only applies at start
	@:keep public static final scoreTextSize:Int = 18; // ayyyy
	
	/**
	 * Sets the GUI scale. Defaults to 1
	 */
	 @:keep public static final noteScale:Float = 1;
	
	/**
	 * Maximum ratings allowed shown on screen. Helps with performance.
	 */
	 @:keep public static final maxRatingsAllowed:Int = 5;
	
	/**
	 * Maximum amount of splashes. 0 disables them.
	 */
	 @:keep public static final maxSplashes:Int = 10;
	
	/**
	 * Maximum amount of splashes. 0 disables them.
	 */
	 @:keep public static final splashesEnabled:Bool = true;
	
	/**
	 * Maximum amount of splashes. 0 disables them.
	 */
	 @:keep public static final splashesAlpha:Float = 0.8;
	
	/**
	 * Whenever splashes should be spawn behind or in front of the strums.
	 */
	 @:keep public static final spawnSplashBehind:Bool = false;

	 
	 /**
	  * Whenever vocals should automatically be resynced.
	  */
	@:keep public static final autoResyncVocals:Bool = true;


	
	// USELESS IN SCRIPTS
	@:keep public static final antialiasing:Bool = true;
	@:keep public static final autopause:Bool = true;
	@:keep public static final autoplayInFreeplay:Bool = false;
	@:keep public static final freeplayCooldown:Float = 2;
	@:keep public static final fpsCap:Int = 120;
	@:keep public static final emptySkinCache:Bool = false;
	@:keep public static final rainbowNotes:Bool = false; //Unused
	@:keep public static final memoryOptimization:Bool = true;
	@:keep public static final blammedEffect:Bool = true;
	@:keep public static final yoshiCrafterEngineCharter:Bool = true;
	@:keep public static final developerMode:Bool = false;
	@:keep public static final showAccuracyMode:Bool = false;
	@:keep public static final lastSelectedSong:String = "Friday Night Funkin':tutorial";
	@:keep public static final lastSelectedSongDifficulty:Int = 1; // Normal
	@:keep public static final charEditor_showDadAndBF:Bool = true;
	@:keep public static final combineNoteTypes:Bool = true;
	@:keep public static final selectedMod:String = "Friday Night Funkin'"; // for ui stuff
	@:keep public static final freeplayShowAll:Bool = false;
	@:keep public static final autoSwitchToLastInstalledMod:Bool = true;
	@:keep public static final stageQuality:StageQuality = HIGH;
	@:keep public static final alwaysCheckForMods:Bool = true;
	@:keep public static final fps_showFPS:Bool = true;
	@:keep public static final fps_showMemory:Bool = true;
	@:keep public static final fps_showMemoryPeak:Bool = true;
	@:keep public static final volume:Float = 1;
	@:keep public static final checkForUpdates:Bool = true;
	@:keep public static final showErrorsInMessageBoxes:Bool = false;
	@:keep public static final useStressMP4:Bool = true;
	@:keep public static final logLimit:Int = 250;
	@:keep public static final lastInstalledMods:Array<String> = ["Friday Night Funkin'", "YoshiCrafterEngine"];
	@:keep public static final logStateChanges:Bool = true;
	@:keep public static final menuMouse:Bool = true;
	@:keep public static final secretWidescreenSweep:Bool = false;
	
	@:keep public static final charter_showStrums:Bool = true;
	@:keep public static final charter_hitsoundsEnabled:Bool = false;
	@:keep public static final charter_topView:Bool = false;
	@:keep public static final charter_showInstWaveform:Bool = false;
	@:keep public static final charter_showVoicesWaveform:Bool = false;
	@:keep public static final charter_instWaveformColor:FlxColor = 0xFF1573FF;
	@:keep public static final charter_voicesWaveformColor:FlxColor = 0xFF93FF4A;
	@:keep public static final charter_instVolume:Float = 0.8;
	@:keep public static final charter_voicesVolume:Float = 1;
	@:keep public static final charter_opponentHitsoundVolume:Float = 1 / 3;
	@:keep public static final charter_playerHitsoundVolume:Float = 1 / 3;
	@:keep public static final charter_separatorColor:FlxColor = 0xFFFFFFFF;

	@:keep public static final flashingLights:Bool = true;
	@:keep public static final approvedFlashingLightsMods:Array<String> = [];
	@:keep public static final flashingLightsDoNotShow:Bool = false;
	
	// ========================================================
	// PER KEY SET CONTROLS
	// SYNTAX = control_(NUMBER OF KEYS)_(NOTE INDEX)
	//
	// CHECK : https://api.haxeflixel.com/flixel/input/keyboard/FlxKey.html
	//
	@:keep public static final control_1_0:FlxKey = FlxKey.UP;

	@:keep public static final control_2_0:FlxKey = FlxKey.LEFT;
	@:keep public static final control_2_1:FlxKey = FlxKey.RIGHT;

	@:keep public static final control_3_0:FlxKey = FlxKey.LEFT;
	@:keep public static final control_3_1:FlxKey = FlxKey.UP;
	@:keep public static final control_3_2:FlxKey = FlxKey.RIGHT;

	@:keep public static final control_4_0:FlxKey = FlxKey.LEFT;
	@:keep public static final control_4_1:FlxKey = FlxKey.DOWN;
	@:keep public static final control_4_2:FlxKey = FlxKey.UP;
	@:keep public static final control_4_3:FlxKey = FlxKey.RIGHT;

	@:keep public static final control_5_0:FlxKey = FlxKey.LEFT;
	@:keep public static final control_5_1:FlxKey = FlxKey.DOWN;
	@:keep public static final control_5_2:FlxKey = FlxKey.SPACE;
	@:keep public static final control_5_3:FlxKey = FlxKey.UP;
	@:keep public static final control_5_4:FlxKey = FlxKey.RIGHT;

	@:keep public static final control_6_0:FlxKey = FlxKey.S;
	@:keep public static final control_6_1:FlxKey = FlxKey.D;
	@:keep public static final control_6_2:FlxKey = FlxKey.F;
	@:keep public static final control_6_3:FlxKey = FlxKey.J;
	@:keep public static final control_6_4:FlxKey = FlxKey.K;
	@:keep public static final control_6_5:FlxKey = FlxKey.L;

	@:keep public static final control_7_0:FlxKey = FlxKey.S;
	@:keep public static final control_7_1:FlxKey = FlxKey.D;
	@:keep public static final control_7_2:FlxKey = FlxKey.F;
	@:keep public static final control_7_3:FlxKey = FlxKey.SPACE;
	@:keep public static final control_7_4:FlxKey = FlxKey.J;
	@:keep public static final control_7_5:FlxKey = FlxKey.K;
	@:keep public static final control_7_6:FlxKey = FlxKey.L;

	@:keep public static final control_8_0:FlxKey = FlxKey.A;
	@:keep public static final control_8_1:FlxKey = FlxKey.S;
	@:keep public static final control_8_2:FlxKey = FlxKey.D;
	@:keep public static final control_8_3:FlxKey = FlxKey.F;
	@:keep public static final control_8_4:FlxKey = FlxKey.H;
	@:keep public static final control_8_5:FlxKey = FlxKey.J;
	@:keep public static final control_8_6:FlxKey = FlxKey.K;
	@:keep public static final control_8_7:FlxKey = FlxKey.L;

	@:keep public static final control_9_0:FlxKey = FlxKey.A;
	@:keep public static final control_9_1:FlxKey = FlxKey.S;
	@:keep public static final control_9_2:FlxKey = FlxKey.D;
	@:keep public static final control_9_3:FlxKey = FlxKey.F;
	@:keep public static final control_9_4:FlxKey = FlxKey.SPACE;
	@:keep public static final control_9_5:FlxKey = FlxKey.H;
	@:keep public static final control_9_6:FlxKey = FlxKey.J;
	@:keep public static final control_9_7:FlxKey = FlxKey.K;
	@:keep public static final control_9_8:FlxKey = FlxKey.L;
	// ========================================================
}

class Settings {
	@:keep public static final save_bind_name:String = "Save";
	@:keep public static final save_bind_path:String = "";




	/**
	 * `FlxSave` that contains all of the engine settings.
	 */
	@:keep public static var engineSettings:FlxSave;

		/**
	 * Load the engine's settings. Use `EngineSettings` in your modcharts to get access to values
	 */
    public static function loadDefault() {
		engineSettings = new FlxSave();

		engineSettings.bind("Settings");
		for(k in Type.getClassFields(SuperCoolSettings)) {
			var ogVal:Dynamic = std.Reflect.field(engineSettings.data, k);
			if (ogVal == null) {
				if (k == "useStressMP4") {
					trace(engineSettings.data.useStressMP4 = Main.getMemoryAmount() > Math.pow(2, 32) * 1.5 /* 6GB */ ? false : true);
				} else {
					std.Reflect.setField(engineSettings.data, k, std.Reflect.field(SuperCoolSettings, k));
				}
				
				
			}
		}
		engineSettings.flush();

		CoolUtil.updateAntialiasing();
    }
}