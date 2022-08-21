package dev_toolbox;

typedef CharacterJSON = {
    var anims:Array<CharacterAnim>;
    var globalOffset:CharacterPosition;
    var camOffset:CharacterPosition;
    var antialiasing:Bool;
    var scale:Float;
    var danceSteps:Array<String>;
    var healthIconSteps:Array<Array<Int>>;
    var flipX:Bool;
    var healthbarColor:String;
    var arrowColors:Array<String>;
}

typedef CharacterPosition = {
    var x:Float;
    var y:Float;
}
typedef CharacterAnim = {
    var name:String;
    var anim:String;
    var framerate:Int;
    var x:Float;
    var y:Float;
    var loop:Bool;
    var indices:Array<Int>;
}