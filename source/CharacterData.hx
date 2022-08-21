import flixel.math.FlxPoint;
import flixel.util.FlxColor;



/**
* JSON support, unused for now
*/
typedef CharacterData = {
    public var color:FlxColor;
    public var flipX:Bool;
    public var pixel:Bool;
    public var globalOffset:FlxPoint;
    public var anims:Array<CharacterAnims>;
    public var animsIndices:Array<CharacterAnims>;
    public var idleDanceSteps:Array<String>;
    public var emotes:Array<String>;
}

typedef CharacterAnims = {
    public var name:String;
    public var anim:String;
    public var framerate:Int;
    public var x:Int;
    public var y:Int;
    public var loop:Bool;
    public var animPrefixKeys:Array<Int>;
}