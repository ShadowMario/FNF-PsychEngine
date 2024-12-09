package backend.ui;

import flixel.util.FlxDestroyUtil;
import flixel.FlxObject;

class PsychUIRadioGroup extends FlxSpriteGroup
{
	public static final CLICK_EVENT = 'radiogroup_click';

	public var labels(default, set):Array<String> = [];
	public var radios:Array<PsychUIRadioItem> = [];

	public var space(default, set):Float = 25;
	public var textWidth(default, set):Int = 100;
	public var maxItems(default, set):Int = 0;

	public var stackHorizontal(default, set):Bool = false;

	public var checked(default, set):Int = -1;
	public var checkedRadio(default, set):PsychUIRadioItem;

	public var arrowUp:FlxSprite;
	public var arrowDown:FlxSprite;

	public var onClick:Void->Void;

	var _hitbox:FlxObject;
	public function new(x:Float, y:Float, labels:Array<String>, space:Float = 25, maxItems:Int = 0, ?isHorizontal:Bool = false, ?textWidth:Int = 100)
	{
		super(x, y);
		
		_hitbox = new FlxObject();

		arrowUp = new FlxSprite().loadGraphic(Paths.image('psych-ui/arrow_up', 'embed'), true, 24, 18);
		arrowUp.animation.add('normal', [0]);
		arrowUp.animation.add('press', [1]);
		arrowUp.animation.play('normal');
		arrowUp.visible = false;
		arrowDown = new FlxSprite().loadGraphic(Paths.image('psych-ui/arrow_down', 'embed'), true, 24, 18);
		arrowDown.animation.add('normal', [0]);
		arrowDown.animation.add('press', [1]);
		arrowDown.animation.play('normal');
		arrowDown.visible = false;

		this.space = space;
		this.textWidth = textWidth;
		@:bypassAccessor if(labels != null) this.labels = labels;
		@:bypassAccessor this.stackHorizontal = isHorizontal;
		this.maxItems = maxItems;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_hitbox.x = x;
		_hitbox.y = y;
		_hitbox.width = width;
		_hitbox.height = height;
		if(maxItems > 0 && maxItems < labels.length && FlxG.mouse.wheel != 0 && FlxG.mouse.overlaps(_hitbox, camera))
		{
			curScroll -= FlxG.mouse.wheel;
			//trace('just scrolled: ' + FlxG.mouse.wheel);
		}

		var baseY:Float = y + radios.length * space;
		if(stackHorizontal) baseY = y + 25;

		var hasArrowUp:Bool = false;
		var hasArrowDown:Bool = false;
		if(arrowDown != null && arrowDown.exists && arrowDown.active)
		{
			arrowDown.x = x;
			arrowDown.y = baseY;
			hasArrowDown = true;
		}

		if(arrowUp != null && arrowUp.exists && arrowUp.active)
		{
			arrowUp.x = x;
			arrowUp.y = baseY;
			hasArrowUp = true;
			if(hasArrowDown)
				arrowDown.x += arrowUp.width + 8;
		}

		if(FlxG.mouse.justPressed)
		{
			if(hasArrowUp && maxItems > 0 && curScroll > 0 && FlxG.mouse.overlaps(arrowUp, camera))
			{
				curScroll--;
				arrowUp.animation.play('press');
			}
			else if(hasArrowDown && maxItems > 0 && curScroll < (labels.length - maxItems) && FlxG.mouse.overlaps(arrowDown, camera))
			{
				curScroll++;
				arrowDown.animation.play('press');
			}
		}
		else if(FlxG.mouse.released)
		{
			if(hasArrowUp && arrowUp.animation.curAnim != null && arrowUp.animation.curAnim.name != 'normal')
				arrowUp.animation.play('normal');
			if(hasArrowDown && arrowDown.animation.curAnim != null && arrowDown.animation.curAnim.name != 'normal')
				arrowDown.animation.play('normal');
		}
	}

	override function draw()
	{
		super.draw();

		if(arrowUp != null && arrowUp.exists && arrowUp.active)
			arrowUp.draw();

		if(arrowDown != null && arrowDown.exists && arrowDown.active)
			arrowDown.draw();
	}

	override function destroy()
	{
		_hitbox = FlxDestroyUtil.destroy(_hitbox);
		arrowUp = FlxDestroyUtil.destroy(arrowUp);
		arrowDown = FlxDestroyUtil.destroy(arrowDown);
		super.destroy();
	}

	public var curScroll(default, set):Int = 0;
	function set_curScroll(v:Int)
	{
		var lastScroll:Int = curScroll;
		if(maxItems > 0 && labels.length > maxItems)
		{
			curScroll = Std.int(FlxMath.bound(v, 0, labels.length - maxItems));
			if(arrowUp != null && arrowUp.exists) 
			{
				arrowUp.visible = arrowUp.active = true;
				arrowUp.alpha = (curScroll != 0) ? 1 : 0.4;
			}
			if(arrowDown != null && arrowDown.exists) 
			{
				arrowDown.visible = arrowDown.active = true;
				arrowDown.alpha = (curScroll != (labels.length - maxItems)) ? 1 : 0.4;
			}
		}
		else
		{
			curScroll = 0;
			if(arrowUp != null && arrowUp.exists) 
			{
				arrowUp.visible = arrowUp.active = false;
				arrowUp.alpha = 1;
			}
			if(arrowDown != null && arrowDown.exists) 
			{
				arrowDown.visible = arrowDown.active = false;
				arrowDown.alpha = 1;
			}
		}
		if(curScroll != lastScroll)
		{
			checked += (lastScroll - curScroll);
			updateRadioItems();
		}
		return curScroll;
	}

	function set_stackHorizontal(v:Bool)
	{
		stackHorizontal = v;
		updateRadioItems();
		return stackHorizontal;
	}

	function set_checked(v:Int)
	{
		checked = Std.int(FlxMath.bound(v, -1, Math.min(labels.length-1, radios.length-1)));
		@:bypassAccessor checkedRadio = null;
		for (num => radio in radios)
		{
			radio.checked = (num == checked);
			if(num == checked) @:bypassAccessor checkedRadio = radio;
		}
		return checked;
	}

	function set_labels(v:Array<String>)
	{
		labels = v;
		updateRadioItems();
		set_checked(checked);
		set_curScroll(curScroll);
		return labels;
	}

	function set_checkedRadio(v:PsychUIRadioItem)
	{
		checkedRadio = null;
		@:bypassAccessor checked = -1;
		for (num => radio in radios)
		{
			radio.checked = (v == radio);
			if(v == radio)
			{
				checkedRadio = radio;
				@:bypassAccessor checked = num;
			}
		}
		return checkedRadio;
	}

	function set_space(v:Float)
	{
		space = v;
		for (num => radio in radios)
		{
			if(!stackHorizontal)
				radio.y = y + num * space;
			else
				radio.x = x + num * (textWidth + space);
		}

		return space;
	}


	function set_textWidth(v:Int)
	{
		textWidth = v;
		for (num => radio in radios)
			radio.text.fieldWidth = textWidth;

		return textWidth;
	}

	function set_maxItems(v:Int)
	{
		maxItems = v;
		set_curScroll(curScroll);

		updateRadioItems();
		return maxItems;
	}

	public function updateRadioItems()
	{
		if(maxItems > 0)
		{
			for (radio in radios)
				radio.kill();

			radios = [];
			for (i in 0...maxItems)
			{
				var rad = _addNewRadio();
				if(i >= labels.length)
					rad.visible = rad.active = false;
			}
		}
		else
		{
			while(radios.length > labels.length)
			{
				//kill extra radios
				radios[radios.length-1].kill();
				radios.pop();
			}
			while(radios.length < labels.length)
			{
				//recycle radios to fit number
				_addNewRadio();
			}
		}
		
		for (num => radio in radios)
		{
			radio.visible = radio.active = (num < labels.length || labels.length > maxItems);
			radio.label = labels[num + curScroll] != null ? labels[num + curScroll] : '';
			if(!stackHorizontal)
			{
				radio.x = x;
				radio.y = y + num * space;
			}
			else
			{
				radio.x = x + num * (textWidth + space);
				radio.y = y;
			}
		}
	}

	override function set_cameras(v:Array<FlxCamera>)
	{
		if(arrowUp != null && arrowUp.exists) arrowUp.cameras = v;
		if(arrowDown != null && arrowDown.exists) arrowDown.cameras = v;
		return super.set_cameras(v);
	}

	override function set_camera(v:FlxCamera)
	{
		if(arrowUp != null && arrowUp.exists) arrowUp.camera = v;
		if(arrowDown != null && arrowDown.exists) arrowDown.camera = v;
		return super.set_camera(v);
	}

	public var broadcastRadioGroupEvent:Bool = true;
	function _addNewRadio()
	{
		var radio:PsychUIRadioItem = cast recycle(PsychUIRadioItem);
		radio.onClick = function() {
			checkedRadio = radio;
			if(onClick != null) onClick();
			if(broadcastRadioGroupEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
		};
		radio.visible = radio.active = true;
		radio.text.fieldWidth = textWidth;
		radios.push(radio);
		return insert(0, radio);
	}
}

class PsychUIRadioItem extends PsychUICheckBox
{
	public function new(x:Float, y:Float, label:String, textWid:Int = 100)
	{
		super(x, y, label, textWid);
		broadcastCheckBoxEvent = false;
	}
	override function boxGraphic()
	{
		box.loadGraphic(Paths.image('psych-ui/radio', 'embed'), true, 16, 16);
		box.animation.add('false', [0]);
		box.animation.add('true', [1]);
		box.animation.play('false');
	}
}