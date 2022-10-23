package flxanimate;

import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxShader;
import openfl.utils._internal.ShaderMacro;
class Filters
{
	public var shader(default, null):FilterShader;

    public var hue(get, set):Float;
	public var saturation(get, set):Float;
	public var lightness(get, set):Float;

	public function new():Void
	{
			shader = new FilterShader();
			shader.HSV.value = [];
			hue = 0;
			saturation = 0;
			lightness = 0;
	}

	function get_hue()
	{
		return shader.HSV.value[0];
	}
	function set_hue(hue:Float)
	{
		hue %= 360;
		shader.HSV.value[0] = hue;
		return hue;
	}
	function get_saturation()
	{
		return (shader.HSV.value[1] * 100) - 100;
	}
	function set_saturation(saturation:Float)
	{
		shader.HSV.value[1] = saturation / 100;
		return saturation;
	}
	function get_lightness()
	{
		return (shader.HSV.value[2] * 100) - 100;
	}
	function set_lightness(lightness:Float)
	{
		shader.HSV.value[2] = lightness / 100;
		return lightness;
	}
}

class FilterShader extends FlxShader
{
	@:glFragmentSource("
	#pragma header
	uniform vec3 HSV;

	vec3 rgb2hsl(vec3 c)
	{
		// variable shit
		float r = c.r / 255;
		float g = c.g / 255;
		float b = c.b / 255;
		float max = max(max(r,g),b);
		float min = min(min(r,g),b);
		float delta = max-min;

		// the formulas
		float L = ((max + min) / 2);
		float S = (delta == 0) ? 0 : (delta)/(1.0-abs(2 * L - 1));
		float H = 0;
		if (delta == 0) 
			H = 0;
		else
		{ 
			if (max == r) H = mod((g-b)/(delta), 6);
			if (max == g) H = 2.0 + (b-r)/(delta);
			if (max == b) H = 4.0 + (r-g)/(delta);
			H *= 60;
		}
		if (H < 0) H += 360;
		return vec3(H,S,L);
	}

	vec3 hsl2rgb(vec3 h)
	{
		// the classic hsl thing
		float H = mod(h.r, 360);
		float S = h.g;
		float L = h.b;
		
		// the variables required
		float C = (1 - abs(2 * L - 1)) * S;
		float X = C * (1 - abs(mod(H / 60, 2) - 1));
		float m = L - C / 2;
		vec3 rgb = vec3(0,0,0);

		// the formula
		if (H >= 0 && H < 60) rgb = vec3(C,X,0);
		if (H >= 60 && H < 120) rgb = vec3(X,C,0);
		if (H >= 120 && H < 180) rgb = vec3(0,C,X);
		if (H >= 180 && H < 240) rgb = vec3(0,X,C);
		if (H >= 240 && H < 300) rgb = vec3(X,0,C);
		if (H >= 300 && H < 360) rgb = vec3(C,0,X);
		rgb += m;
		rgb *= 255;
		return rgb;
	}

	void main(){
		vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		vec3 fragRGB = textureColor.rgb;
		vec3 fragHSV = rgb2hsl(fragRGB);
		fragHSV.x += HSV.x;

		fragRGB = hsl2rgb(fragHSV);
		gl_FragColor = vec4(fragRGB, textureColor.w);
	}
	")
	public function new()
	{
		super();
	}
}