package psychlua;

class DebugLuaText extends FlxText
{
	public var disableTime:Float = 6;
	public function new() {
		super(10, 10, 0, '', 16);

		setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		disableTime -= elapsed;
		if(disableTime < 0) disableTime = 0;
		if(disableTime < 1) alpha = disableTime;

		if(alpha == 0 || y >= FlxG.height) kill();
	}
}