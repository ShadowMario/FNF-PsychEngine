package charter;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.*;

class EnterTextScreen extends FlxUISubState {
    var callback:String->Void = null;
    var label:String = "";
    var okButtonLabel:String = "";
    var defaultText:String = "";
    public override function new(callback:String->Void, ?defaultText:String = "", ?label:String = "Type in something", ?okButtonLabel:String = "OK") {
        super();
        this.callback = callback;
        this.label = label;
        this.okButtonLabel = okButtonLabel;
        this.defaultText = defaultText;
    }
    public override function create() {
        super.create();
        var bg:FlxSprite;
        add(bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000));
        bg.scrollFactor.set();
        
        var ui = new FlxUITabMenu(null, [
            {
                name: "tab",
                label: label
            }
        ], true);

        add(ui);
        
        var tab = new FlxUI(null, ui);
        tab.name = "tab";

        
        var textInput = new FlxUIInputText(10, 10, 380, defaultText);
        var okButton = new FlxUIButton(200, textInput.y + textInput.height + 10, okButtonLabel, function() {
            var text = textInput.text;
            close();
            if (callback != null) callback(text);
        });
        var h = okButton.y + okButton.height + 30;
        okButton.x -= okButton.width / 2;
        tab.add(textInput);
        tab.add(okButton);
        ui.resize(400, Std.int(h / 2) * 2);
        ui.addGroup(tab);
        ui.scrollFactor.set();
        ui.screenCenter();

        var closeButton = new FlxUIButton(ui.x + ui.width - 20, ui.y, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.scrollFactor.set();
        closeButton.resize(20, 20);
        add(closeButton);
    }
}