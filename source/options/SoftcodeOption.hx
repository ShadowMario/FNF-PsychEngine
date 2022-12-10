package options;

class SoftcodeOption extends Option
{
    private var emulatedValue:Dynamic = null;
    
    override function getValue():Dynamic {
        return emulatedValue;
    }

    override function setValue(value:Dynamic) {
        return emulatedValue = value;
    }
}