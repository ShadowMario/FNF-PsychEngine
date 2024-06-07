package substates;

import flixel.*;
import flixel.FlxSubState;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * ...
 * @author 
 */
class Prompt extends MusicBeatSubstate
{
	public var okc:Void->Void;
	public var cancelc:Void->Void;
	var theText:String = '';
	var goAnyway:Bool = false;
	var panel:FlxSprite;
	var panelText:FlxText;
	var buttonAccept:PsychUIButton;
	var buttonNo:PsychUIButton;
	public function new(promptText:String, ?okCallback:Void->Void = null, ?cancelCallback:Void->Void = null, ?acceptOnDefault:Bool=false) 
	{
		okc = okCallback;
		cancelc = cancelCallback;
		theText = promptText;
		goAnyway = acceptOnDefault;
		super();	
	}
	
	override public function create():Void 
	{
		super.create();
		if (goAnyway)
		{
			if(okc != null)okc();
			close();
		}
		else
		{
			panel = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			panel.setGraphicSize(300, 150);
			panel.updateHitbox();
			panel.alpha = 0.6;
			panel.scrollFactor.set();
			panel.screenCenter();
			add(panel);

			panelText = new FlxText(0, 0, 300, theText, 16);
			panelText.scrollFactor.set();
			panelText.alignment = CENTER;
			panelText.screenCenter();
			add(panelText);

			buttonAccept = new PsychUIButton(0, panel.y + panel.height - 30, 'OK', function()
			{
				if(okc != null) okc();
				close();
			});
			buttonAccept.scrollFactor.set();
			buttonAccept.screenCenter(X);
			buttonAccept.x -= 55;
			add(buttonAccept);

			buttonNo = new PsychUIButton(0, panel.y + panel.height - 30, 'CANCEL', function()
			{
				if(cancelc != null) cancelc();
				close();
			});
			buttonNo.scrollFactor.set();
			buttonNo.screenCenter(X);
			buttonNo.x += 55;
			add(buttonNo);
		}
	}
}