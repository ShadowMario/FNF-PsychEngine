package options;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class DeleteSavesSubState extends MusicBeatSubstate
{
    private var curSelected:Int = 0;
    private var grpName:FlxTypedGroup<Alphabet>;
    private var daList:Array<Array<Dynamic>> = [];

    private var noModsTxt:FlxText;
    private var descBox:FlxSprite;
	private var descText:FlxText;
    private var statusText:FlxText;
    
    public function new()
    {
        super();

        #if desktop
		DiscordClient.changePresence("Modpacks Options Saves Menu", null);
		#end

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        noModsTxt = new FlxText(0, 0, FlxG.width, "NO MODPACK OPTIONS SAVES FOUND\nPRESS BACK TO EXIT", 48);
		if(FlxG.random.bool(0.1)) noModsTxt.text += '\nBITCH.';
		noModsTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noModsTxt.scrollFactor.set();
		noModsTxt.borderSize = 2;
		add(noModsTxt);
		noModsTxt.screenCenter();

		grpName = new FlxTypedGroup<Alphabet>();
		add(grpName);

        var titleText:Alphabet = new Alphabet(75, 40, 'Modpacks Options Saves Menu', true);
		titleText.scaleX = 0.6;
		titleText.scaleY = 0.6;
		titleText.alpha = 0.4;
		add(titleText);

        descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

        descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

        statusText = new FlxText(descBox.getGraphicMidpoint().x, descBox.y, descText.fieldWidth, "", 20);
		statusText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		statusText.scrollFactor.set();
		statusText.borderSize = 1.4;
		add(statusText);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "Select a mod's options saves that you want to delete: Press ACCEPT to delete the selected save / Press RESET to delete every save.", 16);
		text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

        var active:Array<String> = Paths.getActiveModsDir();
        for (save in ClientPrefs.data.modsOptsSaves.keys())
        {
            var toCheck:Array<Dynamic> = [save, null, false];
            if (save != '') {
                var path:String = Paths.mods(save + '/pack.json');
                if (FileSystem.exists(path)) {
                    var rawJson:String = File.getContent(path);
                    if (rawJson != null && rawJson.length > 0) {
                        toCheck[1] = Reflect.getProperty(Json.parse(rawJson), "name");
                        toCheck[2] = active.contains(save);
                    }
                }
                daList.push(toCheck);
            }
            else daList.insert(0, toCheck);
        }
        loadOptions();
    }

    private function loadOptions(mod:Array<Dynamic> = null)
    {
        if (mod != null) {
            ClientPrefs.data.modsOptsSaves.remove(mod[0]);
            daList.remove(mod);
        }

        while (grpName.members.length > 0) {
            grpName.remove(grpName.members[0], true);
        }

        if (daList.length > 0)
        {
            noModsTxt.visible = false;
            for (i in 0...daList.length)
            {
                var modName:Alphabet = new Alphabet(200, 360, daList[i][0] == '' ? 'Main Global Folder' : daList[i][0], true);
                modName.isMenuItem = true;
                modName.targetY = i;
                modName.snapToPosition();
                grpName.add(modName);
            }
            changeSelection(0, mod == null);
        }
        else noModsTxt.visible = true;
        descBox.visible = !noModsTxt.visible;
        descText.visible = !noModsTxt.visible;
        statusText.visible = !noModsTxt.visible;
    }

    var nextAccept:Int = 5;
    var holdTime:Float = 0;
    var noModsSine:Float = 0;
    override function update(elapsed:Float) {
        if(noModsTxt.visible)
		{
			noModsSine += 180 * elapsed;
			noModsTxt.alpha = 1 - Math.sin((Math.PI * noModsSine) / 180);
		}

        if (controls.BACK) {
            close();
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }

        if (daList.length > 0 && nextAccept <= 0)
        {
            if (controls.RESET) {
                ClientPrefs.data.modsOptsSaves = [];
                daList = [];
                loadOptions();
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }

            if (controls.ACCEPT) {
                loadOptions(daList[curSelected]);
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }

            if ((controls.UI_DOWN || controls.UI_UP) && daList.length > 1)
            {
                var shiftMult:Int = 1;
                if(FlxG.keys.pressed.SHIFT && daList.length > 5) shiftMult = 3;

                var upP = controls.UI_UP_P;
                var downP = controls.UI_DOWN_P;

                if (upP)
                {
                    changeSelection(-shiftMult);
                    holdTime = 0;
                }
                if (downP)
                {
                    changeSelection(shiftMult);
                    holdTime = 0;
                }
                
                var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
                holdTime += elapsed;
                var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

                if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                {
                    changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
                }
            }
        }

        if (nextAccept > 0) {
			nextAccept -= 1;
		}

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0, playSound:Bool = true)
	{
        if (playSound) {
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        curSelected += change;
        if (curSelected < 0)
            curSelected = daList.length - 1;
        if (curSelected >= daList.length)
            curSelected = 0;

        var daString:String;
        if (daList[curSelected][0] == '') daString = "From the Main Global Folder.";
        else if (daList[curSelected][1] == null) daString = "Couldn't find Modpack's name.";
        else daString = "Modpack's name: " + daList[curSelected][1] + ".";
        descText.text = daString;
        descText.screenCenter(Y);
        descText.y += 270;

		var bullShit:Int = 0;

		for (item in grpName.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}

        descBox.setPosition(descText.x - 10, descText.y - 10);
        descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
        descBox.updateHitbox();

        if (daList[curSelected][0] != '') {
			statusText.text = 'Status: ' + (daList[curSelected][2] ? 'Active' : 'Inactive');
			statusText.setPosition(descBox.getGraphicMidpoint().x, descBox.y - 15);
		}
		else statusText.text = '';
	}
}