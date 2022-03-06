package editors;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import StageData.StageFile;
import LayerFile;
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
import flixel.group.FlxSpriteGroup;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;
import flash.net.FileFilter;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class StageEditorState extends MusicBeatState
{
	var layers:Array<String>;
	var bf:Boyfriend;
	var i:LayerFile;
	var dad:Character;
	var gf:Character;
	var startMousePos:FlxPoint = new FlxPoint();
	var holdingObjectType:Null<Bool> = null;
	var startDragging:FlxPoint = new FlxPoint();
	var directories:Array<String>;
	var defaultZoom:Float;
	var isPixelStage:Bool;
	var camFollow:FlxObject;
	var confirmAdded:Bool = false;

	var ispixel:FlxUICheckBox;

	var isflippedY:FlxUICheckBox;
	var isflippedX:FlxUICheckBox;

	var ischar:FlxUICheckBox;

	var data:StageFile;
	var shouldStayIn:FlxSprite;

	public static var stageFile:StageFile;
	public static var stepperscrollX:FlxUIInputText;
	public static var stepperscrollY:FlxUIInputText;

	var scaleStepper:FlxUINumericStepper;
	public static var layerStepper:FlxUINumericStepper;
	var coolstageFile:StageData;
	var addedLayers:Array<LayerFile>;

	var dummyLayer:FlxSprite;

	public static var luaStages:Array<String> = [];
	public static var luaScrollFactors:Array<String> = [];
	public static var luaAdded:Array<String> = [];
	public static var luaFlipX:Array<String> = [];
	public static var luaFlipY:Array<String> = [];

	var visualLayers:Array<FlxSprite> = [];

	var createdLayer:FlxSprite;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;

	var layerAdded:Bool = false;

	var stageCounter:Int;

	var noStage:Bool = true;

	var bg:FlxSprite;
	var stageFront:FlxSprite;
	var stageCurtains:FlxSprite;

	var UI_box:FlxUITabMenu;
	var UI_stagebox:FlxUITabMenu;

	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;
	private var camTips:FlxCamera;
	private var camGrid:FlxCamera;
	private var camPeople:FlxCamera;
	private var camshit:FlxCamera;
	private var camhidden:FlxCamera;

	// so many text boxes lol
	public static var nameInputText:FlxUIInputText;
	public static var directoryInputText:FlxUIInputText;
	public static var directoryInputTextcool:FlxUIInputText;
	public static var xInputText:FlxUIInputText;
	public static var yInputText:FlxUIInputText;
	public static var gfInputText:FlxUIInputText;
	public static var bfInputText:FlxUIInputText;
	public static var opponentinputtext:FlxUIInputText;
	public static var zoominputtext:FlxUIInputText;
	public static var dirinputtext:FlxUIInputText;
	public static var goToPlayState:Bool = true;

	override function create()
	{
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		bf = new Boyfriend(770, 450, 'bf');
		dad = new Character(100, 100, 'dad');
		gf = new Character(400, 130, 'gf');

		bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		bg.antialiasing = true;

		stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;

		stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;

		FlxG.camera.follow(camFollow);

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;
		camTips = new FlxCamera();
		camTips.bgColor.alpha = 0;
		camGrid = new FlxCamera();
		camGrid.bgColor.alpha = 0;
		camPeople = new FlxCamera();
		camPeople.bgColor.alpha = 0;
		camshit = new FlxCamera();
		camshit.bgColor.alpha = 0;
		camhidden = new FlxCamera();
		camhidden.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camshit);
		FlxG.cameras.add(camPeople);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxG.cameras.add(camTips);
		FlxG.cameras.add(camGrid);

		FlxCamera.defaultCameras = [camEditor];

		gf.cameras = [camPeople];
		bf.cameras = [camPeople];
		dad.cameras = [camPeople];

		var tabs = [{name: 'Layers', label: 'Layers'}, {name: 'Settings', label: 'Settings'},];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camMenu];

		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		UI_stagebox = new FlxUITabMenu(null, tabs, true);
		UI_stagebox.cameras = [camMenu];

		UI_stagebox.resize(350, 350);
		UI_stagebox.x = UI_box.x - 100;
		UI_stagebox.y = UI_box.y + UI_box.height;
		UI_stagebox.scrollFactor.set();
		add(UI_stagebox);

		addLayersUI();
		addSettingsUI();

		add(bg);
		add(stageCurtains);
		add(stageFront);

		UI_stagebox.selected_tab_id = 'Layers';

		var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0, "E/Q - Camera Zoom In/Out
        \nArrow Keys/Hold And Drag\n - Move Layer
        \nR - Reset Current Zoom", 12);
		tipText.cameras = [camTips];
		tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.screenCenter(Y);
		tipText.x -= tipText.width;
		tipText.y -= tipText.height - 10;
		add(tipText);

		var gridOutline:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('stageborder'));
		gridOutline.screenCenter();
		gridOutline.cameras = [camGrid];
		add(gridOutline);

		FlxG.mouse.visible = true;

		dummyLayer = new FlxSprite();
        dummyLayer.visible = false;
		dummyLayer.cameras = [camhidden];
		visualLayers.push(dummyLayer);

		makePlaceholders();

		super.create();
	}

	function addLayersUI()
	{
		
		nameInputText = new FlxUIInputText(15, 50, 200, "", 8);
		var namelabel = new FlxText(15, nameInputText.y + 20, 64, 'Layer Name');
		directoryInputText = new FlxUIInputText(15, nameInputText.y + 50, 200, "", 8);
		var directlabel = new FlxText(15, directoryInputText.y + 20, 64, 'Image Directory');
		xInputText = new FlxUIInputText(15, directoryInputText.y + 50, 200, "", 8);
		var xlabel = new FlxText(15, xInputText.y + 20, 64, 'X Axis');
		yInputText = new FlxUIInputText(15, xInputText.y + 50, 200, "", 8);
		var ylabel = new FlxText(15, yInputText.y + 20, 64, 'Y Axis');

		stepperscrollY = new FlxUIInputText(240, yInputText.y, 64, '');

		var whylabel = new FlxText(240, stepperscrollY.y + 20, 64, 'Scroll Factor Y');

		stepperscrollX = new FlxUIInputText(240, xInputText.y, 64, '');

		var exlabel = new FlxText(240, stepperscrollX.y + 20, 64, 'Scroll Factor X');

		scaleStepper = new FlxUINumericStepper(240, directoryInputText.y, 0.1, 1, 0, 10, 1);

		var scalelabel = new FlxText(240, scaleStepper.y + 20, 64, 'Scale');

		layerStepper = new FlxUINumericStepper(15, scaleStepper.y + 150, 1, 0, 0, 0, 1);

		var layerlabel = new FlxText(15, layerStepper.y + 20, 64, 'Selected Layer');


		isflippedX = new FlxUICheckBox(240, layerStepper.y + 20, null, null, "FlipX", 100);

		isflippedY = new FlxUICheckBox(240, isflippedX.y + 20, null, null, "FlipY", 100);

		var addLayer:FlxButton = new FlxButton(140, 20, "Add Layer", function()
		{
			noStage = false;
			layerAdded = true;
			stageCounter + 1;
			var stageSwag:LayerFile = {
				name: nameInputText.text,
				directory: directoryInputText.text,
				xAxis: Std.parseFloat(xInputText.text),
				yAxis: Std.parseFloat(yInputText.text),
				scrollY: Std.parseFloat(stepperscrollX.text),
				scrollX: Std.parseFloat(stepperscrollY.text),
				scale: scaleStepper.value,
				flipX: isflippedX.checked,
				flipY: isflippedY.checked
			};

			var luaMakeStage:String = "makeLuaSprite('" + nameInputText.text + "', " + "'" + directoryInputText.text + "', " + xInputText.text + ", "
				+ yInputText.text + ");";
			var luaMakeScrollFactor:String = "setScrollFactor('" + nameInputText.text + "', " + stepperscrollX.text + ", " + stepperscrollY.text + ");";
			var luaAdd:String = "addLuaSprite('" + nameInputText.text + "', " + "'false'" + ");";
			var luaFlipYstring:String = "setProperty('" + nameInputText.text + ".flipY', " + isflippedY.checked + ");";
			var luaFlipXstring:String = "setProperty('" + nameInputText.text + ".flipX', " + isflippedX.checked + ");";
			createdLayer = new FlxSprite();
			if (visualLayers.contains(dummyLayer)) {
				visualLayers.remove(dummyLayer);
			}
			add(createdLayer);
			visualLayers.push(createdLayer);
			luaStages.push(luaMakeStage);
			luaScrollFactors.push(luaMakeScrollFactor);
			luaAdded.push(luaAdd);
			layerStepper.max = stageFile.layerArray.length;
			layerStepper.value++;
			luaFlipX.push(luaFlipXstring);
			luaFlipY.push(luaFlipYstring);
			stageFile.layerArray.push(stageSwag);
			remove(bg);
			remove(stageFront);
			remove(stageCurtains);
			// we need to make sure the created layer exists before being able to scale it or we'll experience a crash
			if (stageFile.layerArray.contains(stageSwag))
			{
				for (cool in stageFile.layerArray)
				{
					if (cool.directory != "")
					{
						confirmAdded = true;
					}
				}
			}
		});

		var removeLayer:FlxButton = new FlxButton(40, 20, "Remove Layer", function()
		{
			if (!noStage)
			{
				var stageSwag:LayerFile = {
					name: nameInputText.text,
					directory: directoryInputText.text,
					xAxis: Std.parseFloat(xInputText.text),
					yAxis: Std.parseFloat(yInputText.text),
					scrollY: Std.parseFloat(stepperscrollX.text),
					scrollX: Std.parseFloat(stepperscrollY.text),
					scale: scaleStepper.value,
					flipX: isflippedX.checked,
					flipY: isflippedY.checked
				};

				var luaMakeStage:String = "makeLuaSprite('" + nameInputText.text + "', " + "'" + directoryInputText.text + "', " + xInputText.text + ", "
					+ yInputText.text + ");";
				var luaMakeScrollFactor:String = "setScrollFactor('" + nameInputText.text + "', " + stepperscrollX.text + ", " + stepperscrollY.text + ");";
				var luaAdd:String = "addLuaSprite('" + nameInputText.text + "', " + "'false'" + ");";
				var luaFlipYstring:String = "setProperty('" + nameInputText.text + ".flipY', " + isflippedY.checked + ");";
				var luaFlipXstring:String = "setProperty('" + nameInputText.text + ".flipX', " + isflippedX.checked + ");";

				deleteLayer();
				xInputText.text = "" + 0;
				yInputText.text = "" + 0;
				luaStages.remove(luaMakeStage);
				luaScrollFactors.remove(luaMakeScrollFactor);
				luaAdded.remove(luaAdd);
				luaFlipX.remove(luaFlipXstring);
				luaFlipY.remove(luaFlipYstring);
				layerStepper.value--;
				remove(createdLayer);
				visualLayers.remove(createdLayer);
				stageFile.layerArray.remove(stageSwag);
				
			}
		});

		removeLayer.color = FlxColor.RED;
		removeLayer.label.color = FlxColor.WHITE;

		var tab_group_layers = new FlxUI(null, UI_stagebox);
		tab_group_layers.name = "Layers";
		tab_group_layers.add(nameInputText);
		tab_group_layers.add(isflippedY);
		tab_group_layers.add(isflippedX);
		tab_group_layers.add(directoryInputText);
		tab_group_layers.add(removeLayer);
		tab_group_layers.add(addLayer);
		tab_group_layers.add(scaleStepper);
		tab_group_layers.add(layerStepper);
		tab_group_layers.add(layerlabel);
		tab_group_layers.add(scalelabel);
		tab_group_layers.add(namelabel);
		tab_group_layers.add(directlabel);
		tab_group_layers.add(stepperscrollX);
		tab_group_layers.add(stepperscrollY);
		tab_group_layers.add(whylabel);
		tab_group_layers.add(exlabel);
		tab_group_layers.add(xInputText);
		tab_group_layers.add(yInputText);
		tab_group_layers.add(ylabel);
		tab_group_layers.add(xlabel);

		UI_stagebox.addGroup(tab_group_layers);

		UI_stagebox.scrollFactor.set();
	}

	function makePlaceholders()
	{
		add(gf);
		add(bf);
		add(dad);
	}

	var stageFiler:StageFile = null;

	function addSettingsUI()
	{
		directoryInputTextcool = new FlxUIInputText(15, 20, 200, "", 8);
		var directlabel = new FlxText(15, directoryInputTextcool.y + 20, 64, 'Image Directory');
		bfInputText = new FlxUIInputText(15, directoryInputTextcool.y + 50, 200, "770, 450", 8);
		var xlabel = new FlxText(15, bfInputText.y + 20, 64, 'BoyFriend Position');
		gfInputText = new FlxUIInputText(15, bfInputText.y + 50, 200, "400, 130", 8);
		var gflabel = new FlxText(15, gfInputText.y + 20, 64, 'GirlFriend Position');
		opponentinputtext = new FlxUIInputText(15, gfInputText.y + 50, 200, "100, 100", 8);
		var ylabel = new FlxText(15, opponentinputtext.y + 20, 64, 'Opponent Position');
		zoominputtext = new FlxUIInputText(15, opponentinputtext.y + 50, 200, "", 8);
		var elabel = new FlxText(15, zoominputtext.y + 20, 64, 'Default Zoom');
		dirinputtext = new FlxUIInputText(15, zoominputtext.y + 50, 200, "", 8);
		var directorycoollabel = new FlxText(15, dirinputtext.y + 20, 64, 'Stage Name');

		ispixel = new FlxUICheckBox(240, 220, null, null, "IsPixelStage", 100);
		ischar = new FlxUICheckBox(240, 270, null, null, "Characters Are Visible", 100);

		ischar.checked = true;

		var saveStuff:FlxButton = new FlxButton(240, 20, "Save Stage", function()
		{
			saveStage(stageFile);
		});
		var saveLua:FlxButton = new FlxButton(240, 70, "Save LUA Script", function()
		{
			saveStageLua();
		});
		var saveLuaj:FlxButton = new FlxButton(240, 120, "Save LUA Config", function()
		{
			saveStageLuaJSON();
		});

		saveLua.color = FlxColor.BLUE;
		saveLua.label.color = FlxColor.WHITE;
		saveLuaj.color = FlxColor.ORANGE;
		saveLuaj.label.color = FlxColor.WHITE;

		var loadStuff:FlxButton = new FlxButton(240, 170, "Load Stage", function()
		{
			loadStage();
		});

		var tab_group_settings = new FlxUI(null, UI_stagebox);
		tab_group_settings.name = "Settings";
		tab_group_settings.add(saveStuff);
		tab_group_settings.add(saveLua);
		tab_group_settings.add(ischar);
		tab_group_settings.add(saveLuaj);
		tab_group_settings.add(bfInputText);
		tab_group_settings.add(ispixel);
		tab_group_settings.add(loadStuff);
		tab_group_settings.add(gfInputText);
		tab_group_settings.add(opponentinputtext);
		tab_group_settings.add(xlabel);
		tab_group_settings.add(ylabel);
		tab_group_settings.add(gflabel);
		tab_group_settings.add(elabel);
		tab_group_settings.add(zoominputtext);
		tab_group_settings.add(dirinputtext);
		tab_group_settings.add(directorycoollabel);

		UI_stagebox.addGroup(tab_group_settings);

		UI_stagebox.scrollFactor.set();
	}

	function reloadStages() {

		bfInputText.text = Std.string(stageFile.boyfriend[0] + ", " + stageFile.boyfriend[1]);
		gfInputText.text = Std.string(stageFile.girlfriend[0] + ", " + stageFile.girlfriend[1]);
		opponentinputtext.text = Std.string(stageFile.opponent[0] + ", " + stageFile.opponent[1]);
		dirinputtext.text = stageFile.name;
		directoryInputText.text = stageFile.directory + "";
		zoominputtext.text = Std.string(stageFile.defaultZoom + "");
		ispixel.checked = stageFile.isPixelStage;

		for (layer in stageFile.layerArray) {

			layerStepper.value++;
			layerStepper.max++;
		
			nameInputText.text = layer.name;
			directoryInputText.text = layer.directory;
			xInputText.text = Std.string(layer.xAxis);
			yInputText.text = Std.string(layer.yAxis);
			stepperscrollX.text = Std.string(layer.scrollX);
			stepperscrollY.text = Std.string(layer.scrollY);
			scaleStepper.value = layer.scale;
			isflippedX.checked = layer.flipX;
            isflippedY.checked = layer.flipY;

			var assetName:String = layer.directory;
			var directoryLayer:String = "images/" + assetName + ".png";
			                        //.cpp error moment
			if (FileSystem.exists(Paths.modsImages(assetName))) {
			createdLayer = new FlxSprite();
			createdLayer.loadGraphic(Paths.image(assetName));
			createdLayer.x = layer.xAxis;
			createdLayer.y = layer.yAxis;
			createdLayer.setGraphicSize(Std.int(createdLayer.width * layer.scale));
			add(createdLayer);
			visualLayers.push(createdLayer);
			}
			                       //.cpp error moment
			if (Paths.fileExists(directoryLayer, IMAGE)) {
			createdLayer = new FlxSprite();
			createdLayer.loadGraphic(Paths.getPath(directoryLayer, IMAGE));
			createdLayer.x = layer.xAxis;
			createdLayer.y = layer.yAxis;
			createdLayer.setGraphicSize(Std.int(createdLayer.width * layer.scale));
			add(createdLayer);
			visualLayers.push(createdLayer);
			}
       }	
  }

	function searchForLayer()
	{
		var assetName:String = directoryInputText.text.trim();
		var directoryLayer:String = "images/" + assetName + ".png";
		if (assetName != null && assetName.length > 0)
		{
			if (FileSystem.exists(Paths.modFolders(directoryLayer)))
			{
				visualLayers[Std.int(layerStepper.value)].loadGraphic(Paths.image(assetName));
				visualLayers[Std.int(layerStepper.value)].visible = true;
				bg.visible = false;
				stageFront.visible = false;
				stageCurtains.visible = false;
			}
			else
			{
				visualLayers[Std.int(layerStepper.value)].visible = false;
			}
			if (Paths.fileExists(directoryLayer, IMAGE))
			{
				visualLayers[Std.int(layerStepper.value)].loadGraphic(Paths.getPath(directoryLayer, IMAGE));
				visualLayers[Std.int(layerStepper.value)].visible = true;
				bg.visible = false;
				stageFront.visible = false;
				stageCurtains.visible = false;
			}
			else
			{
				visualLayers[Std.int(layerStepper.value)].visible = false;
			}
		}
		else
		{
			visualLayers[Std.int(layerStepper.value)].visible = false;
		} 
	}

	function deleteLayer()
	{
		remove(visualLayers[Std.int(layerStepper.value)]);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			if (sender == scaleStepper)
			{
				var stageSwag:LayerFile = {
					name: nameInputText.text,
					directory: directoryInputText.text,
					xAxis: Std.parseFloat(xInputText.text),
					yAxis: Std.parseFloat(yInputText.text),
					scrollY: Std.parseFloat(stepperscrollX.text),
					scrollX: Std.parseFloat(stepperscrollY.text),
					scale: scaleStepper.value,
					flipX: isflippedX.checked,
					flipY: isflippedY.checked
				};
				stageSwag.scale = sender.value;
				visualLayers[Std.int(layerStepper.value)].setGraphicSize(Std.int(visualLayers[Std.int(layerStepper.value)].width * stageSwag.scale));
			}
		}
	}

	override public function update(elapsed:Float)
	{

		var inputTexts:Array<FlxUIInputText> = [
			nameInputText, directoryInputText, directoryInputText, directoryInputTextcool, xInputText, yInputText, gfInputText, bfInputText,
			opponentinputtext, zoominputtext, dirinputtext
		];
		for (i in 0...inputTexts.length)
		{
			if (inputTexts[i].hasFocus)
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
				{ // Copy paste
					inputTexts[i].text = CharacterEditorState.ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				if (FlxG.keys.justPressed.ENTER)
				{
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}

		if (loadedFile != null)
		{
			stageFile = loadedFile;
			loadedFile = null;

			reloadStages();
		}

		if (FlxG.save.data.layerPositions == null)
			FlxG.save.data.layerPositions = [0, 0];

		super.update(elapsed);

		gf.visible = ischar.checked;
		bf.visible = ischar.checked;
		dad.visible = ischar.checked;

		searchForLayer();

		if (stageFile == null)
		{
			stageFile = {
				name: "",
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				layerArray: []
			};
		}
		else
		{
			var STRING = bfInputText.text.trim().split(", ");
			var x = Std.parseInt(STRING[0].trim());
			var y = Std.parseInt(STRING[1].trim());
			stageFile.boyfriend = [x, y];
			bf.x = x;
			bf.y = y;

			var STRING2 = gfInputText.text.trim().split(", ");
			var x2 = Std.parseInt(STRING2[0].trim());
			var y2 = Std.parseInt(STRING2[1].trim());
			stageFile.girlfriend = [x2, y2];
			gf.x = x2;
			gf.y = y2;

			var STRING3 = opponentinputtext.text.trim().split(", ");
			var x3 = Std.parseInt(STRING3[0].trim());
			var y3 = Std.parseInt(STRING3[1].trim());
			stageFile.opponent = [x3, y3];
			dad.x = x3;
			dad.y = y3;
		}

		stageFile.defaultZoom = Std.parseFloat(zoominputtext.text);
		stageFile.name = dirinputtext.text;
		stageFile.isPixelStage = ispixel.checked;

		visualLayers[Std.int(layerStepper.value)].flipX = isflippedX.checked;
		visualLayers[Std.int(layerStepper.value)].flipY = isflippedY.checked;

		yInputText.text = visualLayers[Std.int(layerStepper.value)].y + "";
		xInputText.text = visualLayers[Std.int(layerStepper.value)].x + "";

		if (FlxG.keys.pressed.LEFT)
		{
			visualLayers[Std.int(layerStepper.value)].x -= 1;
			xInputText.text = visualLayers[Std.int(layerStepper.value)].x + "";
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			visualLayers[Std.int(layerStepper.value)].x += 1;
			xInputText.text = visualLayers[Std.int(layerStepper.value)].x + "";
		}
		else if (FlxG.keys.pressed.UP)
		{
			visualLayers[Std.int(layerStepper.value)].y -= 1;
			yInputText.text = visualLayers[Std.int(layerStepper.value)].y + "";
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			visualLayers[Std.int(layerStepper.value)].y += 1;
			yInputText.text = visualLayers[Std.int(layerStepper.value)].y + "";
		}

		if (FlxG.mouse.justPressed)
		{
			holdingObjectType = null;
			FlxG.mouse.getScreenPosition(camEditor, startMousePos);
			if (startMousePos.x - visualLayers[Std.int(layerStepper.value)].x >= 0
				&& startMousePos.x - visualLayers[Std.int(layerStepper.value)].x <= visualLayers[Std.int(layerStepper.value)].width
				&& startMousePos.y - visualLayers[Std.int(layerStepper.value)].y >= 0
				&& startMousePos.y - visualLayers[Std.int(layerStepper.value)].y <= visualLayers[Std.int(layerStepper.value)].height)
			{
				holdingObjectType = false;
				startDragging.x = FlxG.save.data.layerPositions[0];
				startDragging.y = FlxG.save.data.layerPositions[1];
			}
		}
		if (FlxG.mouse.justReleased)
			holdingObjectType = null;

		if (holdingObjectType != null && FlxG.mouse.justMoved)
		{
			var mousePos:FlxPoint = FlxG.mouse.getScreenPosition(camEditor);
			var addNum:Int = holdingObjectType ? 2 : 0;
			FlxG.save.data.layerPositions[addNum + 0] = Math.round((mousePos.x - startMousePos.x) + startDragging.x);
			FlxG.save.data.layerPositions[addNum + 1] = -Math.round((mousePos.y - startMousePos.y) - startDragging.y);
			repositionShit();
		}

		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1;
		}
		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}

		camMenu.zoom = FlxG.camera.zoom;
		camPeople.zoom = FlxG.camera.zoom;
		camGrid.zoom = FlxG.camera.zoom;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			MusicBeatState.switchState(new editors.MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

			FlxG.mouse.visible = false;
			return;
		}
	}

	function repositionShit()
	{
		visualLayers[Std.int(layerStepper.value)].screenCenter();
		visualLayers[Std.int(layerStepper.value)].x = visualLayers[Std.int(layerStepper.value)].x - 40 + FlxG.save.data.layerPositions[0];
		visualLayers[Std.int(layerStepper.value)].y -= 60 + FlxG.save.data.layerPositions[1];
	}

	private static var _file:FileReference;

	public static function saveStage(stageFile:StageFile)
	{
		var data:String = Json.stringify(stageFile, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, dirinputtext.text + ".json");
		}
	}

	// for the json config if you are using lua
	public static function saveStageLuaJSON()
	{
		var stageFile = {
			directory: "",
			defaultZoom: stageFile.defaultZoom,
			isPixelStage: false,
			boyfriend: stageFile.boyfriend,
			girlfriend: stageFile.girlfriend,
			opponent: stageFile.opponent
		}

		var data:String = Json.stringify(stageFile, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, dirinputtext.text + ".json");
		}
	}

	public static function saveStageLua()
	{
		if (dirinputtext.text != "")
		{
			{
				_file = new FileReference();
				_file.addEventListener(Event.COMPLETE, onSaveComplete);
				_file.addEventListener(Event.CANCEL, onSaveCancel);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				_file.save("function onCreate()\n" + luaStages.join("\n") + "\n" + luaScrollFactors.join("\n") + "\n" + luaFlipY.join("\n") + "\n" + luaFlipX.join("\n") + "\n" + luaAdded.join("\n") + "\n" + "end",
					dirinputtext.text + ".lua");
			}
		}
	}

	private static function onSaveComplete(_):Void
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
	private static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

	public static function loadStage()
	{
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public static var loadedFile:StageFile = null;
	public static var loadError:Bool = false;

	private static function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			var rawJson:String = File.getContent(fullPath);
			if (rawJson != null)
			{
				loadedFile = cast Json.parse(rawJson);
				if (loadedFile.layerArray != null && loadedFile.name != null)
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					loadError = false;

					stageFile.name = cutName;
					_file = null;
					return;
				}
			}
		}
		loadError = true;
		loadedFile = null;
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private static function onLoadCancel(_):Void
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
	private static function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}
}
