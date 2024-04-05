package states.editors;

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;

typedef ModFolder = {
    var name:String;
    var description:String;
    var restart:Bool;
    var runsGlobally:Bool;
    var color:Array<Int>;
    var discordRPC:String;
    var iconFramerate:Int;
}

class ModSetupTabs extends FlxUITabMenu
{
    var tabGroup:FlxUI;

    var modFolderInput:FlxUIInputText;
    var modNameInput:FlxUIInputText;
    var modDescInput:FlxUIInputText;

    var modColorInputR:FlxUIInputText;
    var modColorInputG:FlxUIInputText;
    var modColorInputB:FlxUIInputText;

    var modDiscordInput:FlxUIInputText;
    var modIconFramerateInput:FlxUIInputText;

    var createButton:FlxUIButton;

    var restartCheck:FlxUICheckBox;
    var globalCheck:FlxUICheckBox;

    var focusList:Array<FlxUIInputText> = [];

    var DEFAULT_MOD:ModFolder = {
        name: "Name",
        description: "Description",
        restart: false,
        runsGlobally: false,
        color: [170, 0, 255],
        discordRPC: "863222024192262205",
        iconFramerate: 10
    };
    
    public function getFocus():Bool
    {
        for (i in focusList) if (i.hasFocus) return true;
        return false;
    }

    static final invalidFolderCharacters:Array<String> = ["/", ":", "*", "?", '"', "<", ">", "|", "."];

    public function new()
    {
        super(null, [{name: "Setup Mod Folder", label: "Setup Mod Folder"}], true);

        screenCenter();
        setPosition(300, 250);
        
        resize(400, 400);

        selected_tab = 0;

        tabGroup = new FlxUI(null, this);
        tabGroup.name = "Setup Mod Folder";
        addGroup(tabGroup);

        final _sep:Int = 35;

        modFolderInput = new FlxUIInputText(25, 25, 350, "folder");
        addToGroup(modFolderInput, "Mod Folder:", true);

        modNameInput = new FlxUIInputText(25, 25 + _sep, 350, "Name");
        addToGroup(modNameInput, "Mod Name:", true);

        modDescInput = new FlxUIInputText(25, 25 + _sep * 2, 350, "Description");
        modDescInput.lines = 999;
        addToGroup(modDescInput, "Mod Description:", true);

        modColorInputR = new FlxUIInputText(25, 25 + _sep * 3, 350, "0-255");
        addToGroup(modColorInputR, "Mod Color (Red):", true);

        modColorInputG = new FlxUIInputText(25, 25 + _sep * 4, 350, "0-255");
        addToGroup(modColorInputG, "Mod Color (Green):", true);

        modColorInputB = new FlxUIInputText(25, 25 + _sep * 5, 350, "0-255");
        addToGroup(modColorInputB, "Mod Color (Blue):", true);

        modDiscordInput = new FlxUIInputText(25, 25 + _sep * 6, 350, "rpc");
        addToGroup(modDiscordInput, "Mod Discord RPC:", true);

        modIconFramerateInput = new FlxUIInputText(25, 25 + _sep * 7, 350, "framerate");
        addToGroup(modIconFramerateInput, "Mod Icon Framerate:", true);

        createButton = new FlxUIButton(310, 350, "Create Folder", () -> {
            final modFolder = modFolderInput.text;

            var keys:Array<String> = [];
            for (i in ModsSetupState.modFolderDirs.keys()) keys.push(i);
            if (keys.contains(modFolder))
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                return; // invalid folder name
            }

            for (i in invalidFolderCharacters) {
                if (modFolder.contains(i) || modFolder.endsWith(".")) {
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    return; // invalid folder character
                }
            }

            var createFunc = () -> {
                ModsSetupState.setupModFolder(modFolder);
                
                var _jsonData = copyJson(DEFAULT_MOD);
                _jsonData.name = modNameInput.text;
                _jsonData.description = modDescInput.text;
                _jsonData.restart = restartCheck.checked;
                _jsonData.runsGlobally = globalCheck.checked;
                _jsonData.color = [Std.parseInt(modColorInputR.text), Std.parseInt(modColorInputG.text), Std.parseInt(modColorInputB.text)];
                _jsonData.discordRPC = modDiscordInput.text;
                _jsonData.iconFramerate = Std.parseInt(modIconFramerateInput.text);

                var _jsonStr = Json.stringify(_jsonData, "\t");
                File.saveContent('mods/$modFolder/pack.json', _jsonStr);
                FlxG.sound.play(Paths.sound('confirmMenu'));
            }

            if (FileSystem.exists('mods/$modFolder')) {
                FlxG.state.openSubState(new substates.Prompt("Mod folder\n$modFolder\nalready exists\n\nAre you sure you want to\noverwrite this folder?", 
                    0, createFunc, () -> {
                        FlxG.state.closeSubState();
                    }));
            }
            else
                createFunc();
        });
        tabGroup.add(createButton);

        restartCheck = new FlxUICheckBox(25, 275, null, null, "Restart");
        restartCheck.checked = false;
        tabGroup.add(restartCheck);

        globalCheck = new FlxUICheckBox(25, 300, null, null, "Global Mod");
        globalCheck.checked = false;
        tabGroup.add(globalCheck);
    }

    function addToGroup(object:Dynamic, txt:String = "", focusPush:Bool = false) 
    {
        if (focusPush && object is FlxUIInputText) focusList.push(object);
        if (txt.length > 0) tabGroup.add(new FlxText(object.x, object.y - 15, txt));
        tabGroup.add(object);
    }

    function copyJson<T>(c:T):T
        return haxe.Unserializer.run(haxe.Serializer.run(c));
}

class ModsSetupState extends MusicBeatState
{
    var modTab:ModSetupTabs;

    override function create()
    {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set();
        bg.color = 0xFF353535;
        add(bg);

        modTab = new ModSetupTabs();
        add(modTab);

        super.create();
    }

    public static var modFolderDirs(default, never):Map<String, Array<String>> = [
        "scripts" => [],
        "shaders" => [],
        "videos" => [],
        "sounds" => [],
        "images" => [],
        "music" => [],
        "fonts" => [],
        "data" => [],
        "weeks" => [],
        "stages" => [],
        "songs" => [],
        "characters" => [],
        "custom_notetypes" => [],
        "custom_events" => []
    ];

    public static function setupModFolder(name:String)
    {
        for (k in modFolderDirs.keys())
        {
            var keyArr = modFolderDirs.get(k);
            createFolderWithTxt('$name/$k');
            for (i in keyArr) createFolderWithTxt('$name/$k/$i');
        }
    }

    static function createFolderWithTxt(path:String)
    {
        var pathParts = path.split("/");
        createFolder(path);
        File.saveContent('mods/$path/${pathParts[pathParts.length - 1]}-go-here.txt', "");
    }

    public static function createFolder(path:String, prefix:String = "mods/") 
    {
        var dirs = path.split("/");
        var lastDir = prefix;
        for (i in dirs) {
            final _ext = haxe.io.Path.extension(i);
            if (i == null || (_ext.length != 0 && !_ext.contains(" "))) continue;
            lastDir += '$i/';
            if (!FileSystem.exists(lastDir))
                FileSystem.createDirectory(lastDir);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (modTab.getFocus()) return;
        
        if (controls.BACK) 
        {
            MusicBeatState.switchState(new states.editors.MasterEditorMenu());
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }
    }
}
