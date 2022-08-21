package dev_toolbox;

import Discord.DiscordClient;
import flixel.util.FlxCollision;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import sys.FileSystem;
import flixel.FlxSprite;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import flixel.addons.ui.*;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class ToolboxMain extends MusicBeatState {
    var modName:FlxUIText = null;
    var modDesc:FlxUIText = null;
    var modIcon:FlxSprite = null;
    var selectButton:FlxUIButton = null;

    var nonEditableMods:Array<String> = ["Friday Night Funkin'", "YoshiCrafterEngine"];

    var selectedMod:String = "";

    public override function new(?mod:String) {
        #if desktop
            Discord.DiscordClient.changePresence("In the Toolbox's Mod Selection Screen...", null, "Toolbox Icon");
        #end
        if (mod != null) selectedMod = mod;
        if (!Std.isOfType(FlxG.state, MainMenuState) && !Std.isOfType(FlxG.state, ToolboxHome)) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
        }
        super();
        CoolUtil.addBG(this);
        var tabs = [
			{name: "main", label: 'Select a mod...'}
		];
        var UI_Main = new FlxUITabMenu(null, tabs, true);
        UI_Main.resize((FlxG.width / 2), 282);
        UI_Main.screenCenter();
        add(UI_Main);

        
		var tab = new FlxUI(null, UI_Main);
		tab.name = "main";
        
		var label = new FlxUIText(10, 10, 620, "Select a mod to begin, or click on \"Create a new mod\".");

        selectButton = new FlxUIButton(10, 232, "Edit mod...", function() {
            if (selectedMod.trim() == "") return;
            FlxG.switchState(new ToolboxHome(selectedMod));
        });
        var closeButton = new FlxUIButton(UI_Main.x + UI_Main.width - 23, UI_Main.y + 3, "X", function() {
            FlxG.switchState(new MainMenuState());
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        add(closeButton);
        var createButton = new FlxUIButton(selectButton.x + selectButton.width + 10, 232, "Create a new mod", function() {
            FlxG.switchState(new NewModWizard());
        });
        createButton.resize(140, 20);
        var deleteMod = new FlxUIButton(createButton.x + createButton.width + 10, 232, "Delete this mod", function() {
            if (selectedMod.trim() == "") return;
            var mName = ModSupport.modConfig[selectedMod].name;
            if (mName == null || mName == "") mName = selectedMod;
            if (nonEditableMods.contains(selectedMod)) {
                openSubState(ToolboxMessage.showMessage("Error", '$mName is an essential mod since the engine relies on it. It can\'t be deleted.\r\nAnd if you\'re curious, deleting it would result in an engine crash.'));
                return;
            }
            openSubState(new ToolboxMessage("Delete a mod", 'Are you sure you want to delete $mName ? This operation cannot be cancelled.', 
            [
                {
                    label: "Yes",
                    onClick: function(t) {
                        try {
                            CoolUtil.deleteFolder('${Paths.modsPath}/$selectedMod');
                            FileSystem.deleteDirectory('${Paths.modsPath}/$selectedMod');
                            ModSupport.reloadModsConfig();
                            openSubState(new ToolboxMessage("Success", '$selectedMod was successfully deleted.', [
                                {
                                    label: "OK",
                                    onClick: function(t) {
                                        FlxG.resetState();
                                    }
                                }
                            ]));
                        } catch(e) {
                            openSubState(ToolboxMessage.showMessage("Error", 'Couldn\'t delete $selectedMod.'));
                        }
                    }
                },
                {
                    label: "No",
                    onClick: function(t) {}
                }
            ]
            ));
        });
        deleteMod.resize(100, 20);
        deleteMod.color = 0xFFFF4444;
        deleteMod.label.color = FlxColor.WHITE;

        modName = new FlxUIText(10, label.y + label.height + 10, 620);
        modName.size *= 2;
        modName.text = "Select a mod...";

        modIcon = new FlxUISprite(10, modName.y + modName.height + 10);
        modIcon.antialiasing = true;

        var mods:Array<StrNameLabel> = [];
        var it = ModSupport.modConfig.keys();
        while (it.hasNext()) {
            var k = it.next();
            if (k == null || k == "null") continue;
            var mName = ModSupport.modConfig[k].name;
            if (mName == null || mName == "") mName = k;
            #if toolboxBypass
            mods.push(new StrNameLabel(k, mName));
            #else
            if (ModSupport.modConfig[k].locked != true) // if false or null
                mods.push(new StrNameLabel(k, mName));
            #end
        }

        modDesc = new FlxUIText(170, modName.y + modName.height + 10, 460, "");
        if (mods.length == 0) {
            modName.text = "No mod projects";
            modDesc.text = "Go ahead and create one using the \"Create a new mod\" button.";
            modIcon.loadGraphic(Paths.image("modEmptyIcon", "preload"));
            modIcon.setGraphicSize(150, 150);
            modIcon.updateHitbox();
            modIcon.scale.set(Math.min(modIcon.scale.x, modIcon.scale.y), Math.min(modIcon.scale.x, modIcon.scale.y));
            
            createButton.x = selectButton.x;
            tab.add(createButton);
            tab.add(modName);
            tab.add(modDesc);
            tab.add(modIcon);
        } else {
            var modDropDown = new FlxUIDropDownMenu(630, 10, mods, function(label:String) {
                selectedMod = label;
                updateModData();
            }, new FlxUIDropDownHeader(250));
            modDropDown.x -= modDropDown.width;
            tab.add(modDropDown);
            updateModData();

            tab.add(label);
            tab.add(selectButton);
            tab.add(createButton);
            tab.add(deleteMod);
            tab.add(modName);
            tab.add(modDesc);
            tab.add(modIcon);
        }

        

	
		UI_Main.addGroup(tab);
    }

    public function updateModData() {
        if (selectedMod.trim() == "") {
            modName.text = "No selected mod";
            modDesc.text = "";
            modIcon.loadGraphic(Paths.image("modEmptyIcon", "preload"));
            modIcon.setGraphicSize(150, 150);
            modIcon.updateHitbox();
            modIcon.scale.set(Math.min(modIcon.scale.x, modIcon.scale.y), Math.min(modIcon.scale.x, modIcon.scale.y));
            selectButton.color = FlxColor.GRAY;
        } else {
            modName.text = ModSupport.modConfig[selectedMod].name != null ? ModSupport.modConfig[selectedMod].name : selectedMod;
            modDesc.text = ModSupport.modConfig[selectedMod].description != null ? ModSupport.modConfig[selectedMod].description : "(No description)";
            if (FileSystem.exists('${Paths.modsPath}/$selectedMod/modIcon.png')) {
                modIcon.loadGraphic(Paths.getBitmapOutsideAssets('${Paths.modsPath}/$selectedMod/modIcon.png')); // wtf???
            } else {
                modIcon.loadGraphic(Paths.image("modEmptyIcon", "preload"));
            }
            modIcon.setGraphicSize(150, 150);
            modIcon.updateHitbox();
            modIcon.scale.set(Math.min(modIcon.scale.x, modIcon.scale.y), Math.min(modIcon.scale.x, modIcon.scale.y));
            
            selectButton.color = FlxColor.WHITE;
        }
        
    }
}