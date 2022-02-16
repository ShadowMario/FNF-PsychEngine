package;

import openfl.display.GraphicsShader;
import flixel.FlxG;
import flixel.graphics.tile.FlxGraphicsShader;
import sys.FileSystem;

/*
	Class to handle animated shaders, calling the new consturctor is enough, 
	the update function will be automatically called by the playstate.

	Access the shader the handler with `PlayState.animatedShaders["fileName"]`

	Shaders should be placed at /shaders folder, with ".frag" extension, 
	See shaders folder for examples and guides.

	Optimize variable might help with some heavy shaders but only makes a difference on decent Intel CPUs.

	@author Kemo

	Please respect the effort but to this and credit us if used :]
	
	
	
	Hiiiii bbpanzu i edited the shits to work with psych engineee < 33333
 */
 
class DynamicShaderHandler
{
	public var shader:FlxGraphicsShader;

	private var bHasResolution:Bool = false;
	private var bHasTime:Bool = false;

	public function new(fileName:String, optimize:Bool = false)
	{
		var path = Paths.modsShaderFragment(fileName);
		trace(path);
		if (!FileSystem.exists(path)) path = Paths.shaderFragment(fileName);
		
		trace(path);
		var fragSource:String = "";

		if (FileSystem.exists(path))
		{
			fragSource = sys.io.File.getContent(path);
		}

		
		var path2 = Paths.modsShaderVertex(fileName);
		trace(path2);
		if (!FileSystem.exists(path2)) path2 = Paths.shaderVertex(fileName);
		
		trace(path2);
		var vertSource:String = "";

		if (FileSystem.exists(path2))
		{
			vertSource = sys.io.File.getContent(path2);
		}

		if (fragSource != "" || vertSource != "")
		{
			shader = new FlxGraphicsShader(fragSource, optimize, vertSource);
		}

		if (shader == null)
		{
			return;
		}

		if (fragSource.indexOf("iResolution") != -1)
		{
			bHasResolution = true;
			shader.data.iResolution.value = [FlxG.width, FlxG.height];
		}

		if (fragSource.indexOf("iTime") != -1)
		{
			bHasTime = true;
			shader.data.iTime.value = [0];
		}

		#if LUA_ALLOWED 
		PlayState.instance.luaShaders[fileName] = this;
		#end
		PlayState.animatedShaders[fileName] = this;
	
			//trace(shader.data.get('rOffset'));
		
	}

	public function modifyShaderProperty(property:String, value:Dynamic)
	{
		if (shader == null)
		{
			return;
		}
		
		if (shader.data.get(property) != null)
		{
			shader.data.get(property).value = value;
		}
	}

	private function getTime()
	{
		return shader.data.iTime.value[0];
	}

	private function setTime(value)
	{
		shader.data.iTime.value = [value];
	}

	public function update(elapsed:Float)
	{
		if (bHasTime)
		{
			setTime(getTime() + elapsed);
		}
	}
}
