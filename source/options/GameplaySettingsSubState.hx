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

		var option:Option = new Option('Mobile Middlescroll',
			"If checked, your notes and the opponent's notes get centered.",
			'mobileMidScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'If unchecked, opponent notes get hidden.',
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('HP Gain Type:',
			"Which engine's health gain do you want?",
			'healthGainType',
			'string',
			'VS Impostor',
			['VS Impostor', 'Kade (1.2)', 'Kade (1.4.2 to 1.6)', 'Kade (1.6+)', 'Doki Doki+', 'Psych Engine', 'Leather Engine']);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Auto-Pause if Focus Lost',
			"If unchecked, the game won't pause when your game loses focus.",
			'autoPause',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('CommunityGame Mode',
			"What do you think this does?",
			'communityGameMode',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Remove Marvelous!! Judgement',
			"If unchecked, removes the Marvelous judgement.",
			'noMarvJudge',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Cool Gameplay',
			"Get the COOLEST gameplay ever!!1!111!1!11",
			'coolGameplay',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Disable Chart Editor',
			"If checked, disables the Chart Editor. Try opening it with this option enabled and see what happens!",
			'antiCheatEnable',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Even LESS Botplay Lag',
			"Reduce Botplay lag even further.",
			'lessBotLag',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Instant Respawn',
			"Instantly respawn when you die.",
			'instaRestart',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('More Max Health',
			"If checked, increases your max health to 150% instead of 100%.",
			'moreMaxHP',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Shit Gives Miss',
			"If checked, hitting a Shit rating will count as a miss.",
			'shitGivesMiss',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Enable Taunt Key',
			"If checked, pressing the Taunt key will make BF go HEY!!",
			'spaceVPose',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ghost Tapping Plays Anim',
			"If checked, Ghost Tapping will play BF's animations.",
			'ghostTapAnim',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Enable Miss Sound',
			"If checked, re-enables the miss sound when you miss a note.",
			'missSoundShit',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Hitsound:',
			"What type of hitsound would you like?",
			'hitsoundType',
			'string',
			'osu!mania',
			['osu!mania', 'Dave And Bambi', 'Indie Cross', 'Snap', 'Clap', 'Generic Click', 'Keyboard Click', 'vine boom', 'ADOFAI', 'Randomized']);
		addOption(option);

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

		var option:Option = new Option('Marvelous! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Marvelous!" in milliseconds.',
			'marvWindow',
			'int',
			22);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 1;
		option.maxValue = ClientPrefs.sickWindow - 1;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = ClientPrefs.marvWindow + 1;
		option.maxValue = ClientPrefs.goodWindow - 1;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = ClientPrefs.sickWindow + 1;
		option.maxValue = ClientPrefs.badWindow - 1;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = ClientPrefs.goodWindow + 1;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('More Specific Speed',
			"If checked, Playback Rate's modifier will change in multiples of 0.01 instead of 0.05.",
			'moreSpecificSpeed',
			'bool',
			true);
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}