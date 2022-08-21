package dev_toolbox.character_editor;

import openfl.desktop.ClipboardTransferMode;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import dev_toolbox.CharacterJSON.CharacterAnim;
import flixel.FlxG;
import flixel.addons.ui.*;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;

using StringTools;

class NewAnimDialogue extends MusicBeatSubstate {
    public override function new() {
        super();
        var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        bg.scrollFactor.set();
        add(bg);
        var UI_Tabs = new FlxUITabMenu(null, 
            [
                {
                    name: 'test',
                    label: "Add an animation"
                }
            ], true );
        var tab = new FlxUI(null, UI_Tabs);
        tab.name = "test";
        UI_Tabs.resize(320, 400);
        UI_Tabs.scrollFactor.set();
        add(UI_Tabs);

        

		var label = new FlxUIText(10, 10, 300, "Anim name (ex : idle, singUP)");
        var animName = new FlxUIInputText(10, label.y + label.height, 300, "");
        tab.add(label);
        tab.add(animName);
        
		var label = new FlxUIText(10, animName.y + animName.height + 10, 300, "Anim name on spritesheet (ex : \"bf idle dance\", \"bf sing up\")");
        var animSparrow = new FlxUIInputText(10, label.y + label.height, 240, "");
        tab.add(label);
        tab.add(animSparrow);
        var pasteButton = new FlxUIButton(animSparrow.x + animSparrow.width + 10, animSparrow.y, "Paste", function() {
            var data = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_ONLY);
            if (data != null) {
                animSparrow.text = data.toString();
            }
        });
        pasteButton.resize(50, 20);
        tab.add(pasteButton);

        var addButton = new FlxUIButton(110, animSparrow.y + animSparrow.height + 10, "Add", function() {
            if (animName.text.trim() == "") {
                var mes = ToolboxMessage.showMessage("Error", "You must specify an animation name (ex : 'idle' or 'singUP')");
                mes.cameras = cameras;
                openSubState(mes);
                return;
            }
            if (animSparrow.text.trim() == "") {
                var mes = ToolboxMessage.showMessage("Error", "You must specify the Sparrow atlas animation name (the name of the animation in Adobe Animate)");
                mes.cameras = cameras;
                openSubState(mes);
                return;
            }
                if (CharacterEditor.current.character.animation.getByName(animName.text) != null) {
                    var mes = ToolboxMessage.showMessage("Error", 'The ${animName.text} animation already exists.');
                    mes.cameras = cameras;
                    openSubState(mes);
                    return;
                }
            if (CharacterEditor.current.addAnim(animName.text, animSparrow.text)) {
                close();
            } else {
                var mes = ToolboxMessage.showMessage("Error", '"${animName.text}" animation couldn\'t be added because "${animSparrow.text}"\'s animation doesn\'t exists.');
                mes.cameras = cameras;
                openSubState(mes);
                return;
            }
        });
        tab.add(addButton);

        UI_Tabs.resize(320, addButton.y + addButton.height + 30);
        UI_Tabs.screenCenter();

        var closeButton = new FlxUIButton(UI_Tabs.x + UI_Tabs.width - 23, UI_Tabs.y + 3, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        closeButton.scrollFactor.set();
        add(closeButton);

        UI_Tabs.addGroup(tab);
    }
}