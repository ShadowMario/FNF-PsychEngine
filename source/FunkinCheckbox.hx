import flixel.FlxSprite;

class FunkinCheckbox extends FlxSprite {
    public var checked(default, set):Bool = false;

    private var __offsets:Map<String, Array<Float>> = [
        "unchecked" => [0, 0],
        "checking" => [25, 100],
        "checked" => [13, 71]
    ];

    public function new(x:Float, y:Float, checked:Bool) {
        super(x, y);
        frames = Paths.getSparrowAtlas("checkboxThingie", "preload");
        animation.addByPrefix("checked", "Check Box Selected Static", 24, true);
        animation.addByPrefix("unchecked", "Check Box unselected", 24, true);
        animation.addByPrefix("checking", "Check Box selecting animation", 24, false);
        animation.play(checked ? "checked" : "unchecked");

        antialiasing = true;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (animation.curAnim == null || animation.finished || (animation.curAnim.reversed && animation.curAnim.curFrame <= 0)) {
            var anim = checked ? "checked" : "unchecked";
            animation.play(anim, true);
        }
        updateHitbox();
        if (animation.curAnim != null && __offsets.exists(animation.curAnim.name)) {
            var o = __offsets[animation.curAnim.name];
            offset.x += o[0] * scale.x;
            offset.y += o[1] * scale.y;
        } else {
        }
    }

    public function set_checked(v:Bool) {
        if (checked != (checked = v)) {
            animation.play("checking", true, !checked);
        }
        return checked;
    }

    public function check(c:Bool) {
        if (checked != (checked = c)) {
            CoolUtil.playMenuSFX(c ? 6 : 7);
        }
    }
}