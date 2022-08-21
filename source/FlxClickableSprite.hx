import flixel.math.FlxPoint;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class FlxClickableSprite extends FlxSprite {
    public var onClick:Void->Void = null;
    public var hoverColor:Null<FlxColor> = null;
    public var hovering:Bool = false;
    public var key:Null<FlxKey> = null;
	public var justPressed:Bool = false;
	public var pressed:Bool = false;
	public var justReleased:Bool = false;
    public var hitbox:FlxPoint = null;

    public override function new(x:Float, y:Float, ?onClick:Void->Void) {
        super(x, y);
        this.onClick = onClick;
    }

    public function _overlaps(point:FlxPoint) {
        var pos = this.getScreenPosition(null, this.camera);
        return (point.x > pos.x && point.x < pos.x + hitbox.x && point.y > pos.y && point.y < pos.y + hitbox.y);
    }
    public function setHitbox() {
        hitbox = new FlxPoint(frameWidth, frameHeight);
    }
    
    public override function update(elapsed) {
        super.update(elapsed);
		
        if (hitbox == null)
            setHitbox();
        var good = false;
        #if android
		for (t in FlxG.touches.list) {
			if (_overlaps(t.getScreenPosition(this.camera))) {
                justPressed = t.justPressed;
                pressed = t.pressed;
                justReleased = t.justReleased;
                good = true;
                if (hoverColor != null) color = hoverColor;
                break;
            }
		}
        #else
        if (_overlaps(FlxG.mouse.getScreenPosition(this.camera))) {
            hovering = true;
            justPressed = FlxG.mouse.justPressed;
            pressed = FlxG.mouse.pressed;
            justReleased = FlxG.mouse.justReleased;
            good = true;
            if (justPressed || pressed) {
                if (hoverColor != null) color = hoverColor;
            } else {
                if (hoverColor != null) color = FlxColor.WHITE;
            }
        }
        #end
        
        if (!good) {
            if (hoverColor != null) color = FlxColor.WHITE;
            justPressed = false;
            pressed = false;
            justReleased = false;
        }
        if (justPressed && onClick != null) {
            onClick();
        }
    }
}