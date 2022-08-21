package dev_toolbox.song_editor;

import dev_toolbox.toolbox_tabs.SongTab;
import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import flixel.FlxSprite;
import flixel.addons.ui.*;
import sys.FileSystem;
import flixel.FlxG;
import dev_toolbox.ToolboxHome;

using StringTools;

class SongCreator extends MusicBeatSubstate {
    public override function new(home:SongTab) {
        super();

        add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000));

        var tabMenu = new FlxUITabMenu(null, [
            {
                name: "add",
                label: "Add a song"
            }
        ], true);
        tabMenu.resize(500, FlxG.height);
        var tab = new FlxUI(null, tabMenu);
        tab.name = "add";
        
        var labels:Array<FlxUIText> = [];

        var label = new FlxUIText(10, 10, 480, "Song Name");
        labels.push(label);
        var songName = new FlxUIInputText(10, label.y + label.height, 480, "");

        var label = new FlxUIText(10, songName.y + songName.height + 10, 480, "Song Display Name (leave blank for none)");
        labels.push(label);
        var songDisplayName = new FlxUIInputText(10, label.y + label.height, 480, "");

        var label = new FlxUIText(10, songDisplayName.y + songDisplayName.height + 10, 480, "Song Instrumental");
        labels.push(label);
        var instPath = "";
        var songInst:FlxUIButton = null;
        songInst = new FlxUIButton(10, label.y + label.height, "Browse...", function() {
            CoolUtil.openDialogue(OPEN, "Choose your song's instrumental (.ogg)", function(t) {
                if (Path.extension(t).toLowerCase() != "ogg") {
                    songInst.color = 0xFFFF4444;
                    songInst.label.text = "(Browse...) File must be in .ogg format.";
                    instPath = "";
                    return;
                }
                instPath = t;
                songInst.color = 0xFF44FF44;
                songInst.label.text = "(Browse...) Inst selected.";
            });
        });
        songInst.resize(480, 20);

        var label = new FlxUIText(10, songInst.y + songInst.height + 10, 480, "Song Voices (optional but recommended)");
        labels.push(label);
        var songVoices:FlxUIButton = null;
        var voicesPath = "";
        songVoices = new FlxUIButton(10, label.y + label.height, "Browse...", function() {
            CoolUtil.openDialogue(OPEN, "Choose your song's voices (.ogg)", function(t) {
                if (Path.extension(t).toLowerCase() != "ogg") {
                    songVoices.color = 0xFFFF4444;
                    songVoices.label.text = "(Browse...) File must be in .ogg format.";
                    voicesPath = "";
                    return;
                }
                voicesPath = t;
                songVoices.color = 0xFF44FF44;
                songVoices.label.text = "(Browse...) Vocals selected.";
            });
        });
        songVoices.resize(480, 20);

        var label = new FlxUIText(10, songVoices.y + songVoices.height + 10, 480, "Song Difficulties (seperate using \",\")");
        labels.push(label);
        var difficulties = new FlxUIInputText(10, label.y + label.height, 480, "Easy, Normal, Hard");

        var label = new FlxUIText(10, difficulties.y + difficulties.height + 10, 480, "Freeplay Character Icon");
        labels.push(label);
        var fpIcon = new FlxUIInputText(10, label.y + label.height, 480, "bf");
        var colorPanel = new FlxUISprite(10, fpIcon.y + fpIcon.height + 10);
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
            openSubState(new dev_toolbox.ColorPicker(colorPanel.color, function(c) {
                colorPanel.color = c;
            }));
        });

        var label = new FlxUIText(editButton.x + editButton.width + 10, editButton.y + (editButton.height / 2), 0, "BPM: ");
        labels.push(label);
        var bpm = new FlxUINumericStepper(label.x + label.width, label.y, 1, 150, 1, 999);
        label.y -= label.height / 2;
        bpm.y -= bpm.height / 2;

        var validateButton = new FlxUIButton(250, editButton.y + editButton.height + 10, "Create", function() {
            if (songName.text.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "The song name cannot be empty."));
                return;
            }
            if (FileSystem.exists('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/${songName.text.trim()}/')) {
                openSubState(ToolboxMessage.showMessage("Error", "The song already exists."));
                return;
            }
            if (instPath.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "You haven't selected any instrumental OGG file or the file is invalid."));
                return;
            }
            if (fpIcon.text.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "A Freeplay icon character is required."));
                return;
            }
            if (!FileSystem.exists(instPath)) {
                openSubState(ToolboxMessage.showMessage("Error", "The selected instrumental file does not exist."));
                return;
            }
            // var home = cast(FlxG.state, dev_toolbox.ToolboxHome);
            var json:FreeplayState.FreeplaySong = {
                name: songName.text.trim(),
                char: fpIcon.text,
                displayName: songDisplayName.text.trim() == "" ? null : songDisplayName.text.trim(),
                difficulties: [for(e in difficulties.text.split(",")) e.trim()],
                color: colorPanel.color.toWebString(),
                bpm: Std.int(bpm.value)
            };
            FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/${json.name}/');
            File.copy(instPath.trim(), '${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/${json.name}/Inst.ogg');
            if (voicesPath.trim() != "") File.copy(voicesPath.trim(), '${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/${json.name}/Voices.ogg');

            
            FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${json.name}/');
            var _song = {
                song : {
                    song: json.name,
                    notes: [],
                    bpm: Std.int(bpm.value),
                    needsVoices: true,
                    player1: 'bf',
                    player2: 'dad',
                    speed: 1,
                    validScore: true,
                    keyNumber: 4,
                    noteTypes : ["Friday Night Funkin':Default Note"]
                }
			};

            for (diff in json.difficulties) {
                if (diff.toLowerCase() == "normal")
                    File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${json.name}/${json.name}.json', Json.stringify(_song));
                else
                    File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/${json.name}/${json.name}-${diff.trim().toLowerCase().replace(" ", "-")}.json', Json.stringify(_song));
                
                
            }
            
            // ${json.name}
            home.freeplaySonglist.songs.push(json);
            close();
            home.save();
            home.refreshSongs();
        });
        validateButton.x -= validateButton.width / 2;

        for (l in labels) tab.add(l);
        tab.add(songName);
        tab.add(songDisplayName);
        tab.add(songInst);
        tab.add(songVoices);
        tab.add(difficulties);
        tab.add(colorPanel);
        tab.add(editButton);
        tab.add(fpIcon);
        tab.add(bpm);
        tab.add(validateButton);

        tabMenu.resize(500, 30 + validateButton.y + validateButton.height);
        tabMenu.screenCenter();

        tabMenu.addGroup(tab);
        add(tabMenu);

        var closeButton = new FlxUIButton(tabMenu.x + tabMenu.width - 23, tabMenu.y + 3, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = 0xFFFFFFFF;
        add(closeButton);
    }
}