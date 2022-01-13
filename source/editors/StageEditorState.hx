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
#end
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class StageEditorState extends MusicBeatState
{
    var layers:Array<String>;
    var directories:Array<String>;
    var defaultZoom:Float;
	var isPixelStage:Bool;
    var camFollow:FlxObject;
    var confirmAdded:Bool = false;
    
    var data:StageFile;
    var shouldStayIn:FlxSprite;
    public static var swagStage:StageFile;
    var stepperscrollX:FlxUIInputText;
    var stepperscrollY:FlxUIInputText;
    var scaleStepper:FlxUINumericStepper;
    var coolswagStage:StageData;
    var addedLayers:Array<LayerFile>;


    var createdLayer:FlxSprite = new FlxSprite();

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;

    var layerAdded:Bool = false;

    var stageCounter:Int;
    var gridBG:FlxSprite;

    var noStage:Bool = true;

    var UI_box:FlxUITabMenu;
	var UI_stagebox:FlxUITabMenu;

    private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;
    private var camTips:FlxCamera;
    
    // so many text boxes lol
    public var typingShit:FlxUIInputText;
	public var typingCrap:FlxUIInputText;
	public var typingDiarehha:FlxUIInputText;
	public var typingWaste:FlxUIInputText;
    public var typingWasted:FlxUIInputText;
    public static var nameInputText:FlxUIInputText;
    public var directoryInputText:FlxUIInputText;
    public var directoryInputTextcool:FlxUIInputText;
    public var xInputText:FlxUIInputText;
    public var yInputText:FlxUIInputText;
    public static var gfInputText:FlxUIInputText;
    public static var bfInputText:FlxUIInputText;
    public var opponentinputtext:FlxUIInputText;
    public var zoominputtext:FlxUIInputText;
    public static var dirinputtext:FlxUIInputText;
    public static var goToPlayState:Bool = true;

    override function create()
    {

    gridBG = FlxGridOverlay.create(25, 25);
    add(gridBG);
	camFollow = new FlxObject(0, 0, 2, 2);
    camFollow.screenCenter();
	add(camFollow);

    FlxG.camera.follow(camFollow);


	camEditor = new FlxCamera();
	camHUD = new FlxCamera();
	camHUD.bgColor.alpha = 0;
	camMenu = new FlxCamera();
	camMenu.bgColor.alpha = 0;
    camTips = new FlxCamera();
	camTips.bgColor.alpha = 0;

    FlxG.cameras.reset(camEditor);
	FlxG.cameras.add(camHUD);
	FlxG.cameras.add(camMenu);
    FlxG.cameras.add(camTips);
	FlxCamera.defaultCameras = [camEditor];

    var tabs = [
        {name: 'Layers', label: 'Layers'},
        {name: 'Settings', label: 'Settings'},
    ];

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
    searchForLayer();

    UI_stagebox.selected_tab_id = 'Layers';

    var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0,
        "E/Q - Camera Zoom In/Out
        \nArrow Keys - Move Layer
        \nR - Reset Current Zoom", 12);
    tipText.cameras = [camTips];
    tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    tipText.scrollFactor.set();
    tipText.borderSize = 1;
    tipText.screenCenter(Y);
    tipText.x -= tipText.width;
    tipText.y -= tipText.height - 10;
    add(tipText);

    FlxG.mouse.visible = true;

    add(createdLayer);

    super.create();
}
    
    function addLayersUI() {

        nameInputText = new FlxUIInputText(15, 50, 200, "", 8);
        var namelabel = new FlxText(15, nameInputText.y + 20, 64, 'Layer Name');
        typingShit = nameInputText;
        directoryInputText = new FlxUIInputText(15, nameInputText.y + 50, 200, "", 8);
        var directlabel = new FlxText(15, directoryInputText.y + 20, 64, 'Image Directory');
        typingCrap = directoryInputText;
        xInputText = new FlxUIInputText(15, directoryInputText.y + 50, 200, "", 8);
        var xlabel = new FlxText(15, xInputText.y + 20, 64, 'X Axis');
        typingDiarehha = xInputText;
        yInputText = new FlxUIInputText(15, xInputText.y + 50, 200, "", 8);
        var ylabel = new FlxText(15, yInputText.y + 20, 64, 'Y Axis');
        typingWaste = yInputText;
 
		stepperscrollY = new FlxUIInputText(240, yInputText.y, 64, '');
        
        var whylabel = new FlxText(240, stepperscrollY.y + 20, 64, 'Scroll Factor Y');

        stepperscrollX = new FlxUIInputText(240, xInputText.y, 64, '');

        var exlabel = new FlxText(240, stepperscrollX.y + 20, 64, 'Scroll Factor X');

        scaleStepper = new FlxUINumericStepper(240, directoryInputText.y, 0.1, 1, 0.05, 10, 1);

        var scalelabel = new FlxText(240, scaleStepper.y + 20, 64, 'Scale');

        var addLayer:FlxButton = new FlxButton(140, 20, "Add Layer", function() {
            noStage = false;
            layerAdded = true;
            stageCounter + 1;
            var stageSwag:LayerFile = {
                name: nameInputText.text, 
                directory: directoryInputText.text, 
                xAxis: Std.parseFloat(xInputText.text), 
                yAxis:  Std.parseFloat(yInputText.text), 
                scrollY: Std.parseFloat(stepperscrollX.text), 
                scrollX: Std.parseFloat(stepperscrollY.text), 
                scale: scaleStepper.value
                 };
            createdLayer = new FlxSprite();
            add(createdLayer);
            if (layerAdded) {
            swagStage.layerArray.push(stageSwag);
            xInputText.text = "" + 0;
            yInputText.text = "" + 0;
            }
            // we need to make sure the created layer exists before being able to scale it or we'll experience a crash
            if (swagStage.layerArray.contains(stageSwag)) {
                for (cool in swagStage.layerArray) {
                    if (cool.directory != ""){
                        confirmAdded = true;
                    }
                }
            }
        });

        var removeLayer:FlxButton = new FlxButton(40, 20, "Remove Layer", function() {
        if (!noStage){
            var stageSwag:LayerFile = {
                name: nameInputText.text, 
                directory: directoryInputText.text, 
                xAxis: Std.parseFloat(xInputText.text), 
                yAxis:  Std.parseFloat(yInputText.text), 
                scrollY: Std.parseFloat(stepperscrollX.text), 
                scrollX: Std.parseFloat(stepperscrollY.text), 
                scale: scaleStepper.value
                 };
           deleteLayer();
           xInputText.text = "" + 0;
           yInputText.text = "" + 0;
           if (swagStage.layerArray.contains(stageSwag)){
           remove(createdLayer);
           swagStage.layerArray.remove(stageSwag);
           }
        }
    });

           removeLayer.color = FlxColor.RED;
           removeLayer.label.color = FlxColor.WHITE;

           var tab_group_layers = new FlxUI(null, UI_stagebox);
           tab_group_layers.name = "Layers";
           tab_group_layers.add(nameInputText);
           tab_group_layers.add(directoryInputText);
           tab_group_layers.add(removeLayer);
           tab_group_layers.add(addLayer);
           tab_group_layers.add(scaleStepper);
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

    function addSettingsUI() {
        directoryInputTextcool = new FlxUIInputText(15, 20, 200, "", 8);
        var directlabel = new FlxText(15, directoryInputTextcool.y + 20, 64, 'Image Directory');
        bfInputText = new FlxUIInputText(15, directoryInputTextcool.y + 50, 200, "", 8);
        var xlabel = new FlxText(15, bfInputText.y + 20, 64, 'BoyFriend Position');
        gfInputText = new FlxUIInputText(15, bfInputText.y + 50, 200, "", 8);
        var gflabel = new FlxText(15, gfInputText.y + 20, 64, 'GirlFriend Position');
        opponentinputtext = new FlxUIInputText(15, gfInputText.y + 50, 200, "", 8);
        var ylabel = new FlxText(15, opponentinputtext.y + 20, 64, 'Opponent Position');
        zoominputtext = new FlxUIInputText(15, opponentinputtext.y + 50, 200, "", 8);
        var elabel = new FlxText(15, zoominputtext.y + 20, 64, 'Default Zoom');
        dirinputtext = new FlxUIInputText(15, zoominputtext.y + 50, 200, "", 8);
        var directorycoollabel = new FlxText(15, dirinputtext.y + 20, 64, 'Stage Name');

        var saveStuff:FlxButton = new FlxButton(240, 20, "Save Stage", function() {
        saveStage(swagStage);
        });
       /* var loadStuff:FlxButton = new FlxButton(240, 70, "Load Stage", function() {
        loadStage();
        });
         */
           var tab_group_settings = new FlxUI(null, UI_stagebox);
           tab_group_settings.name = "Settings";
           tab_group_settings.add(saveStuff);
           tab_group_settings.add(bfInputText);
           //tab_group_settings.add(loadStuff);
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
    function searchForLayer() {
        var assetName:String = directoryInputText.text.trim();
        var directoryLayer:String = "images/" + assetName + ".png";
        if(assetName != null && assetName.length > 0) {
        if (Paths.fileExists(directoryLayer, IMAGE)){
        #if MODS_ALLOWED
        createdLayer.loadGraphic(Paths.mods(directoryLayer));
        #else
        createdLayer.loadGraphic(Paths.getPath(directoryLayer, IMAGE));
        #end
        createdLayer.visible = true;
    }
    else{
        createdLayer.visible = false;
    }
}
else{
    createdLayer.visible = false;
}
    }
    function deleteLayer() {
        remove(createdLayer);
      }
    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
    if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
        if (sender == scaleStepper)
			{   var stageSwag:LayerFile = {
                name: nameInputText.text, 
                directory: directoryInputText.text, 
                xAxis: Std.parseFloat(xInputText.text), 
                yAxis:  Std.parseFloat(yInputText.text), 
                scrollY: Std.parseFloat(stepperscrollX.text), 
                scrollX: Std.parseFloat(stepperscrollY.text), 
                scale: scaleStepper.value
                };
				stageSwag.scale = sender.value;
                createdLayer.setGraphicSize(Std.int(createdLayer.width * stageSwag.scale));
		}
    }
}
    
   override public function update(elapsed:Float) {

      super.update(elapsed);

      searchForLayer();
      
      if(swagStage == null) {
      swagStage = {
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
      else{
      var STRING = bfInputText.text.trim().split(", ");
      var x = Std.parseInt(STRING[0].trim());
      var y = Std.parseInt(STRING[1].trim());
      swagStage.boyfriend = [x, y];

      var STRING2 = gfInputText.text.trim().split(", ");
      var x2 = Std.parseInt(STRING2[0].trim());
      var y2 = Std.parseInt(STRING2[1].trim());
      swagStage.girlfriend = [x2, y2];

      var STRING3 = opponentinputtext.text.trim().split(", ");
      var x3 = Std.parseInt(STRING3[0].trim());
      var y3 = Std.parseInt(STRING3[1].trim());
      swagStage.opponent = [x3, y3];
      }
      
      swagStage.defaultZoom = Std.parseFloat(zoominputtext.text);
      swagStage.name = dirinputtext.text;


      if (FlxG.keys.pressed.LEFT) {
        createdLayer.x -= 1;
        xInputText.text = createdLayer.x + "";
      }
      else if (FlxG.keys.pressed.RIGHT) {
        createdLayer.x += 1;
        xInputText.text = createdLayer.x + "";
      }
      else if (FlxG.keys.pressed.UP) {
        createdLayer.y -= 1;
        yInputText.text = createdLayer.y + "";
      }
      else if (FlxG.keys.pressed.DOWN) {
        createdLayer.y += 1; 
        yInputText.text = createdLayer.y + "";
      }

     if (FlxG.keys.justPressed.R) {
        FlxG.camera.zoom = 1;
     }
     if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3) {
        FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
        if(FlxG.camera.zoom > 3) FlxG.camera.zoom = 3;
    }
    if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) {
        FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
        if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
    } 
    camMenu.zoom = FlxG.camera.zoom;
    if (FlxG.keys.justPressed.ESCAPE) {

            if(goToPlayState) {
                MusicBeatState.switchState(new PlayState());
            } else {
                MusicBeatState.switchState(new editors.MasterEditorMenu());
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
            }
            FlxG.mouse.visible = false;
            return;
    }
}

 
private static var _file:FileReference;
public static function saveStage(stageFile:StageFile) {
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

}