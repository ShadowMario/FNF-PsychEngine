package options.screens;

import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.ToolboxMain;
import options.OptionScreen;
import flixel.FlxG;

class DevMenu extends OptionScreen {
    public function new() {
        super("Options > Developer Settings");
    }
    public override function create() {
        options = [
            {
                name: "Developer Mode",
                desc: "When checked, enables Developer Mode, which allows you to access the Toolbox to create and edit mods.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.developerMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.developerMode = !Settings.engineSettings.data.developerMode);}
            },
            {
                name: "Open the Toolbox",
                desc: "Select this option to open the Toolbox (dev mode only).",
                value: "Open",
                onSelect: function(e) {
                    if (Settings.engineSettings.data.developerMode) {
                        doFlickerAnim(1, function() {
                            FlxG.switchState(new ToolboxMain());
                        });
                    } else {
                        CoolUtil.playMenuSFX(3);
                    }
                }
            },
            {
                name: "Log Limit",
                desc: "Maximum lines allowed in logs. If the limit is reached, older lines will be removed. Higher limit equals to higher memory amount.",
                value: "",
                onCreate: function(e) {e.value = Settings.engineSettings.data.logLimit;},
                onUpdate: function(e) {
                    if (controls.RIGHT_P) Settings.engineSettings.data.logLimit += 10;
                    if (controls.LEFT_P) Settings.engineSettings.data.logLimit -= 10;
                    if (Settings.engineSettings.data.logLimit < 10) Settings.engineSettings.data.logLimit = 10;
                    if (Settings.engineSettings.data.logLimit > 10000) Settings.engineSettings.data.logLimit = 10000;
                    e.value = '< ${Settings.engineSettings.data.logLimit} >';
                },
                onLeft: function(e) {
                    e.value = Settings.engineSettings.data.logLimit;
                }
            },
            {
                name: "Show Errors in boxes",
                desc: "When checked, exceptions will be shown in a message box, instead of logs. You'll be able to bypass this by holding down the Shift key.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showErrorsInMessageBoxes);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showErrorsInMessageBoxes = !Settings.engineSettings.data.showErrorsInMessageBoxes);}
            },
            {
                name: "Log state changes",
                desc: "When checked, the new state class will be logged everything you switch state (ex: FreeplayState).",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.logStateChanges);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.logStateChanges = !Settings.engineSettings.data.logStateChanges);}
            }
        ];
        super.create();
    }
    
    public override function update(elapsed:Float) {
        super.update(elapsed);
        spawnedOptions[1]._nameAlphabet.textColor = Settings.engineSettings.data.developerMode ? 0xFFFFFFFF : 0xFF888888;
    }
}