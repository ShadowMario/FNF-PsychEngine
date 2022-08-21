package charter;

import haxe.io.Path;
import flixel.math.FlxMath;
import dev_toolbox.stage_editor.StageEditor;
import sys.FileSystem;
import openfl.utils.Assets;
import flixel.*;
import flixel.addons.ui.*;
import flixel.group.FlxSpriteGroup;

class ChooseCharacterScreen extends MusicBeatSubstate {
    public var modsScroll:FlxSpriteGroup;
    public var charsScroll:FlxSpriteGroup;
    public var modsScrollY:Float = 0;
    public var charsScrollY:Float = 0;
    public var callback:String->String->Void;
    public function new(callback:String->String->Void) {
        super();
        this.callback = callback;
    }
    public override function create() {
        super.create();
        var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        bg.scrollFactor.set(0, 0);
        add(bg);
        modsScroll = new FlxSpriteGroup(0, 0);
        
        var i:Int = 0;
        for(k=>m in ModSupport.modConfig) {
            i++;
            var button = new FlxUIButton((FlxG.width / 2) - 300, 0 + (i * 50), ModSupport.getModName(k), function() {
                changeSecondMenu(k);
            });
            button.label.alignment = LEFT;
            button.label.offset.x = -50;
            button.resize(300, 50);
            var buttonIcon = new FlxSprite(button.x + 5, button.y + 5).loadGraphic(Paths.image('modEmptyIcon', 'preload'));
            if (Assets.exists(Paths.file('modIcon.png', IMAGE, 'mods/$k'))) {
                buttonIcon.loadGraphic(Paths.file('modIcon.png', IMAGE, 'mods/$k'));
            }
            
            buttonIcon.setGraphicSize(40, 40);
            buttonIcon.updateHitbox();
            buttonIcon.scale.set(Math.min(buttonIcon.scale.x, buttonIcon.scale.y), Math.min(buttonIcon.scale.x, buttonIcon.scale.y));
            var markThing = new FlxSprite(button.x + 273, button.y + 18).loadGraphic(FlxUIAssets.IMG_DROPDOWN_RIGHT);
            modsScroll.add(button);
            modsScroll.add(markThing);
            modsScroll.add(buttonIcon);
        }
        modsScroll.scrollFactor.set();
        add(modsScroll);
        charsScroll = new FlxSpriteGroup(0, 0);
        charsScroll.scrollFactor.set();
        add(charsScroll);
        changeSecondMenu("Friday Night Funkin'");

        if (Std.isOfType(FlxG.state, StageEditor)) {
            var state = cast(FlxG.state, StageEditor);
            modsScroll.cameras = [state.dummyHUDCamera, state.camHUD];
            charsScroll.cameras = [state.dummyHUDCamera, state.camHUD];
            bg.cameras = [state.dummyHUDCamera, state.camHUD];
        }

        var closeButton = new FlxUIButton(FlxG.width - 30, 5, "X", function() {
            close();
        });
        closeButton.label.size = Std.int(closeButton.label.size * 1.5);
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.color = 0xFFFF4444;
        closeButton.resize(25, 25);
        closeButton.scrollFactor.set();
        add(closeButton);
    }

    public function changeSecondMenu(mod:String) {
        for(m in charsScroll.members) {
            if (m == null) continue;
            m.destroy();
            charsScroll.remove(m);
            remove(m);
        }
        FileSystem.createDirectory('${Paths.modsPath}/$mod/characters/');
        var psychChar:Bool = false;
        for(i=>char in [for(e in FileSystem.readDirectory('${Paths.modsPath}/$mod/characters/')) if ((psychChar = Path.extension(e).toLowerCase() == "json") || FileSystem.isDirectory('${Paths.modsPath}/$mod/characters/$e')) psychChar ? Path.withoutExtension(e) : e]) {
            var button = new FlxUIButton(Std.int(FlxG.width / 2), 0 + ((i + 1) * 50), char, function() {
                close();
                if (callback != null) callback(mod, char);
            });
            button.label.alignment = LEFT;
            button.label.offset.x = -50;
            button.resize(300, 50);
            var healthIcon:HealthIcon = new HealthIcon('$mod:$char');
            healthIcon.scale.set(40 / 150, 40 / 150);
            healthIcon.updateHitbox();
            healthIcon.health = 0.5;
            healthIcon.x = button.x + 25 - (healthIcon.width / 2);
            healthIcon.y = button.y + 25 - (healthIcon.height / 2);
            charsScroll.add(button);
            charsScroll.add(healthIcon);
        }
        trace(mod);
        charsScroll.y = 0;
        charsScrollY = 0;
    }

    public override function update(elapsed:Float) {
        if (FlxG.mouse.overlaps(modsScroll)) {
            var maxY = -Math.max(modsScroll.height + 100 - FlxG.height, 0);
            modsScrollY += 50 * FlxG.mouse.wheel * 1.5;
            if (modsScrollY < maxY) modsScrollY = maxY;
            else if (modsScrollY > 0) modsScrollY = 0;
        }
        if (FlxG.mouse.overlaps(charsScroll)) {
            var maxY = -Math.max(charsScroll.height + 100 - FlxG.height, 0);
            charsScrollY += 50 * FlxG.mouse.wheel * 1.5;
            if (charsScrollY < maxY) charsScrollY = maxY;
            else if (charsScrollY > 0) charsScrollY = 0;
        }
        modsScroll.y = FlxMath.lerp(modsScroll.y, modsScrollY, FlxMath.bound(elapsed * 0.25 * 60, 0, 1));
        charsScroll.y = FlxMath.lerp(charsScroll.y, charsScrollY, FlxMath.bound(elapsed * 0.25 * 60, 0, 1));
        super.update(elapsed);
    }
}