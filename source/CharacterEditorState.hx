package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
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
import Character;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;

#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

/**
	*DEBUG MODE
 */
class CharacterEditorState extends MusicBeatState
{
	var char:Character;
	var textAnim:FlxText;
	var bgLayer:FlxTypedGroup<FlxSprite>;
	var charLayer:FlxTypedGroup<Character>;
	var dumbTexts:FlxTypedGroup<FlxText>;
	//var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	var UI_box:FlxUITabMenu;
	var UI_characterbox:FlxUITabMenu;

	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;

	var changeBGbutton:FlxButton;
	var leHealthIcon:HealthIcon;
	var characterList:Array<String> = [];

	var cameraFollowPointer:FlxSprite;
	var healthBarBG:FlxSprite;

	override function create()
	{
		FlxG.sound.music.stop();

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxCamera.defaultCameras = [camEditor];

		bgLayer = new FlxTypedGroup<FlxSprite>();
		add(bgLayer);
		charLayer = new FlxTypedGroup<Character>();
		add(charLayer);

		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);

		changeBGbutton = new FlxButton(FlxG.width - 360, 25, "", function()
		{
			onPixelBG = !onPixelBG;
			reloadBGs();
		});
		changeBGbutton.cameras = [camMenu];

		loadChar(!daAnim.startsWith('bf'), false);

		healthBarBG = new FlxSprite(30, FlxG.height - 75).loadGraphic(Paths.image('healthBar'));
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBarBG.cameras = [camHUD];

		leHealthIcon = new HealthIcon(char.healthIcon, false);
		leHealthIcon.y = FlxG.height - 150;
		add(leHealthIcon);
		leHealthIcon.cameras = [camHUD];

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];

		textAnim = new FlxText(300, 16);
		textAnim.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textAnim.borderSize = 1;
		textAnim.size = 32;
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
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
		tipText.cameras = [camHUD];
		tipText.scrollFactor.set();
		tipText.color = FlxColor.RED;
		tipText.x -= tipText.width;
		tipText.y -= tipText.height;
		add(tipText);

		FlxG.camera.follow(camFollow);

		var tabs = [
			//{name: 'Offsets', label: 'Offsets'},
			{name: 'Settings', label: 'Settings'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camMenu];

		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		var tabs = [
			{name: 'Character', label: 'Character'},
			{name: 'Animations', label: 'Animations'},
		];
		UI_characterbox = new FlxUITabMenu(null, tabs, true);
		UI_characterbox.cameras = [camMenu];

		UI_characterbox.resize(350, 250);
		UI_characterbox.x = UI_box.x - 100;
		UI_characterbox.y = UI_box.y + UI_box.height;
		UI_characterbox.scrollFactor.set();
		add(UI_characterbox);
		add(UI_box);
		add(changeBGbutton);
		
		//addOffsetsUI();
		addSettingsUI();

		addCharacterUI();
		addAnimationsUI();
		UI_characterbox.selected_tab_id = 'Character';

		FlxG.mouse.visible = true;
		reloadCharacterOptions();

		super.create();
	}

	var onPixelBG:Bool = false;
	var OFFSET_X:Float = 300;
	function reloadBGs() {
		bgLayer.clear();
		var playerXDifference = 0;
		if(char.isPlayer) playerXDifference = 670;

		if(onPixelBG) {
			var playerYDifference:Float = 0;
			if(char.isPlayer) {
				playerXDifference += 200;
				playerYDifference = 220;
			}

			var bgSky:BGSprite = new BGSprite('weeb/weebSky', OFFSET_X - (playerXDifference / 2) - 300, 0 - playerYDifference, 0.1, 0.1);
			bgLayer.add(bgSky);
			bgSky.antialiasing = false;

			var repositionShit = -200 + OFFSET_X - playerXDifference;

			var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, -playerYDifference + 6, 0.6, 0.90);
			bgLayer.add(bgSchool);
			bgSchool.antialiasing = false;

			var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, -playerYDifference, 0.95, 0.95);
			bgLayer.add(bgStreet);
			bgStreet.antialiasing = false;

			var widShit = Std.int(bgSky.width * 6);
			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800 - playerYDifference);
			bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			bgLayer.add(bgTrees);
			bgTrees.antialiasing = false;

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));

			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			changeBGbutton.text = "Regular BG";
		} else {
			var bg:BGSprite = new BGSprite('stageback', -600 + OFFSET_X - playerXDifference, -300, 0.9, 0.9);
			bgLayer.add(bg);

			var stageFront:BGSprite = new BGSprite('stagefront', -650 + OFFSET_X - playerXDifference, 500, 0.9, 0.9);
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			bgLayer.add(stageFront);
			changeBGbutton.text = "Pixel BG";
		}
	}

	/*var animationInputText:FlxUIInputText;
	function addOffsetsUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Offsets";

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
	}*/

	var charDropDown:FlxUIDropDownMenuCustom;
	function addSettingsUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Settings";

		var check_player = new FlxUICheckBox(10, 60, null, null, "Playable Character", 100);
		check_player.checked = daAnim.startsWith('bf');
		check_player.callback = function()
		{
			char.isPlayer = !char.isPlayer;
			char.flipX = !char.flipX;
			updatePointerPos();
			reloadBGs();
		};

		charDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(character:String)
		{
			daAnim = characterList[Std.parseInt(character)];
			check_player.checked = daAnim.startsWith('bf');
			loadChar(!check_player.checked);
			updatePresence();
			reloadCharacterDropDown();
		});
		charDropDown.selectedLabel = daAnim;
		reloadCharacterDropDown();

		var reloadCharacter:FlxButton = new FlxButton(140, 30, "Reload Char", function()
		{
			loadChar(!check_player.checked);
			reloadCharacterDropDown();
		});
		
		tab_group.add(new FlxText(charDropDown.x, charDropDown.y - 18, 0, 'Character:'));
		tab_group.add(check_player);
		tab_group.add(reloadCharacter);
		tab_group.add(charDropDown);
		tab_group.add(reloadCharacter);
		UI_box.addGroup(tab_group);
	}
	
	var imageInputText:FlxUIInputText;
	var healthIconInputText:FlxUIInputText;

	var singDurationStepper:FlxUINumericStepper;
	var scaleStepper:FlxUINumericStepper;
	var positionXStepper:FlxUINumericStepper;
	var positionYStepper:FlxUINumericStepper;
	var positionCameraXStepper:FlxUINumericStepper;
	var positionCameraYStepper:FlxUINumericStepper;

	var flipXCheckBox:FlxUICheckBox;
	var noAntialiasingCheckBox:FlxUICheckBox;

	var healthColorStepperR:FlxUINumericStepper;
	var healthColorStepperG:FlxUINumericStepper;
	var healthColorStepperB:FlxUINumericStepper;

	function addCharacterUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Character";

		imageInputText = new FlxUIInputText(15, 30, 200, 'characters/BOYFRIEND', 8);
		var reloadImage:FlxButton = new FlxButton(imageInputText.x + 210, imageInputText.y - 3, "Reload Image", function()
		{
			char.imageFile = imageInputText.text;
			reloadCharacterImage();
			if(char.animation.curAnim != null) {
				char.playAnim(char.animation.curAnim.name, true);
			}
		});

		healthIconInputText = new FlxUIInputText(15, imageInputText.y + 35, 75, leHealthIcon.getCharacter(), 8);

		singDurationStepper = new FlxUINumericStepper(15, healthIconInputText.y + 45, 0.1, 4, 0, 999, 1);

		scaleStepper = new FlxUINumericStepper(15, singDurationStepper.y + 40, 0.1, 1, 0.1, 30, 1);

		flipXCheckBox = new FlxUICheckBox(singDurationStepper.x + 80, singDurationStepper.y, null, null, "Flip X", 50);
		flipXCheckBox.checked = char.flipX;
		if(char.isPlayer) flipXCheckBox.checked = !flipXCheckBox.checked;
		flipXCheckBox.callback = function() {
			char.originalFlipX = !char.originalFlipX;
			char.flipX = char.originalFlipX;
			if(char.isPlayer) char.flipX = !char.flipX;
		};

		noAntialiasingCheckBox = new FlxUICheckBox(flipXCheckBox.x, flipXCheckBox.y + 40, null, null, "No Antialiasing", 80);
		noAntialiasingCheckBox.checked = char.noAntialiasing;
		noAntialiasingCheckBox.callback = function() {
			char.antialiasing = false;
			if(!noAntialiasingCheckBox.checked && ClientPrefs.globalAntialiasing) {
				char.antialiasing = true;
			}
			char.noAntialiasing = noAntialiasingCheckBox.checked;
		};

		positionXStepper = new FlxUINumericStepper(flipXCheckBox.x + 110, flipXCheckBox.y, 10, char.positionArray[0], -9000, 9000, 0);
		positionYStepper = new FlxUINumericStepper(positionXStepper.x + 60, positionXStepper.y, 10, char.positionArray[1], -9000, 9000, 0);
		
		positionCameraXStepper = new FlxUINumericStepper(positionXStepper.x, positionXStepper.y + 40, 10, char.cameraPosition[0], -9000, 9000, 0);
		positionCameraYStepper = new FlxUINumericStepper(positionYStepper.x, positionYStepper.y + 40, 10, char.cameraPosition[1], -9000, 9000, 0);

		var saveCharacterButton:FlxButton = new FlxButton(reloadImage.x, noAntialiasingCheckBox.y + 40, "Save Character", function() {
			saveCharacter();
		});

		healthColorStepperR = new FlxUINumericStepper(singDurationStepper.x, saveCharacterButton.y, 20, char.healthColorArray[0], 0, 255, 0);
		healthColorStepperG = new FlxUINumericStepper(singDurationStepper.x + 65, saveCharacterButton.y, 20, char.healthColorArray[1], 0, 255, 0);
		healthColorStepperB = new FlxUINumericStepper(singDurationStepper.x + 130, saveCharacterButton.y, 20, char.healthColorArray[2], 0, 255, 0);

		tab_group.add(new FlxText(15, imageInputText.y - 18, 0, 'Image file name:'));
		tab_group.add(new FlxText(15, healthIconInputText.y - 18, 0, 'Health icon name:'));
		tab_group.add(new FlxText(15, singDurationStepper.y - 18, 0, 'Sing Animation length:'));
		tab_group.add(new FlxText(15, scaleStepper.y - 18, 0, 'Scale:'));
		tab_group.add(new FlxText(positionXStepper.x, positionXStepper.y - 18, 0, 'Character X/Y:'));
		tab_group.add(new FlxText(positionCameraXStepper.x, positionCameraXStepper.y - 18, 0, 'Camera X/Y:'));
		tab_group.add(new FlxText(healthColorStepperR.x, healthColorStepperR.y - 18, 0, 'Health bar R/G/B:'));
		tab_group.add(imageInputText);
		tab_group.add(reloadImage);
		tab_group.add(healthIconInputText);
		tab_group.add(singDurationStepper);
		tab_group.add(scaleStepper);
		tab_group.add(flipXCheckBox);
		tab_group.add(noAntialiasingCheckBox);
		tab_group.add(positionXStepper);
		tab_group.add(positionYStepper);
		tab_group.add(positionCameraXStepper);
		tab_group.add(positionCameraYStepper);
		tab_group.add(healthColorStepperR);
		tab_group.add(healthColorStepperG);
		tab_group.add(healthColorStepperB);
		tab_group.add(saveCharacterButton);
		UI_characterbox.addGroup(tab_group);
	}

	var animationDropDown:FlxUIDropDownMenuCustom;
	var animationInputText:FlxUIInputText;
	var animationNameInputText:FlxUIInputText;
	var animationIndicesInputText:FlxUIInputText;
	var animationNameFramerate:FlxUINumericStepper;
	var animationLoopCheckBox:FlxUICheckBox;
	function addAnimationsUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Animations";
		
		var anims:Array<String> = [];
		for (anim in char.animationsArray) {
			anims.push(anim.anim);
		}

		animationInputText = new FlxUIInputText(15, 85, 80, '', 8);
		animationNameInputText = new FlxUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		animationIndicesInputText = new FlxUIInputText(animationNameInputText.x, animationNameInputText.y + 40, 250, '', 8);
		animationNameFramerate = new FlxUINumericStepper(animationInputText.x + 170, animationInputText.y, 1, 24, 0, 240, 0);
		animationLoopCheckBox = new FlxUICheckBox(animationNameInputText.x + 170, animationNameInputText.y - 1, null, null, "Should it Loop?", 100);

		animationDropDown = new FlxUIDropDownMenuCustom(15, animationInputText.y - 55, FlxUIDropDownMenuCustom.makeStrIdLabelArray(anims, true), function(pressed:String) {
			var selectedAnimation:Int = Std.parseInt(pressed);
			for (anim in char.animationsArray) {
				if(char.animationsArray[selectedAnimation].anim == anim.anim) {
					animationInputText.text = anim.anim;
					animationNameInputText.text = anim.name;
					animationLoopCheckBox.checked = anim.loop;
					animationNameFramerate.value = anim.fps;

					var indicesStr:String = anim.indices.toString();
					animationIndicesInputText.text = indicesStr.substr(1, indicesStr.length - 2);
					break;
				}
			}
		});

		var addUpdateButton:FlxButton = new FlxButton(70, animationIndicesInputText.y + 30, "Add/Update", function() {
			var indices:Array<Int> = [];
			var indicesStr:Array<String> = animationIndicesInputText.text.trim().split(',');
			if(indicesStr.length > 1) {
				for (i in 0...indicesStr.length) {
					var index:Int = Std.parseInt(indicesStr[i]);
					if(indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1) {
						indices.push(index);
					}
				}
			}

			var lastAnim:String = '';
			if(char.animation.curAnim != null) {
				lastAnim = char.animation.curAnim.name;
			}

			var lastOffsets:Array<Int> = [0, 0];
			for (anim in char.animationsArray) {
				if(animationInputText.text == anim.anim) {
					lastOffsets = anim.offsets;
					if(char.animation.getByName(animationInputText.text) != null) {
						char.animation.remove(animationInputText.text);
					}
					char.animationsArray.remove(anim);
				}
			}

			var newAnim:AnimArray = {
				anim: animationInputText.text,
				name: animationNameInputText.text,
				fps: Math.round(animationNameFramerate.value),
				loop: animationLoopCheckBox.checked,
				indices: indices,
				offsets: lastOffsets
			};
			if(indices != null && indices.length > 0) {
				char.animation.addByIndices(newAnim.anim, newAnim.name, newAnim.indices, "", newAnim.fps, newAnim.loop);
			} else {
				char.animation.addByPrefix(newAnim.anim, newAnim.name, newAnim.fps, newAnim.loop);
			}
			
			if(!char.animOffsets.exists(newAnim.anim)) {
				char.addOffset(newAnim.anim, 0, 0);
			}
			char.animationsArray.push(newAnim);

			if(lastAnim == animationInputText.text) {
				char.playAnim(lastAnim, true);
			}

			reloadAnimationDropDown();
			genBoyOffsets();
			trace('Added/Updated animation: ' + animationInputText.text);
		});

		var removeButton:FlxButton = new FlxButton(180, animationIndicesInputText.y + 30, "Remove", function() {
			for (anim in char.animationsArray) {
				if(animationInputText.text == anim.anim) {
					var resetAnim:Bool = false;
					if(char.animation.curAnim != null && anim.anim == char.animation.curAnim.name) resetAnim = true;

					if(char.animation.getByName(anim.anim) != null) {
						char.animation.remove(anim.anim);
					}
					if(char.animOffsets.exists(anim.anim)) {
						char.animOffsets.remove(anim.anim);
					}
					char.animationsArray.remove(anim);

					if(resetAnim && char.animationsArray.length > 0) {
						char.playAnim(char.animationsArray[0].anim, true);
					}
					reloadAnimationDropDown();
					genBoyOffsets();
					trace('Removed animation: ' + animationInputText.text);
					break;
				}
			}
		});

		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
		tab_group.add(new FlxText(animationNameFramerate.x, animationNameFramerate.y - 18, 0, 'Framerate:'));
		tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 0, 'Animation on .XML/.TXT file:'));
		tab_group.add(new FlxText(animationIndicesInputText.x, animationIndicesInputText.y - 18, 0, 'ADVANCED - Animation Indices:'));

		tab_group.add(animationInputText);
		tab_group.add(animationNameInputText);
		tab_group.add(animationIndicesInputText);
		tab_group.add(animationNameFramerate);
		tab_group.add(animationLoopCheckBox);
		tab_group.add(addUpdateButton);
		tab_group.add(removeButton);
		tab_group.add(animationDropDown);
		UI_characterbox.addGroup(tab_group);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == healthIconInputText) {
				leHealthIcon.changeIcon(healthIconInputText.text);
				char.healthIcon = healthIconInputText.text;
				updatePresence();
			}
			else if(sender == imageInputText) {
				char.imageFile = imageInputText.text;
			}
		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			if (sender == scaleStepper)
			{
				reloadCharacterImage();
				char.jsonScale = sender.value;
				char.setGraphicSize(Std.int(char.width * char.jsonScale));
				char.updateHitbox();
				updatePointerPos();

				if(char.animation.curAnim != null) {
					char.playAnim(char.animation.curAnim.name, true);
				}
			}
			else if(sender == positionXStepper)
			{
				char.positionArray[0] = positionXStepper.value;
				char.x = char.positionArray[0] + OFFSET_X + 100;
				updatePointerPos();
			}
			else if(sender == positionYStepper)
			{
				char.positionArray[1] = positionYStepper.value;
				char.y = char.positionArray[1];
				updatePointerPos();
			}
			else if(sender == positionCameraXStepper)
			{
				char.cameraPosition[0] = positionCameraXStepper.value;
				updatePointerPos();
			}
			else if(sender == positionCameraYStepper)
			{
				char.cameraPosition[1] = positionCameraYStepper.value;
				updatePointerPos();
			}
			else if(sender == healthColorStepperR)
			{
				char.healthColorArray[0] = Math.round(healthColorStepperR.value);
				healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
			}
			else if(sender == healthColorStepperG)
			{
				char.healthColorArray[1] = Math.round(healthColorStepperG.value);
				healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
			}
			else if(sender == healthColorStepperB)
			{
				char.healthColorArray[2] = Math.round(healthColorStepperB.value);
				healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
			}
		}
	}

	function reloadCharacterImage() {
		var lastAnim:String = '';
		if(char.animation.curAnim != null) {
			lastAnim = char.animation.curAnim.name;
		}

		var anims:Array<AnimArray> = char.animationsArray.copy();
		if(Paths.fileExists('images/' + char.imageFile + '.txt', TEXT)) {
			char.frames = Paths.getPackerAtlas(char.imageFile);
		} else {
			char.frames = Paths.getSparrowAtlas(char.imageFile);
		}

		if(char.animationsArray != null && char.animationsArray.length > 0) {
			for (anim in char.animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;
				if(animIndices != null && animIndices.length > 0) {
					char.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				} else {
					char.animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
			}
		} else {
			char.quickAnimAdd('idle', 'BF idle dance');
		}
		
		if(lastAnim != '') {
			char.playAnim(lastAnim, true);
		} else {
			char.dance();
		}
	}

	function genBoyOffsets():Void
	{
		var daLoop:Int = 0;

		dumbTexts.clear();

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);
			text.cameras = [camHUD];

			daLoop++;
		}

		textAnim.visible = true;
		if(dumbTexts.length < 1) {
			var text:FlxText = new FlxText(10, 38, 0, "ERROR! No animations found.", 15);
			text.scrollFactor.set();
			text.color = FlxColor.RED;
			dumbTexts.add(text);
			textAnim.visible = false;
		}
	}

	function loadChar(isDad:Bool, blahBlahBlah:Bool = true) {
		charLayer.clear();
		char = new Character(0, 0, daAnim, !isDad);
		char.screenCenter();
		char.debugMode = true;
		charLayer.add(char);
		char.setPosition(char.positionArray[0] + OFFSET_X + 100, char.positionArray[1]);

		/* THIS FUNCTION WAS USED TO PUT THE .TXT OFFSETS INTO THE .JSON

		for (anim => offset in char.animOffsets) {
			var leAnim:AnimArray = findAnimationByName(anim);
			if(leAnim != null) {
				leAnim.offsets = [offset[0], offset[1]];
			}
		}*/

		if(blahBlahBlah) {
			genBoyOffsets();
		}
		reloadCharacterOptions();
		reloadBGs();
		updatePointerPos();
	}

	function updatePointerPos() {
		var x:Float = char.getMidpoint().x;
		var y:Float = char.getMidpoint().y;
		if(!char.isPlayer) {
			x += 150 + char.cameraPosition[0];
		} else {
			x -= 100 + char.cameraPosition[0];
		}
		y -= 100 - char.cameraPosition[1];

		x -= cameraFollowPointer.width / 2;
		y -= cameraFollowPointer.height / 2;
		cameraFollowPointer.setPosition(x, y);
	}

	function findAnimationByName(name:String):AnimArray {
		for (anim in char.animationsArray) {
			if(anim.anim == name) {
				return anim;
			}
		}
		return null;
	}

	function reloadCharacterOptions() {
		if(UI_characterbox != null) {
			imageInputText.text = char.imageFile;
			healthIconInputText.text = char.healthIcon;
			singDurationStepper.value = char.singDuration;
			scaleStepper.value = char.jsonScale;
			flipXCheckBox.checked = char.originalFlipX;
			noAntialiasingCheckBox.checked = char.noAntialiasing;
			resetHealthBarColor();
			leHealthIcon.changeIcon(healthIconInputText.text);
			positionXStepper.value = char.positionArray[0];
			positionYStepper.value = char.positionArray[1];
			positionCameraXStepper.value = char.cameraPosition[0];
			positionCameraYStepper.value = char.cameraPosition[1];
			reloadAnimationDropDown();
			updatePresence();
		}
	}

	function reloadAnimationDropDown() {
		var anims:Array<String> = [];
		for (anim in char.animationsArray) {
			anims.push(anim.anim);
		}
		if(anims.length < 1) anims.push(''); //Prevents crash

		animationDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(anims, true));
	}

	function reloadCharacterDropDown() {
		var charsLoaded:Map<String, Bool> = new Map();

		#if MODS_ALLOWED
		characterList = [];
		var directories:Array<String> = [Paths.mods('characters/'), Paths.getPreloadPath('characters/')];
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var charToCheck:String = file.substr(0, file.length - 5);
						if(!charsLoaded.exists(charToCheck)) {
							characterList.push(charToCheck);
							charsLoaded.set(charToCheck, true);
						}
					}
				}
			}
		}
		#else
		characterList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#end

		charDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true));
		charDropDown.selectedLabel = daAnim;
	}

	function resetHealthBarColor() {
		healthColorStepperR.value = char.healthColorArray[0];
		healthColorStepperG.value = char.healthColorArray[1];
		healthColorStepperB.value = char.healthColorArray[2];
		healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
	}

	function updatePresence() {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Character Editor", "Character: " + daAnim, leHealthIcon.getCharacter());
		#end
	}

	override function update(elapsed:Float)
	{
		if(char.animation.curAnim != null) {
			textAnim.text = char.animation.curAnim.name;
		} else {
			textAnim.text = '';
		}

		var inputTexts:Array<FlxUIInputText> = [animationInputText, imageInputText, healthIconInputText, animationNameInputText, animationIndicesInputText];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && lime.system.Clipboard.text != null) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

		if(!charDropDown.dropPanel.visible) {
			if (FlxG.keys.justPressed.ESCAPE) {
				MusicBeatState.switchState(new PlayState());
				FlxG.mouse.visible = false;
				return;
			}

			if (FlxG.keys.pressed.E && FlxG.camera.zoom < 5) {
				FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
				if(FlxG.camera.zoom > 5) FlxG.camera.zoom = 5;
			}
			if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) {
				FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
				if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
			}

			if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 4;

				if (FlxG.keys.pressed.I)
					camFollow.velocity.y = -90 * shiftMult;
				else if (FlxG.keys.pressed.K)
					camFollow.velocity.y = 90 * shiftMult;
				else
					camFollow.velocity.y = 0;

				if (FlxG.keys.pressed.J)
					camFollow.velocity.x = -90 * shiftMult;
				else if (FlxG.keys.pressed.L)
					camFollow.velocity.x = 90 * shiftMult;
				else
					camFollow.velocity.x = 0;
			}
			else
			{
				camFollow.velocity.set();
			}

			if(char.animationsArray.length > 0) {
				if (FlxG.keys.justPressed.W)
				{
					curAnim -= 1;
				}

				if (FlxG.keys.justPressed.S)
				{
					curAnim += 1;
				}

				if (curAnim < 0)
					curAnim = char.animationsArray.length - 1;

				if (curAnim >= char.animationsArray.length)
					curAnim = 0;

				if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
				{
					char.playAnim(char.animationsArray[curAnim].anim, true);
					genBoyOffsets();
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
						char.animationsArray[curAnim].offsets[arrayVal] += negaMult * multiplier;
						char.addOffset(char.animationsArray[curAnim].anim, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);

						char.playAnim(char.animationsArray[curAnim].anim, false);
						genBoyOffsets();
					}
				}
			}
		}
		camMenu.zoom = FlxG.camera.zoom;
		super.update(elapsed);
	}

	var _file:FileReference;
	/*private function saveOffsets()
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
	}*/

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

	function saveCharacter() {
		var json = {
			"animations": char.animationsArray,
			"image": char.imageFile,
			"scale": char.jsonScale,
			"sing_duration": char.singDuration,
			"healthicon": char.healthIcon,
		
			"position":	char.positionArray,
			"camera_position": char.cameraPosition,
		
			"flip_x": char.originalFlipX,
			"no_antialiasing": char.noAntialiasing,
			"healthbar_colors": char.healthColorArray
		};

		var data:String = Json.stringify(json, "\t");

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, daAnim + ".json");
		}
	}

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + lime.system.Clipboard.text.replace('\n', '');
		return text;
	}
}
