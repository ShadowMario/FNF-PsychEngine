package objects;

import flixel.util.helpers.FlxBounds;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class Bar extends FlxSpriteGroup
{
	public var leftBar:FlxSprite;
	public var rightBar:FlxSprite;
	public var bg:FlxSprite;
	public var valueFunction:Void->Float;
	public var percent(default, set):Float = 0;
	public var bounds:FlxBounds<Float> = new FlxBounds<Float>(0, 1);
	public var leftToRight(default, set):Bool = true;
	public var barCenter(default, null):Float = 0;

	// you might need to change this if you want to use a custom bar
	public var barWidth(default, set):Int = 1;
	public var barHeight(default, set):Int = 1;
	public var barOffset:FlxPoint = FlxPoint.get(3, 3);

	public function new(x:Float, y:Float, image:String = 'healthBar', ?valueFunction:Void->Float, boundX:Float = 0, boundY:Float = 1)
	{
		super(x, y);
		
		this.valueFunction = valueFunction;
		setBounds(boundX, boundY);
		
		bg = new FlxSprite().loadGraphic(Paths.image(image));
		barWidth = Std.int(bg.width - 6);
		barHeight = Std.int(bg.height - 6);

		leftBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height));

		rightBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height));
		rightBar.color = FlxColor.BLACK;

		antialiasing = ClientPrefs.data.antialiasing;

		add(leftBar);
		add(rightBar);
		add(bg);
		regenerateClips();
	}

	public var enabled:Bool = true;
	override function update(elapsed:Float)
	{
		if(!enabled)
		{
			super.update(elapsed);
			return;
		}

		var value:Null<Float> = null;
		if(valueFunction != null)
			value = FlxMath.remapToRange(FlxMath.bound(valueFunction(), bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
		percent = (value != null ? value : 0);

		super.update(elapsed);
	}

	override public function destroy()
	{
		bounds = null;
		barOffset = FlxDestroyUtil.put(barOffset);
		if (leftBar.clipRect != null)
			leftBar.clipRect = FlxDestroyUtil.put(leftBar.clipRect);
		if (rightBar.clipRect != null)
			rightBar.clipRect = FlxDestroyUtil.put(rightBar.clipRect);
		super.destroy();
	}
	
	public function setBounds(min:Float, max:Float):FlxBounds<Float> //idk
	{
		return bounds.set(min, max);
	}

	public function setColors(?left:FlxColor, ?right:FlxColor)
	{
		if (left != null)
			leftBar.color = left;
		if (right != null)
			rightBar.color = right;
	}

	public function updateBar()
	{
		if(leftBar == null || rightBar == null) return;

		leftBar.setPosition(bg.x, bg.y);
		rightBar.setPosition(bg.x, bg.y);

		final leftSize:Float = FlxMath.lerp(0, barWidth, (leftToRight ? percent / 100 : 1 - percent / 100));

		leftBar.clipRect.width = leftSize;
		leftBar.clipRect.height = barHeight;
		leftBar.clipRect.x = barOffset.x;
		leftBar.clipRect.y = barOffset.y;

		rightBar.clipRect.width = barWidth - leftSize;
		rightBar.clipRect.height = barHeight;
		rightBar.clipRect.x = barOffset.x + leftSize;
		rightBar.clipRect.y = barOffset.y;

		barCenter = leftBar.x + leftSize + barOffset.x;

		// flixel is retarded
		leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;
	}

	public function regenerateClips()
	{
		if (leftBar == null && rightBar == null) return;

		final width = Std.int(bg.width);
		final height = Std.int(bg.height);
		if (leftBar != null)
		{
			leftBar.setGraphicSize(width, height);
			leftBar.updateHitbox();
			if (leftBar.clipRect == null)
				leftBar.clipRect = FlxRect.get(0, 0, width, height);
			else
				leftBar.clipRect.set(0, 0, width, height);
		}
		if (rightBar != null)
		{
			rightBar.setGraphicSize(width, height);
			rightBar.updateHitbox();
			if (rightBar.clipRect == null)
				rightBar.clipRect = FlxRect.get(0, 0, width, height);
			else
				rightBar.clipRect.set(0, 0, width, height);
		}
		updateBar();
	}

	private function set_percent(value:Float)
	{
		final doUpdate:Bool = (value != percent);
		percent = value;

		if(doUpdate) updateBar();
		return value;
	}

	private function set_leftToRight(value:Bool)
	{
		leftToRight = value;
		updateBar();
		return value;
	}

	private function set_barWidth(value:Int)
	{
		barWidth = value;
		regenerateClips();
		return value;
	}

	private function set_barHeight(value:Int)
	{
		barHeight = value;
		regenerateClips();
		return value;
	}

	override function set_x(Value:Float):Float // for dynamic center point update
	{
		final prevX:Float = x;
		super.set_x(Value);
		barCenter += Value - prevX;
		return Value;
	}

	override function set_antialiasing(Antialiasing:Bool):Bool
	{
		for (member in members)
			member.antialiasing = Antialiasing;

		return antialiasing = Antialiasing;
	}
}