package dev_toolbox.toolbox_tabs;

import dev_toolbox.song_editor.SongCreator;
import Song.SwagSong;
import FreeplayState.FreeplaySongList;
import FreeplayState.FreeplaySong;
import dev_toolbox.file_explorer.FileExplorer;
import openfl.display.BitmapData;
import flixel.tweens.FlxTween;
using StringTools;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.*;
import haxe.Json;
import sys.io.File;
import flixel.text.FlxText;
import flixel.FlxSprite;
import sys.FileSystem;

class SongTab extends ToolboxTab {
    // Songs tab
    public var songsRadioList:FlxUIRadioGroup;
    public var displayHealthIcon:HealthIcon;
    public var displayAlphabet:Alphabet;
    public var songDisplayName:FlxUIInputText;
    public var difficulties:FlxUIInputText;
    public var fpIcon:FlxUIInputText;
    public var colorPanel:FlxUISprite;
    public var songTabThingy:FlxUITabMenu;
    public var fpSongToEdit:FreeplaySong;
    public var freeplaySonglist:FreeplaySongList = {
        songs : []
    }
    var twColor = 0xFF8C8C8C;
    
    public override function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "songs", home);
        
        var bg = new FlxSprite(0, 0).makeGraphic(320, Std.int(FlxG.height - y), 0xFF8C8C8C);
        bg.pixels.lock();
        bg.pixels.fillRect(new openfl.geom.Rectangle(318, 0, 1, Std.int(FlxG.height - y)), 0xFF4C4C4C);
        bg.pixels.fillRect(new openfl.geom.Rectangle(319, 0, 1, Std.int(FlxG.height - y)), 0xFF000000);
        bg.pixels.unlock();
        add(bg);

        songTabThingy = new FlxUITabMenu(null, [
            {
                label: "Song Settings",
                name: "settings"
            }
        ], true);
        songTabThingy.resize(500, 350);
        songTabThingy.x = 320 + ((FlxG.width - 320) / 2) - 250;

        var songSettings = new FlxUI(null, songTabThingy);
        songSettings.name = "settings";

        var labels:Array<FlxUIText> = [];

        var label = new FlxUIText(10, 10, 480, "Song Display Name (leave blank for none)");
        labels.push(label);
        songDisplayName = new FlxUIInputText(10, label.y + label.height, 480, "");

        var label = new FlxUIText(10, songDisplayName.y + songDisplayName.height + 10, 480, "Song Difficulties (seperate using \",\")");
        labels.push(label);
        difficulties = new FlxUIInputText(10, label.y + label.height, 480, "Easy, Normal, Hard");

        var label = new FlxUIText(10, difficulties.y + difficulties.height + 10, 480, "Freeplay Character Icon");
        labels.push(label);
        fpIcon = new FlxUIInputText(10, label.y + label.height, 480, "bf");
        colorPanel = new FlxUISprite(10, fpIcon.y + fpIcon.height + 10);
        colorPanel.makeGraphic(30, 20, 0xFFFFFFFF);
        colorPanel.pixels.lock();
        for (x in 0...colorPanel.pixels.width) {
            colorPanel.pixels.setPixel32(x, 0, 0xFF000000);
            colorPanel.pixels.setPixel32(x, 1, 0xFF000000);
            colorPanel.pixels.setPixel32(x, 18, 0xFF000000);
            colorPanel.pixels.setPixel32(x, 19, 0xFF000000);
        }
        for (y in 0...colorPanel.pixels.height) {
            colorPanel.pixels.setPixel32(0, y, 0xFF000000);
            colorPanel.pixels.setPixel32(1, y, 0xFF000000);
            colorPanel.pixels.setPixel32(28, y, 0xFF000000);
            colorPanel.pixels.setPixel32(29, y, 0xFF000000);
        }
        var editButton = new FlxUIButton(colorPanel.x + colorPanel.width + 10, colorPanel.y, "Select Color", function() {
            state.openSubState(new dev_toolbox.ColorPicker(colorPanel.color, function(c) {
                colorPanel.color = c;
            }));
        });
        var applyButton = new FlxUIButton(editButton.x + editButton.width + 10, colorPanel.y, "Apply & Save", function() {
            fpSongToEdit.displayName = songDisplayName.text.trim() == "" ? null : songDisplayName.text.trim();
            var diffs = difficulties.text.split(",");
            var bpm = 100;
            try {
                for (f in FileSystem.readDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${fpSongToEdit.name}/')) {
                    if (f.toLowerCase().startsWith('${fpSongToEdit.name.toLowerCase()}') && f.toLowerCase().endsWith('.json')) {
                        trace('$f is a chart.');
                        var chart:SwagSong = Json.parse('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${fpSongToEdit.name}/$f');
                        bpm = chart.bpm;
                        break;
                    }
                }
            } catch(e) {

            }
            var _song = {
                song : {
                    song: fpSongToEdit.name,
                    notes: [],
                    bpm: bpm,
                    needsVoices: true,
                    player1: 'bf',
                    player2: 'dad',
                    speed: 1,
                    validScore: true,
                    keyNumber: 4,
                    noteTypes : ["Friday Night Funkin':Default Note"]
                }
			};
            for(d in diffs) {
                var diff = d.trim().toLowerCase().replace(" ", "-");
                var path = '${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${fpSongToEdit.name}/${fpSongToEdit.name}-${d.trim().toLowerCase().replace(" ", "-")}.json';
                if (diff == "normal") {
                    path = '${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${fpSongToEdit.name}/${fpSongToEdit.name}.json';
                }
                if (!FileSystem.exists(path)) {
                    File.saveContent(path, Json.stringify(_song, "\t"));
                }
            }
            fpSongToEdit.difficulties = [for(t in diffs) t.trim()];
            fpSongToEdit.color = colorPanel.color.toWebString();
            fpSongToEdit.char = fpIcon.text.trim();
            
            save();
            refreshSongs();
            for(s in freeplaySonglist.songs) {
                if (s.name == fpSongToEdit.name) {
                    fpSongToEdit = s;
                }
            }
            updateSongTab(fpSongToEdit, false);
        });

        songTabThingy.resize(500, applyButton.y + applyButton.height + 30);
        songTabThingy.y = 690 - songTabThingy.height;


        for (l in labels) songSettings.add(l);
        songSettings.add(songDisplayName);
        songSettings.add(difficulties);
        songSettings.add(colorPanel);
        songSettings.add(fpIcon);
        songSettings.add(editButton);
        songSettings.add(applyButton);
        songTabThingy.addGroup(songSettings);

        songsRadioList = new FlxUIRadioGroup(10, 10, [], [], function(id) {
            var s:FreeplaySong = null;
            for(so in freeplaySonglist.songs) if (so.name == id) s = so;
            updateSongTab(s);
            if (!members.contains(songTabThingy)) add(songTabThingy);
        }, 25, 300, Std.int(FlxG.width / 2));
        add(songsRadioList);
        refreshSongs();

        
        var createButton = new FlxUIButton(10, 670, "Add", function() {
            state.openSubState(new SongCreator(this));
        });
        var deleteButton = new FlxUIButton(createButton.x + createButton.width + 10, 670, "Remove", function() {
            if (songsRadioList.selectedIndex == -1) {
                home.showMessage("Error", "You need to select a song to delete.");
                return;
            }
            home.openSubState(new ToolboxMessage('Warning', 'Do you really want to delete ${songsRadioList.selectedLabel}?\nThis operation will also delete the charts.', [
                {
                    label: "Yes",
                    onClick: function(e) {
                        for(s in freeplaySonglist.songs) {
                            if (s.name.toLowerCase() == songsRadioList.selectedLabel.toLowerCase()) {
                                freeplaySonglist.songs.remove(s);
                                break;
                            }
                        }
                        save();
                        var deletedCharts = true;
                        var deletedSong = true;
                        try {
                            CoolUtil.deleteFolder('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/${songsRadioList.selectedLabel}/');
                            FileSystem.deleteDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/${songsRadioList.selectedLabel}/');
                        } catch(e) {
                            deletedSong = false;
                        }
                        try {
                            CoolUtil.deleteFolder('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${songsRadioList.selectedLabel}/');
                            FileSystem.deleteDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${songsRadioList.selectedLabel}/');
                        } catch(e) {
                            deletedCharts = false;
                        }
                        if (!deletedSong && !deletedCharts) {
                            home.showMessage("Error", "Failed to delete both the charts and the song audio files.");
                        } else if (!deletedSong) {
                            home.showMessage("Error", "Failed to delete the song audio files.");
                        } else if (!deletedCharts) {
                            home.showMessage("Error", "Failed to delete the song charts.");
                        }

                        refreshSongs();


                        remove(displayAlphabet);
                        remove(displayHealthIcon);
                        remove(songTabThingy);
                    }
                },
                {
                    label: "No",
                    onClick: function(e) {}
                }
            ]));
        });
        add(createButton);
        add(deleteButton);
    }

    
    public function refreshSongs() {
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/');   
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/');
        if (!FileSystem.exists('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/freeplaySonglist.json')) {
            var json:FreeplaySongList = {
                songs : []
            };
            File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/freeplaySonglist.json', Json.stringify(json));
        }
        var displayNames = [];
        freeplaySonglist = try {Json.parse(File.getContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/freeplaySonglist.json'));} catch(e) {null;};
        if (freeplaySonglist == null) freeplaySonglist = {songs : []};
        if (freeplaySonglist.songs == null) freeplaySonglist.songs = [];

        for (e in freeplaySonglist.songs) {
            var freeplayThingy:FreeplayState.FreeplaySong = e;

            displayNames.push(freeplayThingy.displayName != null ? freeplayThingy.displayName : freeplayThingy.name);
        }

        songsRadioList.updateRadios([for (e in freeplaySonglist.songs) e.name], displayNames);
    }

    public function save() {
        File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/freeplaySonglist.json', Json.stringify(freeplaySonglist, "\t"));
    }

    public override function onTabEnter() {
        state.bgTweenColor = twColor;
    }

    public override function onTabExit() {
        state.bgTweenColor = 0xFF8C8C8C;
    }

    public function updateSongTab(s:FreeplaySong, ?replace:Bool = true) {
        if (replace) fpSongToEdit = s;
        if (displayAlphabet != null) {
            remove(displayAlphabet);
            displayAlphabet.destroy();
        }
        if (displayHealthIcon != null) {
            remove(displayHealthIcon);
            displayHealthIcon.destroy();
        }

        songDisplayName.text = s.displayName == null ? "" : s.displayName;
        if (s.difficulties == null) s.difficulties = ["Easy", "Normal", "Hard"];
        difficulties.text = s.difficulties.join(", ");
        fpIcon.text = s.char;
        var c:Null<FlxColor> = FlxColor.fromString(s.color);
        if (c == null) c = 0xFFFFFFFF;
        colorPanel.color = c;

        displayAlphabet = new Alphabet(0, 0, s.displayName == null ? s.name : s.displayName, true);
        add(displayAlphabet);
        displayAlphabet.x = 500;
        displayAlphabet.y = 50;
        state.bgTweenColor = FlxColor.fromString(s.color);
        if (state.bgTweenColor == null) state.bgTweenColor = 0xFF8C8C8C;
        twColor = state.bgTweenColor;

        displayHealthIcon = new HealthIcon(s.char == null ? "unknown" : s.char, false, ToolboxHome.selectedMod);
        displayHealthIcon.x = displayAlphabet.x + displayAlphabet.width;
        displayHealthIcon.y = displayAlphabet.y + (displayAlphabet.height / 2) - (displayHealthIcon.height / 2);
        add(displayHealthIcon);
    }
}