package dev_toolbox;

import openfl.display.PNGEncoderOptions;
import flixel.addons.transition.FlxTransitionableState;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.addons.ui.*;
import flixel.FlxSprite;

using StringTools;

class CharacterCreator extends MusicBeatSubstate {
    public override function new() {
        super();
        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        add(bg);

        var tabs = [
            {name: "char", label: 'Create a character'}
		];
        var UI_Tabs = new FlxUITabMenu(null, tabs, true);
        UI_Tabs.x = 0;
        UI_Tabs.resize(420, FlxG.height);
        UI_Tabs.scrollFactor.set();
        add(UI_Tabs);

		var tab = new FlxUI(null, UI_Tabs);
		tab.name = "char";

		var label = new FlxUIText(10, 10, 400, "Character name");
        var char_name = new FlxUIInputText(10, label.y + label.height, 400, "your-char");
        tab.add(label);
        tab.add(char_name);

		var label = new FlxUIText(10, char_name.y + char_name.height + 10, 400, "Character Icon");
        var char_icon:BitmapData = null;
        var icon_path_button:FlxUIButton = null;
        icon_path_button = new FlxUIButton(10, label.y + label.height, "Browse...", function() {
            CoolUtil.openDialogue(OPEN, "Select your character's icon grid.", function(path) {
                char_icon = BitmapData.fromFile(path);
                if (char_icon == null) {
                    icon_path_button.color = 0xFFFF2222;
                    icon_path_button.label.text = "(Browse...) File couldn't be opened.";
                    return;
                }
                var res = Math.floor(char_icon.width / 150) * Math.floor(char_icon.height / 150);
                if (res < 1) {
                    icon_path_button.color = 0xFFFF2222;
                    icon_path_button.label.text = "(Browse...) The 150x150 grid must have 1 sprite or more.";
                    return;
                }
                icon_path_button.color = 0xFF22FF22;
                icon_path_button.label.text = '(Browse...) $res icons loaded.';
            });
        });
        icon_path_button.resize(400, 20);
        tab.add(label);
        tab.add(icon_path_button);

		var label = new FlxUIText(10, icon_path_button.y + icon_path_button.height + 10, 400, "Character Spritesheet (Sparrow / Packer)");
        var char_spritesheet:String = null;
        var spritesheet_path_button:FlxUIButton = null;
		
		var usesJson = false;
        spritesheet_path_button = new FlxUIButton(10, label.y + label.height, "Browse...", function() {
            CoolUtil.openDialogue(OPEN, "Select your character's spritesheet.png or spritesheet.xml/json.", function(path) {
                var areFilesThere = [false, false];
                char_spritesheet = "";
				usesJson = false;
                if (Path.extension(path) == "xml") {
                    areFilesThere[1] = true;
                    if (FileSystem.exists(Path.withoutExtension(path) + ".png")) {
                        areFilesThere[0] = true;
                    }
                } else if (Path.extension(path) == "json") {
                    areFilesThere[1] = true;
					usesJson = true;
                    if (FileSystem.exists(Path.withoutExtension(path) + ".png")) {
                        areFilesThere[0] = true;
                    }
                } else if (Path.extension(path) == "png") {
                    areFilesThere[0] = true;
                    if (FileSystem.exists(Path.withoutExtension(path) + ".xml")) {
                        areFilesThere[1] = true;
                    }
					if (FileSystem.exists(Path.withoutExtension(path) + ".json")) {
						areFilesThere[1] = true;
						usesJson = true;
					}
                } else {
                    spritesheet_path_button.color = 0xFFFF2222;
                    spritesheet_path_button.label.text = "(Browse...) Selected file isn't of type JSON, XML or PNG.";
                    return;
                }

                if (!areFilesThere[0]) {
                    spritesheet_path_button.color = 0xFFFF2222;
                    spritesheet_path_button.label.text = "(Browse...) PNG file is missing.";
                    return;
                }
                if (!areFilesThere[1]) {
                    spritesheet_path_button.color = 0xFFFF2222;
                    spritesheet_path_button.label.text = "(Browse...) JSON/XML file is missing.";
                    return;
                }
                var bMap = BitmapData.fromFile(Path.withoutExtension(path) + ".png");
                if (bMap == null) {
                    spritesheet_path_button.color = 0xFFFF2222;
                    spritesheet_path_button.label.text = '(Browse...) PNG file is invalid.';
                    return;
                }
                bMap.dispose();
                char_spritesheet = Path.withoutExtension(path);
                spritesheet_path_button.color = 0xFF22FF22;
                spritesheet_path_button.label.text = '(Browse...) Spritesheet selected.';
            });
        });
        spritesheet_path_button.resize(400, 20);
        tab.add(label);
        tab.add(spritesheet_path_button);
        
        var createButton:FlxUIButton = null;
        createButton = new FlxUIButton(10, spritesheet_path_button.y + spritesheet_path_button.height + 10, "Create", function() {
            var charName = Toolbox.generateModFolderName(char_name.text);
            if (FileSystem.exists('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/$charName')) {
                createButton.color = 0xFFFF2222;
                createButton.label.text = "(Create) Character with this name already exists.";
                return;
            }
            if (char_icon == null) {
                createButton.color = 0xFFFF2222;
                createButton.label.text = icon_path_button.color == 0xFFFF2222 ? "(Create) Icon Grid is invalid." : "(Create) Character's icon grid haven't been selected yet.";
                return;
            }
            if (char_spritesheet == null || char_spritesheet.trim() == "") {
                createButton.color = 0xFFFF2222;
                createButton.label.text = spritesheet_path_button.color == 0xFFFF2222 ? "(Create) Spritesheet is invalid." : "(Create) Character's Spritesheet haven't been selected yet.";
                return;
            }
            FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/$charName');
            var averageColor:FlxColor = CoolUtil.getMostPresentColor(char_icon);
            var json:CharacterJSON = {
                anims: [],
                globalOffset: {
                    x: 0,
                    y: 0
                },
                camOffset: {
                    x: 0,
                    y: 0
                },
                antialiasing: true,
                scale: 1,
                danceSteps: ["idle"],
                healthIconSteps: [[20, 0], [0, 1]],
                healthbarColor: averageColor.toWebString(),
                arrowColors: null,
                flipX: false
            };
            var folder = '${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/$charName';
            if (ToolboxHome.selectedMod == "~") folder = '${Paths.getSkinsPath()}/$charName';
            File.saveContent('$folder/Character.json', Json.stringify(json, "\t"));
            File.copy(char_spritesheet + (usesJson ? ".json" : ".xml"), '$folder/spritesheet.' + (usesJson ? "json" : "xml"));
            File.copy(char_spritesheet + ".png", '$folder/spritesheet.png');
            var characterHX = 'function create() {\r\n\tcharacter.frames = Paths.getCharacter(character.curCharacter);\r\n\tcharacter.loadJSON(true);\r\n}';
            File.saveContent('$folder/Character.hx', characterHX);
            File.saveBytes('$folder/icon.png', char_icon.encode(char_icon.rect, new PNGEncoderOptions(true)));

            openSubState(ToolboxMessage.showMessage("Success", "Character successfully created.", function() {
                close();
                FlxTransitionableState.skipNextTransIn = true;
                FlxTransitionableState.skipNextTransOut = true;
                FlxG.resetState();
            }));
        });
        createButton.resize(400, 20);
        tab.add(createButton);

        UI_Tabs.addGroup(tab);
        UI_Tabs.resize(420, 30 + createButton.y + createButton.height);
        UI_Tabs.screenCenter();

        var closeButton = new FlxUIButton(UI_Tabs.x + UI_Tabs.width - 23, UI_Tabs.y + 3, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        add(closeButton);
    }
}