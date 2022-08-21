package dev_toolbox.toolbox_tabs;

import flixel.FlxBasic;
import flixel.math.FlxRect;
import openfl.geom.Rectangle;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.file_explorer.FileExplorer;
import openfl.display.BitmapData;
import flixel.tweens.FlxTween;
using StringTools;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.*;
import haxe.Json;
import sys.io.File;
import flixel.text.FlxText;
import flixel.FlxSprite;
import sys.FileSystem;
import flixel.group.FlxSpriteGroup;

class CharTab extends ToolboxTab {
    public var character:Character = null;
    public var danceTime:Float = 0;
    public var legend:FlxUIText;
    public var anims_text:FlxUIText;
    public var previewButton:FlxUIButton;

    public var anims:Array<String> = [];
    public var selectedAnim:Int = 0;

    public var selectedCharIndex:Int = 0;
    public var chars:Array<String> = [];

    public var charSprites:FlxSpriteGroup = new FlxSpriteGroup();

    public override function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "chars", home);

        
        var bg = new FlxSprite(0, 0).makeGraphic(320, Std.int(FlxG.height - y), 0xFF8C8C8C);
        bg.pixels.lock();
        bg.pixels.fillRect(new openfl.geom.Rectangle(318, 0, 1, Std.int(FlxG.height - y)), 0xFF4C4C4C);
        bg.pixels.fillRect(new openfl.geom.Rectangle(319, 0, 1, Std.int(FlxG.height - y)), 0xFF000000);
        bg.pixels.unlock();
        add(bg);
        
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters');
        var chars =[
            for(folder in FileSystem.readDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters'))
                if (FileSystem.isDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/$folder'))
                    folder
        ];
        var buttons:Array<FlxUIButton> = [];
        
        for(k=>c in chars) {
            var b:FlxUIButton = null;
            b = new FlxUIButton(10, (k * 50), c, function() {
                selectedCharIndex = k;
                for(e in buttons)
                    if (e.label.text.startsWith("> "))
                        e.label.text = e.label.text.substr(2, e.label.text.length - 4);
                b.label.text = '> $c <';
            });
            b.resize(290, 50);
            b.label.alignment = LEFT;
            b.label.offset.x -= 50;


            buttons.push(b);

            var healthIcon:HealthIcon = new HealthIcon('${ToolboxHome.selectedMod}:$c');
            healthIcon.scale.set(40 / 150, 40 / 150);
            healthIcon.updateHitbox();
            healthIcon.health = 0.5;
            healthIcon.x = b.x + 25 - (healthIcon.width / 2);
            healthIcon.y = b.y + 25 - (healthIcon.height / 2);
            charSprites.add(b);
            charSprites.add(healthIcon);
        }
        
        add(charSprites);
        var charLayer = 0;
        previewButton = new FlxUIButton(10, 670, "Preview", function() {
            if (selectedCharIndex < 0) return;
            if (character != null) {
                remove(character);
                character.destroy();
            }
            character = new Character(0, 0, CoolUtil.getCharacterFullString(chars[selectedCharIndex], ToolboxHome.selectedMod));
            insert(charLayer, character);
            character.screenCenter(Y);
            character.x = 320 + ((FlxG.width - 320) / 2) - (character.width / 2);
            character.setPosition(character.x - character.camOffset.x, character.y - character.camOffset.y);
            anims = [];
            @:privateAccess
            var it = character.animation._animations.keys();
            while (it.hasNext()) {
                var v = it.next();
                if (v.trim() != "") anims.push(v);
            }
            anims.sort(function(a, b) {return (a.toUpperCase() < b.toUpperCase()) ? -1 : ((a.toUpperCase() > b.toUpperCase()) ? 1 : 0);});
        });
        previewButton.resize(67, 20);
        add(previewButton);
        var createButton = new FlxUIButton(previewButton.x + previewButton.width + 10, 670, "Create", function() {
            state.openSubState(new CharacterCreator());
        });
        createButton.resize(67, 20);
        var editButton = new FlxUIButton(createButton.x + createButton.width + 10, 670, "Edit", function() {
            if (selectedCharIndex < 0) {
                state.openSubState(ToolboxMessage.showMessage("Error", "No character was selected."));
                return;
            }
            dev_toolbox.character_editor.CharacterEditor.fromFreeplay = false;
            FlxG.switchState(new dev_toolbox.character_editor.CharacterEditor(chars[selectedCharIndex]));
        });
        editButton.resize(67, 20);
        var deleteButton = new FlxUIButton(editButton.x + editButton.width + 10, 670, "Delete", function() {
            if (selectedCharIndex < 0) {
                state.openSubState(ToolboxMessage.showMessage("Error", "No character was selected."));
                return;
            }
            state.openSubState(new ToolboxMessage("Delete Character", 'Are you sure you want to delete ${chars[selectedCharIndex]} ? This operation is irreversible.', [
                {
                    label: "Yes",
                    onClick: function(t) {
                        CoolUtil.deleteFolder('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/${chars[selectedCharIndex]}/');
                        FileSystem.deleteDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/${chars[selectedCharIndex]}/');
                        state.openSubState(ToolboxMessage.showMessage("Success", '${chars[selectedCharIndex]} was successfully deleted.', function() {
                            FlxTransitionableState.skipNextTransIn = true;
                            FlxTransitionableState.skipNextTransOut = true;
                            FlxG.resetState();
                        }));
                    }
                },
                {
                    label: "No",
                    onClick: function(t) {}
                }
            ]));
        });
        deleteButton.resize(67, 20);
        add(createButton);
        add(editButton);
        add(deleteButton);
        legend = new FlxUIText(330, 666, FlxG.width - 330, "[Up/Down] Change animation | [Space] Play Animation | [Enter] Flip");
        legend.size = 20;
        legend.color = FlxColor.BLACK;
        add(legend);

        anims_text = new FlxUIText(330, 0, FlxG.width - 330, "");
        anims_text.size = 12;
        anims_text.color = FlxColor.BLACK;
        add(anims_text);

        charLayer = 1;

        scrollY += y;
    }

    var scrollY:Float = 50;

    public override function tabUpdate(elapsed:Float) {
        scrollY += FlxG.mouse.wheel * 50;
        scrollY = FlxMath.bound(scrollY, Math.min(-(charSprites.height - 645), 0), 50);
        charSprites.y = FlxMath.lerp(charSprites.y, scrollY, 0.25 * elapsed * 60);
        var clip:FlxSprite->Void;
        clip = function(m) {
            var y = FlxMath.bound(m.y + ((m.height - m.frameHeight) / 3 * m.scale.y), 0, m.height);
            var y2 = FlxMath.bound(m.y + ((m.height - m.frameHeight) / 3 * m.scale.y - 615), 0, m.height);
            m.clipRect = new FlxRect(
                0,
                (m.height - y) / m.height * m.frameHeight, 
                m.frameWidth, 
                (m.height - y2) / m.height * m.frameHeight);
            if (Std.isOfType(m, FlxUIButton)) {
                var butt = cast(m, FlxUIButton);
                butt.active = butt.label.visible = (butt.clipRect.y < 0.5 * m.frameHeight) && (butt.clipRect.height > 0.5 * m.frameHeight);
            }
        }
        charSprites.forEach(clip, false);
        if (character == null) {
            anims_text.text = "Select a character...";
            return;
        }
        var t = (selectedAnim == 0 ? "> " : "") + "Dance animation";
        for (k=>e in anims) {
            if (k == selectedAnim - 1) {
                t += '\n> ${anims[k]}';
            } else {
                t += '\n${anims[k]}';
            }
        }
        anims_text.text = t;
        if (FlxControls.justPressed.UP) {
            selectedAnim--;
        }
        if (FlxControls.justPressed.DOWN) {
            selectedAnim++;
        }
        if (FlxControls.justPressed.ENTER) {
            character.flipX = !character.flipX;
        }
        if (selectedAnim > anims.length) selectedAnim = 0;
        if (selectedAnim < 0) selectedAnim = anims.length;
        if (selectedAnim == 0) {
            danceTime += elapsed;
            if (danceTime > 0.5) {
                danceTime = danceTime % 0.5;
                if (character != null) {
                    character.lastNoteHitTime = -500;
                    character.dance();
                }
            }
        } else {
            if (character.animation.curAnim == null || character.animation.curAnim.name != anims[selectedAnim - 1]) {
                character.playAnim(anims[selectedAnim - 1]);
            }
        }

        if (FlxControls.justPressed.SPACE && selectedAnim > 0) {
            character.playAnim(anims[selectedAnim - 1], true);
        }
    }
}