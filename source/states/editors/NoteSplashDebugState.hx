package states.editors;

import objects.Note;
import objects.StrumNote;
import objects.NoteSplash;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUINumericStepper;

class NoteSplashDebugState extends MusicBeatState
{
	var config:NoteSplashConfig;
	var forceFrame:Int = -1;
	var curSelected:Int = 0;
	var maxNotes:Int = 4;

	var selection:FlxSprite;
	var notes:FlxTypedGroup<StrumNote>;
	var splashes:FlxTypedGroup<FlxSprite>;
	
	var nameInputText:FlxInputText;
	var stepperMinFps:FlxUINumericStepper;
	var stepperMaxFps:FlxUINumericStepper;

	var offsetsText:FlxText;
	var curFrameText:FlxText;
	var curAnimText:FlxText;
	var savedText:FlxText;
	var selecArr:Array<Float> = null;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.fromHSL(0, 0, 0.5);
		selection = new FlxSprite(0, 270).makeGraphic(150, 150, FlxColor.BLACK);
		selection.alpha = 0.4;
		add(selection);

		notes = new FlxTypedGroup<StrumNote>();
		add(notes);

		splashes = new FlxTypedGroup<FlxSprite>();
		add(splashes);

		for (i in 0...maxNotes)
		{
			var x = i * 220 + 240;
			var y = 290;
			var note:StrumNote = new StrumNote(x, y, i, 0);
			note.alpha = 0.75;
			note.playAnim('static');
			notes.add(note);

			var splash:FlxSprite = new FlxSprite(x, y);
			splash.setPosition(splash.x - Note.swagWidth * 0.95, splash.y - Note.swagWidth);
			splash.shader = note.rgbShader.parent.shader;
			splash.antialiasing = ClientPrefs.data.antialiasing;
			splashes.add(splash);
		}


		//
		var txtx = 60;
		var txty = 640;
		var animName:FlxText = new FlxText(txtx, txty, 'Animation name:', 16);
		add(animName);

		nameInputText = new FlxInputText(txtx, txty + 20, 360, '', 16);
		nameInputText.callback = function(text:String, action:String)
		{
			switch(action)
			{
				case 'enter':
					nameInputText.hasFocus = false;
				
				default:
					trace('changed anim name to $text');
					config.anim = text;
					curAnim = 1;
					reloadAnims();
			}

		};
		add(nameInputText);
		
		add(new FlxText(txtx, txty - 84, 0, 'Min/Max Framerate:', 16));
		stepperMinFps = new FlxUINumericStepper(txtx, txty - 60, 1, 22, 1, 60, 0);
		stepperMinFps.name = 'min_fps';
		add(stepperMinFps);

		stepperMaxFps = new FlxUINumericStepper(txtx + 60, txty - 60, 1, 26, 1, 60, 0);
		stepperMaxFps.name = 'max_fps';
		add(stepperMaxFps);


		//
		offsetsText = new FlxText(300, 150, 680, '', 16);
		offsetsText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetsText.scrollFactor.set();
		add(offsetsText);

		curFrameText = new FlxText(300, 100, 680, '', 16);
		curFrameText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curFrameText.scrollFactor.set();
		add(curFrameText);

		curAnimText = new FlxText(300, 50, 680, '', 16);
		curAnimText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curAnimText.scrollFactor.set();
		add(curAnimText);

		var text:FlxText = new FlxText(0, 520, FlxG.width,
			"Press SPACE to Reset animation\n
			Press ENTER twice to save to the loaded Note Splash PNG's folder\n
			A/D change selected note - Arrow Keys to change offset (Hold shift for 10x)\n
			Ctrl + C/V - Copy & Paste", 16);
		text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		add(text);

		savedText = new FlxText(0, 340, FlxG.width, '', 24);
		savedText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		savedText.scrollFactor.set();
		add(savedText);

		loadFrames();
		changeSelection();
		super.create();
		FlxG.mouse.visible = true;
	}

	var curAnim:Int = 1;
	var visibleTime:Float = 0;
	var pressEnterToSave:Float = 0;
	override function update(elapsed:Float)
	{
		@:privateAccess
		cast(stepperMinFps.text_field, FlxInputText).hasFocus = cast(stepperMaxFps.text_field, FlxInputText).hasFocus = false;

		var notTyping:Bool = !nameInputText.hasFocus;
		if(controls.BACK && notTyping)
		{
			MusicBeatState.switchState(new MasterEditorMenu());
			FlxG.mouse.visible = false;
		}
		super.update(elapsed);

		if(!notTyping) return;
		
		if (FlxG.keys.justPressed.A) changeSelection(-1);
		else if (FlxG.keys.justPressed.D) changeSelection(1);

		if(maxAnims < 1) return;

		if(selecArr != null)
		{
			var movex = 0;
			var movey = 0;
			if(FlxG.keys.justPressed.LEFT) movex = -1;
			else if(FlxG.keys.justPressed.RIGHT) movex = 1;

			if(FlxG.keys.justPressed.UP) movey = 1;
			else if(FlxG.keys.justPressed.DOWN) movey = -1;
			
			if(FlxG.keys.pressed.SHIFT)
			{
				movex *= 10;
				movey *= 10;
			}

			if(movex != 0 || movey != 0)
			{
				selecArr[0] -= movex;
				selecArr[1] += movey;
				updateOffsetText();
				splashes.members[curSelected].offset.set(10 + selecArr[0], 10 + selecArr[1]);
			}
		}

		// Copy & Paste
		if(FlxG.keys.pressed.CONTROL)
		{
			if(FlxG.keys.justPressed.C)
			{
				var arr:Array<Float> = selectedArray();
				if(copiedArray == null) copiedArray = [0, 0];
				copiedArray[0] = arr[0];
				copiedArray[1] = arr[1];
			}
			else if(FlxG.keys.justPressed.V && copiedArray != null)
			{
				var offs:Array<Float> = selectedArray();
				offs[0] = copiedArray[0];
				offs[1] = copiedArray[1];
				splashes.members[curSelected].offset.set(10 + offs[0], 10 + offs[1]);
				updateOffsetText();
			}
		}

		// Saving
		pressEnterToSave -= elapsed;
		if(visibleTime >= 0)
		{
			visibleTime -= elapsed;
			if(visibleTime <= 0)
				savedText.visible = false;
		}

		if(FlxG.keys.justPressed.ENTER)
		{
			savedText.text = 'Press ENTER again to save.';
			if(pressEnterToSave > 0) //save
			{
				saveFile();
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				pressEnterToSave = 0;
				visibleTime = 3;
			}
			else
			{
				pressEnterToSave = 0.5;
				visibleTime = 0.5;
			}
			savedText.visible = true;
		}

		// Reset anim & change anim
		if (FlxG.keys.justPressed.SPACE)
			changeAnim();
		else if (FlxG.keys.justPressed.S) changeAnim(-1);
		else if (FlxG.keys.justPressed.W) changeAnim(1);

		// Force frame
		var updatedFrame:Bool = false;
		if(updatedFrame = FlxG.keys.justPressed.Q) forceFrame--;
		else if(updatedFrame = FlxG.keys.justPressed.E) forceFrame++;

		if(updatedFrame)
		{
			if(forceFrame < 0) forceFrame = 0;
			else if(forceFrame >= maxFrame) forceFrame = maxFrame - 1;
			//trace('curFrame: $forceFrame');
			
			curFrameText.text = 'Force Frame: ${forceFrame+1} / $maxFrame\n(Press Q/E to change)';
			splashes.forEachAlive(function(spr:FlxSprite) {
				spr.animation.curAnim.paused = true;
				spr.animation.curAnim.curFrame = forceFrame;
			});
		}
	}

	function updateOffsetText()
	{
		selecArr = selectedArray();
		offsetsText.text = selecArr.toString();
	}

	var texturePath:String = '';
	var copiedArray:Array<Float> = null;
	function loadFrames()
	{
		texturePath = ClientPrefs.data.splashSkin != 'Disabled' ? NoteSplash.getSplashSkin() : NoteSplash.defaultNoteSplash;
		splashes.forEachAlive(function(spr:FlxSprite) {
			spr.frames = Paths.getSparrowAtlas(texturePath);
		});
	
		// Initialize config
		NoteSplash.configs.clear();
		config = NoteSplash.precacheConfig(texturePath);
		if(config == null) config = NoteSplash.precacheConfig(NoteSplash.defaultNoteSplash);
		nameInputText.text = config.anim;
		stepperMinFps.value = config.minFps;
		stepperMaxFps.value = config.maxFps;
		//

		reloadAnims();
	}

	function saveFile()
	{
		#if sys
		var maxLen:Int = maxAnims * Note.colArray.length;
		var curLen:Int = config.offsets.length;
		while(curLen > maxLen)
		{
			config.offsets.pop();
			curLen = config.offsets.length;
		}

		var strToSave = config.anim + '\n' + config.minFps + ' ' + config.maxFps;
		for (offGroup in config.offsets)
			strToSave += '\n' + offGroup[0] + ' ' + offGroup[1];

		var path:String = Paths.getPath('images/$texturePath.png', IMAGE, true).split('.png')[0] + '.txt';
		savedText.text = 'Saved to: $path';
		sys.io.File.saveContent(path, strToSave);

		//trace(strToSave);
		#else
		savedText.text = 'Can\'t save on this platform, too bad.';
		#end
	}
	
	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			switch(wname)
			{
				case 'min_fps':
					if(nums.value > stepperMaxFps.value)
						stepperMaxFps.value = nums.value;
				case 'max_fps':
					if(nums.value < stepperMinFps.value)
						stepperMinFps.value = nums.value;
			}
			config.minFps = Std.int(stepperMinFps.value);
			config.maxFps = Std.int(stepperMaxFps.value);
		}
	}

	var maxAnims:Int = 0;
	function reloadAnims()
	{
		var loopContinue:Bool = true;
		splashes.forEachAlive(function(spr:FlxSprite)
		{
			spr.animation.destroyAnimations();
		});

		maxAnims = 0;
		while(loopContinue)
		{
			var animID:Int = maxAnims + 1;
			splashes.forEachAlive(function(spr:FlxSprite)
			{
				for (i in 0...Note.colArray.length) {
					var animName = 'note$i-$animID';
					if (!addAnimAndCheck(spr, animName, '${config.anim} ${Note.colArray[i]} $animID', 24, false)) {
						loopContinue = false;
						return;
					}
					spr.animation.play(animName, true);
				}
			});
			if(loopContinue) maxAnims++;
		}
		trace('maxAnims: $maxAnims');
		changeAnim();
	}

	var maxFrame:Int = 0;
	function changeAnim(change:Int = 0)
	{
		maxFrame = 0;
		forceFrame = -1;
		if (maxAnims > 0)
		{
			curAnim += change;
			if(curAnim > maxAnims) curAnim = 1;
			else if(curAnim < 1) curAnim = maxAnims;

			curAnimText.text = 'Current Animation: $curAnim / $maxAnims\n(Press W/S to change)';
			curFrameText.text = 'Force Frame Disabled\n(Press Q/E to change)';

			for (i in 0...maxNotes)
			{
				var spr:FlxSprite = splashes.members[i];
				spr.animation.play('note$i-$curAnim', true);
				
				if(maxFrame < spr.animation.curAnim.numFrames)
					maxFrame = spr.animation.curAnim.numFrames;
				
				spr.animation.curAnim.frameRate = FlxG.random.int(config.minFps, config.maxFps);
				var offs:Array<Float> = selectedArray(i);
				spr.offset.set(10 + offs[0], 10 + offs[1]);
			}
		}
		else
		{
			curAnimText.text = 'INVALID ANIMATION NAME';
			curFrameText.text = '';
		}
		updateOffsetText();
	}

	function changeSelection(change:Int = 0)
	{
		var max:Int = Note.colArray.length;
		curSelected += change;
		if(curSelected < 0) curSelected = max - 1;
		else if(curSelected >= max) curSelected = 0;

		selection.x = curSelected * 220 + 220;
		updateOffsetText();
	}

	function selectedArray(sel:Int = -1)
	{
		if(sel < 0) sel = curSelected;
		var animID:Int = sel + ((curAnim - 1) * Note.colArray.length);
		if(config.offsets[animID] == null)
		{
			while(config.offsets[animID] == null)
				config.offsets.push(config.offsets[FlxMath.wrap(animID, 0, config.offsets.length-1)].copy());
		}
		return config.offsets[FlxMath.wrap(animID, 0, config.offsets.length-1)];
	}

	function addAnimAndCheck(spr:FlxSprite, name:String, anim:String, ?framerate:Int = 24, ?loop:Bool = false)
	{
		spr.animation.addByPrefix(name, anim, framerate, loop);
		return spr.animation.getByName(name) != null;
	}

	override function destroy()
	{
		super.destroy();
	}
}