package states.stages.objects;

class BackgroundGirls extends FlxSprite
{
	var isPissed:Bool = true;
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/bgFreaks');
		antialiasing = false;
		swapDanceType();

		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		updateHitbox();
		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function swapDanceType():Void
	{
		isPissed = !isPissed;
		if(!isPissed) { //Gets unpissed
			animation.addByIndices('danceLeft', 'BG girls group', [for (i in 0...14) i], "", 24, false);
			animation.addByIndices('danceRight', 'BG girls group', [for (i in 15...30) i], "", 24, false);
		} else { //Pisses
			animation.addByIndices('danceLeft', 'BG fangirls dissuaded', [for (i in 0...14) i], "", 24, false);
			animation.addByIndices('danceRight', 'BG fangirls dissuaded', [for (i in 15...30) i], "", 24, false);
		}
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
