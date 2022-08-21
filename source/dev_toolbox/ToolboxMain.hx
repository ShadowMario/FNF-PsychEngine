package dev_toolbox;

import sys.FileSystem;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxSpriteGroup;

using StringTools;

class ToolboxMain extends MusicBeatState {

    public var modButtons = new FlxSpriteGroup();
    public var scrollY:Float = 0;
    public var card:ModCard;
    public var selectedMod:String = null;
    public var editModButton:FlxUIButton;
    public var deleteButton:FlxUIButton;
    public var emptyCardBG:FlxSprite;
    public function new() {
        super();

    }

    public override function create() {
        super.create();
        var bg = CoolUtil.addBG(this);
        
        var i = 0;
        for(k=>m in ModSupport.modConfig) {
            if (m.locked != true) {
                var button = new FlxUIButton(0, i * 50, ModSupport.getModName(k), function() {
                    selectedMod = k;
                    card.updateMod(k);
                });
                button.resize(300, 50);
                button.label.alignment = LEFT;
                button.label.offset.x = -50; // weird flixel stuff
                
                var modIcon = new FlxSprite(5, (i * 50) + 5);
                if (Assets.exists(Paths.file('modIcon.png', 'mods/$k'))) {
                    modIcon.loadGraphic(Paths.file('modIcon.png', 'mods/$k'));
                } else {
                    modIcon.loadGraphic(Paths.image('modEmptyIcon'));
                }
                modIcon.setGraphicSize(40, 40);
                modIcon.updateHitbox();
                modIcon.scale.set(Math.min(modIcon.scale.x, modIcon.scale.y), Math.min(modIcon.scale.x, modIcon.scale.y));

                modButtons.add(button);
                modButtons.add(modIcon);

                i++;
            }
        }

        add(modButtons);
        modButtons.x = (FlxG.width - 300 - modButtons.width) / 2 - 175;
        if (CoolUtil.isDevMode()) {
            card = new ModCard(selectedMod = Settings.engineSettings.data.selectedMod, ModSupport.modConfig[selectedMod]);
        } else {
            card = new ModCard("Friday Night Funkin'", ModSupport.modConfig["Friday Night Funkin'"]);
            
        }
        card.screenCenter(Y);
        card.x = 300 + ((FlxG.width - 300 - card.width) / 2) + 5;
        add(card);

        emptyCardBG = new FlxSprite(card.x, card.y).loadGraphic(Paths.image("modcardbg", "preload"));
        emptyCardBG.antialiasing = true;
        add(emptyCardBG);

        var closeButton = new FlxUIButton(card.x + card.width - 45, card.y + 15, "X", function() {
            FlxG.switchState(new MainMenuState());
        });
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.resize(30, 30);
        closeButton.label.size = Std.int(closeButton.label.size * 1.5);
        closeButton.offset.y = -2;
        add(closeButton);

        editModButton = new FlxUIButton(card.x + card.width - 140 - 30, card.y + card.height + 10, "Edit", function() {
            if (selectedMod != null) {
                Settings.engineSettings.data.selectedMod = ToolboxHome.selectedMod = selectedMod;
                FlxG.switchState(new ToolboxHome(selectedMod));
            }
        });
        editModButton.color = 0xFFFFC02D;
        editModButton.resize(140, 30);
        editModButton.label.y = editModButton.y + ((editModButton.height - editModButton.label.height) / 2) - 8;
        editModButton.label.color = 0xFF000000;

        var editModButtonIcon = new FlxSprite(editModButton.x + 7, editModButton.y + 7);
        CoolUtil.loadUIStuff(editModButtonIcon);
        editModButtonIcon.animation.play("edit");

        add(editModButton);
        add(editModButtonIcon);

        var createModButton = new FlxUIButton(editModButton.x - 150, card.y + card.height + 10, "Create a new mod", function() {
            FlxG.switchState(new NewModWizard());
        });
        createModButton.color = 0xFF44FF44;
        createModButton.resize(140, 30);
        createModButton.label.y = createModButton.y + ((createModButton.height - createModButton.label.height) / 2) - 8;
        createModButton.label.color = 0xFF000000;

        var createModButtonIcon = new FlxSprite(createModButton.x + 7, createModButton.y + 7);
        CoolUtil.loadUIStuff(createModButtonIcon);
        createModButtonIcon.animation.play("add");

        add(createModButton);
        add(createModButtonIcon);

        deleteButton = new FlxUIButton(createModButtonIcon.x - 50, card.y + card.height + 10, "", function() {
            if (selectedMod.trim() == "") return;
            var mName = ModSupport.modConfig[selectedMod].name;
            if (mName == null || mName == "") mName = selectedMod;
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
        deleteButton.resize(30, 30);
        deleteButton.color = 0xFFFF4444;
        
        var deleteButtonIcon = new FlxSprite(deleteButton.x + 7, deleteButton.y + 7);
        CoolUtil.loadUIStuff(deleteButtonIcon);
        deleteButtonIcon.animation.play("delete");
        add(deleteButton);
        add(deleteButtonIcon);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK) FlxG.switchState(new MainMenuState());

        if (FlxG.mouse.getPosition().x < 465) scrollY = FlxMath.bound(scrollY + (FlxG.mouse.wheel * 50), Math.min(0, -(modButtons.height - FlxG.height)), 0);
        if (modButtons.height < FlxG.height) {
            modButtons.screenCenter(Y);
        } else {
            modButtons.y = FlxMath.lerp(modButtons.y, scrollY, 0.25 * elapsed * 60);
        }
        deleteButton.alpha = editModButton.alpha = (deleteButton.active = editModButton.active = (selectedMod != null)) ? 1 : 0.5;
        emptyCardBG.visible = !(card.visible = selectedMod != null);
    }
}