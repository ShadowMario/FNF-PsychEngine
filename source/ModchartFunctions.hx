package;

import flixel.FlxG;
import openfl.*;

class ModchartFunctions {
    public static function camZoom(width:Int, height:Int)
    {
        FlxG.resizeGame(width, height);
    }
    public static function moveWindow(x:Int, y:Int)
    {
        Lib.application.window.move(x, y);
    }
}