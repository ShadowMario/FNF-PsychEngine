package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Controller Mode',
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'Changes the direction of the notes to fall down.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'Moves your play area to the center of the screen.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hitsounds', // Credits to Sector03
			'Plays a sound whenever a note is hit, like in osu!\nAdd your own .ogg file to the "/mods/sounds" folder and name it "hitsound"\nto change hitsound.',
			'hitSounds',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('No Anti-Mash', // Credits to tposejank
			"If checked, The Anti-Mash protection will be disabled.\nDon't brag about completing a song when this is checked.",
			'noAntimash',
			false);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool',
			false);
		addOption(option);

		/*var option:Option = new Option('Note Delay',
			'Changes how late a note is spawned.\nUseful for preventing audio lag from wireless earphones.',
			'noteOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 100;
		option.minValue = 0;
		option.maxValue = 500;
		addOption(option);*/

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Perfect Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Perfect Sick!" in milliseconds.\nDefault is 22, the same value as Judge 4 in StepMania/Etterna.\nSetting this to lowest value = Judge 7.',
			'sickWindow',
			'int',
			22);
		option.displayFormat = '%vms';
		option.scrollSpeed = 5;
		option.minValue = 11;
		option.maxValue = 22;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.\nDefault is 45, the same value as Judge 4 in StepMania/Etterna.\nSetting this to lowest value = Judge 7.',
			'greatWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 23;
		option.maxValue = 45;
		addOption(option);
		

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds. Default is 90, the same value as Judge 4 in StepMania/Etterna.\nSetting this to lowest value = Judge 7.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 45;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds. Default is 135, the same value as Judge 4 in StepMania/Etterna.\nSetting this to lowest value = Judge 7.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 68;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.\nIf you want to get better, then 5 frames are great to improve your accuracy.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 0;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}
}