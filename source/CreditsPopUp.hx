package;

import sys.FileSystem;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxMath;

typedef SongHeading = {
	var path:String;
	var antiAliasing:Bool;
	var iconOffset:Float;
}
class CreditsPopUp extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var bgHeading:FlxSprite;

	public var funnyText:FlxText;
	var curHeading:SongHeading;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
		add(bg);
		var songCreator:String = '';
		var headingPath:SongHeading = null;

		songCreator = PlayState.SONG.songCredit;
				headingPath = {path: 'JSEHeading', antiAliasing: false, iconOffset: 0};

		if (headingPath != null)
		{
				bg.loadGraphic(Paths.image(headingPath.path));
			bg.antialiasing = headingPath.antiAliasing;
			curHeading = headingPath;
		}
		createHeadingText("Song by" + ' ' + songCreator);

		rescaleBG();

		var yValues = CoolUtil.getMinAndMax(bg.height, funnyText.height);
		funnyText.y = funnyText.y + ((yValues[0] - yValues[1]) / 2);
	}
	public function switchHeading(newHeading:SongHeading)
	{
		if (bg != null)
		{
			remove(bg);
		}
		bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
		if (newHeading != null)
		{
				bg.loadGraphic(Paths.image(newHeading.path));
		}
		bg.antialiasing = newHeading.antiAliasing;
		curHeading = newHeading;
		add(bg);
		
		rescaleBG();
	}
	public function changeText(newText:String, rescaleHeading:Bool = true)
	{
		createHeadingText(newText);

		if (rescaleHeading)
		{
			rescaleBG();
		}
	}
	function createHeadingText(text:String)
	{
		if (funnyText != null)
		{
			remove(funnyText);
		}
		funnyText = new FlxText(1, 0, 650, text, 16);
		funnyText.setFormat('vcr.ttf', 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyText.borderSize = 2;
		funnyText.antialiasing = true;
		add(funnyText);
	}
	function rescaleBG()
	{
		bg.setGraphicSize(Std.int((funnyText.textField.textWidth + 0.5)), Std.int(funnyText.height + 0.5));
		bg.updateHitbox();
	}
}