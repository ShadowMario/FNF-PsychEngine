import openfl.display3D.Program3D;
import flixel.system.FlxAssets.FlxShader;

using StringTools;

// goddamn prefix

@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.Program3D)
@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)
class FlxFixedShader extends FlxShader {
    public var custom:Bool = false;
    public override function new() {
        super();
    }
    @:noCompletion private override function __initGL():Void
    {
        if (__glSourceDirty || __paramBool == null)
        {
            __glSourceDirty = false;
            program = null;

            __inputBitmapData = new Array();
            __paramBool = new Array();
            __paramFloat = new Array();
            __paramInt = new Array();

            __processGLData(glVertexSource, "attribute");
            __processGLData(glVertexSource, "uniform");
            __processGLData(glFragmentSource, "uniform");
        }

        if (__context != null && program == null)
        {
            var prefix = "#version 120\n";

            var gl = __context.gl;

			prefix += "#ifdef GL_ES
				"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH
				precision highp float;
				#else
				precision mediump float;
				#endif" : "precision lowp float;")
				+ "
				#endif
				";

			var vertex = prefix + glVertexSource;
			var fragment = prefix + glFragmentSource;

			var id = vertex + fragment;

			if (__context.__programs.exists(id))
			{
				program = __context.__programs.get(id);
			}
			else
			{
				program = __context.createProgram(GLSL);

				// TODO
				// program.uploadSources (vertex, fragment);
				program.__glProgram = __createGLProgram(vertex, fragment);

				__context.__programs.set(id, program);
			}

			if (program != null)
			{
				glProgram = program.__glProgram;

				for (input in __inputBitmapData)
				{
					if (input.__isUniform)
					{
						input.index = gl.getUniformLocation(glProgram, input.name);
					}
					else
					{
						input.index = gl.getAttribLocation(glProgram, input.name);
					}
				}

				for (parameter in __paramBool)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramFloat)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramInt)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}
			}
        }
    }
}