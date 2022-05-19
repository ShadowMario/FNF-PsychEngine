package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
#end

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

    public var animations:Array<String> = null;
    public var iconWidth:Int = 150;
    public var iconHeight:Int = 150;
    public var forceAntialiasing:Array<Bool> = null;

    private var isAnimated:Bool;
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

	public function swapOldIcon() 
    {
		if (isOldIcon = !isOldIcon) 
            changeIcon('bf-old');

		else 
            changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String) 
    {
		if (this.char != char) 
        {
            resetValues();

			var name:String = 'icons/' + char;

			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
                name = 'icons/icon-' + char; //Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
                name = 'icons/icon-face'; //Prevents crash from missing icon
			
            var file:Dynamic = Paths.image(name);

            
            #if MODS_ALLOWED
            var jsonPath:String = Paths.mods('images/icons/icon-$char.json');

            if (!FileSystem.exists(jsonPath))
                jsonPath = Paths.getPath('images/icons/icon-$char.json', TEXT);
            #end

            if (FileSystem.exists(jsonPath))
            {
                animations = getValue(jsonPath, "animations");
                iconWidth = getValue(jsonPath, "width");
                iconHeight = getValue(jsonPath, "height");
                forceAntialiasing = getValue(jsonPath, "forceAntialiasing");

                width = iconWidth;
                height = iconHeight;
            }

            if (animations.length > 1 && animations != null)
                isAnimated = true;

            if (!isAnimated)
            {   
                loadGraphic(file); //Load stupidly first for getting the file size
                loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
                animation.add(char, [0, 1], 0, false, isPlayer);
                animation.play(char);

                iconOffsets[0] = (width - 150) / 2;
                iconOffsets[1] = (width - 150) / 2;
            }

            else 
            {
                if (animations != null && animations.length > 1)
                {
                    animation.addByPrefix('idle', animations[0], animations[2], false);
                    animation.addByPrefix('die', animations[1], animations[2], false);
                    animation.play('idle');
                }
            }

			updateHitbox();

			this.char = char;

            if (forceAntialiasing == null)
            {
                antialiasing = ClientPrefs.globalAntialiasing;

                if (char.endsWith('-pixel')) 
                {
                    antialiasing = false;
                }
            }

            else
            {
                if (forceAntialiasing[0])
                {
                    antialiasing = forceAntialiasing[1];
                }
            }
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();

        if (!isAnimated)
        {
		    offset.x = iconOffsets[0];
		    offset.y = iconOffsets[1];
        }
	}

	public function getCharacter():String 
    {
		return char;
	}

    //causes crashes if the values are not reset
    public function resetValues()
    {
        animations = null;
        iconWidth = 150;
        iconHeight = 150;
        forceAntialiasing = null;
        isAnimated = false;
    }

    public function getValue(path:String, value:String):Any
    {
        return Reflect.getProperty(Json.parse(File.getContent(path)), value);
    }
}