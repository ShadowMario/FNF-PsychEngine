package dev_toolbox.file_explorer;

import flixel.FlxG;
import flixel.FlxSprite;
import dev_toolbox.file_explorer.FileExplorer.FileExplorerIcon;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.*;

class FileExplorerElement extends FlxSpriteGroup {
    var icon:FlxSprite;
    var selectionThingy:FlxSprite;
    var text:FlxUIText;
    var selected:Bool = false;
    var callback:Void->Void;

    public function select(select:Bool = true) {
        selected = select;
        if (select) {
            icon.color = 0xFF88B8FF;
        } else {
            icon.color = 0xFFFFFFFF;
        }
        selectionThingy.visible = select;
    }
    public override function new(fileName:String, fileIcon:FileExplorerIcon, callback:Void->Void, selectionThingyWidth:Null<Int> = null) {
        super();
        icon = new FlxSprite(0, 0);
        icon.loadGraphic(Paths.image("fileIcons", "preload"), true, 16, 16);
        icon.animation.add("icon", [cast(fileIcon, Int)], 0, false);
        icon.animation.play("icon");

        text = new FlxUIText(20, 0, 256, fileName);
        text.y = icon.y + (icon.height / 2) - (text.height / 2);

        selectionThingy = new FlxSprite(0, 0).makeGraphic(selectionThingyWidth != null ? selectionThingyWidth : Std.int(22 + text.width), 16, 0xFF88B8FF);

        add(selectionThingy);
        add(icon);
        add(text);

        this.callback = callback;
    }

    public override function update(elapsed) {
        super.update(elapsed);
        if (FlxG.mouse.justReleased) {
            var screenPos = FlxG.mouse.getScreenPosition(FlxG.camera);
            if (screenPos.x > x && screenPos.x < selectionThingy.x + selectionThingy.width
             && screenPos.y > y && screenPos.y < y + 16) {
                if (selected) {
                    if (callback != null) callback();
                } else {
                    select(true);
                }
             } else {
                select(false);
             }
        }
        selectionThingy.visible = selected;
    }
}