package charter;

import haxe.io.Path;
import dev_toolbox.file_explorer.FileExplorer;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.*;
import flixel.*;

using StringTools;

class ScriptPicker extends MusicBeatSubstate {
    public var scripts:Array<String> = [];
    public var elements:Array<FlxSprite> = [];

    public var UI:FlxUITabMenu;
    public var tab:FlxUI;
    public var buttonY:Float = 0;


    public var helpTexts:Array<String> = [
        "Click on the \"Add Script\" button at the bottom of this window to add a script, or remove added scripts by clicking the bin button next to the script names. Please note that this list and the one from the \"Edit Song Scripts\" have different values. While this one only applies on this specific chart, the other list applies on every difficulty of the song. Scripts will add up, which means if a script is on both lists, it's going to be run twice.",
        "Click on the \"Add Script\" button at the bottom of this window to add a script, or remove added scripts by clicking the bin button next to the script names. Please note that this list and the one from the \"Edit Chart Scripts\" have different values. While this one applies on every difficulty of the song, the other list only applies on this specific chart. Scripts will add up, which means if a script is on both lists, it's going to be run twice."
    ];
    public function new(callback:Array<String>->Void, ?scripts:Array<String>, ?label:String = "Edit Scripts", ?helpText:Int = 0) {
        super();
        if (scripts == null) scripts = [];
        for(s in scripts) this.scripts.push(s);

        var bg:FlxSprite;
        (bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000)).scrollFactor.set();
        add(bg);

        UI = new FlxUITabMenu(null, [
            {
                name: "scripts",
                label: label
            }
        ], true);
        UI.scrollFactor.set();
        UI.resize(400, FlxG.height - 100);
        UI.screenCenter();
        add(UI);

        tab = new FlxUI(null, UI);
        tab.name = "scripts";

        var label = new FlxUIText(10, 10, 380, helpTexts[helpText]);
        buttonY = label.y + label.height + 10;
        tab.add(label);

        tab.add(new FlxSprite(10, buttonY).loadGraphic(FlxGridOverlay.createGrid(380, 20, 380, 480, true, 0xFFA0A0A0, 0xFF7A7A7A)));

        var addScriptButton = new FlxUIButton(10, FlxG.height - 150, "Add Script", function() {
            openSubState(new FileExplorer(PlayState.songMod, FileExplorerType.Script, "", function(path) {
                this.scripts.push('${PlayState.songMod}:${Path.withoutExtension(path)}');
                refreshElements();
            }));
        });

        var clearScriptsButton = new FlxUIButton(addScriptButton.x + addScriptButton.width + 10, addScriptButton.y, "Clear Scripts", function() {
            while(this.scripts.length > 0) this.scripts.pop();
            refreshElements();
        });

        var addManualScript = new FlxUIButton(clearScriptsButton.x + clearScriptsButton.width + 10, addScriptButton.y, "Add Script Manually", function() {
            openSubState(new EnterTextScreen(function(text) {
                if (text.trim() != "") {
                    this.scripts.push(text);
                    refreshElements();
                }
            }, "", "Enter a script", "Add Script"));
        });
        addManualScript.resize(110, 20);
        

        var saveButton = new FlxUIButton(390 - clearScriptsButton.width, clearScriptsButton.y, "Save", function() {
            close();
            callback(this.scripts);
        });
        saveButton.color = 0xFF44FF44;
        saveButton.label.setFormat(null, 8, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF268F26);

        tab.add(addScriptButton);
        tab.add(clearScriptsButton);
        tab.add(addManualScript);
        tab.add(saveButton);
        UI.addGroup(tab);

        var closeButton = new FlxUIButton(UI.x + UI.width - 20, UI.y, "X", function() {
            close();
        });
        closeButton.resize(20, 20);
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.color = 0xFFFF4444;
        closeButton.scrollFactor.set();
        add(closeButton);

        refreshElements();
    }

    public function clearElements() {
        for(e in elements) {
            tab.remove(e);
            remove(e);
            e.destroy();
        }
        elements = [];
    }

    public function refreshElements() {
        clearElements();
        for(i=>s in scripts) {
            var button = new FlxUIButton(370, buttonY + (20 * i), "", function() {
                scripts.remove(s);
                refreshElements();
            });
            button.resize(20, 20);
            button.color = 0xFFFF4444;
            var buttonImage = new FlxSprite(button.x + 2, button.y + 2);
            CoolUtil.loadUIStuff(buttonImage, "delete");

            var label = new FlxUIText(10, buttonY + (20 * (i + 0.5)), 340, s);
            label.y -= label.height / 2;
            for(e in [label, button, buttonImage]) {
                tab.add(e);
                elements.push(e);
            }
        }
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);
    }
}