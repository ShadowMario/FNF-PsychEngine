import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;

class MainMenuOptions extends FlxTypedGroup<MainMenuItem> {
    public var curSelected:Int = -1;
    override public function draw():Void
    {
        var i:Int = 0;
        var basic:FlxBasic = null;

        @:privateAccess
        var oldDefaultCameras = FlxCamera._defaultCameras;
        if (cameras != null)
        {
            @:privateAccess
            FlxCamera._defaultCameras = cameras;
        }

        while (i < length)
        {
            if (i == curSelected) {
                i++;
                continue;
            }
            basic = members[i++];
            if (basic != null && basic.exists && basic.visible)
            {
                basic.draw();
            }
        }

        if ((basic = members[curSelected]) != null) {
            
            if (basic != null && basic.exists && basic.visible)
            {
                basic.draw(); // will draw the selected one on top of every other one
            }
        }
        @:privateAccess
        FlxCamera._defaultCameras = oldDefaultCameras;
    }
}