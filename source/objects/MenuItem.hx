package objects;

class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;
	//public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekName:String = '')
	{
		super(x, y, Paths.image('storymenu/$weekName'));
		antialiasing = ClientPrefs.data.antialiasing;
		//trace('Test added: ' + WeekData.getWeekNumber(weekNum) + ' (' + weekNum + ')');
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	// WHAT WHERE NINJA SMOKING BRUH??????
	//var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	public var isFlashing(default, set):Bool = false;
	final flashColor:Int = 0xFF33ffff;
	final flashFrame:Int = 6;
	var flashElapsed:Float = 0.0;

	inline function set_isFlashing(flashing:Bool):Bool
	{
		flashElapsed = 0.0;
		color = (flashing ? flashColor : FlxColor.WHITE);
		return isFlashing = flashing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, Math.max(elapsed * 10.2, 0));

		if (isFlashing)
		{
			flashElapsed += elapsed;
			color = (flashElapsed * FlxG.updateFramerate) % flashFrame > flashFrame * 0.5 ? FlxColor.WHITE : flashColor;
		}

		/*if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			color = 0xFF33ffff;
		else
			color = FlxColor.WHITE;*/
	}
}
