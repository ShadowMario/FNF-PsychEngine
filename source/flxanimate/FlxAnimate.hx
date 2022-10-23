package flxanimate;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flxanimate.animate.*;
import flxanimate.zip.Zip;
import openfl.Assets;
import haxe.io.BytesInput;
import flixel.system.FlxSound;
import flixel.FlxG;
import flxanimate.data.AnimationData;
import flixel.FlxSprite;
import flxanimate.animate.FlxAnim;
import flxanimate.frames.FlxAnimateFrames;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.math.FlxMath;
import flixel.FlxBasic;

typedef Settings = {
	?ButtonSettings:Map<String, flxanimate.animate.FlxAnim.ButtonSettings>,
	?FrameRate:Float,
	?Reversed:Bool,
	?OnComplete:Void->Void,
	?ShowPivot:Bool,
	?Antialiasing:Bool,
	?ScrollFactor:FlxPoint,
	?Offset:FlxPoint,
}

class FlxAnimate extends FlxSprite
{
	public var anim(default, null):FlxAnim;

	#if FLX_SOUND_SYSTEM
	public var audio:FlxSound;
	#end
	
	public var rectangle:FlxRect;
	
	public var showPivot:Bool = false;

	/**
	 * # Description
	 * `FlxAnimate` is a texture atlas parser from the drawing software *Adobe Animate* (once being *Adobe Flash*).
	 * It tries to replicate how Adobe Animate works on Haxe so it would be considered (as *MrCheemsAndFriends* likes to call it,) a "*Flash--*", in other words, a replica of Animate's work
	 * on the side of drawing, making symbols, etc.
	 * ## WARNINGS
	 * - This is the only way to use the sprites using the `FlxAnimateFrames` function, `fromTextureAtlas`.
	 * - This does not convert to spritesheet, if you want to use spritesheets (not recommended), use Smokey555's repo, [Flixel-TextureAtlas](https://github.com/Smokey555/Flixel-TextureAtlas)
	 * - This can be really fragile on some repos, mainly because even though the repo was made by two ppl collabing, [Dot-With] doesn't seem to be involucrated on `FlxAnimate` no more.
	 *	 Making really difficult to give really big updates (such as Filters, or Masks) like some *dumass user who doesn't know shit about coding or anything at all.
	 *
	 * @param X 		The initial X position of the sprite.
	 * @param Y 		The initial Y position of the sprite.
	 * @param Path      The path to the texture atlas, **NOT** the path of the any of the files inside the texture atlas (`Animation.json`, `spritemap.json`, etc).
	 * @param Settings  Optional settings for the animation (antialiasing, framerate, reversed, etc.).
	 * @return a new `FlxAnimate` instance from a texture atlas of Adobe Animate
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Path:String, ?Settings:Settings)
	{
		super(X, Y);
		anim = new FlxAnim(this);
		if (Path != null)
			loadAtlas(Path);
		if (Settings != null)
			setTheSettings(Settings);
	}

	public function loadAtlas(Path:String)
	{
		if (!Assets.exists('$Path/Animation.json') && haxe.io.Path.extension(Path) != "zip")
		{
			FlxG.log.error('Animation file not found in specified path: "$path", have you written the correct path?');
			return;
		}
		anim._loadAtlas(atlasSetting(Path));
		frames = FlxAnimateFrames.fromTextureAtlas(Path);
	}
	public override function draw():Void
	{
		@:privateAccess
		parseSymbol(anim.curSymbol, _matrix, anim.curFrame, anim.symbolType, colorTransform, true);
	}
	function parseSymbol(symbol:FlxSymbol, m:FlxMatrix, FF:Int, symbolType:SymbolType, colorFilter:ColorTransform, mainSymbol:Bool)
	{
		switch (symbolType)
		{
			case button, "button": setButtonFrames(symbol);
			case movieclip, "movieclip":
			{
				(anim.swfRender) ? symbol.update(anim.framerate, anim.reversed, loop) : if (symbol.curFrame != 0) symbol.curFrame = 0;
			}
			default:
		}
		var lbl:Null<String> = null;
		for (i in 0...symbol.timeline.L.length)
		{
			var layer = symbol.timeline.L[symbol.timeline.L.length - 1 - i];
			if (!symbol._layers.contains(layer.LN) && mainSymbol) continue;
			var selectedFrame = symbol.prepareFrame(layer, ([SymbolType.graphic, "graphic"].indexOf(symbolType) != -1) ? FF : symbol.curFrame);
			if (selectedFrame == null) continue;

			if (selectedFrame.N != null)
			{
				symbol.labels.get(selectedFrame.N).fireCallbacks();
			}
			
			for (element in selectedFrame.E)
			{
				var isSymbol = element.SI != null;
				var m3d = (isSymbol) ? element.SI.M3D : element.ASI.M3D;
				var pos = (isSymbol) ? element.SI.bitmap.POS : element.ASI.POS;
				var matrix = FlxSymbol.prepareMatrix(m3d, pos);
				matrix.concat(m);
				var colorF = new ColorTransform();
				colorF.concat(colorEffect(selectedFrame.C));
				colorF.concat(colorFilter);
				colorF.concat(colorEffect(element.SI.C));
				if (element.SI.bitmap == null && isSymbol)
				{
					var symbol = anim.symbolDictionary.get(element.SI.SN);
					parseSymbol(symbol, matrix, symbol.frameControl(element.SI.FF,element.SI.LP), element.SI.ST, colorF, false);
					continue;
				}
				var limb = frames.getByName((isSymbol) ? element.SI.bitmap.N : element.ASI.N);
				drawLimb(limb, matrix, colorF);
			}
		}
	}
	static function colorEffect(sInstance:ColorEffects)
	{
		var CT = new ColorTransform();
		if (sInstance == null) return CT;
		switch (sInstance.M)
		{
			case Tint, "Tint":
			{
				var color = flixel.util.FlxColor.fromString(sInstance.TC);
				var opacity = sInstance.TM;
				CT.redMultiplier -= opacity;
				CT.redOffset = Math.round(color.red * opacity);
				CT.greenMultiplier -= opacity;
				CT.greenOffset = Math.round(color.green * opacity);
				CT.blueMultiplier -= opacity;
				CT.blueOffset = Math.round(color.blue * opacity);
			}
			case Alpha, "Alpha":
			{
				CT.alphaMultiplier = sInstance.AM;
			}
			case Brightness, "Brightness":
			{
				CT.redMultiplier = CT.greenMultiplier = CT.blueMultiplier -= Math.abs(sInstance.BRT);
				if (sInstance.BRT >= 0)
					CT.redOffset = CT.greenOffset = CT.blueOffset = 255 * sInstance.BRT;
			}
			case Advanced, "Advanced":
			{
				CT.redMultiplier = sInstance.RM;
				CT.redOffset = sInstance.RO;
				CT.greenMultiplier = sInstance.GM;
				CT.greenOffset = sInstance.GO;
				CT.blueMultiplier = sInstance.BM;
				CT.blueOffset = sInstance.BO;
				CT.alphaMultiplier = sInstance.AM;
				CT.alphaOffset = sInstance.AO;
			}
		}
		return CT;
	}

	var pressed:Bool = false;
	function setButtonFrames(symbol:FlxSymbol)
	{
		var badPress:Bool = false;
		var goodPress:Bool = false;
		#if !mobile
		if (FlxG.mouse.pressed && FlxG.mouse.overlaps(this))
			goodPress = true;
		if (FlxG.mouse.pressed && !FlxG.mouse.overlaps(this) && !goodPress)
		{
			badPress = true;
		}
		if (!FlxG.mouse.pressed)
		{
			badPress = false;
			goodPress = false;
		}
		if (FlxG.mouse.overlaps(this) && !badPress)
		{
			@:privateAccess
			var event = anim.buttonMap.get(anim.curSymbol.name);
			if (FlxG.mouse.justPressed && !pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnClick : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = true;
			}
			if (FlxG.mouse.pressed)
			{
				symbol.frameControl(2, singleframe);
			}
			else
			{
				symbol.frameControl(1, singleframe);
			}
			if (FlxG.mouse.justReleased && pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnRelease : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = false;
			}
		}
		else
		{
			symbol.frameControl(0, singleframe);
		}
		#else
		FlxG.log.error("Button stuff isn't available for mobile!");
		#end
	}
	function drawLimb(limb:FlxFrame, _matrix:FlxMatrix, colorTransform:ColorTransform)
	{
		if (alpha == 0 || colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255 || limb == null || limb.type == EMPTY)
			return;
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !limbOnScreen(limb, _matrix, camera))
				return;
			getScreenPosition(_point, camera).subtractPoint(offset);

			_matrix.scale(scale.x, scale.y);
			
			if (isPixelPerfectRender(camera))
		    {
			    _point.floor();
		    }
			
			_matrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, _matrix, colorTransform, blend, antialiasing/*, AnimationData.filters.shader*/);
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
	function limbOnScreen(limb:FlxFrame, m:FlxMatrix, ?Camera:FlxCamera)
	{
		if (Camera == null)
			Camera = FlxG.camera;

		var minX:Float = x + m.tx - offset.x - scrollFactor.x * Camera.scroll.x;
		var minY:Float = y + m.ty - offset.y - scrollFactor.y * Camera.scroll.y;
		
		var radiusX:Float =  limb.frame.width * Math.max(1, m.a);
		var radiusY:Float = limb.frame.height * Math.max(1, m.d);
		var radius:Float = Math.max(radiusX, radiusY);
		radius *= FlxMath.SQUARE_ROOT_OF_TWO;
		minY -= radius;
		minX -= radius;
		radius *= 2;

		_point.set(minX, minY);

		return Camera.containsPoint(_point, radius, radius);
	}

	function checkSize(limb:FlxFrame, m:FlxMatrix)
	{
		return (limb != null) ? {width: limb.sourceSize.x * (Math.abs(m.a) + Math.abs(m.c)), height: limb.sourceSize.y * (Math.abs(m.d) + Math.abs(m.b))} : {width: 0, height: 0};
	}
	var oldMatrix:FlxMatrix;
	override function set_flipX(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.a = -oldMatrix.a;
			_matrix.c = -oldMatrix.c;
		}
		else
		{
			_matrix.a = oldMatrix.a;
			_matrix.c = oldMatrix.c;
		}
		return Value;
	}
	override function set_flipY(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.b = -oldMatrix.b;
			_matrix.d = -oldMatrix.d;
		}
		else
		{
			_matrix.b = oldMatrix.b;
			_matrix.d = oldMatrix.d;
		}
		return Value;
	}

	override function destroy()      
	{                                                                
		if (anim != null)
			anim.destroy();
		anim = null;
		#if FLX_SOUND_SYSTEM
		if (audio != null)
			audio.destroy();
		#end
		super.destroy();
	}

	public override function updateAnimation(elapsed:Float) 
	{
		anim.update(elapsed);
	}

	public function setButtonPack(button:String, callbacks:ClickStuff #if FLX_SOUND_SYSTEM , sound:FlxSound #end):Void
	{
		@:privateAccess
		anim.buttonMap.set(button, {Callbacks: callbacks, #if FLX_SOUND_SYSTEM Sound:  sound #end});
	}

	function setTheSettings(?Settings:Settings):Void
	{
		@:privateAccess
		if (true)
		{
			antialiasing = Settings.Antialiasing;
			if (Settings.ButtonSettings != null)
			{
				anim.buttonMap = Settings.ButtonSettings;
				if ([button, "button"].indexOf(anim.symbolType) == -1)
					anim.symbolType = button;
			}
			if (Settings.Reversed != null)
				anim.reversed = Settings.Reversed;
			if (Settings.FrameRate != null)
				anim.framerate = (Settings.FrameRate > 0 ? anim.coolParse.MD.FRT : Settings.FrameRate);
			if (Settings.OnComplete != null)
				anim.onComplete = Settings.OnComplete;
			if (Settings.ShowPivot != null)
				showPivot = Settings.ShowPivot;
			if (Settings.Antialiasing != null)
				antialiasing = Settings.Antialiasing;
			if (Settings.ScrollFactor != null)
				scrollFactor = Settings.ScrollFactor;
			if (Settings.Offset != null)
				offset = Settings.Offset;
		}
	}

	function atlasSetting(Path:String):AnimAtlas
	{
		var jsontxt:AnimAtlas = null;
		if (haxe.io.Path.extension(Path) == "zip")
		{
			var thing = Zip.readZip(Assets.getBytes(Path));
			
			for (list in Zip.unzip(thing))
			{
				if (list.fileName.indexOf("Animation.json") != -1)
				{
					jsontxt = haxe.Json.parse(list.data.toString());
					thing.remove(list);
					continue;
				}
			}
			@:privateAccess
			FlxAnimateFrames.zip = thing;
		}
		else
		{
			jsontxt = haxe.Json.parse(openfl.Assets.getText('$Path/Animation.json'));
		}

		return jsontxt;
	}
}
