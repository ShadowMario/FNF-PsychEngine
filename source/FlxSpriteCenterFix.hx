import flixel.FlxObject;
import flixel.util.FlxAxes;

class FlxSpriteCenterFix {
    public static function cameraCenter(f:FlxObject, ?axes:FlxAxes):FlxObject
    {
        if (axes == null)
            axes = FlxAxes.XY;

        if (axes != FlxAxes.Y)
            f.x = (f.camera.width / 2) - (f.width / 2);
        if (axes != FlxAxes.X)
            f.y = (f.camera.height / 2) - (f.height / 2);

        return f;
    }
    public static function hudCenter(f:FlxObject, ?axes:FlxAxes):FlxObject
    {
        if (PlayState.current == null) return f;
        if (axes == null)
            axes = FlxAxes.XY;

        if (axes != FlxAxes.Y)
            f.x = (PlayState.current.guiSize.x / 2) - (f.width / 2);
        if (axes != FlxAxes.X)
            f.y = (PlayState.current.guiSize.y / 2) - (f.height / 2);

        return f;
    }
}