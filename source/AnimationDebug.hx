package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;

using StringTools;

/**
	*DEBUG MODE
 */
class AnimationDebug extends FlxState
{
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	var UI_box:FlxUITabMenu;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Animation Debug", "Character: " + daAnim);
		#end
		FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		loadChar(!daAnim.startsWith('bf'), false);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textAnim.borderSize = 1;
		textAnim.size = 32;
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height - 5, 0,
			"ESC - Go back to the Game
			\nE/Q - Camera Zoom In/Out
			\nJKLI - Move Camera
			
			\nW/S - Previous/Next Animation
			\nSpace - Play Animation
			\nArrow Keys - Move Character Offset
			\nHold Shift to Move 10x faster\n", 15);
		tipText.scrollFactor.set();
		tipText.color = FlxColor.RED;
		tipText.x -= tipText.width;
		tipText.y -= tipText.height;
		add(tipText);

		FlxG.camera.follow(camFollow);

		var tabs = [
			{name: 'Animations', label: 'Animations'},
			{name: 'Character', label: 'Character'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 300;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);
		
		addAnimationsUI();
		addCharacterUI();

		FlxG.mouse.visible = true;

		super.create();
	}

	var animationInputText:FlxUIInputText;
	function addAnimationsUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Animations";

		animationInputText = new FlxUIInputText(15, 30, 100, 'idle', 8);
		
		var addButton:FlxButton = new FlxButton(animationInputText.x + animationInputText.width + 23, animationInputText.y - 2, "Add", function()
		{
			var theText:String = animationInputText.text;
			if(theText != '') {
				var alreadyExists:Bool = false;
				for (i in 0...animList.length) {
					if(animList[i] == theText) {
						alreadyExists = true;
						break;
					}
				}

				if(!alreadyExists) {
					char.animOffsets.set(theText, [0, 0]);
					animList.push(theText);
				}
			}
		});
			
		var removeButton:FlxButton = new FlxButton(animationInputText.x + animationInputText.width + 23, animationInputText.y + 20, "Remove", function()
		{
			var theText:String = animationInputText.text;
			if(theText != '') {
				for (i in 0...animList.length) {
					if(animList[i] == theText) {
						if(char.animOffsets.exists(theText)) {
							char.animOffsets.remove(theText);
						}

						animList.remove(theText);
						if(char.animation.curAnim.name == theText && animList.length > 0) {
							char.playAnim(animList[0], true);
						}
						break;
					}
				}
			}
		});
			
		var saveButton:FlxButton = new FlxButton(animationInputText.x, animationInputText.y + 35, "Save Offsets", function()
		{
			saveOffsets();
		});

		tab_group.add(new FlxText(10, animationInputText.y - 18, 0, 'Add/Remove Animation:'));
		tab_group.add(addButton);
		tab_group.add(removeButton);
		tab_group.add(saveButton);
		tab_group.add(animationInputText);
		UI_box.addGroup(tab_group);
	}

	var charDropDown:FlxUIDropDownMenuCustom;
	function addCharacterUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Character";

		var check_player = new FlxUICheckBox(10, 60, null, null, "Playable Character", 100);
		check_player.checked = daAnim.startsWith('bf');
		check_player.callback = function()
		{
			remove(char);
			loadChar(!check_player.checked);
		};

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		charDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			remove(char);
			daAnim = characters[Std.parseInt(character)];
			check_player.checked = daAnim.startsWith('bf');
			loadChar(!check_player.checked);
		});
		charDropDown.selectedLabel = daAnim;

		var reloadCharacter:FlxButton = new FlxButton(140, 30, "Reload Char", function()
		{
			remove(char);
			loadChar(!check_player.checked);
		});
		
		tab_group.add(new FlxText(charDropDown.x, charDropDown.y - 18, 0, 'Character:'));
		tab_group.add(check_player);
		tab_group.add(reloadCharacter);
		tab_group.add(charDropDown);
		UI_box.addGroup(tab_group);
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}

		if(dumbTexts.length < 1) {
			var text:FlxText = new FlxText(10, 38, 0, "ERROR! No animations found.", 15);
			text.scrollFactor.set();
			text.color = FlxColor.RED;
			dumbTexts.add(text);
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	function loadChar(isDad:Bool, blahBlahBlah:Bool = true) {
		char = new Character(0, 0, daAnim, !isDad);
		char.screenCenter();
		char.debugMode = true;
		add(char);

		if(blahBlahBlah) {
			animList = [];
			genBoyOffsets();
		}
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		if(animationInputText.hasFocus) {
			if(FlxG.keys.justPressed.ENTER) {
				animationInputText.hasFocus = false;
			}
		} else if(!charDropDown.dropPanel.visible) {
			if (FlxG.keys.justPressed.ESCAPE) {
				FlxG.switchState(new PlayState());
				FlxG.mouse.visible = false;
			}

			if (FlxG.keys.justPressed.E)
				FlxG.camera.zoom += 0.25;
			if (FlxG.keys.justPressed.Q)
				FlxG.camera.zoom -= 0.25;

			if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
			{
				if (FlxG.keys.pressed.I)
					camFollow.velocity.y = -90;
				else if (FlxG.keys.pressed.K)
					camFollow.velocity.y = 90;
				else
					camFollow.velocity.y = 0;

				if (FlxG.keys.pressed.J)
					camFollow.velocity.x = -90;
				else if (FlxG.keys.pressed.L)
					camFollow.velocity.x = 90;
				else
					camFollow.velocity.x = 0;
			}
			else
			{
				camFollow.velocity.set();
			}

			if(animList.length > 0) {
				if (FlxG.keys.justPressed.W)
				{
					curAnim -= 1;
				}

				if (FlxG.keys.justPressed.S)
				{
					curAnim += 1;
				}

				if (curAnim < 0)
					curAnim = animList.length - 1;

				if (curAnim >= animList.length)
					curAnim = 0;

				if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
				{
					char.playAnim(animList[curAnim], true);
				}

				var controlArray:Array<Bool> = [FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.UP, FlxG.keys.justPressed.DOWN];
				for (i in 0...controlArray.length) {
					if(controlArray[i]) {
						var holdShift = FlxG.keys.pressed.SHIFT;
						var multiplier = 1;
						if (holdShift)
							multiplier = 10;

						var arrayVal = 0;
						if(i > 1) arrayVal = 1;

						var negaMult:Int = 1;
						if(i % 2 == 1) negaMult = -1;
						char.animOffsets.get(animList[curAnim])[arrayVal] += negaMult * multiplier;

						char.playAnim(animList[curAnim], false);
					}
				}
			}
		}
		updateTexts();
		genBoyOffsets(false);

		super.update(elapsed);
	}

	var _file:FileReference;
	private function saveOffsets()
	{
		var data:String = '';
		for (anim => offsets in char.animOffsets) {
			data += anim + ' ' + offsets[0] + ' ' + offsets[1] + '\n';
		}

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, daAnim + "Offsets.txt");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved Character Offsets.");
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
		FlxG.log.error("Problem saving Character Offsets");
	}
}
