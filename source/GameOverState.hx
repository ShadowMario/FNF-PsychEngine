package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverState extends FlxTransitionableState
{
	var bfX:Float = 0;
	var bfY:Float = 0;

	public var char = "Friday Night Funkin':bf";
	public var firstDeathSFX = "Friday Night Funkin':fnf_loss_sfx";
	public var gameOverMusic = "Friday Night Funkin':gameOver";
	public var gameOverMusicBPM = 100;
	public var retrySFX = "Friday Night Funkin':gameOverEnd";

	public function new(x:Float, y:Float)
	{
		super();

		bfX = x;
		bfY = y;
	}

	override function create()
	{
		var bf:Boyfriend = new Boyfriend(bfX, bfY);
		add(bf);
		bf.playAnim('firstDeath');

		FlxG.camera.follow(bf, LOCKON, 0.001);
		FlxG.sound.music.fadeOut(2, FlxG.sound.music.volume * 0.6);
		super.create();
	}

	private var fading:Bool = false;

	override function update(elapsed:Float)
	{
		var pressed:Bool = FlxControls.justPressed.ANY;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.ANY)
				pressed = true;
		}

		pressed = false;

		if (pressed && !fading)
		{
			fading = true;
			FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween)
			{
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		super.update(elapsed);
	}
}
