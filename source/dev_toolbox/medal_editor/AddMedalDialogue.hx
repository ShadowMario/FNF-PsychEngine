package dev_toolbox.medal_editor;

import dev_toolbox.file_explorer.FileExplorer;
import flixel.addons.ui.FlxUIButton;
import lime.utils.Assets;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxSprite;
import haxe.io.Path;

using StringTools;

class AddMedalDialogue extends MusicBeatSubstate {
    var __name:String;
    var __buttonLabel:String;
    var __callback:MedalsJSON.Medal->Void;
    var medal:MedalsJSON.Medal;
    var img:FlxSprite;
    var animField:FlxUIInputText;
    public override function new(medal:MedalsJSON.Medal, callback:MedalsJSON.Medal->Void, ?windowName:String = "Edit Medal", ?buttonLabel:String = "Edit") {
        __name = windowName;
        __buttonLabel = buttonLabel;
        __callback = callback;
        this.medal = medal;
        if (this.medal == null) this.medal = {
            name: "Medal Name",
            desc: "Medal Description",
            img: null
        };
        if (this.medal.img == null) this.medal.img = {
            src: '',
            anim: '',
            fps: 24
        }
        super();
    }

    public override function create() {
        super.create();

        var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        bg.scrollFactor.set();
        add(bg);
        var UI_Tabs = new FlxUITabMenu(null, 
            [
                {
                    name: 'window',
                    label: __name
                }
            ], true);
        var tab = new FlxUI(null, UI_Tabs);
        tab.name = "window";
        UI_Tabs.scrollFactor.set();

        var medalNameLabel:FlxUIText = new FlxUIText(10, 10, 0, "Medal Name");
        var medalName:FlxUIInputText = new FlxUIInputText(10, medalNameLabel.y + medalNameLabel.height, Std.int(FlxG.width / 2 - 20), medal.name);
        
        img = new FlxSprite(10, medalName.y + medalName.height + 10);
        img.antialiasing = true;
        updateImg();


        var changeImgButton = new FlxUIButton(10, medalName.y + medalName.height + 120, "Change Icon", function() {
            openSubState(new FileExplorer(ToolboxHome.selectedMod, Bitmap, '', function(p) {
                var path = p.toLowerCase();
                while(path.charAt(0) == "/") path = path.substr(1);
                if (path.startsWith("images/")) {
                    medal.img.src = Path.withoutExtension(path.substr(7));
                    updateImg();
                } else {
                    openSubState(ToolboxMessage.showMessage('Error', 'File must be in the "images" folder.'));
                }
            }, 'Select a bitmap or a Sparrow spritesheet.'));
        });
        changeImgButton.resize(100, 20);

        var descriptionFieldLabel = new FlxUIText(120, medalName.y + medalName.height + 10, 0, "Medal Description");
        var descriptionField = new FlxUIInputText(120, descriptionFieldLabel.y + descriptionFieldLabel.height, Std.int(FlxG.width / 2) - 130, medal.desc);

        var animFieldLabel:FlxUIText = new FlxUIText(120, descriptionField.y + descriptionField.height + 10, 0, "Animation Name");
        animField = new FlxUIInputText(120, animFieldLabel.y + animFieldLabel.height, Std.int(FlxG.width / 2) - 130, medal.img.anim);

        var validateButton = new FlxUIButton((FlxG.width / 2) - 20, changeImgButton.y, __buttonLabel, function() {
            medal.name = medalName.text;
            medal.desc = descriptionField.text;
            medal.img.anim = animField.text;
            if (__callback != null)
                __callback(medal);
            close();
        });
        validateButton.color = 0xFF44FF44;
        validateButton.label.color = 0xFF000000;
        validateButton.x -= validateButton.width;
        tab.add(medalNameLabel);
        tab.add(medalName);
        tab.add(img);
        tab.add(changeImgButton);
        tab.add(descriptionFieldLabel);
        tab.add(descriptionField);
        tab.add(animFieldLabel);
        tab.add(animField);
        tab.add(validateButton);

        UI_Tabs.resize(FlxG.width / 2, validateButton.y + validateButton.height + 30);
        UI_Tabs.addGroup(tab);
        UI_Tabs.screenCenter();
        add(UI_Tabs);

        var closeButton = new FlxUIButton(UI_Tabs.x + UI_Tabs.width - 20, UI_Tabs.y, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.resize(20, 20);
        add(closeButton);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (medal.img.anim != (medal.img.anim = animField.text)) {
            img.animation.addByPrefix('anim', medal.img.anim, medal.img.fps, true);
            if (img.animation.getByName('anim') != null) img.animation.play('anim');
        }
    }
    
    function updateImg() {
        if (medal.img != null && Assets.exists(Paths.file('images/${medal.img.src}.png', TEXT, 'mods/${ToolboxHome.selectedMod}'))) {
            if (Assets.exists(Paths.file('images/${medal.img.src}.xml', TEXT, 'mods/${ToolboxHome.selectedMod}'))) {
                img.frames = Paths.getSparrowAtlas(medal.img.src, 'mods/${ToolboxHome.selectedMod}');
                img.animation.addByPrefix('anim', medal.img.anim, medal.img.fps, true);
                img.animation.play('anim');
            } else {
                img.loadGraphic(Paths.image(medal.img.src, 'mods/${ToolboxHome.selectedMod}'));
            }
        }
        img.setGraphicSize(100, 100);
        img.updateHitbox();
        var min = Math.min(img.scale.x, img.scale.y);
        img.scale.set(min, min);
    }
}