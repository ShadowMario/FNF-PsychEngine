package options.screens;

import flixel.FlxG;

class MiscMenu extends OptionScreen {
    public function new() {
        super("Options > Miscellaneous");
    }

    public override function create() {
        options = [
            {
                name: "Show advanced options",
                desc: "If enabled, will show advanced options to further customize your experience.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showAdvancedOptions);},
                onSelect: function(e) {
                    e.check(Settings.engineSettings.data.showAdvancedOptions = !Settings.engineSettings.data.showAdvancedOptions);
                    FlxG.resetState();
                },
            },
            {
                name: "Auto Check for Updates",
                desc: "If enabled, will automatically look for updates, and prompt you if one is available. Disable if the antivirus blocks the engine.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.checkForUpdates);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.checkForUpdates = !Settings.engineSettings.data.checkForUpdates);},
            },
            {
                name: "Green Screen Mode",
                desc: "If enabled, will show a green screen behind the GUI, for green screen videos.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.greenScreenMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.greenScreenMode = !Settings.engineSettings.data.greenScreenMode);},
            },
            {
                name: "Auto Pause",
                desc: "If disabled, the game will no longer pause when it loses focus.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.autopause);},
                onSelect: function(e) {FlxG.autoPause = e.check(Settings.engineSettings.data.autopause = !Settings.engineSettings.data.autopause);},
            },
            {
                name: "Enable mouse controls",
                desc: "If enabled, will allow you to browse through the main menus using your mouse.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.menuMouse);},
                onSelect: function(e) {FlxG.autoPause = e.check(Settings.engineSettings.data.menuMouse = !Settings.engineSettings.data.menuMouse);},
            },
            {
                name: "Auto add new mods",
                desc: "If enabled, will automatically add new installed mods once game gains focus again.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.autoSwitchToLastInstalledMod);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.autoSwitchToLastInstalledMod = !Settings.engineSettings.data.autoSwitchToLastInstalledMod);},
            },
            {
                name: "Show FPS counter",
                desc: "If enabled, will show a counter with the current FPS.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.fps_showFPS);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.fps_showFPS = !Settings.engineSettings.data.fps_showFPS);},
            },
            {
                name: "Show Memory",
                desc: "If enabled, will show a counter with the current memory amount.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.fps_showMemory);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.fps_showMemory = !Settings.engineSettings.data.fps_showMemory);},
            },
            {
                name: "Show Memory Peak",
                desc: "If enabled, will show the maximum amount of memory the game reached.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.fps_showMemoryPeak);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.fps_showMemoryPeak = !Settings.engineSettings.data.fps_showMemoryPeak);},
            },
            {
                name: "Use legacy charter",
                desc: "If enabled, will use the old charter instead of the new one (no longer supported).",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(!Settings.engineSettings.data.yoshiCrafterEngineCharter);},
                onSelect: function(e) {e.check(!(Settings.engineSettings.data.yoshiCrafterEngineCharter = !Settings.engineSettings.data.yoshiCrafterEngineCharter));},
            }
        ];
        super.create();
    }
}