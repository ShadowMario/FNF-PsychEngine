package flixel.addons.ui;

import flixel.ui.FlxBar;
import flixel.addons.ui.FlxUIAssets;

class FlxUISliderNew extends FlxUIGroup {

    public var object:Dynamic;
    public var variable:String;
    public var min:Float = 0;
    public var max:Float = 100;

    public var sliderSprite:FlxSprite;
    public var bar:FlxBar;

    public var minLabel:FlxUIText;
    public var maxLabel:FlxUIText;

    private var __isBeingMoved:Bool = false;

    public var step:Float = 0;
    public override function new(x:Float, y:Float, width:Int, height:Int, object:Dynamic, variable:String, min:Float, max:Float, ?minLabel:String, ?maxLabel:String) {
        super(x, y);
        this.object = object;
        this.variable = variable;
        this.min = min;
        this.max = max;

        if (minLabel == null) minLabel = Std.string(min);
        if (maxLabel == null) maxLabel = Std.string(max);

        sliderSprite = new FlxSprite(0, 0).loadGraphic(FlxUIAssets.IMG_SLIDER, true, FlxUIAssets.SLIDER_BUTTON_SIZE[0], FlxUIAssets.SLIDER_BUTTON_SIZE[1]);

        bar = new FlxBar(0, sliderSprite.y + sliderSprite.height, LEFT_TO_RIGHT, width, height, object, variable, min, max);
        bar.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);
        bar.y -= bar.height / 2;

        this.minLabel = new FlxUIText(bar.x, bar.y + bar.height + 5, 0, minLabel);
        this.maxLabel = new FlxUIText(bar.x + bar.width, bar.y + bar.height + 5, 0, maxLabel);
        this.maxLabel.x -= this.maxLabel.width;

        add(this.minLabel);
        add(this.maxLabel);
        add(bar);
        add(sliderSprite);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        

        if (FlxG.mouse.justPressed && (FlxG.mouse.overlaps(sliderSprite, camera) || FlxG.mouse.overlaps(bar, camera))) {
            __isBeingMoved = true;
        }
        if (FlxG.mouse.justReleased) __isBeingMoved = false;
        if (__isBeingMoved) {
            var cursorX = FlxG.mouse.getScreenPosition(camera).x - bar.x;
            if (object != null && variable != null) {
                if (step != 0) {
                    Reflect.setProperty(object, variable, CoolUtil.wrapFloat(min + (Math.floor(max / bar.width * cursorX / step) * step), min, max));
                } else {
                    Reflect.setProperty(object, variable, CoolUtil.wrapFloat(min + (max / bar.width * cursorX), min, max));
                }
            } else {
                trace("object is null");
            }
        }

        if (object != null && variable != null) bar.value = Reflect.getProperty(object, variable);
        sliderSprite.x = bar.x + ((bar.percent / 100) * bar.width) - (sliderSprite.width / 2);
    }
}