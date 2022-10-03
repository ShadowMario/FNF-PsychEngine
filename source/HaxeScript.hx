package;

import flixel.*;
import flixel.math.*;
import flixel.util.*;

class HaxeScript extends SScript
{
    public function new(file:String, ?preset:Bool = true)
    {
        super(file, preset);
    }

    override public function preset():Void
    {
        super.preset();

        interp.variables.set('FlxSprite', FlxSprite);
        interp.variables.set('FlxObject', FlxObject);
        //interp.variables.set('FlxColor', FlxColor);
        interp.variables.set('FlxMath', FlxMath);
    }
}
