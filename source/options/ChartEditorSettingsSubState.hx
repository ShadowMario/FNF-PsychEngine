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

class ChartEditorSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Chart Editor Settings';
		rpcTitle = 'Chart Editor Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Autosave',
			'If checked, the Chart Editor will autosave.',
			'autosaveCharts',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('AutoSave Interval',
			'Interval for chart editor autosaves (in minutes).',
			'autosaveInterval',
			'float',
			5.0);
		option.scrollSpeed = 5;
		option.minValue = 1;
		option.maxValue = 30;
		option.changeValue = 1;
		option.displayFormat = '%v Minutes';
		addOption(option);

		super();
	}
}