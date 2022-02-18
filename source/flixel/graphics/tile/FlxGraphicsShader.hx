package flixel.graphics.tile;

import openfl.display.ShaderParameter;
import sys.io.File;
#if FLX_DRAW_QUADS
import openfl.display.GraphicsShader;

// Edited by gedehari and kemo
class FlxGraphicsShader extends GraphicsShader
{
	public var alpha:ShaderParameter<Float>;
	public var colorMultiplier:ShaderParameter<Float>;
	public var colorOffset:ShaderParameter<Float>;
	public var hasTransform:ShaderParameter<Bool>;
	public var hasColorTransform:ShaderParameter<Bool>;

	/* 
		To avoid conflicts this constructor adds the flixel vars and uniforms to the sources, 
		Add them yourself if you are going to use the super class directly.
	 */
	public function new(?fragSource:String = "", optimize:Bool = false,vertxSource:String = "")
	{
		super( // Vertex
			"#pragma header
			", // Fragment

			"#pragma header
			", false);

		glFragmentHeader += "uniform bool hasTransform;
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

		if (fragSource != null && fragSource != "")
		{
			glFragmentHeader += fragSource;
		}
		else
		{
			glFragmentHeader += "			
			void main(void)
			{
				gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			}";
		}

		if (vertxSource != null && vertxSource != "")
		{
			glVertexHeader += vertxSource;
		}
		else
		{
			glVertexHeader += "
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
		}

		if (optimize)
		{
			precisionHint = FAST;
		}

		__initGL();

		bitmap = data.bitmap;
		alpha = data.alpha;
		colorMultiplier = data.colorMultiplier;
		colorOffset = data.colorOffset;
		hasTransform = data.hasTransform;
		hasColorTransform = data.hasColorTransform;
	}
}
#end
