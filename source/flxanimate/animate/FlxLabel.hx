package flxanimate.animate;

import flixel.FlxG;

class FlxLabel
{
    public var frame(default, null):Int;

    public var name(default, null):String;

    public var callbacks(default, null):Array<Void->Void>;

    public function new(name:String, frame:Int)
    {
        this.name = name;
        this.frame = frame;
        callbacks = [];
    }
    public function fireCallbacks()
    {
        for (callback in callbacks)
        {
            callback();
        }
    }
    @:allow(flxanimate.animate.FlxSymbol)
    function removeCallbacks()
    {
        callbacks = [];
    }
    public function toString():String
    {
        return '(frame: $frame || callbacks: $callbacks)';
    }
}