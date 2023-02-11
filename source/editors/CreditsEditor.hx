package editors;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

import flixel.FlxCamera;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import flash.net.FileFilter;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;

using StringTools;

class CreditsEditor extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	var camUI:FlxCamera;
	var UI_box:FlxUITabMenu;

	var text:String = "";

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		FlxG.mouse.visible = true;
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);
		FlxG.cameras.setDefaultDrawTarget(FlxG.camera, true);

		var tabs = [
			{name: "Credit", label: 'Credit'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camUI];
		UI_box.resize(260, 400);
		UI_box.x = 840;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);
		UI_box.selected_tab = 0;

		text =
		"W/S or Up/Down - Change selected item
		\nSpace - Get selected item data
		\nEnter - Apply changes
		\nDelete - Delete selected item
		\nR - Reset inputs
		";

		var tipTextArray:Array<String> = text.split('\n');
		for (i in 0...tipTextArray.length) {
			var tipText:FlxText = new FlxText(UI_box.x, UI_box.y + UI_box.height + 8, 0, tipTextArray[i], 14);
			tipText.y += i * 9;
			tipText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			tipText.borderSize = 1;
			tipText.scrollFactor.set();
			add(tipText);
			tipText.cameras = [camUI];
		}

		addCreditUI();

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			['Tittle'],
			['Person',	'',	'Informations go here...',	'',	'e1e1e1']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);
		descBox.cameras = [camUI];
		descText.cameras = [camUI];
	
		updateCreditObjects();

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		
		super.create();
	}

	function pushAtPos(pos:Int, data:Array<String>){
		var daStuff:Array<Array<String>> = [];
		for(i in 0...creditsStuff.length){
			if(i == pos){
				daStuff.push(data);
			}
			daStuff.push(creditsStuff[i]);
		}
		if(pos == creditsStuff.length){
			daStuff.push(data);
		}
		creditsStuff = daStuff;
	}

	function updateCreditObjects(){
		if(creditsStuff != null && creditsStuff.length > 0){
			for (i in 0...iconArray.length){
				iconArray[i].kill();
			}
			iconArray = [];
			for (option in grpOptions){
				option.kill();
			}
			grpOptions.clear();
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i - curSelected;

			optionText.ID = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var pathExists:Bool = Paths.fileExists('images/credits/' + creditsStuff[i][1] + '.png', IMAGE);
				var icon:AttachedSprite;
				if(pathExists) icon = new AttachedSprite('credits/' + creditsStuff[i][1]);
				else {
					icon = new AttachedSprite('credits/unknow'); // If icon didnt load it will load the unknow icon.
					if(creditsStuff[i][1] == null || creditsStuff[i][1] == '') icon = new AttachedSprite('credits/none');
				}

				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}
	}

	function addCredit(){		
		var daData:Array<String> = [];
		daData.push('Person');
		daData.push('');
		daData.push('Informations go here...');
		daData.push('');
		daData.push('e1e1e1');

		pushAtPos(curSelected + 1, daData);

		updateCreditObjects();
		changeSelection();
	}

	function addTittle(){
		var daData:Array<String> = [];
		daData.push('Tittle');
		pushAtPos(curSelected + 1, daData);

		if(tittleJump.checked){
			var daData:Array<String> = [];
			pushAtPos(curSelected + 1, daData);
		}

		updateCreditObjects();
		changeSelection();
	}

	function cleanInputs(){
		tittleInput.text = '';
		creditNameInput.text = '';
		iconInput.text = '';
		descInput.text = '';
		linkInput.text = '';
		colorInput.text = '';
		iconColor(iconInput.text);
	}
	function goToInputs(){
		if(curSelIsTittle){
			tittleInput.text = creditsStuff[curSelected][0];
		} else {
			creditNameInput.text = creditsStuff[curSelected][0];
			iconInput.text = creditsStuff[curSelected][1];
			descInput.text = creditsStuff[curSelected][2];
			linkInput.text = creditsStuff[curSelected][3];
			colorInput.text = creditsStuff[curSelected][4];
			iconColor(iconInput.text);
		}
	}

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	var tittleInput:FlxUIInputText;
	var tittleJump:FlxUICheckBox = null;

	var creditNameInput:FlxUIInputText;
	var iconInput:FlxUIInputText;
	var iconExistCheck:FlxSprite;
	var descInput:FlxUIInputText;
	var linkInput:FlxUIInputText;
	var colorInput:FlxUIInputText;
	var colorSquare:FlxSprite;
	function addCreditUI():Void
	{
		var yDist:Float = 20;
		tittleInput = new FlxUIInputText(60, 20, 180, '', 8);
		tittleJump = new FlxUICheckBox(20, tittleInput.y + yDist, null, null, 'Space betwen tittles', 180);
		if (FlxG.save.data.jumpTittle == null) FlxG.save.data.jumpTittle = true;
		tittleJump.checked = FlxG.save.data.jumpTittle;
		tittleJump.callback = function()
		{
			FlxG.save.data.jumpTittle = tittleJump.checked;
		};
		var tittleAdd:FlxButton = new FlxButton(20, tittleJump.y + yDist, "Add Tittle", function()
			{
				addTittle();
			});

		blockPressWhileTypingOn.push(tittleInput);

		creditNameInput = new FlxUIInputText(60, tittleInput.y + 100, 180, '', 8);
		iconInput = new FlxUIInputText(60, creditNameInput.y + yDist, 155, '', 8);
		iconExistCheck = new FlxSprite(iconInput.x + 165, iconInput.y).makeGraphic(15, 15, 0xFFFFFFFF);
		descInput = new FlxUIInputText(100, iconInput.y + yDist, 140, '', 8);
		linkInput = new FlxUIInputText(60, descInput.y + yDist, 180, '', 8);
		colorInput = new FlxUIInputText(60, linkInput.y + yDist, 70, '', 8);
		colorSquare = new FlxSprite(colorInput.x + 80, colorInput.y).makeGraphic(15, 15, 0xFFFFFFFF);
		var getIconColor:FlxButton = new FlxButton(colorSquare.x + 23, colorSquare.y - 2, "Get Icon Color", function()
			{
				var icon:String;
				if(iconInput.text != null && iconInput.text.length > 0) icon = iconInput.text;
				else icon = creditsStuff[curSelected][1];

				var daIcon:String;
				var pathExists:Bool = Paths.fileExists('images/credits/' + icon + '.png', IMAGE);
				if(pathExists) daIcon = 'credits/' + icon;
				else daIcon = 'credits/none';

				var iconSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(daIcon));				
				var daColor:String = StringTools.hex(CoolUtil.dominantColor(iconSprite)).substring(2, this.length);
				colorInput.text = daColor;

				iconSprite.kill();
			});
		var creditAdd:FlxButton = new FlxButton(20, colorInput.y + 25, "Add credit", function()
			{
				addCredit();
			});
		
		blockPressWhileTypingOn.push(creditNameInput);
		blockPressWhileTypingOn.push(iconInput);
		blockPressWhileTypingOn.push(linkInput);
		blockPressWhileTypingOn.push(descInput);
		blockPressWhileTypingOn.push(colorInput);
		
		var loadFile:FlxButton = new FlxButton(50, 320, "Load Credits", function()
			{
				loadCredits();
			});
		var saveFile:FlxButton = new FlxButton(loadFile.x + 90, loadFile.y, "Save Credits", function()
			{
				saveCredits();
			});
		var resetAll:FlxButton = new FlxButton(loadFile.x, loadFile.y - 25, "reset all", function()
			{
				creditsStuff = [
					['Tittle'],
					['Person',	'',	'Informations go here...',	'',	'e1e1e1']
				];
				updateCreditObjects();
				changeSelection();
			});
		resetAll.color = FlxColor.RED;
		resetAll.label.color = FlxColor.WHITE;

		var tab_group_credit = new FlxUI(null, UI_box);
		tab_group_credit.name = "Credit";

		tab_group_credit.add(tittleInput);
		tab_group_credit.add(new FlxText(tittleInput.x - 40, tittleInput.y, 0, 'Tittle:'));
		tab_group_credit.add(tittleJump);

		tab_group_credit.add(creditNameInput);
		tab_group_credit.add(iconInput);
		tab_group_credit.add(iconExistCheck);
		tab_group_credit.add(descInput);
		tab_group_credit.add(linkInput);
		tab_group_credit.add(colorInput);
		tab_group_credit.add(colorSquare);
		tab_group_credit.add(getIconColor);
		tab_group_credit.add(new FlxText(creditNameInput.x - 40, creditNameInput.y, 0, 'Name:'));
		tab_group_credit.add(new FlxText(iconInput.x - 40, iconInput.y, 0, 'Icon:'));
		tab_group_credit.add(new FlxText(descInput.x - 80, descInput.y, 0, 'Description:'));
		tab_group_credit.add(new FlxText(linkInput.x - 40, linkInput.y, 0, 'Link:'));
		tab_group_credit.add(new FlxText(colorInput.x - 40, colorInput.y, 0, 'Color:'));
		tab_group_credit.add(tittleAdd);
		tab_group_credit.add(creditAdd);

		tab_group_credit.add(loadFile);
		tab_group_credit.add(saveFile);
		tab_group_credit.add(resetAll);

		UI_box.addGroup(tab_group_credit);
		iconColor(iconInput.text);
	}

	function updateDaInfo(){
		if(curSelIsTittle){
			if(tittleInput.text != null && tittleInput.text.length > 0) creditsStuff[curSelected][0] = tittleInput.text;
			else creditsStuff[curSelected][0] = 'Tittle';
		} else {
			if(creditNameInput.text != null && creditNameInput.text.length > 0) creditsStuff[curSelected][0] = creditNameInput.text;
			else creditsStuff[curSelected][0] = 'Person';
	
			creditsStuff[curSelected][1] = iconInput.text;		
	
			if(descInput.text != null && descInput.text.length > 0) creditsStuff[curSelected][2] = descInput.text;
			else creditsStuff[curSelected][2] = 'Informations go here...';
	
			creditsStuff[curSelected][3] = linkInput.text;
			
			if(colorInput.text != null && colorInput.text.length > 0) creditsStuff[curSelected][4] = colorInput.text;
			else creditsStuff[curSelected][4] = 'e1e1e1';
		}
	}

	function deleteDaStuff(){
		var daStuff:Array<Array<String>> = [];
		for(i in 0...creditsStuff.length){
			if(!unselectableCheck(curSelected)){
				if(i != curSelected){
					daStuff.push(creditsStuff[i]);
				}
			} else {
				if(curSelected == 0) return; // you trying to delete the first tittle? why dont you edit it...

				var shit:Bool = true;
				if(nullCheck(curSelected - 1)){ // remove space betwen tittle's
					var u:Int = curSelected - 1;
					if(i == u) shit = false;
				}

				if(i != curSelected && shit){
					daStuff.push(creditsStuff[i]);
				}
			}
		}
		creditsStuff = daStuff;
		if(curSelected > (creditsStuff.length - 1)) curSelected = creditsStuff.length;
		do {
			curSelected -= 1;
		} while(nullCheck(curSelected));

		updateCreditObjects();
		changeSelection();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var daColor:Int;
		if(colorInput.text != null && colorInput.text.length > 0) daColor = Std.parseInt('0xFF' + colorInput.text);
		else daColor = Std.parseInt('0xFFe1e1e1');
		colorSquare.color = daColor;

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}		

		if(!quitting && !blockInput)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if(FlxG.keys.pressed.R){
					cleanInputs();
				}

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(FlxG.keys.justPressed.ENTER) {
				updateDaInfo();
				updateCreditObjects();
				changeSelection();
			}
			if(FlxG.keys.justPressed.SPACE) {
				goToInputs();
			}
			if(FlxG.keys.justPressed.DELETE) {
				deleteDaStuff();
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new editors.MasterEditorMenu());
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				item.x = 200;
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	var curSelIsTittle:Bool = false;
	function changeSelection(change:Int = 0)
	{
		if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(nullCheck(curSelected));
		curSelIsTittle = false;
		if(unselectableCheck(curSelected)) curSelIsTittle = true;

		var newColor:Int;
		if(unselectableCheck(curSelected)) newColor =  Std.parseInt('0xFFe1e1e1');
		else newColor =  getCurrentBGColor();

		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
		
		var bullShit:Int = 0;
		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!nullCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descBox.visible = !unselectableCheck(curSelected);	
		descText.visible = !unselectableCheck(curSelected);
		descText.text = creditsStuff[curSelected][2];

		if(change != 0){
			descText.y = FlxG.height - descText.height + offsetThing - 60;
			if(moveTween != null) moveTween.cancel();
			moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});
		}

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	function iconColor(text:String){
		var daColor:Int;
		if(text.length == 0){
			daColor = Std.parseInt('0xFFFFC31E');
		} else {
			var pathExists:Bool = Paths.fileExists('images/credits/' + text + '.png', IMAGE);
			if(!pathExists) daColor = Std.parseInt('0xFFFF004C');
			else daColor = Std.parseInt('0xFF00FF37');
		}
		iconExistCheck.color = daColor;
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
	private function nullCheck(num:Int):Bool {
		if(creditsStuff[num].length <= 1 && creditsStuff[num][0].length <= 0) return true;
		return false;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == iconInput) {
				iconColor(iconInput.text);
			}
		}
	}

	var _file:FileReference;
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

	function saveCredits() {
		var daStuff:Array<String> = [];
		for(i in 0...creditsStuff.length){
			daStuff.push(creditsStuff[i].join('::'));
		}

		var data:String = daStuff.join('\n');

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "credits.txt");
		}
	}

	function loadCredits() {
		var txtFilter:FileFilter = new FileFilter('TXT', 'txt');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([txtFilter]);
	}
	
	var loadError:Bool = false;
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
			var rawTxt:String = File.getContent(fullPath);
			if(rawTxt != null) {
				creditsStuff = [];
				var firstarray:Array<String> = rawTxt.split('\n');
				for(i in firstarray)
				{
					var arr:Array<String> = i.replace('\\n', '\n').split("::");
					creditsStuff.push(arr);
				}
				updateCreditObjects();
				
				return;
			}
		}
		loadError = true;
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
}