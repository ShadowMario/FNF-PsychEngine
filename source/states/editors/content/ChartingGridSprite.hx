package states.editors.content;

import flixel.addons.display.FlxGridOverlay;

// Laggier than a single sprite for the grid, but this is to avoid having to re-create the sprite constantly
class ChartingGridSprite extends FlxSprite
{
	public var rows(default, set):Int = 16;
	public var columns(default, null):Int = 0;
	public var spacing(default, set):Int = 0;
	public var stripe:FlxSprite;
	public var stripes:Array<Int>;

	public function new(columns:Int, ?color1:FlxColor = 0xFFE6E6E6, ?color2:FlxColor = 0xFFD8D8D8)
	{
		super();
		this.columns = columns;
		scrollFactor.x = 0;
		active = false;

		scale.set(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
		loadGrid(color1, color2);
		updateHitbox();
		recalcHeight();

		stripe = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		stripe.scrollFactor.x = 0;
		stripe.color = FlxColor.BLACK;
		updateStripes();
	}

	public function loadGrid(color1:FlxColor, color2:FlxColor)
	{
		loadGraphic(FlxGridOverlay.createGrid(1, 1, columns, 2, true, color1, color2), true, columns, 1);
		animation.add('odd', [0], false);
		animation.add('even', [1], false);
		animation.play('even', true);
	}

	override function draw()
	{
		if(rows < 1) return;

		super.draw();
		if(rows == 1)
		{
			_drawStripes();
			return;
		}

		var initialY:Float = y;
		for (i in 1...rows)
		{
			y += ChartingState.GRID_SIZE + spacing;
			animation.play((i % 2 == 1) ? 'odd' : 'even', true);
			super.draw();
		}
		animation.play('even', true);
		y = initialY;

		_drawStripes();
	}

	function _drawStripes()
	{
		for (i => column in stripes)
		{
			if(column == 0)
				stripe.x = this.x;
			else 
				stripe.x = this.x + ChartingState.GRID_SIZE * column - stripe.width/2;
			stripe.draw();
		}
	}

	public function updateStripes()
	{
		if(stripe == null || !stripe.exists) return;
		stripe.y = this.y;
		stripe.setGraphicSize(2, this.height);
		stripe.updateHitbox();
	}

	function set_rows(v:Int)
	{
		rows = v;
		recalcHeight();
		return rows;
	}

	function set_spacing(v:Int)
	{
		rows = v;
		recalcHeight();
		return rows;
	}

	function recalcHeight()
	{
		height = ((ChartingState.GRID_SIZE + spacing) * rows) - spacing;
		updateStripes();
	}
}