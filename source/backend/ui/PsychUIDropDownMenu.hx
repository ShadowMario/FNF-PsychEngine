package backend.ui;

import backend.ui.PsychUIBox.UIStyleData;

class PsychUIDropDownMenu extends PsychUIInputText
{
	public static final CLICK_EVENT = "dropdown_click";

	public var list(default, set):Array<String> = [];
	public var button:FlxSprite;
	public var onSelect:Int->String->Void;

	public var selectedIndex(default, set):Int = -1;
	public var selectedLabel(default, set):String = null;

	var _curFilter:Array<String>;
	public function new(x:Float, y:Float, list:Array<String>, callback:Int->String->Void)
	{
		super(x, y);
		if(list == null) list = [];

		setGraphicSize(width, 20);
		updateHitbox();
		textObj.y += 2;

		button = new FlxSprite(behindText.width + 1, 0).loadGraphic(Paths.image('psych-ui/dropdown_button', 'embed'), true, 20, 20);
		button.animation.add('normal', [0], false);
		button.animation.add('pressed', [1], false);
		button.animation.play('normal', true);
		add(button);

		onSelect = callback;

		onChange = function(old:String, cur:String)
		{
			if(old != cur)
			{
				_curFilter = list.filter(function(str:String) return str.startsWith(cur));
				showDropDown(true, 0, _curFilter);
			}
		}
		unfocus = function()
		{
			showDropDownClickFix();
			showDropDown(false);
		}

		for (option in list)
			addOption(option);

		selectedIndex = 0;
		showDropDown(false);
	}

	function set_selectedIndex(v:Int)
	{
		selectedIndex = v;
		if(selectedIndex < 0 || selectedIndex >= list.length) selectedIndex = -1;

		@:bypassAccessor selectedLabel = list[selectedIndex];
		text = (selectedLabel != null) ? selectedLabel : '';
		return selectedIndex;
	}

	function set_selectedLabel(v:String)
	{
		var id:Int = list.indexOf(v);
		if(id >= 0)
		{
			@:bypassAccessor selectedIndex = id;
			selectedLabel = v;
			text = selectedLabel;
		}
		else
		{
			@:bypassAccessor selectedIndex = -1;
			selectedLabel = null;
			text = '';
		}
		return selectedLabel;
	}

	var _items:Array<PsychUIDropDownItem> = [];
	public var curScroll:Int = 0;
	override function update(elapsed:Float)
	{
		var lastFocus = PsychUIInputText.focusOn;
		super.update(elapsed);
		if(FlxG.mouse.justPressed)
		{
			if(FlxG.mouse.overlaps(button, camera))
			{
				button.animation.play('pressed', true);
				if(lastFocus != this)
					PsychUIInputText.focusOn = this;
				else if(PsychUIInputText.focusOn == this)
					PsychUIInputText.focusOn = null;
			}
		}
		else if(FlxG.mouse.released && button.animation.curAnim != null && button.animation.curAnim.name != 'normal') button.animation.play('normal', true);

		if(lastFocus != PsychUIInputText.focusOn)
		{
			showDropDown(PsychUIInputText.focusOn == this);
		}
		else if(PsychUIInputText.focusOn == this)
		{
			var wheel:Int = FlxG.mouse.wheel;
			if(FlxG.keys.justPressed.UP) wheel++;
			if(FlxG.keys.justPressed.DOWN) wheel--;
			if(wheel != 0) showDropDown(true, curScroll - wheel, _curFilter);
		}
	}

	private function showDropDownClickFix()
	{
		if(FlxG.mouse.justPressed)
		{
			for (item in _items) //extra update to fix a little bug where it wouldnt click on any option if another input text was behind the drop down
				if(item != null && item.active && item.visible)
					item.update(0);
		}
	}

	public function showDropDown(vis:Bool = true, scroll:Int = 0, onlyAllowed:Array<String> = null)
	{
		if(!vis)
		{
			text = selectedLabel;
			_curFilter = null;
		}

		curScroll = Std.int(Math.max(0, Math.min(onlyAllowed != null ? (onlyAllowed.length - 1) : (list.length - 1), scroll)));
		if(vis)
		{
			var n:Int = 0;
			for (item in _items)
			{
				if(onlyAllowed != null)
				{
					if(onlyAllowed.contains(item.label))
					{
						item.active = item.visible = (n >= curScroll);
						n++;
					}
					else item.active = item.visible = false;
				}
				else
				{
					item.active = item.visible = (n >= curScroll);
					n++;
				}
			}

			var txtY:Float = behindText.y + behindText.height + 1;
			for (num => item in _items)
			{
				if(!item.visible) continue;
				item.y = txtY;
				txtY += item.height;
				item.forceNextUpdate = true;
			}
			bg.scale.y = txtY - behindText.y + 2;
			bg.updateHitbox();
		}
		else
		{
			for (item in _items)
				item.active = item.visible = false;

			bg.scale.y = 20;
			bg.updateHitbox();
		}
	}

	public var broadcastDropDownEvent:Bool = true;
	function clickedOn(num:Int, label:String)
	{
		selectedIndex = num;
		showDropDown(false);
		if(onSelect != null) onSelect(num, label);
		if(broadcastDropDownEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
	}

	function addOption(option:String)
	{
		@:bypassAccessor list.push(option);
		var curID:Int = list.length - 1;
		var item:PsychUIDropDownItem = cast recycle(PsychUIDropDownItem);
		item.x = 1;
		item.y = 1;
		item.label = option;
		item.visible = item.active = false;
		item.onClick = function() clickedOn(curID, option);
		item.forceNextUpdate = true;
		_items.push(item);
		insert(1, item);
	}

	function set_list(v:Array<String>)
	{
		var selected:String = selectedLabel;
		showDropDown(false);

		for (item in _items)
			item.kill();

		_items = [];
		list = [];
		for (option in v)
			addOption(option);

		if(selectedLabel != null) selectedLabel = selected;
		return v;
	}
}

class PsychUIDropDownItem extends FlxSpriteGroup
{
	public var hoverStyle:UIStyleData = {
		bgColor: 0xFF0066FF,
		textColor: FlxColor.WHITE,
		bgAlpha: 1
	};
	public var normalStyle:UIStyleData = {
		bgColor: FlxColor.WHITE,
		textColor: FlxColor.BLACK,
		bgAlpha: 1
	};

	public var bg:FlxSprite;
	public var text:FlxText;
	public function new(x:Float = 0, y:Float = 0, width:Int = 100)
	{
		super(x, y);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		bg.setGraphicSize(width, 20);
		bg.updateHitbox();
		add(bg);

		text = new FlxText(0, 0, width, 8);
		text.color = FlxColor.BLACK;
		add(text);
	}

	public var onClick:Void->Void;
	public var forceNextUpdate:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.mouse.justMoved || FlxG.mouse.justPressed || forceNextUpdate)
		{
			var overlapped:Bool = (FlxG.mouse.overlaps(bg, camera));

			var style = overlapped ? hoverStyle : normalStyle;
			bg.color = style.bgColor;
			text.color = style.textColor;
			bg.alpha = style.bgAlpha;
			forceNextUpdate = false;

			if(overlapped && FlxG.mouse.justPressed)
				onClick();
		}
		
		text.x = bg.x;
		text.y = bg.y + bg.height/2 - text.height/2;
	}

	public var label(default, set):String;
	function set_label(v:String)
	{
		label = v;
		text.text = v;
		bg.scale.y = text.height + 6;
		bg.updateHitbox();
		return v;
	}
}