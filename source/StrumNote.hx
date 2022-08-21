import flixel.math.FlxPoint;
import flixel.FlxG;
import NoteShader.ColoredNoteShader;
import flixel.FlxSprite;

@:allow(PlayState)
class StrumNote extends FlxSprite {
    public var notes_angle:Null<Float> = null;
    public var notes_alpha:Null<Float> = null; // Ranges from 0 to 1

    public var notesAlpha(get, set):Null<Float>; function get_notesAlpha() {return notes_alpha;} function set_notesAlpha(v:Float) {return notes_alpha = v;}
    public var notesAngle(get, set):Null<Float>; function get_notesAngle() {return notes_angle;} function set_notesAngle(v:Float) {return notes_angle = v;}


    public var colored:Bool = false;
    public var cpuRemainingGlowTime:Float = 0;
    public var isCpu:Bool = false;
    public var scrollSpeed:Null<Float> = null;

    private var _defaultPosition:FlxPoint;

    public var defaultPosition(get, null):FlxPoint;
    public function get_defaultPosition() {
        return new FlxPoint(_defaultPosition.x, _defaultPosition.y);
    }

    public function getAnimName() {
        return animation.curAnim == null ? "" : animation.curAnim.name;
    }

    public function getScrollSpeed() {
        
        return PlayState.current.engineSettings.customScrollSpeed ? PlayState.current.engineSettings.scrollSpeed : (scrollSpeed == null ? PlayState.SONG.speed : scrollSpeed);
    }

    public function getAlpha() {
        return (notes_alpha == null ? alpha : notes_alpha);
    }

    public function getAngle() {
        return (notes_angle == null ? angle : notes_angle);
    }

    public override function update(elapsed:Float) {
        doCpuStuff(elapsed);
        super.update(elapsed);
    }
    public override function draw() {
        doCpuStuff(0);
        super.draw();
    }

    public function doCpuStuff(elapsed:Float) {
        if (isCpu) {
            var animName = getAnimName();
            cpuRemainingGlowTime -= elapsed;
            if (cpuRemainingGlowTime <= 0 && animName != "static") {
                animation.play("static");
                animName = "static";
                centerOffsets();
                centerOrigin();
            }
            toggleColor(animName != "static" && colored);
            
        }
    }

    public function toggleColor(toggle:Bool) {
        if (Std.isOfType(this.shader, ColoredNoteShader))
            cast(this.shader, ColoredNoteShader).enabled.value = [toggle];
    }
}