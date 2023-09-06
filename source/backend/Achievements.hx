package backend;

import objects.AchievementPopup;
import haxe.Exception;

#if ACHIEVEMENTS_ALLOWED
class Achievements {
	public static var achievements:Array<Dynamic> = [
		//Name -- Description -- Achievement save tag -- is hidden while locked -- max score -- max number of decimals you want it to display
		["Freaky on a Friday Night",	"Play on a Friday... Night.",						'friday_night_play',	true],
		["She Calls Me Daddy Too",		"Beat Week 1 on Hard with no Misses.",				'week1_nomiss'],
		["No More Tricks",				"Beat Week 2 on Hard with no Misses.",				'week2_nomiss'],
		["Call Me The Hitman",			"Beat Week 3 on Hard with no Misses.",				'week3_nomiss'],
		["Lady Killer",					"Beat Week 4 on Hard with no Misses.",				'week4_nomiss'],
		["Missless Christmas",			"Beat Week 5 on Hard with no Misses.",				'week5_nomiss'],
		["Highscore!!",					"Beat Week 6 on Hard with no Misses.",				'week6_nomiss'],
		["God Effing Damn It!",			"Beat Week 7 on Hard with no Misses.",				'week7_nomiss'],
		["What a Funkin' Disaster!",	"Complete a Song with a rating lower than 20%.",	'ur_bad'],
		["Perfectionist",				"Complete a Song with a rating of 100%.",			'ur_good'],
		["Roadkill Enthusiast",			"Watch the Henchmen die 50 times.",					'roadkill_enthusiast',	false,	50,	0],
		["Oversinging Much...?",		"Hold down a note for 10 seconds.",					'oversinging'],
		["Hyperactive",					"Finish a Song without going Idle.",				'hype'],
		["Just the Two of Us",			"Finish a Song pressing only two keys.",			'two_keys'],
		["Toaster Gamer",				"Have you tried to run the game on a toaster?",		'toastie'],
		["Debugger",					"Beat the \"Test\" Stage from the Chart Editor.",	'debugger',				true]
	];

	public static var variables:Map<String, Float> = [];
	public static var achievementsUnlocked:Array<String> = [];
	private static var _firstLoad:Bool = true;

	public static function load():Void
	{
		if(!_firstLoad) return;

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
		{
			variables.set(name, 0);
		}

		for (achievement in achievements)
		{
			if(achievement[2] == name)
			{
				if(achievement.length <= 4 || achievement[4] < 1) throw new Exception('Achievement has score disabled or is incorrectly configured: $name');

				var max:Float = achievement[4];
				if(achievementsUnlocked.contains(name)) return max;

				var val = addOrSet;
				switch(mode)
				{
					case 0: return variables.get(name); //get
					case 2: val += variables.get(name); //add
				}

				if(val >= max)
				{
					unlock(name);
					val = max;
				}
				variables.set(name, val);

				Achievements.save();
				if(saveIfNotUnlocked || val >= max) FlxG.save.flush();
				return val;
			}
		}
		return -1;
	}

	static var _lastUnlock:Int = -999;
	public static function unlock(name:String, autoStartPopup:Bool = true):String {
		if(Achievements.getIndexOf(name) < 0)
		{
			FlxG.log.error('Achievement "$name" does not exists!');
			throw new Exception('Achievement "$name" does not exists!');
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

	public static function getIndexOf(name:String)
	{
		for (i in 0...achievements.length)
			if(achievements[i][2] == name)
				return i;

		return -1;
	}
	
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
}
#end