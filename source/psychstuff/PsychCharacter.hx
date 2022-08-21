package psychstuff;

typedef PsychCharacter = {
    var scale:Null<Float>;
    var sing_duration:Null<Float>;
    var camera_position:Null<Array<Float>>;
    var healthbar_colors:Null<Array<Int>>;
    var flip_x:Bool;
    var healthicon:Null<String>;
    var position:Null<Array<Int>>;
    var no_antialiasing:Bool; // this is confusing
    var animations:Array<PsychCharAnim>;
    var image:String;
}

typedef PsychCharAnim = {
    var loop:Bool;
    var offsets:Array<Float>;
    var anim:String;
    var name:String;
    var indices:Array<Int>;
    var fps:Null<Int>;
}