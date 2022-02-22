package flixel.addons.display;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawTilesItem;
import flixel.math.FlxPoint;
import flixel.math.FlxPoint.FlxCallbackPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

using flixel.util.FlxColorTransformUtil;

/**
 * Used for showing infinitely scrolling backgrounds.
 * @author Chevy Ray
 */
class FlxBackdrop extends FlxSprite
{
	var _ppoint:Point;
	var _scrollW:Int = 0;
	var _scrollH:Int = 0;
	var _repeatX:Bool = false;
	var _repeatY:Bool = false;

	var _spaceX:Int = 0;
	var _spaceY:Int = 0;

	/**
	 * Frame used for tiling
	 */
	var _tileFrame:FlxFrame;

	var _tileInfo:Array<Float>;
	var _numTiles:Int = 0;

	// TODO: remove this hack and add docs about how to avoid tearing problem by preparing assets and some code...

	/**
	 * Try to eliminate 1 px gap between tiles in tile render mode by increasing tile scale,
	 * so the tile will look one pixel wider than it is.
	 */
	public var useScaleHack:Bool = true;

	/**
	 * Creates an instance of the FlxBackdrop class, used to create infinitely scrolling backgrounds.
	 *
	 * @param   Graphic		The image you want to use for the backdrop.
	 * @param   ScrollX 	Scrollrate on the X axis.
	 * @param   ScrollY 	Scrollrate on the Y axis.
	 * @param   RepeatX 	If the backdrop should repeat on the X axis.
	 * @param   RepeatY 	If the backdrop should repeat on the Y axis.
	 * @param	SpaceX		Amount of spacing between tiles on the X axis
	 * @param	SpaceY		Amount of spacing between tiles on the Y axis
	 */
	public function new(?Graphic:FlxGraphicAsset, ScrollX:Float = 1, ScrollY:Float = 1, RepeatX:Bool = true, RepeatY:Bool = true, SpaceX:Int = 0,
			SpaceY:Int = 0)
	{
		super();

		scale = new FlxCallbackPoint(scaleCallback);
		scale.set(1, 1);

		_repeatX = RepeatX;
		_repeatY = RepeatY;

		_spaceX = SpaceX;
		_spaceY = SpaceY;

		_ppoint = new Point();

		scrollFactor.x = ScrollX;
		scrollFactor.y = ScrollY;

		if (Graphic != null)
			loadGraphic(Graphic);

		FlxG.signals.gameResized.add(onGameResize);
	}

	override public function destroy():Void
	{
		_tileInfo = null;
		_ppoint = null;
		scale = FlxDestroyUtil.destroy(scale);
		setTileFrame(null);

		FlxG.signals.gameResized.remove(onGameResize);

		super.destroy();
	}

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FlxSprite
	{
		var tileGraphic:FlxGraphic = FlxG.bitmap.add(Graphic);
		setTileFrame(tileGraphic.imageFrame.frame);

		var w:Int = Std.int(_tileFrame.sourceSize.x + _spaceX);
		var h:Int = Std.int(_tileFrame.sourceSize.y + _spaceY);

		_scrollW = w;
		_scrollH = h;

		regenGraphic();

		return this;
	}

	public function loadFrame(Frame:FlxFrame):FlxBackdrop
	{
		setTileFrame(Frame);

		var w:Int = Std.int(_tileFrame.sourceSize.x + _spaceX);
		var h:Int = Std.int(_tileFrame.sourceSize.y + _spaceY);

		_scrollW = w;
		_scrollH = h;

		regenGraphic();

		return this;
	}

	override public function draw():Void
	{
		var isColored:Bool = (alpha != 1) || (color != 0xffffff);
		var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
				continue;

			var ssw:Float = _scrollW * Math.abs(scale.x);
			var ssh:Float = _scrollH * Math.abs(scale.y);

			// Find x position
			if (_repeatX)
			{
				_ppoint.x = ((x - offset.x - camera.scroll.x * scrollFactor.x) % ssw);

				if (_ppoint.x > 0)
					_ppoint.x -= ssw;
			}
			else
			{
				_ppoint.x = (x - offset.x - camera.scroll.x * scrollFactor.x);
			}

			// Find y position
			if (_repeatY)
			{
				_ppoint.y = ((y - offset.y - camera.scroll.y * scrollFactor.y) % ssh);

				if (_ppoint.y > 0)
					_ppoint.y -= ssh;
			}
			else
			{
				_ppoint.y = (y - offset.y - camera.scroll.y * scrollFactor.y);
			}

			// Draw to the screen
			if (FlxG.renderBlit)
			{
				if (graphic == null)
					return;

				if (dirty)
					calcFrame(useFramePixels);

				_flashRect2.setTo(0, 0, graphic.width, graphic.height);
				camera.copyPixels(frame, framePixels, _flashRect2, _ppoint, colorTransform, blend, antialiasing, shader);
			}
			else
			{
				if (_tileFrame == null)
					return;

				var drawItem = camera.startQuadBatch(_tileFrame.parent, isColored, hasColorOffsets, blend, antialiasing, shader);

				_tileFrame.prepareMatrix(_matrix);

				var scaleX:Float = scale.x;
				var scaleY:Float = scale.y;

				if (useScaleHack)
				{
					scaleX += 1 / (_tileFrame.sourceSize.x * camera.totalScaleX);
					scaleY += 1 / (_tileFrame.sourceSize.y * camera.totalScaleY);
				}

				_matrix.scale(scaleX, scaleY);

				var tx:Float = _matrix.tx;
				var ty:Float = _matrix.ty;

				for (j in 0..._numTiles)
				{
					var currTileX = _tileInfo[j * 2];
					var currTileY = _tileInfo[(j * 2) + 1];

					_matrix.tx = tx + (_ppoint.x + currTileX);
					_matrix.ty = ty + (_ppoint.y + currTileY);

					drawItem.addQuad(_tileFrame, _matrix, colorTransform);
				}
			}
		}
	}

	function regenGraphic():Void
	{
		var sx:Float = Math.abs(scale.x);
		var sy:Float = Math.abs(scale.y);

		var ssw:Int = Std.int(_scrollW * sx);
		var ssh:Int = Std.int(_scrollH * sy);

		var w:Int = ssw;
		var h:Int = ssh;

		var frameBitmap:BitmapData = null;

		if (_repeatX)
			w += FlxG.width;
		if (_repeatY)
			h += FlxG.height;

		if (FlxG.renderBlit)
		{
			if (graphic == null || (graphic.width != w || graphic.height != h))
			{
				makeGraphic(w, h, FlxColor.TRANSPARENT, true);
			}
		}
		else
		{
			_tileInfo = [];
			_numTiles = 0;

			width = frameWidth = w;
			height = frameHeight = h;
		}

		_ppoint.x = _ppoint.y = 0;

		if (FlxG.renderBlit)
		{
			pixels.lock();
			_flashRect2.setTo(0, 0, graphic.width, graphic.height);
			pixels.fillRect(_flashRect2, FlxColor.TRANSPARENT);
			_matrix.identity();
			_matrix.scale(sx, sy);
			frameBitmap = _tileFrame.paint();
		}

		while (_ppoint.y < h)
		{
			while (_ppoint.x < w)
			{
				if (FlxG.renderBlit)
				{
					pixels.draw(frameBitmap, _matrix);
					_matrix.tx += ssw;
				}
				else
				{
					_tileInfo.push(_ppoint.x);
					_tileInfo.push(_ppoint.y);
					_numTiles++;
				}
				_ppoint.x += ssw;
			}
			if (FlxG.renderBlit)
			{
				_matrix.tx = 0;
				_matrix.ty += ssh;
			}

			_ppoint.x = 0;
			_ppoint.y += ssh;
		}

		if (FlxG.renderBlit)
		{
			frameBitmap.dispose();
			pixels.unlock();
			dirty = true;
			calcFrame();
		}
	}

	function onGameResize(_, _):Void
	{
		if (_tileFrame != null)
			regenGraphic();
	}

	inline function scaleCallback(Scale:FlxPoint)
	{
		if (_tileFrame != null)
			regenGraphic();
	}

	function setTileFrame(Frame:FlxFrame):FlxFrame
	{
		if (Frame != _tileFrame)
		{
			if (_tileFrame != null)
				_tileFrame.parent.useCount--;

			if (Frame != null)
				Frame.parent.useCount++;
		}

		return _tileFrame = Frame;
	}
}