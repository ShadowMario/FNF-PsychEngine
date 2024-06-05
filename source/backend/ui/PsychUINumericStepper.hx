package backend.ui;

class PsychUINumericStepper extends PsychUIInputText
{
	public static final CHANGE_EVENT = "numericstepper_change";

	public var step:Float = 0;
	public var min(default, set):Float = 0;
	public var max(default, set):Float = 0;
	public var decimals(default, set):Int = 0;
	public var isPercent(default, set):Bool = false;
	public var buttonPlus:FlxSprite;
	public var buttonMinus:FlxSprite;

	public var onValueChange:Void->Void;
	public var value(default, set):Float;
	public function new(x:Float = 0, y:Float = 0, step:Float = 1, defValue:Float = 0, min:Float = -999, max:Float = 999, decimals:Int = 0, ?wid:Int = 60, ?isPercent:Bool = false)
	{
		super(x, y, wid, '');
		fieldWidth = Std.int(behindText.width + 2);
		@:bypassAccessor this.decimals = decimals;
		@:bypassAccessor this.isPercent = isPercent;
		@:bypassAccessor this.min = min;
		@:bypassAccessor this.max = max;
		this.step = step;
		_updateFilter();

		buttonPlus = new FlxSprite(fieldWidth).loadGraphic(Paths.image('psych-ui/stepper_plus', 'embed'), true, 16, 16);
		buttonPlus.animation.add('normal', [0], false);
		buttonPlus.animation.add('pressed', [1], false);
		buttonPlus.animation.play('normal');
		add(buttonPlus);
		
		buttonMinus = new FlxSprite(fieldWidth + buttonPlus.width).loadGraphic(Paths.image('psych-ui/stepper_minus', 'embed'), true, 16, 16);
		buttonMinus.animation.add('normal', [0], false);
		buttonMinus.animation.add('pressed', [1], false);
		buttonMinus.animation.play('normal');
		add(buttonMinus);

		unfocus = function()
		{
			_updateValue();
			_internalOnChange();
		}
		value = defValue;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.mouse.justPressed)
		{
			if(buttonPlus != null && buttonPlus.exists && FlxG.mouse.overlaps(buttonPlus, camera))
			{
				buttonPlus.animation.play('pressed');
				value += step;
				_internalOnChange();
			}
			else if(buttonMinus != null && buttonMinus.exists && FlxG.mouse.overlaps(buttonMinus, camera))
			{
				buttonMinus.animation.play('pressed');
				value -= step;
				_internalOnChange();
			}
		}
		else if(FlxG.mouse.released)
		{
			if(buttonPlus != null && buttonPlus.exists && buttonPlus.animation.curAnim != null && buttonPlus.animation.curAnim.name != 'normal')
				buttonPlus.animation.play('normal');
			if(buttonMinus != null && buttonMinus.exists && buttonMinus.animation.curAnim != null && buttonMinus.animation.curAnim.name != 'normal')
				buttonMinus.animation.play('normal');
		}
	}

	function set_value(v:Float)
	{
		value = Math.max(min, Math.min(max, v));
		text = Std.string(isPercent ? (value * 100) : value);
		_updateValue();
		return value;
	}

	function set_min(v:Float)
	{
		min = v;
		@:bypassAccessor if(min > max) max = min;
		_updateFilter();
		_updateValue();
		return min;
	}

	function set_max(v:Float)
	{
		max = v;
		@:bypassAccessor if(max < min) min = max;
		_updateFilter();
		_updateValue();
		return max;
	}

	function set_decimals(v:Int)
	{
		decimals = v;
		_updateFilter();
		return decimals;
	}
	function set_isPercent(v:Bool)
	{
		var changed:Bool = (isPercent != v);
		isPercent = v;
		_updateFilter();

		if(changed)
		{
			text = Std.string(value * 100);
			_updateValue();
		}
		return isPercent;
	}

	function _updateValue()
	{
		var txt:String = text.replace('%', '');
		if(txt.indexOf('-') > 0)
			txt.replace('-', '');

		while(txt.indexOf('.') > -1 && txt.indexOf('.') != txt.lastIndexOf('.'))
		{
			var lastId = txt.lastIndexOf('.');
			txt = txt.substr(0, lastId) + txt.substring(lastId+1);
		}

		var val:Float = Std.parseFloat(txt);
		if(Math.isNaN(val))
			val = 0;

		if(isPercent) val /= 100;

		if(val < min) val = min;
		else if(val > max) val = max;
		val = FlxMath.roundDecimal(val, decimals);
		@:bypassAccessor value = val;

		if(isPercent)
		{
			text = Std.string(val * 100);
			text += '%';
		}
		else text = Std.string(val);

		if(caretIndex > text.length) caretIndex = text.length;
		if(selectIndex > text.length) selectIndex = text.length;
	}
	
	function _updateFilter()
	{
		if(min < 0)
		{
			if(decimals > 0)
			{
				if(isPercent)
					customFilterPattern = ~/[^0-9.%\-]*/g;
				else
					customFilterPattern = ~/[^0-9.\-]*/g;
			}
			else
			{
				if(isPercent)
					customFilterPattern = ~/[^0-9%\-]*/g;
				else
					customFilterPattern = ~/[^0-9\-]*/g;
			}
		}
		else
		{
			if(decimals > 0)
			{
				if(isPercent)
					customFilterPattern = ~/[^0-9.%]*/g;
				else
					customFilterPattern = ~/[^0-9.]*/g;
			}
			else
			{
				if(isPercent)
					customFilterPattern = ~/[^0-9%]*/g;
				else
					customFilterPattern = ~/[^0-9]*/g;
			}
		}
	}

	public var broadcastStepperEvent:Bool = true;
	function _internalOnChange()
	{
		if(onValueChange != null) onValueChange();
		if(broadcastStepperEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
	}

	override function setGraphicSize(width:Float = 0, height:Float = 0)
	{
		super.setGraphicSize(width, height);
		behindText.setGraphicSize(width - 32, height - 2);
	}
}