import flixel.system.macros.FlxMacroUtil;
import flixel.math.FlxAngle;
import Achievements.AchievementObject;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxDestroyUtil;
import openfl.Lib;
import openfl.text.TextFormat;
import flixel.FlxBasic;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import flixel.system.FlxAssets.FlxShader;
import flixel.addons.text.FlxTypeText;
import openfl.media.Sound;
import options.BaseOptionsMenu;
import openfl.text.TextField;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import flixel.addons.display.FlxGridOverlay;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import lime.system.Clipboard;
import haxe.io.Path;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUI;
import openfl.display.BitmapData;
import haxe.Json;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.FlxGraphic;
import lime.media.openal.AL;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets as LimeAssets;
import openfl.Assets as OpenFlAssets;
import lime.app.Application;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSort;
import flixel.util.FlxSave;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.math.FlxRect;
#if HSCRIPT_ALLOWED
#if DISCORD_ALLOWED
import Discord.DiscordClient;
#end
import options.OptionsState;
import editors.MasterEditorMenu;
import editors.CharacterEditorState;
import editors.ChartingState;
import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.effects.FlxTrail;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import hscript.InterpEx;

using StringTools;

class FunkinHscript extends InterpEx {
    public function new() {
        super();
        //CLASSES
        //THIS IS PROBABLY MORE THAN ANYONE EVER NEEDS AND YOU CAN IMPORT CLASSES MANUALLY ANYWAYS BUT WHATEVER
        variables.set('AL', AL);
        variables.set('Application', Application);
        variables.set('AudioBuffer', AudioBuffer);
        variables.set('BitmapData', BitmapData);
        variables.set('Bytes', Bytes);
        variables.set('Clipboard', Clipboard);
        variables.set('Event', Event);
        variables.set('FlxAngle', FlxAngle);
        variables.set('FlxAtlasFrames', FlxAtlasFrames);
        variables.set('FlxBackdrop', FlxBackdrop);
        variables.set('FlxBar', FlxBar);
        variables.set('FlxBasic', FlxBasic);
        variables.set('FlxButton', FlxButton);
        variables.set('FlxCamera', FlxCamera);
        variables.set('FlxColor', FlxColorCustom);
        variables.set('FlxDestroyUtil', FlxDestroyUtil);
        variables.set('FlxEase', FlxEase);
        variables.set('FlxFlicker', FlxFlicker);
        variables.set('FlxFrame', FlxFrame);
        variables.set('FlxG', FlxG);
        variables.set('FlxGradient', FlxGradient);
        variables.set('FlxGraphic', FlxGraphic);
        variables.set('FlxGridOverlay', FlxGridOverlay);
        variables.set('FlxGroup', FlxGroup);
        variables.set('FlxKey', FlxKeyCustom);
        variables.set('FlxMath', FlxMath);
        variables.set('FlxObject', FlxObject);
        variables.set('FlxPoint', FlxPoint);
        variables.set('FlxRect', FlxRect);
        variables.set('FlxSave', FlxSave);
        variables.set('FlxShader', FlxShader);
        variables.set('FlxSort', FlxSort);
        variables.set('FlxSound', FlxSound);
        variables.set('FlxSprite', FlxSprite);
        variables.set('FlxSpriteGroup', FlxSpriteGroup);
        variables.set('FlxState', FlxState);
        variables.set('FlxStringUtil', FlxStringUtil);
        variables.set('FlxSubState', FlxSubState);
        variables.set('FlxText', FlxText);
        variables.set('FlxTimer', FlxTimer);
        variables.set('FlxTrail', FlxTrail);
        variables.set('FlxTransitionableState', FlxTransitionableState);
        variables.set('FlxTween', FlxTween);
        variables.set('FlxTypedGroup', FlxTypedGroup);
        variables.set('FlxTypedSpriteGroup', FlxTypedSpriteGroup);
        variables.set('FlxUI', FlxUI);
        variables.set('FlxUICheckBox', FlxUICheckBox);
        variables.set('FlxUIDropDownMenu', FlxUIDropDownMenu);
        variables.set('FlxUIInputText', FlxUIInputText);
        variables.set('FlxUINumericStepper', FlxUINumericStepper);
        variables.set('FlxUITabMenu', FlxUITabMenu);
        variables.set('FlxTypeText', FlxTypeText);
        variables.set('IOErrorEvent', IOErrorEvent);
        variables.set('Json', Json);
        variables.set('Lib', Lib);
        variables.set('LimeAssets', LimeAssets);
        variables.set('OpenFlAssets', OpenFlAssets);
        variables.set('Path', Path);
        variables.set('Reflect', Reflect);
        variables.set('Sound', Sound);
        variables.set('StringTools', StringTools);
        variables.set('TextField', TextField);
        variables.set('TextFormat', TextFormat);
        #if sys
        variables.set('File', File);
        variables.set('FileSystem', FileSystem);
        #end

        variables.set('AchievementObject', AchievementObject);
        variables.set('Achievements', Achievements);
        variables.set('AchievementsMenuState', AchievementsMenuState);
        variables.set('Alphabet', Alphabet);
        variables.set('AtlasFrameMaker', AtlasFrameMaker);
        variables.set('AttachedFlxText', AttachedFlxText);
        variables.set('AttachedSprite', AttachedSprite);
        variables.set('AttachedText', AttachedText);
        variables.set('BaseOptionsMenu', BaseOptionsMenu);
        variables.set('BGSprite', BGSprite);
        variables.set('Boyfriend', Boyfriend);
        variables.set('Character', Character);
        variables.set('CharacterEditorState', CharacterEditorState);
        variables.set('ChartingState', ChartingState);
        variables.set('CheckboxThingie', CheckboxThingie);
        variables.set('ClientPrefs', ClientPrefs);
        variables.set('ColorSwap', ColorSwap);
        variables.set('Conductor', Conductor);
        variables.set('CoolUtil', CoolUtil);
        variables.set('CreditsState', CreditsState);
        variables.set('CustomFadeTransition', CustomFadeTransition);
        variables.set('DialogueBox', DialogueBox);
        variables.set('DialogueBoxPsych', DialogueBoxPsych);
        #if DISCORD_ALLOWED
        variables.set('DiscordClient', DiscordClient);
        #end
        #if VIDEOS_ALLOWED
        variables.set('FlxVideo', FlxVideo);
        #end
        variables.set('FreeplayState', FreeplayState);
        variables.set('FunkinHscript', FunkinHscript);
        variables.set('FunkinLua', FunkinLua);
        variables.set('GameOverSubState', GameOverSubState);
        variables.set('HealthIcon', HealthIcon);
        variables.set('Highscore', Highscore);
        variables.set('InputFormatter', InputFormatter);
        variables.set('MainMenuState', MainMenuState);
        variables.set('MasterEditorMenu', MasterEditorMenu);
        variables.set('MusicBeatState', MusicBeatState);
        variables.set('MusicBeatSubState', MusicBeatSubState);
        variables.set('Note', Note);
        variables.set('NoteSplash', NoteSplash);
        variables.set('OptionsState', OptionsState);
        variables.set('Paths', Paths);
        variables.set('PauseSubState', PauseSubState);
        variables.set('PlayState', PlayState);
        variables.set('Prompt', Prompt);
        variables.set('Song', Song);
        variables.set('StageData', StageData);
        variables.set('StoryMenuState', StoryMenuState);
        variables.set('StrumNote', StrumNote);
        variables.set('TitleState', TitleState);
        variables.set('WeekData', WeekData);
        variables.set('WiggleEffect', WiggleEffect);

        //VARIABLES
        variables.set('Function_Stop', FunkinLua.Function_Stop);
		variables.set('Function_Continue', FunkinLua.Function_Continue);
		variables.set('inChartEditor', PlayState.instance.inEditor);
		variables.set('curBpm', Conductor.bpm);
		variables.set('bpm', Conductor.bpm);
		variables.set('signatureNumerator', Conductor.timeSignature[0]);
		variables.set('signatureDenominator', Conductor.timeSignature[1]);
		variables.set('crochet', Conductor.crochet);
		variables.set('stepCrochet', Conductor.stepCrochet);
		variables.set('scrollSpeed', PlayState.SONG.speed);
		variables.set('playerKeyAmount', PlayState.SONG.playerKeyAmount);
		variables.set('opponentKeyAmount', PlayState.SONG.opponentKeyAmount);
		variables.set('playerSkin', PlayState.instance.uiSkinMap.get('player').name);
		variables.set('opponentSkin', PlayState.instance.uiSkinMap.get('opponent').name);
		variables.set('songLength', 0);
		variables.set('songName', PlayState.SONG.song);
		variables.set('startedCountdown', false);
		variables.set('isStoryMode', PlayState.isStoryMode);
		variables.set('difficulty', PlayState.storyDifficulty);
		variables.set('difficultyName', CoolUtil.difficulties[PlayState.storyDifficulty]);
		variables.set('weekRaw', PlayState.storyWeek);
		variables.set('week', WeekData.weeksLoaded.get(WeekData.weeksList[PlayState.storyWeek]).fileName);
		variables.set('seenCutscene', PlayState.seenCutscene);

		// Camera poo
		variables.set('cameraX', 0);
		variables.set('cameraY', 0);
		
		// Screen stuff
		variables.set('screenWidth', FlxG.width);
		variables.set('screenHeight', FlxG.height);

		// PlayState cringe ass nae nae bullcrap
		variables.set('curBeat', 0);
		variables.set('curNumeratorBeat', 0);
		variables.set('curStep', 0);

		variables.set('score', 0);
		variables.set('misses', 0);
		variables.set('hits', 0);

		variables.set('rating', 0);
		variables.set('ratingName', '');
		variables.set('ratingFC', '');
		variables.set('version', MainMenuState.psychEngineVersion.trim());
		variables.set('versionExtra', MainMenuState.psychEngineExtraVersion.trim());
		
		variables.set('inGameOver', false);
		variables.set('curSection', 0);
		variables.set('mustHitSection', false);
		variables.set('altAnim', false);
		variables.set('gfSection', false);
		variables.set('lengthInSteps', 16);
		variables.set('changeBPM', false);
		variables.set('changeSignature', false);

		// Gameplay settings
		variables.set('healthGainMult', PlayState.instance.healthGain);
		variables.set('healthLossMult', PlayState.instance.healthLoss);
		variables.set('instakillOnMiss', PlayState.instance.instakillOnMiss);
		variables.set('botPlay', PlayState.instance.cpuControlled);
		variables.set('practice', PlayState.instance.practiceMode);
		variables.set('opponentPlay', PlayState.instance.opponentChart);
		variables.set('playbackRate', PlayState.instance.playbackRate);

		for (i in 0...Note.MAX_KEYS) {
			variables.set('defaultPlayerStrumX$i', 0);
			variables.set('defaultPlayerStrumY$i', 0);
			variables.set('defaultOpponentStrumX$i', 0);
			variables.set('defaultOpponentStrumY$i', 0);
		}

		// Default character positions woooo
		variables.set('defaultBoyfriendX', PlayState.instance.BF_X);
		variables.set('defaultBoyfriendY', PlayState.instance.BF_Y);
		variables.set('defaultOpponentX', PlayState.instance.DAD_X);
		variables.set('defaultOpponentY', PlayState.instance.DAD_Y);
		variables.set('defaultGirlfriendX', PlayState.instance.GF_X);
		variables.set('defaultGirlfriendY', PlayState.instance.GF_Y);

		// Character shit
		variables.set('boyfriendName', PlayState.SONG.player1);
		variables.set('dadName', PlayState.SONG.player2);
		variables.set('gfName', PlayState.SONG.gfVersion);

		// Some settings, no jokes
		variables.set('downscroll', ClientPrefs.downScroll);
		variables.set('middlescroll', ClientPrefs.middleScroll);
		variables.set('framerate', ClientPrefs.framerate);
		variables.set('ghostTapping', ClientPrefs.ghostTapping);
		variables.set('hideHud', ClientPrefs.hideHud);
		variables.set('timeBarType', ClientPrefs.timeBarType);
		variables.set('scoreZoom', ClientPrefs.scoreZoom);
		variables.set('cameraZoomOnBeat', ClientPrefs.camZooms);
		variables.set('flashingLights', ClientPrefs.flashing);
		variables.set('noteOffset', ClientPrefs.noteOffset);
		variables.set('healthBarAlpha', ClientPrefs.healthBarAlpha);
		variables.set('noResetButton', ClientPrefs.noReset);
		variables.set('gameQuality', ClientPrefs.gameQuality);
		variables.set('instantRestart', ClientPrefs.instantRestart);
		variables.set('lowQuality', ClientPrefs.gameQuality != 'Normal');

		#if windows
		variables.set('buildTarget', 'windows');
		#elseif linux
		variables.set('buildTarget', 'linux');
		#elseif mac
		variables.set('buildTarget', 'mac');
		#elseif html5
		variables.set('buildTarget', 'browser');
		#elseif android
		variables.set('buildTarget', 'android');
		#else
		variables.set('buildTarget', 'unknown');
		#end

        variables.set('controls', PlayerSettings.player1.controls);
        variables.set('instance', PlayState.instance);
        variables.set('window', Application.current.window);

        //EVENTS
		var funcs = [
			'onCreate',
			'onCreatePost',
			'onDestroy'
		];
		for (i in funcs)
			variables.set(i, function() {});
		variables.set('onUpdate', function(elapsed) {});
		variables.set('onUpdatePost', function(elapsed) {});
    }

    inline function getInstance()
	{
		return PlayState.instance.isDead ? GameOverSubState.instance : PlayState.instance;
	}
}

//cant use an abstract as a value so made one with just the static functions
class FlxColorCustom
{
	public static inline var TRANSPARENT:FlxColor = 0x00000000;
	public static inline var WHITE:FlxColor = 0xFFFFFFFF;
	public static inline var GRAY:FlxColor = 0xFF808080;
	public static inline var BLACK:FlxColor = 0xFF000000;

	public static inline var GREEN:FlxColor = 0xFF008000;
	public static inline var LIME:FlxColor = 0xFF00FF00;
	public static inline var YELLOW:FlxColor = 0xFFFFFF00;
	public static inline var ORANGE:FlxColor = 0xFFFFA500;
	public static inline var RED:FlxColor = 0xFFFF0000;
	public static inline var PURPLE:FlxColor = 0xFF800080;
	public static inline var BLUE:FlxColor = 0xFF0000FF;
	public static inline var BROWN:FlxColor = 0xFF8B4513;
	public static inline var PINK:FlxColor = 0xFFFFC0CB;
	public static inline var MAGENTA:FlxColor = 0xFFFF00FF;
	public static inline var CYAN:FlxColor = 0xFF00FFFF;

	/**
	 * A `Map<String, Int>` whose values are the static colors of `FlxColor`.
	 * You can add more colors for `FlxColor.fromString(String)` if you need.
	 */
	public static var colorLookup(default, null):Map<String, Int> = FlxMacroUtil.buildMap("flixel.util.FlxColor");

	static var COLOR_REGEX = ~/^(0x|#)(([A-F0-9]{2}){3,4})$/i;

	/**
	 * Create a color from the least significant four bytes of an Int
	 *
	 * @param	Value And Int with bytes in the format 0xAARRGGBB
	 * @return	The color as a FlxColor
	 */
	public static inline function fromInt(Value:Int):FlxColor
	{
		return new FlxColor(Value);
	}

	/**
	 * Generate a color from integer RGB values (0 to 255)
	 *
	 * @param Red	The red value of the color from 0 to 255
	 * @param Green	The green value of the color from 0 to 255
	 * @param Blue	The green value of the color from 0 to 255
	 * @param Alpha	How opaque the color should be, from 0 to 255
	 * @return The color as a FlxColor
	 */
	public static inline function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
	{
		var color = new FlxColor();
		return color.setRGB(Red, Green, Blue, Alpha);
	}

	/**
	 * Generate a color from float RGB values (0 to 1)
	 *
	 * @param Red	The red value of the color from 0 to 1
	 * @param Green	The green value of the color from 0 to 1
	 * @param Blue	The green value of the color from 0 to 1
	 * @param Alpha	How opaque the color should be, from 0 to 1
	 * @return The color as a FlxColor
	 */
	public static inline function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setRGBFloat(Red, Green, Blue, Alpha);
	}

	/**
	 * Generate a color from CMYK values (0 to 1)
	 *
	 * @param Cyan		The cyan value of the color from 0 to 1
	 * @param Magenta	The magenta value of the color from 0 to 1
	 * @param Yellow	The yellow value of the color from 0 to 1
	 * @param Black		The black value of the color from 0 to 1
	 * @param Alpha		How opaque the color should be, from 0 to 1
	 * @return The color as a FlxColor
	 */
	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}

	/**
	 * Generate a color from HSB (aka HSV) components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	(aka Value) A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a FlxColor
	 */
	public static function fromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setHSB(Hue, Saturation, Brightness, Alpha);
	}

	/**
	 * Generate a color from HSL components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Lightness	A number between 0 and 1, indicating the lightness of the color
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a FlxColor
	 */
	public static inline function fromHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setHSL(Hue, Saturation, Lightness, Alpha);
	}

	/**
	 * Parses a `String` and returns a `FlxColor` or `null` if the `String` couldn't be parsed.
	 *
	 * Examples (input -> output in hex):
	 *
	 * - `0x00FF00`    -> `0xFF00FF00`
	 * - `0xAA4578C2`  -> `0xAA4578C2`
	 * - `#0000FF`     -> `0xFF0000FF`
	 * - `#3F000011`   -> `0x3F000011`
	 * - `GRAY`        -> `0xFF808080`
	 * - `blue`        -> `0xFF0000FF`
	 *
	 * @param	str 	The string to be parsed
	 * @return	A `FlxColor` or `null` if the `String` couldn't be parsed
	 */
	public static function fromString(str:String):Null<FlxColor>
	{
		var result:Null<FlxColor> = null;
		str = StringTools.trim(str);

		if (COLOR_REGEX.match(str))
		{
			var hexColor:String = "0x" + COLOR_REGEX.matched(2);
			result = new FlxColor(Std.parseInt(hexColor));
			if (hexColor.length == 8)
			{
				result.alphaFloat = 1;
			}
		}
		else
		{
			str = str.toUpperCase();
			for (key in colorLookup.keys())
			{
				if (key.toUpperCase() == str)
				{
					result = new FlxColor(colorLookup.get(key));
					break;
				}
			}
		}

		return result;
	}

	/**
	 * Get HSB color wheel values in an array which will be 360 elements in size
	 *
	 * @param	Alpha Alpha value for each color of the color wheel, between 0 (transparent) and 255 (opaque)
	 * @return	HSB color wheel as Array of FlxColors
	 */
	public static function getHSBColorWheel(Alpha:Int = 255):Array<FlxColor>
	{
		return [for (c in 0...360) fromHSB(c, 1.0, 1.0, Alpha)];
	}

	/**
	 * Get an interpolated color based on two different colors.
	 *
	 * @param 	Color1 The first color
	 * @param 	Color2 The second color
	 * @param 	Factor Value from 0 to 1 representing how much to shift Color1 toward Color2
	 * @return	The interpolated color
	 */
	public static inline function interpolate(Color1:FlxColor, Color2:FlxColor, Factor:Float = 0.5):FlxColor
	{
		var r:Int = Std.int((Color2.red - Color1.red) * Factor + Color1.red);
		var g:Int = Std.int((Color2.green - Color1.green) * Factor + Color1.green);
		var b:Int = Std.int((Color2.blue - Color1.blue) * Factor + Color1.blue);
		var a:Int = Std.int((Color2.alpha - Color1.alpha) * Factor + Color1.alpha);

		return fromRGB(r, g, b, a);
	}

	/**
	 * Create a gradient from one color to another
	 *
	 * @param Color1 The color to shift from
	 * @param Color2 The color to shift to
	 * @param Steps How many colors the gradient should have
	 * @param Ease An optional easing function, such as those provided in FlxEase
	 * @return An array of colors of length Steps, shifting from Color1 to Color2
	 */
	public static function gradient(Color1:FlxColor, Color2:FlxColor, Steps:Int, ?Ease:Float->Float):Array<FlxColor>
	{
		var output = new Array<FlxColor>();

		if (Ease == null)
		{
			Ease = function(t:Float):Float
			{
				return t;
			}
		}

		for (step in 0...Steps)
		{
			output[step] = interpolate(Color1, Color2, Ease(step / (Steps - 1)));
		}

		return output;
	}

	/**
	 * Multiply the RGB channels of two FlxColors
	 */
	@:op(A * B)
	public static inline function multiply(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGBFloat(lhs.redFloat * rhs.redFloat, lhs.greenFloat * rhs.greenFloat, lhs.blueFloat * rhs.blueFloat);
	}

	/**
	 * Add the RGB channels of two FlxColors
	 */
	@:op(A + B)
	public static inline function add(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGB(lhs.red + rhs.red, lhs.green + rhs.green, lhs.blue + rhs.blue);
	}

	/**
	 * Subtract the RGB channels of one FlxColor from another
	 */
	@:op(A - B)
	public static inline function subtract(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGB(lhs.red - rhs.red, lhs.green - rhs.green, lhs.blue - rhs.blue);
	}
}

class FlxKeyCustom
{
	public static var fromStringMap(default, null):Map<String, FlxKey> = FlxMacroUtil.buildMap("flixel.input.keyboard.FlxKey");
	public static var toStringMap(default, null):Map<FlxKey, String> = FlxMacroUtil.buildMap("flixel.input.keyboard.FlxKey", true);
	// Key Indicies
	static var NONE = -1;

	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}
}
#end