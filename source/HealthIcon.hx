package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	public function changeIcon(char:String) {
		if(char != 'bf-pixel' && char != 'bf-old') {
			char = (char.split('-')[0]).trim();
		}

		if(this.char != char) {
			var file:String = Paths.image('icons/icon-' + char);
			if(!OpenFlAssets.exists(file)) file = Paths.image('icons/icon-face'); //Prevents crash from missing icon

			loadGraphic(file, true, 150, 150);
			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			switch(char) {
				case 'bf-pixel' | 'senpai' | 'spirit':
					antialiasing = false;

				default:
					antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}
}
