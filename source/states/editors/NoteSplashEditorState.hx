package states.editors;

import objects.Note;
import objects.NoteSplash;
import objects.StrumNote;

import openfl.net.FileFilter;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import haxe.Json;

@:access(objects.NoteSplash)
class NoteSplashEditorState extends MusicBeatState
{
    var strums:FlxTypedSpriteGroup<StrumNote> = new FlxTypedSpriteGroup();
    var splashes:FlxTypedSpriteGroup<NoteSplash> = new FlxTypedSpriteGroup();
    var config = NoteSplash.createConfig();

    var tipText:FlxText;
    var errorText:FlxText;
    var curText:FlxText;

    static var imageSkin:String = null;
    var splash:NoteSplash;

    var UI:PsychUIBox;
    var properUI:PsychUIBox;
    var shaderUI:PsychUIBox;

    override function create()
    {
        if (imageSkin == null)
            imageSkin =  NoteSplash.DEFAULT_SKIN + NoteSplash.getSplashSkinPostfix();

        FlxG.mouse.visible = true;

        FlxG.sound.volumeUpKeys = [];
        FlxG.sound.volumeDownKeys = [];
        FlxG.sound.muteKeys = [];

        #if DISCORD_ALLOWED
        DiscordClient.changePresence('Note Splash Editor');
        #end

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF505050;
		add(bg);      

        UI = new PsychUIBox(0, 0, 0, 0, ["Animation"]);
        UI.canMove = UI.canMinimize = false;
        UI.y += 20;
        UI.x = FlxG.width - 300;
        UI.resize(290, 240);

        properUI = new PsychUIBox(0, 0, 0, 0, ["Properties"]);
        properUI.canMove = properUI.canMinimize = false;
        properUI.resize(280, 210);
        properUI.y += 20;
        properUI.x = UI.x - properUI.width - 5;
        add(properUI);
        add(UI);

        shaderUI = new PsychUIBox(0, 0, 0, 0, ["Shader"]);
        shaderUI.canMove = shaderUI.canMinimize = false;
        shaderUI.resize(160, 180);
        shaderUI.x = FlxG.width - shaderUI.width - 10;
        shaderUI.y = UI.y + UI.height + 10;
        add(shaderUI);

        var tipText:FlxText = new FlxText();
        tipText.setFormat(null, 32);
        tipText.text = "Press F1 for Help";
        tipText.setPosition(properUI.x - properUI.width - 60, UI.y);
        add(tipText);

        for (i in 0...4)
        {
            var babyArrow:StrumNote = new StrumNote(-273, 50, i % 4, 1);
            babyArrow.postAddedToGroup();
            babyArrow.screenCenter(Y);
            babyArrow.ID = i;
            strums.add(babyArrow);
        }

        add(strums);
        add(splashes);

        splash = new NoteSplash(imageSkin); // this cannot be recycled 
        splash.alpha = .0;
        splashes.add(splash);

        if (splash.config != null)
            config = splash.config;

        parseRGB();

        addProperitiesTab();
        addAnimTab();
        addShadersTab();

        errorText = new FlxText();
        errorText.setFormat(null, 16, FlxColor.RED);
        errorText.text = "ERROR!";
        errorText.y = FlxG.height - errorText.height;
        errorText.alpha = .0;
        add(errorText);

        curText = new FlxText();
        curText.setFormat(null, 24, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        curText.text = 'Copied Offsets: [0, 0]\nCurrent Animation: NONE';
        curText.y = FlxG.height - curText.height;
        curText.x += 5;
        add(curText);

        super.create();
    }

    var animDropDown:PsychUIDropDownMenu;
    var curAnim:String;
    var addButton:PsychUIButton;
    var curAnimText = null;
    var numericStepperData:PsychUINumericStepper;
    var templateButton:PsychUIButton;
    function addAnimTab()
    {
        var UI = UI.getTab("Animation").menu;

        UI.add(new FlxText(20, 20, 0, "Animation Name:", 8));
        var name_input:PsychUIInputText = new PsychUIInputText(20, 37.5, 100, "", 8);
        name_input.name = "name_input";
        curAnimText = name_input;
        UI.add(name_input);

        UI.add(new FlxText(name_input.x, name_input.y + 30, 0, "Animation Prefix:", 8));
        var prefix_input:PsychUIInputText = new PsychUIInputText(20, name_input.y + 47.5, 100, "", 8);
        UI.add(prefix_input);

        UI.add(new FlxText(150, 20, 0, "Note Data:"));
        numericStepperData = new PsychUINumericStepper(150, 37.5, 1, .0, .0, 999, 0);
        UI.add(numericStepperData);

        UI.add(new FlxText(150, name_input.y + 30, 0, "Indices (OPTIONAL):"));
        var indices_input:PsychUIInputText = new PsychUIInputText(150, name_input.y + 47.5, 100, "", 8);
        UI.add(indices_input);

        UI.add(new FlxText(20, 110, 0, "Minimum FPS:"));
        var minFps:PsychUINumericStepper = new PsychUINumericStepper(20, 127.5, 1, 22, 1, 120);
        UI.add(minFps);

        UI.add(new FlxText(150, 110, 0, "Maximum FPS:"));
        var maxFps:PsychUINumericStepper = new PsychUINumericStepper(150, 127.5, 1, 26, 1, 120);
        UI.add(maxFps);

        animDropDown = new PsychUIDropDownMenu(-155, 57, [""], function(id:Int, name:String)
        {
            if (config != null && name.length > 0)
            {
                var i = config.animations.get(name);
                if (i != null)
                {
                    name_input.text = name;
                    prefix_input.text = i.prefix; 
                    numericStepperData.min = 0;     
                    numericStepperData.value = i.noteData;
                    curAnim = name;
                    minFps.value = i.fps[0];
                    maxFps.value = i.fps[1];
                    if (i.indices != null && i.indices.length > 0)
                        indices_input.text = i.indices.toString().substring(1, i.indices.toString().length - 2);

                    playStrumAnim(curAnim, i.noteData);
                }
            }
        });

        function setAnimDropDown()
        {
            var anims:Array<String> = [];
            if (config != null && config.animations != null)
                for (i in config.animations.keys())
                {
                    anims.push(i);
                }

            if (anims.length < 1)
                anims.push("");

            if (curAnim == null && anims[0].length > 0)
                curAnim = anims[0];

            animDropDown.list = anims;
            animDropDown.selectedLabel = curAnim;
        }

        setAnimDropDown();

        templateButton.onClick = function()
        {
            NoteSplash.configs.clear();
            config = NoteSplash.createConfig();

            curAnim = null;
            name_input.text = "";
            prefix_input.text = "";        
            indices_input.text = "";  
            numericStepperData.value = 0;
            minFps.value = 22;
            maxFps.value = 26;
            setAnimDropDown();
            parseRGB();
            changeShader.selectedLabel = "Red";
            changeShader.onSelect(0, "Red");
        }

        addButton = new PsychUIButton(20, 185, "Add/Update", function()
        {       
            var indices:Array<Int> = [];
            if (indices_input.text.split(',').length > 1)
            {
                for (i in indices_input.text.split(','))
                {
                    var index:Null<Int> = Std.parseInt(i);
                    if (!Math.isNaN(index) && index != null)
                    {
                        indices.push(index);
                    }
                }
            }

            var offsets:Array<Float> = [0, 0];
            var conf = config.animations.get(name_input.text);

            if (conf != null)
                offsets = conf.offsets;

            if (offsets == null)
                offsets = [0, 0];
            else 
                offsets = offsets.copy();

            config = NoteSplash.addAnimationToConfig(config, scaleNumericStepper.value, name_input.text, prefix_input.text, [cast minFps.value, cast maxFps.value], offsets, indices, cast numericStepperData.value);
            curAnim = name_input.text;
            playStrumAnim(curAnim, cast numericStepperData.value);
            setAnimDropDown();

            if (errorText.alpha == 1)
            {
                config.animations.remove(curAnim);
                curAnim = null;
                setAnimDropDown();
            }
            //if (animDropDown.list)
        }); 
        UI.add(addButton);

        var removeButton:PsychUIButton = new PsychUIButton(185, 185, "Remove", function()
        {
            if (config != null)
            {
                if (config.animations.exists(curAnim))
                { 
                    config.animations.remove(curAnim);

                    curAnim = null;
                    name_input.text = "";
                    prefix_input.text = "";
                    indices_input.text = "";  
                    numericStepperData.value = 0;
                    setAnimDropDown();
                }
            }
        });
        UI.add(removeButton);
        UI.add(animDropDown);

        reloadImage = function()
        {
            imageSkin = imageInputText.text;

            errorText.color = FlxColor.RED;
            FlxTween.cancelTweensOf(errorText);

            var image = Paths.image(imageSkin);
            if (image == null)
            {
                errorText.text = 'ERROR! Couldn\'t find $imageSkin.png';
                errorText.alpha = 1;
                return;
            }
            else
            {
                errorText.color = FlxColor.GREEN;
                errorText.alpha = 1;
                errorText.text = 'Succesfully loaded $imageSkin.png';
            }

            NoteSplash.configs.clear();

            FlxTween.tween(errorText, {alpha: 0}, 1, {startDelay: 1, onComplete: (twn) -> {
                errorText.color = FlxColor.RED;
            }});

            splash.loadSplash(imageSkin);
            splash.alpha = 0.0001;

            if (splash.config != null) config = splash.config;
            else config = NoteSplash.createConfig();

            curAnim = null;
            name_input.text = "";
            prefix_input.text = "";        
            indices_input.text = "";  
            numericStepperData.value = 0;
            minFps.value = 22;
            maxFps.value = 26;
            setAnimDropDown();
            parseRGB();
            changeShader.selectedLabel = "Red";
            changeShader.onSelect(0, "Red");
        }
    }

    var imageInputText:PsychUIInputText;
    var scaleNumericStepper:PsychUINumericStepper;
    function addProperitiesTab()
    {
        var ui = properUI.getTab("Properties").menu;

        ui.add(new FlxText(20, 10, 0, "Image:"));
        imageInputText = new PsychUIInputText(60, 10, 120, imageSkin, 8);
        ui.add(imageInputText);

        var reloadButton:PsychUIButton = new PsychUIButton(185, 6.8, "Reload Image", function()
        {
            reloadImage();
        });
        ui.add(reloadButton);

        ui.add(new FlxText(20, 40, "Scale:"));
        scaleNumericStepper = new PsychUINumericStepper(20, 57.5, 0.1, 1, 0, 4, 2, 60);
        ui.add(scaleNumericStepper);

        scaleNumericStepper.value = config != null ? config.scale : 1;

        ui.add(new FlxText(130, 40, "Animations:"));

        var saveButton:PsychUIButton = new PsychUIButton(20, 130, "Save", saveSplash);
        ui.add(saveButton);

        templateButton = new PsychUIButton(20, 155, "Template");
        ui.add(templateButton);

        var loadButton:PsychUIButton = new PsychUIButton(180, 155, "Convert TXT", loadTxt);
        ui.add(loadButton);

        var allowRGBCheck:PsychUICheckBox = new PsychUICheckBox(20, 105, "", 1);
        function check()
        {
            if (config != null)
                config.allowRGB = allowRGBCheck.checked;
        }
        allowRGBCheck.onClick = check;
        allowRGBCheck.checked = config != null && cast(config.allowRGB, Null<Bool>) != null ? config.allowRGB : false;

        var rgbText = new FlxText(allowRGBCheck.x + 20, 0);
        rgbText.text = "Allow RGB?";
		rgbText.y = allowRGBCheck.y + 2.5;
		ui.add(rgbText);

        ui.add(allowRGBCheck);

        var allowPixelCheck:PsychUICheckBox = new PsychUICheckBox(allowRGBCheck.x + 110, allowRGBCheck.y, "", 1);
        function check()
        {
            if (config != null)
                config.allowPixel = allowPixelCheck.checked;
        }
        allowPixelCheck.onClick = check;
        allowPixelCheck.checked = config != null && cast(config.allowPixel, Null<Bool>) != null ? config.allowPixel : false;

        var pixelText = new FlxText(allowPixelCheck.x + 20, 0);
        pixelText.text = "Allow Pixel?";
		pixelText.y = allowPixelCheck.y + 2.5;
		ui.add(pixelText);

        ui.add(allowPixelCheck);
    }

    var redEnabled:Bool = true;
    var blueEnabled:Bool = true;
    var greenEnabled:Bool = true;
    var redShader:Array<Int> = [0, 0, 0];
    var greenShader:Array<Int> = [0, 0, 0];
    var blueShader:Array<Int> = [0, 0, 0];
    var changeShader:PsychUIDropDownMenu;
    var defaultButton:PsychUICheckBox;
    function addShadersTab()
    {
        var tab = shaderUI.getTab("Shader").menu;

        tab.add(new FlxText(40, 10, "Replacing Color:"));
        tab.add(new FlxText(25, 30, "Red:"));
        tab.add(new FlxText(25, 50, "Green:"));
        tab.add(new FlxText(25, 70, "Blue:"));

        var red = new PsychUINumericStepper(60, 30, 1, redShader[0], 0, 255, 0);
        red.onValueChange = () -> {
            var shader = switch changeShader.selectedLabel
            {
                case "Red": redShader[0] = Std.int(red.value);
                case "Green": greenShader[0] = Std.int(red.value);
                case _: blueShader[0] = Std.int(red.value);
            }
            setConfigRGB();
        };
        tab.add(red);

        var green = new PsychUINumericStepper(60, 50, 1, redShader[2], 0, 255, 0);
        green.onValueChange = () -> {
            var shader = switch changeShader.selectedLabel
            {
                case "Red": redShader[1] = Std.int(green.value);
                case "Green": greenShader[1] = Std.int(green.value);
                case _: blueShader[1] = Std.int(green.value);
            }
            setConfigRGB();
        };
        tab.add(green);

        var blue = new PsychUINumericStepper(60, 70, 1, redShader[1], 0, 255, 0);
        blue.onValueChange = () -> {
            var shader = switch changeShader.selectedLabel
            {
                case "Red": redShader[2] = Std.int(blue.value);
                case "Green": greenShader[2] = Std.int(blue.value);
                case _: blueShader[2] = Std.int(blue.value);
            }
            setConfigRGB();
        };
        tab.add(blue);

        function onCheck(change:Bool = true)
        {
            if (!defaultButton.checked)
                shaderUI.alpha = 1;
            else 
                shaderUI.alpha = 0.6;

            if (change)
                switch changeShader.selectedLabel
                {
                    case "Red": redEnabled = !defaultButton.checked;
                    case "Green": greenEnabled = !defaultButton.checked;
                    case "Blue": blueEnabled = !defaultButton.checked;
                }

            setConfigRGB();
        }

        add(new FlxText(shaderUI.x + 20, shaderUI.y + 135, 0, "Color to Replace:"));
        changeShader = new PsychUIDropDownMenu(shaderUI.x + 20, shaderUI.y + 150, ["Red", "Green", "Blue"], function(id:Int, name:String)
        {
            var shader = switch name
            {
                case "Red": redShader;
                case "Green": greenShader;
                case _: blueShader;
            }

            red.value = shader[0];
            green.value = shader[1];
            blue.value = shader[2];

            // changing checked doesn't initiate onCheck!!
            defaultButton.checked = !(switch name {
                case "Red": redEnabled;
                case "Green": greenEnabled;
                case _: blueEnabled;
            });
            onCheck(false);
        });
        add(changeShader);
        
        defaultButton = new PsychUICheckBox(shaderUI.x + 30, shaderUI.y + 115, "Do not replace", 100, () -> onCheck());
        defaultButton.text.y += 2.5;
        add(defaultButton);

        changeShader.selectedLabel = "Red";
        changeShader.onSelect(0, "Red");
    }

    dynamic function reloadImage() // Dynamic because needs to be changed later
    {
        //
    }

	var holdingArrowsTime:Float = 0;
	var holdingArrowsElapsed:Float = 0;
    var copiedOffset:Array<Float> = [0, 0];
    override function update(elapsed:Float)
    { 
        super.update(elapsed);

        errorText.x = FlxG.width - errorText.width - 5;

        curText.text = 'Copied Offsets: ${Std.string(copiedOffset).replace(',', ', ')}\n';
        curText.text += 'Current Animation: ${curAnim == null || curAnim.length < 1  ? "NONE" : curAnim}';

        if (config != null && !curText.text.contains('NONE'))
        {
            var offsets:Array<Float> = try config.animations.get(curAnim).offsets catch (e) [0, 0];
            curText.text += ' ($offsets)'.replace(',', ', ');
        }

        if (config != null)
        {
            var currentAnim:String = curAnimText.text;
            if (config.animations.exists(currentAnim) && config.animations.get(currentAnim) != null)
                addButton.label = 'Update';
            else
                addButton.label = 'Add';

            config.scale = scaleNumericStepper.value;
        }
        
        var blockInput:Bool = PsychUIInputText.focusOn != null;
        if (!blockInput && config != null && config.animations != null && config.animations.exists(curAnim) && curAnim != null && curAnim.length > 0)
        {
            function splash()
            {
                if (config.animations.get(curAnim) != null)
                {
                    playStrumAnim(curAnim, config.animations.get(curAnim).noteData);
                    FlxTween.cancelTweensOf(errorText);
                    errorText.alpha = 0;
                }
            }

            var changedOffset = false;
            if (FlxG.keys.pressed.CONTROL && config.animations.get(curAnim) != null)
            {
                if (FlxG.keys.justPressed.C)
                {
                    copiedOffset = config.animations.get(curAnim).offsets.copy();
                }
                else if (FlxG.keys.justPressed.V)
                {
                    var conf = config.animations.get(curAnim);
                    conf.offsets = copiedOffset.copy(); 
                    config.animations.set(curAnim, conf);
                    changedOffset = true;
                }
                else if(FlxG.keys.justPressed.R)
                {
                    var conf = config.animations.get(curAnim);
                    conf.offsets = [0, 0];
                    config.animations.set(curAnim, conf);
                    changedOffset = true;
                }
            }

            var multiplier:Int = (FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyPressed(LEFT_SHOULDER)) ? 10 : 1;

            var moveKeysP = [FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.UP, FlxG.keys.justPressed.DOWN];
            if(moveKeysP.contains(true))
            {
                config.animations[curAnim].offsets[0] += ((moveKeysP[0] ? 1 : 0) - (moveKeysP[1] ? 1 : 0)) * multiplier;
                config.animations[curAnim].offsets[1] += ((moveKeysP[2] ? 1 : 0) - (moveKeysP[3] ? 1 : 0)) * multiplier;
                changedOffset = true;
            }
    
            var moveKeys = [FlxG.keys.pressed.LEFT, FlxG.keys.pressed.RIGHT, FlxG.keys.pressed.UP, FlxG.keys.pressed.DOWN];
            if(moveKeys.contains(true))
            {
                holdingArrowsTime += elapsed;
                if(holdingArrowsTime > 0.6)
                {
                    holdingArrowsElapsed += elapsed;
                    while(holdingArrowsElapsed > (1/60))
                    {
                        config.animations[curAnim].offsets[0] += ((moveKeys[0] ? 1 : 0) - (moveKeys[1] ? 1 : 0)) * multiplier;
                        config.animations[curAnim].offsets[1] += ((moveKeys[2] ? 1 : 0) - (moveKeys[3] ? 1 : 0)) * multiplier;
                        holdingArrowsElapsed -= (1/60);
                        changedOffset = true;
                    }
                }
            }
            else holdingArrowsTime = 0;

            if(changedOffset || FlxG.keys.justPressed.SPACE) splash();
        }

        if (!blockInput)
        {
            if (controls.BACK)
                MusicBeatState.switchState(new MasterEditorMenu());
            if (FlxG.keys.justPressed.F1)
                openSubState(new NoteSplashEditorHelpSubState());
        }

        if (FlxG.mouse.overlaps(strums))
        {
            strums.forEach(function(strum:StrumNote)
            {
                if (FlxG.mouse.overlaps(strum))
                {
                    if (!FlxG.mouse.justPressed)
                    {
                        if (strum.animation.curAnim.name != 'pressed' && strum.animation.curAnim.name != 'confirm')
                            strum.playAnim('pressed');
                    }
                    else
                    {
                        strum.playAnim('confirm', true);
                        //strum.holdTimer = Math.POSITIVE_INFINITY;

                        var splash:NoteSplash = new NoteSplash(imageSkin);
                        splash.alpha = 0.00001;
                        splash.config = config;

                        var anims:Int = 0;
                        var datas:Int = 0;
                        var animArray:Array<Int> = [];

                        while (true)
                        {
                            var data:Int = strum.ID % 4 + (datas * 4); 
                            if (!splash.noteDataMap.exists(data) || !splash.animation.exists(splash.noteDataMap[data]))
                                break;

                            datas++;
                            anims++;
                        }

                        if (anims > 1)
                        {
                            for (i in 0...anims)
                            {
                                animArray.push(strum.ID % 4 + (i * 4));
                            }
                        }

                        var int:Int = strum.ID % 4;
                        if (!splash.noteDataMap.exists(int) && splash.noteDataMap.exists(strum.ID % 4 + 4))
                            int = strum.ID % 4 + 4;

                        if (animArray.length > 1)
                        {
                            var r:Int = FlxG.random.bool() ? 0 : 1;
                            int = animArray[r];
                        }

                        splash.babyArrow = strum;
                        splash.spawnSplashNote(null, int);
                        splash.alpha = 1;
                        splashes.add(splash);
                    }
                }
                else strum.playAnim('static');
            });
        }
        else
        {
            for (strum in strums)
                strum.playAnim('static');
        }
    }

    function playStrumAnim(?name:String, noteData:Int)
    {
        var splash:NoteSplash = new NoteSplash(imageSkin);
        splash.alpha = 1;
        splash.config = config;
        if (noteData < 0) noteData = 0;

        if (name != null && splash.animation.exists(name) && noteData > -1)
        {
            splash.babyArrow = strums.members[noteData % 4];
            splash.spawnSplashNote(null, noteData, false);
            splash.alpha = 1;
            splashes.add(splash);
        }
        else
        {
            splashes.remove(splash);
            errorText.alpha = 1;
            errorText.text = "ERROR while playing splash";
            
            FlxTween.cancelTweensOf(errorText);
            FlxTween.tween(errorText, {alpha: 0}, {startDelay: 1});
        }
    }

    function resetRGB()
    {
        redShader = [0, 0, 0];
        greenShader = [0, 0, 0];
        blueShader = [0, 0, 0];
    }

    function parseRGB()
    {
        resetRGB();
        if (config.rgb != null)
            for (i in 0...config.rgb.length)
            {
                if (i > 2) break;

                var rgb = config.rgb[i];
                if (rgb == null)
                { 
                    if (i == 0)
                        redEnabled = false;
                    else if (i == 1)
                        greenEnabled = false;
                    else if (i == 2)
                        blueEnabled = false;

                    continue;
                }
                else
                {
                    if (i == 0)
                        redEnabled = true;
                    else if (i == 1)
                        greenEnabled = true;
                    else if (i == 2)
                        blueEnabled = true;
                }
                
                var colors = [rgb.r, rgb.g, rgb.b];
                if (i == 0)
                    redShader = colors;
                else if (i == 1)
                    greenShader = colors;
                else if (i == 2)
                    blueShader = colors;
            }
        else
        {
            resetRGB(); 
            redEnabled = blueEnabled = greenEnabled = false;
        }
    }

    function setConfigRGB()
    {
        if (config == null)
            config = NoteSplash.createConfig();
        
        if (!redEnabled && !greenEnabled && !blueEnabled)
        {
            config.rgb = null;
            return;
        }

        config.rgb = [];

        if (redEnabled)
            config.rgb.push({r: redShader[0], g: redShader[1], b: redShader[2]});
        else
            config.rgb.push(null);

        if (greenEnabled)
            config.rgb.push({r: greenShader[0], g: greenShader[1], b: greenShader[2]});
        else
            config.rgb.push(null);

        if (blueEnabled)
            config.rgb.push({r: blueShader[0], g: blueShader[1], b: blueShader[2]});
        else
            config.rgb.push(null);
    }

    var _file:FileReference;
    function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

    function saveSplash()
    {
        imageSkin = imageInputText.text;
        var data:String = Json.stringify(config, "\t");
        if (data.length > 0)
        {
            _file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, imageSkin + ".json");
        }
    }

	public function loadTxt()
	{
		var jsonFilter:FileFilter = new FileFilter('Select a note splash TXT', '*.txt');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([#if windows jsonFilter #end]);
	}

	function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		try 
		{
			var txtLoaded:Dynamic = Json.parse(Json.stringify(_file));
            var txt:String = null;
            var file:String = "config.json";
            #if MODS_ALLOWED
            if (txtLoaded.__path != null)
            {
                try txt = File.getContent(txtLoaded.__path) catch (e) txt = null;
                file = txtLoaded.__path;
                file = file.substring(0, file.length - 4) + ".json";
            }

            var conf = parseTxt(txt);
            _file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(Json.stringify(conf, "\t"), file);
            #end
		}
		catch (e)
		{
			trace(e.stack);
		}
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

    override function destroy()
    {
        super.destroy();

        FlxG.sound.music.volume = 1;
        FlxG.sound.muteKeys = [FlxKey.ZERO];
	    FlxG.sound.volumeDownKeys = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	    FlxG.sound.volumeUpKeys = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
    }

    public static function parseTxt(content:String):NoteSplashConfig
	{
		var config = NoteSplash.createConfig();
		if (content == null)
			return config;

		var trim:String = content.trim();
		if (trim.length < 1) // empty txt
			return config;

		var configs = content.split('\n');
		// checks for empty txts
		if (configs.length < 2 || configs[0].trim() == "")
			return config;

		var animation:String = configs[0].rtrim();
		var fps:Array<Null<Int>> = [22, 26];
		if (configs[1] != null && configs[1].trim() != "")
		{
			var newFps = configs[1].trim().split(" ");
			fps = [Std.parseInt(newFps[0]), Std.parseInt(newFps[1])];
			if (fps[0] == null) fps[0] = 22;
			if (fps[1] == null) fps[1] = 26;
		}

		var hasOneOffset = false;
		var offsets:Array<Array<Null<Float>>> = [[0, 0]];
		if (configs.length == 3 || configs.length == 2)
		{
			hasOneOffset = true;
			if (configs.length == 3)
			{
                offsets = [];
				var offset = configs[2].trim();
				if (offset != "")
				{
					var offset:Array<String> = offset.split(" ");
					var x:Null<Float> = Std.parseFloat(offset[0]);
					var y:Null<Float> = Std.parseFloat(offset[1]);
					if (x == null) x = 0;
					if (y == null) y = 0;
					offsets.push([x, y]);
				}
			}
		}
		else if (configs.length > 3)
		{
			offsets = [];
			var i = 2;
			while (true)
			{
				var offset = configs[i].trim();
				if (offset != "")
				{
					var offset:Array<String> = offset.split(" ");
					var x:Null<Float> = Std.parseFloat(offset[0]);
					var y:Null<Float> = Std.parseFloat(offset[1]);
					if (x == null) x = 0;
					if (y == null) y = 0;
					offsets.push([x, y]);
				}
				i++;

				if (i + 1 > configs.length)
					break;
			}
		}

		for (i in 0...Note.colArray.length)
		{
			var offset = offsets[hasOneOffset ? 0 : i];
			if (i + 1 > configs.length && !hasOneOffset)
				break;

			config = NoteSplash.addAnimationToConfig(config, 1, Note.colArray[i], '$animation ${Note.colArray[i]} 10', fps, offset, [], i);
		}

		if (offsets.length > 4)
		{
			for (i in 0...Note.colArray.length)
			{
				var offset = offsets[i + 4];
				if (i + 1 > offsets.length)
					break;

				config = NoteSplash.addAnimationToConfig(config, 1, Note.colArray[i] + "2", '$animation ${Note.colArray[i]} 20', fps, offset, [], i + 4);
			}
		}

		return config;
	}
}


class NoteSplashEditorHelpSubState extends MusicBeatSubstate
{
    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

		var str:Array<String> = ["Click on a Strum or Press Space",
		"to spawn a Splash",
		"",
		"Arrow Keys - Move Offset",
		"Hold Shift - Move Offsets 10x faster",
		"",
		"",
		"Ctrl + C - Copy Current Offset",
		"Ctrl + V - Paste Copied Offset on Current Splash",
		"Ctrl + R - Reset Current Offset"];

		var helpTexts:FlxSpriteGroup = new FlxSpriteGroup();
		for (i => txt in str)
		{
			if(txt.length < 1) continue;

			var helpText:FlxText = new FlxText(0, 0, 0, txt, 32);
			helpText.setFormat(null, 32, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
			helpText.borderColor = FlxColor.BLACK;
			helpText.scrollFactor.set();
			helpText.borderSize = 1;
			helpText.screenCenter();
			add(helpText);
			helpText.y += ((i - str.length/2) * 32) + 16;
			helpTexts.add(helpText);
		}
		add(helpTexts);

        var noteDataText:FlxText = new FlxText();
        noteDataText.setFormat(null, 32, FlxColor.WHITE, RIGHT, OUTLINE_FAST, FlxColor.BLACK);
        noteDataText.text = "NOTE DATAS:\nLEFT: 0 and 4\nDOWN: 1 and 5\nUP: 2 and 6\nRIGHT: 3 and 7";
        noteDataText.x = FlxG.width - noteDataText.width - 5;
        noteDataText.y = FlxG.height - noteDataText.height - 5;

        add(noteDataText);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.BACK || FlxG.keys.justPressed.F1)
            close();
    }
}