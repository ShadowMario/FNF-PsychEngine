package states.stages.objects;

enum SpraycanState
{
	WAITING;
	ARCING;		// In the air.
	SHOT;		// Hit by the player.
	IMPACTED;	// Impacted the player.
}

class SpraycanAtlasSprite extends FlxSpriteGroup
{
	public var currentState:SpraycanState = WAITING;

	public var canAtlas:FlxAnimate;
	public var explosion:FlxSprite;
	public function new(x:Float = 0, y:Float = 0)
	{
		super();

		canAtlas = new FlxAnimate(x, y);
		Paths.loadAnimateAtlas(canAtlas, 'spraycanAtlas');
		canAtlas.anim.addBySymbolIndices('Can Start', 'Can with Labels', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 24, false);
		canAtlas.anim.addBySymbolIndices('Hit Pico', 'Can with Labels', [19, 20, 21, 22, 23, 24, 25], false);
		canAtlas.anim.addBySymbolIndices('Can Shot', 'Can with Labels', [26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42], 24, false);
		canAtlas.anim.onComplete.add(finishCanAnimation);
		canAtlas.visible = canAtlas.active = false;
		canAtlas.antialiasing = ClientPrefs.data.antialiasing;
		add(canAtlas);

		explosion = new FlxSprite(x - 25, y - 450);
		explosion.frames = Paths.getSparrowAtlas('spraypaintExplosionEZ');
		explosion.animation.addByPrefix('idle', 'explosion round 1 short0', 24, false);
		explosion.animation.finishCallback = (name:String) -> explosion.visible = explosion.active = false;
		explosion.visible = explosion.active = false;
		explosion.antialiasing = ClientPrefs.data.antialiasing;
		add(explosion);
	}

	public var cutscene:Bool = false;
	public function finishCanAnimation()
	{
		switch(playingAnim)
		{
			case 'Can Start':
				playHitPico();
			case 'Can Shot':
				canAtlas.visible = canAtlas.active = false;
				currentState = WAITING;
			case 'Hit Pico':
				if(!cutscene) playHitExplosion();
				canAtlas.visible = canAtlas.active = false;
				currentState = WAITING;
		}
	}

	public function playHitExplosion():Void
	{
		explosion.visible = explosion.active = true;
		explosion.animation.play('idle', true);
	}

	public function playCanStart():Void
	{
		playAnimation('Can Start');
		canAtlas.visible = canAtlas.active = true;
		currentState = ARCING;
	}

	public function playCanShot():Void
	{
		playAnimation('Can Shot');
		currentState = SHOT;
	}

	public function playHitPico():Void
	{
		playAnimation('Hit Pico');
		currentState = IMPACTED;
	}

	var playingAnim:String;
	public function playAnimation(name:String)
	{
		canAtlas.anim.play(name, true);
		playingAnim = name;
	}
}