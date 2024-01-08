package states.editors;

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;
import haxe.Json;
import lime.system.Clipboard;

import objects.TypedAlphabet;

import cutscenes.DialogueBoxPsych;
import cutscenes.DialogueCharacter;

class DialogueCharacterEditorState extends MusicBeatState
{
	var box:FlxSprite;
	var daText:TypedAlphabet = null;

	private static var TIP_TEXT_MAIN:String =
	'JKLI - Move camera (Hold Shift to move 4x faster)
	\nQ/E - Zoom out/in
	\nR - Reset Camera
	\nH - Toggle Speech Bubble
	\nSpace - Reset text';

	private static var TIP_TEXT_OFFSET:String =
	'JKLI - Move camera (Hold Shift to move 4x faster)
	\nQ/E - Zoom out/in
	\nR - Reset Camera
	\nH - Toggle Ghosts
	\nWASD - Move Looping animation offset (Red)
	\nArrow Keys - Move Idle/Finished animation offset (Blue)
	\nHold Shift to move offsets 10x faster';

	var tipText:FlxText;
	var offsetLoopText:FlxText;
	var offsetIdleText:FlxText;
	var animText:FlxText;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var mainGroup:FlxSpriteGroup;
	var hudGroup:FlxSpriteGroup;

	var character:DialogueCharacter;
	var ghostLoop:DialogueCharacter;
	var ghostIdle:DialogueCharacter;

	var curAnim:Int = 0;

	override function create() {
		persistentUpdate = persistentDraw = true;
		camGame = initPsychCamera();
		camGame.bgColor = FlxColor.fromHSL(0, 0, 0.5);
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		
		mainGroup = new FlxSpriteGroup();
		mainGroup.cameras = [camGame];
		hudGroup = new FlxSpriteGroup();
		hudGroup.cameras = [camGame];
		add(mainGroup);
		add(hudGroup);

		character = new DialogueCharacter();
		character.scrollFactor.set();
		mainGroup.add(character);
		
		ghostLoop = new DialogueCharacter();
		ghostLoop.alpha = 0;
		ghostLoop.color = FlxColor.RED;
		ghostLoop.isGhost = true;
		ghostLoop.jsonFile = character.jsonFile;
		ghostLoop.cameras = [camGame];
		add(ghostLoop);
		
		ghostIdle = new DialogueCharacter();
		ghostIdle.alpha = 0;
		ghostIdle.color = FlxColor.BLUE;
		ghostIdle.isGhost = true;
		ghostIdle.jsonFile = character.jsonFile;
		ghostIdle.cameras = [camGame];
		add(ghostIdle);

		box = new FlxSprite(70, 370);
		box.antialiasing = ClientPrefs.data.antialiasing;
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('center', 'speech bubble middle', 24);
		box.animation.play('normal', true);
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		hudGroup.add(box);

		tipText = new FlxText(10, 10, FlxG.width - 20, TIP_TEXT_MAIN, 8);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.cameras = [camHUD];
		tipText.scrollFactor.set();
		add(tipText);

		offsetLoopText = new FlxText(10, 10, 0, '', 32);
		offsetLoopText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetLoopText.cameras = [camHUD];
		offsetLoopText.scrollFactor.set();
		add(offsetLoopText);
		offsetLoopText.visible = false;

		offsetIdleText = new FlxText(10, 46, 0, '', 32);
		offsetIdleText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetIdleText.cameras = [camHUD];
		offsetIdleText.scrollFactor.set();
		add(offsetIdleText);
		offsetIdleText.visible = false;

		animText = new FlxText(10, 22, FlxG.width - 20, '', 8);
		animText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		animText.scrollFactor.set();
		animText.cameras = [camHUD];
		add(animText);

		reloadCharacter();
		updateTextBox();

		daText = new TypedAlphabet(DialogueBoxPsych.DEFAULT_TEXT_X, DialogueBoxPsych.DEFAULT_TEXT_Y, '', 0.05, false);
		daText.setScale(0.7);
		daText.text = DEFAULT_TEXT;
		hudGroup.add(daText);

		addEditorBox();
		FlxG.mouse.visible = true;
		updateCharTypeBox();
		
		super.create();
	}

	var UI_typebox:FlxUITabMenu;
	var UI_mainbox:FlxUITabMenu;
	function addEditorBox() {
		var tabs = [
			{name: 'Character Type', label: 'Character Type'},
		];
		UI_typebox = new FlxUITabMenu(null, tabs, true);
		UI_typebox.resize(120, 180);
		UI_typebox.x = 900;
		UI_typebox.y = FlxG.height - UI_typebox.height - 50;
		UI_typebox.scrollFactor.set();
		UI_typebox.camera = camHUD;
		addTypeUI();
		add(UI_typebox);

		var tabs = [
			{name: 'Animations', label: 'Animations'},
			{name: 'Character', label: 'Character'},
		];
		UI_mainbox = new FlxUITabMenu(null, tabs, true);
		UI_mainbox.resize(200, 250);
		UI_mainbox.x = UI_typebox.x + UI_typebox.width;
		UI_mainbox.y = FlxG.height - UI_mainbox.height - 50;
		UI_mainbox.scrollFactor.set();
		UI_mainbox.camera = camHUD;
		addAnimationsUI();
		addCharacterUI();
		add(UI_mainbox);
		UI_mainbox.selected_tab_id = 'Character';
		lastTab = UI_mainbox.selected_tab_id;
	}

	var leftCheckbox:FlxUICheckBox;
	var centerCheckbox:FlxUICheckBox;
	var rightCheckbox:FlxUICheckBox;
	function addTypeUI() {
		var tab_group = new FlxUI(null, UI_typebox);
		tab_group.name = "Character Type";

		leftCheckbox = new FlxUICheckBox(10, 20, null, null, "Left", 100);
		leftCheckbox.callback = function()
		{
			character.jsonFile.dialogue_pos = 'left';
			updateCharTypeBox();
		};

		centerCheckbox = new FlxUICheckBox(leftCheckbox.x, leftCheckbox.y + 40, null, null, "Center", 100);
		centerCheckbox.callback = function()
		{
			character.jsonFile.dialogue_pos = 'center';
			updateCharTypeBox();
		};

		rightCheckbox = new FlxUICheckBox(centerCheckbox.x, centerCheckbox.y + 40, null, null, "Right", 100);
		rightCheckbox.callback = function()
		{
			character.jsonFile.dialogue_pos = 'right';
			updateCharTypeBox();
		};

		tab_group.add(leftCheckbox);
		tab_group.add(centerCheckbox);
		tab_group.add(rightCheckbox);
		UI_typebox.addGroup(tab_group);
	}

	var curSelectedAnim:String;
	var animationArray:Array<String> = [];
	var animationDropDown:FlxUIDropDownMenu;
	var animationInputText:FlxUIInputText;
	var loopInputText:FlxUIInputText;
	var idleInputText:FlxUIInputText;
	function addAnimationsUI() {
		var tab_group = new FlxUI(null, UI_mainbox);
		tab_group.name = "Animations";

		animationDropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(animation:String) {
			var anim:String = animationArray[Std.parseInt(animation)];
			if(character.dialogueAnimations.exists(anim)) {
				ghostLoop.playAnim(anim);
				ghostIdle.playAnim(anim, true);

				curSelectedAnim = anim;
				var animShit:DialogueAnimArray = character.dialogueAnimations.get(curSelectedAnim);
				offsetLoopText.text = 'Loop: ' + animShit.loop_offsets;
				offsetIdleText.text = 'Idle: ' + animShit.idle_offsets;

				animationInputText.text = animShit.anim;
				loopInputText.text = animShit.loop_name;
				idleInputText.text = animShit.idle_name;
			}
		});
		
		animationInputText = new FlxUIInputText(15, 85, 80, '', 8);
		blockPressWhileTypingOn.push(animationInputText);
		loopInputText = new FlxUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		blockPressWhileTypingOn.push(loopInputText);
		idleInputText = new FlxUIInputText(loopInputText.x, loopInputText.y + 40, 150, '', 8);
		blockPressWhileTypingOn.push(idleInputText);
		
		var addUpdateButton:FlxButton = new FlxButton(10, idleInputText.y + 30, "Add/Update", function() {
			var theAnim:String = animationInputText.text.trim();
			if(character.dialogueAnimations.exists(theAnim)) //Update
			{
				for (i in 0...character.jsonFile.animations.length) {
					var animArray:DialogueAnimArray = character.jsonFile.animations[i];
					if(animArray.anim.trim() == theAnim) {
						animArray.loop_name = loopInputText.text;
						animArray.idle_name = idleInputText.text;
						break;
					}
				}

				character.reloadAnimations();
				ghostLoop.reloadAnimations();
				ghostIdle.reloadAnimations();
				if(curSelectedAnim == theAnim) {
					ghostLoop.playAnim(theAnim);
					ghostIdle.playAnim(theAnim, true);
				}
			}
			else //Add
			{
				var newAnim:DialogueAnimArray = {
					anim: theAnim,
					loop_name: loopInputText.text,
					loop_offsets: [0, 0],
					idle_name: idleInputText.text,
					idle_offsets: [0, 0]
				}
				character.jsonFile.animations.push(newAnim);

				var lastSelected:String = animationDropDown.selectedLabel;
				character.reloadAnimations();
				ghostLoop.reloadAnimations();
				ghostIdle.reloadAnimations();
				reloadAnimationsDropDown();
				animationDropDown.selectedLabel = lastSelected;
			}
		});
		
		var removeUpdateButton:FlxButton = new FlxButton(100, addUpdateButton.y, "Remove", function() {
			for (i in 0...character.jsonFile.animations.length) {
				var animArray:DialogueAnimArray = character.jsonFile.animations[i];
				if(animArray != null && animArray.anim.trim() == animationInputText.text.trim()) {
					var lastSelected:String = animationDropDown.selectedLabel;
					character.jsonFile.animations.remove(animArray);
					character.reloadAnimations();
					ghostLoop.reloadAnimations();
					ghostIdle.reloadAnimations();
					reloadAnimationsDropDown();
					if(character.jsonFile.animations.length > 0 && lastSelected == animArray.anim.trim()) {
						var animToPlay:String = character.jsonFile.animations[0].anim;
						ghostLoop.playAnim(animToPlay);
						ghostIdle.playAnim(animToPlay, true);
					}
					animationDropDown.selectedLabel = lastSelected;
					animationInputText.text = '';
					loopInputText.text = '';
					idleInputText.text = '';
					break;
				}
			}
		});
		
		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
		tab_group.add(new FlxText(loopInputText.x, loopInputText.y - 18, 0, 'Loop name on .XML file:'));
		tab_group.add(new FlxText(idleInputText.x, idleInputText.y - 18, 0, 'Idle/Finished name on .XML file:'));
		tab_group.add(animationInputText);
		tab_group.add(loopInputText);
		tab_group.add(idleInputText);
		tab_group.add(addUpdateButton);
		tab_group.add(removeUpdateButton);
		tab_group.add(animationDropDown);
		UI_mainbox.addGroup(tab_group);
		reloadAnimationsDropDown();
	}

	function reloadAnimationsDropDown() {
		animationArray = [];
		for (anim in character.jsonFile.animations) {
			animationArray.push(anim.anim);
		}

		if(animationArray.length < 1) animationArray = [''];
		animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(animationArray, true));
	}

	var imageInputText:FlxUIInputText;
	var scaleStepper:FlxUINumericStepper;
	var xStepper:FlxUINumericStepper;
	var yStepper:FlxUINumericStepper;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	function addCharacterUI() {
		var tab_group = new FlxUI(null, UI_mainbox);
		tab_group.name = "Character";

		imageInputText = new FlxUIInputText(10, 30, 80, character.jsonFile.image, 8);
		blockPressWhileTypingOn.push(imageInputText);
		xStepper = new FlxUINumericStepper(imageInputText.x, imageInputText.y + 50, 10, character.jsonFile.position[0], -2000, 2000, 0);
		yStepper = new FlxUINumericStepper(imageInputText.x + 80, xStepper.y, 10, character.jsonFile.position[1], -2000, 2000, 0);
		scaleStepper = new FlxUINumericStepper(imageInputText.x, xStepper.y + 50, 0.05, character.jsonFile.scale, 0.1, 10, 2);

		var noAntialiasingCheckbox:FlxUICheckBox = new FlxUICheckBox(scaleStepper.x + 80, scaleStepper.y, null, null, "No Antialiasing", 100);
		noAntialiasingCheckbox.checked = (character.jsonFile.no_antialiasing == true);
		noAntialiasingCheckbox.callback = function()
		{
			character.jsonFile.no_antialiasing = noAntialiasingCheckbox.checked;
			character.antialiasing = !character.jsonFile.no_antialiasing;
		};
		
		tab_group.add(new FlxText(10, imageInputText.y - 18, 0, 'Image file name:'));
		tab_group.add(new FlxText(10, xStepper.y - 18, 0, 'Position Offset:'));
		tab_group.add(new FlxText(10, scaleStepper.y - 18, 0, 'Scale:'));
		tab_group.add(imageInputText);
		tab_group.add(xStepper);
		tab_group.add(yStepper);
		tab_group.add(scaleStepper);
		tab_group.add(noAntialiasingCheckbox);

		var reloadImageButton:FlxButton = new FlxButton(10, scaleStepper.y + 60, "Reload Image", function() {
			reloadCharacter();
		});
		
		var loadButton:FlxButton = new FlxButton(reloadImageButton.x + 100, reloadImageButton.y, "Load Character", function() {
			loadCharacter();
		});
		var saveButton:FlxButton = new FlxButton(loadButton.x, reloadImageButton.y - 25, "Save Character", function() {
			saveCharacter();
		});
		tab_group.add(reloadImageButton);
		tab_group.add(loadButton);
		tab_group.add(saveButton);
		UI_mainbox.addGroup(tab_group);
	}
	
	function updateCharTypeBox() {
		leftCheckbox.checked = false;
		centerCheckbox.checked = false;
		rightCheckbox.checked = false;

		switch(character.jsonFile.dialogue_pos) {
			case 'left':
				leftCheckbox.checked = true;
			case 'center':
				centerCheckbox.checked = true;
			case 'right':
				rightCheckbox.checked = true;
		}
		reloadCharacter();
		updateTextBox();
	}

	private static var DEFAULT_TEXT:String = 'Lorem ipsum dolor sit amet';

	function reloadCharacter() {
		var charsArray:Array<DialogueCharacter> = [character, ghostLoop, ghostIdle];
		for (char in charsArray) {
			char.frames = Paths.getSparrowAtlas('dialogue/' + character.jsonFile.image);
			char.jsonFile = character.jsonFile;
			char.reloadAnimations();
			char.setGraphicSize(Std.int(char.width * DialogueCharacter.DEFAULT_SCALE * character.jsonFile.scale));
			char.updateHitbox();
		}
		character.x = DialogueBoxPsych.LEFT_CHAR_X;
		character.y = DialogueBoxPsych.DEFAULT_CHAR_Y;

		switch(character.jsonFile.dialogue_pos) {
			case 'right':
				character.x = FlxG.width - character.width + DialogueBoxPsych.RIGHT_CHAR_X;
			
			case 'center':
				character.x = FlxG.width / 2;
				character.x -= character.width / 2;
		}
		character.x += character.jsonFile.position[0] + mainGroup.x;
		character.y += character.jsonFile.position[1] + mainGroup.y;
		character.playAnim(character.jsonFile.animations[0].anim);
		if(character.jsonFile.animations.length > 0) {
			curSelectedAnim = character.jsonFile.animations[0].anim;
			var animShit:DialogueAnimArray = character.dialogueAnimations.get(curSelectedAnim);
			ghostLoop.playAnim(animShit.anim);
			ghostIdle.playAnim(animShit.anim, true);
			offsetLoopText.text = 'Loop: ' + animShit.loop_offsets;
			offsetIdleText.text = 'Idle: ' + animShit.idle_offsets;
		}

		curAnim = 0;
		animText.text = 'Animation: ' + character.jsonFile.animations[curAnim].anim + ' (' + (curAnim + 1) +' / ' + character.jsonFile.animations.length + ') - Press W or S to scroll';

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Dialogue Character Editor", "Editting: " + character.jsonFile.image);
		#end
	}

	function updateTextBox() {
		box.flipX = false;
		var anim:String = 'normal';
		switch(character.jsonFile.dialogue_pos) {
			case 'left':
				box.flipX = true;
			case 'center':
				anim = 'center';
		}
		box.animation.play(anim, true);
		DialogueBoxPsych.updateBoxOffsets(box);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && sender == imageInputText) {
			character.jsonFile.image = imageInputText.text;
		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			if(sender == scaleStepper) {
				character.jsonFile.scale = scaleStepper.value;
				reloadCharacter();
			} else if(sender == xStepper) {
				character.jsonFile.position[0] = xStepper.value;
				reloadCharacter();
			} else if(sender == yStepper) {
				character.jsonFile.position[1] = yStepper.value;
				reloadCharacter();
			}
		}
	}

	var currentGhosts:Int = 0;
	var lastTab:String = 'Character';
	var transitioning:Bool = false;
	override function update(elapsed:Float) {
		if(transitioning) {
			super.update(elapsed);
			return;
		}

		if(character.animation.curAnim != null) {
			if(daText.finishedText) {
				if(character.animationIsLoop()) {
					character.playAnim(character.animation.curAnim.name, true);
				}
			} else if(character.animation.curAnim.finished) {
				character.animation.curAnim.restart();
			}
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				ClientPrefs.toggleVolumeKeys(false);
				blockInput = true;

				if(FlxG.keys.justPressed.ENTER) inputText.hasFocus = false;
				break;
			}
		}

		if(!blockInput && !animationDropDown.dropPanel.visible) {
			ClientPrefs.toggleVolumeKeys(true);
			if(FlxG.keys.justPressed.SPACE && UI_mainbox.selected_tab_id == 'Character') {
				character.playAnim(character.jsonFile.animations[curAnim].anim);
				daText.resetDialogue();
				updateTextBox();
			}

			//lots of Ifs lol get trolled
			var offsetAdd:Int = 1;
			var speed:Float = 300;
			if(FlxG.keys.pressed.SHIFT) {
				speed = 1200;
				offsetAdd = 10;
			}

			var negaMult:Array<Int> = [1, 1, -1, -1];
			var controlArray:Array<Bool> = [FlxG.keys.pressed.J, FlxG.keys.pressed.I, FlxG.keys.pressed.L, FlxG.keys.pressed.K];
			for (i in 0...controlArray.length) {
				if(controlArray[i]) {
					if(i % 2 == 1) {
						mainGroup.y += speed * elapsed * negaMult[i];
					} else {
						mainGroup.x += speed * elapsed * negaMult[i];
					}
				}
			}

			if(UI_mainbox.selected_tab_id == 'Animations' && curSelectedAnim != null && character.dialogueAnimations.exists(curSelectedAnim)) {
				var moved:Bool = false;
				var animShit:DialogueAnimArray = character.dialogueAnimations.get(curSelectedAnim);
				var controlArrayLoop:Array<Bool> = [FlxG.keys.justPressed.A, FlxG.keys.justPressed.W, FlxG.keys.justPressed.D, FlxG.keys.justPressed.S];
				var controlArrayIdle:Array<Bool> = [FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.UP, FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.DOWN];
				for (i in 0...controlArrayLoop.length) {
					if(controlArrayLoop[i]) {
						if(i % 2 == 1) {
							animShit.loop_offsets[1] += offsetAdd * negaMult[i];
						} else {
							animShit.loop_offsets[0] += offsetAdd * negaMult[i];
						}
						moved = true;
					}
				}
				for (i in 0...controlArrayIdle.length) {
					if(controlArrayIdle[i]) {
						if(i % 2 == 1) {
							animShit.idle_offsets[1] += offsetAdd * negaMult[i];
						} else {
							animShit.idle_offsets[0] += offsetAdd * negaMult[i];
						}
						moved = true;
					}
				}

				if(moved) {
					offsetLoopText.text = 'Loop: ' + animShit.loop_offsets;
					offsetIdleText.text = 'Idle: ' + animShit.idle_offsets;
					ghostLoop.offset.set(animShit.loop_offsets[0], animShit.loop_offsets[1]);
					ghostIdle.offset.set(animShit.idle_offsets[0], animShit.idle_offsets[1]);
				}
			}

			if (FlxG.keys.pressed.Q && camGame.zoom > 0.1) {
				camGame.zoom -= elapsed * camGame.zoom;
				if(camGame.zoom < 0.1) camGame.zoom = 0.1;
			}
			if (FlxG.keys.pressed.E && camGame.zoom < 1) {
				camGame.zoom += elapsed * camGame.zoom;
				if(camGame.zoom > 1) camGame.zoom = 1;
			}
			if(FlxG.keys.justPressed.H) {
				if(UI_mainbox.selected_tab_id == 'Animations') {
					currentGhosts++;
					if(currentGhosts > 2) currentGhosts = 0;

					ghostLoop.visible = (currentGhosts != 1);
					ghostIdle.visible = (currentGhosts != 2);
					ghostLoop.alpha = (currentGhosts == 2 ? 1 : 0.6);
					ghostIdle.alpha = (currentGhosts == 1 ? 1 : 0.6);
				} else {
					hudGroup.visible = !hudGroup.visible;
				}
			}
			if(FlxG.keys.justPressed.R) {
				camGame.zoom = 1;
				mainGroup.setPosition(0, 0);
				hudGroup.visible = true;
			}

			if(UI_mainbox.selected_tab_id != lastTab) {
				if(UI_mainbox.selected_tab_id == 'Animations') {
					hudGroup.alpha = 0;
					mainGroup.alpha = 0;
					ghostLoop.alpha = 0.6;
					ghostIdle.alpha = 0.6;
					tipText.text = TIP_TEXT_OFFSET;
					offsetLoopText.visible = true;
					offsetIdleText.visible = true;
					animText.visible = false;
					currentGhosts = 0;
				} else {
					hudGroup.alpha = 1;
					mainGroup.alpha = 1;
					ghostLoop.alpha = 0;
					ghostIdle.alpha = 0;
					tipText.text = TIP_TEXT_MAIN;
					offsetLoopText.visible = false;
					offsetIdleText.visible = false;
					animText.visible = true;
					updateTextBox();
					daText.resetDialogue();
					
					if(curAnim < 0) curAnim = character.jsonFile.animations.length - 1;
					else if(curAnim >= character.jsonFile.animations.length) curAnim = 0;
					
					character.playAnim(character.jsonFile.animations[curAnim].anim);
					animText.text = 'Animation: ' + character.jsonFile.animations[curAnim].anim + ' (' + (curAnim + 1) +' / ' + character.jsonFile.animations.length + ') - Press W or S to scroll';
				}
				lastTab = UI_mainbox.selected_tab_id;
				currentGhosts = 0;
			}
			
			if(UI_mainbox.selected_tab_id == 'Character')
			{
				var negaMult:Array<Int> = [1, -1];
				var controlAnim:Array<Bool> = [FlxG.keys.justPressed.W, FlxG.keys.justPressed.S];

				if(controlAnim.contains(true))
				{
					for (i in 0...controlAnim.length) {
						if(controlAnim[i] && character.jsonFile.animations.length > 0) {
							curAnim -= negaMult[i];
							if(curAnim < 0) curAnim = character.jsonFile.animations.length - 1;
							else if(curAnim >= character.jsonFile.animations.length) curAnim = 0;

							var animToPlay:String = character.jsonFile.animations[curAnim].anim;
							if(character.dialogueAnimations.exists(animToPlay)) {
								character.playAnim(animToPlay, daText.finishedText);
							}
						}
					}
					animText.text = 'Animation: ' + character.jsonFile.animations[curAnim].anim + ' (' + (curAnim + 1) +' / ' + character.jsonFile.animations.length + ') - Press W or S to scroll';
				}
			}

			if(FlxG.keys.justPressed.ESCAPE) {
				MusicBeatState.switchState(new states.editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
				transitioning = true;
			}

			ghostLoop.setPosition(character.x, character.y);
			ghostIdle.setPosition(character.x, character.y);
			hudGroup.x = mainGroup.x;
			hudGroup.y = mainGroup.y;
		}
		super.update(elapsed);
	}
	
	var _file:FileReference = null;
	function loadCharacter() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	function onLoadComplete(_):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if(_file.__path != null) fullPath = _file.__path;

		if(fullPath != null) {
			var rawJson:String = File.getContent(fullPath);
			if(rawJson != null) {
				var loadedChar:DialogueCharacterFile = cast Json.parse(rawJson);
				if(loadedChar.dialogue_pos != null) //Make sure it's really a dialogue character
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					character.jsonFile = loadedChar;
					reloadCharacter();
					reloadAnimationsDropDown();
					updateCharTypeBox();
					updateTextBox();
					daText.resetDialogue();
					imageInputText.text = character.jsonFile.image;
					scaleStepper.value = character.jsonFile.scale;
					xStepper.value = character.jsonFile.position[0];
					yStepper.value = character.jsonFile.position[1];
					_file = null;
					return;
				}
			}
		}
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
	function onLoadCancel(_):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	function onLoadError(_):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	function saveCharacter() {
		var data:String = haxe.Json.stringify(character.jsonFile, "\t");
		if (data.length > 0)
		{
			var splittedImage:Array<String> = imageInputText.text.trim().split('_');
			var characterName:String = splittedImage[0].toLowerCase().replace(' ', '');

			_file = new FileReference();
			_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, characterName + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	function onSaveError(_):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}