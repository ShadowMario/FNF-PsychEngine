package;

#if sys
import sys.io.FileInput;
#end
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
#if sys
import sys.io.File;
import Sys;
import haxe.io.Bytes;
#end

using StringTools;

class CoolUtil
{
	// [Difficulty name, Chart file suffix]
	public static var difficultyStuff:Array<Dynamic> = [
		['Easy', '-easy'],
		['Normal', ''],
		['Hard', '-hard']
	];

	public static function difficultyString():String
	{
		return difficultyStuff[PlayState.storyDifficulty][0].toUpperCase();
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;
		if(newValue < min) newValue = min;
		else if(newValue > max) newValue = max;
		return newValue;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		#if sys
		var daList:Array<String> = File.getContent(path).trim().split('\n');
		#else
		var daList:Array<String> = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		if(!Assets.cache.hasSound(Paths.sound(sound, library))) {
			FlxG.sound.cache(Paths.sound(sound, library));
		}
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site, "&"]);
		#else
		FlxG.openURL(site);
		#end
	}
	#if sys
	public static function saveFiles(thing:Bytes,dir:String) {

		trace(thing);
		var sussyamogus = sys.io.File.write(/*Sys.getEnv('LOCAlAPPDATA') + "\\psych-engine-online\\" + dir*/'./yes/amongus.png');
		sussyamogus.write(thing);
		sussyamogus.flush();
	}
	#end
}
