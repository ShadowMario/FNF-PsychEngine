package;

import flixel.FlxSprite;
import haxe.Json;
import haxe.Exception;
import openfl.utils.Assets as OpenFlAssets;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef HealthIconFile = {
    var forceAntialiasing:Null<Bool>;
    var offsets:Array<Null<Float>>;
    var animations:Array<Dynamic>;
    var width:Int;
    var height:Int;
}

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
    public var iconFile:HealthIconFile;
    public var animated:Bool;
    var forcingAntialiasing:Bool;
	var isOldIcon:Bool = false;
	var isPlayer:Bool = false;
	var char:String = '';
    var iconOffsets:Array<Float> = [0, 0];
    var offsets:Array<Null<Float>>;

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

	public function changeIcon(char:String) 
    {
        iconFile = null;

        #if MODS_ALLOWED
        iconFile = castIconFile(char);
        #end

		if (this.char != char) 
        {
			var name:String = 'icons/' + char;

			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) 
                name = 'icons/icon-' + char; //Older versions of psych engine's support

			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
                name = 'icons/icon-face'; //Prevents crash from missing icon

            #if MODS_ALLOWED
            if (iconFile != null && iconFile.animations != null && iconFile.animations.length > 1)
                animated = true;

            if (iconFile != null)
            {
                width = iconFile.width;
                height = iconFile.height;
                offsets = iconFile.offsets;

                forcingAntialiasing = (iconFile.forceAntialiasing);
            }
            #end

            if (!animated)
            {
                var file = Paths.image(name);
                loadGraphic(file); //Load stupidly first for getting the file size
                loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
                iconOffsets[0] = (width - 150) / 2;
                iconOffsets[1] = (width - 150) / 2;
                updateHitbox();

                animation.add(char, [0, 1], 0, false, isPlayer);
                animation.play(char);
            }

            #if MODS_ALLOWED
            else if (iconFile != null)
            {
                frames = Paths.getSparrowAtlas('icons/$char');
                animation.addByPrefix('idle', iconFile.animations[0][0], iconFile.animations[0][1]);
                animation.addByPrefix('dead', iconFile.animations[1][0], iconFile.animations[1][1]);
                playAnim('idle', true);
            }
            #end

            this.char = char;

            if (!forcingAntialiasing)
            {
                antialiasing = ClientPrefs.globalAntialiasing;

                if (char.endsWith('-pixel')) 
                    antialiasing = false;
            }

            #if MODS_ALLOWED
            else
                antialiasing = true;
            #end
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();

        if (!animated)
        {
		    offset.x = iconOffsets[0];
		    offset.y = iconOffsets[1];
        }
	}

	public function getCharacter():String
		return char;

    public function castIconFile(?char:String = 'bf'):HealthIconFile
    {
        #if MODS_ALLOWED
        var path:String = Paths.getPreloadPath('images/icons/icon-$char.json');
        var modPath:String = Paths.modFolders('images/icons/icon-$char.json');
        
        if (FileSystem.exists(path) || FileSystem.exists(modPath))
        {
            trace('found file!');

            if (FileSystem.exists(modPath))
                path = modPath;

            var file:HealthIconFile = cast Json.parse(File.getContent(path));
            return file;
        }

        return null;
        #else
        throw new Exception('Extended Icons do not support HTML5!');
        #end
    }

    
    #if MODS_ALLOWED
    public function playAnim(name:String, force:Bool = false)
    {
        animation.play(name, force);
        offset.set(offsets[0], offsets[1]);
    }
    #end
}