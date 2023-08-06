package psychlua;

@:publicFields
class CustomFlxColor
{
	static var instance:CustomFlxColor = new CustomFlxColor();
	function new() {}

	var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	var WHITE(default, null):Int = FlxColor.WHITE;
	var GRAY(default, null):Int = FlxColor.GRAY;
	var BLACK(default, null):Int = FlxColor.BLACK;

	var GREEN(default, null):Int = FlxColor.GREEN;
	var LIME(default, null):Int = FlxColor.LIME;
	var YELLOW(default, null):Int = FlxColor.YELLOW;
	var ORANGE(default, null):Int = FlxColor.ORANGE;
	var RED(default, null):Int = FlxColor.RED;
	var PURPLE(default, null):Int = FlxColor.PURPLE;
	var BLUE(default, null):Int = FlxColor.BLUE;
	var BROWN(default, null):Int = FlxColor.BROWN;
	var PINK(default, null):Int = FlxColor.PINK;
	var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	var CYAN(default, null):Int = FlxColor.CYAN;

	function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	function getRGB(color:Int):Array<Int>
	{
		var flxcolor:FlxColor = FlxColor.fromInt(color);
		return [flxcolor.red, flxcolor.green, flxcolor.blue, flxcolor.alpha];
	}
	function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}
	function getRGBFloat(color:Int):Array<Float>
	{
		var flxcolor:FlxColor = FlxColor.fromInt(color);
		return [flxcolor.redFloat, flxcolor.greenFloat, flxcolor.blueFloat, flxcolor.alphaFloat];
	}
	function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}
	function getCMYK(color:Int):Array<Float>
	{
		var flxcolor:FlxColor = FlxColor.fromInt(color);
		return [flxcolor.cyan, flxcolor.magenta, flxcolor.yellow, flxcolor.black, flxcolor.alphaFloat];
	}
	function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	function getHSB(color:Int):Array<Float>
	{
		var flxcolor:FlxColor = FlxColor.fromInt(color);
		return [flxcolor.hue, flxcolor.saturation, flxcolor.brightness, flxcolor.alphaFloat];
	}
	function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	function getHSL(color:Int):Array<Float>
	{
		var flxcolor:FlxColor = FlxColor.fromInt(color);
		return [flxcolor.hue, flxcolor.saturation, flxcolor.lightness, flxcolor.alphaFloat];
	}
	function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
	function getHSBColorWheel(Alpha:Int = 255):Array<Int>
	{
		return cast FlxColor.getHSBColorWheel(Alpha);
	}
	function interpolate(Color1:Int, Color2:Int, Factor:Float = 0.5):Int
	{
		return cast FlxColor.interpolate(Color1, Color2, Factor);
	}
	function gradient(Color1:Int, Color2:Int, Steps:Int, ?Ease:Float->Float):Array<Int>
	{
		return cast FlxColor.gradient(Color1, Color2, Steps, Ease);
	}
	function multiply(lhs:Int, rhs:Int):Int
	{
		return cast FlxColor.multiply(lhs, rhs);
	}
	function add(lhs:Int, rhs:Int):Int
	{
		return cast FlxColor.add(lhs, rhs);
	}
	function subtract(lhs:Int, rhs:Int):Int
	{
		return cast FlxColor.subtract(lhs, rhs);
	}
	function getComplementHarmony(color:Int):Int
	{
		return cast FlxColor.fromInt(color).getComplementHarmony();
	}
	function getAnalogousHarmony(color:Int, Threshold:Int = 30):CustomHarmony
	{
		return cast FlxColor.fromInt(color).getAnalogousHarmony(Threshold);
	}
	function getSplitComplementHarmony(color:Int, Threshold:Int = 30):CustomHarmony
	{
		return cast FlxColor.fromInt(color).getSplitComplementHarmony(Threshold);
	}
	function getTriadicHarmony(color:Int):CustomTriadicHarmony
	{
		return cast FlxColor.fromInt(color).getTriadicHarmony();
	}
	function to24Bit(color:Int):Int
	{
		return color & 0xffffff;
	}
	function toHexString(color:Int, Alpha:Bool = true, Prefix:Bool = true):String
	{
		return cast FlxColor.fromInt(color).toHexString(Alpha, Prefix);
	}
	function toWebString(color:Int):String
	{
		return cast FlxColor.fromInt(color).toWebString();
	}
	function getColorInfo(color:Int):String
	{
		return cast FlxColor.fromInt(color).getColorInfo();
	}
	function getDarkened(color:Int, Factor:Float = 0.2):Int
	{
		return cast FlxColor.fromInt(color).getDarkened(Factor);
	}
	function getLightened(color:Int, Factor:Float = 0.2):Int
	{
		return cast FlxColor.fromInt(color).getLightened(Factor);
	}
	function getInverted(color:Int):Int
	{
		return cast FlxColor.fromInt(color).getInverted();
	}
}
typedef CustomHarmony = {
	original:Int,
	warmer:Int,
	colder:Int
}
typedef CustomTriadicHarmony = {
	color1:Int,
	color2:Int,
	color3:Int
}