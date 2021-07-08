package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class CheckboxThingie extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public function new(x:Float = 0, y:Float = 0, ?checked = false) {
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix("static", "Check Box unselected", 24, false);
		animation.addByPrefix("checked", "Check Box selecting animation", 24, false);
		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(0.7 * width));
		updateHitbox();
		set_daValue(checked);
	}

	override function update(elapsed:Float) {
		switch (animation.curAnim.name) {
			case "checked":
				offset.set(17, 70);
			case "static":
				offset.set(0, 0);
		}

		if (sprTracker != null)
			setPosition(sprTracker.x - 100, sprTracker.y + 5);

		super.update(elapsed);
	}

	public function set_daValue(checked:Bool) {
		if(checked) {
			if(animation.curAnim.name != 'checked') {
				animation.play('checked', true);
				offset.set(17, 70);
			}
		} else {
			animation.play("static");
			offset.set(0, 0);
		}
	}
}