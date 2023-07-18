package states.stages.objects;

import flixel.graphics.frames.FlxAtlasFrames;

class TankmenBG extends FlxSprite
{
	public static var animationNotes:Array<Dynamic> = [];
	private var tankSpeed:Float;
	private var endingOffset:Float;
	private var goingRight:Bool;
	public var strumTime:Float;

	public function new(x:Float, y:Float, facingRight:Bool)
	{
		tankSpeed = 0.7;
		goingRight = false;
		strumTime = 0;
		goingRight = facingRight;
		super(x, y);

		frames = Paths.getSparrowAtlas('tankmanKilled1');
		animation.addByPrefix('run', 'tankman running', 24, true);
		animation.addByPrefix('shot', 'John Shot ' + FlxG.random.int(1, 2), 24, false);
		animation.play('run');
		animation.curAnim.curFrame = FlxG.random.int(0, animation.curAnim.frames.length - 1);
		antialiasing = ClientPrefs.data.antialiasing;

		setGraphicSize(Std.int(0.8 * width));
		updateHitbox();
	}

	public function resetShit(x:Float, y:Float, goingRight:Bool):Void
	{
		this.x = x;
		this.y = y;
		this.goingRight = goingRight;
		endingOffset = FlxG.random.float(50, 200);
		tankSpeed = FlxG.random.float(0.6, 1);
		flipX = goingRight;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		visible = (x > -0.5 * FlxG.width && x < 1.2 * FlxG.width);

		if(animation.curAnim.name == "run")
		{
			var speed:Float = (Conductor.songPosition - strumTime) * tankSpeed;
			if(goingRight)
				x = (0.02 * FlxG.width - endingOffset) + speed;
			else
				x = (0.74 * FlxG.width + endingOffset) - speed;
		}
		else if(animation.curAnim.finished)
		{
			kill();
		}

		if(Conductor.songPosition > strumTime)
		{
			animation.play('shot');
			if(goingRight)
			{
				offset.x = 300;
				offset.y = 200;
			}
		}
	}
}