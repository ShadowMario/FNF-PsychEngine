package dev_toolbox.stage_editor;

import dev_toolbox.file_explorer.FileExplorer;
import charter.ChooseCharacterScreen;
import flixel.tweens.FlxEase;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.display.Application;
import openfl.display.Window;
import sys.FileSystem;
import sys.FileSystem;
import haxe.io.Path;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.input.mouse.FlxMouse;
import lime.ui.MouseCursor;
import openfl.ui.Mouse;
import flixel.addons.ui.*;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import sys.io.File;
import haxe.Json;
import stage.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class StageEditor extends MusicBeatState {
    public static var fromFreeplay = false;
    public static var easeFuncs:Map<String, Float->Float>;
    public var ui:FlxSpriteGroup;
    public var camHUD:FlxCamera;
    public var camGame:FlxCamera;
    public var dummyHUDCamera:FlxCamera;
    public var stage:StageJSON;
    public var stageFile:String;
    public var bfDefPos:FlxPoint = new FlxPoint(770, 100);
    public var gfDefPos:FlxPoint = new FlxPoint(400, 130);
    public var dadDefPos:FlxPoint = new FlxPoint(100, 100);

    public var bf:Character;
    public var gf:Character;
    public var dad:Character;

    public var selectedObj(default, set):FlxStageSprite;

    public static var animTypes:Array<StrNameLabel> = [
        new StrNameLabel("OnBeat", "On Beat"),
        new StrNameLabel("OnBeatForce", "On Beat (Force)"),
        new StrNameLabel("Loop", "Loop")
    ];

    function set_selectedObj(n:FlxStageSprite):FlxStageSprite {
        selectedObj = n;
        objName.text = selectedObj != null ? selectedObj.name : "(No selected sprite)";
        if (selectedObj == null) {
             // global shit
            for (e in [posLabel, sprPosX, sprPosY, scaleLabel, scaleNum, opacityLabel, opacityNum, antialiasingCheckbox, scrFacX, scrFacY, scrollFactorLabel, shaderLabel, shaderNameInput, pickShader, pickShaderIcon, bumpOffsetLabel, bumpOffsetXLabel, bumpOffsetYLabel, bumpOffsetY, bumpOffsetX, bumpOffsetEase, bumpOffsetEaseType]) {
                e.visible = false;
            }
            // sparrow shit
            for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                e.visible = false;
            }
        } else {
            for (e in [posLabel, sprPosX, sprPosY, scaleLabel, scaleNum, opacityLabel, opacityNum, antialiasingCheckbox, scrFacX, scrFacY, scrollFactorLabel, shaderLabel, shaderNameInput, pickShader, pickShaderIcon, bumpOffsetLabel, bumpOffsetXLabel, bumpOffsetYLabel, bumpOffsetY, bumpOffsetX, bumpOffsetEase, bumpOffsetEaseType]) {
                e.visible = true;
            }
            sprPosX.value = selectedObj.x;
            sprPosY.value = selectedObj.y;
            scrFacX.value = selectedObj.scrollFactor.x;
            scrFacY.value = selectedObj.scrollFactor.y;
            if (selectedObj.onBeatOffset == null)
                selectedObj.onBeatOffset = {
                    x: 0,
                    y: 0,
                    ease: "linear"
                };
            bumpOffsetX.value = selectedObj.onBeatOffset.x;
            bumpOffsetY.value = selectedObj.onBeatOffset.y;
            
            var id = "";
            if (selectedObj.onBeatOffset.ease.endsWith("InOut")) id = "InOut";
            else if (selectedObj.onBeatOffset.ease.endsWith("In")) id = "In";
            else if (selectedObj.onBeatOffset.ease.endsWith("Out")) id = "Out";

            bumpOffsetEase.selectedId = selectedObj.onBeatOffset.ease.substr(0, selectedObj.onBeatOffset.ease.length - id.length);
            bumpOffsetEaseType.selectedId = id;
            bumpOffsetEaseType.visible = id != "";
            
            scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
            opacityNum.value = selectedObj.alpha;
            antialiasingCheckbox.checked = selectedObj.antialiasing;
            shaderNameInput.text = selectedObj.shaderName == null ? "" : selectedObj.shaderName;

            if (selectedObj.type.toLowerCase() == "sparrowatlas" && selectedObj.anim != null) {
                for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                    e.visible = true;
                }
                animationNameTextBox.text = selectedObj.anim.name;
                animationFPSNumeric.value = selectedObj.anim.fps;
                animationLabel.selectedId = selectedObj.anim.type;

            } else {
                for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                    e.visible = false;
                }
            }

            if (homies.contains(selectedObj.type)) {
                for (e in [scaleLabel, scaleNum, opacityLabel, opacityNum, antialiasingCheckbox, bumpOffsetLabel, bumpOffsetXLabel, bumpOffsetYLabel, bumpOffsetY, bumpOffsetX, bumpOffsetEase, bumpOffsetEaseType]) {
                    e.visible = false;
                }
            }
        }

        for(b in selectOnlyButtons) {
            var resolvedName = resolveButtonName(b.label.text);
            if (selectedObj != null && selectedObj.name == b.label.text) {
                b.label.text = '> $resolvedName <';
            } else {
                b.label.text = '$resolvedName';
            }
        }

        return selectedObj;
    }


    function resolveButtonName(name:String):String {if (name.startsWith("> ") && name.endsWith(" <")) return name.substr(2, name.length - 4); else return name;}
    public var camThingy:FlxSprite;
    public var tabs:FlxUITabMenu;

    public var homies:Array<String> = ["BF", "GF", "Dad"];

    public var stageTab:FlxUI;
    public var globalSetsTab:FlxUI;
    public var selectedObjTab:FlxUI;

    public var defCamZoomNum:FlxUINumericStepper;
    public var followLerpNum:FlxUINumericStepper;

    public var objName:FlxUIText;
    public var posLabel:FlxUIText;
    public var sprPosX:FlxUINumericStepper;
    public var sprPosY:FlxUINumericStepper;
    public var scrollFactorLabel:FlxUIText;
    public var scrFacX:FlxUINumericStepper;
    public var scrFacY:FlxUINumericStepper;
    public var scaleLabel:FlxUIText;
    public var scaleNum:FlxUINumericStepper;
    public var opacityLabel:FlxUIText;
    public var opacityNum:FlxUINumericStepper;
    public var antialiasingCheckbox:FlxUICheckBox;
    public var sparrowAnimationTitle:FlxUIText;
    public var animationNameTitle:FlxUIText;
    public var animationNameTextBox:FlxUIInputText;
    public var animationLabel:FlxUIDropDownMenu;
    public var animationFPSNumeric:FlxUINumericStepper;
    public var fpsLabel:FlxUIText;
    public var shaderLabel:FlxUIText;
    public var shaderNameInput:FlxUIInputText;
    public var pickShader:FlxUIButton;
    public var pickShaderIcon:FlxSprite;
    public var animationTypeLabel:FlxUIText;
    public var applySparrowButton:FlxUIButton;
    public var bumpOffsetLabel:FlxUIText;
    public var bumpOffsetX:FlxUINumericStepper;
    public var bumpOffsetXLabel:FlxUIText;
    public var bumpOffsetY:FlxUINumericStepper;
    public var bumpOffsetYLabel:FlxUIText;
    public var bumpOffsetEaseLabel:FlxUIText;
    public var bumpOffsetEase:FlxUIDropDownMenu;
    public var bumpOffsetEaseType:FlxUIDropDownMenu;

    public var oldTab = "";
    public var selectOnly(default, set):FlxStageSprite = null;
    public var selectOnlyButtons:Array<FlxUIButton> = [];
    public var moveOffset:FlxPoint = new FlxPoint(0, 0);
    public var objBeingMoved:FlxStageSprite = null;
    
    public var closed:Bool = false;

    function set_selectOnly(s:FlxStageSprite):FlxStageSprite {
        selectOnly = s;

        for (m in members) {
            if (Std.isOfType(m, FlxStageSprite)) {
                var sprite = cast(m, FlxStageSprite);
                if (sprite == selectOnly || selectOnly == null) {
                    sprite.colorTransform.redOffset = 0;
                    sprite.colorTransform.greenOffset = 0;
                    sprite.colorTransform.blueOffset = 0;
                    sprite.colorTransform.redMultiplier = 1;
                    sprite.colorTransform.greenMultiplier = 1;
                    sprite.colorTransform.blueMultiplier = 1;
                } else {
                    sprite.colorTransform.redOffset = 128;
                    sprite.colorTransform.greenOffset = 128;
                    sprite.colorTransform.blueOffset = 128;
                    sprite.colorTransform.redMultiplier = 0.25;
                    sprite.colorTransform.greenMultiplier = 0.25;
                    sprite.colorTransform.blueMultiplier = 0.25;
                }
            }
        }
        camGame.bgColor = selectOnly == null ? FlxColor.BLACK : 0xFF888888;

        return s;
    }


    public override function new(stage:String) {
        this.stageFile = stage;
        super();
    }

    public function bye() {
        if (fromFreeplay)
            FlxG.switchState(new PlayState());
        else
            FlxG.switchState(new ToolboxHome(ToolboxHome.selectedMod));
    }

    function addStageTab() {
        stageTab = new FlxUI(null, tabs);
        stageTab.name = "stage";

        var names:FlxUIText = new FlxUIText(10, 10, 280, "Sprites");
        names.alignment = CENTER;

        var all = new FlxUIButton(10, names.y + names.height + 10, "(Can Select All)", function() {
            selectOnly = null;
        });
        all.resize(280, 20);

        stageTab.add(names);
        stageTab.add(all);

        var deleteSpriteButton = new FlxUIButton(10, FlxG.height - 70, "Delete", function() {
            if (selectedObj == null) {
                var t = ToolboxMessage.showMessage("Error", "No sprite was selected", function() {}, camHUD);
                t.cameras = [dummyHUDCamera, camHUD];
                openSubState(t);
                return;
            }
            if (homies.contains(selectedObj.type)) {
                var t = ToolboxMessage.showMessage("Error", 'You can\'t delete ${selectedObj.name}', function() {}, camHUD);
                t.cameras = [dummyHUDCamera, camHUD];
                openSubState(t);
                return;
            }
            var t = new ToolboxMessage("Delete a sprite", 'Are you sure you want to delete "${selectedObj.name}"? This operation is irreversible.', [
                {
                    label: "Yes",
                    onClick: function(t) {
                        for(s in stage.sprites) {
                            if (s.name == selectedObj.name) {
                                stage.sprites.remove(s);
                                selectedObj = null;
                                selectOnly = null;
                                updateStageElements();
                                break;
                            }
                        }
                    }
                },
                {
                    label: "No",
                    onClick: function(t) {}
                }
            ]);
            t.cameras = [dummyHUDCamera, camHUD];
            openSubState(t);
        });
        deleteSpriteButton.color = 0xFFFF4444;
        deleteSpriteButton.label.color = FlxColor.WHITE;

        var addSpriteButton = new FlxUIButton(deleteSpriteButton.x + deleteSpriteButton.width + 10, deleteSpriteButton.y, "Add", function() {
            openSubState(new StageSpriteCreator(this));
        });

        var layerUpButton = new FlxUIButton(10, FlxG.height - 100, "<", function() {
            if (selectedObj != null) {
                moveLayer(selectedObj, -1);
            }
        });
        layerUpButton.resize(20, 20);
        layerUpButton.label.angle = 90;
        layerUpButton.cameras = [dummyHUDCamera, camHUD];

        var layerDownButton = new FlxUIButton(layerUpButton.x + layerUpButton.width, layerUpButton.y, ">", function() {
            if (selectedObj != null) {
                moveLayer(selectedObj, 1);
            }
        });
        layerDownButton.resize(20, 20);
        layerDownButton.label.angle = 90;
        layerDownButton.cameras = [dummyHUDCamera, camHUD];

        var moveLayerLabel = new FlxUIText(10, layerUpButton.y + (layerUpButton.height / 2), 0, "Move Sprite Layer (Q / E)");
        moveLayerLabel.y -= moveLayerLabel.height / 2;
        layerDownButton.x += moveLayerLabel.width;
        layerUpButton.x += moveLayerLabel.width;

        var changeBFButton = new FlxUIButton((90 * 2) + 10, layerUpButton.y - 10, "Change BF", function() {
            openSubState(new ChooseCharacterScreen(function(mod, name) {
                var bfLayer = members.indexOf(bf);
                var newChar = new Boyfriend(bf.x - bf.charGlobalOffset.x, bf.y - bf.charGlobalOffset.y, '$mod:$name');
                
                newChar.name = "Boyfriend";
                newChar.type = "BF";
                newChar.scrollFactor.set(bf.scrollFactor.x, bf.scrollFactor.y);

                if (selectedObj == bf) selectedObj = newChar;
                if (selectOnly == bf) selectOnly = newChar;
                remove(bf);
                bf.destroy();
                bf = newChar;
                insert(bfLayer, newChar);
                updateStageElements();
            }));
        });
        changeBFButton.y -= changeBFButton.height;

        var changeGFButton = new FlxUIButton((90 * 1) + 10, changeBFButton.y, "Change GF", function() {
            openSubState(new ChooseCharacterScreen(function(mod, name) {
                var gfLayer = members.indexOf(gf);
                var newChar = new Character(gf.x - gf.charGlobalOffset.x, gf.y - gf.charGlobalOffset.y, '$mod:$name');
                
                newChar.name = "Girlfriend";
                newChar.type = "GF";
                newChar.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);

                if (selectedObj == gf) selectedObj = newChar;
                if (selectOnly == gf) selectOnly = newChar;
                remove(gf);
                gf.destroy();
                gf = newChar;
                insert(gfLayer, newChar);
                updateStageElements();
            }));
        });

        var changeDadButton = new FlxUIButton(10, changeBFButton.y, "Change Dad", function() {
            openSubState(new ChooseCharacterScreen(function(mod, name) {
                var dadLayer = members.indexOf(dad);
                var newChar = new Character(dad.x - dad.charGlobalOffset.x, dad.y - dad.charGlobalOffset.y, '$mod:$name');
                
                newChar.name = "Dad";
                newChar.type = "Dad";
                newChar.scrollFactor.set(dad.scrollFactor.x, dad.scrollFactor.y);

                if (selectedObj == dad) selectedObj = newChar;
                if (selectOnly == dad) selectOnly = newChar;
                remove(dad);
                dad.destroy();
                dad = newChar;
                insert(dadLayer, newChar);
                updateStageElements();
            }));
        });


        stageTab.add(deleteSpriteButton);
        stageTab.add(addSpriteButton);
        stageTab.add(layerUpButton);
        stageTab.add(layerDownButton);
        stageTab.add(moveLayerLabel);
        stageTab.add(changeDadButton);
        stageTab.add(changeGFButton);
        stageTab.add(changeBFButton);
        tabs.addGroup(stageTab);
    }

    function addGlobalSetsTab() {
        globalSetsTab = new FlxUI(null, tabs);
        globalSetsTab.name = "globalSets";

        defCamZoomNum = new FlxUINumericStepper(290, 10, 0.05, stage.defaultCamZoom == null ? 1 : stage.defaultCamZoom, 0.1, 5, 2);
        defCamZoomNum.x -= defCamZoomNum.width;
        var defCamZoomLabel = new FlxUIText(10, defCamZoomNum.y + (defCamZoomNum.height / 2), 0, "Camera Zoom");
        defCamZoomLabel.y -= defCamZoomLabel.height / 2;

        followLerpNum = new FlxUINumericStepper(defCamZoomNum.x, defCamZoomNum.y + defCamZoomNum.height + 5, 0.01, stage.followLerp == null ? 0.04 : stage.followLerp, 0.01, 1, 2);
        var followLerpNumLabel = new FlxUIText(10, followLerpNum.y + (followLerpNum.height / 2), 0, "Follow Lerp");
        followLerpNumLabel.y -= followLerpNumLabel.height / 2;
        
        globalSetsTab.add(defCamZoomLabel);
        globalSetsTab.add(defCamZoomNum);
        globalSetsTab.add(followLerpNumLabel);
        globalSetsTab.add(followLerpNum);
        tabs.addGroup(globalSetsTab);
    }

    public override function onDropFile(path:String) {
        trace(path);
        var fileExt = Path.extension(path).toLowerCase();
        var stagePath = '${Paths.modsPath}/${ToolboxHome.selectedMod}/images/stages/${stageFile}';
        var fileName = Path.withoutDirectory(Path.withoutExtension(path));
        FileSystem.createDirectory('$stagePath/');

        var pathWithoutExt = Path.withoutExtension(path);

        var doSparrow = function() {
            if (FileSystem.exists('$stagePath/${fileName}.png') ||
                FileSystem.exists('$stagePath/${fileName}.xml')) {
                
                
                for (i in 0...100) { // now try iterating backwards, bitch (lmao)
                    if (!FileSystem.exists('$stagePath/${fileName}${i}.png') &&
                        !FileSystem.exists('$stagePath/${fileName}${i}.xml')) {
                            fileName = '${fileName}${i}';
                            break;
                    }
                }
            }
            File.copy('$pathWithoutExt.png', '$stagePath/${fileName}.png');
            File.copy('$pathWithoutExt.xml', '$stagePath/${fileName}.xml');
			
			ModSupport.loadMod(ToolboxHome.selectedMod); // reload all assets

            stage.sprites.push({
                type: "SparrowAtlas",
                scrollFactor: [1, 1],
                name: fileName,
                src: 'stages/${stageFile}/${fileName}',
                animation: {
                    name: "",
                    fps: 24,
                    type: "Loop"
                }
            });
            updateStageElements();
        }
        switch(fileExt) {
            case "png":
                if (FileSystem.exists('$pathWithoutExt.xml')) {
                    doSparrow();
                } else {
                    if (FileSystem.exists('$stagePath/${fileName}.png')) {
                    } else {
                        File.copy('$pathWithoutExt.png', '$stagePath/${fileName}.png');
						ModSupport.loadMod(ToolboxHome.selectedMod);
                    }
                    stage.sprites.push({
                        type: "Bitmap",
                        scrollFactor: [1, 1],
                        name: fileName,
                        src: 'stages/${stageFile}/${fileName}'
                    });
                    updateStageElements();
                }
            case "xml":
                if (FileSystem.exists('$pathWithoutExt.png')) {
                    doSparrow();
                } else {
                    showMessage("Error", "No PNG file was found for your Sparrow Atlas. Make sure there's a corresponding PNG file.");
                    return;
                }
            default:
                showMessage("Error", "Dropped file must be of type \"png\" or \"xml\"");
                return;
        }

        lime.app.Application.current.window.focus();
    }
    
    function updateEase() {
        if (selectedObj == null || homies.contains(selectedObj.name)) return true;
        var v = bumpOffsetEase.selectedId + bumpOffsetEaseType.selectedId;
        var invalid = easeFuncs[v] == null;
        var val = v;
        if (invalid)
            val = bumpOffsetEase.selectedId;
        if (selectedObj != null) {
            if (selectedObj.onBeatOffset == null) selectedObj.onBeatOffset = {
                x: 0,
                y: 0,
                ease: "linear"
            };
            selectedObj.onBeatOffset.ease = val;
        }
        return invalid;
    }

    function addSelectedObjectTab() {
        selectedObjTab = new FlxUI(null, tabs);
        selectedObjTab.name = "selectedElem";

        objName = new FlxUIText(10, 10, 280, "(No selected sprite)", 12);
        posLabel = new FlxUIText(10, objName.y + objName.height + 10, 280, "Sprite position");

        sprPosX = new FlxUINumericStepper(10, posLabel.y + (posLabel.height / 2), 10, 0, -99999, 99999);
        sprPosX.y -= sprPosX.height / 2;
        sprPosY = new FlxUINumericStepper(10, sprPosX.y, 10, 0, -99999, 99999);

        sprPosY.x = 290 - sprPosY.width;
        sprPosX.x = sprPosY.x - sprPosY.width - 5;

        scrollFactorLabel = new FlxUIText(10, posLabel.y + sprPosX.height + 5, 280, "Scroll Factor");

        scrFacX = new FlxUINumericStepper(10, scrollFactorLabel.y + (scrollFactorLabel.height / 2), 0.05, 1, -99999, 99999, 2);
        scrFacX.y -= scrFacX.height / 2;
        scrFacY = new FlxUINumericStepper(10, scrFacX.y, 0.05, 1, -99999, 99999, 2);

        scrFacY.x = 290 - scrFacY.width;
        scrFacX.x = scrFacY.x - scrFacY.width - 5;

        scaleLabel = new FlxUIText(10, scrollFactorLabel.y + scrFacX.height + 5, 280, "Scale");
        scaleNum = new FlxUINumericStepper(10, scaleLabel.y + (scaleLabel.height / 2), 0.1, 0, 0, 10, 2);
        scaleNum.y -= scaleLabel.height / 2;
        scaleNum.x = 290 - scaleNum.width;

        opacityLabel = new FlxUIText(10, scaleLabel.y + scaleNum.height + 5, 280, "Opacity");
        opacityNum = new FlxUINumericStepper(10, opacityLabel.y + (opacityLabel.height / 2), 0.1, 1, 0, 1, 2);
        opacityNum.y -= opacityNum.height / 2;
        opacityNum.x = 290 - opacityNum.width;

        antialiasingCheckbox = new FlxUICheckBox(10, opacityNum.y + opacityNum.height, null, null, "Anti-aliasing", 100, null, function() {
            if (selectedObj != null) selectedObj.antialiasing = antialiasingCheckbox.checked;
        });

        shaderLabel = new FlxUIText(10, antialiasingCheckbox.y + antialiasingCheckbox.height + 10, 280, "Custom Shader name (without the .frag and .vert ext)");
        shaderNameInput = new FlxUIInputText(10, shaderLabel.y + shaderLabel.height, 250, '');
        pickShader = new FlxUIButton(shaderNameInput.x + shaderNameInput.width + 10, shaderNameInput.y, "", function() {
            var fe:FileExplorer;
            openSubState(fe = new FileExplorer(ToolboxHome.selectedMod, Shader, '', function(p) {
                p = p.replace("\\", "/");
                while(p.charAt(0) == "/") p = p.substr(1);
                if (p.startsWith("shaders/")) {
                    shaderNameInput.text = '${ToolboxHome.selectedMod}:${Path.withoutExtension(p.substr(8))}';
                } else {
                    var m = ToolboxMessage.showMessage("Error", "The shader must be in the \"shaders\" folder");
                    m.cameras = [dummyHUDCamera, camHUD];
                    openSubState(m);
                }
            }));
            fe.cameras = [dummyHUDCamera, camHUD];
        });
        pickShader.resize(20, 20);
        pickShaderIcon = new FlxSprite(pickShader.x + 2, pickShader.y + 2);
        CoolUtil.loadUIStuff(pickShaderIcon, "folder");
        shaderNameInput.y += 2;

        bumpOffsetLabel = new FlxUIText(10, shaderNameInput.y + shaderNameInput.height + 10, 280, "On Beat tween");
        bumpOffsetX = new FlxUINumericStepper(10, bumpOffsetLabel.y + bumpOffsetLabel.height, 10, 0, -9999, 9999);
        bumpOffsetXLabel = new FlxUIText(10, bumpOffsetX.y + (bumpOffsetX.height / 2), 0, "X: ");
        bumpOffsetXLabel.y -= bumpOffsetXLabel.height / 2;
        bumpOffsetX.x += bumpOffsetXLabel.width;
        bumpOffsetYLabel = new FlxUIText(bumpOffsetX.x + bumpOffsetX.width + 10, bumpOffsetXLabel.y, 0, "Y: ");
        bumpOffsetY = new FlxUINumericStepper(bumpOffsetYLabel.x + bumpOffsetYLabel.width, bumpOffsetX.y, 10, 0, -9999, 9999);
        bumpOffsetEaseLabel = new FlxUIText(bumpOffsetY.x + bumpOffsetY.width + 10, bumpOffsetYLabel.y, 0, "Ease: ");
        var eases:Array<StrNameLabel> = [];
        for(k=>e in easeFuncs) {
            var invalid = false;
            var inOutShit = 0;
            if (k.endsWith('InOut')) inOutShit = 5;
            else if (k.endsWith('In')) inOutShit = 2;
            else if (k.endsWith('Out')) inOutShit = 3;
            var finalString = k.substr(0, k.length - inOutShit);
            for(e in eases) if (e.name == finalString) {invalid = true; break;}
            if (invalid) continue;

            var resultString:Array<String> = [];
            var currentString = "";
            for(i in 0...finalString.length) {
                var char = finalString.charAt(i);
                if (char.toUpperCase() == char) { // if uppercase
                    resultString.push(currentString);
                    currentString = char;
                } else {
                    currentString += char;
                    if (currentString.length < 2) currentString = currentString.toUpperCase();
                }
            }
            if (currentString.trim() != "") {
                resultString.push(currentString);
            }
            eases.push(new StrNameLabel(k.substr(0, k.length - inOutShit), resultString.join(" ")));
        }
        bumpOffsetEase = new FlxUIDropDownMenu(10, bumpOffsetY.y + bumpOffsetY.height + 10, eases, function(s) {
            bumpOffsetEaseType.visible = !updateEase();
        });
        bumpOffsetEase.dropDirection = Down;
        bumpOffsetEaseType = new FlxUIDropDownMenu(bumpOffsetEase.x + bumpOffsetEase.width + 10, bumpOffsetEase.y, [new StrNameLabel('In', 'In'), new StrNameLabel('Out', 'Out'), new StrNameLabel('InOut', 'In & Out')], function(s) {
            updateEase();
        });

        /*
         *  /!\ SPARROW SHIT
         */
        sparrowAnimationTitle = new FlxUIText(10, bumpOffsetEaseType.y + 30, 280, "Sparrow Animation Settings");
        sparrowAnimationTitle.alignment = CENTER;
        animationNameTitle = new FlxUIText(10, sparrowAnimationTitle.y + sparrowAnimationTitle.height + 10, 280, "Animation Name");

        animationNameTextBox = new FlxUIInputText(10, animationNameTitle.y + animationNameTitle.height, 280, "", 8);
        animationFPSNumeric = new FlxUINumericStepper(10, animationNameTextBox.y + animationNameTextBox.height + 5, 1, 24, 1, 120, 0);

        fpsLabel = new FlxUIText(10, animationFPSNumeric.y + (animationFPSNumeric.height / 2), 0, "FPS: ");
        fpsLabel.y -= fpsLabel.height / 2;
        animationFPSNumeric.x += fpsLabel.width;

        animationLabel = new FlxUIDropDownMenu(10, animationFPSNumeric.y + animationFPSNumeric.height + 10, animTypes, function(id) {});

        animationTypeLabel = new FlxUIText(10, animationLabel.y + (10), 0, "Type: ");
        animationTypeLabel.y -= animationTypeLabel.height / 2;
        animationLabel.x += animationTypeLabel.width;

        applySparrowButton = new FlxUIButton(150, animationLabel.y + 30, "Apply", function () {
            selectedObj.anim = {
                type: animationLabel.selectedId,
                name: animationNameTextBox.text,
                fps: Std.int(animationFPSNumeric.value)
            };
            selectedObj.animation.addByPrefix(selectedObj.anim.name, selectedObj.anim.name, selectedObj.anim.fps, selectedObj.anim.type.toLowerCase() == "loop");
            selectedObj.animation.play(selectedObj.anim.name);
        });
        applySparrowButton.x -= applySparrowButton.width / 2;



       

        selectedObjTab.add(objName);
        selectedObjTab.add(posLabel);
        selectedObjTab.add(sprPosX);
        selectedObjTab.add(sprPosY);
        selectedObjTab.add(scrollFactorLabel);
        selectedObjTab.add(scrFacX);
        selectedObjTab.add(scrFacY);
        selectedObjTab.add(scaleLabel);
        selectedObjTab.add(scaleNum);
        selectedObjTab.add(opacityLabel);
        selectedObjTab.add(opacityNum);
        selectedObjTab.add(antialiasingCheckbox);
        selectedObjTab.add(shaderLabel);
        selectedObjTab.add(shaderNameInput);
        selectedObjTab.add(pickShader);
        selectedObjTab.add(pickShaderIcon);
        selectedObjTab.add(bumpOffsetLabel);
        selectedObjTab.add(bumpOffsetX);
        selectedObjTab.add(bumpOffsetXLabel);
        selectedObjTab.add(bumpOffsetY);
        selectedObjTab.add(bumpOffsetYLabel);
        selectedObjTab.add(sparrowAnimationTitle);
        selectedObjTab.add(animationNameTitle);
        selectedObjTab.add(animationNameTextBox);
        selectedObjTab.add(animationFPSNumeric);
        selectedObjTab.add(fpsLabel);
        selectedObjTab.add(animationLabel);
        selectedObjTab.add(animationTypeLabel);
        selectedObjTab.add(applySparrowButton);
        selectedObjTab.add(bumpOffsetEase);
        selectedObjTab.add(bumpOffsetEaseType);
        tabs.addGroup(selectedObjTab);

        selectedObj = null;
    }
    public override function create() {
        easeFuncs = [];
        var forbiddenValues = ["PI2", "EL", "B1", "B2", "B3", "B4", "B5", "B6", "ELASTIC_AMPLITUDE", "ELASTIC_PERIOD"];
        for(s in Type.getClassFields(FlxEase)) {
            if (!forbiddenValues.contains(s)) {
                var value = Reflect.getProperty(FlxEase, s);
                easeFuncs[s] = value;
            }
        }
        
        Conductor.songPosition = Conductor.songPositionOld = -1;
        if (FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music("characterEditor", "preload"));
            Conductor.changeBPM(125);
        }
        #if desktop
            Discord.DiscordClient.changePresence("In the Stage Editor...", null, "Stage Editor Icon");
        #end
        super.create();
        persistentDraw = true;
        persistentUpdate = false;

        camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        dummyHUDCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        FlxG.cameras.reset(dummyHUDCamera);
        FlxG.cameras.add(camGame, true);
		FlxG.cameras.add(camHUD, false);
        camHUD.bgColor = 0x00000000;

        camThingy = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/camThingy', 'shared'));
        camThingy.cameras = [dummyHUDCamera, camHUD];
        camThingy.alpha = 0.5;
        camThingy.x = ((FlxG.width - 300) / 2) - (camThingy.width / 2);
        camThingy.scrollFactor.set(0, 0);
        add(camThingy);

        tabs = new FlxUITabMenu(null, [
            {
                label: "Elements",
                name: "stage"
            },
            {
                label: "Selected Elem.",
                name: "selectedElem"
            },
            {
                label: "Global Settings",
                name: "globalSets"
            }
        ], true);

        var jsonMode = false;
        if (FileSystem.exists('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.json')) {
            stage = Json.parse(File.getContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.json'));
        } else {
            stage = Unserializer.run(File.getContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.stage'));
        }
        camGame.zoom = stage.defaultCamZoom == null ? 1 : stage.defaultCamZoom;

        if (stage.bfOffset == null || stage.bfOffset.length == 0) stage.bfOffset = [0, 0];
        if (stage.bfOffset.length < 2) stage.bfOffset = [stage.bfOffset[0], 0];

        if (stage.gfOffset == null || stage.gfOffset.length == 0) stage.gfOffset = [0, 0];
        if (stage.gfOffset.length < 2) stage.gfOffset = [stage.gfOffset[0], 0];

        if (stage.dadOffset == null || stage.dadOffset.length == 0) stage.dadOffset = [0, 0];
        if (stage.dadOffset.length < 2) stage.dadOffset = [stage.dadOffset[0], 0];

        bf = new Boyfriend(bfDefPos.x + stage.bfOffset[0], bfDefPos.y + stage.bfOffset[1], "Friday Night Funkin':bf");
        bf.name = "Boyfriend";
        bf.type = "BF";

        gf = new Character(gfDefPos.x + stage.gfOffset[0], gfDefPos.y + stage.gfOffset[1], "Friday Night Funkin':gf");
        gf.name = "Girlfriend";
        gf.type = "GF";

        dad = new Character(dadDefPos.x + stage.dadOffset[0], dadDefPos.y + stage.dadOffset[1], "Friday Night Funkin':dad");
        dad.name = "Dad";
        dad.type = "Dad";

        /*
        for(e in [bf, gf, dad]) {
            e.frames = Paths.getSparrowAtlas("stageEditorChars", "shared");
            switch(e.type) {
                case "BF":
                    e.animation.addByPrefix("dance", "BF idle dance", 24);
                case "GF":
                    e.animation.addByPrefix("dance", "GF Dancing Beat", 24);
                case "Dad":
                    e.animation.addByPrefix("dance", "Dad idle dance", 24);
            }
            e.animation.play("dance");
            e.antialiasing = true;
            e.updateHitbox();
        }
        */

        addStageTab();
        addSelectedObjectTab();
        addGlobalSetsTab();

        var hideButton:FlxUIButton = null;
        hideButton = new FlxUIButton(FlxG.width - 320, 20, ">", function() {
            closed = !closed;
            hideButton.label.text = closed ? "<" : ">";
        });
        hideButton.scrollFactor.set(1, 1);
        hideButton.resize(20, FlxG.height - 20);
        hideButton.cameras = [camHUD];
        add(hideButton);

        tabs.addGroup(stageTab);

        tabs.cameras = [dummyHUDCamera, camHUD];
        tabs.resize(300, FlxG.height - 20);
        tabs.x = FlxG.width - tabs.width;
        tabs.y = 20;
        add(tabs);
        var closeButton = new FlxUIButton(FlxG.width - 20, 0, "X", onClose);
        closeButton.resize(20, 20);
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = FlxColor.WHITE;
        closeButton.cameras = [dummyHUDCamera, camHUD];

        var saveButton = new FlxUIButton(FlxG.width - 20, 0, "Save", function() {
            try {
                save();
            } catch(e) {
                openSubState(ToolboxMessage.showMessage('Error', 'Failed to save stage\n\n$e', null, camHUD));
                return;
            }
            openSubState(ToolboxMessage.showMessage('Success', 'Stage saved successfully !', null, camHUD));
        });
        saveButton.x -= saveButton.width;
        saveButton.cameras = [dummyHUDCamera, camHUD];
        saveButton.scrollFactor.set(1, 1);
        add(saveButton);
        add(closeButton);
        updateStageElements();

    }
    
    public function onClose() {
        if (unsaved) {
            
            var t = new ToolboxMessage("Warning", "Some changes to the stage weren't saved. Do you want to save them ?", [
                {
                    label: "Save",
                    onClick: function(mes) {
                        save();
                        bye();
                    }
                },
                { 
                    label: "Don't Save",
                    onClick: function(mes) {
                        bye();
                    }
                },
                {
                    label: "Cancel",
                    onClick: function(mes) {}
                }
            ], null, camHUD);
            t.cameras = [dummyHUDCamera, camHUD];
            openSubState(t);
        } else {
            bye();
        }
    }
    public var unsaved = false;
    public function save() {
        updateJsonData();
        var path = '${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}';
        /*
        if (FileSystem.exists('$path.json')) FileSystem.deleteFile('$path.json');
        File.saveContent('$path.stage', Serializer.run(stage));
        */
        File.saveContent('$path.json', Json.stringify(stage));
        unsaved = false;
    }
    public function updateStageElements() {
        var alreadySpawnedSprites:Map<String, FlxStageSprite> = [];
        var toDelete:Array<FlxStageSprite> = [];
        for (e in selectOnlyButtons) {
            remove(e);
            stageTab.remove(e);
            e.destroy();
        }
        selectOnlyButtons = [];
        for (e in members) {
            if (Std.isOfType(e, FlxStageSprite)) {
                var sprite = cast(e, FlxStageSprite);
                if (!homies.contains(sprite.type)) {
                    alreadySpawnedSprites[sprite.name] = sprite;
                    toDelete.push(sprite);
                }
                remove(sprite);
            }
        }
        for(s in stage.sprites) {
            var spr = alreadySpawnedSprites[s.name];
            if (spr != null) {
                toDelete.remove(spr);
                add(spr);
            } else {
                switch(s.type) {
                    case "SparrowAtlas":
                        spr = Stage.generateSparrowAtlas(s, ToolboxHome.selectedMod);
                        trace(spr);
                        add(spr);
                    case "Bitmap":
                        spr = Stage.generateBitmap(s, ToolboxHome.selectedMod);
                        trace(spr);
                        add(spr);
                    case "BF":
                        if (s.scrollFactor == null) s.scrollFactor = [1, 1];
                        while (s.scrollFactor.length < 2) s.scrollFactor.push(1);
                        bf.scrollFactor.set(s.scrollFactor[0], s.scrollFactor[1]);
                        Stage.doTheCharShader(bf, s, ToolboxHome.selectedMod);
                        add(bf);
                        spr = bf;
                    case "GF":
                        if (s.scrollFactor == null) s.scrollFactor = [1, 1];
                        while (s.scrollFactor.length < 2) s.scrollFactor.push(1);
                        gf.scrollFactor.set(s.scrollFactor[0], s.scrollFactor[1]);
                        Stage.doTheCharShader(gf, s, ToolboxHome.selectedMod);
                        add(gf);
                        spr = gf;
                    case "Dad":
                        if (s.scrollFactor == null) s.scrollFactor = [1, 1];
                        while (s.scrollFactor.length < 2) s.scrollFactor.push(1);
                        dad.scrollFactor.set(s.scrollFactor[0], s.scrollFactor[1]);
                        Stage.doTheCharShader(dad, s, ToolboxHome.selectedMod);
                        add(dad);
                        spr = dad;
                }
            }
            if (spr != null) {
                var button = new FlxUIButton(10, 58 + (selectOnlyButtons.length * 20), (selectedObj == spr || objBeingMoved == spr || selectOnly == spr) ? '> ${spr.name} <' : spr.name, function() {
                    if (selectOnly == spr) {
                        selectOnly = selectedObj = null;
                    } else {
                        selectedObj = spr;
                        selectOnly = spr;
                    }
                });
                button.visible = tabs.selected_tab_id == "stage";
                if (homies.contains(spr.type)) {
                    button.label.color = FlxColor.WHITE;
                    switch(spr.type.toLowerCase()) {
                        case "bf":
                            button.color = 0xFF31B0D1;
                        case "gf":
                            button.color = 0xFFA5004D;
                        case "dad":
                            button.color = 0xFFAF66CE;
                    }
                }
                button.resize(280, 20);
                stageTab.add(button);
                selectOnlyButtons.push(button);
            }
        }
    }

    public function updateJsonData() {
        stage.sprites = [];
        for (e in members) {
            if (Std.isOfType(e, FlxStageSprite)) {
                var sprite = cast(e, FlxStageSprite);
                stage.sprites.push({
                    type: sprite.type,
                    src: sprite.spritePath,
                    scrollFactor: [sprite.scrollFactor.x, sprite.scrollFactor.y],
                    scale: FlxMath.roundDecimal((sprite.scale.x + sprite.scale.y) / 2, 2),
                    pos: [FlxMath.roundDecimal(sprite.x, 2), FlxMath.roundDecimal(sprite.y, 2)],
                    name: sprite.name,
                    antialiasing: sprite.antialiasing,
                    animation: sprite.anim,
                    shader: sprite.shaderName,
                    beatTween: sprite.onBeatOffset,
                    alpha: FlxMath.roundDecimal(sprite.alpha, 2)
                });
            }
        }
        stage.bfOffset = [FlxMath.roundDecimal(bf.x - bfDefPos.x - bf.charGlobalOffset.x, 2), FlxMath.roundDecimal(bf.y - bfDefPos.y - bf.charGlobalOffset.y, 2)];
        stage.gfOffset = [FlxMath.roundDecimal(gf.x - gfDefPos.x - gf.charGlobalOffset.x, 2), FlxMath.roundDecimal(gf.y - gfDefPos.y - gf.charGlobalOffset.y, 2)];
        stage.dadOffset = [FlxMath.roundDecimal(dad.x - dadDefPos.x - dad.charGlobalOffset.x, 2), FlxMath.roundDecimal(dad.y - dadDefPos.y - dad.charGlobalOffset.y, 2)];
        
        unsaved = true;
    }

    public override function update(elapsed:Float) {
        var controlsEnabled:Bool = true;
        for(e in members) {
            if (Std.isOfType(e, FlxUIInputText)) {
                if (cast(e, FlxUIInputText).hasFocus) {
                    controlsEnabled = false;
                    break;
                }
            }
        }
        if (FlxG.sound.music.time != Conductor.songPositionOld) {
            Conductor.songPosition = Conductor.songPositionOld = FlxG.sound.music.time;
        } else {
            Conductor.songPosition += elapsed * 1000;
        }
        if (tabs.selected_tab_id != oldTab) {
            oldTab = tabs.selected_tab_id;
            switch(tabs.selected_tab_id) {
                case "selectedElem":
                    selectedObj = selectedObj;
            }
        }

        var scrollVal = elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
        if (controlsEnabled) {
            if (FlxG.keys.pressed.LEFT) {
                camGame.scroll.x -= scrollVal;
                moveOffset.x -= scrollVal;
            }
            if (FlxG.keys.pressed.RIGHT) {
                camGame.scroll.x += scrollVal;
                moveOffset.x += scrollVal;
            }
            if (FlxG.keys.pressed.DOWN) {
                camGame.scroll.y += elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
                moveOffset.y += scrollVal;
            }
            if (FlxG.keys.pressed.UP) {
                camGame.scroll.y -= elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
                moveOffset.y -= scrollVal;
            }
        }

        if (selectedObj != null) {
            if (selectedObj.onBeatOffset == null) selectedObj.onBeatOffset = {x:0,y:0,ease:'linear'};
            selectedObj.onBeatOffset.x = bumpOffsetX.value;
            selectedObj.onBeatOffset.y = bumpOffsetY.value;
            if (selectedObj.shaderName != shaderNameInput.text) {
                selectedObj.shaderName = shaderNameInput.text;

                var splitThing = selectedObj.shaderName.split(":");
                if (splitThing.length < 2) splitThing.insert(0, ToolboxHome.selectedMod);
                selectedObj.shader = new CustomShader(splitThing.join(":"), null, null);
            } 
            if (controlsEnabled) {
                if (FlxG.keys.pressed.SHIFT) {
                    if (FlxG.keys.justPressed.W)
                        selectedObj.y -= 10;
        
                    if (FlxG.keys.justPressed.S)
                        selectedObj.y += 10;
        
                    if (FlxG.keys.justPressed.A)
                        selectedObj.x -= 10;
        
                    if (FlxG.keys.justPressed.D)
                        selectedObj.x += 10;
    
                } else {
                    if (FlxG.keys.pressed.W)
                        selectedObj.y -= 250 * elapsed / camGame.zoom;
        
                    if (FlxG.keys.pressed.S)
                        selectedObj.y += 250 * elapsed / camGame.zoom;
        
                    if (FlxG.keys.pressed.A)
                        selectedObj.x -= 250 * elapsed / camGame.zoom;
        
                    if (FlxG.keys.pressed.D)
                        selectedObj.x += 250 * elapsed / camGame.zoom;
                }
    
                if (FlxG.keys.justPressed.Q)
                    moveLayer(selectedObj, -1);
        
                if (FlxG.keys.justPressed.E)
                    moveLayer(selectedObj, 1);
            }
        }


        if (controlsEnabled) {
            if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.BACKSPACE) {
                // resets
                var f = false;
                for(m in members) {
                    if (Std.isOfType(m, FlxUIInputText)) {
                        if (cast(m, FlxUIInputText).hasFocus) {
                            f = true;
                            break;
                        }
                    }
                }
                if (!f) camGame.scroll.x = camGame.scroll.y = 0;
            }
            if (FlxG.keys.justPressed.ESCAPE) {
                onClose();
            }
        }

        for(s in members) {
            if (Std.isOfType(s, FlxStageSprite)) {
                var sprite = cast(s, FlxStageSprite);
                if (!homies.contains(sprite.type)) {
                    if (Conductor.crochet == 0 || sprite.onBeatOffset == null) {
                        sprite.updateHitbox();
                    } else {
                        var easeFunc = easeFuncs[sprite.onBeatOffset.ease];
                        if (easeFunc == null) easeFunc = function(v) {return v;};
                        var easeVar = easeFunc((Conductor.songPosition / Conductor.crochet) % 1);
                        
				
                        sprite.updateHitbox();
                        sprite.offset.x += (sprite.onBeatOffset.x * easeVar);
                        sprite.offset.y += (sprite.onBeatOffset.y * easeVar);
                    }
                }
            }
        }
        try {
            super.update(elapsed);
        } catch(e) {

        }
        var mousePos = FlxG.mouse.getWorldPosition(camGame);
        
        if (objBeingMoved != null) {
            camHUD.alpha = FlxMath.lerp(camHUD.alpha, 0.2, 0.30 * 30 * elapsed);
            if (FlxG.mouse.pressed) {
                objBeingMoved.x = mousePos.x + moveOffset.x;
                objBeingMoved.y = mousePos.y + moveOffset.y;
                if (FlxG.mouse.wheel != 0 && !homies.contains(objBeingMoved.type)) {
                    objBeingMoved.scale.x = objBeingMoved.scale.y = ((objBeingMoved.scale.x + objBeingMoved.scale.y) / 2) + (0.1 * FlxG.mouse.wheel);
                    objBeingMoved.updateHitbox();
                }

                if (selectedObj != null) {
                    sprPosX.value = selectedObj.x;
                    sprPosY.value = selectedObj.y;
                    scrFacX.value = selectedObj.scrollFactor.x;
                    scrFacY.value = selectedObj.scrollFactor.y;
                    scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
                    opacityNum.value = selectedObj.alpha;
                }
            } else {
                enableGUI(true);
                objBeingMoved = null;
                updateJsonData();
            }
        } else {
            camHUD.alpha = FlxMath.lerp(camHUD.alpha, 1, 0.30 * 30 * elapsed);
            if (FlxG.keys.pressed.CONTROL)
                defCamZoomNum.value += 0.05 * FlxG.mouse.wheel;
            else
                camGame.zoom += 0.1 * FlxG.mouse.wheel;
            if (camGame.zoom < 0.1) camGame.zoom = 0.1;
            if (defCamZoomNum.value < 0.1) defCamZoomNum.value = 0.1;

            if (FlxG.mouse.getScreenPosition(camHUD).x >= FlxG.width - 320 - camHUD.scroll.x) {
                // when on tabs thingy
                if (selectedObj != null) {
                    selectedObj.x = sprPosX.value;
                    selectedObj.y = sprPosY.value;
                    selectedObj.scrollFactor.x = scrFacX.value;
                    selectedObj.scrollFactor.y = scrFacY.value;
                    if (scaleNum.value != selectedObj.scale.x) {
                        selectedObj.scale.set(scaleNum.value, scaleNum.value);
                        selectedObj.updateHitbox();
                    }
                    selectedObj.alpha = opacityNum.value;
                }
            } else {
                
                if (selectedObj != null && selectedObj.exists) {
                    sprPosX.value = selectedObj.x;
                    sprPosY.value = selectedObj.y;
                    scrFacX.value = selectedObj.scrollFactor.x;
                    scrFacY.value = selectedObj.scrollFactor.y;
                    scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
                    opacityNum.value = (selectedObj.alpha);
                }

                // when on stage thingy
                var i = members.length - 1;
                if (selectOnly != null) {
                    if (FlxG.mouse.justPressed) {
                        enableGUI(false);
                        select(selectOnly, mousePos);
                    }
                } else {
                    while(i >= 0) {
                        var s = members[i];
                        if (Std.isOfType(s, FlxStageSprite)) {
                            s.cameras = [camGame];
                            var sprite = cast(s, FlxStageSprite);
                            if (overlaps(sprite, mousePos)) {
                                if (FlxG.mouse.justPressed) {
                                    enableGUI(false);
                                    select(sprite, mousePos);
                                }
                                break;
                            }
                        }
                        i--;
                    }
                }
            }
            
        }

        stage.defaultCamZoom = defCamZoomNum.value;
        stage.followLerp = followLerpNum.value;
        camThingy.scale.x = camThingy.scale.y = camGame.zoom / stage.defaultCamZoom;

        camHUD.scroll.x = FlxMath.lerp(camHUD.scroll.x, closed ? -300 : 0, 0.30 * 30 * elapsed);
        camThingy.x = (FlxG.width / 2) + camGame.x - (camThingy.width / 2);
        dummyHUDCamera.scroll.x = camHUD.scroll.x;
        
    }

    public var isGUIEnabled = true;
    function enableGUI(enable:Bool) {
        if (enable == isGUIEnabled) return;

        tabs.active = enable;
        for (s in members) {
            if (s == null) continue;
            if (s.cameras.contains(camHUD)) {
                s.active = enable;
            }
        }

        isGUIEnabled = enable;
    }
    function select(sprite:FlxStageSprite, mousePos:FlxPoint):Void {
        moveOffset.x = sprite.x - mousePos.x;
        moveOffset.y = sprite.y - mousePos.y;
        objBeingMoved = sprite;
        selectedObj = sprite;
    }
    function overlaps(sprite:FlxStageSprite, mousePos:FlxPoint):Bool {
        var pos = {
            x: sprite.x - sprite.offset.x,
            y: sprite.y - sprite.offset.y,
            x2: sprite.x - sprite.offset.x + sprite.width,
            y2: sprite.y - sprite.offset.y + sprite.height
        };
        return mousePos.x >= pos.x && mousePos.x < pos.x2 && mousePos.y >= pos.y && mousePos.y < pos.y2;
    }

    function moveLayer(sprite:FlxStageSprite, layer:Int) {
        for(k=>e in stage.sprites) {
            if (e.name == sprite.name) {
                if (k + layer < 0 || k + layer > stage.sprites.length) break;
                stage.sprites.remove(e);
                stage.sprites.insert(k + layer, e);
                updateStageElements();
                break;
            }
        }
    }

    public override function beatHit() {
        super.beatHit();
        for(s in members) {
            if (Std.isOfType(s, FlxStageSprite)) {
                var sprite = cast(s, FlxStageSprite);
                if (sprite.animType != null) {
                    if (sprite.animType.startsWith('OnBeat')) {
                        if (sprite.animation.curAnim != null) {
                            sprite.animation.play(sprite.animation.curAnim.name, sprite.animType == 'OnBeatForce');
                        }
                    }
                }
            }
        }
        
        bf.dance();
        dad.dance();
        gf.dance();
    }
}