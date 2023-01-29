package;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class ColorMask
{
	public var shader(default, null):ColorMaskShader = new ColorMaskShader();
	public var rCol(default, set):FlxColor = FlxColor.WHITE;
	public var gCol(default, set):FlxColor = FlxColor.WHITE;
	public var bCol(default, set):FlxColor = FlxColor.WHITE;

	private function set_rCol(value:FlxColor)
	{
		rCol = value;
		shader.rCol.value = [rCol.red, rCol.green, rCol.blue];
		return rCol;
	}

	private function set_gCol(value:FlxColor)
	{
		gCol = value;
		shader.gCol.value = [gCol.red, gCol.green, gCol.blue];
		return gCol;
	}

	private function set_bCol(value:FlxColor)
	{
		bCol = value;
		shader.bCol.value = [bCol.red, bCol.green, bCol.blue];
		return bCol;
	}

	public function new()
	{
		shader.rCol.value = [rCol.red, rCol.green, rCol.blue];
		shader.gCol.value = [gCol.red, gCol.green, gCol.blue];
		shader.bCol.value = [bCol.red, bCol.green, bCol.blue];
	}
}

class ColorMaskShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

	uniform vec3 rCol;
	uniform vec3 gCol;
	uniform vec3 bCol;

	vec3 rgb(vec3 col)
	{
		return col / vec3(255.0);
	}

	void main()
	{
		vec4 texture = flixel_texture2D(bitmap, openfl_TextureCoordv.xy) / openfl_Alphav;
		float alpha = texture.a * openfl_Alphav;

		vec3 rCol = rgb(rCol);
		vec3 gCol = rgb(gCol);
		vec3 bCol = rgb(bCol);

		vec3 red = mix(vec3(0.0), rCol, texture.r);
		vec3 green = mix(vec3(0.0), gCol, texture.g);
		vec3 blue = mix(vec3(0.0), bCol, texture.b);
		vec3 color = red + green + blue;

		gl_FragColor = vec4(color * openfl_Alphav, alpha);
	}
	')

	public function new()
	{
		super();
	}
}
