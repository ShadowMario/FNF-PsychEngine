package charter;

import dev_toolbox.ToolboxMessage;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.*;

using StringTools;

class AddEventDialogue extends MusicBeatSubstate {
    var UI_Box:FlxUITabMenu;
    var callback:String->Array<String>->Void = null;
    var closeButton:FlxUIButton;
    var createButton:FlxUIButton;
    var addParamButton:FlxUIButton;
    var deleteParamButton:FlxUIButton;
    var funcParametersBasePos:Float = 0;
    var eventParams:Array<FlxUIInputText> = [];
    var mainWindow:FlxUI;
    var createParams:Array<String> = null;
    var createName:String = null;
	
	public static var lastName:String = "your_func";
	public static var lastParameters:Array<String> = [];

    var windowName:String = "";
    var okButtonText:String = "";
    public override function new(callback:String->Array<String>->Void, windowName:String = "Add an event", okButtonText:String = "Create Event", params:Array<String> = null, name:String = null) {
        super();
        this.callback = callback;
        this.windowName = windowName;
        this.okButtonText = okButtonText;
		this.createName = name == null ? lastName : name;
		this.createParams = params == null ? lastParameters : params;
    }
    public override function create() {
        super.create();

        cast(add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000, true)), FlxSprite).scrollFactor.set(0, 0);

        UI_Box = new FlxUITabMenu(null, [
            {
                name: 'main',
                label: windowName
            }
        ]);
        UI_Box.resize(400, 600);

        mainWindow = new FlxUI(null, UI_Box);
        mainWindow.name = 'main';

        var allowedChars = "0123456789_ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "ABCDEFGHIJKLMNOPQRSTUVWXYZ".toLowerCase(); // lazy af lmfaooo
        var functionNameLabel = new FlxUIText(10, 10, 380, "Function Name (Must only contain characters such as A-Z, 0-9 and _)");
        var functionNameBox = new FlxUIInputText(10, functionNameLabel.y + functionNameLabel.height, 380, createName);
        var functionParamsLabel = new FlxUIText(10, functionNameBox.y + functionNameBox.height + 10, 380, "Function Parameters");

        createButton = new FlxUIButton(200, 600 - 50, okButtonText, function() {
            var funcName = functionNameBox.text.trim();
            for(i in 0...funcName.length) {
                if (!allowedChars.contains(funcName.charAt(i))) {
                    openSubState(ToolboxMessage.showMessage("Error", 'Function name cannot contain "${funcName.charAt(i)}"'));
                    return;
                }
            }
			var params = [for (p in eventParams) p.text.trim()];
			lastName = funcName;
			lastParameters = params;
            callback(functionNameBox.text, params);
            close();
        });
        createButton.x -= createButton.width / 2;
        addParamButton = new FlxUIButton(200, 600 - 50, "Add Param", function() {
            var params = [for(p in eventParams) p.text.trim()];
            params.push("");
            setParameters(params);
        });
        addParamButton.x = createButton.x - createButton.width - 10;
        deleteParamButton = new FlxUIButton(200, 600 - 50, "Delete Last Param", function() {
            var params = [for(p in eventParams) p.text.trim()];
            params.pop();
            setParameters(params);
        });
        deleteParamButton.x = createButton.x + createButton.width + 10;

        funcParametersBasePos = functionParamsLabel.y + functionParamsLabel.height;

        mainWindow.add(functionNameLabel);
        mainWindow.add(functionNameBox);
        mainWindow.add(functionParamsLabel);
        mainWindow.add(createButton);
        mainWindow.add(addParamButton);
        mainWindow.add(deleteParamButton);
        UI_Box.addGroup(mainWindow);
        UI_Box.screenCenter();
        UI_Box.scrollFactor.set(0, 0);
        add(UI_Box);

        closeButton = new FlxUIButton(UI_Box.x + UI_Box.width - 20, UI_Box.y, "X", function() {
            close();
        });
        closeButton.resize(20, 20);
        closeButton.scrollFactor.set(0, 0);
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = 0xFFFFFFFF;
        add(closeButton);

        setParameters(createParams);
    }

    public function setParameters(params:Array<String>) {
        for(e in eventParams) {
            mainWindow.remove(e);
            remove(e);
            e.destroy();
        }
        eventParams = [];
        for(k=>p in params) {
            var eventParamBox = new FlxUIInputText(10, funcParametersBasePos + (k * 16), 380, p);
            // eventParamBox.text = p;
            eventParams.push(eventParamBox);
            mainWindow.add(eventParamBox);
        }
    }

    public override function update(elapsed) {
        super.update(elapsed);
    }
}