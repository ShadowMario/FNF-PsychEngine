package states.editors;

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;
import tjson.TJSON as Json;
#if sys
import sys.io.File;
#end

import objects.MenuCharacter;

class MenuCharacterEditorState extends MusicBeatState
{
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var characterFile:MenuCharacterFile = null;
	var txtOffsets:FlxText;
	var defaultCharacters:Array<String> = ['dad', 'bf', 'gf'];

	override function create() {
		characterFile = {
			image: 'Menu_Dad',
			scale: 1,
			position: [0, 0],
			idle_anim: 'M Dad Idle',
			confirm_anim: 'M Dad Idle',
			flipX: false
		};
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Menu Character Editor", "Editting: " + characterFile.image);
		#end

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, defaultCharacters[char]);
			weekCharacterThing.y += 70;
			weekCharacterThing.alpha = 0.2;
			grpWeekCharacters.add(weekCharacterThing);
		}

		add(new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51));
		add(grpWeekCharacters);

		txtOffsets = new FlxText(20, 10, 0, "[0, 0]", 32);
		txtOffsets.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txtOffsets.alpha = 0.7;
		add(txtOffsets);

		var tipText:FlxText = new FlxText(0, 540, FlxG.width,
			"Arrow Keys - Change Offset (Hold shift for 10x speed)
			\nSpace - Play \"Start Press\" animation (Boyfriend Character Type)", 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		tipText.scrollFactor.set();
		add(tipText);

		addEditorBox();
		FlxG.mouse.visible = true;
		updateCharTypeBox();

		super.create();
	}

	var UI_typebox:FlxUITabMenu;
	var UI_mainbox:FlxUITabMenu;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	function addEditorBox() {
		var tabs = [
			{name: 'Character Type', label: 'Character Type'},
		];
		UI_typebox = new FlxUITabMenu(null, tabs, true);
		UI_typebox.resize(120, 180);
		UI_typebox.x = 100;
		UI_typebox.y = FlxG.height - UI_typebox.height - 50;
		UI_typebox.scrollFactor.set();
		addTypeUI();
		add(UI_typebox);

		var tabs = [
			{name: 'Character', label: 'Character'},
		];
		UI_mainbox = new FlxUITabMenu(null, tabs, true);
		UI_mainbox.resize(240, 180);
		UI_mainbox.x = FlxG.width - UI_mainbox.width - 100;
		UI_mainbox.y = FlxG.height - UI_mainbox.height - 50;
		UI_mainbox.scrollFactor.set();
		addCharacterUI();
		add(UI_mainbox);

		var loadButton:FlxButton = new FlxButton(0, 480, "Load Character", function() {
			loadCharacter();
		});
		loadButton.screenCenter(X);
		loadButton.x -= 60;
		add(loadButton);
	
		var saveButton:FlxButton = new FlxButton(0, 480, "Save Character", function() {
			saveCharacter();
		});
		saveButton.screenCenter(X);
		saveButton.x += 60;
		add(saveButton);
	}

	var opponentCheckbox:FlxUICheckBox;
	var boyfriendCheckbox:FlxUICheckBox;
	var girlfriendCheckbox:FlxUICheckBox;
	var curTypeSelected:Int = 0; //0 = Dad, 1 = BF, 2 = GF
	function addTypeUI() {
		var tab_group = new FlxUI(null, UI_typebox);
		tab_group.name = "Character Type";

		opponentCheckbox = new FlxUICheckBox(10, 20, null, null, "Opponent", 100);
		opponentCheckbox.callback = function()
		{
			curTypeSelected = 0;
			updateCharTypeBox();
		};

		boyfriendCheckbox = new FlxUICheckBox(opponentCheckbox.x, opponentCheckbox.y + 40, null, null, "Boyfriend", 100);
		boyfriendCheckbox.callback = function()
		{
			curTypeSelected = 1;
			updateCharTypeBox();
		};

		girlfriendCheckbox = new FlxUICheckBox(boyfriendCheckbox.x, boyfriendCheckbox.y + 40, null, null, "Girlfriend", 100);
		girlfriendCheckbox.callback = function()
		{
			curTypeSelected = 2;
			updateCharTypeBox();
		};

		tab_group.add(opponentCheckbox);
		tab_group.add(boyfriendCheckbox);
		tab_group.add(girlfriendCheckbox);
		UI_typebox.addGroup(tab_group);
	}

	var imageInputText:FlxUIInputText;
	var idleInputText:FlxUIInputText;
	var confirmInputText:FlxUIInputText;
	var scaleStepper:FlxUINumericStepper;
	var flipXCheckbox:FlxUICheckBox;
	function addCharacterUI() {
		var tab_group = new FlxUI(null, UI_mainbox);
		tab_group.name = "Character";
		
		imageInputText = new FlxUIInputText(10, 20, 80, characterFile.image, 8);
		blockPressWhileTypingOn.push(imageInputText);
		idleInputText = new FlxUIInputText(10, imageInputText.y + 35, 100, characterFile.idle_anim, 8);
		blockPressWhileTypingOn.push(idleInputText);
		confirmInputText = new FlxUIInputText(10, idleInputText.y + 35, 100, characterFile.confirm_anim, 8);
		blockPressWhileTypingOn.push(confirmInputText);

		flipXCheckbox = new FlxUICheckBox(10, confirmInputText.y + 30, null, null, "Flip X", 100);
		flipXCheckbox.callback = function()
		{
			grpWeekCharacters.members[curTypeSelected].flipX = flipXCheckbox.checked;
			characterFile.flipX = flipXCheckbox.checked;
		};

		var reloadImageButton:FlxButton = new FlxButton(140, confirmInputText.y + 30, "Reload Char", function() {
			reloadSelectedCharacter();
		});
		
		scaleStepper = new FlxUINumericStepper(140, imageInputText.y, 0.05, 1, 0.1, 30, 2);

		var confirmDescText = new FlxText(10, confirmInputText.y - 18, 0, 'Start Press animation on the .XML:');
		tab_group.add(new FlxText(10, imageInputText.y - 18, 0, 'Image file name:'));
		tab_group.add(new FlxText(10, idleInputText.y - 18, 0, 'Idle animation on the .XML:'));
		tab_group.add(new FlxText(scaleStepper.x, scaleStepper.y - 18, 0, 'Scale:'));
		tab_group.add(flipXCheckbox);
		tab_group.add(reloadImageButton);
		tab_group.add(confirmDescText);
		tab_group.add(imageInputText);
		tab_group.add(idleInputText);
		tab_group.add(confirmInputText);
		tab_group.add(scaleStepper);
		UI_mainbox.addGroup(tab_group);
	}

	function updateCharTypeBox() {
		opponentCheckbox.checked = false;
		boyfriendCheckbox.checked = false;
		girlfriendCheckbox.checked = false;

		switch(curTypeSelected) {
			case 0:
				opponentCheckbox.checked = true;
			case 1:
				boyfriendCheckbox.checked = true;
			case 2:
				girlfriendCheckbox.checked = true;
		}

		updateCharacters();
	}

	function updateCharacters() {
		for (i in 0...3) {
			var char:MenuCharacter = grpWeekCharacters.members[i];
			char.alpha = 0.2;
			char.character = '';
			char.changeCharacter(defaultCharacters[i]);
		}
		reloadSelectedCharacter();
	}
	
	function reloadSelectedCharacter() {
		var char:MenuCharacter = grpWeekCharacters.members[curTypeSelected];

		char.alpha = 1;
		char.frames = Paths.getSparrowAtlas('menucharacters/' + characterFile.image);
		char.animation.addByPrefix('idle', characterFile.idle_anim, 24);
		if(curTypeSelected == 1) char.animation.addByPrefix('confirm', characterFile.confirm_anim, 24, false);
		char.flipX = (characterFile.flipX == true);

		char.scale.set(characterFile.scale, characterFile.scale);
		char.updateHitbox();
		char.animation.play('idle');
		updateOffset();
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Menu Character Editor", "Editting: " + characterFile.image);
		#end
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == imageInputText) {
				characterFile.image = imageInputText.text;
			} else if(sender == idleInputText) {
				characterFile.idle_anim = idleInputText.text;
			} else if(sender == confirmInputText) {
				characterFile.confirm_anim = confirmInputText.text;
			}
		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			if (sender == scaleStepper) {
				characterFile.scale = scaleStepper.value;
				reloadSelectedCharacter();
			}
		}
	}

	override function update(elapsed:Float) {
		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				ClientPrefs.toggleVolumeKeys(false);
				blockInput = true;

				if(FlxG.keys.justPressed.ENTER) inputText.hasFocus = false;
				break;
			}
		}

		if(!blockInput) {
			ClientPrefs.toggleVolumeKeys(true);
			if(FlxG.keys.justPressed.ESCAPE) {
				MusicBeatState.switchState(new states.editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}

			var shiftMult:Int = 1;
			if(FlxG.keys.pressed.SHIFT) shiftMult = 10;

			if(FlxG.keys.justPressed.LEFT) {
				characterFile.position[0] += shiftMult;
				updateOffset();
			}
			if(FlxG.keys.justPressed.RIGHT) {
				characterFile.position[0] -= shiftMult;
				updateOffset();
			}
			if(FlxG.keys.justPressed.UP) {
				characterFile.position[1] += shiftMult;
				updateOffset();
			}
			if(FlxG.keys.justPressed.DOWN) {
				characterFile.position[1] -= shiftMult;
				updateOffset();
			}

			if(FlxG.keys.justPressed.SPACE && curTypeSelected == 1) {
				grpWeekCharacters.members[curTypeSelected].animation.play('confirm', true);
			}
		}

		var char:MenuCharacter = grpWeekCharacters.members[1];
		if(char.animation.curAnim != null && char.animation.curAnim.name == 'confirm' && char.animation.curAnim.finished) {
			char.animation.play('idle', true);
		}

		super.update(elapsed);
	}

	function updateOffset() {
		var char:MenuCharacter = grpWeekCharacters.members[curTypeSelected];
		char.offset.set(characterFile.position[0], characterFile.position[1]);
		txtOffsets.text = '' + characterFile.position;
	}

	var _file:FileReference = null;
	function loadCharacter() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if(_file.__path != null) fullPath = _file.__path;

		if(fullPath != null) {
			var rawJson:String = File.getContent(fullPath);
			if(rawJson != null) {
				var loadedChar:MenuCharacterFile = cast Json.parse(rawJson);
				if(loadedChar.idle_anim != null && loadedChar.confirm_anim != null) //Make sure it's really a character
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					characterFile = loadedChar;
					reloadSelectedCharacter();
					imageInputText.text = characterFile.image;
					idleInputText.text = characterFile.image;
					confirmInputText.text = characterFile.image;
					scaleStepper.value = characterFile.scale;
					updateOffset();
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
		_file.removeEventListener(Event.SELECT, onLoadComplete);
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
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	function saveCharacter() {
		var data:String = haxe.Json.stringify(characterFile, "\t");
		if (data.length > 0)
		{
			var splittedImage:Array<String> = imageInputText.text.trim().split('_');
			var characterName:String = splittedImage[splittedImage.length-1].toLowerCase().replace(' ', '');

			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, characterName + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
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
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
}