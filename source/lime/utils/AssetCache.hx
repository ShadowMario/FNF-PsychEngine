package lime.utils;

import haxe.macro.Compiler;
import lime.media.AudioBuffer;
import lime.graphics.Image;
#if !(macro || commonjs)
import lime._internal.macros.AssetsMacro;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class AssetCache
{
	public var audio:Map<String, AudioBuffer>;
	public var enabled:Bool = true;
	public var image:Map<String, Image>;
	public var font:Map<String, Dynamic /*Font*/>;
	public var version:Int;

	public function new()
	{
		audio = new Map<String, AudioBuffer>();
		font = new Map<String, Dynamic /*Font*/>();
		image = new Map<String, Image>();

		#if (macro || commonjs || lime_disable_assets_version)
		version = 0;
		#elseif lime_assets_version
		version = Std.parseInt(Compiler.getDefine("lime-assets-version"));
		#else
		version = AssetsMacro.cacheVersion();
		#end
	}

	public function exists(id:String, ?type:AssetType):Bool
	{
		if (type == AssetType.IMAGE || type == null)
		{
			if (image.exists(id)) return true;
		}

		if (type == AssetType.FONT || type == null)
		{
			if (font.exists(id)) return true;
		}

		if (type == AssetType.SOUND || type == AssetType.MUSIC || type == null)
		{
			if (audio.exists(id)) return true;
		}

		return false;
	}

	public function set(id:String, type:AssetType, asset:Dynamic):Void
	{
		switch (type)
		{
			case FONT:
				font.set(id, asset);

			case IMAGE:
				if (!(asset is Image)) throw "Cannot cache non-Image asset: " + asset + " as Image";

				image.set(id, asset);

			case SOUND, MUSIC:
				if (!(asset is AudioBuffer)) throw "Cannot cache non-AudioBuffer asset: " + asset + " as AudioBuffer";

				audio.set(id, asset);

			default:
				throw type + " assets are not cachable";
		}
	}

	public function clearExceptArray(array:Array<String>) {
		for (key=>a in audio)
		{
			if (!array.contains(key))
			{
                a.dispose();
				audio.remove(key);
			}
		}

		for (key=>f in font)
		{
			if (!array.contains(key))
			{
				font.remove(key);
			}
		}

		for (key=>i in image)
		{
			if (!array.contains(key))
			{
				image.remove(key);
			}
		}
        
        @:privateAccess
        for(lib in Assets.libraries) {
            lib.clearExceptArray(array);
        }
	}
	public function clear(prefix:String = null):Void
	{
		if (prefix == null)
		{
			audio = new Map<String, AudioBuffer>();
			font = new Map<String, Dynamic /*Font*/>();
			image = new Map<String, Image>();
		}
		else
		{
			var keys = audio.keys();

			for (key in keys)
			{
				if (StringTools.startsWith(key, prefix))
				{
					audio.remove(key);
				}
			}

			var keys = font.keys();

			for (key in keys)
			{
				if (StringTools.startsWith(key, prefix))
				{
					font.remove(key);
				}
			}

			var keys = image.keys();

			for (key in keys)
			{
				if (StringTools.startsWith(key, prefix))
				{
					image.remove(key);
				}
			}
		}
	}
}
