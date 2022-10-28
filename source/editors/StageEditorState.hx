package editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.ui.FlxButton;
import flixel.FlxCamera;
import CoolUtil.FileSaveContext;

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
    public var zoomInput:FlxInputText;
    public var idInput:FlxInputText;

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
            console.text += '\nAdded graphic: ' + graphicName.text + ', ID is ' + genID + ' (you need the id for removing an object)';

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

        zoomInput = new FlxInputText(10,140,50);
        add(zoomInput);
        zoomInput.cameras = [camHUD];

        var zoomTxt:FlxText = new FlxText(10,120,'Stage Zoom');
        add(zoomTxt);
        zoomTxt.cameras = [camHUD];

        var idTxt:FlxText = new FlxText(10,190,'Object ID (see console)');
        add(idTxt);
        idTxt.cameras = [camHUD];

        idInput = new FlxInputText(10,210,200);
        add(idInput);
        idInput.cameras = [camHUD];

        var removeGraphic:FlxButton = new FlxButton(10, 250, "Remove Graphic", function()
        {
            for (i in 0...idArray.length)
            {
                if (idArray[i] == idInput.text)
                {
                    remove(spriteArray[i]);
                    spriteArray.remove(spriteArray[i]);
                    idArray.remove(idArray[i]);
                    loadedSpriteArray.remove(loadedSpriteArray[i]);
                    console.text += '\nRemoved item.';
                }
            }
        });
        add(removeGraphic);
        removeGraphic.cameras = [camHUD];

        var saveStage:FlxButton = new FlxButton(0,FlxG.height - 90, "Save Stage as .pyst", function()
        {
            var string:String = '';
            for (num in 0...spriteArray.length)      
            {
                var i = spriteArray[num];
                string += '\nSTAGESPRITE:' + i.x + ',' + i.y + '/' + loadedSpriteArray[num];
            }
            string += '\nSTAGEINFO:' + camGame.zoom + '/' + '0,0-0,0';
            CoolUtil.saveFile({
                content: string,
                fileDefaultName: 'New Stage',
                format: 'pyst'
            });
        });
        add(saveStage);
        saveStage.cameras = [camHUD];

        super.create();
    }

    override function update(e:Float) {
        super.update(e);

        if (controls.BACK)
        {
            Main.fpsVar.x = 10;
            Main.fpsVar.y = 0;
            Main.fpsVar.alpha = 1;
            MusicBeatState.switchState(new MasterEditorMenu());
        }
        else
        {
            Main.fpsVar.x = Application.current.window.width - Main.fpsVar.width - 10;
            Main.fpsVar.y = Application.current.window.height - Main.fpsVar.height - 10;
            Main.fpsVar.alpha = 0.3;
        }

        camGame.zoom = Std.parseFloat(zoomInput.text);
    }
}