package objects;

import backend.Highscore;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import objects.AttachedSprite;
import psychlua.FunkinLua;

class UserInterface extends FlxGroup
{
	private var game(get, never):PlayState;

	function get_game():PlayState
		return PlayState.instance;

	public var scoreTxt:FlxText;
	public var timeTxt:FlxText;
	public var botplayTxt:FlxText;

	public var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;

	public var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var botplaySine:Float = 0;

	private var scoreTxtTween:FlxTween;

	// for Time Bar
	private var songPercent:Float = 0;
	private var updateTime:Bool = true;

	public function new()
	{
		super();

		if (ClientPrefs.data.timeBarType != 'Disabled')
		{
			timeTxt = new FlxText(PlayState.STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.scrollFactor.set();
			timeTxt.alpha = 0;
			timeTxt.borderSize = 2;

			if (ClientPrefs.data.downScroll)
				timeTxt.y = FlxG.height - 44;

			if (ClientPrefs.data.timeBarType == 'Song Name')
				timeTxt.text = PlayState.SONG.song;

			timeBarBG = new AttachedSprite('timeBar');
			timeBarBG.x = timeTxt.x;
			timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
			timeBarBG.scrollFactor.set();
			timeBarBG.alpha = 0;
			timeBarBG.color = FlxColor.BLACK;
			timeBarBG.xAdd = -4;
			timeBarBG.yAdd = -4;
			add(timeBarBG);

			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
			timeBar.alpha = 0;
			add(timeBar);
			add(timeTxt);
			timeBarBG.sprTracker = timeBar;

			if (ClientPrefs.data.timeBarType == 'Song Name')
			{
				timeTxt.size = 24;
				timeTxt.y += 3;
			}
		}

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if (ClientPrefs.data.downScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, '', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(game.boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(game.dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);

        var botPosition:Float = (FlxG.width / 2) - 248;

		botplayTxt = new FlxText(400, botPosition + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = game.cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.data.downScroll)
			botplayTxt.y = botPosition - 78;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

        /*
        if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();
        */

        // fix for health percentage
        healthBar.percent = game.health * 50;

		if (botplayTxt != null && botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0;
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0;

		if (timeTxt != null && timeTxt.visible)
		{
			var curTime:Float = Conductor.songPosition - ClientPrefs.data.noteOffset;
			if (curTime < 0)
				curTime = 0;

			songPercent = (curTime / game.songLength);

			var songCalc:Float = (game.songLength - curTime);
			if (ClientPrefs.data.timeBarType == 'Time Elapsed')
				songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if (secondsTotal < 0)
				secondsTotal = 0;

			if (ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}
	}

    // for lua
	public var separator:String = ' | ';

	// don't know if structures are accesible with lua, if not, then use hscript @BeastlyGabi
	public var scoreDisplays = {
		misses: true,
		ratingPercent: true,
		ratingName: true,
		ratingFC: true
	};

	public function updateScore(miss:Bool = false)
	{
		var ret:Dynamic = game.callOnLuas('onUpdateScore', [miss]);
		if (ret == FunkinLua.Function_Stop)
			return;

		var scoreString:String = 'Score: ' + game.songScore;

        if (scoreDisplays.misses)
		    scoreString += separator + 'Misses: ' + game.songMisses;
        if (scoreDisplays.ratingName)
		    scoreString += separator + 'Rating: ' + game.ratingName;
		if (game.ratingName != '?' && scoreDisplays.ratingPercent)
			scoreString += ' (${Highscore.floorDecimal(game.ratingPercent * 100, 2)}%)';

		if (game.ratingFC != '' && scoreDisplays.ratingFC)
			scoreString += ' - ${game.ratingFC}';

		scoreTxt.text = scoreString;

		if (ClientPrefs.data.scoreZoom && !miss && !game.cpuControlled)
		{
			if (scoreTxtTween != null)
				scoreTxtTween.cancel();

			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}
	}

	public function beatHit(curBeat:Int)
	{
		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}

	public function reloadHealthBarColors()
	{
		var dad:Character = game.dad;
		var boyfriend:Character = game.boyfriend;

		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		healthBar.updateBar();
	}
}
