package states.editors;

class ConfirmationPopupSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var finishCallback:Void->Void;
	public function new(finishCallback:Void->Void = null)
	{
		this.finishCallback = finishCallback;
		super();
	}

	var blockInput:Float = 0.1;
	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		bg = new FlxSpriteGroup();
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scale.set(420, 160);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var txt:FlxText = new FlxText(0, bg.y + 30, 400, 'There\'s unsaved progress,\nare you sure you want to exit?', 16);
		txt.screenCenter(X);
		txt.alignment = CENTER;
		add(txt);

		var btnY = 390;
		var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Exit', function() {
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new states.editors.MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			if(finishCallback != null) finishCallback();
		});
		btn.normalStyle.bgColor = FlxColor.RED;
		btn.normalStyle.textColor = FlxColor.WHITE;
		btn.screenCenter(X);
		btn.x -= 100;
		btn.cameras = cameras;
		add(btn);

		var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Cancel', function() close());
		btn.screenCenter(X);
		btn.x += 100;
		btn.cameras = cameras;
		add(btn);

		FlxG.mouse.visible = true;
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		blockInput = Math.max(0, blockInput - elapsed);
		if(blockInput <= 0 && FlxG.keys.justPressed.ESCAPE)
			close();
	}
}