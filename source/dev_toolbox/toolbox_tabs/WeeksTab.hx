package dev_toolbox.toolbox_tabs;

import dev_toolbox.week_editor.WeekEditor;
import haxe.io.Path;
import lime.utils.Assets;
import flixel.group.FlxSpriteGroup;
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
import WeeksJson.FNFWeek;
import sys.FileSystem;


class WeeksTab extends ToolboxTab {
    public var weekJson:WeeksJson;
    public var buttons:FlxSpriteGroup;

    public function refreshWeeks() {
        for(e in buttons.members) {
            e.destroy();
        }
        buttons.clear();

        for(k=>e in weekJson.weeks) {
            var button = new FlxUIButton(0, k * 50, e.name, function() {
                save();
                WeekEditor.fromStory = false;
                FlxG.switchState(new WeekEditor(k));
            });
            button.resize(FlxG.width / 2, 50);
            button.label.alignment = LEFT;
            button.label.offset.x -= 200;
            button.screenCenter(X);

            var image = new FlxUISprite(button.x + 10, button.y + 10);
            var p = Paths.image(Path.withoutExtension(e.buttonSprite.startsWith("images/") ? e.buttonSprite.substr(7) : e.buttonSprite));
            if (Assets.exists(p)) {
                image.loadGraphic(p);
            }
                
            image.color = 0xFF222222;
            image.setGraphicSize(180, 30);
            image.antialiasing = true;
            image.updateHitbox();
            
            var minScale = Math.min(image.scale.x, image.scale.y);
            image.scale.set(minScale, minScale);

            var deleteButton = new FlxUIButton(button.x + button.width, button.y, function() {
                weekJson.weeks.remove(e);
                refreshWeeks();
            });
            deleteButton.resize(20, 50);
            deleteButton.color = 0xFFFF4444;

            var icon = CoolUtil.createUISprite("delete", deleteButton);

            var upButton = new FlxUIButton(button.x - 20, button.y, function() {
                weekJson.weeks.remove(e);
                weekJson.weeks.insert(k - 1, e);
                refreshWeeks();
            });
            var downButton = new FlxUIButton(button.x - 20, button.y + 25, function() {
                weekJson.weeks.remove(e);
                weekJson.weeks.insert(k + 1, e);
                refreshWeeks();
            });
            for(e in [upButton, downButton]) {
                e.color = 0xFF6FD0FF;
                e.resize(20, 25);
            }

            var upIcon = CoolUtil.createUISprite("up", upButton);
            var downIcon = CoolUtil.createUISprite("down", downButton);


            buttons.add(button);
            buttons.add(image);
            buttons.add(deleteButton);
            buttons.add(icon);

            buttons.add(upButton);
            buttons.add(downButton);
            buttons.add(upIcon);
            buttons.add(downIcon);
        }

        var addButton = new FlxUIButton(0, weekJson.weeks.length * 50, "", function() {
            weekJson.weeks.push({
                songs: [],
                selectSFX: null,
                name: "Your new week",
                buttonSprite: "storymenu/week1",
                bf: null,
                gf: null,
                dad: null,
                color: null,
                difficulties: null,
                bg: null,
                bgAnim: null
            });
            refreshWeeks();
        });
        addButton.color = 0xFF44FF44;
        addButton.resize(FlxG.width / 2, 20);
        addButton.screenCenter(X);

        var icon = CoolUtil.createUISprite("add", addButton);
        buttons.add(addButton);
        buttons.add(icon);
    }
    public override function destroy() {
        save();
        super.destroy();
    }
    public function save() {
        var weeksPath = '${Paths.modsPath}/${ToolboxHome.selectedMod}/weeks.json';
        File.saveContent(weeksPath, Json.stringify(weekJson));
    }
    public override function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "weeks", home);

        weekJson = {
            weeks: []
        };
        var weeksPath = '${Paths.modsPath}/${ToolboxHome.selectedMod}/weeks.json';
        if (FileSystem.exists(weeksPath)) {
            weekJson = Json.parse(File.getContent(weeksPath));
        } else {
            save();
        }
        if (weekJson == null) weekJson = {weeks: []};
        if (weekJson.weeks == null) weekJson.weeks = [];

        buttons = new FlxSpriteGroup();
        add(buttons);

        refreshWeeks();
    }
}