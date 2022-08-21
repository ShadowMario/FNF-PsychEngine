package charter;

import flixel.addons.ui.FlxUIText;
import flixel.text.FlxText;
import flixel.*;
import flixel.group.FlxSpriteGroup;

class CharterEvent extends FlxSpriteGroup {
    public var sprite:FlxSprite;
    public var text:FlxUIText;
    public var time:Float;

    public var funcName:String = "";
    public var funcParams:Array<String> = [];

    public function overlapsSprite(?camera:FlxCamera) {
        if (camera == null) camera = FlxG.camera;
        return FlxG.mouse.overlaps(sprite, camera);
    }

    public function new(time:Float, ?funcName:String, ?funcParams:Array<String>) {
        if (funcName == null) funcName = "eventName";
        if (funcParams == null) funcParams = [];
        this.time = time;
        this.funcName = funcName;
        this.funcParams = funcParams;

        super();
        sprite = new FlxSprite(0, 0);
        sprite.frames = Paths.getSparrowAtlas('events', 'shared');
        sprite.animation.addByPrefix('PSYCH EVENT!!!!!', 'psych event');
        sprite.animation.addByPrefix('YOSHI ENGINE EVENT!!!!!!', 'event');
        sprite.animation.play('YOSHI ENGINE EVENT!!!!!!');
        sprite.setGraphicSize(YoshiCrafterCharter.GRID_SIZE, YoshiCrafterCharter.GRID_SIZE);
        sprite.updateHitbox();
        sprite.antialiasing = true;
        add(sprite);


        text = new FlxUIText(-350, sprite.height / 2, 350, "Function(Parameter1, Parameter2)");
        text.alignment = RIGHT;
        text.y -= text.height / 2;
        add(text);

        updateText();
    }

    public function updateText() {
        text.text = '$funcName(${funcParams.join(", ")})';
    }
}