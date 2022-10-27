package editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.ui.FlxButton;
import flixel.FlxCamera;

class StageEditorState extends MusicBeatState
{
    public var graphicName:FlxInputText;
    public var xInput:FlxInputText;
    public var yInput:FlxInputText;
    public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
    public var console:FlxText;
    public var spriteArray:Array<FlxSprite> = [];
    public var loadedSpriteArray:Array<String> = [];
    public var idArray:Array<String> = [];
    override function create() 
    {
        FlxG.mouse.visible = true;

        camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

        graphicName = new FlxInputText(10,30,200);
        add(graphicName);
        graphicName.cameras = [camHUD];

        var graphicTxt:FlxText = new FlxText(10,10,'Graphic Path');
        add(graphicTxt);
        graphicTxt.cameras = [camHUD];

        xInput = new FlxInputText(20,60,50);
        add(xInput);
        xInput.cameras = [camHUD];

        yInput = new FlxInputText(90,60,50);
        add(yInput);
        yInput.cameras = [camHUD];

        var xyTxt:FlxText = new FlxText(10,45,'Graphic Coordinates');
        add(xyTxt);
        xyTxt.cameras = [camHUD];

        var xTxt:FlxText = new FlxText(10,60,'X');
        add(xTxt);
        xTxt.cameras = [camHUD];

        var yTxt:FlxText = new FlxText(80,60,'Y');
        add(yTxt);
        yTxt.cameras = [camHUD];

        var addGraphic:FlxButton = new FlxButton(10, 90, "Add Graphic", function()
        {
            var sprite:FlxSprite = new FlxSprite(Std.parseInt(xInput.text), Std.parseInt(yInput.text));
            sprite.loadGraphic(Paths.image(graphicName.text));
            add(sprite);
            spriteArray.push(sprite);
            loadedSpriteArray.push(graphicName.text);
            var genID:String = '';
            for (i in 0...7)
            {
                genID += FlxG.random.int(0, 10);
            }
            idArray.push(genID);
            console.text += '\nAdded graphic: ' + graphicName.text + ', ID is ' + genID + ' (you need the id for manipulating an object)';

            graphicName.text = '';
            xInput.text = '';
            yInput.text = '';
        });
        add(addGraphic);
        addGraphic.cameras = [camHUD];

        var consoleLogDesc = new FlxText(10, FlxG.height - 300,'Console Log');
        add(consoleLogDesc);
        consoleLogDesc.cameras = [camHUD];

        console = new FlxText(10, FlxG.height - 290, '');
        add(console);
        console.cameras = [camHUD];

        super.create();
    }

    override function update(e:Float) {
        super.update(e);

        Main.fpsVar.x = Application.current.window.width - Main.fpsVar.width - 10;
    }
}