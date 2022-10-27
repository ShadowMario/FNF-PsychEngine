package editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;

class StageEditorState extends MusicBeatState
{
    public var graphicName:FlxInputText;

    override function create() 
    {
        graphicName = new FlxInputText(50,10,200);
        add(graphicName);
        super.create();
    }
}