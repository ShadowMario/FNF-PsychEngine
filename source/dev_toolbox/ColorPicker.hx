package dev_toolbox;

import openfl.geom.Rectangle;
import openfl.desktop.ClipboardTransferMode;
import flixel.tweens.FlxTween;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import openfl.display.PNGEncoderOptions;
import flixel.addons.transition.FlxTransitionableState;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.addons.ui.*;
import flixel.FlxSprite;

using StringTools;

class ColorPicker extends MusicBeatSubstate {
    var colorSprite:FlxUISprite;
    var colorPickerSprite:FlxUISprite;
    var colorSliderSprite:FlxUISprite;
    var colorSliderThing:FlxUISprite;
    var colorPickerThing:FlxUISprite;
    var color:FlxColor;
    var redNumeric:FlxUINumericStepperPlus;
    var greenNumeric:FlxUINumericStepperPlus;
    var blueNumeric:FlxUINumericStepperPlus;

    public function updatePicker(c:FlxColor) {
        colorPickerSprite.pixels.lock();
        var hue = c.hue;
        for (x in 0...100) {
            for (y in 0...100) {
                colorPickerSprite.pixels.setPixel32(x + 1, y + 1, FlxColor.fromHSL(hue, x / 100, y / 100));
            }
        }
        colorPickerSprite.pixels.unlock();
        
        
        color.hue = hue;
        updateColor(null, false);

        colorPickerThing.visible = true;
        colorPickerThing.setPosition(colorPickerSprite.x + (color.saturation * 100) - 4, colorPickerSprite.y + (color.lightness * 100) - 5);
        colorSliderThing.visible = true;
        colorSliderThing.y = colorSliderSprite.y + (c.hue / 3.6) - 3;

    }

    public function updateColor(?e:Dynamic, pick:Bool = true) {
        colorSprite.color = color;
        var ignore = [redNumeric, greenNumeric, blueNumeric];
        if (!ignore.contains(e)) {
            redNumeric.value = color.red;
            greenNumeric.value = color.green;
            blueNumeric.value = color.blue;
        }
        if (pick) updatePicker(color);
    }
    
    public override function new(color2:FlxColor, callback:FlxColor->Void) {
        super();
        color = color2;
        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        bg.scrollFactor.set();
        add(bg);

        var tabs = [
            {name: "colorPicker", label: 'Select a color...'}
		];
        var UI_Tabs = new FlxUITabMenu(null, tabs, true);
        UI_Tabs.x = 0;
        UI_Tabs.resize(420, 720);
        UI_Tabs.scrollFactor.set();
        UI_Tabs.screenCenter();
        add(UI_Tabs);

		var tab = new FlxUI(null, UI_Tabs);
		tab.name = "colorPicker";

        colorSprite = new FlxUISprite(10, 10);
        colorSprite.makeGraphic(70, 55, 0xFFFFFFFF);
        colorSprite.pixels.lock();
        for (x in 0...colorSprite.pixels.width) {
            colorSprite.pixels.setPixel32(x, 0, 0xFF000000);
            colorSprite.pixels.setPixel32(x, 1, 0xFF000000);
            colorSprite.pixels.setPixel32(x, 53, 0xFF000000);
            colorSprite.pixels.setPixel32(x, 54, 0xFF000000);
        }
        for (y in 0...colorSprite.pixels.height) {
            colorSprite.pixels.setPixel32(0, y, 0xFF000000);
            colorSprite.pixels.setPixel32(1, y, 0xFF000000);
            colorSprite.pixels.setPixel32(68, y, 0xFF000000);
            colorSprite.pixels.setPixel32(69 /* nice */, y, 0xFF000000);
        }
        colorSprite.pixels.unlock();
        colorSprite.x = 175;
        tab.add(colorSprite);
		var label = new FlxUIText(10, 75, 400, "RGB");
        redNumeric = new FlxUINumericStepperPlus(10, 75 + label.height, 1, 0, 0, 255, 0);
        greenNumeric = new FlxUINumericStepperPlus(20 + redNumeric.width, 75 + label.height, 1, 0, 0, 255, 0);
        blueNumeric = new FlxUINumericStepperPlus(30 + greenNumeric.width + redNumeric.width, 75 + label.height, 1, 0, 0, 255, 0);
        redNumeric.value = color.red;
        greenNumeric.value = color.green;
        blueNumeric.value = color.blue;
        tab.add(label);
        redNumeric.onChange = function(value) {
            color.red = Std.int(redNumeric.value);
            updateColor(redNumeric);
        };
        greenNumeric.onChange = function(value) {
            color.green = Std.int(greenNumeric.value);
            updateColor(greenNumeric);
        };
        blueNumeric.onChange = function(value) {
            color.blue = Std.int(blueNumeric.value);
            updateColor(blueNumeric);
        };

        var flashTween:FlxTween = null;
        var pasteFromClipboard:FlxUIButton = null;
        pasteFromClipboard = new FlxUIButton(blueNumeric.x + blueNumeric.width + 10, 75 + label.height, "Paste from Clipboard", function() {
            var clipboard = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_PREFERRED);
            if (clipboard == null) {
                if (flashTween != null) {
                    flashTween.cancel();
                    flashTween = null;
                }
                pasteFromClipboard.color = 0xFFFF4444;
                flashTween = FlxTween.color(pasteFromClipboard, 0.2, 0xFFFF4444, 0xFFFFFFFF, {startDelay: 0.2});
                return;
            }
            var generatedColor = FlxColor.fromString(clipboard.toString());
            if (clipboard == null) {
                if (flashTween != null) {
                    flashTween.cancel();
                    flashTween = null;
                }
                pasteFromClipboard.color = 0xFFFF4444;
                flashTween = FlxTween.color(pasteFromClipboard, 0.2, 0xFFFF4444, 0xFFFFFFFF, {startDelay: 0.2});
                return;
            }
            redNumeric.value = generatedColor.red;
            greenNumeric.value = generatedColor.green;
            blueNumeric.value = generatedColor.blue;
            colorSprite.color = generatedColor;
            color = generatedColor;
        });
        pasteFromClipboard.resize(280 - (blueNumeric.x + blueNumeric.width + 10), 20);


        colorPickerSprite = new FlxUISprite(10, blueNumeric.y + blueNumeric.height + 10);
        colorPickerSprite.makeGraphic(102, 102, 0xFF000000);


        colorSliderSprite = new FlxUISprite(colorPickerSprite.x + colorPickerSprite.width + 10, colorPickerSprite.y);
        colorSliderSprite.makeGraphic(22, 102, 0xFF000000);
        colorSliderSprite.pixels.lock();

        colorSliderThing = new FlxUISprite(colorSliderSprite.x + colorSliderSprite.width + 1);
        colorSliderThing.loadGraphic(Paths.image("ui/colorHueSelector", "shared"));
        colorSliderThing.visible = false;

        colorPickerThing = new FlxUISprite(0, 0);
        colorPickerThing.loadGraphic(Paths.image("ui/colorSelector", "shared"));
        colorPickerThing.visible = false;

        for(y in 1...101) {
            colorSliderSprite.pixels.fillRect(new Rectangle(1, y, 20, 1), FlxColor.fromHSL(360 / 100 * (y - 1), 1, 0.5));
        }
        colorSliderSprite.pixels.unlock();
        updateColor();

        tab.add(label);
        tab.add(redNumeric);
        tab.add(greenNumeric);
        tab.add(blueNumeric);
        tab.add(pasteFromClipboard);
        tab.add(colorPickerSprite);
        tab.add(colorSliderSprite);
        tab.add(colorPickerThing);
        tab.add(colorSliderThing);

        var okButton = new FlxUIButton(10, colorSliderSprite.y + colorSliderSprite.height + 10, "OK", function() {
            close();
            callback(color);
        });
        tab.add(okButton);

        UI_Tabs.resize(420, okButton.y + 50);
        UI_Tabs.screenCenter();
        UI_Tabs.y -= UI_Tabs.y % 1;

        var closeButton = new FlxUIButton(UI_Tabs.x + UI_Tabs.width - 23, UI_Tabs.y + 3, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        closeButton.scrollFactor.set();
        add(closeButton);

        UI_Tabs.addGroup(tab);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
            var screenPos = FlxG.mouse.getScreenPosition(FlxG.camera);
        if (FlxG.mouse.pressed) {
            if (
                screenPos.x > colorPickerSprite.x + 1 &&
                screenPos.y > colorPickerSprite.y + 1 &&
                screenPos.x < colorPickerSprite.x + colorPickerSprite.width - 1 &&
                screenPos.y < colorPickerSprite.y + colorPickerSprite.height - 1) {
                    var x = Std.int(screenPos.x - colorPickerSprite.x);
                    var y = Std.int(screenPos.y - colorPickerSprite.y);
                    var c = colorPickerSprite.pixels.getPixel32(x, y);
                    if (c == color) return;
                    color = colorPickerSprite.pixels.getPixel32(x, y);

                    
                    colorPickerThing.visible = true;
                    colorPickerThing.setPosition(Std.int(colorPickerSprite.x + x - 6), Std.int(colorPickerSprite.y + y - 5));

                    updateColor(null, false);
            }
            if (
                screenPos.x > colorSliderSprite.x + 1 &&
                screenPos.y > colorSliderSprite.y + 1 &&
                screenPos.x < colorSliderSprite.x + colorSliderSprite.width - 1 &&
                screenPos.y < colorSliderSprite.y + colorSliderSprite.height - 1) {
                    var x = Std.int(screenPos.x - colorSliderSprite.x);
                    var y = Std.int(screenPos.y - colorSliderSprite.y);
                    updatePicker(colorSliderSprite.pixels.getPixel32(x,y));
            }
        }
        
    }
}