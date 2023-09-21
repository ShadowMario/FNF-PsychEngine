package flixel.addons.display;

#if (FLX_DRAW_QUADS && !flash)
import flixel.graphics.tile.FlxGraphicsShader;
#if lime
import lime.utils.Float32Array;
#end
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;

using StringTools;

/**
 * An wrapper for Flixel/OpenFL's shaders, which takes fragment and vertex source
 * in the constructor instead of using macros so it can be provided at runtime.
 * 
 * @author MasterEric
 * @author Mihai Alexandru (M.A. Jigsaw)
 * 
 * @see https://github.com/openfl/openfl/blob/develop/src/openfl/utils/_internal/ShaderMacro.hx
 * @see https://dixonary.co.uk/blog/shadertoy
 */
class FlxRuntimeShader extends FlxGraphicsShader
{
	private static final BASE_VERTEX_HEADER:String = "attribute float openfl_Alpha;
		attribute vec4 openfl_ColorMultiplier;
		attribute vec4 openfl_ColorOffset;
		attribute vec4 openfl_Position;
		attribute vec2 openfl_TextureCoord;

		varying float openfl_Alphav;
		varying vec4 openfl_ColorMultiplierv;
		varying vec4 openfl_ColorOffsetv;
		varying vec2 openfl_TextureCoordv;

		uniform mat4 openfl_Matrix;
		uniform bool openfl_HasColorTransform;
		uniform vec2 openfl_TextureSize;";

	private static final BASE_VERTEX_BODY:String = "openfl_Alphav = openfl_Alpha;
		openfl_TextureCoordv = openfl_TextureCoord;

		if (openfl_HasColorTransform)
		{
			openfl_ColorMultiplierv = openfl_ColorMultiplier;
			openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
		}

		gl_Position = openfl_Matrix * openfl_Position;";

	private static final BASE_VERTEX_SOURCE:String = "#pragma header

		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;

		void main(void)
		{
			#pragma body

			openfl_Alphav = openfl_Alpha * alpha;

			if (hasColorTransform)
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}";

	private static final BASE_FRAGMENT_HEADER:String = "varying float openfl_Alphav;
		varying vec4 openfl_ColorMultiplierv;
		varying vec4 openfl_ColorOffsetv;
		varying vec2 openfl_TextureCoordv;

		uniform bool openfl_HasColorTransform;
		uniform vec2 openfl_TextureSize;
		uniform sampler2D bitmap;

		uniform bool hasTransform;
		uniform bool hasColorTransform;

		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);

			if (!hasTransform)
			{
				return color;
			}

			if (color.a == 0.0)
			{
				return vec4(0.0, 0.0, 0.0, 0.0);
			}

			if (!hasColorTransform)
			{
				return color * openfl_Alphav;
			}

			color = vec4(color.rgb / color.a, color.a);

			mat4 colorMultiplier = mat4(0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

			color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

			if (color.a > 0.0)
			{
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}

			return vec4(0.0, 0.0, 0.0, 0.0);
		}";

	private static final BASE_FRAGMENT_BODY:String = "vec4 color = texture2D(bitmap, openfl_TextureCoordv);

		if (color.a == 0.0)
		{
			gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
		}
		else if (openfl_HasColorTransform)
		{
			color = vec4 (color.rgb / color.a, color.a);

			mat4 colorMultiplier = mat4 (0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = 1.0; // openfl_ColorMultiplierv.w;

			color = clamp (openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

			if (color.a > 0.0)
			{
				gl_FragColor = vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			else
			{
				gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
			}
		}
		else
		{
			gl_FragColor = color * openfl_Alphav;
		}";

	private static final BASE_FRAGMENT_SOURCE:String = "#pragma header

		void main(void)
		{
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		}";

	/**
	 * Creates a `FlxRuntimeShader` with specified shader sources.
	 * If none is provided, it will use the default shader sources.
	 *
	 * @param fragmentSource The fragment shader source.
	 * @param vertexSource The vertex shader source.
	 */
	public function new(?fragmentSource:String, ?vertexSource:String):Void
	{
		if (fragmentSource != null && fragmentSource.length > 0)
			glFragmentSource = fragmentSource;
		else
			glFragmentSource = BASE_FRAGMENT_SOURCE;

		if (vertexSource != null && vertexSource.length > 0)
			glVertexSource = vertexSource;
		else
			glVertexSource = BASE_VERTEX_SOURCE;

		super();
	}

	/**
	 * Modify a float parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setFloat(name:String, value:Float):Void
	{
		var prop:ShaderParameter<Float> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader float property "$name" not found.');
			return;
		}

		prop.value = [value];
	}

	/**
	 * Retrieve a float parameter of the shader.
	 *
	 * @param name The name of the parameter to retrieve.
	 */
	public function getFloat(name:String):Null<Float>
	{
		var prop:ShaderParameter<Float> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader float property "$name" not found.');
			return null;
		}

		return prop.value[0];
	}

	/**
	 * Modify a float array parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setFloatArray(name:String, value:Array<Float>):Void
	{
		var prop:ShaderParameter<Float> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader float[] property "$name" not found.');
			return;
		}

		prop.value = value;
	}

	/**
	 * Retrieve a float array parameter of the shader.
	 *
	 * @param name The name of the parameter to retrieve.
	 */
	public function getFloatArray(name:String):Null<Array<Float>>
	{
		var prop:ShaderParameter<Float> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader float[] property "$name" not found.');
			return null;
		}

		return prop.value;
	}

	/**
	 * Modify an integer parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setInt(name:String, value:Int):Void
	{
		var prop:ShaderParameter<Int> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader int property "$name" not found.');
			return;
		}

		prop.value = [value];
	}

	/**
	 * Retrieve an integer parameter of the shader.
	 *
	 * @param name The name of the parameter to retrieve.
	 */
	public function getInt(name:String):Null<Int>
	{
		var prop:ShaderParameter<Int> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader int property "$name" not found.');
			return null;
		}

		return prop.value[0];
	}

	/**
	 * Modify an integer array parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setIntArray(name:String, value:Array<Int>):Void
	{
		var prop:ShaderParameter<Int> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader int[] property "$name" not found.');
			return;
		}

		prop.value = value;
	}

	/**
	 * Retrieve an integer array parameter of the shader.
	 *
	 * @param name The name of the parameter to retrieve.
	 */
	public function getIntArray(name:String):Null<Array<Int>>
	{
		var prop:ShaderParameter<Int> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader int[] property "$name" not found.');
			return null;
		}

		return prop.value;
	}

	/**
	 * Modify a bool parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setBool(name:String, value:Bool):Void
	{
		var prop:ShaderParameter<Bool> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader bool property "$name" not found.');
			return;
		}

		prop.value = [value];
	}

	/**
	 * Retrieve a bool parameter of the shader.
	 *
	 * @param name The name of the parameter to retrieve.
	 */
	public function getBool(name:String):Null<Bool>
	{
		var prop:ShaderParameter<Bool> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader bool property "$name" not found.');
			return null;
		}

		return prop.value[0];
	}

	/**
	 * Modify a bool array parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setBoolArray(name:String, value:Array<Bool>):Void
	{
		var prop:ShaderParameter<Bool> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader bool[] property "$name" not found.');
			return;
		}

		prop.value = value;
	}

	/**
	 * Retrieve a bool array parameter of the shader.
	 *
	 * @param name The name of the parameter to retrieve.
	 */
	public function getBoolArray(name:String):Null<Array<Bool>>
	{
		var prop:ShaderParameter<Bool> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader bool[] property "$name" not found.');
			return null;
		}

		return prop.value;
	}

	/**
	 * Modify a bitmap data parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setSampler2D(name:String, value:BitmapData):Void
	{
		var prop:ShaderInput<BitmapData> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader sampler2D property "$name" not found.');
			return;
		}

		prop.input = value;
	}

	/**
	 * Retrieve a bitmap data parameter of the shader.
	 *
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getSampler2D(name:String):Null<BitmapData>
	{
		var prop:ShaderInput<BitmapData> = Reflect.field(data, name);

		if (prop == null)
		{
			FlxG.log.warn('Shader sampler2D property "$name" not found.');
			return null;
		}

		return prop.input;
	}

	// Overrides
	@:noCompletion private override function __processGLData(source:String, storageType:String):Void
	{
		var lastMatch = 0, position, regex, name, type;

		if (storageType == "uniform")
		{
			regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
		}
		else
		{
			regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
		}

		@:privateAccess
		while (regex.matchSub(source, lastMatch))
		{
			type = regex.matched(1);
			name = regex.matched(2);

			if (StringTools.startsWith(name, "gl_"))
				continue;

			var isUniform = (storageType == "uniform");

			if (StringTools.startsWith(type, "sampler"))
			{
				var input = new ShaderInput<BitmapData>();
				input.name = name;
				input.__isUniform = isUniform;
				__inputBitmapData.push(input);

				switch (name)
				{
					case "openfl_Texture":
						__texture = input;
					case "bitmap":
						__bitmap = input;
					default:
				}

				Reflect.setField(__data, name, input);

				try
				{
					if (__isGenerated)
						Reflect.setField(this, name, input);
				}
				catch (e:Dynamic) {}
			}
			else if (!Reflect.hasField(__data, name) || Reflect.field(__data, name) == null)
			{
				var parameterType:ShaderParameterType = switch (type)
				{
					case "bool": BOOL;
					case "double", "float": FLOAT;
					case "int", "uint": INT;
					case "bvec2": BOOL2;
					case "bvec3": BOOL3;
					case "bvec4": BOOL4;
					case "ivec2", "uvec2": INT2;
					case "ivec3", "uvec3": INT3;
					case "ivec4", "uvec4": INT4;
					case "vec2", "dvec2": FLOAT2;
					case "vec3", "dvec3": FLOAT3;
					case "vec4", "dvec4": FLOAT4;
					case "mat2", "mat2x2": MATRIX2X2;
					case "mat2x3": MATRIX2X3;
					case "mat2x4": MATRIX2X4;
					case "mat3x2": MATRIX3X2;
					case "mat3", "mat3x3": MATRIX3X3;
					case "mat3x4": MATRIX3X4;
					case "mat4x2": MATRIX4X2;
					case "mat4x3": MATRIX4X3;
					case "mat4", "mat4x4": MATRIX4X4;
					default: null;
				}

				var length = switch (parameterType)
				{
					case BOOL2, INT2, FLOAT2: 2;
					case BOOL3, INT3, FLOAT3: 3;
					case BOOL4, INT4, FLOAT4, MATRIX2X2: 4;
					case MATRIX3X3: 9;
					case MATRIX4X4: 16;
					default: 1;
				}

				var arrayLength = switch (parameterType)
				{
					case MATRIX2X2: 2;
					case MATRIX3X3: 3;
					case MATRIX4X4: 4;
					default: 1;
				}

				switch (parameterType)
				{
					case BOOL, BOOL2, BOOL3, BOOL4:
						var parameter = new ShaderParameter<Bool>();
						parameter.name = name;
						parameter.type = parameterType;
						parameter.__arrayLength = arrayLength;
						parameter.__isBool = true;
						parameter.__isUniform = isUniform;
						parameter.__length = length;
						__paramBool.push(parameter);

						if (name == "openfl_HasColorTransform")
						{
							__hasColorTransform = parameter;
						}

						Reflect.setField(__data, name, parameter);

						try
						{
							if (__isGenerated)
								Reflect.setField(this, name, parameter);
						}
						catch (e:Dynamic) {}

					case INT, INT2, INT3, INT4:
						var parameter = new ShaderParameter<Int>();
						parameter.name = name;
						parameter.type = parameterType;
						parameter.__arrayLength = arrayLength;
						parameter.__isInt = true;
						parameter.__isUniform = isUniform;
						parameter.__length = length;
						__paramInt.push(parameter);

						Reflect.setField(__data, name, parameter);

						try
						{
							if (__isGenerated)
								Reflect.setField(this, name, parameter);
						}
						catch (e:Dynamic) {}

					default:
						var parameter = new ShaderParameter<Float>();
						parameter.name = name;
						parameter.type = parameterType;
						parameter.__arrayLength = arrayLength;
						#if lime
						if (arrayLength > 0)
							parameter.__uniformMatrix = new Float32Array(arrayLength * arrayLength);
						#end
						parameter.__isFloat = true;
						parameter.__isUniform = isUniform;
						parameter.__length = length;
						__paramFloat.push(parameter);

						if (StringTools.startsWith(name, "openfl_"))
						{
							switch (name)
							{
								case "openfl_Alpha": __alpha = parameter;
								case "openfl_ColorMultiplier": __colorMultiplier = parameter;
								case "openfl_ColorOffset": __colorOffset = parameter;
								case "openfl_Matrix": __matrix = parameter;
								case "openfl_Position": __position = parameter;
								case "openfl_TextureCoord": __textureCoord = parameter;
								case "openfl_TextureSize": __textureSize = parameter;
								default:
							}
						}

						Reflect.setField(__data, name, parameter);

						try
						{
							if (__isGenerated)
								Reflect.setField(this, name, parameter);
						}
						catch (e:Dynamic) {}
				}
			}

			position = regex.matchedPos();
			lastMatch = position.pos + position.len;
		}
	}

	@:noCompletion private override function set_glFragmentSource(value:String):String
	{
		if (value != null)
			value = value.replace("#pragma header", BASE_FRAGMENT_HEADER).replace("#pragma body", BASE_FRAGMENT_BODY);

		if (value != __glFragmentSource)
			__glSourceDirty = true;

		return __glFragmentSource = value;
	}

	@:noCompletion private override function set_glVertexSource(value:String):String
	{
		if (value != null)
			value = value.replace("#pragma header", BASE_VERTEX_HEADER).replace("#pragma body", BASE_VERTEX_BODY);

		if (value != __glVertexSource)
			__glSourceDirty = true;

		return __glVertexSource = value;
	}
}
#end
