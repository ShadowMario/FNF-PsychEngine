package mod_support_stuff;

import openfl.geom.Rectangle;
import flixel.ui.FlxBar;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIText;
import flixel.FlxSubState;

typedef Option = {
    var label:String;
    var callback:Void->Void;
    @:optional var enabled:Bool;
}

class ContextMenu extends MusicBeatSubstate {
    var options:Array<{label:FlxUIText, callback:Void->Void, enabled:Bool}> = [];
    var bg:FlxSprite;
    var curSelected(default, set):Int = -1;
    function set_curSelected(v:Int):Int {
        if (v != curSelected) {
            selectorThing.x = bg.x + 2;
            selectorThing.y = bg.y + 2 + (v * 20);
            selectorThing.value = 0;
        }
        return curSelected = v;
    }
    var selectorThing:FlxBar;
    public function new(x:Float, y:Float, options:Array<Option>) {
        super();
        FlxG.state.persistentUpdate = true;

        for(i=>option in options) {
            var label = new FlxUIText(x + 4, y + 4 + ((i + 0.5) * 20), 0, option.label);
            label.y -= label.height / 2;
            label.scrollFactor.set(0, 0);
            add(label);
            var enabled = true;
            if (option.enabled != null) enabled = option.enabled;
            label.color = enabled ? FlxColor.WHITE : 0xFFBBBBBB;
            this.options.push({label: label, callback: option.callback, enabled: enabled});
        }
        var w:Int = 75;
        for(o in this.options)
            if (o.label.width > w)
                w = Std.int(o.label.width);
        bg = new FlxSprite(x, y).makeGraphic(w + 8, (options.length * 20) + 8, 0xFF000000);
        bg.pixels.lock();
        bg.pixels.fillRect(new Rectangle(1, 1, bg.pixels.width - 2, bg.pixels.height - 2), 0xFFD1D1D1);
        bg.pixels.fillRect(new Rectangle(2, 2, bg.pixels.width - 4, bg.pixels.height - 4), 0xFF8C8C8C);
        bg.scrollFactor.set(0, 0);
        bg.pixels.unlock();

        selectorThing = new FlxBar(x + 2, y + 2, LEFT_TO_RIGHT, w + 4, 20);
        selectorThing.createGradientBar([0], [0xFF510568, 0xFF160977]);
        selectorThing.setRange(0, 100);
        selectorThing.scrollFactor.set(0, 0);
        insert(0, selectorThing);
        insert(0, bg);
    }

    public override function update(elapsed:Float) {
        if (FlxG.mouse.overlaps(bg)) { // nice bg
            var y = FlxG.mouse.y - FlxG.camera.scroll.y - bg.y;
            curSelected = FlxMath.wrap(Std.int(y / 20), 0, options.length - 1);
            if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(selectorThing)) {
                select();
            }
            // prevents event diffusion
            @:privateAccess
            FlxG.mouse._leftButton.current = RELEASED;
            @:privateAccess
            FlxG.mouse._middleButton.current = RELEASED;
            @:privateAccess
            FlxG.mouse._rightButton.current = RELEASED;
        } else {
            if (FlxG.mouse.justPressed || controls.BACK) {
                FlxG.state.persistentUpdate = false;
                close();
            }
            if (controls.ACCEPT) {
                select();
            }
        }
        selectorThing.value = FlxMath.lerp(selectorThing.value, selectorThing.max, CoolUtil.wrapFloat(0.5 * 60 * elapsed, 0, 1));
        super.update(elapsed);
        // prevents event diffusion
        @:privateAccess
        FlxG.mouse._leftButton.current = RELEASED;
        @:privateAccess
        FlxG.mouse._middleButton.current = RELEASED;
        @:privateAccess
        FlxG.mouse._rightButton.current = RELEASED;
    }

    public function select() {
        var option = options[curSelected];
        if (option.enabled) {
            option.callback();
            close();
        }
    }
}