import flixel.addons.ui.FlxUINumericStepper;

class FlxUINumericStepperPlus extends FlxUINumericStepper {
    public var oldValue:Null<Float> = null;
    public var onChange:Float->Void;

    public override function set_value(v:Float):Float {
        oldValue = v;
        return super.set_value(v);
    }

    public override function update(elapsed) {
        super.update(elapsed);
        if (oldValue == null) oldValue = value;
        if (oldValue != value) {
            if (onChange != null) onChange(value);
            oldValue = value;
        }
    }
    public override function _onPlus() {
        @:privateAccess
        super._onPlus();
        if (onChange != null) onChange(value);
    }
    public override function _onMinus() {
        @:privateAccess
        super._onMinus();
        if (onChange != null) onChange(value);
    }
}