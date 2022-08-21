import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.FlxG;

typedef Mod = {
    var folderName:String;
    var card:ModCard;
}

class ModMenuState extends MusicBeatState {
    public var cards:Array<Mod> = [];
    public var selectedIndex:Int = 0;
    public override function new() {
        super();
        var bg = CoolUtil.addBG(this);
        bg.scrollFactor.set(0, 0);

        for (k=>m in ModSupport.modConfig) {
            var card = new ModCard(k, m);
            card.y = 250 * cards.length;
            cards.push({
                folderName: k,
                card: card
            });
            add(card);
        }

        var fancyHUDTopBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, 75, 0x88000000, true);
        fancyHUDTopBar.scrollFactor.set(0, 0);
        add(fancyHUDTopBar);
        
        var titleBarAlphabet = new Alphabet(0, 0, "Installed Mods", true, false, FlxColor.WHITE);
        for (m in titleBarAlphabet) {
            m.scale.set(0.65, 0.65);
            m.updateHitbox();
            m.x *= 0.65;
        }
        titleBarAlphabet.scrollFactor.set(0, 0);
        // titleBarAlphabet.x = 10;
        titleBarAlphabet.screenCenter(X);
        titleBarAlphabet.y = 37.5 - (titleBarAlphabet.height / 2);
        add(titleBarAlphabet);
    }

    public override function onDropFile(path:String) {
        super.onDropFile(path);
        trace(path);
        if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
            if (FileSystem.exists('$path/config.json')) {
                if (FileSystem.exists('./mods/${Path.withoutDirectory(path)}/')) {
                    trace("mod already exists");    
                    return;
                }
                CoolUtil.copyFolder(path, './mods/${Path.withoutDirectory(path)}/');
                FlxG.resetState();
            } else {
                trace("not a yoshi engine mod");
            }
        } else {
            trace("not a folder or doesnt exists");
        }
    }

    public override function update(elapsed) {
        super.update(elapsed);

        FlxG.camera.scroll.set(
            FlxMath.lerp(FlxG.camera.scroll.x, cards[selectedIndex].card.x + (cards[selectedIndex].card.width / 2) - (FlxG.width / 2), 0.30 * 30 * elapsed),
            FlxMath.lerp(FlxG.camera.scroll.y, cards[selectedIndex].card.y + (cards[selectedIndex].card.height / 2) - (FlxG.height / 2), 0.30 * 30 * elapsed));

        for (k=>c in cards) {
            if (k == selectedIndex) {
                // c.card.scale.set(FlxMath.lerp(c.card.scale.x, 1, 0.25 * elapsed), FlxMath.lerp(c.card.scale.y, 1, 0.25 * elapsed));
                c.card.alpha = FlxMath.lerp(c.card.alpha, 1, 0.30 * 30 * elapsed);
                c.card.active = false;
            } else {
                // c.card.scale.set(FlxMath.lerp(c.card.scale.x, 0.5, 0.25 * elapsed), FlxMath.lerp(c.card.scale.y, 0.5, 0.25 * elapsed));
                c.card.alpha = FlxMath.lerp(c.card.alpha, 0.35, 0.30 * 30 * elapsed);
                c.card.active = true;
            }
        }
        if (subState != null) return;
        if (controls.UP_P) {
            changeSelection(-1);
        }
        if (controls.DOWN_P) {
            changeSelection(1);
        }
        if (controls.ACCEPT) {
            openSubState(new RightPane('Mod Settings', [
                {
                    label: "Switch to",
                    callback: function(t) {
                        Settings.engineSettings.data.selectedMod = cards[selectedIndex].folderName;
                        FlxG.switchState(new MainMenuState());
                        if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.25, 0, function(t) {
                            FlxG.sound.music.stop();
                            FlxG.sound.music = null;
                        });
                    }
                },
                {
                    label: "Delete Save Data",
                    callback: function(t) {
                        var mod = cards[selectedIndex].folderName;
                        if (ModSupport.modSaves[mod] != null)
                            ModSupport.modSaves[mod].erase();
                    }
                }
            ]));
        }
        if (Settings.engineSettings.data.menuMouse && FlxG.mouse.wheel != 0) {
            changeSelection(-FlxG.mouse.wheel);
        }
        if (controls.BACK) {
            FlxG.switchState(new MainMenuState());
        }
    }

    function changeSelection(v:Int) {
        selectedIndex += v;
        if (selectedIndex < 0) {
            selectedIndex = cards.length - 1;
        } else if (selectedIndex >= cards.length) {
            selectedIndex = 0;
        }
        CoolUtil.playMenuSFX(0);
    }
}