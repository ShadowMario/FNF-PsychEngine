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
		changeIcon(if(isOldIcon = !isOldIcon) 'bf-old' else 'bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];


	public dynamic function updateAnim(health:Float){ // Dynamic to prevent having like 20 if statements
		if (health < 20)
			animation.curAnim.curFrame = 1;
		else
			animation.curAnim.curFrame = 0;
	}

	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			
			var icoheight:Int = 150;
			var icowidth:Int = 150;
			var frameCount = 1; // Has to be 1 instead of 2 due to how compooters handle numbers
			if(width % 150 != 0 || height % 150 != 0){ // Invalid sized health icon! Split in half
				icoheight = file.height;
				icowidth = Std.int(file.width * 0.5);
			}else{
				frameCount = Std.int(file.width / 150) - 1; // If this isn't an integer, fucking run
				if(frameCount == 0) updateAnim = function(health:Float){return;};
				else if(frameCount == 1) updateAnim = function(health:Float){
					if (health < 20)
						animation.curAnim.curFrame = 1;
					else
						animation.curAnim.curFrame = 0;
				};
				// This goes from Losing to Winning
				else if(frameCount > 1) updateAnim = function(health:Float){animation.curAnim.curFrame = Math.round( animation.curAnim.frameCount * (health / 100) );};
				
			}
			loadGraphic(file, true, icowidth, icoheight); //Then load it fr
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();


			frameCount = frameCount + 1;
			animation.add(char, if(frameCount > 1)[for (i in 0 ... frameCount) i] else [0,1], 0, false, isPlayer);

			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
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
