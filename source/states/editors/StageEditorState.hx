package states.editors;

import backend.StageData;
import backend.PsychCamera;
import objects.Character;
import psychlua.LuaUtils;

import flixel.FlxObject;
import flixel.addons.ui.*;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.ui.FlxButton;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import openfl.display.Sprite;

import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import psychlua.ModchartSprite;
import flash.net.FileFilter;

class StageEditorState extends MusicBeatState
{
	final minZoom = 0.1;
	final maxZoom = 2;

	var gf:Character;
	var dad:Character;
	var boyfriend:Character;
	var stageJson:StageFile;

	#if FLX_DEBUG
	var camGame:FlxCamera;
	#else
	var camGame:DebugCamera;
	#end
	public var camHUD:FlxCamera;

	var UI_stagebox:FlxUITabMenu;
	var UI_box:FlxUITabMenu;
	var stageSprites:Array<StageEditorMetaSprite> = [];
	public function new(stageToLoad:String = 'stage', cachedJson:StageFile = null)
	{
		lastLoadedStage = stageToLoad;
		stageJson = cachedJson;
		super();
	}

	var lastLoadedStage:String;
	var camFollow:FlxObject = new FlxObject(0, 0, 1, 1);

	var helpBg:FlxSprite;
	var helpTexts:FlxSpriteGroup;
	var posTxt:FlxText;
	var errorTxt:FlxText;

	var animationEditor:StageEditorAnimationSubstate;
	var unsavedProgress:Bool = false;
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if FLX_DEBUG
		camGame = initPsychCamera();
		#else
		camGame = new DebugCamera();
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		_psychCameraInitialized = true;
		#end

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		if(stageJson == null) stageJson = StageData.getStageFile(lastLoadedStage);
		FlxG.camera.follow(null, LOCKON, 0);

		loadJsonAssetDirectory();
		gf = new Character(0, 0, stageJson._editorMeta != null ? stageJson._editorMeta.gf : 'gf');
		gf.visible = !(stageJson.hide_girlfriend);
		gf.scrollFactor.set(0.95, 0.95);
		dad = new Character(0, 0, stageJson._editorMeta != null ? stageJson._editorMeta.dad : 'dad');
		boyfriend = new Character(0, 0, stageJson._editorMeta != null ? stageJson._editorMeta.boyfriend : 'bf', true);

		FlxG.camera.zoom = stageJson.defaultZoom;
		repositionGirlfriend();
		repositionDad();
		repositionBoyfriend();
		var point = focusOnTarget('boyfriend');
		FlxG.camera.scroll.set(point.x - FlxG.width/2, point.y - FlxG.height/2);

		screenUI();
		spriteCreatePopup();
		editorUI();
		
		add(camFollow);
		updateSpriteList();

		addHelpScreen();
		FlxG.mouse.visible = true;
		destroySubStates = false;
		animationEditor = new StageEditorAnimationSubstate();

		super.create();
	}

	function loadJsonAssetDirectory()
	{
		var directory:String = 'shared';
		var weekDir:String = stageJson.directory;
		if (weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);
	}

	var showSelectionQuad:Bool = true;
	function addHelpScreen()
	{
		#if FLX_DEBUG
		var btn = 'F3';
		#else
		var btn = 'F2';
		#end

		var str:String = '
		E/Q - Camera Zoom In/Out
		\nJ/K/L/I - Move Camera
		\nR - Reset Camera Zoom
		\nArrow Keys/Mouse & Right Click - Move Object
		\n
		\n ' + btn + ' - Toggle HUD
		\nF12 - Toggle Selection Rectangle
		\nHold Shift - Move Objects and Camera 4x faster
		\nHold Control - Move Objects pixel-by-pixel and Camera 4x slower';

		helpBg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		helpBg.scale.set(FlxG.width, FlxG.height);
		helpBg.updateHitbox();
		helpBg.alpha = 0.6;
		helpBg.cameras = [camHUD];
		helpBg.active = helpBg.visible = false;
		add(helpBg);

		var arr = str.split('\n');
		helpTexts = new FlxSpriteGroup();
		helpTexts.cameras = [camHUD];
		for (i in 0...arr.length)
		{
			if(arr[i].length < 2) continue;

			var helpText:FlxText = new FlxText(0, 0, 640, arr[i], 16);
			helpText.setFormat(null, 16, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
			helpText.borderColor = FlxColor.BLACK;
			helpText.scrollFactor.set();
			helpText.borderSize = 1;
			helpText.screenCenter();
			add(helpText);
			helpText.y += ((i - arr.length/2) * 16);
			helpText.active = false;
			helpTexts.add(helpText);
		}
		helpTexts.active = helpTexts.visible = false;
		add(helpTexts);
	}

	function updateSpriteList()
	{
		for (spr in stageSprites)
			if(spr != null && !StageData.reservedNames.contains(spr.type))
				spr.sprite = FlxDestroyUtil.destroy(spr.sprite);

		stageSprites = [];
		var list:Map<String, FlxSprite> = [];
		if(stageJson.objects != null && stageJson.objects.length > 0)
		{
			list = StageData.addObjectsToState(stageJson.objects, gf, dad, boyfriend, null, true);
			for (key => spr in list)
				stageSprites[spr.ID] = new StageEditorMetaSprite(stageJson.objects[spr.ID], spr);

			/*for (num => spr in stageSprites)
				trace('$num: ${spr.type}, ${spr.name}');*/
		}

		for (character in ['gf', 'dad', 'boyfriend'])
			if(!list.exists(character))
				stageSprites.push(new StageEditorMetaSprite({type: character}, Reflect.field(this, character)));

		updateSpriteListRadio();
	}

	var spriteListBg:FlxSprite;
	var spriteListTip:FlxText;
	var spriteListRadioGroup:FlxUIRadioGroup;
	var focusRadioGroup:FlxUIRadioGroup;

	var buttonMoveUp:FlxButton;
	var buttonMoveDown:FlxButton;
	var buttonCreate:FlxButton;
	var buttonDuplicate:FlxButton;
	var buttonDelete:FlxButton;
	function screenUI()
	{
		var lowQualityCheckbox:FlxUICheckBox = null;
		var highQualityCheckbox:FlxUICheckBox = null;
		function visibilityFilterUpdate()
		{
			curFilters = 0;
			if(lowQualityCheckbox.checked) curFilters |= LOW_QUALITY;
			if(highQualityCheckbox.checked) curFilters |= HIGH_QUALITY;
		}

		spriteListBg = new FlxSprite(25, 40).makeGraphic(1, 1, FlxColor.BLACK);
		spriteListBg.cameras = [camHUD];
		spriteListBg.alpha = 0.6;
		spriteListBg.scale.set(250, 200);
		spriteListBg.updateHitbox();
		
		var buttonX = spriteListBg.x + spriteListBg.width + 10;
		var buttonY = spriteListBg.y;
		buttonMoveUp = new FlxButton(buttonX, buttonY, 'Move Up', function()
		{
			var selected:Int = spriteListRadioGroup.selectedIndex;
			if(selected < 0) return;

			var selected:Int = spriteListRadioGroup.numRadios - selected - 1;
			var spr = stageSprites[selected];
			if(spr == null) return;

			var newSel:Int = Std.int(Math.min(stageSprites.length-1, selected + 1));
			stageSprites.remove(spr);
			stageSprites.insert(newSel, spr);

			updateSpriteListRadio();
		});
		buttonMoveUp.cameras = [camHUD];
		add(buttonMoveUp);

		buttonMoveDown = new FlxButton(buttonX, buttonY + 30, 'Move Down', function()
		{
			var selected:Int = spriteListRadioGroup.selectedIndex;
			if(selected < 0) return;

			var selected:Int = spriteListRadioGroup.numRadios - selected - 1;
			var spr = stageSprites[selected];
			if(spr == null) return;

			var newSel:Int = Std.int(Math.max(0, selected - 1));
			stageSprites.remove(spr);
			stageSprites.insert(newSel, spr);

			updateSpriteListRadio();
		});
		buttonMoveDown.cameras = [camHUD];
		add(buttonMoveDown);
		
		buttonCreate = new FlxButton(buttonX, buttonY + 60, 'New', function() createPopup.visible = createPopup.active = true);
		buttonCreate.cameras = [camHUD];
		buttonCreate.color = FlxColor.GREEN;
		buttonCreate.label.color = FlxColor.WHITE;
		add(buttonCreate);

		buttonDuplicate = new FlxButton(buttonX, buttonY + 90, 'Duplicate', function()
		{
			var selected:Int = spriteListRadioGroup.selectedIndex;
			if(selected < 0) return;

			var selected:Int = spriteListRadioGroup.numRadios - selected - 1;
			var spr = stageSprites[selected];
			if(spr == null || StageData.reservedNames.contains(spr.type)) return;

			var copiedSpr = new ModchartSprite();
			var copiedMeta:StageEditorMetaSprite = new StageEditorMetaSprite(null, copiedSpr);
			for (field in Reflect.fields(spr))
			{
				if(field == 'sprite') continue; //do NOT copy sprite or it might get messy

				try
				{
					var fld:Dynamic = Reflect.getProperty(spr, field);
					if(fld is Array)
					{
						var arr:Array<Dynamic> = fld;
						arr = arr.copy();
						if(arr != null)
						{
							for (k => v in arr)
							{
								var indices:Array<Int> = v.indices;
								if(indices != null) indices = indices.copy();
	
								var offs:Array<Int> = v.offsets;
								if(offs != null) offs = offs.copy();

								fld[k] = {
									anim: v.anim,
									name: v.name,
									fps: v.fps,
									loop: v.loop,
									indices: indices,
									offsets: offs
								}
							}
						}
						fld = arr;
					}

					Reflect.setProperty(copiedMeta, field, fld);
					//trace('success? $field');
				}
				catch(e:Dynamic)
				{
					//trace('failed: $field');
				}
			}

			for (num => anim in copiedMeta.animations)
			{
				if(anim.indices != null && anim.indices.length > 0)
					copiedSpr.animation.addByIndices(anim.anim, anim.name, anim.indices, '', anim.fps, anim.loop);
				else
					copiedSpr.animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

				if(anim.offsets != null && anim.offsets.length > 1)
					copiedSpr.addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);

				if(copiedSpr.animation.curAnim == null || copiedMeta.firstAnimation == anim.anim)
					copiedSpr.playAnim(anim.anim, true);
			}
			copiedMeta.setScale(copiedMeta.scale[0], copiedMeta.scale[1]);
			copiedMeta.setScrollFactor(copiedMeta.scroll[0], copiedMeta.scroll[1]);
			copiedMeta.name = findUnoccupiedName('${copiedMeta.name}_copy');
			insertMeta(copiedMeta, 1);
		});
		buttonDuplicate.cameras = [camHUD];
		buttonDuplicate.color = FlxColor.BLUE;
		buttonDuplicate.label.color = FlxColor.WHITE;
		add(buttonDuplicate);
	
		buttonDelete = new FlxButton(buttonX, buttonY + 120, 'Delete', function()
		{
			var selected:Int = spriteListRadioGroup.selectedIndex;
			if(selected < 0) return;

			var selected:Int = spriteListRadioGroup.numRadios - selected - 1;
			var spr = stageSprites[selected];
			if(spr == null || StageData.reservedNames.contains(spr.type)) return;

			stageSprites.remove(spr);
			spr.sprite = FlxDestroyUtil.destroy(spr.sprite);

			updateSpriteListRadio();
		});
		buttonDelete.cameras = [camHUD];
		buttonDelete.color = FlxColor.RED;
		buttonDelete.label.color = FlxColor.WHITE;
		add(buttonDelete);
		
		spriteListTip = new FlxText(spriteListBg.x + spriteListBg.width/2 - 50, spriteListBg.y + 8, 100, 'Sprite List', 12);
		spriteListTip.alignment = CENTER;
		spriteListTip.cameras = [camHUD];
		spriteListTip.scrollFactor.set();
		spriteListTip.active = false;
		add(spriteListBg);
		add(spriteListTip);

		var bg:FlxSprite = new FlxSprite(0, FlxG.height - 60).makeGraphic(1, 1, FlxColor.BLACK);
		bg.cameras = [camHUD];
		bg.alpha = 0.4;
		bg.scale.set(FlxG.width, FlxG.height - bg.y);
		bg.updateHitbox();
		add(bg);
		
		var tipText:FlxText = new FlxText(0, FlxG.height - 44, 300, 'Press F1 for Help', 20);
		tipText.alignment = CENTER;
		tipText.cameras = [camHUD];
		tipText.scrollFactor.set();
		tipText.screenCenter(X);
		tipText.active = false;
		add(tipText);

		var targetTxt:FlxText = new FlxText(30, FlxG.height - 52, 300, 'Camera Target', 16);
		targetTxt.alignment = CENTER;
		targetTxt.cameras = [camHUD];
		targetTxt.scrollFactor.set();
		targetTxt.active = false;
		add(targetTxt);

		focusRadioGroup = new FlxUIRadioGroup(targetTxt.x, FlxG.height - 24, ['dad', 'boyfriend', 'gf'], ['Opponent', 'Boyfriend', 'Girlfriend'], function(target:String) {
			//trace('Changed focus to $target');
			var point = focusOnTarget(target);
			camFollow.setPosition(point.x, point.y);
			FlxG.camera.target = camFollow;
		}, 0, 200, 20, 200);

		for (id => check in focusRadioGroup.getRadios())
		{
			check.x += id * 100;
			check.textY -= 4;
			check.getLabel().size = 11;
		}
		
		focusRadioGroup.cameras = [camHUD];
		add(focusRadioGroup);

		lowQualityCheckbox = new FlxUICheckBox(FlxG.width - 240, FlxG.height - 36, null, null, 'Can see Low Quality Sprites?', 90);
		lowQualityCheckbox.cameras = [camHUD];
		lowQualityCheckbox.callback = visibilityFilterUpdate;
		lowQualityCheckbox.checked = false;
		add(lowQualityCheckbox);

		highQualityCheckbox = new FlxUICheckBox(FlxG.width - 120, FlxG.height - 36, null, null, 'Can see High Quality Sprites?', 90);
		highQualityCheckbox.cameras = [camHUD];
		highQualityCheckbox.callback = visibilityFilterUpdate;
		highQualityCheckbox.checked = true;
		add(highQualityCheckbox);
		visibilityFilterUpdate();

		posTxt = new FlxText(0, 50, 500, 'X: 0\nY: 0', 24);
		posTxt.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		posTxt.borderSize = 2;
		posTxt.cameras = [camHUD];
		posTxt.screenCenter(X);
		posTxt.visible = false;
		add(posTxt);

		errorTxt = new FlxText(0, 0, 800, '', 24);
		errorTxt.alignment = CENTER;
		errorTxt.borderStyle = OUTLINE_FAST;
		errorTxt.borderSize = 1;
		errorTxt.color = FlxColor.RED;
		errorTxt.cameras = [camHUD];
		errorTxt.screenCenter();
		errorTxt.alpha = 0;
		add(errorTxt);
	}

	function showError(txt:String)
	{
		errorTxt.text = txt;
		errorTime = 3;
	}

	var createPopup:FlxSpriteGroup;
	function findUnoccupiedName(prefix = 'sprite')
	{
		var num:Int = 1;
		var name:String = 'unnamed';
		while(true)
		{
			var cantUseName:Bool = false;
			
			name = prefix + num;
			for (basic in stageSprites)
			{
				if(basic.name == name)
				{
					cantUseName = true;
					break;
				}
			}
			
			if(cantUseName)
			{
				num++;
				continue;
			}
			break;
		}
		return name;
	}

	function insertMeta(meta, insertOffset:Int = 0)
	{
		var num:Int = Std.int(Math.max(0, Math.min(spriteListRadioGroup.numRadios, spriteListRadioGroup.numRadios - spriteListRadioGroup.selectedIndex - 1 + insertOffset)));
		stageSprites.insert(num, meta);
		updateSpriteListRadio();
		createPopup.visible = createPopup.active = false;
		spriteListRadioGroup.selectedIndex = spriteListRadioGroup.numRadios - num - 1;
		updateSelectedUI();
		unsavedProgress = true;
	}

	function spriteCreatePopup()
	{
		createPopup = new FlxSpriteGroup();
		createPopup.cameras = [camHUD];
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scale.set(300, 240);
		bg.updateHitbox();
		bg.screenCenter();
		createPopup.add(bg);

		var txt:FlxText = new FlxText(0, bg.y + 10, 180, 'New Sprite', 24);
		txt.screenCenter(X);
		txt.alignment = CENTER;
		createPopup.add(txt);

		var btnY = 320;
		var btn:FlxButton = new FlxButton(0, btnY, 'No Animation', function() loadImage('sprite'));
		btn.screenCenter(X);
		createPopup.add(btn);

		btnY += 50;
		var btn:FlxButton = new FlxButton(0, btnY, 'Animated', function() loadImage('animatedSprite'));
		btn.screenCenter(X);
		createPopup.add(btn);

		btnY += 50;
		var btn:FlxButton = new FlxButton(0, btnY, 'Solid Color', function() {
			var meta:StageEditorMetaSprite = new StageEditorMetaSprite({type: 'square', scale: [200, 200], name: findUnoccupiedName()}, new ModchartSprite());
			meta.sprite.makeGraphic(1, 1, FlxColor.WHITE);
			meta.sprite.scale.set(200, 200);
			meta.sprite.updateHitbox();
			meta.sprite.screenCenter();
			insertMeta(meta);
		});
		btn.screenCenter(X);
		createPopup.add(btn);
		add(createPopup);
		createPopup.visible = createPopup.active = false;
	}
	
	function updateSpriteListRadio()
	{
		var _sel:String = (spriteListRadioGroup != null ? spriteListRadioGroup.selectedId : null);
		var idList:Array<String> = [];
		var nameList:Array<String> = [];
		for (spr in stageSprites)
		{
			if(spr == null) continue;

			idList.push(spr.name != null ? spr.name : spr.type);
			switch(spr.type)
			{
				case 'gf':
					nameList.push('- Girlfriend -');
				case 'boyfriend':
					nameList.push('- Boyfriend -');
				case 'dad':
					nameList.push('- Opponent -');
				default:
					nameList.push(spr.name);
			}
		}
		//trace(idList);
		idList.reverse();
		nameList.reverse();
		
		final maxNum:Int = 18;

		if(spriteListRadioGroup != null) spriteListRadioGroup.destroy();
		spriteListRadioGroup = new FlxUIRadioGroup(spriteListBg.x + 10, spriteListBg.y + 30, idList, nameList, function(target:String) {
			trace('Selected sprite: $target');
			updateSelectedUI();
		}, 25, 200, 20, 200);
		spriteListRadioGroup.fixedSize = true;
		spriteListRadioGroup.height = 500;
		spriteListRadioGroup.cameras = [camHUD];
		spriteListRadioGroup.selectedIndex = -1;
		@:privateAccess
		spriteListRadioGroup._list.spacing = 12;
		spriteListRadioGroup.selectedId = _sel;
		insert(members.indexOf(spriteListBg) + 1, spriteListRadioGroup);

		/*if(idList.length > maxNum)
			trace('Too much options: ${idList.length}');*/

		spriteListBg.scale.y = Math.min(maxNum, idList.length) * 28 + 30;
		spriteListBg.updateHitbox();
	}

	function editorUI()
	{
		var tabs = [
			{name: 'Data', label: 'Data'},
			{name: 'Object', label: 'Object'},
			{name: 'Meta', label: 'Meta'},
		];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];

		UI_box.resize(200, 400);
		UI_box.x = FlxG.width - 225;
		UI_box.y = 10;
		UI_box.scrollFactor.set();
		add(UI_box);

		var tabs = [
			{name: 'Stage', label: 'Stage'},
		];
		UI_stagebox = new FlxUITabMenu(null, tabs, true);
		UI_stagebox.cameras = [camHUD];

		UI_stagebox.resize(250, 100);
		UI_stagebox.x = FlxG.width - 275;
		UI_stagebox.y = 25;
		UI_stagebox.scrollFactor.set();
		add(UI_stagebox);
		UI_box.y += UI_stagebox.y + UI_stagebox.height;

		addDataTab();
		addObjectTab();
		addMetaTab();
		addStageTab();
		UI_stagebox.selected_tab_id = 'Stage';
	}

	var directoryDropDown:FlxUIDropDownMenu;
	var focusCheck:Array<FlxUIInputText> = [];
	
	var uiInputText:FlxUIInputText;
	var hideGirlfriendCheckbox:FlxUICheckBox;
	var zoomStepper:FlxUINumericStepper;
	var cameraSpeedStepper:FlxUINumericStepper;
	var camDadStepperX:FlxUINumericStepper;
	var camDadStepperY:FlxUINumericStepper;
	var camGfStepperX:FlxUINumericStepper;
	var camGfStepperY:FlxUINumericStepper;
	var camBfStepperX:FlxUINumericStepper;
	var camBfStepperY:FlxUINumericStepper;

	function addDataTab()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = 'Data';

		var objX = 10;
		var objY = 20;
		tab_group.add(new FlxText(objX, objY - 18, 150, 'Compiled Assets:'));

		var folderList:Array<String> = [''];
		#if sys
		for (folder in FileSystem.readDirectory('assets/'))
			if(FileSystem.isDirectory('assets/$folder') && folder != 'shared' && !Mods.ignoreModFolders.contains(folder))
				folderList.push(folder);
		#end

		var saveButton:FlxButton = new FlxButton(UI_box.width - 90, UI_box.height - 50, 'Save', function() {
			saveData();
		});
		tab_group.add(saveButton);

		directoryDropDown = new FlxUIDropDownMenu(objX, objY, FlxUIDropDownMenu.makeStrIdLabelArray(folderList), function(selected:String) {
			stageJson.directory = selected;
			saveObjectsToJson();
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new StageEditorState(lastLoadedStage, stageJson));
		});
		directoryDropDown.selectedId = stageJson.directory;

		objY += 50;
		tab_group.add(new FlxText(objX, objY - 18, 100, 'UI Style:'));
		uiInputText = new FlxUIInputText(objX, objY, 100, stageJson.stageUI != null ? stageJson.stageUI : '', 8);
		uiInputText.params = [function() stageJson.stageUI = uiInputText.text];
		focusCheck.push(uiInputText);

		objY += 30;
		hideGirlfriendCheckbox = new FlxUICheckBox(objX, objY, null, null, 'Hide Girlfriend?', 100);
		hideGirlfriendCheckbox.callback = function()
		{
			stageJson.hide_girlfriend = hideGirlfriendCheckbox.checked;
			gf.visible = !hideGirlfriendCheckbox.checked;
			if(focusRadioGroup.selectedId != null)
			{
				var point = focusOnTarget(focusRadioGroup.selectedId);
				camFollow.setPosition(point.x, point.y);
			}
		};
		hideGirlfriendCheckbox.checked = !gf.visible;

		objY += 50;
		tab_group.add(new FlxText(objX, objY - 18, 100, 'Camera Offsets:'));

		objY += 20;
		tab_group.add(new FlxText(objX, objY - 18, 100, 'Opponent:'));

		var cx:Float = 0;
		var cy:Float = 0;
		if(stageJson.camera_opponent != null && stageJson.camera_opponent.length > 1)
		{
			cx = stageJson.camera_opponent[0];
			cy = stageJson.camera_opponent[0];
		}
		camDadStepperX = new FlxUINumericStepper(objX, objY, 50, cx, -10000, 10000, 0);
		camDadStepperY = new FlxUINumericStepper(objX + 80, objY, 50, cy, -10000, 10000, 0);
		camDadStepperX.params = camDadStepperY.params = [function() {
			if(stageJson.camera_opponent == null) stageJson.camera_opponent = [0, 0];
			stageJson.camera_opponent[0] = camDadStepperX.value;
			stageJson.camera_opponent[1] = camDadStepperY.value;
		}, 'update camera'];

		objY += 40;
		var cx:Float = 0;
		var cy:Float = 0;
		if(stageJson.camera_girlfriend != null && stageJson.camera_girlfriend.length > 1)
		{
			cx = stageJson.camera_girlfriend[0];
			cy = stageJson.camera_girlfriend[0];
		}
		tab_group.add(new FlxText(objX, objY - 18, 100, 'Girlfriend:'));
		camGfStepperX = new FlxUINumericStepper(objX, objY, 50, cx, -10000, 10000, 0);
		camGfStepperY = new FlxUINumericStepper(objX + 80, objY, 50, cy, -10000, 10000, 0);
		camGfStepperX.params = camGfStepperY.params = [function() {
			if(stageJson.camera_girlfriend == null) stageJson.camera_girlfriend = [0, 0];
			stageJson.camera_girlfriend[0] = camGfStepperX.value;
			stageJson.camera_girlfriend[1] = camGfStepperY.value;
		}, 'update camera'];

		objY += 40;
		var cx:Float = 0;
		var cy:Float = 0;
		if(stageJson.camera_boyfriend != null && stageJson.camera_boyfriend.length > 1)
		{
			cx = stageJson.camera_boyfriend[0];
			cy = stageJson.camera_boyfriend[0];
		}
		tab_group.add(new FlxText(objX, objY - 18, 100, 'Boyfriend:'));
		camBfStepperX = new FlxUINumericStepper(objX, objY, 50, cx, -10000, 10000, 0);
		camBfStepperY = new FlxUINumericStepper(objX + 80, objY, 50, cy, -10000, 10000, 0);
		camBfStepperX.params = camBfStepperY.params = [function() {
			if(stageJson.camera_boyfriend == null) stageJson.camera_boyfriend = [0, 0];
			stageJson.camera_boyfriend[0] = camBfStepperX.value;
			stageJson.camera_boyfriend[1] = camBfStepperY.value;
		}, 'update camera'];

		objY += 50;
		tab_group.add(new FlxText(objX, objY - 18, 100, 'Camera Data:'));
		objY += 20;
		tab_group.add(new FlxText(objX, objY - 18, 100, 'Zoom:'));
		zoomStepper = new FlxUINumericStepper(objX, objY, 0.05, stageJson.defaultZoom, minZoom, maxZoom, 2);
		zoomStepper.params = [function() {
			stageJson.defaultZoom = zoomStepper.value;
			FlxG.camera.zoom = stageJson.defaultZoom;
		}];

		tab_group.add(new FlxText(objX + 80, objY - 18, 100, 'Speed:'));
		cameraSpeedStepper = new FlxUINumericStepper(objX + 80, objY, 0.1, stageJson.camera_speed != null ? stageJson.camera_speed : 1, 0, 10, 2);
		cameraSpeedStepper.params = [function() {
			stageJson.camera_speed = cameraSpeedStepper.value;
			FlxG.camera.followLerp = 0.04 * stageJson.camera_speed;
		}];
		FlxG.camera.followLerp = 0.04 * cameraSpeedStepper.value;

		tab_group.add(hideGirlfriendCheckbox);
		tab_group.add(camDadStepperX);
		tab_group.add(camDadStepperY);
		tab_group.add(camGfStepperX);
		tab_group.add(camGfStepperY);
		tab_group.add(camBfStepperX);
		tab_group.add(camBfStepperY);
		tab_group.add(zoomStepper);
		tab_group.add(cameraSpeedStepper);
		
		tab_group.add(uiInputText);
		tab_group.add(directoryDropDown);
		UI_box.addGroup(tab_group);
	}

	var colorInputText:FlxUIInputText;
	var nameInputText:FlxUIInputText;
	var imgTxt:FlxText;

	var scaleStepperX:FlxUINumericStepper;
	var scaleStepperY:FlxUINumericStepper;
	var scrollStepperX:FlxUINumericStepper;
	var scrollStepperY:FlxUINumericStepper;
	var angleStepper:FlxUINumericStepper;
	var alphaStepper:FlxUINumericStepper;

	var antialiasingCheckbox:FlxUICheckBox;
	var flipXCheckBox:FlxUICheckBox;
	var flipYCheckBox:FlxUICheckBox;
	var lowQualityCheckbox:FlxUICheckBox;
	var highQualityCheckbox:FlxUICheckBox;

	function getSelected(blockReserved:Bool = true)
	{
		var selected:Int = spriteListRadioGroup.selectedIndex;
		if(selected >= 0)
		{
			var spr = stageSprites[spriteListRadioGroup.numRadios - selected - 1];
			if(spr != null && (!blockReserved || !StageData.reservedNames.contains(spr.type)))
				return spr;
		}
		return null;
	}

	function addObjectTab()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = 'Object';

		var objX = 10;
		var objY = 30;
		tab_group.add(new FlxText(objX, objY - 18, 150, 'Name (for Lua/HScript):'));
		nameInputText = new FlxUIInputText(objX, objY, 120, '', 8);
		nameInputText.customFilterPattern = ~/[^a-zA-Z0-9_\-]*/g;
		nameInputText.params = [function() {
			// change name
			var selected = getSelected();
			if(selected != null)
			{
				var changedName:String = nameInputText.text;
				if(changedName.length < 1)
				{
					showError('Sprite name cannot be empty!');
					return;
				}
				
				if(StageData.reservedNames.contains(changedName))
				{
					showError('To avoid conflicts, this name cannot be used!');
					return;
				}

				for (basic in stageSprites)
				{
					if (selected != basic && basic.name == changedName)
					{
						showError('Name "$changedName" is already in use!');
						return;
					}
				}

				selected.name = changedName;
				var radio = spriteListRadioGroup.getRadios()[spriteListRadioGroup.selectedIndex];
				radio.text = selected.name;
				errorTime = 0;
				errorTxt.alpha = 0;
			}
		}];
		focusCheck.push(nameInputText);
		tab_group.add(nameInputText);

		objY += 35;
		imgTxt = new FlxText(objX, objY - 15, 200, 'Image: ', 8);
		var imgButton:FlxButton = new FlxButton(objX, objY, 'Change Image', function() {
			trace('attempt to load image');
			loadImage();
		});
		tab_group.add(imgButton);
		tab_group.add(imgTxt);
		
		var animationsButton:FlxButton = new FlxButton(objX + 90, objY, 'Animations', function() {
			var selected = getSelected();
			if(selected == null)
				return;

			if(selected.type != 'animatedSprite')
			{
				showError('Only Animated Sprites can hold Animation data.');
				return;
			}

			persistentDraw = false;
			animationEditor.target = selected;
			unsavedProgress = true;
			openSubState(animationEditor);
		});
		tab_group.add(animationsButton);
		
		objY += 45;
		tab_group.add(new FlxText(objX, objY - 18, 80, 'Color:'));
		colorInputText = new FlxUIInputText(objX, objY, 80, 'FFFFFF', 8);
		colorInputText.filterMode = FlxInputText.ONLY_ALPHANUMERIC;
		colorInputText.params = [function() {
			// change color
			var selected = getSelected();
			if(selected != null)
				selected.color = colorInputText.text;
		}];
		focusCheck.push(colorInputText);
		tab_group.add(colorInputText);

		function updateScale()
		{
			// scale
			var selected = getSelected();
			if(selected != null)
				selected.setScale(scaleStepperX.value, scaleStepperY.value);
		}
		
		objY += 45;
		tab_group.add(new FlxText(objX, objY - 18, 100, 'Scale (X/Y):'));
		scaleStepperX = new FlxUINumericStepper(objX, objY, 0.05, 1, 0.05, 10, 2);
		scaleStepperY = new FlxUINumericStepper(objX + 70, objY, 0.05, 1, 0.05, 10, 2);
		scaleStepperX.params = scaleStepperY.params = [updateScale];
		tab_group.add(scaleStepperX);
		tab_group.add(scaleStepperY);

		function updateScroll()
		{
			// scroll factor
			var selected = getSelected();
			if(selected != null)
				selected.setScrollFactor(scrollStepperX.value, scrollStepperY.value);
		}

		objY += 40;
		tab_group.add(new FlxText(objX, objY - 18, 150, 'Scroll Factor (X/Y):'));
		scrollStepperX = new FlxUINumericStepper(objX, objY, 0.05, 1, 0, 10, 2);
		scrollStepperY = new FlxUINumericStepper(objX + 70, objY, 0.05, 1, 0, 10, 2);
		scrollStepperX.params = scrollStepperY.params = [updateScroll];
		tab_group.add(scrollStepperX);
		tab_group.add(scrollStepperY);
		
		objY += 40;
		tab_group.add(new FlxText(objX, objY - 18, 80, 'Opacity:'));
		alphaStepper = new FlxUINumericStepper(objX, objY, 0.1, 1, 0, 1, 2, FlxUINumericStepper.STACK_HORIZONTAL, null, null, null, true);
		alphaStepper.params = [function() {
			// alpha/opacity
			var selected = getSelected();
			if(selected != null)
				selected.alpha = alphaStepper.value;
		}];
		tab_group.add(alphaStepper);

		antialiasingCheckbox = new FlxUICheckBox(objX + 90, objY, null, null, 'Anti-Aliasing', 80);
		antialiasingCheckbox.callback = function()
		{
			// antialiasing
			var selected = getSelected();
			if(selected != null)
			{
				if(selected.type != 'square')
					selected.antialiasing = antialiasingCheckbox.checked;
				else
				{
					antialiasingCheckbox.checked = false;
					selected.antialiasing = false;
				}
			}
		};
		tab_group.add(antialiasingCheckbox);

		objY += 40;
		tab_group.add(new FlxText(objX, objY - 18, 80, 'Angle:'));
		angleStepper = new FlxUINumericStepper(objX, objY, 10, 0, 0, 360, 0);
		angleStepper.params = [function() {
			// alpha/opacity
			var selected = getSelected();
			if(selected != null)
				selected.angle = angleStepper.value;
		}];
		tab_group.add(angleStepper);

		function updateFlip()
		{
			//flip X and flip Y
			var selected = getSelected();
			if(selected != null)
			{
				if(selected.type != 'square')
				{
					selected.flipX = flipXCheckBox.checked;
					selected.flipY = flipYCheckBox.checked;
				}
				else
				{
					flipXCheckBox.checked = flipYCheckBox.checked = false;
					selected.flipX = selected.flipY = false;
				}
			}
		}

		objY += 25;
		flipXCheckBox = new FlxUICheckBox(objX, objY, null, null, 'Flip X', 60);
		flipXCheckBox.callback = updateFlip;
		flipYCheckBox = new FlxUICheckBox(objX + 90, objY, null, null, 'Flip Y', 60);
		flipYCheckBox.callback = updateFlip;
		tab_group.add(flipXCheckBox);
		tab_group.add(flipYCheckBox);

		objY += 45;
		function recalcFilter()
		{
			// low and/or high quality
			var selected = getSelected();
			if(selected != null)
			{
				var filt = 0;
				if(lowQualityCheckbox.checked) filt |= LOW_QUALITY;
				if(highQualityCheckbox.checked) filt |= HIGH_QUALITY;
				selected.filters = filt;
			}
		};
		tab_group.add(new FlxText(objX + 60, objY - 18, 100, 'Visible in:'));
		lowQualityCheckbox = new FlxUICheckBox(objX, objY, null, null, 'Low Quality', 70);
		highQualityCheckbox = new FlxUICheckBox(objX + 90, objY, null, null, 'High Quality', 70);
		lowQualityCheckbox.callback = recalcFilter;
		highQualityCheckbox.callback = recalcFilter;
		tab_group.add(lowQualityCheckbox);
		tab_group.add(highQualityCheckbox);
		UI_box.addGroup(tab_group);
	}

	var oppDropdown:FlxUIDropDownMenu;
	var gfDropdown:FlxUIDropDownMenu;
	var plDropdown:FlxUIDropDownMenu;
	function addMetaTab()
	{
		var tab_group = new FlxUI(null, UI_stagebox);
		tab_group.name = 'Meta';

		var characterList = Mods.mergeAllTextsNamed('data/characterList.txt');
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'characters/');
		for (folder in foldersToCheck)
			for (file in FileSystem.readDirectory(folder))
				if(file.toLowerCase().endsWith('.json'))
				{
					var charToCheck:String = file.substr(0, file.length - 5);
					if(!characterList.contains(charToCheck))
						characterList.push(charToCheck);
				}

		if(characterList.length < 1) characterList.push(''); //Prevents crash
		
		var objX = 10;
		var objY = 20;

		function setMetaData(data:String, char:String)
		{
			if(stageJson._editorMeta == null) stageJson._editorMeta = {dad: 'dad', gf: 'gf', boyfriend: 'bf'};
			Reflect.setField(stageJson._editorMeta, data, char);
		}

		oppDropdown = new FlxUIDropDownMenu(objX, objY, FlxUIDropDownMenu.makeStrIdLabelArray(characterList), function(selected:String)
		{
			dad.changeCharacter(selected);
			setMetaData('dad', selected);
			repositionDad();
		});
		oppDropdown.selectedId = dad.curCharacter;

		objY += 80;
		gfDropdown = new FlxUIDropDownMenu(objX, objY, FlxUIDropDownMenu.makeStrIdLabelArray(characterList), function(selected:String)
		{
			gf.changeCharacter(selected);
			setMetaData('gf', selected);
			repositionGirlfriend();
		});
		gfDropdown.selectedId = gf.curCharacter;

		objY += 80;
		plDropdown = new FlxUIDropDownMenu(objX, objY, FlxUIDropDownMenu.makeStrIdLabelArray(characterList), function(selected:String)
		{
			boyfriend.changeCharacter(selected);
			setMetaData('boyfriend', selected);
			repositionBoyfriend();
		});
		plDropdown.selectedId = boyfriend.curCharacter;

		tab_group.add(new FlxText(plDropdown.x, plDropdown.y - 18, 100, 'Player:'));
		tab_group.add(plDropdown);
		tab_group.add(new FlxText(gfDropdown.x, gfDropdown.y - 18, 100, 'Girlfriend:'));
		tab_group.add(gfDropdown);
		tab_group.add(new FlxText(oppDropdown.x, oppDropdown.y - 18, 100, 'Opponent:'));
		tab_group.add(oppDropdown);
		UI_box.addGroup(tab_group);
	}

	var stageDropDown:FlxUIDropDownMenu;
	function addStageTab()
	{
		var tab_group = new FlxUI(null, UI_stagebox);
		tab_group.name = 'Stage';

		var reloadStage:FlxButton = new FlxButton(140, 10, 'Reload', function()
		{
			stageJson = StageData.getStageFile(lastLoadedStage);
			updateSpriteList();
			updateStageDataUI();
			reloadCharacters();
			reloadStageDropDown();
		});

		var dummyStage:FlxButton = new FlxButton(140, 40, 'Load Template', function()
		{
			stageJson = StageData.dummy();
			updateSpriteList();
			updateStageDataUI();
			reloadCharacters();
		});
		dummyStage.color = FlxColor.RED;
		dummyStage.label.color = FlxColor.WHITE;

		stageDropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(selected:String)
		{
			var characterPath:String = 'stages/$selected.json';
			var path:String = Paths.getPath(characterPath, TEXT, null, true);
			#if MODS_ALLOWED
			if (FileSystem.exists(path))
			#else
			if (Assets.exists(path))
			#end
			{
				stageJson = StageData.getStageFile(selected);
				lastLoadedStage = selected;
				updateSpriteList();
				updateStageDataUI();
				reloadCharacters();
				reloadStageDropDown();
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadStageDropDown();
			}
		});
		reloadStageDropDown();

		tab_group.add(new FlxText(stageDropDown.x, stageDropDown.y - 18, 60, 'Stage:'));
		tab_group.add(reloadStage);
		tab_group.add(dummyStage);
		tab_group.add(stageDropDown);
		UI_stagebox.addGroup(tab_group);
	}
	
	function  updateStageDataUI()
	{
		//input texts
		uiInputText.text = (stageJson.stageUI != null ? stageJson.stageUI : '');
		//checkboxes
		hideGirlfriendCheckbox.checked = (stageJson.hide_girlfriend);
		gf.visible = !hideGirlfriendCheckbox.checked;
		//steppers
		zoomStepper.value = FlxG.camera.zoom = stageJson.defaultZoom;
		
		if(stageJson.camera_speed != null) cameraSpeedStepper.value = stageJson.camera_speed;
		else cameraSpeedStepper.value = 1;
		FlxG.camera.followLerp = 0.04 * cameraSpeedStepper.value;

		if(stageJson.camera_opponent != null && stageJson.camera_opponent.length > 1)
		{
			camDadStepperX.value = stageJson.camera_opponent[0];
			camDadStepperY.value = stageJson.camera_opponent[1];
		}
		else camDadStepperX.value = camDadStepperY.value = 0;

		if(stageJson.camera_girlfriend != null && stageJson.camera_girlfriend.length > 1)
		{
			camGfStepperX.value = stageJson.camera_girlfriend[0];
			camGfStepperY.value = stageJson.camera_girlfriend[1];
		}
		else camGfStepperX.value = camGfStepperY.value = 0;

		if(stageJson.camera_boyfriend != null && stageJson.camera_boyfriend.length > 1)
		{
			camBfStepperX.value = stageJson.camera_boyfriend[0];
			camBfStepperY.value = stageJson.camera_boyfriend[1];
		}
		else camBfStepperX.value = camBfStepperY.value = 0;

		if(focusRadioGroup.selectedId != null)
		{
			var point = focusOnTarget(focusRadioGroup.selectedId);
			camFollow.setPosition(point.x, point.y);
		}
		loadJsonAssetDirectory();
	}

	function updateSelectedUI()
	{
		posTxt.visible = false;
		var selected = getSelected(false);
		if(selected == null) return;

		var displayX:Float = Math.round(selected.x);
		var displayY:Float = Math.round(selected.y);
		
		var char:Character = cast selected.sprite;
		if(char != null)
		{
			displayX -= char.positionArray[0];
			displayY -= char.positionArray[1];
		}

		posTxt.text = 'X: $displayX\nY: $displayY';
		posTxt.visible = true;

		var selected = getSelected();
		if(selected == null) return;

		// Texts/Input Texts
		colorInputText.text = selected.color;
		nameInputText.text = selected.name;
		imgTxt.text = 'Image: ' + selected.image;

		// Steppers
		if (selected.type != 'square')
		{
			scaleStepperX.decimals = scaleStepperY.decimals = 2;
			scaleStepperX.max = scaleStepperY.max = 10;
			scaleStepperX.min = scaleStepperY.min = 0.05;
			scaleStepperX.stepSize = scaleStepperY.stepSize = 0.05;
		}
		else
		{
			scaleStepperX.decimals = scaleStepperY.decimals = 0;
			scaleStepperX.max = scaleStepperY.max = 10000;
			scaleStepperX.min = scaleStepperY.min = 50;
			scaleStepperX.stepSize = scaleStepperY.stepSize = 50;
		}
		scaleStepperX.value = selected.scale[0];
		scaleStepperY.value = selected.scale[1];
		scrollStepperX.value = selected.scroll[0];
		scrollStepperY.value = selected.scroll[1];
		angleStepper.value = selected.angle;
		alphaStepper.value = selected.alpha;

		// Checkboxes
		antialiasingCheckbox.checked = selected.antialiasing;
		flipXCheckBox.checked = selected.flipX;
		flipYCheckBox.checked = selected.flipY;
		lowQualityCheckbox.checked = (selected.filters & LOW_QUALITY) == LOW_QUALITY;
		highQualityCheckbox.checked = (selected.filters & HIGH_QUALITY) == HIGH_QUALITY;
	}

	function reloadCharacters()
	{
		if(stageJson._editorMeta != null)
		{
			gf.changeCharacter(stageJson._editorMeta.gf);
			dad.changeCharacter(stageJson._editorMeta.dad);
			boyfriend.changeCharacter(stageJson._editorMeta.boyfriend);
		}
		repositionGirlfriend();
		repositionDad();
		repositionBoyfriend();

		focusRadioGroup.selectedIndex = -1;
		FlxG.camera.target = null;
		var point = focusOnTarget('boyfriend');
		FlxG.camera.scroll.set(point.x - FlxG.width/2, point.y - FlxG.height/2);
		FlxG.camera.zoom = stageJson.defaultZoom;
		oppDropdown.selectedId = dad.curCharacter;
		gfDropdown.selectedId = gf.curCharacter;
		plDropdown.selectedId = boyfriend.curCharacter;
	}
	
	function reloadStageDropDown()
	{
		var stageList:Array<String> = [];
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'stages/');
		for (folder in foldersToCheck)
			for (file in FileSystem.readDirectory(folder))
				if(file.toLowerCase().endsWith('.json'))
				{
					var stageToCheck:String = file.substr(0, file.length - '.json'.length);
					if(!stageList.contains(stageToCheck))
						stageList.push(stageToCheck);
				}

		if(stageList.length < 1) stageList.push('');
		stageDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(stageList));
		stageDropDown.selectedLabel = lastLoadedStage;
		directoryDropDown.selectedId = stageJson.directory;
	}

	function checkUIOnObject()
	{
		if(UI_box.selected_tab_id == 'Object')
		{
			var selected:Int = spriteListRadioGroup.selectedIndex;
			if(selected >= 0)
			{
				var spr = stageSprites[spriteListRadioGroup.numRadios - selected - 1];
				if(spr != null && StageData.reservedNames.contains(spr.type))
					UI_box.selected_tab_id = 'Data';
			}
			else UI_box.selected_tab_id = 'Data';
		}
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		switch(id)
		{
			case FlxUIRadioGroup.CLICK_EVENT, FlxUITabMenu.CLICK_EVENT:
				if(sender == spriteListRadioGroup || sender == UI_box)
					checkUIOnObject();
				
			case FlxUICheckBox.CLICK_EVENT:
				unsavedProgress = true;

			case FlxUIInputText.CHANGE_EVENT, FlxUINumericStepper.CHANGE_EVENT:
				unsavedProgress = true;
				if(params[0] != null)
					params[0]();
				
				if(params[1] != null)
				{
					switch(params[1])
					{
						case 'update camera':
							if(focusRadioGroup.selectedId != null)
							{
								var point = focusOnTarget(focusRadioGroup.selectedId);
								camFollow.setPosition(point.x, point.y);
							}
					}
				}
		}
	}

	var errorTime:Float = 0;
	override function update(elapsed:Float)
	{
		if(createPopup.visible && (FlxG.mouse.justPressedRight || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(createPopup, camHUD))))
			createPopup.visible = createPopup.active = false;

		for (basic in stageSprites)
			basic.update(curFilters, elapsed);

		super.update(elapsed);
		
		errorTime = Math.max(0, errorTime - elapsed);
		errorTxt.alpha = errorTime;

		var canPress:Bool = true;
		for (txt in focusCheck)
			if(txt.hasFocus) canPress = false;

		if(!canPress) return;

		if(FlxG.keys.justPressed.ESCAPE)
		{
			if(!unsavedProgress)
			{
				MusicBeatState.switchState(new states.editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
			else openSubState(new ConfirmationPopupSubstate());
			return;
		}

		if(FlxG.keys.justPressed.W)
		{
			spriteListRadioGroup.selectedIndex = Math.floor(Math.max(0, spriteListRadioGroup.selectedIndex - 1));
			checkUIOnObject();
			updateSelectedUI();
		}
		else if(FlxG.keys.justPressed.S)
		{
			spriteListRadioGroup.selectedIndex = Math.floor(Math.min(stageSprites.length - 1, spriteListRadioGroup.selectedIndex + 1));
			checkUIOnObject();
			updateSelectedUI();
		}

		if(FlxG.keys.justPressed.F1 || (helpBg.visible && FlxG.keys.justPressed.ESCAPE))
		{
			helpBg.visible = !helpBg.visible;
			helpTexts.visible = helpBg.visible;
		}

		#if FLX_DEBUG
		if(FlxG.keys.justPressed.F3)
		#else
		if(FlxG.keys.justPressed.F2)
		#end
		{
			UI_box.visible = !UI_box.visible;
			UI_box.active = !UI_box.active;
			UI_box.selected_tab_id = UI_box.selected_tab_id;

			var objs = [UI_stagebox, spriteListRadioGroup, spriteListBg, spriteListTip, buttonMoveUp, buttonMoveDown, buttonCreate, buttonDuplicate, buttonDelete];
			for (obj in objs)
			{
				obj.visible = UI_box.visible;
				if(!(obj is FlxText)) obj.active = UI_box.active;
			}
		}
		
		if(FlxG.keys.justPressed.F12)
			showSelectionQuad = !showSelectionQuad;
		
		var shiftMult:Float = 1;
		var ctrlMult:Float = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 4;
		if(FlxG.keys.pressed.CONTROL) ctrlMult = 0.25;

		// CAMERA CONTROLS
		var camX:Float = 0;
		var camY:Float = 0;
		if (FlxG.keys.pressed.J) camX -= elapsed * 500 * shiftMult * ctrlMult;
		if (FlxG.keys.pressed.K) camY += elapsed * 500 * shiftMult * ctrlMult;
		if (FlxG.keys.pressed.L) camX += elapsed * 500 * shiftMult * ctrlMult;
		if (FlxG.keys.pressed.I) camY -= elapsed * 500 * shiftMult * ctrlMult;

		if(camX != 0 || camY != 0)
		{
			FlxG.camera.scroll.x += camX;
			FlxG.camera.scroll.y += camY;
			if(FlxG.camera.target != null) FlxG.camera.target = null;
			if(focusRadioGroup.selectedIndex > -1) focusRadioGroup.selectedIndex = -1;
		}

		var lastZoom = FlxG.camera.zoom;
		if(FlxG.keys.justPressed.R && !FlxG.keys.pressed.CONTROL)
			FlxG.camera.zoom = stageJson.defaultZoom;
		else if (FlxG.keys.pressed.E && FlxG.camera.zoom < maxZoom)
			FlxG.camera.zoom = Math.min(maxZoom, FlxG.camera.zoom + elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);
		else if (FlxG.keys.pressed.Q && FlxG.camera.zoom > minZoom)
			FlxG.camera.zoom = Math.max(minZoom, FlxG.camera.zoom - elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);
		
		// SPRITE X/Y
		var shiftMult:Float = 1;
		var ctrlMult:Float = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 4;
		if(FlxG.keys.pressed.CONTROL) ctrlMult = 0.2;

		var moveX:Float = 0;
		var moveY:Float = 0;
		if (FlxG.keys.justPressed.LEFT) moveX -= 5 * shiftMult * ctrlMult;
		if (FlxG.keys.justPressed.RIGHT) moveX += 5 * shiftMult * ctrlMult;
		if (FlxG.keys.justPressed.UP) moveY -= 5 * shiftMult * ctrlMult;
		if (FlxG.keys.justPressed.DOWN) moveY += 5 * shiftMult * ctrlMult;

		if(FlxG.mouse.pressedRight && (FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0))
		{
			moveX += FlxG.mouse.deltaScreenX * ctrlMult;
			moveY += FlxG.mouse.deltaScreenY * ctrlMult;
		}

		if(moveX != 0 || moveY != 0)
		{
			var selected:Int = spriteListRadioGroup.selectedIndex;
			if(selected < 0) return;

			var spr = stageSprites[spriteListRadioGroup.numRadios - selected - 1];
			if(spr != null)
			{
				var displayX:Float, displayY:Float;
				spr.x = displayX = Math.round(spr.x + moveX);
				spr.y = displayY = Math.round(spr.y + moveY);
				var char:Character = cast spr.sprite;
				switch(spr.type)
				{
					case 'boyfriend':
						stageJson.boyfriend[0] = displayX = spr.x - char.positionArray[0];
						stageJson.boyfriend[1] = displayY = spr.y - char.positionArray[1];
					case 'gf':
						stageJson.girlfriend[0] = displayX = spr.x - char.positionArray[0];
						stageJson.girlfriend[1] = displayY = spr.y - char.positionArray[1];
					case 'dad':
						stageJson.opponent[0] = displayX = spr.x - char.positionArray[0];
						stageJson.opponent[1] = displayY = spr.y - char.positionArray[1];
				}
				posTxt.text = 'X: $displayX\nY: $displayY';
			}
		}
	}

	var curFilters:LoadFilters = (LOW_QUALITY)|(HIGH_QUALITY);
	override function draw()
	{
		#if !FLX_DEBUG
		camGame.debugLayer.graphics.clear();
		#end

		if(persistentDraw || subState == null)
		{

			for (basic in stageSprites)
				if(basic.visible)
					basic.draw(curFilters);
	
			if(showSelectionQuad && spriteListRadioGroup.selectedId != null)
				drawDebugOnCamera(stageSprites[spriteListRadioGroup.numRadios - spriteListRadioGroup.selectedIndex - 1].sprite);
		}

		super.draw();
	}

	function focusOnTarget(target:String)
	{
		var focusPoint:FlxPoint = FlxPoint.weak(0, 0);
		switch(target)
		{
			case 'boyfriend':
				focusPoint.x += boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] - 100;
				focusPoint.y += boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] - 100;
				if(stageJson.camera_boyfriend != null && stageJson.camera_boyfriend.length > 1)
				{
					focusPoint.x += stageJson.camera_boyfriend[0];
					focusPoint.y += stageJson.camera_boyfriend[1];
				}
			case 'dad':
				focusPoint.x += dad.getMidpoint().x + dad.cameraPosition[0] + 150;
				focusPoint.y += dad.getMidpoint().y + dad.cameraPosition[1] - 100;
				if(stageJson.camera_opponent != null && stageJson.camera_opponent.length > 1)
				{
					focusPoint.x += stageJson.camera_opponent[0];
					focusPoint.y += stageJson.camera_opponent[1];
				}
			case 'gf':
				if(gf.visible)
				{
					focusPoint.x += gf.getMidpoint().x + gf.cameraPosition[0];
					focusPoint.y += gf.getMidpoint().y + gf.cameraPosition[1];
				}

				if(stageJson.camera_girlfriend != null && stageJson.camera_girlfriend.length > 1)
				{
					focusPoint.x += stageJson.camera_girlfriend[0];
					focusPoint.y += stageJson.camera_girlfriend[1];
				}
		}
		return focusPoint;
	}

	function repositionGirlfriend()
	{
		gf.setPosition(stageJson.girlfriend[0], stageJson.girlfriend[1]);
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
	}
	function repositionDad()
	{
		dad.setPosition(stageJson.opponent[0], stageJson.opponent[1]);
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
	}
	function repositionBoyfriend()
	{
		boyfriend.setPosition(stageJson.boyfriend[0], stageJson.boyfriend[1]);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
	}
	
	// borrowing from flixel
	public function drawDebugOnCamera(spr:FlxSprite):Void
	{
		if (!spr.isOnScreen(FlxG.camera))
			return;

		@:privateAccess
		var rect = spr.getBoundingBox(FlxG.camera);
		var gfx = camGame.debugLayer.graphics;
		gfx.lineStyle(3, FlxColor.LIME, 0.8);
		gfx.drawRect(rect.x, rect.y, rect.width, rect.height);
		gfx.endFill();
	}

	// save

	function saveObjectsToJson()
	{
		stageJson.objects = [];
		for (basic in stageSprites)
			stageJson.objects.push(basic.formatToJson());
	}

	function saveData()
	{
		if(_file != null) return;

		saveObjectsToJson();
		var data = haxe.Json.stringify(stageJson, '\t');
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, '$lastLoadedStage.json');
		}
	}

	var _file:FileReference;
	function onSaveComplete(_):Void
	{
		if(_file == null) return;
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice('Successfully saved file.');
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
	function onSaveCancel(_):Void
	{
		if(_file == null) return;
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
		if(_file == null) return;
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error('Problem saving file');
	}

	var _makeNewSprite = null;
	public function loadImage(onNewSprite:String = null) {
		if(_file != null) return;

		_makeNewSprite = onNewSprite;
		_file = new FileReference();
		_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		final filters = [new FileFilter('PNG (Image)', '*.png'), new FileFilter('XML (Sparrow)', '*.xml'), new FileFilter('JSON (Aseprite)', '*.json'), new FileFilter('TXT (Packer)', '*.txt')];
		_file.browse(filters);
	}
	
	private function onLoadComplete(_):Void
	{
		if(_file == null) return;
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if(_file.__path != null) fullPath = _file.__path;

		if(fullPath != null)
		{
			fullPath = fullPath.replace('\\', '/');
			var exePath = Sys.getCwd().replace('\\', '/');
			if(fullPath.startsWith(exePath + 'assets/images/') #if MODS_ALLOWED || (fullPath.startsWith(exePath + 'mods/') && fullPath.contains('/images/')) #end)
			{

				var imageToLoad:String = fullPath.substring(fullPath.indexOf('/images/') + '/images/'.length, fullPath.indexOf('.'));
				if(_makeNewSprite != null)
				{
					if(_makeNewSprite == 'animatedSprite' && !Paths.fileExists('images/$imageToLoad.xml', TEXT) &&
						!Paths.fileExists('images/$imageToLoad.json', TEXT) && !Paths.fileExists('images/$imageToLoad.txt', TEXT))
					{
						showError('No Animation file found with the same name of the image!');
						_makeNewSprite = null;
						_file = null;
						return;
					}
					insertMeta(new StageEditorMetaSprite({type: _makeNewSprite, name: findUnoccupiedName()}, new ModchartSprite()));
				}
				var selected = getSelected();
				tryLoadImage(selected, imageToLoad);
				
				if(_makeNewSprite != null)
				{
					selected.sprite.x = Math.round(FlxG.camera.scroll.x + FlxG.width/2 - selected.sprite.width/2);
					selected.sprite.y = Math.round(FlxG.camera.scroll.y + FlxG.height/2 - selected.sprite.height/2);
					posTxt.visible = true;
					posTxt.text = 'X: ${selected.sprite.x}\nY: ${selected.sprite.y}';
				}
				_makeNewSprite = null;
				//trace('Inside Psych Engine Folder');
			}
			else showError('Can\'t load files outside of "images/" folder');
			//TO DO: Maybe make copy of loaded file to an usable folder automatically? That would be very practical
			//TO DO: Bring this to Character Editor too
		}
		_file = null;
		#else
		trace('File couldn't be loaded! You aren't on Desktop, are you?');
		#end
	}

	function tryLoadImage(spr:StageEditorMetaSprite, imgPath:String)
	{
		if(spr == null || StageData.reservedNames.contains(spr.type) || spr.type == 'square' || imgPath == null) return;

		spr.image = imgPath;
		updateSelectedUI();
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
	private function onLoadCancel(_):Void
	{
		if(_file == null) return;
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		
		if(_makeNewSprite != null)
		{
			createPopup.visible = createPopup.active = false;
			_makeNewSprite = null;
		}
		trace('Cancelled file loading.');
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	private function onLoadError(_):Void
	{
		if(_file == null) return;
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;

		if(_makeNewSprite != null)
		{
			createPopup.visible = createPopup.active = false;
			_makeNewSprite = null;
		}
		trace('Problem loading file');
	}

	override function destroy()
	{
		destroySubStates = true;
		animationEditor.destroy();
		super.destroy();
	}
}

#if !FLX_DEBUG
class DebugCamera extends PsychCamera
{
	public var debugLayer:Sprite;
	public function new()
	{
		super();

		debugLayer = new Sprite();
		_scrollRect.addChild(debugLayer);
		updateInternalSpritePositions();
	}

	override function updateInternalSpritePositions()
	{
		super.updateInternalSpritePositions();
		
		if (canvas != null && debugLayer != null)
		{
			debugLayer.x = canvas.x;
			debugLayer.y = canvas.y;

			debugLayer.scaleX = totalScaleX;
			debugLayer.scaleY = totalScaleY;
		}
	}
	
	override function destroy()
	{
		FlxDestroyUtil.removeChild(_scrollRect, debugLayer);
		debugLayer = null;
		super.destroy();
	}
}
#end

class StageEditorMetaSprite
{
	public var sprite:FlxSprite;
	public var visible(get, set):Bool;
	function get_visible() return sprite.visible;
	function set_visible(v:Bool) return (sprite.visible = v);

	// basic variables for all types
	public var type:String;

	// variables for all types that aren't Character
	public var name:String;
	public var filters:LoadFilters = (LOW_QUALITY)|(HIGH_QUALITY);
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var alpha(get, set):Float;
	public var angle(get, set):Float;
	function get_x() return sprite.x;
	function set_x(v:Float) return (sprite.x = v);
	function get_y() return sprite.y;
	function set_y(v:Float) return (sprite.y = v);
	function get_alpha() return sprite.alpha;
	function set_alpha(v:Float) return (sprite.alpha = v);
	function get_angle() return sprite.angle;
	function set_angle(v:Float) return (sprite.angle = v);

	public var color(default, set):String = 'FFFFFF';
	function set_color(v:String)
	{
		sprite.color = CoolUtil.colorFromString(v);
		return (color = v);
	}
	public var image(default, set):String = 'unknown';
	function set_image(v:String)
	{
		try
		{
			switch(type)
			{
				case 'sprite':
					sprite.loadGraphic(Paths.image(v));
				case 'animatedSprite':
					sprite.frames = Paths.getAtlas(v);
			}
		}
		sprite.updateHitbox();
		return (image = v);
	}

	public var scroll:Array<Float> = [1, 1];
	public function setScrollFactor(scrX:Null<Float> = null, scrY:Null<Float> = null)
	{
		scroll[0] = (scrX != null ? scrX : scroll[0]);
		scroll[1] = (scrY != null ? scrY : scroll[1]);
		sprite.scrollFactor.set(scroll[0], scroll[1]);
	}

	public var scale:Array<Float> = [1, 1];
	public var antialiasing(default, set):Bool = true;
	function set_antialiasing(v:Bool)
	{
		sprite.antialiasing = (v && ClientPrefs.data.antialiasing);
		return (antialiasing = v);
	}

	public function setScale(wid:Null<Float> = null, hei:Null<Float> = null)
	{
		scale[0] = (wid != null ? wid : scale[0]);
		scale[1] = (hei != null ? hei : scale[1]);
		sprite.scale.set(scale[0], scale[1]);
		sprite.updateHitbox();
	}
	
	public var flipX(get, set):Bool;
	public var flipY(get, set):Bool;
	function get_flipX() return sprite.flipX;
	function set_flipX(v:Bool) return (sprite.flipX = (v && type != 'square'));
	function get_flipY() return sprite.flipY;
	function set_flipY(v:Bool) return (sprite.flipY = (v && type != 'square'));

	// "animatedSprite" only variables
	public var firstAnimation:String;
	public var animations:Array<AnimArray>;

	public function new(data:Dynamic, spr:FlxSprite)
	{
		this.sprite = spr;
		if(data == null) return;

		this.type = data.type;
		switch(this.type)
		{
			case 'sprite', 'square', 'animatedSprite':
				for (v in ['name', 'image', 'scale', 'scroll', 'color', 'filters', 'antialiasing'])
				{
					var dat:Dynamic = Reflect.field(data, v);
					if(dat != null) Reflect.setField(this, v, dat);
				}

				if(this.type == 'animatedSprite')
				{
					this.animations = data.animations;
					this.firstAnimation = data.firstAnimation;
				}
		}
	}

	public function formatToJson()
	{
		var obj:Dynamic = {type: type};
		switch(type)
		{
			case 'square', 'sprite', 'animatedSprite':
				obj.name = name;
				obj.x = x;
				obj.y = y;
				obj.scale = scale;
				obj.scroll = scroll;
				obj.alpha = alpha;
				obj.angle = angle;
				obj.color = color;
				obj.filters = filters;

				if(type != 'square')
				{
					obj.flipX = flipX;
					obj.flipY = flipY;
					obj.image = image;
					obj.antialiasing = antialiasing;
					if(type == 'animatedSprite')
					{
						obj.animations = animations;
						obj.firstAnimation = firstAnimation;
					}
				}
		}
		return obj;
	}

	public function update(curFilters:LoadFilters, elapsed:Float)
	{
		if((curFilters & filters) != 0 || StageData.reservedNames.contains(type))
			sprite.update(elapsed);
	}

	public function draw(curFilters:LoadFilters)
	{
		if((curFilters & filters) != 0 || StageData.reservedNames.contains(type))
			sprite.draw();
	}
}

class StageEditorAnimationSubstate extends MusicBeatSubstate {
	var bg:FlxSprite;
	var originalZoom:Float;
	var originalCamPoint:FlxPoint;
	var originalPosition:FlxPoint;
	var originalCamTarget:FlxObject;
	var originalAlpha:Float = 1;
	public var target:StageEditorMetaSprite;
	
	var curAnim:Int = 0;
	var animsTxtGroup:FlxTypedGroup<FlxText>;

	var UI_animationbox:FlxUITabMenu;
	var camHUD:FlxCamera = cast(FlxG.state, StageEditorState).camHUD;
	public function new()
	{
		super();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(50, 50, 100, 100, true, 0xFFAAAAAA, 0xFF666666));
		add(grid);
		
		animsTxtGroup = new FlxTypedGroup<FlxText>();
		animsTxtGroup.cameras = [camHUD];
		add(animsTxtGroup);
		
		UI_animationbox = new FlxUITabMenu(null, [{name: 'Animations', label: 'Animations'}], true);
		UI_animationbox.cameras = [camHUD];

		UI_animationbox.resize(300, 250);
		UI_animationbox.x = FlxG.width - 320;
		UI_animationbox.y = 20;
		UI_animationbox.scrollFactor.set();
		add(UI_animationbox);
		addAnimationsUI();

		openCallback = function()
		{
			curAnim = 0;
			originalZoom = FlxG.camera.zoom;
			originalCamPoint = FlxPoint.weak(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
			originalPosition = FlxPoint.weak(target.x, target.y);
			originalCamTarget = FlxG.camera.target;
			originalAlpha = target.alpha;
			FlxG.camera.zoom = 0.5;
			FlxG.camera.scroll.set(0, 0);

			target.alpha = 1;
			target.sprite.screenCenter();
			add(target.sprite);
			reloadAnimList();
			trace('Opened substate');
		};

		closeCallback = function()
		{
			FlxG.camera.zoom = originalZoom;
			FlxG.camera.scroll.set(originalCamPoint.x, originalCamPoint.y);
			FlxG.camera.target = originalCamTarget;

			target.x = originalPosition.x;
			target.y = originalPosition.y;
			target.alpha = originalAlpha;
			remove(target.sprite);

			if(target.animations.length > 0)
			{
				if(target.firstAnimation == null) target.firstAnimation = target.animations[0].anim;
				playAnim(target.firstAnimation);
			}
		};
	}

	var animationDropDown:FlxUIDropDownMenu;
	var animationInputText:FlxUIInputText;
	var animationNameInputText:FlxUIInputText;
	var animationIndicesInputText:FlxUIInputText;
	var animationFramerate:FlxUINumericStepper;
	var animationLoopCheckBox:FlxUICheckBox;
	var focusCheck:Array<Dynamic> = [];
	var mainAnimTxt:FlxText;
	function addAnimationsUI()
	{
		var tab_group = new FlxUI(null, UI_animationbox);
		tab_group.name = 'Animations';


		animationInputText = new FlxUIInputText(15, 85, 80, '', 8);
		animationNameInputText = new FlxUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		animationIndicesInputText = new FlxUIInputText(animationNameInputText.x, animationNameInputText.y + 40, 250, '', 8);
		animationFramerate = new FlxUINumericStepper(animationInputText.x + 170, animationInputText.y, 1, 24, 0, 240, 0);
		animationLoopCheckBox = new FlxUICheckBox(animationNameInputText.x + 170, animationNameInputText.y - 1, null, null, 'Should it Loop?', 100);
		focusCheck.push(animationInputText);
		focusCheck.push(animationNameInputText);
		focusCheck.push(animationIndicesInputText);
		focusCheck.push(animationFramerate);

		animationDropDown = new FlxUIDropDownMenu(15, animationInputText.y - 55, FlxUIDropDownMenu.makeStrIdLabelArray([''], true), function(pressed:String) {
			var selectedAnimation:Int = Std.parseInt(pressed);
			var anim:AnimArray = target.animations[selectedAnimation];
			if(anim == null) return;

			animationInputText.text = anim.anim;
			animationNameInputText.text = anim.name;
			animationLoopCheckBox.checked = anim.loop;
			animationFramerate.value = anim.fps;

			var indicesStr:String = anim.indices.toString();
			animationIndicesInputText.text = indicesStr.substr(1, indicesStr.length - 2);
		});

		mainAnimTxt = new FlxText(160, animationDropDown.y - 18, 0, 'Main Anim.: ');
		var initAnimButton = new FlxButton(160, animationDropDown.y, 'Main Animation', function() {
			var anim:AnimArray = target.animations[curAnim];
			if(anim == null) return;

			mainAnimTxt.text = 'Main Anim.: ${anim.anim}';
			target.firstAnimation = anim.anim;
		});
		tab_group.add(mainAnimTxt);
		tab_group.add(initAnimButton);

		var addUpdateButton:FlxButton = new FlxButton(40, animationIndicesInputText.y + 35, 'Add/Update', function() {
			if(animationInputText.text == '') return;

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

			var lastAnim:String = (target.animations[curAnim] != null) ? target.animations[curAnim].anim : '';
			var lastOffsets:Array<Int> = null;
			for (anim in target.animations)
				if(animationInputText.text == anim.anim)
				{
					lastOffsets = anim.offsets;
					cast (target.sprite, ModchartSprite).animOffsets.remove(animationInputText.text);
					target.sprite.animation.remove(animationInputText.text);
					target.animations.remove(anim);
				}

			var addedAnim:AnimArray = {
				anim: animationInputText.text,
				name: animationNameInputText.text,
				fps: Math.round(animationFramerate.value),
				loop: animationLoopCheckBox.checked,
				indices: indices,
				offsets: lastOffsets
			};

			if(addedAnim.indices != null && addedAnim.indices.length > 0)
				target.sprite.animation.addByIndices(addedAnim.anim, addedAnim.name, addedAnim.indices, '', addedAnim.fps, addedAnim.loop);
			else
				target.sprite.animation.addByPrefix(addedAnim.anim, addedAnim.name, addedAnim.fps, addedAnim.loop);

			target.animations.push(addedAnim);
			reloadAnimList();
			playAnim(addedAnim.anim, true);

			curAnim = target.animations.length - 1;
			updateTextColors();
			trace('Added/Updated animation: ' + animationInputText.text);
		});

		var removeButton:FlxButton = new FlxButton(160, animationIndicesInputText.y + 35, 'Remove', function()
		{
			for (anim in target.animations)
			{
				if(animationInputText.text == anim.anim)
				{
					var targetSprite:ModchartSprite = cast (target.sprite, ModchartSprite);
					var resetAnim:Bool = false;
					if(targetSprite.animation.curAnim != null && anim.anim == targetSprite.animation.curAnim.name) resetAnim = true;

					if(targetSprite.animOffsets.exists(anim.anim))
						targetSprite.animOffsets.remove(anim.anim);

					target.animations.remove(anim);
					targetSprite.animation.remove(anim.anim);

					if(resetAnim && target.animations.length > 0)
					{
						curAnim = FlxMath.wrap(curAnim, 0, target.animations.length-1);
						playAnim(target.animations[curAnim].anim, true);
						updateTextColors();
					}
					else if(target.animations.length < 1)
						target.sprite.animation.curAnim = null;

					trace('Removed animation: ' + animationInputText.text);
					reloadAnimList();
					break;
				}
			}
		});

		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
		tab_group.add(new FlxText(animationFramerate.x, animationFramerate.y - 18, 0, 'Framerate:'));
		tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 0, 'Animation Symbol Name/Tag:'));
		tab_group.add(new FlxText(animationIndicesInputText.x, animationIndicesInputText.y - 18, 0, 'ADVANCED - Animation Indices:'));

		tab_group.add(animationInputText);
		tab_group.add(animationNameInputText);
		tab_group.add(animationIndicesInputText);
		tab_group.add(animationFramerate);
		tab_group.add(animationLoopCheckBox);
		tab_group.add(addUpdateButton);
		tab_group.add(removeButton);
		tab_group.add(animationDropDown);
		UI_animationbox.addGroup(tab_group);
	}

	function reloadAnimList()
	{
		if(target.animations == null) target.animations = [];
		else if(target.animations.length > 0) playAnim(target.animations[0].anim, true);
		curAnim = 0;

		for (text in animsTxtGroup)
			text.kill();

		var spr:ModchartSprite = cast (target.sprite, ModchartSprite);
		if(target.animations.length > 0)
		{
			if(target.firstAnimation == null || !target.sprite.animation.exists(target.firstAnimation))
				target.firstAnimation = target.animations[0].anim;

			mainAnimTxt.text = 'Main Anim.: ${target.firstAnimation}';
		}
		else
		{
			target.firstAnimation = null;
			mainAnimTxt.text = '(No Main Animation)';
		}

		for (num => anim in target.animations)
		{
			var text:FlxText = animsTxtGroup.recycle(FlxText);
			text.x = 10;
			text.y = 32 + (20 * num);
			text.fieldWidth = 400;
			text.fieldHeight = 20;
			if(anim.offsets != null)
				text.text = '${anim.anim}: ${spr.animOffsets.get(anim.anim)}';
			else
				text.text = '${anim.anim}: No offsets';

			text.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 1;
			animsTxtGroup.add(text);
		}
		updateTextColors();
		reloadAnimationDropDown();
	}
	
	function reloadAnimationDropDown() {
		var animList:Array<String> = [];
		for (anim in target.animations) animList.push(anim.anim);
		if(animList.length < 1) animList.push('NO ANIMATIONS'); //Prevents crash

		animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(animList, true));
	}

	inline function updateTextColors()
	{
		for (num => text in animsTxtGroup)
		{
			text.color = FlxColor.WHITE;
			if(num == curAnim) text.color = FlxColor.LIME;
		}
	}

	function playAnim(name:String, force:Bool = false)
	{
		var spr:ModchartSprite = cast (target.sprite, ModchartSprite);
		spr.playAnim(name, force);
		if(!spr.animOffsets.exists(name)) spr.updateHitbox();
	}
	
	final minZoom = 0.25;
	final maxZoom = 2;
	var holdingArrowsTime:Float = 0;
	var holdingArrowsElapsed:Float = 0;
	var holdingFrameTime:Float = 0;
	var holdingFrameElapsed:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var canPress:Bool = true;
		for (txt in focusCheck)
			if(txt.hasFocus) canPress = false;

		if(!canPress) return;

		// ANIMATION SCROLLING
		if(target.animations.length > 1)
		{
			var changedAnim:Bool = false;
			if(FlxG.keys.justPressed.W && (changedAnim = true)) curAnim--;
			else if(FlxG.keys.justPressed.S && (changedAnim = true)) curAnim++;
			else if(FlxG.keys.justPressed.SPACE) changedAnim = true;

			if(changedAnim)
			{
				curAnim = FlxMath.wrap(curAnim, 0, target.animations.length-1);
				playAnim(target.animations[curAnim].anim, true);
				updateTextColors();
			}
		}

		var shiftMult:Float = 1;
		var ctrlMult:Float = 1;
		var shiftMultBig:Float = 1;
		if(FlxG.keys.pressed.SHIFT)
		{
			shiftMult = 4;
			shiftMultBig = 10;
		}
		if(FlxG.keys.pressed.CONTROL) ctrlMult = 0.25;

		// OFFSET
		if(target.sprite.animation.curAnim != null)
		{
			var spr:ModchartSprite = cast (target.sprite, ModchartSprite);
			var anim:String = spr.animation.curAnim.name;
			var changedOffset = false;
			var moveKeysP = [FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.UP, FlxG.keys.justPressed.DOWN];
			var moveKeys = [FlxG.keys.pressed.LEFT, FlxG.keys.pressed.RIGHT, FlxG.keys.pressed.UP, FlxG.keys.pressed.DOWN];
			if(moveKeysP.contains(true))
			{
				if(spr.animOffsets.get(anim) != null)
				{
					spr.offset.x += ((moveKeysP[0] ? 1 : 0) - (moveKeysP[1] ? 1 : 0)) * shiftMultBig;
					spr.offset.y += ((moveKeysP[2] ? 1 : 0) - (moveKeysP[3] ? 1 : 0)) * shiftMultBig;
				}
				else spr.offset.x = spr.offset.y = 0;
				changedOffset = true;
			}
	
			if(moveKeys.contains(true))
			{
				holdingArrowsTime += elapsed;
				if(holdingArrowsTime > 0.6)
				{
					holdingArrowsElapsed += elapsed;
					while(holdingArrowsElapsed > (1/60))
					{
						if(spr.animOffsets.get(anim) != null)
						{
							spr.offset.x += ((moveKeys[0] ? 1 : 0) - (moveKeys[1] ? 1 : 0)) * shiftMultBig;
							spr.offset.y += ((moveKeys[2] ? 1 : 0) - (moveKeys[3] ? 1 : 0)) * shiftMultBig;
						}
						else spr.offset.x = spr.offset.y = 0;
						holdingArrowsElapsed -= (1/60);
						changedOffset = true;
					}
				}
			}
			else holdingArrowsTime = 0;
	
			if(FlxG.mouse.pressedRight && (FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0))
			{
				spr.offset.x -= FlxG.mouse.deltaScreenX;
				spr.offset.y -= FlxG.mouse.deltaScreenY;
				changedOffset = true;
			}

			if (FlxG.keys.justPressed.R && FlxG.keys.pressed.CONTROL)
			{
				target.animations[curAnim].offsets = null;
				spr.animOffsets.remove(anim);
				spr.updateHitbox();
				animsTxtGroup.members[curAnim].text = '${anim}: No offsets';
			}
			
			if(changedOffset)
			{
				var offX = Math.round(spr.offset.x);
				var offY = Math.round(spr.offset.y);

				spr.addOffset(anim, offX, offY);
				target.animations[curAnim].offsets = [offX, offY];
				animsTxtGroup.members[curAnim].text = '${anim}: ${spr.animOffsets.get(anim)}';
			}
		}
		else
		{
			holdingArrowsTime = 0;
			holdingArrowsElapsed = 0;
		}

		// CAMERA CONTROLS
		var camX:Float = 0;
		var camY:Float = 0;
		if (FlxG.keys.pressed.J) camX -= elapsed * 500 * shiftMult * ctrlMult;
		if (FlxG.keys.pressed.K) camY += elapsed * 500 * shiftMult * ctrlMult;
		if (FlxG.keys.pressed.L) camX += elapsed * 500 * shiftMult * ctrlMult;
		if (FlxG.keys.pressed.I) camY -= elapsed * 500 * shiftMult * ctrlMult;

		if(camX != 0 || camY != 0)
		{
			FlxG.camera.scroll.x += camX;
			FlxG.camera.scroll.y += camY;
		}

		var lastZoom = FlxG.camera.zoom;
		if(FlxG.keys.justPressed.R && !FlxG.keys.pressed.CONTROL)
			FlxG.camera.zoom = 0.5;
		else if (FlxG.keys.pressed.E && FlxG.camera.zoom < maxZoom)
			FlxG.camera.zoom = Math.min(maxZoom, FlxG.camera.zoom + elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);
		else if (FlxG.keys.pressed.Q && FlxG.camera.zoom > minZoom)
			FlxG.camera.zoom = Math.max(minZoom, FlxG.camera.zoom - elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);

		if(FlxG.keys.justPressed.ESCAPE)
		{
			persistentDraw = true;
			close();
		}
	}

	override function draw()
	{
		super.draw();
	}
}