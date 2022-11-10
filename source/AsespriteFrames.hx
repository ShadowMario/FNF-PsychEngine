package;

import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames.TexturePackerObject;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTexturePackerSource;
import openfl.Assets;
import haxe.Json;
import haxe.xml.Access;
import sys.io.File;
import sys.FileSystem;

using StringTools;
// note that this also requires a modified flxframes and flxanimation to work

class AsespriteFrames extends FlxAtlasFrames
{
	/**
	 * Parsing method for TexturePacker atlases in JSON format.
	 *
	 * @param   Source        The image source (can be `FlxGraphic`, `String`, or `BitmapData`).
	 * @param   Description   Contents of JSON file with atlas description.
	 *                        You can get it with `Assets.getText(path/to/description.json)`.
	 *                        Or you can just a pass path to the JSON file in the assets directory.
	 *                        You can also directly pass in the parsed object.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromTexturePackerJson(Source:FlxGraphicAsset, Description:FlxTexturePackerSource):AsespriteFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:AsespriteFrames = cast FlxAtlasFrames.findFrame(graphic); // TODO: make an AsespriteFrames version
		if (frames != null)
			return frames;

		if (graphic == null || Description == null)
			return null;

		frames = new AsespriteFrames(graphic);

		var data:TexturePackerObject;

		if ((Description is String))
		{
			var json:String = Description;

			if (Assets.exists(json))
				json = Assets.getText(json);

			if(FileSystem.exists(json))
				json = File.getContent(json);

			json = json.trim();
			trace(json);

			data = Json.parse(json);
		}
		else
		{
			data = Description;
		}

		// JSON-Array
		if ((data.frames is Array))
		{
			for (frame in Lambda.array(data.frames))
				texturePackerHelper(frame.filename, frame, frames);
		}
		// JSON-Hash
		else
		{
			for (frameName in Reflect.fields(data.frames))
				texturePackerHelper(frameName, Reflect.field(data.frames, frameName), frames);
		}

		return frames;
	}

	/**
	 * Internal method for TexturePacker parsing. Parses the actual frame data.
	 *
	 * @param   FrameName   Name of the frame (file name of the original source image).
	 * @param   FrameData   The TexturePacker data excluding "filename".
	 * @param   Frames      The `FlxAtlasFrames` to add this frame to.
	 */
	static function texturePackerHelper(FrameName:String, FrameData:Dynamic, Frames:AsespriteFrames):Void
	{
		var rotated:Bool = FrameData.rotated;
		var name:String = FrameName;
		var sourceSize:FlxPoint = FlxPoint.get(FrameData.sourceSize.w, FrameData.sourceSize.h);
		var offset:FlxPoint = FlxPoint.get(FrameData.spriteSourceSize.x, FrameData.spriteSourceSize.y);
		var angle:FlxFrameAngle = FlxFrameAngle.ANGLE_0;
		var frameRect:FlxRect = null;
		if (rotated)
		{
			frameRect = FlxRect.get(FrameData.frame.x, FrameData.frame.y, FrameData.frame.h, FrameData.frame.w);
			angle = FlxFrameAngle.ANGLE_NEG_90;
		}
		else
		{
			frameRect = FlxRect.get(FrameData.frame.x, FrameData.frame.y, FrameData.frame.w, FrameData.frame.h);
		}

		if (FrameData.duration==null)
			Frames.addAtlasFrame(frameRect, sourceSize, offset, name, angle);
		else{
			Frames.addAseFrame(frameRect, sourceSize, offset, name, angle, FrameData.duration / 1000);
		}
	}

	public function addAseFrame(frame:FlxRect, sourceSize:FlxPoint, offset:FlxPoint, ?name:String, angle:FlxFrameAngle = 0, flipX:Bool = false,
			flipY:Bool = false, duration:Float = 0):FlxFrame
	{
		if (name != null && framesHash.exists(name))
			return framesHash.get(name);

		var texFrame:FlxFrame = new FlxFrame(parent, angle, flipX, flipY);
		texFrame.name = name;
		texFrame.sourceSize.set(sourceSize.x, sourceSize.y);
		texFrame.offset.set(offset.x, offset.y);
		texFrame.frame = checkFrame(frame, name);
		texFrame.delay = duration;

		sourceSize = FlxDestroyUtil.put(sourceSize);
		offset = FlxDestroyUtil.put(offset);

		return pushFrame(texFrame);
	}
}
