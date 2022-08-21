package dev_toolbox.stage_editor;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.addons.ui.*;

using StringTools;

class StageCreator extends MusicBeatSubstate {
    public override function new() {
        super();

        add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000));
        var window = new FlxUITabMenu(null, [
            {
                name: "stage",
                label: "Create a Stage"
            }
        ], true);

        var tab = new FlxUI(null, window);
        tab.name = "stage";

        var label:FlxUIText = new FlxUIText(10, 10, 480, "Stage JSON name");
        var stageName:FlxUIInputText = new FlxUIInputText(10, label.y + label.height, 480, "your-stage");

        var warning = new FlxUIText(10, stageName.y + stageName.height + 10, 480, "A script will be automatically created that'll load your stage. You can add it to whatever song you want by adding the stage's script into the song configuration, to load your stage in.");

        var addButton = new FlxUIButton(250, warning.y + warning.height + 10, "Create", function() {
            var name = stageName.text.trim();
            var path = '${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${name}';
            if (name == "") {
                showMessage('Error', 'You need to type a name.');
                return;
            }
            if (FileSystem.exists(path)) {
                showMessage('Error', 'A stage with this name already exists.');
                return;
            }
            
            File.saveContent('$path.json', Json.stringify(Templates.stageTemplate, "\t"));
            File.saveContent('$path.hx', 'var stage:Stage = null;
function create() {
	stage = loadStage(\'{0}\');
}
function update(elapsed) {
	stage.update(elapsed);
}
function beatHit(curBeat) {
	stage.onBeat();
}'.replace('{0}', name));

            close();
            FlxG.switchState(new StageEditor(name));
        });
        addButton.x -= addButton.width / 2;

        


        tab.add(label);
        tab.add(stageName);
        tab.add(warning);
        tab.add(addButton);

        window.addGroup(tab);
        window.resize(500, addButton.y + addButton.height + 10);
        window.screenCenter();
        add(window);
        var closeButton = new FlxUIButton(window.x + window.width - 20, window.y, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = FlxColor.WHITE;
        closeButton.resize(20, 20);
        add(closeButton);
    }
}