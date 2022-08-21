package dev_toolbox.toolbox_tabs;

import sys.io.File;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxSpriteGroup;
import dev_toolbox.medal_editor.AddMedalDialogue;
import haxe.Json;

class MedalsTab extends ToolboxTab {
    public var medals:FlxSpriteGroup = new FlxSpriteGroup();

    public function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "medals", home);
        
        refreshMedals();

        add(medals);
    }

    public function refreshMedals() {
        for(m in medals.members) {
            m.destroy();
        }
        medals.clear();
        var medals = ModSupport.modMedals[ToolboxHome.selectedMod];
        if (medals == null) medals = {medals: []};
        if (medals.medals == null) medals.medals = [];
        for(k=>m in medals.medals) {
            var button = new FlxUIButton(10, 10 + (50 * k), m.name, function() {
                FlxG.state.openSubState(new AddMedalDialogue(m, function(m) {
                    refreshMedals();
                    save();
                }, "Edit Medal", "Save"));
            });
            button.resize(350, 50);
            button.label.alignment = LEFT;
            button.label.offset.x = -50;
            button.x = (FlxG.width - button.width) / 2;

            var img = new FlxSprite(button.x + 5, button.y + 5);
            if (m.img != null) {
                if (Assets.exists(Paths.file('images/${m.img.src}.xml', TEXT, 'mods/${ToolboxHome.selectedMod}'))) {
                    img.frames = Paths.getSparrowAtlas(m.img.src, 'mods/${ToolboxHome.selectedMod}');
                    img.animation.addByPrefix('anim', m.img.anim, m.img.fps, true);
                    img.animation.play('anim');
                } else {
                    img.loadGraphic(Paths.image(m.img.src, 'mods/${ToolboxHome.selectedMod}'));
                }
            }
            img.setGraphicSize(40, 40);
            img.updateHitbox();
            var min = Math.min(img.scale.x, img.scale.y);
            img.scale.set(min, min);
            img.antialiasing = true;

            var deleteButton = new FlxUIButton(button.x + button.width, button.y, "", function() {
                medals.medals.remove(m);
                refreshMedals();
                save();
            });
            deleteButton.color = 0xFFFF4444;
            deleteButton.resize(20, 50);
            
            var deleteIcon = new FlxSprite(deleteButton.x + ((deleteButton.width - 16) / 2), deleteButton.y + ((deleteButton.height - 16) / 2));
            CoolUtil.loadUIStuff(deleteIcon);
            deleteIcon.animation.play("delete");

            this.medals.add(button);
            this.medals.add(img);
            this.medals.add(deleteButton);
            this.medals.add(deleteIcon);
        }
        var addMedalButton = new FlxUIButton((FlxG.width - 350) / 2, 10 + (50 * medals.medals.length), "", function() {
            FlxG.state.openSubState(new AddMedalDialogue(null, function(m) {
                ModSupport.modMedals[ToolboxHome.selectedMod].medals.push(m);
                refreshMedals();
                save();
            }, "Create a new Medal", "Create"));
        });
        addMedalButton.resize(350, 20);
        addMedalButton.color = 0xFF44FF44;

        var addIcon = new FlxSprite(addMedalButton.x + ((addMedalButton.width - 16) / 2), addMedalButton.y + ((addMedalButton.height - 16) / 2));
        CoolUtil.loadUIStuff(addIcon);
        addIcon.animation.play("add");
        this.medals.add(addMedalButton);
        this.medals.add(addIcon);

    }

    function save() {
        var d = ModSupport.modMedals[ToolboxHome.selectedMod];
        var p = '${Paths.modsPath}/${ToolboxHome.selectedMod}/medals.json';
        try {
            File.saveContent(p, Json.stringify(d));
        } catch(e) {
            LogsOverlay.error(e.details());
            FlxG.state.openSubState(ToolboxMessage.showMessage('Error', 'An error occured while saving the medals. Check the F6 logs for more info.'));
        }
    }
    public override function onTabExit() {}
    public override function onTabEnter() {}
}