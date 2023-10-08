package backend;

import objects.AchievementPopup;
import haxe.Exception;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

#if ACHIEVEMENTS_ALLOWED
typedef Achievement =
{
	var name:String;
	var description:String;
	@:optional var hidden:Bool;
	@:optional var maxScore:Float;
	@:optional var maxDecimals:Int;
	@:optional var ID:Int; //handled automatically, ignore it
	
	//custom achievements vars
	@:optional public var save_tag:String;
	@:optional public var active:Null<Bool>;
}

class Achievements {
	public static function init()
	{
		createAchievement('friday_night_play',		{name: "Freaky on a Friday Night", description: "Play on a Friday... Night.", hidden: true});
		createAchievement('week1_nomiss',			{name: "She Calls Me Daddy Too", description: "Beat Week 1 on Hard with no Misses."});
		createAchievement('week2_nomiss',			{name: "No More Tricks", description: "Beat Week 2 on Hard with no Misses."});
		createAchievement('week3_nomiss',			{name: "Call Me The Hitman", description: "Beat Week 3 on Hard with no Misses."});
		createAchievement('week4_nomiss',			{name: "Lady Killer", description: "Beat Week 4 on Hard with no Misses."});
		createAchievement('week5_nomiss',			{name: "Missless Christmas", description: "Beat Week 5 on Hard with no Misses."});
		createAchievement('week6_nomiss',			{name: "Highscore!!", description: "Beat Week 6 on Hard with no Misses."});
		createAchievement('week7_nomiss',			{name: "God Effing Damn It!", description: "Beat Week 7 on Hard with no Misses."});
		createAchievement('ur_bad',					{name: "What a Funkin' Disaster!", description: "Complete a Song with a rating lower than 20%."});
		createAchievement('ur_good',				{name: "Perfectionist", description: "Complete a Song with a rating of 100%."});
		createAchievement('roadkill_enthusiast',	{name: "Roadkill Enthusiast", description: "Watch the Henchmen die 50 times.", maxScore: 50, maxDecimals: 0});
		createAchievement('oversinging', 			{name: "Oversinging Much...?", description: "Hold down a note for 10 seconds."});
		createAchievement('hype',					{name: "Hyperactive", description: "Finish a Song without going Idle."});
		createAchievement('two_keys',				{name: "Just the Two of Us", description: "Finish a Song pressing only two keys."});
		createAchievement('toastier',				{name: "Toaster Gamer", description: "Have you tried to run the game on a toaster?"});
		createAchievement('debugger',				{name: "Debugger", description: "Beat the \"Test\" Stage from the Chart Editor.", hidden: true});
		
		//dont delete this thing below
		_originalLength = _sortID + 1;

		#if CUSTOM_ACHIEVEMENTS_ALLOWED
		copyAchievements = achievements.copy();
		copyID = _sortID;
		#end
	}

	public static var achievements:Map<String, Achievement> = new Map<String, Achievement>();
	public static var variables:Map<String, Float> = [];
	public static var achievementsUnlocked:Array<String> = [];
	private static var _firstLoad:Bool = true;

	public static function get(name:String):Achievement
		return achievements.get(name);
	public static function exists(name:String):Bool
		return achievements.exists(name);


	@:allow(states.PlayState)
	#if CUSTOM_ACHIEVEMENTS_ALLOWED
	static var modsAchievements:Map<String, String> = [];
	static var copyAchievements:Map<String, Achievement>;
	static var copyID:Int;
	public static function loadModAchievements():Void 
	{
		if (_firstLoad) 
			return;

		modsAchievements = [];
		achievements = copyAchievements.copy();
		_sortID = copyID;

		var paths:Array<String> = [Paths.modsAchievement(),];
		for (i in backend.Mods.getGlobalMods()) {
			var path = Paths.mods(i + '/achievements/');
			if(!paths.contains(path))
				paths.push(path);
		}
		var path = Paths.mods('achievements/');
		if(!paths.contains(path))
			paths.push(path);

		paths.push(Paths.getPreloadPath('achievements/'));

		for (i in paths) 
		{
			if (FileSystem.exists(i))
			{
				for (file in FileSystem.readDirectory(i))
				{
					if(file.endsWith('.json')) 
					{
						var content:String = File.getContent(i + file);
						if(content != null && content.length > 0) {
							var achievement:Achievement = cast haxe.Json.parse(content);
							var achievementArray:Array<Dynamic> = [];
							if (achievement.active == null || achievement.active)
							{
								if (achievement.name != null && achievement.name.length > 0)
									achievementArray.push(achievement.name);
								if (achievement.description != null && achievement.description.length > 0)
									achievementArray.push(achievement.description);
								if (achievement.save_tag != null && achievement.save_tag.length > 0)
									achievementArray.push(achievement.save_tag);

								if(achievementArray.length < 3) throw new Exception('$file is badly formatted');

								var newAchievement:Achievement =  {
									name: achievement.name,
									description: achievement.description,
								};
								if (achievement.hidden != null)
									newAchievement.hidden = achievement.hidden;
								if (achievement.maxScore != null)
								{
									newAchievement.maxScore = achievement.maxScore;
									if (achievement.maxDecimals == null)
										achievement.maxDecimals = 0;
									newAchievement.maxDecimals = 0;
								}

								createAchievement(achievement.save_tag, newAchievement);

								var script = i + file.substring(0, file.length - 5);
								var luaScript = script + '.lua', hxScript = script + '.hx';

								var foundScript:Bool = false;
								if(FileSystem.exists(luaScript))
								{
									modsAchievements[achievement.save_tag] = luaScript;
									foundScript = true;
								}
								if(FileSystem.exists(hxScript))
								{	
									modsAchievements[achievement.save_tag] = hxScript;
									foundScript = true;
								}
								if(!foundScript)
									trace('Could not find any script for ${i + file}');
							}
						}
					}
				}
			}
		}
	}

	public static function setLuaAchievement(lua:psychlua.FunkinLua, tag:String):Void
	{
		lua.addLocalCallback("unlockAchievement", function(name:String):String
		{
			if (!exists(name))
				return "Achievement " + name + " does not exist";
			if (isUnlocked(name))
				return "Achievement " + name + " is already unlocked";

			unlock(name);
			return "Unlocked achievement " + name;
		});

		lua.addLocalCallback("getAchievementScore", function():Float
		{
			return getScore(tag);
		});

		lua.addLocalCallback("setAchievementScore", function(value:Float, saveIfNotUnlocked:Bool = true):Float
		{
			return setScore(tag, value, saveIfNotUnlocked);
		});

		lua.addLocalCallback("addAchievementScore", function(value:Float = 1, saveIfNotUnlocked:Bool = true):Float
		{
			return addScore(tag, value, saveIfNotUnlocked);
		});
	}

	public static function setHaxeAchievement(hx:psychlua.HScript, tag:String):Void
	{
		hx.set("unlockAchievement", function(name:String):String
		{
			if (!exists(name))
				return "Achievement " + name + " does not exist";
			if (isUnlocked(name))
				return "Achievement " + name + " is already unlocked";

			unlock(name);
			return "Unlocked achievement " + name;
		});

		hx.set("getAchievementScore", function():Float
		{
			return getScore(tag);
		});

		hx.set("setAchievementScore", function(value:Float, saveIfNotUnlocked:Bool = true):Float
		{
			return setScore(tag, value, saveIfNotUnlocked);
		});

		hx.set("addAchievementScore", function(value:Float = 1, saveIfNotUnlocked:Bool = true):Float
		{
			return addScore(tag, value, saveIfNotUnlocked);
		});
	}
	#end

	public static function load():Void
	{
		if(!_firstLoad) return;

		if(_originalLength < 0) init();

		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsUnlocked != null)
				achievementsUnlocked = FlxG.save.data.achievementsUnlocked;

			var savedMap:Map<String, Float> = cast FlxG.save.data.achievementsVariables;
			if(savedMap != null)
			{
				for (key => value in savedMap)
				{
					variables.set(key, value);
				}
			}
			_firstLoad = false;
		}
	}

	public static function save():Void
	{
		FlxG.save.data.achievementsUnlocked = achievementsUnlocked;
		FlxG.save.data.achievementsVariables = variables;
	}
	
	public static function getScore(name:String):Float
		return _scoreFunc(name, 0);

	public static function setScore(name:String, value:Float, saveIfNotUnlocked:Bool = true):Float
		return _scoreFunc(name, 1, value, saveIfNotUnlocked);

	public static function addScore(name:String, value:Float = 1, saveIfNotUnlocked:Bool = true):Float
		return _scoreFunc(name, 2, value, saveIfNotUnlocked);

	//mode 0 = get, 1 = set, 2 = add
	static function _scoreFunc(name:String, mode:Int = 0, addOrSet:Float = 1, saveIfNotUnlocked:Bool = true):Float
	{
		if(!variables.exists(name))
			variables.set(name, 0);

		if(achievements.exists(name))
		{
			var achievement:Achievement = achievements.get(name);
			if(achievement.maxScore < 1) throw new Exception('Achievement has score disabled or is incorrectly configured: $name');

			if(achievementsUnlocked.contains(name)) return achievement.maxScore;

			var val = addOrSet;
			switch(mode)
			{
				case 0: return variables.get(name); //get
				case 2: val += variables.get(name); //add
			}

			if(val >= achievement.maxScore)
			{
				unlock(name);
				val = achievement.maxScore;
			}
			variables.set(name, val);

			Achievements.save();
			if(saveIfNotUnlocked || val >= achievement.maxScore) FlxG.save.flush();
			return val;
		}
		return -1;
	}

	static var _lastUnlock:Int = -999;
	public static function unlock(name:String, autoStartPopup:Bool = true):String {
		if(!achievements.exists(name))
		{
			FlxG.log.error('Achievement "$name" does not exist!');
			throw new Exception('Achievement "$name" does not exist!');
			return null;
		}

		if(Achievements.isUnlocked(name)) return null;

		trace('Completed achievement "$name"');
		achievementsUnlocked.push(name);

		// earrape prevention
		var time:Int = openfl.Lib.getTimer();
		if(Math.abs(time - _lastUnlock) >= 100) //If last unlocked happened in less than 100 ms (0.1s) ago, then don't play sound
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.5);
			_lastUnlock = time;
		}

		Achievements.save();
		FlxG.save.flush();

		if(autoStartPopup) startPopup(name);
		return name;
	}

	inline public static function isUnlocked(name:String)
		return achievementsUnlocked.contains(name);

	@:allow(objects.AchievementPopup)
	private static var _popups:Array<AchievementPopup> = [];

	public static var showingPopups(get, never):Bool;
	public static function get_showingPopups()
		return _popups.length > 0;

	public static function startPopup(achieve:String, endFunc:Void->Void = null) {
		for (popup in _popups)
		{
			if(popup == null) continue;
			popup.intendedY += 150;
		}

		var newPop:AchievementPopup = new AchievementPopup(achieve, endFunc);
		_popups.push(newPop);
		//trace('Giving achievement ' + achieve);
	}

	// Map sorting cuz haxe is physically incapable of doing that by itself
	static var _sortID = 0;
	static var _originalLength = -1;
	public static function createAchievement(name, data)
	{
		data.ID = _sortID;
		achievements.set(name, data);
		_sortID++;
	}
}
#end