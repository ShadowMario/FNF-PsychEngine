package options.screens;

import flixel.FlxG;
import flixel.math.FlxMath;

class OptiMenu extends OptionScreen {
    var stageQualities = ["Best", "High", "Low", "Medium"];
    var cacheModes = ["All", "Mods", "This Mod"];
    var aaModes = ["16x Anisotropic Filtering", "2x Anisotropic Filtering", "4x Anisotropic Filtering", "8x Anisotropic Filtering", "On", "Off"]; // unused

    public function new() {
        super("Options > Optimization");
    }
    public override function create() {
        options = [
            {
                name: "Stage Quality",
                desc: "Sets the Flash Stage Quality",
                additional: true,
                value: '${stageQualities[Settings.engineSettings.data.stageQuality]}',
                onLeft: function(e) {e.value = '${stageQualities[Settings.engineSettings.data.stageQuality]}';},
                onUpdate: function(e) {
                    if (controls.LEFT_P) Settings.engineSettings.data.stageQuality--;
                    if (controls.RIGHT_P) Settings.engineSettings.data.stageQuality++;
                    Settings.engineSettings.data.stageQuality %= stageQualities.length;
                    if (Settings.engineSettings.data.stageQuality < 0) Settings.engineSettings.data.stageQuality = stageQualities.length + Settings.engineSettings.data.stageQuality;
                    e.value = '< ${stageQualities[Settings.engineSettings.data.stageQuality]} >';
                }
            },
            {
                name: "Antialiasing",
                desc: "If unchecked, will disable antialiasing on every sprite, netherless of the script enabling it or not.",
                value: '',
                onCreate: function(e) {
                    e.check(Settings.engineSettings.data.antialiasing != 5);
                },
                onLeft: function(e) {
                    e.check(Settings.engineSettings.data.antialiasing != 5);
                },
                onUpdate: function(e) {
                    e.check(Settings.engineSettings.data.antialiasing != 5);
                },
                onSelect: function(e) {
                    if (Settings.engineSettings.data.antialiasing != 5)
                        Settings.engineSettings.data.antialiasing = 5;
                    else
                        Settings.engineSettings.data.antialiasing = 4;
                    CoolUtil.updateAntialiasing();
                }
            },
            {
                name: "Antialiasing on videos",
                desc: "If unchecked, will disable antialiasing on MP4 videos and cutscenes.",
                value: '',
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.videoAntialiasing);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.videoAntialiasing = !Settings.engineSettings.data.videoAntialiasing);}
            },
            {
                name: "Use MP4 for Stress",
                desc: "If enabled, will use the MP4 cutscene for Stress instead of the new animations. Enabled by default on PCs with lower than 6GB of RAM.",
                value: '',
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.useStressMP4);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.useStressMP4 = !Settings.engineSettings.data.useStressMP4);}
            },
            {
                name: "Auto resync vocals",
                desc: "If enabled, will automatically resync vocals if they're not synchronized.",
                value: '',
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.autoResyncVocals);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.autoResyncVocals = !Settings.engineSettings.data.autoResyncVocals);}
            },
            {
                name: "Maximum FPS",
                desc: "Sets the maximum FPS the game can reach.",
                value: '${Settings.engineSettings.data.fpsCap} FPS',
                onLeft: function(e) {e.value = '${Settings.engineSettings.data.fpsCap} FPS';},
                onUpdate: function(e) {
                    if (controls.LEFT_P) Settings.engineSettings.data.fpsCap -= 10;
                    if (controls.RIGHT_P) Settings.engineSettings.data.fpsCap += 10;
                    Settings.engineSettings.data.fpsCap = Std.int(FlxMath.bound(Settings.engineSettings.data.fpsCap, 20, 300));
                    
					FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
					FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
                    
                    e.value = '< ${Settings.engineSettings.data.fpsCap} FPS >';
                }
            },
            {
                name: "Ratings Limits",
                desc: "Sets the maximum rating amount that can be displayed on screen. None means no limitation.",
                additional: true,
                value: '${Settings.engineSettings.data.maxRatingsAllowed == -1 ? "None" : Settings.engineSettings.data.maxRatingsAllowed}',
                onLeft: function(e) {e.value = '${Settings.engineSettings.data.maxRatingsAllowed == -1 ? "None" : Settings.engineSettings.data.maxRatingsAllowed}';},
                onUpdate: function(e) {
                    if (controls.LEFT_P) Settings.engineSettings.data.maxRatingsAllowed--;
                    if (controls.RIGHT_P) Settings.engineSettings.data.maxRatingsAllowed++;
                    Settings.engineSettings.data.maxRatingsAllowed = FlxMath.wrap(Settings.engineSettings.data.maxRatingsAllowed, -1, 25);
                    e.value = '< ${Settings.engineSettings.data.maxRatingsAllowed == -1 ? "None" : Settings.engineSettings.data.maxRatingsAllowed} >';
                }
            },
            {
                name: "Enable Alphabet outline",
                desc: "If enabled, will automatically generate an outline around normal letters in bold. If turned off, will disable every outline in alphabets, resulting in a performance boost at cost of worse looking alphabets.",
                value: '',
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.alphabetOutline);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.alphabetOutline = !Settings.engineSettings.data.alphabetOutline);}
            },
            {
                name: "Clear Cache",
                desc: "Select this option to clear the cache.",
                value: '',
                additional: true,
                onSelect: function(e) {
                    openfl.utils.Assets.cache.clear();
                    e.value = 'Cache Cleared!';
                }
            }
        ];
        super.create();
    }
}