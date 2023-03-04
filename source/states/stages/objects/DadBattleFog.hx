package states.stages.objects;

class DadBattleFog extends FlxSpriteGroup
{
	public function new()
	{
		super();
		
		alpha = 0.7;
		blend = ADD;

		var offsetX = 200;
		var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(15, 22);
		smoke.active = true;
		add(smoke);

		var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(-15, -22);
		smoke.active = true;
		smoke.flipX = true;
		add(smoke);
	}
}