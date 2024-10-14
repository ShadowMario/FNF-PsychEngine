package cutscenes;

import flixel.FlxBasic;
import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;
import flixel.addons.display.FlxPieDial;

typedef CutsceneEvent = {
	var time:Float;
	var func:Void->Void;
}

class CutsceneHandler extends FlxBasic
{
	public var timedEvents:Array<CutsceneEvent> = [];
	public var skipCallback:Void->Void = null;
	public var onStart:Void->Void = null;
	public var endTime:Float = 0;
	public var objects:Array<FlxSprite> = [];
	public var music:String = null;

	final _timeToSkip:Float = 1;
	var _canSkip:Bool = false;
	public var holdingTime:Float = 0;
	public var skipSprite:FlxPieDial;
	public var finishCallback:Void->Void = null;

	public function new(canSkip:Bool = true)
	{
		super();

		timer(0, function()
		{
			if(music != null)
			{
				FlxG.sound.playMusic(Paths.music(music), 0, false);
				FlxG.sound.music.fadeIn();
			}
			if(onStart != null) onStart();
		});
		FlxG.state.add(this);

		this._canSkip = canSkip;
		if(canSkip)
		{
			skipSprite = new FlxPieDial(0, 0, 40, FlxColor.WHITE, 40, true, 24);
			skipSprite.replaceColor(FlxColor.BLACK, FlxColor.TRANSPARENT);
			skipSprite.x = FlxG.width - (skipSprite.width + 80);
			skipSprite.y = FlxG.height - (skipSprite.height + 72);
			skipSprite.amount = 0;
			skipSprite.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
			FlxG.state.add(skipSprite);
		}
	}

	private var cutsceneTime:Float = 0;
	private var firstFrame:Bool = false;
	override function update(elapsed)
	{
		super.update(elapsed);

		if(FlxG.state != PlayState.instance || !firstFrame)
		{
			firstFrame = true;
			return;
		}

		cutsceneTime += elapsed;
		while(timedEvents.length > 0 && timedEvents[0].time <= cutsceneTime)
		{
			timedEvents[0].func();
			timedEvents.shift();
		}
		
		if(_canSkip && cutsceneTime > 0.1)
		{
			if(Controls.instance.pressed('accept'))
				holdingTime = Math.max(0, Math.min(_timeToSkip, holdingTime + elapsed));
			else if (holdingTime > 0)
				holdingTime = Math.max(0, FlxMath.lerp(holdingTime, -0.1, FlxMath.bound(elapsed * 3, 0, 1)));

			updateSkipAlpha();
		}

		if(endTime <= cutsceneTime || holdingTime >= _timeToSkip)
		{
			if(holdingTime >= _timeToSkip)
			{
				trace('skipped cutscene');
				if(skipCallback != null)
					skipCallback();
			}
			else finishCallback();

			for (spr in objects)
			{
				spr.kill();
				PlayState.instance.remove(spr);
				spr.destroy();
			}
			
			skipSprite = FlxDestroyUtil.destroy(skipSprite);
			destroy();
			PlayState.instance.remove(this);
		}
	}

	function updateSkipAlpha()
	{
		if(skipSprite == null) return;

		skipSprite.amount = Math.min(1, Math.max(0, (holdingTime / _timeToSkip) * 1.025));
		skipSprite.alpha = FlxMath.remapToRange(skipSprite.amount, 0.025, 1, 0, 1);
	}

	public function push(spr:FlxSprite)
	{
		objects.push(spr);
	}

	public function timer(time:Float, func:Void->Void)
	{
		timedEvents.push({time: time, func: func});
		timedEvents.sort(sortByTime);
	}

	function sortByTime(Obj1:CutsceneEvent, Obj2:CutsceneEvent):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
	}
}