package states.stages.objects;

class PhillyGlowParticle extends FlxSprite
{
	var lifeTime:Float = 0;
	var decay:Float = 0;
	var originalScale:Float = 1;
	public function new(x:Float, y:Float, color:FlxColor)
	{
		super(x, y);
		this.color = color;

		loadGraphic(Paths.image('stages/philly/particle'));
		lifeTime = FlxG.random.float(0.6, 0.9);
		decay = FlxG.random.float(0.8, 1);
		if(!ClientPrefs.data.flashing)
		{
			decay *= 0.5;
			alpha = 0.5;
		}

		originalScale = FlxG.random.float(0.75, 1);
		scale.set(originalScale, originalScale);

		scrollFactor.set(FlxG.random.float(0.3, 0.75), FlxG.random.float(0.65, 0.75));
		velocity.set(FlxG.random.float(-40, 40), FlxG.random.float(-175, -250));
		acceleration.set(FlxG.random.float(-10, 10), 25);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		lifeTime -= elapsed;
		if(lifeTime < 0)
		{
			lifeTime = 0;
			alpha -= decay * elapsed;
			if(alpha > 0)
			{
				scale.set(originalScale * alpha, originalScale * alpha);
			}
		}
		super.update(elapsed);
	}
}