package;

import mod_support_stuff.CharacterSkin;

typedef ModConfig = {
    var name:String;
    var locked:Null<Bool>;
    var description:String;
    var titleBarName:String;
    var skinnableBFs:Array<String>;
    var skinnableGFs:Array<String>;
    var BFskins:Array<CharacterSkin>;
    var GFskins:Array<CharacterSkin>;
    var keyNumbers:Array<Int>;
    var intro:ConfIntro;
    @:optional var gameWidth:Null<Int>;
    @:optional var gameHeight:Null<Int>;
    @:optional var discordRpc:String;
    @:optional var hasFlashingLights:Null<Bool>;
}

typedef ConfIntro = {
    var bpm:Null<Int>;
    var authors:Array<String>;
    var assoc:Array<String>;
    var newgrounds:String;
    var present:String;
    var gameName:Array<String>;
}