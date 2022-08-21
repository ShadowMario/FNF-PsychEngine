import flixel.util.FlxColor;
import flixel.text.FlxText;
import haxe.Json;
import openfl.utils.Assets;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;

typedef JSONCreditChar = {
    var name:String;
    var icon:String;
    var role:String;
    var urls:Array<Url>;
}

typedef JSONShit = {
    var credits:Array<JSONCreditChar>;
}

typedef Url = {
    var name:String;
    var url:String;
}

typedef CreditChar = {
    var nameAlphabet:Alphabet;
    var icon:FlxSprite;
    var role:FlxText;
    var json:JSONCreditChar;
}

class CreditsState extends MusicBeatState {
    var chars:Array<CreditChar> = [];
    var curSelected:Int = 0;
    var curSocial:Int = 0;
    var camFollow:FlxSprite;
    var socialThingy:FlxText;

    public override function create() {
        super.create();

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGYoshiCrafter'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1 / 0.75));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        socialThingy = new FlxText(0, 0, 0, "< Social Network >");
        socialThingy.setFormat(Paths.font("vcr.ttf"), Std.int(44), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        socialThingy.antialiasing = true;
        add(socialThingy);

        camFollow = new FlxSprite(FlxG.width / 2, 0);
        FlxG.camera.follow(camFollow, LOCKON, 0.08);
        FlxG.camera.zoom = 0.75;

        var mFolder = Paths.modsPath;
        var y = 0;

        var mods = ["\\", "Friday Night Funkin'"];
        if (Settings.engineSettings.data.selectedMod.toLowerCase() != "friday night funkin'")
            mods.insert(0, Settings.engineSettings.data.selectedMod);
        
        for (mod in mods) {
			var path:String = Paths.getPath('credits.json', TEXT, mod == "\\" ? "preload" : 'mods/$mod', true);
            if (Assets.exists(path)) {
                var json:JSONShit = null;
                try {
                    json = Json.parse(Assets.getText(Paths.getPath('credits.json', TEXT, mod == "\\" ? "preload" : 'mods/$mod', true)));
                } catch(e) {
                    LogsOverlay.trace('Failed to parse credits json for $mod.\n$e');
                }

                if (json != null) {
                    y++;
                    var modTitle:Alphabet = new Alphabet(0, 125 * y, (mod == "\\") ? "YoshiCrafter Engine" : ModSupport.getModName(mod), true, false);
                    modTitle.x = (FlxG.width / 2) - (modTitle.width / 2);
                    add(modTitle);
                    y++;
                    for (modMaker in json.credits) {
                        var modMakerAlphabet:Alphabet = new Alphabet(0, 125 * y, modMaker.name);
                        modMakerAlphabet.x = -60;
                        y++;
                        add(modMakerAlphabet);

                        var icon:FlxSprite = new FlxSprite(modMakerAlphabet.x - 100, modMakerAlphabet.y + (modMakerAlphabet.height / 2) - (125 / 2));
                        var iconPath = modMaker.icon;
                        if (iconPath != null) {
                            var tex = Paths.image(iconPath, mod == "\\" ? 'preload' : 'mods/$mod');
                            if (tex != null)
                                icon.loadGraphic(tex);
                            else
                                icon.loadGraphic(Paths.image('creditEmptyIcon', 'preload'));
                            
                        } else
                            icon.loadGraphic(Paths.image('creditEmptyIcon', 'preload'));
                        
                        icon.setGraphicSize(125, 125);
                        icon.updateHitbox();
                        var sc = Math.min(icon.scale.x, icon.scale.y);
                        icon.scale.set(sc, sc);
                        icon.antialiasing = true;
                        add(icon);
                        icon.x = modMakerAlphabet.x - 10 - icon.width;
                        icon.y = (125 * y) - (125 / 2) - (icon.height / 2);
                        
                        var role:FlxText = new FlxText(modMakerAlphabet.x, modMakerAlphabet.y + 110, Std.int(FlxG.width - modMakerAlphabet.x - 20), modMaker.role);
                        role.setFormat(Paths.font("vcr.ttf"), Std.int(22), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                        role.antialiasing = true;
                        add(role);
                        chars.push({
                            nameAlphabet: modMakerAlphabet,
                            icon: icon,
                            role: role,
                            json: modMaker
                        });
                    }
                }
            }

        }
        changeSelection();
    }

    
    public function changeSelection(curChange:Int = 0) {
        var oldSocial = "";
        try {
            oldSocial = chars[curSelected].json.urls[curSocial].name;
        } catch(e) {

        }
        curSelected += curChange;
        if (curSelected < 0) curSelected = chars.length - 1;
        if (curSelected >= chars.length) curSelected = 0;

        for(i in 0...chars.length) {
            var e = chars[i];
            e.icon.alpha = (i == curSelected) ? 1 : 0.4;
            e.role.alpha = (i == curSelected) ? 1 : 0.4;
            e.nameAlphabet.alpha = (i == curSelected) ? 1 : 0.4;
            if (i == curSelected) {
                camFollow.y = e.nameAlphabet.y + (e.nameAlphabet.height / 2);
            }
        }
        curSocial = 0;
        if (chars[curSelected].json.urls != null) {
            for(i in 0...chars[curSelected].json.urls.length) {
                if (chars[curSelected].json.urls[i].name.toLowerCase() == oldSocial.toLowerCase()) {
                    curSocial = i;
                    break;
                }
            }
        }
        CoolUtil.playMenuSFX(0);
        changeSocial();
    }
    public function changeSocial(curChange:Int = 0) {
        var exists = chars[curSelected].json.urls != null;
        if (exists) exists = exists && (chars[curSelected].json.urls.length != 0);


        if (exists) {
            curSocial += curChange;
            if (curSocial >= chars[curSelected].json.urls.length) curSocial = 0;
            if (curSocial < 0) curSocial = chars[curSelected].json.urls.length - 1;

            var social = chars[curSelected].json.urls[curSocial].name;
            socialThingy.text = '< $social >';
            socialThingy.x = FlxG.width + ((FlxG.width / 0.75 - FlxG.width) / 2) - 25 - socialThingy.width;
            socialThingy.y = chars[curSelected].nameAlphabet.y + (chars[curSelected].nameAlphabet.height / 2);
        } else {
            socialThingy.text = "";
        }
        
    } 
    public override function update(elapsed) {
        super.update(elapsed);
        if (controls.UP_P) {
            changeSelection(-1);
        }
        if (controls.DOWN_P) {
            changeSelection(1);
        }

        if (controls.ACCEPT) {
            FlxG.openURL(chars[curSelected].json.urls[curSocial].url);
        }

        if (controls.LEFT_P) {
            changeSocial(-1);
        }
        if (controls.RIGHT_P) {
            changeSocial(1);
        }

        if (controls.BACK) {
			CoolUtil.playMenuSFX(2);
            FlxG.switchState(new MainMenuState());
        }
    }
}