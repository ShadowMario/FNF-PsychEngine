package dev_toolbox.toolbox_tabs;

import dev_toolbox.stage_editor.StageCreator;
import dev_toolbox.stage_editor.StageEditor;
import flixel.FlxG;
import flixel.addons.ui.*;
import haxe.io.Path;
import sys.FileSystem;

class StagesTab extends ToolboxTab {
    var stageList:Array<String> = [];
    var stageRadioList:FlxUIRadioGroup;
    var selectedStage:String = null;
    public function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "stages", home);
        // Creates a stages folder in case it doesn't exists.
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/');
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/images/');
        stageRadioList = new FlxUIRadioGroup(10, 10, stageList, stageList, function(stage) {
            selectedStage = stage;
        });
        updateRadioList();
        var selectStageButton = new FlxUIButton((FlxG.width / 2) + 5, FlxG.height - y - 10, "Edit", function() {
            if (selectedStage != null) {
                StageEditor.fromFreeplay = false;
                FlxG.switchState(new StageEditor(selectedStage));
            }
        });
        selectStageButton.y -= selectStageButton.height;
        // selectStageButton.screenCenter(X);

        var createStageButton = new FlxUIButton((FlxG.width / 2) - 5, FlxG.height - y - 10, "Create", function() {
            home.openSubState(new StageCreator());
        });
        createStageButton.x -= createStageButton.width;
        createStageButton.y -= createStageButton.height;
        // createStageButton.screenCenter(X);


        add(stageRadioList);
        add(selectStageButton);
        add(createStageButton);
    }

    function updateRadioList() {
        stageList = [];
        for(f in FileSystem.readDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/')) {
            var exts = ['json', 'stage'];
            if (exts.contains(Path.extension(f).toLowerCase())) {
                // is a json stage
                stageList.push(Path.withoutExtension(f));
            }
        }
        stageRadioList.updateRadios(stageList, stageList);
        stageRadioList.screenCenter(X);
    }
    public override function tabUpdate(elapsed) {
        super.tabUpdate(elapsed);

    }
}