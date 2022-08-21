typedef MedalsJSON = {
    var medals:Array<Medal>;
}

typedef Medal = {
    var name:String;
    var desc:String;
    var img:MedalImg;
}

typedef MedalImg = {
    var src:String;
    var anim:String;
    var fps:Null<Int>;
}