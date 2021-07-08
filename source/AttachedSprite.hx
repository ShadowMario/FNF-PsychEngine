package;

import flixel.FlxSprite;

using StringTools;

class AttachedSprite extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public function new(file:String, ?anim:String = null, ?library:String = null, ?loop:Bool = false)
	{
		super();
		if(anim != null) {
			frames = Paths.getSparrowAtlas(file, library);
			animation.addByPrefix('idle', anim, 24, loop);
			animation.play('idle');
		} else {
			loadGraphic(file);
		}
		antialiasing = ClientPrefs.globalAntialiasing;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
		}
	}
}
