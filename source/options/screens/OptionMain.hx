package options.screens;

import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;

class OptionMain extends OptionScreen {
    public static var fromFreeplay:Bool = false;
    public var skipKeybinds:Bool = false;
    var kId = 0;
    var keys:Array<FlxKey> = [D, E, B, U, G, SEVEN]; // lol

    public function new(x:Float, y:Float) {
        super("Options");
    }

    public override function create() {
        var label = "";
        var keys = CoolUtil.getAllChartKeys();
        for(k=>i in keys) {
            if (k > 0) {
                label += ", ";
                if (k >= keys.length - 1)
                    label += "and ";
            }
            label += Std.string(i);
        }
        skipKeybinds = keys.length <= 1;
        options = [
            {
                name: "Keybinds",
                desc: 'Edit Keybinds for $label keys charts.',
                value: "",
                onSelect: function(spr) {
                    doFlickerAnim(curSelected, function() {FlxG.switchState(new KeybindsMenu());});
                }
            },
            {
                name: "Gameplay",
                desc: "Customize Gameplay Settings such as Downscroll, Middlescroll and more, and access accessibility settings such as turning off flashing lights.",
                value: "",
                onSelect: function(spr) {
                    doFlickerAnim(curSelected, function() {FlxG.switchState(new GameplayMenu());});
                }
            },
            {
                name: "Customisation",
                desc: "Customize Note settings, such as note colors and splashes.",
                value: "",
                onSelect: function(spr) {
                    doFlickerAnim(curSelected, function() {FlxG.switchState(new NotesMenu());});
                }
            },
            {
                name: "Optimization",
                desc: "Change optimization settings here.",
                value: "",
                onSelect: function(spr) {
                    doFlickerAnim(curSelected, function() {FlxG.switchState(new OptiMenu());});
                }
            },
            {
                name: "Miscellaneous",
                desc: "Other settings that does not fit any of the categories above.",
                value: "",
                onSelect: function(spr) {
                    doFlickerAnim(curSelected, function() {FlxG.switchState(new MiscMenu());});
                }
            },
            {
                name: "Developer Settings",
                desc: "Enable Developer Mode to access the Toolbox.",
                value: "",
                onSelect: function(spr) {
                    doFlickerAnim(curSelected, function() {FlxG.switchState(new DevMenu());});
                }
            }
        ];
        super.create();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        // cheat code lmao
        if (FlxG.keys.justPressed.ANY) {
            var k = keys[kId];
            if (FlxG.keys.anyJustPressed([k])) {
                kId++;
                if (kId >= keys.length) {
                    FlxG.switchState(new DebugMenu());
                }
            }
        }
    }

    public override function onExit() {
        if (fromFreeplay && FlxG.sound.music != null)
            FlxG.sound.music.fadeOut(OptionScreen.speedMultiplier);
        
        doFlickerAnim(-2, function() {
            if (fromFreeplay) {
                FlxG.switchState(new PlayState());
            }
            else
                FlxG.switchState(new MainMenuState());
        });
    }
}