package options.screens;

import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.ToolboxMain;
import options.OptionScreen;
import flixel.FlxG;

class DevMenu extends OptionScreen {
    function new() {
        super("Options > Dev Options");
    }
    public override function create() {
        options = [
            {
                name: "Flashing Lights",
                desc: "When unchecked, will disable any form of flashing lights (may not be supported by every mod).",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.flashingLights);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.flashingLights = !Settings.engineSettings.data.flashingLights);}
            }
        ];
        super.create();
    }
}