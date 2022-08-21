package dev_toolbox.toolbox_tabs;

import dev_toolbox.file_explorer.FileExplorer;
import flixel.addons.ui.*;
import SongConf.SongConfSong;
import flixel.FlxSprite;
import haxe.io.Path;
import sys.io.File;
import flixel.FlxG;
import flixel.util.FlxColor;
import sys.FileSystem;
import haxe.Json;
import openfl.utils.Assets;
import SongConf.SongConfJson;

using StringTools;

class SongConfTab extends ToolboxTab {
    var valid:Bool = true;
    var songConfJson:SongConfJson = null;
    var songsRadioList:FlxUIRadioGroup = null;
    var confTabs:FlxUITabMenu = null;
    var songName:FlxUIText = null;
    var cutscene:FlxUIInputText = null;
    var endCutscene:FlxUIInputText = null;
    var confSettings:FlxUI = null;

    var scriptsBasePos:{x:Float, y:Float} = {x:0, y:0};

    var scripts:Array<FlxUIInputText> = [];

    public function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "songconf", home);
        try {
            songConfJson = Json.parse(Assets.getText(Paths.file('song_conf.json', TEXT, 'mods/${ToolboxHome.selectedMod}')));
        } catch(e) {
            valid = false;
            
            var uhOh = new FlxUIText(10, 10, FlxG.width - 20, 'An error occured while opening the song_conf.json. Make sure the file exists in your mod\'s directory, and that the JSON is correct\n\n${e.details()}');
            uhOh.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            add(uhOh);
            return;
        }
        if (songConfJson == null) {
            valid = false;
            
            var uhOh = new FlxUIText(10, 10, FlxG.width - 20, 'An error occured while opening the song_conf.json. Make sure the file exists in your mod\'s directory, and that the JSON is correct.');
            uhOh.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            add(uhOh);
            return;
        }
        var bg = new FlxSprite(0, 0).makeGraphic(320, Std.int(FlxG.height - y), 0xFF8C8C8C);
        bg.pixels.lock();
        bg.pixels.fillRect(new openfl.geom.Rectangle(318, 0, 1, Std.int(FlxG.height - y)), 0xFF4C4C4C);
        bg.pixels.fillRect(new openfl.geom.Rectangle(319, 0, 1, Std.int(FlxG.height - y)), 0xFF000000);
        bg.pixels.unlock();
        add(bg);

        songsRadioList = new FlxUIRadioGroup(10, 10, [], [], function(id) {
            var conf = null;
            for(e in songConfJson.songs) if (e.name.toLowerCase() == id.toLowerCase()) conf = e;
            if (conf == null) return;
            switchSong(conf);
        }, 25, 300, Std.int(FlxG.width / 2));
        add(songsRadioList);

        refreshSongs();

        
        confTabs = new FlxUITabMenu(null, [
            {
                label: "Song Configuration",
                name: "settings"
            }
        ], true);
        confTabs.resize(500, 680);
        confTabs.x = 320 + ((FlxG.width - 320) / 2) - 250;

        confSettings = new FlxUI(null, confTabs);
        confSettings.name = "settings";

        songName = new FlxUIText(10, 10, 480, "Select a song");
        songName.size = Std.int(songName.size * 1.5);

        var cutsceneLabel = new FlxUIText(10, songName.y + songName.height + 10, 480, "Cutscene (Leave empty for none)");
        cutscene = new FlxUIInputText(10, cutsceneLabel.y + cutsceneLabel.height, 480, "");

        var endCutsceneLabel = new FlxUIText(10, cutscene.y + cutscene.height + 10, 480, "End Cutscene (Leave empty for none)");
        endCutscene = new FlxUIInputText(10, endCutsceneLabel.y + endCutsceneLabel.height, 480, "");

        var scriptsLabel = new FlxUIText(10, endCutscene.y + endCutscene.height + 10, 480, "Scripts");
        scriptsBasePos.x = 10;
        scriptsBasePos.y = scriptsLabel.y + scriptsLabel.height;

        var applyButton = new FlxUIButton(10, 650, "Apply Changes", function() {
            for(e in songConfJson.songs) {
                if (e.name.toLowerCase() == songName.text.toLowerCase()) {
                    songConfJson.songs.remove(e);
                    break;
                }
            }
            var newObj:SongConfSong = {
                name: songName.text,
                cutscene: cutscene.text.trim() == "" ? null : cutscene.text.trim(),
                end_cutscene: endCutscene.text.trim() == "" ? null : endCutscene.text.trim(),
                scripts: [for(s in scripts) if (s.text.trim() != "") s.text.trim()],
                difficulties: null
            };
            songConfJson.songs.push(newObj);
            save();
        });
        applyButton.y -= applyButton.height;
        var pushScript = new FlxUIButton(10 + applyButton.x + applyButton.width, applyButton.y, "Add Script", function() {
			home.openSubState(new FileExplorer(ToolboxHome.selectedMod, FileExplorerType.Script, "", function(p) {
				var array = [];
				var f = Path.withoutExtension(p).replace("\\", "/");
				while (f.startsWith("/")) f = f.substr(1);
				(array = [for(s in scripts) s.text]).push(f);
				updateScriptInputs(array);
			}));
        });
        var removeScript = new FlxUIButton(10+pushScript.x+pushScript.width, applyButton.y, "Remove Script", function() {
            var array = [];
            array = ([for(s in scripts) s.text]).splice(0, scripts.length - 1);
            updateScriptInputs(array);
        });
        var addScript = new FlxUIButton(10+removeScript.x+removeScript.width, applyButton.y, "Add Empty", function() {
            var array = [];
            (array = [for(s in scripts) s.text]).push("");
            updateScriptInputs(array);
        });

        confSettings.add(songName);
        confSettings.add(cutsceneLabel);
        confSettings.add(cutscene);
        confSettings.add(endCutsceneLabel);
        confSettings.add(endCutscene);
        confSettings.add(scriptsLabel);
        confSettings.add(applyButton);
        confSettings.add(addScript);
        confSettings.add(pushScript);
        confSettings.add(removeScript);
        // songSettings.add(scriptsInput);

        confTabs.addGroup(confSettings);
        confTabs.screenCenter(Y);
        confTabs.y -= y / 2;
        confTabs.visible = false;
        add(confTabs);
    }

    public function switchSong(conf:SongConfSong) {
        songName.text = conf.name;
        cutscene.text = conf.cutscene == null ? "" : conf.cutscene;
        endCutscene.text = conf.end_cutscene == null ? "" : conf.end_cutscene;

        if (conf.scripts == null) conf.scripts = [];
        updateScriptInputs(conf.scripts);
        confTabs.visible = true;
    }

    public function updateScriptInputs(script:Array<String>) {

        for (e in scripts) {
            e.destroy();
            confSettings.remove(e);
            remove(e);
        }
        scripts = [];
        for(k=>e in script) {
            var scriptInput = new FlxUIInputText(scriptsBasePos.x, scriptsBasePos.y + (k * cutscene.height), 480, e);
            confSettings.add(scriptInput);
            scripts.push(scriptInput);
        }
    }

    public function refreshSongs() {
        if (songConfJson.songs == null) songConfJson.songs = [];
        var addedSongs = [for(e in songConfJson.songs) e.name.toLowerCase()];
        var allSongs = [for (f in FileSystem.readDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/')) if (FileSystem.isDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/$f')) f.toLowerCase()];
        for (s in allSongs)  {
            if (!addedSongs.contains(s.toLowerCase())) {
                songConfJson.songs.push({
                    name: s,
                    scripts: [],
                    cutscene: null,
                    end_cutscene: null,
                    difficulties: []
                });
            }
        }
        var diffArray = [for(s in addedSongs) if (!allSongs.contains(s)) s];
        trace(diffArray);
        for(s in songConfJson.songs) {
            if (diffArray.contains(s.name.toLowerCase())) {
                songConfJson.songs.remove(s);
            }
        }
        var songs = [for(e in songConfJson.songs) e.name];
        songsRadioList.updateRadios(songs, songs);
        save();
    }
    public function save() {
        File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/song_conf.json', Json.stringify(songConfJson, "\t"));
        Assets.cache.clear(Paths.file('song_conf.json', TEXT, 'mods/${ToolboxHome.selectedMod}'));
    }
    public override function onTabEnter() {
        if (!valid) return;
        refreshSongs();
    }
    public override function update(elapsed:Float) {
        
        if (!valid) {
            super.update(elapsed);
            return;
        }

        super.update(elapsed);
    }
}