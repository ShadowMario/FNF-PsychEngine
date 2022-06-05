import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [ //Name, Description, Achievement save tag, Hidden achievement
		["Freaky on a Friday Night",	"Play on a Friday... Night.",						'friday_night_play',	 true],
		["She Calls Me Daddy Too",		"Beat Week 1 on Hard with no Misses.",				'week1_nomiss',			false],
		["No More Tricks",				"Beat Week 2 on Hard with no Misses.",				'week2_nomiss',			false],
		["Call Me The Hitman",			"Beat Week 3 on Hard with no Misses.",				'week3_nomiss',			false],
		["Lady Killer",					"Beat Week 4 on Hard with no Misses.",				'week4_nomiss',			false],
		["Missless Christmas",			"Beat Week 5 on Hard with no Misses.",				'week5_nomiss',			false],
		["Highscore!!",					"Beat Week 6 on Hard with no Misses.",				'week6_nomiss',			false],
		["God Effing Damn It!",			"Beat Week 7 on Hard with no Misses.",				'week7_nomiss',			false],
		["What a Funkin' Disaster!",	"Complete a Song with a rating lower than 20%.",	'ur_bad',				false],
		["Perfectionist",				"Complete a Song with a rating of 100%.",			'ur_good',				false],
		["Roadkill Enthusiast",			"Watch the Henchmen die over 100 times.",			'roadkill_enthusiast',	false],
		["Oversinging Much...?",		"Hold down a note for 10 seconds.",					'oversinging',			false],
		["Hyperactive",					"Finish a Song without going Idle.",				'hype',					false],
		["Just the Two of Us",			"Finish a Song pressing only two keys.",			'two_keys',				false],
		["Toaster Gamer",				"Have you tried to run the game on a toaster?",		'toastie',				false],
		["Debugger",					"Beat the \"Test\" Stage from the Chart Editor.",	'debugger',				 true]
	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(name:String) {
		for (i in 0...achievementsStuff.length) {
			if(achievementsStuff[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
	}

	public static function giveAchievement(achieve:String, achievementEnd:Void->Void = null):Void {
		var achieveID:Int = Achievements.getAchievementIndex(achieve);
		Main.toastManager.createToast(Paths.achievementImage('achievements/' + achieve), Achievements.achievementsStuff[achieveID][0], Achievements.achievementsStuff[achieveID][1], true);
		if (achievementEnd != null)
			Main.toastManager.onFinish = achievementEnd;

		trace('Giving achievement ' + achieve);

		ClientPrefs.saveSettings();
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var tag:String;
	public function new(x:Float = 0, y:Float = 0, name:String) {
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String) {
		this.tag = tag;
		reloadAchievementImage();
	}

	public function reloadAchievementImage() {
		if(Achievements.isAchievementUnlocked(tag)) {
			loadGraphic(Paths.image('achievements/' + tag));
		} else {
			loadGraphic(Paths.image('achievements/lockedachievement'));
		}
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}