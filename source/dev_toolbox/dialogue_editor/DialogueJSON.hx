typedef DialogueJSON = {
    var chars:Array<DialogueChar>;
    var dialogue:Array<DialogueBubble>;
};

typedef DialogueBubble = {
    var bubblePath:String;
    var bubbleAnim:String;
    var loud:Bool;
    var char:String;
    var position:Int;
}

typedef DialogueChar = {
    var sprite:String;
    var name:String;
    var offset:Point;
    var scale:Point;
}

typedef Point = {
    var x:Float;
    var y:Float;
}