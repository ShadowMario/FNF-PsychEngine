package;

import flixel.*;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIPopup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * ...
 * @author 
 */
class Prompt extends MusicBeatSubstate
{
	var selected = 0;

	public var okc:Void->Void;
	public var cancelc:Void->Void;

	var buttons:FlxSprite = new FlxSprite(473.3, 450);
	var theText:String = '';
	var goAnyway:Bool = false;
	var UI_box:FlxUIPopup;
	var panel:FlxSprite;
	var panelbg:FlxSprite;
	var buttonAccept:FlxButton;
	var buttonNo:FlxButton;
	var cornerSize:Int = 10;

	public function new(promptText:String = '', defaultSelected:Int = 0, okCallback:Void->Void, cancelCallback:Void->Void, acceptOnDefault:Bool = false,
			option1:String = null, option2:String = null)
	{
		selected = defaultSelected;
		okc = okCallback;
		cancelc = cancelCallback;
		theText = promptText;
		goAnyway = acceptOnDefault;

		var op1 = 'OK';
		var op2 = 'CANCEL';

		if (option1 != null)
			op1 = option1;
		if (option2 != null)
			op2 = option2;
		buttonAccept = new FlxButton(473.3, 450, op1, function()
		{
			if (okc != null)
				okc();
			close();
		});
		buttonNo = new FlxButton(633.3, 450, op2, function()
		{
			if (cancelc != null)
				cancelc();
			close();
		});
		super();
	}

	override public function create():Void
	{
		super.create();
		if (goAnyway)
		{
			if (okc != null)
				okc();
			close();
		}
		else
		{
			panel = new FlxSprite(0, 0);
			panelbg = new FlxSprite(0, 0);
			makeSelectorGraphic(panel, 300, 150, 0xff999999);
			makeSelectorGraphic(panelbg, 304, 154, 0xff000000);
			// panel.makeGraphic(300, 150, 0xff999999);
			// panel.loadGraphic(Paths.image('ui/promptbg'));
			/*
				buttons.frames = Paths.getSparrowAtlas('ui/prompt_buttons');
				buttons.animation.addByIndices('but0', 'buttons', [0], '', 0);
				buttons.animation.addByIndices('but1', 'buttons', [1], '', 0);
				buttons.animation.play('but0');
				buttons.scrollFactor.set(); */
			panel.scrollFactor.set();
			panel.screenCenter();
			panelbg.scrollFactor.set();
			panelbg.screenCenter();

			add(panelbg);
			add(panel);
			add(buttonAccept);
			add(buttonNo);
			// add(buttons);
			var textshit:FlxText = new FlxText(buttonNo.width * 2, panel.y, 300, theText, 16);
			textshit.alignment = 'center';
			add(textshit);
			textshit.screenCenter();
			buttonAccept.screenCenter();
			buttonNo.screenCenter();
			buttonAccept.x -= buttonNo.width / 1.5;
			buttonAccept.y = panel.y + panel.height - 30;
			buttonNo.x += buttonNo.width / 1.5;
			buttonNo.y = panel.y + panel.height - 30;
			textshit.scrollFactor.set();
		}
	}

	/*
		override public function update(elapsed:Float):Void 
		{
			super.update(elapsed);
			
			
			
			if (!goAnyway){
				
				
				
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P){
				if (selected == 0){
					selected = 1;
				}else{
					selected = 0;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				//buttons.animation.play('but' + selected);
			}
			buttonAccept.color.brightness = 0.5;
			buttonNo.color.brightness = 0.5;
			if (selected == 0 ) buttonAccept.color.brightness = 0.9;
			if (selected == 1 ) buttonNo.color.brightness = 0.9;
			if (controls.ACCEPT ){
				if (selected == 0){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					if(okc != null)okc();
				}else{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					if(cancelc != null)cancelc();
				}
				close();
			}
			
			}
		}
	 */
	function makeSelectorGraphic(panel:FlxSprite, w, h, color:FlxColor)
	{
		panel.makeGraphic(w, h, color);
		panel.pixels.fillRect(new Rectangle(0, 190, panel.width, 5), 0x0);

		// Why did i do this? Because i'm a lmao stupid, of course
		// also i wanted to understand better how fillRect works so i did this shit lol???
		panel.pixels.fillRect(new Rectangle(0, 0, cornerSize, cornerSize), 0x0); // top left
		drawCircleCornerOnSelector(panel, false, false, color);
		panel.pixels.fillRect(new Rectangle(panel.width - cornerSize, 0, cornerSize, cornerSize), 0x0); // top right
		drawCircleCornerOnSelector(panel, true, false, color);
		panel.pixels.fillRect(new Rectangle(0, panel.height - cornerSize, cornerSize, cornerSize), 0x0); // bottom left
		drawCircleCornerOnSelector(panel, false, true, color);
		panel.pixels.fillRect(new Rectangle(panel.width - cornerSize, panel.height - cornerSize, cornerSize, cornerSize), 0x0); // bottom right
		drawCircleCornerOnSelector(panel, true, true, color);
	}

	function drawCircleCornerOnSelector(panel:FlxSprite, flipX:Bool, flipY:Bool, color:FlxColor)
	{
		var antiX:Float = (panel.width - cornerSize);
		var antiY:Float = flipY ? (panel.height - 1) : 0;
		if (flipY)
			antiY -= 2;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 1), Std.int(Math.abs(antiY - 8)), 10, 3), color);
		if (flipY)
			antiY += 1;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 2), Std.int(Math.abs(antiY - 6)), 9, 2), color);
		if (flipY)
			antiY += 1;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 3), Std.int(Math.abs(antiY - 5)), 8, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 4), Std.int(Math.abs(antiY - 4)), 7, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 5), Std.int(Math.abs(antiY - 3)), 6, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 6), Std.int(Math.abs(antiY - 2)), 5, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 8), Std.int(Math.abs(antiY - 1)), 3, 1), color);
	}
}
