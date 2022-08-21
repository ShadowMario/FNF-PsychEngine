package mod_support_stuff;

import MainMenuState.MainMenuItemAlignment;
import flixel.util.FlxColor;

typedef MainMenuJson = {
    var options:Array<MainMenuOption>;
    var flickerColor:String;
    var alignment:MainMenuItemAlignment;
    var bgScroll:Null<Bool>;
    var autoPos:Null<Bool>;
    var autoCamPos:Null<Bool>;
    var defaultBehaviour:Null<Bool>;
}

typedef MainMenuOption = {
    var name:String;
    var image:String;
    var staticAnim:String;
    var selectedAnim:String;
    var instant:Bool;
    var callback:String;
    var devModeOnly:Bool;
}