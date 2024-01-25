package objects;

class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, weekName:String = '', flashColor: FlxColor = 0xFF33FFFF)
	{
		super(x, y);
		loadGraphic(Paths.image('storymenu/' + weekName));
		antialiasing = ClientPrefs.data.antialiasing;
		this.flashColor = flashColor;
		//trace('Test added: ' + WeekData.getWeekNumber(weekNum) + ' (' + weekNum + ')');
	}

	@:allow(states.editors.WeekEditorState) private var isFlashing(default, set):Bool = false;
	@:allow(states.editors.WeekEditorState) private var _flashCooldown:Float = 0; // for Week Editor

	private var _flashingElapsed:Float = 0;
	private final flashes_ps:Int = 6;

	public var flashColor: FlxColor = 0xFF33FFFF;
	// in case you wanna force a specific color when flashing this menu item @crowplexus
	public function startFlashing(?color: FlxColor = -1) {
		if (color != -1 && flashColor != color) flashColor = color;
		isFlashing = true;
	}

	public function set_isFlashing(value:Bool = true):Bool
	{
		isFlashing = value;
		_flashingElapsed = 0;
		color = (isFlashing) ? flashColor : FlxColor.WHITE;
		return isFlashing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		y = FlxMath.lerp((targetY * 120) + 480, y, Math.exp(-elapsed * 10.2));
		if (isFlashing)
		{
			if (_flashCooldown != 0)
				_flashCooldown -= elapsed;
			else if (_flashCooldown <= 0) {
				isFlashing = false;
				color = FlxColor.WHITE;
				return;
			}
			_flashingElapsed += elapsed;
			color = (Math.floor(_flashingElapsed * FlxG.updateFramerate * flashes_ps) % 2 == 0) ? flashColor : FlxColor.WHITE;
		}
	}
}
