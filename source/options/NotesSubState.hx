package options;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import shaders.RGBPalette;
import objects.Note;

class NotesSubState extends MusicBeatSubstate
{
	var onModeColumn:Bool = true;
	var curSelected:Int = 0;
	var onPixel:Bool = false;

	var myNotes:Array<Note> = [];

	public function new() {
		super();
		
		FlxG.mouse.visible = true;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFEA71FD;
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		changeSelection();
	}

	var changingNote:Bool = false;
	override function update(elapsed:Float) {
		if (controls.BACK) {
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = ClientPrefs.data.arrowRGB.length-1;
		if (curSelected >= ClientPrefs.data.arrowRGB.length)
			curSelected = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}