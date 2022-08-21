package options.screens;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import options.*;

class KeybindsMenu extends OptionScreen {
    
    var keys = CoolUtil.getAllChartKeys();
    var map = FlxKey.toStringMap;
    
    public function new() {
        super("Options > Keybinds");
    }

    function getKeyLabel(key) {
        return ControlsSettingsSubState.getKeyName(key, true);
    }
    public override function create() {
        options = [];
        for(k in keys) {
            
            options.push({
                name: '$k keys',
                desc: 'Current keybinds: ${[for(i in 0...k) getKeyLabel(Reflect.field(Settings.engineSettings.data, 'control_${k}_$i'))].join(" ")}',
                img: null,
                value: "",
                onUpdate: null,
                onSelect: function(e) {
                    persistentUpdate = false;
                    openSubState(new ControlsSettingsSubState(k, FlxG.camera, function() {
                        e.desc = 'Current keybinds: ${[for(i in 0...k) getKeyLabel(Reflect.field(Settings.engineSettings.data, 'control_${k}_$i'))].join(" ")}';
                    }));
                }
            });
        }
        options.push({
                name: "Reset Button",
                desc: "If enabled, pressing [R] will blue ball yourself.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.resetButton);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.resetButton = !Settings.engineSettings.data.resetButton);}
            });
        super.create();
    }
}