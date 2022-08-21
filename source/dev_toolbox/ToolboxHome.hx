package dev_toolbox;


import Discord.DiscordClient;
import discord_rpc.DiscordRpc;
import dev_toolbox.toolbox_tabs.*;
import lime.math.Rectangle;
import dev_toolbox.file_explorer.FileExplorer;
import WeeksJson.FNFWeek;
import Song.SwagSong;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.song_editor.SongCreator;
import FreeplayState.FreeplaySongList;
import openfl.display.PNGEncoderOptions;
import sys.io.File;
import openfl.display.BitmapData;
import lime.ui.FileDialogType;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.addons.ui.*;
import flixel.FlxG;
import haxe.Json;
import FreeplayState;
import WeeksJson;
import flixel.text.FlxText;

using StringTools;

class ToolboxHome extends MusicBeatState {

    public var nonEditableMods:Array<String> = ["Friday Night Funkin'", "YoshiCrafterEngine"];

    public static var selectedMod:String = "Friday Night Funkin'";
    public var oldTab:String = "";
    public var bg:FlxSprite;
    public var closeButton:FlxUIButton;
    public var helpButton:FlxUIButton;
    public var docButton:FlxUIButton;
    public var bgColorTween:FlxTween;
    public var bgTweenColor(default, set):Null<FlxColor>;
    private function set_bgTweenColor(c:Null<FlxColor>) {
        bgTweenColor = c;
        if (bgTweenColor == null) bgTweenColor = 0xFFFFFFFF;
        if (bgColorTween != null) {
            bgColorTween.cancel();
            bgColorTween.destroy();
        }
        bgColorTween = FlxTween.color(bg, 1, bg.color, bgTweenColor, {
            ease : FlxEase.quartInOut
        });
        return c;
    }
    
    public var UI_Tabs:FlxUITabMenu;
    public var cTween:FlxTween;

    public var tabs:Map<String, ToolboxTab> = [];

    public override function new(?mod:String) {
        super();
        if (mod != null) selectedMod = mod;
    }

    public override function create() {
        super.create();
        var mod = selectedMod;
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/');
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/data/');
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/images/');
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/songs/');
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/sounds/');
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/music/');
        #if desktop
            DiscordClient.changePresence("In the Toolbox", null, "Toolbox Icon");
        #end
        if (ModSupport.modConfig[mod] == null) {
            var conf:ModConfig = {
                name : mod,
                description : "(No description)",
                titleBarName: "Friday Night Funkin' - " + mod,
                keyNumbers: [4],
                BFskins: [],
                GFskins: [],
                skinnableBFs : [],
                skinnableGFs : [],
                locked: false,
                intro: {
					bpm: 102,
					authors: ['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er'],
					present: 'present',
					assoc: ['In association', 'with'],
					newgrounds: 'newgrounds',
					gameName: ['Friday Night Funkin\'', 'YoshiCrafter', 'Engine']
                }
            };
            ModSupport.modConfig[mod] = conf;
        }
        bg = CoolUtil.addWhiteBG(this);
        bg.color = 0xFF8C8C8C;
        bgTweenColor = 0xFF8C8C8C;
        var tabs = [
            {name: "info", label: 'Mod Info'},
			{name: "songs", label: 'Songs'},
			{name: "chars", label: 'Characters'},
			{name: "weeks", label: 'Weeks'},
			{name: "stages", label: 'Stages JSONs'},
			{name: "songconf", label: 'Song Config'},
			{name: "medals", label: 'Medals'},
		];
        UI_Tabs = new FlxUITabMenu(null, tabs, true);
        UI_Tabs.x = 0;
        UI_Tabs.resize(FlxG.width - 220, 22);
        UI_Tabs.scrollFactor.set();
        add(UI_Tabs);
        var coolTabFadeout = new FlxSprite(0, 20).makeGraphic(FlxG.width, 10, 0x00000000);
        coolTabFadeout.pixels.lock();
        for(y in 0...coolTabFadeout.pixels.height) {
            var c:FlxColor = 0xFF8C8C8C;
            c.alphaFloat = 1 - (y / coolTabFadeout.pixels.height);
            coolTabFadeout.pixels.fillRect(new openfl.geom.Rectangle(0, y, FlxG.width, 1), c);
        }
        coolTabFadeout.pixels.unlock();
        add(coolTabFadeout);

        new InfoTab(0, 22, this);
        new CharTab(0, 22, this);
        new WeeksTab(0, 22, this);
        new SongTab(0, 22, this);
        new StagesTab(0, 22, this);
        new SongConfTab(0, 22, this);
        new MedalsTab(0, 22, this);

        closeButton = new FlxUIButton(FlxG.width - 20, 0, "X", function() {
            FlxG.switchState(new ToolboxMain());
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        add(closeButton);

        docButton = new FlxUIButton(FlxG.width - 120, 0, "Documentation", function() {
            FlxG.openURL("https://yoshicrafter29.github.io/YoshiCrafterEngine-Doc/");
        });
        docButton.color = 0xFF4444FF;
        docButton.resize(100, 20);
        docButton.label.color = FlxColor.WHITE;
        add(docButton);

        helpButton = new FlxUIButton(FlxG.width - 220, 0, "Open Folder", function() {
            CoolUtil.openFolder('${Paths.modsPath}/$mod/');
        });
        helpButton.color = 0xFFFFA244;
        helpButton.resize(100, 20);
        helpButton.label.color = FlxColor.WHITE;
        add(helpButton);
    }

    public function onChangeTab(tab:String) {
        if (oldTab != "") {
            tabs[oldTab].onTabExit();
            remove(tabs[oldTab]);
        }
        oldTab = tab;
        add(tabs[tab]);
        tabs[oldTab].onTabEnter();
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);

        FlxMath.lerp(bg.color.redFloat, bgTweenColor.redFloat, 0.2);
        FlxMath.lerp(bg.color.greenFloat, bgTweenColor.greenFloat, 0.2);
        FlxMath.lerp(bg.color.blueFloat, bgTweenColor.blueFloat, 0.2);

        if (UI_Tabs.selected_tab_id != oldTab) {
            onChangeTab(UI_Tabs.selected_tab_id);
            oldTab = UI_Tabs.selected_tab_id;
        }

        tabs[oldTab].tabUpdate(elapsed);
        
    }
}