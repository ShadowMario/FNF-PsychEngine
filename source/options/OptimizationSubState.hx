package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
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
import openfl.Lib;

using StringTools;

class OptimizationSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Optimization';
		rpcTitle = 'Optimization Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Chars & BG" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Chars & BG', //Name
			'If unchecked, gameplay will only show the HUD.', //Description
			'charsAndBG', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('Optimize Note Hits',
			'If checked, note hits are optimized further.',
			'evenLessBotLag',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Light Opponent Strums',
			"If this is unchecked, the Opponent strums won't light up when the Opponent hits a note.",
			'opponentLightStrum',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Light Botplay Strums',
			"If this is unchecked, the Player strums won't light when Botplay is active.",
			'botLightStrum',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Light Player Strums',
			"If this is unchecked, then uh.. the player strums won't light up.\nit's as simple as that.",
			'playerLightStrum',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Ratings & Combo',
			"If checked, shows the ratings & combo. Kinda defeats the purpose of this engine though...",
			'ratesAndCombo',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Show Unused Combo Popup',
			"If checked, shows the unused 'Combo' popup, ONLY when Botplay is inactive.",
			'comboPopup',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Load Songs',
			"If unchecked, PlayState songs won't be loaded.\n(Breaks a few of the Visuals & UI things, so be careful!)",
			'songLoading',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Even LESS Botplay Lag',
			"Reduce Botplay lag even further.",
			'lessBotLag',
			'bool',
			true);
		addOption(option);

		/* //ok i was GOING to keep this but note types break if you turn it on
		var option:Option = new Option('Optimized Chart Loading', //Name
			'If checked, hopefully tries to get charts to load faster.', //Description
			'fasterChartLoad', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);
		*/
		
		super();
	}
}