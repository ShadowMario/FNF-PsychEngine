import flixel.addons.transition.FlxTransitionableState;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.FlxG;

class WideScreenScale extends BaseScaleMode
{
    public var width(default, set):Int = 1280;
    public var height(default, set):Int = 720;
    public var isWidescreen(get, set):Bool;

    private function set_width(v:Int) {
        width = v;
        @:privateAccess
        FlxG.game.onResize(null);
        return width;
    }
    private function set_height(v:Int) {
        height = v;
        @:privateAccess
        FlxG.game.onResize(null);
        return height;
    }
    private function set_isWidescreen(v:Bool) {
        return FlxG.widescreen = v;
    }
    private function get_isWidescreen() {
        return FlxG.widescreen;
    }
	public function new()
	{
		super();
	}

	override function updateGameSize(Width:Int, Height:Int):Void
    {
        @:privateAccess
        FlxG.width = width;
        @:privateAccess
        FlxG.height = height;
        
        var ratio:Float = width / height;
        var realRatio:Float = Width / Height;

        var scaleY:Bool = realRatio < ratio;
        if (scaleY)
        {
            gameSize.x = Width;
            gameSize.y = Math.floor(gameSize.x / ratio);
        }
        else
        {
            gameSize.y = Height;
            gameSize.x = Math.floor(gameSize.y * ratio);
        }
        updatePlayStateHUD(width, height);

        FlxTransitionableState.defaultTransOut.region.width = FlxTransitionableState.defaultTransIn.region.width = FlxG.width;
        FlxTransitionableState.defaultTransOut.region.height = FlxTransitionableState.defaultTransIn.region.height = FlxG.height;
    }

    public static function updatePlayStateHUD(width:Int = 1280, height:Int = 720) {
        FlxG.camera.width = FlxG.width;
        FlxG.camera.height = FlxG.height;
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
        if (PlayState.current != null) {
            if (PlayState.current.camHUD != null) {
                PlayState.current.camHUD.width = Std.int(FlxG.width);
                PlayState.current.camHUD.height = Std.int(FlxG.height);
                PlayState.current.camHUD.x = PlayState.current.camHUD.y = 0;
                PlayState.current.camHUD.follow(PlayState.current.camFollowHud, LOCKON, 1);
            }
            if (PlayState.current.camGame != null) {
                PlayState.current.camGame.width = FlxG.width;
                PlayState.current.camGame.height = FlxG.height;
            }
        }
        if (FlxG.camera.target != null) FlxG.camera.follow(FlxG.camera.target, LOCKON, FlxG.camera.followLerp);
    }

    override function updateGamePosition():Void
    {
        super.updateGamePosition();
        updatePlayStateHUD();
    }

    public function setSize(width:Int, height:Int) {
        this.width = width;
        this.height = height;
    }
}