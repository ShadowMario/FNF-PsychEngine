package cutscenes;

import flixel.FlxBasic;
import flixel.util.FlxSort;

typedef CutsceneEvent = {
	var time:Float;
	var func:Void->Void;
}

class CutsceneHandler extends FlxBasic
{
	public var timedEvents:Array<CutsceneEvent> = [];
	public var finishCallback:Void->Void = null;
	public var finishCallback2:Void->Void = null;
	public var onStart:Void->Void = null;
	public var endTime:Float = 0;
	public var objects:Array<FlxSprite> = [];
	public var music:String = null;
	public function new()
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

		if(endTime <= cutsceneTime)
		{
			finishCallback();
			if(finishCallback2 != null) finishCallback2();

			for (spr in objects)
			{
				spr.kill();
				PlayState.instance.remove(spr);
				spr.destroy();
			}
			
			kill();
			destroy();
			PlayState.instance.remove(this);
		}
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