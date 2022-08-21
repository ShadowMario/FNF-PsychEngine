package charter;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.ui.*;

class RemoveNotesSubstate extends MusicBeatSubstate {
    var doShit:FlxUIButton;
    var goddamnSlider:FlxUISliderNew;
    var value:Float = 0;
    public override function create() {
        super.create();
        var bg = new FlxSprite();
        bg.makeGraphic(1, 1, 0xFF000000);
        bg.alpha = 0.5;
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        add(bg);
        var tabs:FlxUITabMenu = new FlxUITabMenu(null, [
            {
                name: "ui",
                label: "Remove notes"
            }
        ], true);
        var t = new FlxUI(null, tabs);
        t.name = "ui";
        
        var label:FlxUIText;
        t.add(label = new FlxUIText(10, 10, 620, "This menu will remove a certain percentage of notes from your chart. It affects every single note type. The slider below sets how much you want to remove, from 0% which will remove nothing, to 100% which will remove everything."));
        t.add(goddamnSlider = new FlxUISliderNew(label.x, label.y + label.height + 10, 620, 16, this, "value", 0, 1, "0%", "100%"));
        t.add(doShit = new FlxUIButton(320, goddamnSlider.y + goddamnSlider.height + 10, "Remove notes", function() {
            var state:YoshiCrafterCharter = cast FlxG.state;
            if (state != null) {
                var notesToRemove = [];
                state.notes.forEach(function(n) {
                    if (FlxG.random.bool(value * 100)) {
                        notesToRemove.push(n);
                    }
                });
                for(e in notesToRemove) {
                    state.notes.remove(e);
                    e.destroy();
                }
            }
            close();
        }));
        doShit.x -= doShit.width / 2;

        var h = Std.int(doShit.y + doShit.height + 30);
        if (h % 2 == 1) h++;
        tabs.resize(640, h);
        tabs.addGroup(t);
        tabs.screenCenter();
        tabs.scrollFactor.set();
        add(tabs);

        var closeButt = new FlxUIButton(tabs.x + tabs.width - 20, tabs.y, "X", function() {
            close();
        });
        closeButt.resize(20, 20);
        closeButt.color = 0xFFFF4444;
        closeButt.label.color = 0xFFFFFFFF;
        closeButt.scrollFactor.set();
        add(closeButt);
    }
}