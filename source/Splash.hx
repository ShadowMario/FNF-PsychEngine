import haxe.Json;
import openfl.utils.Assets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import NoteShader.ColoredNoteShader;
import flixel.FlxG;
import flixel.FlxSprite;

typedef SplashConfig = {
    var animations:Array<SplashAnim>;
    var useColorShader:Bool;
    var antialiasing:Null<Bool>;
    var scale:Null<Float>;
}
typedef SplashAnim = {
    var name:String;
    var x:Int;
    var y:Int;
    var fps:Int;
}
class Splash extends FlxSprite {
    public static inline var splashCounts:Int = 2;

    public var config:SplashConfig = {
        useColorShader: true,
        scale: 1,
        antialiasing: true,
        animations: [
            {
                name: "splash1",
                x: 0,
                y: 0,
                fps: 24
            }
        ]
    };
    public function new(path:String) {
        super();
        frames = FlxAtlasFrames.fromSparrow('${path}.png', '$path.xml');
        if (Assets.exists('${path}.json')) {
            try {
                var conf = Json.parse(Assets.getText('${path}.json'));
                config = conf;
            } catch(e) {
                LogsOverlay.error('Failed to parse splash config for ${path}.\n\n$e');
            }
        }

        if (config == null) config = {
            antialiasing: true,
            scale: 1,
            useColorShader: true,
            animations: null
        };
        if (config.animations == null) config.animations = [
            {
                name: "splash",
                x: 0,
                y: 0,
                fps: 24
            }
        ];
        if (config.scale == null) config.scale = 1;
        if (config.antialiasing == null) config.antialiasing = true;

        for(a in config.animations) {
            animation.addByPrefix(a.name, a.name, a.fps, false);
        }
        visible = false;
        alpha = (PlayState.current == null ? Settings.engineSettings.data : PlayState.current.engineSettings).splashesAlpha;
        scale.set(config.scale, config.scale);

        antialiasing = config.antialiasing;
        
        shader = new ColoredNoteShader(255, 255, 255, false);
        updateHitbox();
    }

    public function pop(color:FlxColor) {
        visible = true;
        cast(shader, ColoredNoteShader).enabled.value = [config.useColorShader];
        cast(shader, ColoredNoteShader).setColors(color.red, color.green, color.blue);

        var anim = config.animations[FlxG.random.int(0, config.animations.length - 1)];
        animation.play(anim.name, true);
        centerOffsets();
        centerOrigin();
        offset.x -= anim.x;
        offset.y -= anim.y;
    }

    public override function update(elapsed:Float) {
        visible = animation.curAnim != null && !animation.curAnim.finished;
        super.update(elapsed);
    }

    public override function draw() {
        if (animation.curAnim != null && !animation.curAnim.finished) {
            super.draw();
        }
    }
}