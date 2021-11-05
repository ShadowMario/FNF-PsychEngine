package;

import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
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
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
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
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function bindCheck(mania:Int)
	{
		var keysMap = ClientPrefs.keyBinds;

		var binds:Array<Int> = [keysMap.get('note_left')[0],keysMap.get('note_down')[0], keysMap.get('note_up')[0], keysMap.get('note_right')[0]];
		switch(mania)
		{
			case 0: 
				binds = [keysMap.get('note_left')[0],keysMap.get('note_down')[0], keysMap.get('note_up')[0], keysMap.get('note_right')[0]];
			case 1: 
				binds = [keysMap.get('6k0')[0], keysMap.get('6k1')[0], keysMap.get('6k2')[0], keysMap.get('6k4')[0], keysMap.get('6k5')[0], keysMap.get('6k6')[0]];
			case 2: 
				if (PlayState.maniaToChange	!= 2)
				{
					switch (PlayState.maniaToChange)
					{
						case 0: 
							binds = [keysMap.get('note_left')[0],keysMap.get('note_down')[0], keysMap.get('note_up')[0], keysMap.get('note_right')[0], -1, -1, -1, -1, -1];
						case 1: 
							binds = [keysMap.get('6k0')[0], keysMap.get('6k5')[0], keysMap.get('6k1')[0], keysMap.get('6k2')[0],-1, keysMap.get('6k4')[0],-1, -1,keysMap.get('6k6')[0]];
						case 3: 
							binds = [keysMap.get('note_left')[0],keysMap.get('note_down')[0], keysMap.get('note_up')[0], keysMap.get('note_right')[0], keysMap.get('6k3')[0], -1, -1, -1, -1];
						case 4: 
							binds = [keysMap.get('6k0')[0], keysMap.get('6k5')[0], keysMap.get('6k1')[0], keysMap.get('6k2')[0],keysMap.get('6k3')[0], keysMap.get('6k4')[0],-1, -1,keysMap.get('6k6')[0]];
						case 5: 
							binds = [keysMap.get('9k0')[0], keysMap.get('9k1')[0], keysMap.get('9k2')[0], keysMap.get('9k3')[0], -1, keysMap.get('9k5')[0], keysMap.get('9k6')[0], keysMap.get('9k7')[0], keysMap.get('9k8')[0]];
						case 6: 
							binds = [-1,-1,-1,-1,keysMap.get('6k3')[0],-1,-1,-1,-1];
						case 7:
							binds = [keysMap.get('note_left')[0],-1,-1, keysMap.get('note_right')[0],-1,-1,-1,-1,-1];
						case 8: 
							binds = [keysMap.get('note_left')[0],-1,-1, keysMap.get('note_right')[0],keysMap.get('6k3')[0],-1,-1,-1,-1];
					}
				}
				else
					binds = [keysMap.get('9k0')[0], keysMap.get('9k1')[0], keysMap.get('9k2')[0], keysMap.get('9k3')[0], keysMap.get('9k4')[0], keysMap.get('9k5')[0], keysMap.get('9k6')[0], keysMap.get('9k7')[0], keysMap.get('9k8')[0]];
			case 3: 
				binds = [keysMap.get('note_left')[0],keysMap.get('note_down')[0], keysMap.get('6k3')[0], keysMap.get('note_up')[0], keysMap.get('note_right')[0]];
			case 4: 
				binds = [keysMap.get('6k0')[0], keysMap.get('6k1')[0], keysMap.get('6k2')[0], keysMap.get('6k3')[0], keysMap.get('6k4')[0], keysMap.get('6k5')[0], keysMap.get('6k6')[0]];
			case 5: 
				binds = [keysMap.get('9k0')[0], keysMap.get('9k1')[0], keysMap.get('9k2')[0], keysMap.get('9k3')[0], keysMap.get('9k5')[0], keysMap.get('9k6')[0], keysMap.get('9k7')[0], keysMap.get('9k8')[0]];
			case 6: 
				binds = [keysMap.get('6k3')[0]];
			case 7:
				binds = [keysMap.get('note_left')[0], keysMap.get('note_right')[0]];
			case 8: 
				binds = [keysMap.get('note_left')[0], keysMap.get('6k3')[0], keysMap.get('note_right')[0]];
		}
		return binds;
	}
	public static function altbindCheck(mania:Int)
		{
			var keysMap = ClientPrefs.keyBinds;
	
			var binds:Array<Int> = [keysMap.get('note_left')[1],keysMap.get('note_down')[1], keysMap.get('note_up')[1], keysMap.get('note_right')[1]];
			switch(mania)
			{
				case 0: 
					binds = [keysMap.get('note_left')[1],keysMap.get('note_down')[1], keysMap.get('note_up')[1], keysMap.get('note_right')[1]];
				case 1: 
					binds = [keysMap.get('6k0')[1], keysMap.get('6k1')[1], keysMap.get('6k2')[1], keysMap.get('6k4')[1], keysMap.get('6k5')[1], keysMap.get('6k6')[1]];
				case 2: 
					if (PlayState.maniaToChange	!= 2)
					{
						switch (PlayState.maniaToChange)
						{
							case 0: 
								binds = [keysMap.get('note_left')[1],keysMap.get('note_down')[1], keysMap.get('note_up')[1], keysMap.get('note_right')[1], -1, -1, -1, -1, -1];
							case 1: 
								binds = [keysMap.get('6k0')[1], keysMap.get('6k5')[1], keysMap.get('6k1')[1], keysMap.get('6k2')[1],-1, keysMap.get('6k4')[1],-1, -1,keysMap.get('6k6')[0]];
							case 3: 
								binds = [keysMap.get('note_left')[1],keysMap.get('note_down')[1], keysMap.get('note_up')[1], keysMap.get('note_right')[1], keysMap.get('6k3')[1], -1, -1, -1, -1];
							case 4: 
								binds = [keysMap.get('6k0')[1], keysMap.get('6k5')[1], keysMap.get('6k1')[1], keysMap.get('6k2')[1],keysMap.get('6k3')[1], keysMap.get('6k4')[1],-1, -1,keysMap.get('6k6')[1]];
							case 5: 
								binds = [keysMap.get('9k0')[1], keysMap.get('9k1')[1], keysMap.get('9k2')[1], keysMap.get('9k3')[1], -1, keysMap.get('9k5')[1], keysMap.get('9k6')[1], keysMap.get('9k7')[1], keysMap.get('9k8')[1]];
							case 6: 
								binds = [-1,-1,-1,-1,keysMap.get('6k3')[1],-1,-1,-1,-1];
							case 7:
								binds = [keysMap.get('note_left')[1],-1,-1, keysMap.get('note_right')[1],-1,-1,-1,-1,-1];
							case 8: 
								binds = [keysMap.get('note_left')[1],-1,-1, keysMap.get('note_right')[1],keysMap.get('6k3')[1],-1,-1,-1,-1];
						}
					}
					else
						binds = [keysMap.get('9k0')[1], keysMap.get('9k1')[1], keysMap.get('9k2')[1], keysMap.get('9k3')[1], keysMap.get('9k4')[1], keysMap.get('9k5')[1], keysMap.get('9k6')[1], keysMap.get('9k7')[1], keysMap.get('9k8')[1]];
				case 3: 
					binds = [keysMap.get('note_left')[1],keysMap.get('note_down')[1], keysMap.get('6k3')[1], keysMap.get('note_up')[1], keysMap.get('note_right')[1]];
				case 4: 
					binds = [keysMap.get('6k0')[1], keysMap.get('6k1')[1], keysMap.get('6k2')[1], keysMap.get('6k3')[1], keysMap.get('6k4')[1], keysMap.get('6k5')[1], keysMap.get('6k6')[1]];
				case 5: 
					binds = [keysMap.get('9k0')[1], keysMap.get('9k1')[1], keysMap.get('9k2')[1], keysMap.get('9k3')[1], keysMap.get('9k5')[1], keysMap.get('9k6')[1], keysMap.get('9k7')[1], keysMap.get('9k8')[1]];
				case 6: 
					binds = [keysMap.get('6k3')[1]];
				case 7:
					binds = [keysMap.get('note_left')[1], keysMap.get('note_right')[1]];
				case 8: 
					binds = [keysMap.get('note_left')[1], keysMap.get('6k3')[1], keysMap.get('note_right')[1]];
			}
			return binds;
		}
}
