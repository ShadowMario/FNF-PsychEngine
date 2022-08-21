package dev_toolbox.week_editor;

import flixel.FlxSubState;
import flixel.util.FlxSort;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import sys.io.File;
import haxe.io.Path;
import dev_toolbox.file_explorer.FileExplorer;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import haxe.Json;
import lime.utils.Assets;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import WeeksJson.FNFWeek;
import flixel.addons.ui.*;

using StringTools;

class WeekEditor extends MusicBeatState {
    var weekIndex:Int = -1;
    var week:FNFWeek;
    var weeks:WeeksJson;
    var yellowBG:FlxSprite;
    var hasBeenSaved:Bool = true;

    var weekTitleInput:FlxInputText;

    var scoreText:FlxText;

    var dad:FlxSprite; // youll never get one dream stan
    var bf:FlxSprite; // youll never get one
    var gf:FlxSprite; // youll never get one
    var bg:FlxSprite; // bruh

    var button:FlxSprite;

    var txtTracklist:FlxText;

    var changeColorLabel:AlphabetOptimized;
    var helpLabel:AlphabetOptimized;

    var UI:FlxUITabMenu;

    var weekNameTextBox:FlxUIInputText;
    var songsListBox:FlxUIInputText;
    var buttonSpriteBox:FlxUIInputText;
    var sfxBox:FlxUIInputText;
    var bgInput:FlxUIInputText;
    var bgAnimInput:FlxUIInputText;

    var camDeezNuts:FlxCamera;

    public function new(weekIndex:Int) {
        this.weekIndex = weekIndex;
        super();
    }

    public function updateBf() {
        if (bf != null) {
            week.bf.offset = [bf.offset.x, bf.offset.y];
            week.bf.flipX = bf.flipX;
            bf.destroy();
            // subscribing to dream
            remove(bf);
        }
        bf = new FlxSprite((FlxG.width * 0.5) - 150, 70);
        if (Assets.exists(Paths.image(week.bf.file)) && Assets.exists(Paths.getPath('images/${week.bf.file}.xml', TEXT))) {
            bf.frames = Paths.getSparrowAtlas(week.bf.file);
            bf.antialiasing = true;
            bf.animation.addByPrefix(week.bf.animation, week.bf.animation, 24, true);
            bf.animation.play(week.bf.animation);
        }
        bf.scale.set(week.bf.scale, week.bf.scale);
        bf.updateHitbox();
        bf.flipX = week.bf.flipX;
        bf.offset.set(week.bf.offset[0], week.bf.offset[1]);
        bf.antialiasing = true;
        add(bf);
    }

    public function updateGf() {
        if (gf != null) {
            week.gf.offset = [gf.offset.x, gf.offset.y];
            week.gf.flipX = gf.flipX;
            gf.destroy();
            // subscribing to dream
            remove(gf);
        }
        gf = new FlxSprite((FlxG.width * 0.75) - 150, 70);
        if (Assets.exists(Paths.image(week.gf.file)) && Assets.exists(Paths.getPath('images/${week.gf.file}.xml', TEXT))) {
            gf.frames = Paths.getSparrowAtlas(week.gf.file);
            gf.antialiasing = true;
            gf.animation.addByPrefix(week.gf.animation, week.gf.animation, 24, true);
            gf.animation.play(week.gf.animation);
        }
        gf.scale.set(week.gf.scale, week.gf.scale);
        gf.updateHitbox();
        gf.flipX = week.gf.flipX;
        gf.antialiasing = true;
        gf.offset.set(week.gf.offset[0], week.gf.offset[1]);
        add(gf);
    }

    public function updateDad() {
        if (dad != null) {
            week.dad.offset = [dad.offset.x, dad.offset.y];
            week.dad.flipX = dad.flipX;
            dad.destroy();
            // subscribing to dream
            remove(dad);
        }
        dad = new FlxSprite((FlxG.width * 0.25) - 150, 70);
        if (Assets.exists(Paths.image(week.dad.file)) && Assets.exists(Paths.getPath('images/${week.dad.file}.xml', TEXT))) {
            dad.frames = Paths.getSparrowAtlas(week.dad.file);
            dad.animation.addByPrefix(week.dad.animation, week.dad.animation, 24, true);
            dad.animation.play(week.dad.animation);
            dad.antialiasing = true;
        }
        dad.scale.set(week.dad.scale, week.dad.scale);
        dad.updateHitbox();
        dad.flipX = week.dad.flipX;
        dad.antialiasing = true;
        dad.offset.set(week.dad.offset[0], week.dad.offset[1]);
        add(dad);
    }

    public function updateButton() {
        if (button != null) {
            button.destroy();
            remove(button);
        }
        button = new FlxSprite(0, yellowBG.y + yellowBG.height + 10);

        var path = Paths.image(week.buttonSprite);
        if (Assets.exists(path)) {
            button.loadGraphic(path);
        }
        button.screenCenter(X);
        add(button);
    }

    public function updateBG() {
        if (bg != null){
            bg.destroy();
            remove(bg);
        }

        if (week.bg != null && week.bg.trim() != "") {
            bg = new FlxSprite();
            if (Assets.exists(Paths.getPath('images/${week.bg}.xml', TEXT))) {
                bg.frames = Paths.getSparrowAtlas(week.bg);
            } else {
                bg.loadGraphic(Paths.image(week.bg));
            }
            if (week.bgAnim != null && week.bgAnim.trim() != "") {
                bg.animation.addByPrefix(week.bgAnim, week.bgAnim, 24, true);
                bg.animation.play(week.bgAnim);
            }
            bg.antialiasing = true;
            bg.setPosition(
                yellowBG.x + ((yellowBG.width - bg.width) / 2),
                yellowBG.y + ((yellowBG.height - bg.height) / 2));
            var indexes = [];
            if (gf != null)
                indexes.push(members.indexOf(gf));
            if (dad != null)
                indexes.push(members.indexOf(dad));
            if (bf != null)
                indexes.push(members.indexOf(bf));
            if (indexes.length > 0) {
                indexes.sort(function(v1, v2) {
                    return FlxSort.byValues(FlxSort.ASCENDING, v1, v2); // TANKMAN???
                });
                insert(indexes[0], bg);
            } else {
                add(bg);
            }
        }
    }

    public override function create() {
        super.create();
        FlxG.cameras.reset();
        // It's coming to fruition
        weeks = Json.parse(Assets.getText(Paths.getPath("weeks.json", TEXT, 'mods/${Settings.engineSettings.data.selectedMod}')));

        week = weeks.weeks[weekIndex];

        if (week.dad == null) {
            week.dad = {
                file : "storymenu/campaign_menu_UI_characters",
                animation : "Dad idle dance BLACK LINE",
                scale : 0.5,
                flipX : false,
                offset : [120,200],
                confirmAnim: ""
            };
        }

        if (week.bf == null) {
            week.bf = {
                file : "storymenu/campaign_menu_UI_characters",
                animation : "BF idle dance white",
                scale : 0.9,
                flipX : false,
                offset : [100,20],
                confirmAnim: "BF HEY!!"
            };
        }

        if (week.gf == null) {
            week.gf = {
                file : "storymenu/campaign_menu_UI_characters",
                animation : "GF Dancing Beat WHITE",
                scale : 0.5,
                flipX : false,
                offset : [150,159],
                confirmAnim: ""
            };
        }

        for(f in [week.dad, week.gf, week.bf]) {
            f.file = CoolUtil.getCleanupImagesPath(f.file);
        }
        week.buttonSprite = CoolUtil.getCleanupImagesPath(week.buttonSprite);

		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, FlxColor.WHITE, true);
		yellowBG.color = 0xFFF9CF51;
        add(yellowBG);

        scoreText = new FlxText(10, 10, 0, "SCORE: -", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
        add(scoreText);

        weekTitleInput = new FlxInputText(0, 10, 0, week.name, 32);
		weekTitleInput.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		weekTitleInput.alpha = 0.7;
        weekTitleInput.background = true;
        weekTitleInput.backgroundColor = FlxColor.BLACK;
        weekTitleInput.caretColor = FlxColor.WHITE;
        add(weekTitleInput);

        txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font("vcr.ttf"), 32);
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);

        changeColorLabel = new AlphabetOptimized(0, 61, "Click here to change color", false, 0.5);
        changeColorLabel.x = FlxG.width - changeColorLabel.width - 5;
        changeColorLabel.alpha = 0.5;
        changeColorLabel.textColor = 0xFF000000;
        add(changeColorLabel);

        helpLabel = new AlphabetOptimized(0, FlxG.height - (40), "Click on any visual element to edit it.", false, 1 / 3);
        helpLabel.x = 0;
        helpLabel.alpha = 0.5;
        helpLabel.textColor = 0xFFFFFFFF;
        add(helpLabel);

		var co = 0xFFF9CF51;
		if (week.color != null) {
			var c = FlxColor.fromString(week.color);
			if (c != null) co = c;
		}
        yellowBG.color = co;

        UI = new FlxUITabMenu(null, [
            {
                name: "global",
                label: "Week Settings"
            },
            {
                name: "dad",
                label: "Opponent"
            },
            {
                name: "bf",
                label: "Boyfriend"
            },
            {
                name: "gf",
                label: "Girlfriend"
            }
        ], true);


        addWeekConfig();
        addBFTab();
        addGFTab();
        addDadTab();

        camDeezNuts = new FlxCamera();
        camDeezNuts.bgColor = 0;
        FlxG.cameras.add(camDeezNuts, false);

        UI.resize(Std.int(FlxG.width / 3), FlxG.height - (yellowBG.y + yellowBG.height));
        UI.x = Std.int(FlxG.width * (2 / 3));
        UI.y = yellowBG.y + yellowBG.height;
        UI.cameras = [camDeezNuts];
        add(UI);


        updateBG();
        updateDad();
        updateBf();
        updateGf();
        updateButton();
        updateTrackList();
    }

    var bfSpriteBox:FlxUIInputText;
    var bfAnimBox:FlxUIInputText;
    var bfConfAnimBox:FlxUIInputText;
    var bfOffsetX:FlxUINumericStepper;
    var bfOffsetY:FlxUINumericStepper;
    var bfScale:FlxUINumericStepper;

    public function addBFTab() {
        var tab = new FlxUI(null, UI);
        tab.name = "bf";

        var w = Std.int(FlxG.width / 3);
        var label:FlxUIText;
        tab.add(label = new FlxUIText(10, 10, 0, "Sprite Path"));
        tab.add(bfSpriteBox = new FlxUIInputText(label.x, label.y + label.height, w - 50, week.bf.file));
        tab.add(label = new FlxUIText(10, bfSpriteBox.y + bfSpriteBox.height + 5, 0, "Animation name"));
        tab.add(bfAnimBox = new FlxUIInputText(label.x, label.y + label.height, w - 20, week.bf.animation == null ? "" : week.bf.animation));
        tab.add(label = new FlxUIText(10, bfAnimBox.y + bfAnimBox.height + 5, 0, "Offset"));
        tab.add(bfOffsetX = new FlxUINumericStepper(10, label.y + label.height, 10, week.bf.offset[0], -1000, 1000, 0));
        tab.add(bfOffsetY = new FlxUINumericStepper(bfOffsetX.x + bfOffsetX.width + 10, label.y + label.height, 10, week.bf.offset[0], -1000, 1000, 0));
        tab.add(label = new FlxUIText(10, bfOffsetY.y + bfOffsetY.height + 5, 0, "Scale"));
        tab.add(bfScale = new FlxUINumericStepper(10, label.y + label.height, 0.1, week.bf.scale, -10, 10, 1));
        tab.add(label = new FlxUIText(10, bfScale.y + bfScale.height + 5, 0, "Animation name on select (leave blank for none)"));
        tab.add(bfConfAnimBox = new FlxUIInputText(label.x, label.y + label.height, w - 60, week.bf.confirmAnim == null ? "" : week.bf.confirmAnim));

        var testButton:FlxUIButton;
        tab.add(testButton = new FlxUIButton(bfConfAnimBox.x + bfConfAnimBox.width + 10, bfConfAnimBox.y, "Test", function() {
            if (bf != null) {
                bf.animation.addByPrefix(week.bf.confirmAnim, week.bf.confirmAnim, 24, false);
                bf.animation.play(week.bf.confirmAnim);
            }
        }));
        testButton.resize(40, 20);

        UI.addGroup(tab);
    }

    var gfSpriteBox:FlxUIInputText;
    var gfAnimBox:FlxUIInputText;
    var gfConfAnimBox:FlxUIInputText;
    var gfOffsetX:FlxUINumericStepper;
    var gfOffsetY:FlxUINumericStepper;
    var gfScale:FlxUINumericStepper;

    public function addGFTab() {
        var tab = new FlxUI(null, UI);
        tab.name = "gf";

        var w = Std.int(FlxG.width / 3);
        var label:FlxUIText;
        tab.add(label = new FlxUIText(10, 10, 0, "Sprite Path"));
        tab.add(gfSpriteBox = new FlxUIInputText(label.x, label.y + label.height, w - 50, week.gf.file));
        tab.add(label = new FlxUIText(10, gfSpriteBox.y + gfSpriteBox.height + 5, 0, "Animation name"));
        tab.add(gfAnimBox = new FlxUIInputText(label.x, label.y + label.height, w - 20, week.gf.animation == null ? "" : week.gf.animation));
        tab.add(label = new FlxUIText(10, gfAnimBox.y + gfAnimBox.height + 5, 0, "Offset"));
        tab.add(gfOffsetX = new FlxUINumericStepper(10, label.y + label.height, 10, week.gf.offset[0], -1000, 1000, 0));
        tab.add(gfOffsetY = new FlxUINumericStepper(gfOffsetX.x + gfOffsetX.width + 10, label.y + label.height, 10, week.gf.offset[0], -1000, 1000, 0));
        tab.add(label = new FlxUIText(10, gfOffsetY.y + gfOffsetY.height + 5, 0, "Scale"));
        tab.add(gfScale = new FlxUINumericStepper(10, label.y + label.height, 0.1, week.gf.scale, -10, 10, 1));
        tab.add(label = new FlxUIText(10, gfScale.y + gfScale.height + 5, 0, "Animation name on select (leave blank for none)"));
        tab.add(gfConfAnimBox = new FlxUIInputText(label.x, label.y + label.height, w - 60, week.gf.confirmAnim == null ? "" : week.gf.confirmAnim));
        var testButton:FlxUIButton;
        tab.add(testButton = new FlxUIButton(gfConfAnimBox.x + gfConfAnimBox.width + 10, gfConfAnimBox.y, "Test", function() {
            if (gf != null) {
                gf.animation.addByPrefix(week.gf.confirmAnim, week.gf.confirmAnim, 24, false);
                gf.animation.play(week.gf.confirmAnim);
            }
        }));
        testButton.resize(40, 20);

        UI.addGroup(tab);
    }

    var dadSpriteBox:FlxUIInputText;
    var dadAnimBox:FlxUIInputText;
    var dadConfAnimBox:FlxUIInputText;
    var dadOffsetX:FlxUINumericStepper;
    var dadOffsetY:FlxUINumericStepper;
    var dadScale:FlxUINumericStepper;

    public function addDadTab() {
        var tab = new FlxUI(null, UI);
        tab.name = "dad";

        var w = Std.int(FlxG.width / 3);
        var label:FlxUIText;
        tab.add(label = new FlxUIText(10, 10, 0, "Sprite Path"));
        tab.add(dadSpriteBox = new FlxUIInputText(label.x, label.y + label.height, w - 50, week.dad.file));
        tab.add(label = new FlxUIText(10, dadSpriteBox.y + dadSpriteBox.height + 5, 0, "Animation name"));
        tab.add(dadAnimBox = new FlxUIInputText(label.x, label.y + label.height, w - 20, week.dad.animation == null ? "" : week.dad.animation));
        tab.add(label = new FlxUIText(10, dadAnimBox.y + dadAnimBox.height + 5, 0, "Offset"));
        tab.add(dadOffsetX = new FlxUINumericStepper(10, label.y + label.height, 10, week.dad.offset[0], -1000, 1000, 0));
        tab.add(dadOffsetY = new FlxUINumericStepper(dadOffsetX.x + dadOffsetX.width + 10, label.y + label.height, 10, week.dad.offset[0], -1000, 1000, 0));
        tab.add(label = new FlxUIText(10, dadOffsetY.y + dadOffsetY.height + 5, 0, "Scale"));
        tab.add(dadScale = new FlxUINumericStepper(10, label.y + label.height, 0.1, week.dad.scale, -10, 10, 1));
        tab.add(label = new FlxUIText(10, dadScale.y + dadScale.height + 5, 0, "Animation name on select (leave blank for none)"));
        tab.add(dadConfAnimBox = new FlxUIInputText(label.x, label.y + label.height, w - 60, week.dad.confirmAnim == null ? "" : week.dad.confirmAnim));
        var testButton:FlxUIButton;
        tab.add(testButton = new FlxUIButton(dadConfAnimBox.x + dadConfAnimBox.width + 10, dadConfAnimBox.y, "Test", function() {
            if (dad != null) {
                dad.animation.addByPrefix(week.dad.confirmAnim, week.dad.confirmAnim, 24, false);
                dad.animation.play(week.dad.confirmAnim);
            }
        }));
        testButton.resize(40, 20);

        UI.addGroup(tab);
    }


    public function addWeekConfig() {
        var weeks = new FlxUI(null, UI);
        weeks.name = "global";


        var w = Std.int(FlxG.width / 3);
        var label:FlxUIText;
        weeks.add(label = new FlxUIText(10, 10, 0, "Week Name"));
        weeks.add(weekNameTextBox = new FlxUIInputText(label.x, label.y + label.height, w - 20, week.name));

        weeks.add(label = new FlxUIText(weekNameTextBox.x, weekNameTextBox.y + weekNameTextBox.height + 5, 0, "Song Tracks (separate with \",\")"));
        weeks.add(songsListBox = new FlxUIInputText(label.x, label.y + label.height, w - 20, week.songs.join(", ")));

        weeks.add(label = new FlxUIText(songsListBox.x, songsListBox.y + songsListBox.height + 5, 0, "Button sprite"));
        weeks.add(buttonSpriteBox = new FlxUIInputText(label.x, label.y + label.height, w - 50, week.buttonSprite));

        var browseButton:FlxUIButton;
        weeks.add(browseButton = new FlxUIButton(buttonSpriteBox.x + buttonSpriteBox.width + 10, buttonSpriteBox.y - 2, "", function() {
            persistentUpdate = false;
            openSubState(new FileExplorer(Settings.engineSettings.data.selectedMod, Bitmap, "images/", function(e) {
                if (!e.toLowerCase().startsWith("images/")) {
                    ToolboxMessage.showMessage("Error", "Button must be in \"images\" folder.");
                    return;
                }
                e = e.substr(7);
                while(e.startsWith("/")) {
                    e = e.substr(1);
                }
                buttonSpriteBox.text = week.buttonSprite = Path.withoutExtension(e);
                updateButton();
            }));
        }));
        browseButton.resize(20, 20);
        browseButton.addIcon(CoolUtil.createUISprite("folder"), 2, 2, true);


        weeks.add(label = new FlxUIText(buttonSpriteBox.x, buttonSpriteBox.y + buttonSpriteBox.height + 5, 0, "On select SFX"));
        weeks.add(sfxBox = new FlxUIInputText(label.x, label.y + label.height, w - 80, week.selectSFX == null ? "confirmMenu" : week.selectSFX));
        var playButton:FlxUIButton;
        weeks.add(playButton = new FlxUIButton(sfxBox.x + sfxBox.width + 10, sfxBox.y, "", function() {
            FlxG.sound.play(Paths.sound(week.selectSFX));
        }));
        playButton.color = 0xFF44FF44;
        playButton.resize(20, 20);
        var playIcon:FlxSprite;
        weeks.add(playIcon = CoolUtil.createUISprite("play"));
        playIcon.setPosition(playButton.x + 2, playButton.y + 2);
        var browseButton:FlxUIButton;
        weeks.add(browseButton = new FlxUIButton(sfxBox.x + sfxBox.width + 40, sfxBox.y, "", function() {
            persistentUpdate = false;
            openSubState(new FileExplorer(Settings.engineSettings.data.selectedMod, OGG, "sounds/", function(e) {
                if (!e.toLowerCase().startsWith("sounds/")) {
                    ToolboxMessage.showMessage("Error", "Button must be in \"sounds\" folder.");
                    return;
                }
                e = e.substr(7);
                while(e.startsWith("/")) {
                    e = e.substr(1);
                }
                sfxBox.text = week.selectSFX = Path.withoutExtension(e);
                updateButton();
            }));
        }));
        browseButton.resize(20, 20);
        browseButton.addIcon(CoolUtil.createUISprite("folder"), 2, 2, true);

        weeks.add(label = new FlxUIText(sfxBox.x, sfxBox.y + sfxBox.height + 5, 0, "BG Sprite Path (leave blank for none)"));
        weeks.add(bgInput = new FlxUIInputText(label.x, label.y + label.height, w - 50, week.bg == null ? "" : week.bg));
        var browseButton:FlxUIButton;
        weeks.add(browseButton = new FlxUIButton(bgInput.x + bgInput.width + 10, bgInput.y - 2, "", function() {
            persistentUpdate = false;
            openSubState(new FileExplorer(Settings.engineSettings.data.selectedMod, Bitmap, "images/", function(e) {
                if (!e.toLowerCase().startsWith("images/")) {
                    ToolboxMessage.showMessage("Error", "Button must be in \"images\" folder.");
                    return;
                }
                e = e.substr(7);
                while(e.startsWith("/")) {
                    e = e.substr(1);
                }
                bgInput.text = week.bg = Path.withoutExtension(e);
                updateBG();
            }));
        }));
        browseButton.resize(20, 20);
        browseButton.addIcon(CoolUtil.createUISprite("folder"), 2, 2, true);

        weeks.add(label = new FlxUIText(bgInput.x, bgInput.y + bgInput.height + 5, 0, "BG Sprite Animation"));
        weeks.add(bgAnimInput = new FlxUIInputText(label.x, label.y + label.height, w - 20, week.bgAnim == null ? "" : week.bgAnim));

        var saveButton:FlxUIButton;
        weeks.add(saveButton = new FlxUIButton(bgAnimInput.x, bgAnimInput.y + bgAnimInput.height + 5, "Save", function() {
            if (save()) {
                openSubState(ToolboxMessage.showMessage("Success", "Your week has been saved."));
            } else {
                openSubState(ToolboxMessage.showMessage("Error", "Your week could not be saved."));
            }
        }));
        saveButton.color = 0xFF44FF44;
        saveButton.label.color = 0xFF000000;

        oldSongsText = songsListBox.text;
        
        UI.addGroup(weeks);
    }

    public function updateTrackList() {
        txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = week.songs;

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text += "\n";
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
    }

    var oldSongsText = "";

    public override function openSubState(s:FlxSubState) {
        // shrex
        if (camDeezNuts != null) s.cameras = [camDeezNuts];
        super.openSubState(s);
    }
    var moving:Bool = false;
    var movingOGCursorPos:FlxPoint;
    var movingOGOffset:FlxPoint;

    public override function update(elapsed:Float) {
        
        super.update(elapsed);
        if (switchin) return;
        var curPos:FlxPoint = FlxG.mouse.getScreenPosition();

        if (weekNameTextBox.hasFocus) {
            hasBeenSaved = week.name != (weekTitleInput.text = weekNameTextBox.text) && hasBeenSaved;
        } else {
            hasBeenSaved = week.name != (weekNameTextBox.text = weekTitleInput.text) && hasBeenSaved;
        }

        switch(UI.selected_tab_id) {
            case "bf":
                gf.alpha = dad.alpha = 0.5;
                bf.alpha = 1;
            case "gf":
                bf.alpha = dad.alpha = 0.5;
                gf.alpha = 1;
            case "dad":
                bf.alpha = gf.alpha = 0.5;
                dad.alpha = 1;
            case "global":
                bf.alpha = gf.alpha = dad.alpha = 1;
        }

        week.selectSFX = sfxBox.text;
        if (moving) {
            UI.active = false;
            UI.alpha = FlxMath.lerp(UI.alpha, 0.5, 0.25 * elapsed * 60);

            if (FlxG.mouse.justReleased) {
                moving = false;
                UI.active = true;
                UI.selected_tab_id = UI.selected_tab_id; // to prevent controls from other tabs from activating as well
            }

            var spr = switch(UI.selected_tab_id) {
                case "bf":
                    bf;
                case "gf":
                    gf;
                case "dad":
                    dad;
                default:
                    null;
            }
            if (spr != null) {
                var scale = FlxMath.bound(spr.scale.x + (FlxG.mouse.wheel * 0.1), -10, 10);
                if (scale != spr.scale.x) {
                    spr.scale.set(scale, scale);
                    spr.updateHitbox();
                    bfScale.value = switch(UI.selected_tab_id) {
                        case "bf":
                            week.bf.scale = scale;
                        case "dad":
                            week.dad.scale = scale;
                        case "gf":
                            week.gf.scale = scale;
                        default:
                            scale;
                    }
                }
                spr.offset.set(movingOGOffset.x - (curPos.x - movingOGCursorPos.x), movingOGOffset.y - (curPos.y - movingOGCursorPos.y));
            }
        } else if (FlxG.mouse.justPressed && curPos.x > changeColorLabel.x && curPos.x < FlxG.width && curPos.y > 61 && curPos.y < 61 + 50) {
            // color picker time
            persistentUpdate = false;
            openSubState(new ColorPicker(yellowBG.color, function(c) {
                yellowBG.color = c;
            }));
        } else {
            var alpha = UI.alpha = FlxMath.lerp(UI.alpha, 1, 0.25 * elapsed * 60);
            UI.forEach(function(e) {
                if (Std.isOfType(e, FlxSprite)) {
                    cast(e, FlxSprite).alpha = alpha;
                }
            }, true);

            
            if (FlxG.mouse.justPressed && curPos.y > yellowBG.y && curPos.y < yellowBG.y + yellowBG.height) {
                moving = true;
                movingOGCursorPos = curPos;

                switch(Std.int(curPos.x / FlxG.width * 3)) {
                    case 0:
                        UI.selected_tab_id = "dad";
                        movingOGOffset = new FlxPoint(dad.offset.x, dad.offset.y);
                    case 1:
                        UI.selected_tab_id = "bf";
                        movingOGOffset = new FlxPoint(bf.offset.x, bf.offset.y);
                    case 2:
                        UI.selected_tab_id = "gf";
                        movingOGOffset = new FlxPoint(gf.offset.x, gf.offset.y);
                }
            }
        }

        if (oldSongsText != (oldSongsText = songsListBox.text)) {
            week.songs = [for(e in songsListBox.text.split(",")) if (e.trim() != "") e.trim()];
            hasBeenSaved = false;
            updateTrackList();
        }

        /**
         * BF STUFF
         */
        if (week.bf.file != (week.bf.file = bfSpriteBox.text)) {
            hasBeenSaved = false;
            updateBf();
        }
        if (week.bf.animation != (week.bf.animation = bfAnimBox.text)) {
            hasBeenSaved = false;
            updateBf();
        }

        if (week.bg != (week.bg = bgInput.text)) {
            hasBeenSaved = false;
            updateBG();
        }

        if (week.bgAnim != (week.bgAnim = bgAnimInput.text)) {
            hasBeenSaved = false;
            if (bg != null) {
                bg.animation.addByPrefix(week.bgAnim, week.bgAnim, 24, true);
                bg.animation.play(week.bgAnim);
            }
        }

        @:privateAccess
        if (!moving && (cast(bfOffsetX.text_field, FlxUIInputText).hasFocus || cast(bfOffsetY.text_field, FlxUIInputText).hasFocus || cast(bfScale.text_field, FlxUIInputText).hasFocus || (curPos.x > FlxG.width * (2 / 3) && curPos.y > yellowBG.y + yellowBG.height))) {
            bf.scale.set(bfScale.value, bfScale.value);
            bf.updateHitbox();
            bf.offset.set(bfOffsetX.value, bfOffsetY.value);
        } else {
            bfOffsetX.value = bf.offset.x;
            bfOffsetY.value = bf.offset.y;
            bfScale.value = bf.scale.x;
        }
        week.bf.confirmAnim = bfConfAnimBox.text;

        /**
         * GF STUFF
         */
         if (week.gf.file != (week.gf.file = gfSpriteBox.text)) {
            updateGf();
        }
        if (week.gf.animation != (week.gf.animation = gfAnimBox.text)) {
            updateGf();
        }

        @:privateAccess
        if (!moving && (cast(gfOffsetX.text_field, FlxUIInputText).hasFocus || cast(gfOffsetY.text_field, FlxUIInputText).hasFocus || cast(gfScale.text_field, FlxUIInputText).hasFocus || (curPos.x > FlxG.width * (2 / 3) && curPos.y > yellowBG.y + yellowBG.height))) {
            gf.scale.set(gfScale.value, gfScale.value);
            gf.updateHitbox();
            gf.offset.set(gfOffsetX.value, gfOffsetY.value);
        } else {
            gfOffsetX.value = gf.offset.x;
            gfOffsetY.value = gf.offset.y;
            gfScale.value = gf.scale.x;
        }
        week.gf.confirmAnim = gfConfAnimBox.text;

        /**
         * DAD STUFF
         */
         if (week.dad.file != (week.dad.file = dadSpriteBox.text)) {
            updateDad();
        }
        if (week.dad.animation != (week.dad.animation = dadAnimBox.text)) {
            updateDad();
        }

        @:privateAccess
        if (!moving && (cast(dadOffsetX.text_field, FlxUIInputText).hasFocus || cast(dadOffsetY.text_field, FlxUIInputText).hasFocus || cast(dadScale.text_field, FlxUIInputText).hasFocus || (curPos.x > FlxG.width * (2 / 3) && curPos.y > yellowBG.y + yellowBG.height))) {
            dad.scale.set(dadScale.value, dadScale.value);
            dad.updateHitbox();
            dad.offset.set(dadOffsetX.value, dadOffsetY.value);
        } else {
            dadOffsetX.value = dad.offset.x;
            dadOffsetY.value = dad.offset.y;
            dadScale.value = dad.scale.x;
        }
        week.dad.confirmAnim = dadConfAnimBox.text;



        if (week.buttonSprite != (week.buttonSprite = buttonSpriteBox.text)) {
            updateButton();
        }
        if (FlxG.keys.justPressed.ESCAPE) {
            exit();
        }
        weekTitleInput.x = FlxG.width - weekTitleInput.width;

        for(e in [weekTitleInput]) {
            var dest:Float = 0;
            if (e.hasFocus) {
                dest = 0.15;
            } else if (FlxG.mouse.overlaps(e)) {
                dest = 0.10;
            }
            var c:FlxColor = e.backgroundColor;
            c.redFloat = c.greenFloat = c.blueFloat = FlxMath.lerp(c.redFloat, dest, 0.25 * elapsed * 60);
            e.backgroundColor = c;
        }
    }
    public static var fromStory:Bool = false;
    public var switchin:Bool = false;
    public function exit() {
        if (hasBeenSaved) {
            if (fromStory)
                FlxG.switchState(new StoryMenuState());
            else
                FlxG.switchState(new ToolboxHome(Settings.engineSettings.data.selectedMod));
            switchin = true;
        } else {
            openSubState(new ToolboxMessage("Week not saved.", "The week you're currently editing has not been saved yet. Do you want to save it now?", [
                {
                    label: "Save",
                    onClick: function(m) {
                        save();
                        exit();
                    }
                },
                {
                    label: "Do not save",
                    onClick: function(m) {
                        hasBeenSaved = true;
                        exit();
                    }
                },
                {
                    label: "Cancel",
                    onClick: function(m) {
                        
                    }
                }
            ]));
        }
    }
    
    public function save():Bool {
        week.gf.offset = [gf.offset.x, gf.offset.y];
        week.gf.flipX = gf.flipX;
        week.gf.scale = gf.scale.x;

        week.bf.offset = [bf.offset.x, bf.offset.y];
        week.bf.flipX = bf.flipX;
        week.bf.scale = bf.scale.x;

        week.dad.offset = [dad.offset.x, dad.offset.y];
        week.dad.flipX = dad.flipX;
        week.dad.scale = dad.scale.x;

        week.name = weekTitleInput.text;
        
        week.bg = bgInput.text;
        week.bgAnim = bgAnimInput.text;
        
        var color:FlxColor = yellowBG.color;
        week.color = color.toHexString(true);

        
        var text = Json.stringify(weeks);
        try {
            File.saveContent('${Paths.modsPath}/${Settings.engineSettings.data.selectedMod}/weeks.json', text);
            Assets.cache.clear(Paths.getPath('weeks.json', TEXT, 'mods/${Settings.engineSettings.data.selectedMod}'));
        } catch(e) {
            trace(e.details());
            return hasBeenSaved;
        }
        return hasBeenSaved = true;
    }
}