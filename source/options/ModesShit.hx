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

class ModesShit extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Modes';
		rpcTitle = 'Modes'; //for Discord Rich Presence


		var option:Option = new Option('Neutral',
			'If checked, This will enable modes: Easy,Normal,Hard',
			'normalYes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Erect',
			'If checked, This will only enable [ erect ] as a mode', // you should've read the goddamn option title >:(
		        'erectYes',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('D-Sides + Remixed', // d-sides mods these days Xdddd
			'If checked, This will add 2 modes, remixed and d-sides.',
			'sideYes', 
			'bool',
			false);
		addOption(option);

		//stop committing and telling me that Vs Stupid should have encore remixes, I'm gonna add them in v2.
		var option:Option = new Option('< Encore >',
			"If checked, This will enable encore mode",
			'encoreYes',
			'bool',
			false);
		addOption(option);

		super();
	}
	/*there is no FUCKING GODDAMN WAY 
	 im gonna be able to make encore, d-sides, remixed, and erect songs 
	 with my LAZY team ( half of the team is offline and they do nothing )*/
	 //statement = true;
}
