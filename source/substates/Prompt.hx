package substates;

import flixel.util.FlxDestroyUtil;

// A Simple Prompt with "OK" and "Cancel" that covers most case usages
class Prompt extends BasePrompt
{
	var yesFunction:Void->Void;
	public function new(title:String, yesFunction:Void->Void)
	{
		this.yesFunction = yesFunction;
		super(title, promptCreate);
	}

	function promptCreate(_)
	{
		var btnY = 390;
		var btn:PsychUIButton = new PsychUIButton(0, btnY, 'OK', function() {
			yesFunction();
			close();
		});
		btn.normalStyle.bgColor = FlxColor.RED;
		btn.normalStyle.textColor = FlxColor.WHITE;
		btn.screenCenter(X);
		btn.x -= 100;
		btn.cameras = cameras;
		add(btn);

		var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Cancel', close);
		btn.screenCenter(X);
		btn.x += 100;
		btn.cameras = cameras;
		add(btn);
	}
}

class BasePrompt extends MusicBeatSubstate
{
	var _sizeX:Float = 0;
	var _sizeY:Float = 0;
	var _title:String;

	public var onCreate:BasePrompt->Void;
	public var onUpdate:BasePrompt->Float->Void;
	public function new(?sizeX:Float = 420, ?sizeY:Float = 160, title:String, ?onCreate:BasePrompt->Void, ?onUpdate:BasePrompt->Float->Void)
	{
		this._sizeX = sizeX;
		this._sizeY = sizeY;
		this._title = title;
		this.onCreate = onCreate;
		this.onUpdate = onUpdate;
		super();
	}

	public var bg:FlxSprite;
	public var titleText:FlxText;
	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.alpha = 0.8;
		bg.scale.set(_sizeX, _sizeY);
		bg.updateHitbox();
		bg.screenCenter();
		bg.cameras = cameras;
		add(bg);
		
		titleText = new FlxText(0, bg.y + 30, 400, _title, 16);
		titleText.screenCenter(X);
		titleText.alignment = CENTER;
		titleText.cameras = cameras;
		add(titleText);
		
		if(onCreate != null)
			onCreate(this);
		super.create();
	}

	var _blockInput:Float = 0.1;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_blockInput = Math.max(0, _blockInput - elapsed);
		if(_blockInput <= 0 && FlxG.keys.justPressed.ESCAPE)
		{
			close();
			return;
		}

		if(onUpdate != null)
			onUpdate(this, elapsed);
	}

	override function destroy()
	{
		for (member in members) FlxDestroyUtil.destroy(member);
		super.destroy();
	}
}