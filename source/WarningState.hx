package;
import flixel.*;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

/**
 * ...
 * sorry bbpanzu
 */
class WarningState extends MusicBeatState
{

	public function new() 
	{
		super();
	}
	override function create() 
	{
		super.create();
		
		var bg:FlxSprite = new FlxSprite();
		
		bg.loadGraphic(Paths.image("preload/images/Upozorenje", "assets"));
		add(bg);
		
		addVirtualPad(NONE, A);			
	}
	
	
	override function update(elapsed:Float) 
	{
		super.update(elapsed);
		
		
		if (controls.ACCEPT){
			FlxG.sound.play(Paths.sound('scrollMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
	}
}