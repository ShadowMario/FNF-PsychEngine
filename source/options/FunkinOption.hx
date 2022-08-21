package options;

import options.OptionSprite;

typedef FunkinOption = {
    var name:String;
    var desc:String;
    var value:String;

    @:optional var onUpdate:OptionSprite->Void;
    @:optional var onCreate:OptionSprite->Void;
    @:optional var onSelect:OptionSprite->Void;
    @:optional var onEnter:OptionSprite->Void;
    @:optional var onLeft:OptionSprite->Void;

    @:optional var img:String;
    @:optional var additional:Bool;
}