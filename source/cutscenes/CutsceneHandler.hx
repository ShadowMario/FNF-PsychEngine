package cutscenes;

import flixel.FlxBasic;
import flixel.util.FlxSort;

class CutsceneHandler extends FlxBasic
{
	public var timedEvents:Array<Dynamic> = [];
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
		PlayState.instance.add(this);
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
		if(endTime <= cutsceneTime)
		{
			finishCallback();
			if(finishCallback2 != null) finishCallback2();

			for (spr in objects)
			{
				PlayState.instance.remove(spr);
				spr.destroy();
			}
			
			destroy();
			PlayState.instance.remove(this);
		}
		
		while(timedEvents.length > 0 && timedEvents[0][0] <= cutsceneTime)
		{
			timedEvents[0][1]();
			timedEvents.shift();
		}
	}

	public function push(spr:FlxSprite)
	{
		objects.push(spr);
	}

	public function timer(time:Float, func:Void->Void)
	{
		timedEvents.push([time, func]);
		timedEvents.sort(sortByTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	override function destroy(){
		active = false;
		super.destroy();
	}
}
