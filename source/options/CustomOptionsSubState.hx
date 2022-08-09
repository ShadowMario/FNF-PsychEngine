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

class CustomOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Custom Modifiers';
		rpcTitle = 'Psyde Engine Custom Modifiers'; //for Discord Rich Presence

		var option:Option = new Option('Controller Mode',
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Play Hit Sounds', "Go to below option to see information about this.", 'playHitSounds', 'bool', false);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Enabling hitsounds, does sounds when you hit notes."',
			'hitsoundVolume',
			'percent',
			1);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

        // var option:Option = new Option('Shaders', // scrapped (maybe forever)
		// 	'Enabling this will give you a VHS like things.', // scrapped (maybe forever)
		// 	'shaders', // scrapped (maybe forever)
		// 	'bool', // scrapped (maybe forever)
		// 	false); // scrapped (maybe forever)
		// addOption(option); // scrapped (maybe forever)

        var option:Option = new Option('Easy Mode',
			'This Mode Is only for newbies or noobs or bad at the game. Enabling this gives you no mechanics.',
			'easyMode',
			'bool',
			false);
		addOption(option);
        // custom settings by amitabh/cursedUs64.


		

		super();
	}
}