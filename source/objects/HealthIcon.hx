/*
	The reason for all my changes here is so that icons can be more configurable out of the box, without having to change a thing from base source.
	Yes, users can already make winning icons, but this supports a built in override, which I think is neat.

	This also just seems like a good practice for icons anyway. As it provides a way to create really wacky icons by abusing the height value.

	-- saturn-volv
*/

package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconSize:Int = 0;
	/**
	 * An index which decides which frame of the icon to use.
	 */
	@:isVar public var iconIndex(get, set):Int;
	public function get_iconIndex() {
		return iconIndex = animation?.curAnim.curFrame ?? 0;
	}
	public function set_iconIndex(i:Int):Int {
		return iconIndex = animation.curAnim.curFrame = (i % iconSize);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			
			var graphic = Paths.image(name, allowGPU);
			iconSize = Math.floor(graphic.width / graphic.height);
			loadGraphic(graphic, true, Math.floor(graphic.width / iconSize), Math.floor(graphic.height));
			iconOffsets[0] = (width - 150) / iconSize;
			iconOffsets[1] = (height - 150) / iconSize;
			updateHitbox();

			animation.add(char, 
				      [for(i in 0...iconSize) i], // Creates an array from 0 of iconSize in length;
				      0, false, isPlayer);
			animation.play(char);
			this.char = char;

			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
