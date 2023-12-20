package states.stages.objects;

class BackgroundTank extends BGSprite
{
	public var offsetX:Float = 400;
	public var offsetY:Float = 1300;
	public var tankSpeed:Float = 0;
	public var tankAngle:Float = 0;
	public function new()
	{
		super('tankRolling', 0, 0, 0.5, 0.5, ['BG tank w lighting'], true);
		tankSpeed = FlxG.random.float(5, 7);
		tankAngle = FlxG.random.int(-90, 45);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		tankAngle += elapsed * tankSpeed;
		angle = tankAngle - 90 + 15;
		x = offsetX + 1500 * Math.cos(Math.PI / 180 * (tankAngle + 180));
		y = offsetY + 1100 * Math.sin(Math.PI / 180 * (tankAngle + 180));
	}
}