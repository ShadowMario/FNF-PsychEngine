package dev_toolbox;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.*;

class TextInput extends MusicBeatSubstate {
    public override function new(title:String, desc:String, text:String, callback:String->Void) {
        super();
        add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000));
        var tabUIThingy = new FlxUITabMenu(null, [
            {
                label: title,
                name: "window"
            }
        ], true);
        tabUIThingy.resize((FlxG.width / 2), 200);
        add(tabUIThingy);

        var tab = new FlxUI(null, tabUIThingy);
        tab.name = "window";

        var desc = new FlxUIText(10, 10, 620, desc);

        var inputField = new FlxUIInputText(10, desc.y + desc.height, 620, text);

        var confirmButton = new FlxUIButton(325, inputField.y + inputField.height + 10, "OK", function() {
            close();
            callback(inputField.text);
        });
        var cancelButton = new FlxUIButton(315, inputField.y + inputField.height + 10, "Cancel", function() {
            close();
        });
        cancelButton.x -= cancelButton.width;

        tab.add(desc);
        tab.add(inputField);
        tab.add(confirmButton);
        tab.add(cancelButton);

        tabUIThingy.resize((FlxG.width / 2), cancelButton.y + cancelButton.height + 30);
        tabUIThingy.screenCenter();

        tabUIThingy.addGroup(tab);
    }
}