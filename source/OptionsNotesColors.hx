package;

import options.screens.NotesMenu;
import openfl.desktop.Clipboard;
import flixel.addons.display.shapes.FlxShape;
import haxe.io.Bytes;
import lime.ui.FileDialogType;
import lime.ui.FileDialog;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxButtonPlus;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIInputText;
import NoteShader.ColoredNoteShader;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.Lib;

class OptionsNotesColors extends MusicBeatState {
	var selectionLevel:Int = 0;
	
	var redChannel:Array<FlxSprite> = [];
	var greenChannel:Array<FlxSprite> = [];
	var blueChannel:Array<FlxSprite> = [];

	var labels:Array<Alphabet> = [];

	var selectedChannel:Int = 0;
	
	var arrowSelectorThingy:FlxSprite;

	var colors:Array<FlxColor> = [
		new FlxColor(Settings.engineSettings.data.arrowColor0),
		new FlxColor(Settings.engineSettings.data.arrowColor1),
		new FlxColor(Settings.engineSettings.data.arrowColor2),
		new FlxColor(Settings.engineSettings.data.arrowColor3)
	];
	var arrowSprites:Array<FlxSprite> = [];
	var selectedArrow:Int = 0;

	public override function new() {
		super();

		CoolUtil.addWhiteBG(this).color = 0xFF7EACCD;


		var arrowAnimsNames = ["purple0", "blue0", "green0", "red0"];
		for (i in 0...4)
		{
			var arrow0:FlxSprite = new FlxSprite((FlxG.width / 2) + ((50 + (200 * (i - 2.25))) * 0.7), 75);
			arrow0.frames = Paths.getSparrowAtlas("NOTE_assets_colored", "shared");
			arrow0.animation.addByPrefix("arrow", arrowAnimsNames[i]);
			arrow0.animation.play("arrow");
			arrow0.shader = new ColoredNoteShader(colors[i].red, colors[i].green, colors[i].blue, false);
			arrow0.antialiasing = true;
			arrow0.setGraphicSize(Std.int(arrow0.width * 0.7));
			arrowSprites.push(arrow0);
		}
		arrowSelectorThingy = new FlxSprite(arrowSprites[0].x + 10, arrowSprites[0].y + 10);
		arrowSelectorThingy.loadGraphic(Paths.image("optionsArrowSelector", "shared"));
		arrowSelectorThingy.antialiasing = true;
		add(arrowSelectorThingy);
		for (i in 0...arrowSprites.length)
		{
			add(arrowSprites[i]);
		}


		var labels = ["R", "G", "B"];
		var lastLabelPos:Float = 0;
		for (i in 0...3) {
			var label = new Alphabet(0, 265 + (75 * i), labels[i], true, false);
			//label.x = 
			this.labels.push(label);
			add(label);
			
			var obj:Array<FlxSprite> = switch(i) {
				case 0: redChannel;
				case 1: greenChannel;
				case 2: blueChannel;
				default: redChannel;
			}
			
			var offset:Float = 0;
			for (channel in 0...3) {
				var number = new FlxSprite((FlxG.width / 2) + (40 * channel), 265 + (75 * i) + 2);
				number.frames = Paths.getSparrowAtlas("alphabet", "preload");
				for (num in 0...10) {
					number.animation.addByPrefix(Std.string(num), Std.string(num), 24, true);
				}
				number.animation.play("0");
				number.antialiasing = true;
				number.colorTransform.redMultiplier = number.colorTransform.greenMultiplier = number.colorTransform.blueMultiplier = 0;
				number.colorTransform.redOffset = number.colorTransform.greenOffset = number.colorTransform.blueOffset = 255;
				add(number);
				obj.push(number);
				offset = number.x - (FlxG.width / 2);
			}
			label.x = lastLabelPos = (FlxG.width / 2) - offset - label.width;
		}
		var labels = ["Reset"];
		for (i in 0...labels.length) {
			var a = new Alphabet(0, 300 + (75 * (3 + i)), labels[i], true);
			a.x = lastLabelPos;
			this.labels.push(a);
			add(a);
		}
		updateChannels();
	}
	
	public function updateChannels(forceBump:Bool = false) {
		var arrow = arrowSprites[selectedArrow];
		var color = FlxColor.fromRGBFloat(cast(arrow.shader, ColoredNoteShader).r.value[0], cast(arrow.shader, ColoredNoteShader).g.value[0], cast(arrow.shader, ColoredNoteShader).b.value[0]);
		var strRed = Std.string(color.red);
		while (strRed.length < 3) strRed = " " + strRed;
		var strGreen = Std.string(color.green);
		while (strGreen.length < 3) strGreen = " " + strGreen;
		var strBlue = Std.string(color.blue);
		while (strBlue.length < 3) strBlue = " " + strBlue;
		
		for (channel in 0...3) {
			var channelArray:Array<FlxSprite> = switch(channel) {
				case 0: redChannel;
				case 1: greenChannel;
				case 2: blueChannel;
				case _: redChannel;
			};
			var string:String = switch(channel) {
				case 0: strRed;
				case 1: strGreen;
				case 2: strBlue;
				case _: strRed;
			};
			for (i in 0...string.length) {
				var num = string.charAt(i);
				if (num == " ") {
					if (i == string.length - 1) {
						channelArray[i].visible = true;
						if (channelArray[i].animation.curAnim.name != "0" || forceBump) channelArray[i].offset.y = 10;
						channelArray[i].animation.play("0");
					}
					else
						channelArray[i].visible = false;
				} else {
					if (channelArray[i].animation.curAnim.name != num || forceBump) channelArray[i].offset.y = 10;
					channelArray[i].visible = true;
					channelArray[i].animation.play(num);
				}
			}	
		}
		
	}
	
	var changeAm:Float = 0;
	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.BACK) {
			selectionLevel--;
			switch (selectionLevel) {
				case -1:
					for(k=>arrow in arrowSprites) {
						var shader = cast(arrow.shader, ColoredNoteShader);
						Reflect.setField(Settings.engineSettings.data, 'arrowColor$k', FlxColor.fromRGBFloat(shader.r.value[0], shader.g.value[0], shader.b.value[0]));
					}
					FlxG.switchState(new NotesMenu());
			}
		}
		switch(selectionLevel) {
			case 0:
				if (controls.ACCEPT) {
					selectionLevel++;
				}
				var oldSel = selectedArrow;
				if (controls.RIGHT_P) selectedArrow++;
				if (controls.LEFT_P) selectedArrow--;
				if (selectedArrow < 0) selectedArrow = 3;
				if (selectedArrow > 3) selectedArrow = 0;
				if (oldSel != selectedArrow)
					updateChannels(true);
				for (channel=>e in [redChannel, greenChannel, blueChannel]) {
					for (e in e) {
						e.offset.x = FlxMath.lerp(e.offset.x, 0, 0.25 * 30 * elapsed);
						e.alpha = FlxMath.lerp(e.alpha, 1, 0.25 * 30 * elapsed);
					}
				}
				for (channel=>l in labels) {
					
					l.offset.x = FlxMath.lerp(l.offset.x, 0, 0.25 * 50 * elapsed);
					l.alpha = FlxMath.lerp(l.alpha, 1, 0.25 * 50 * elapsed);
				}
			case 1:
				if (controls.DOWN_P) selectedChannel++;
				if (controls.UP_P) selectedChannel--;
				if (selectedChannel < 0) selectedChannel = labels.length - 1;
				if (selectedChannel >= labels.length) selectedChannel = 0;

				var changevalue = elapsed * (FlxG.keys.pressed.SHIFT ? 75 : 30);
				if (FlxG.keys.pressed.RIGHT) {
					switch(selectedChannel) {
						case 0:
							cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).r.value = [CoolUtil.wrapFloat(cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).r.value[0] + (changevalue / 255), 0, 1)];
						case 1:
							cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).g.value = [CoolUtil.wrapFloat(cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).g.value[0] + (changevalue / 255), 0, 1)];
						case 2:
							cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).b.value = [CoolUtil.wrapFloat(cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).b.value[0] + (changevalue / 255), 0, 1)];
					}
				} else if (FlxG.keys.pressed.LEFT) {
					switch(selectedChannel) {
						case 0:
							cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).r.value = [CoolUtil.wrapFloat(cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).r.value[0] - (changevalue / 255), 0, 1)];
						case 1:
							cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).g.value = [CoolUtil.wrapFloat(cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).g.value[0] - (changevalue / 255), 0, 1)];
						case 2:
							cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).b.value = [CoolUtil.wrapFloat(cast(arrowSprites[selectedArrow].shader, ColoredNoteShader).b.value[0] - (changevalue / 255), 0, 1)];
					}
				}

				for (channel=>e in [redChannel, greenChannel, blueChannel]) {
					for (e in e) {
						e.offset.x = FlxMath.lerp(e.offset.x, channel == selectedChannel ? -35 : 0, 0.25 * 30 * elapsed);
						e.alpha = FlxMath.lerp(e.alpha, channel == selectedChannel ? 1 : 0.4, 0.25 * 30 * elapsed);
					}
				}
				for (channel=>l in labels) {
					
					l.offset.x = FlxMath.lerp(l.offset.x, channel == selectedChannel ? -35 : 0, 0.25 * 50 * elapsed);
					l.alpha = FlxMath.lerp(l.alpha, channel == selectedChannel ? 1 : 0.4, 0.25 * 50 * elapsed);
				}

				if (selectedChannel == 3 && controls.ACCEPT) {
					// resets current note
					var shader = cast(arrowSprites[selectedArrow].shader, ColoredNoteShader);
					var color:FlxColor = switch(selectedArrow) {
						case 0:
							0xFFC24B99;
						case 1:
							0xFF00FFFF;
						case 2:
							0xFF12FA05;
						case 3:
							0xFFF9393F;
						case _:
							0xFFFFFFFF;
					}
					shader.r.value = [color.redFloat];
					shader.g.value = [color.greenFloat];
					shader.b.value = [color.blueFloat];
				}
		}


		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V) { // CTRL+V
			var clipboardText = Clipboard.generalClipboard.getData(TEXT_FORMAT, CLONE_PREFERRED);
			if (clipboardText != null) {
				var parsedColor:Null<FlxColor> = FlxColor.fromString(clipboardText);
				if (parsedColor != null) {
					// color found!!!!
					var shader = cast(arrowSprites[selectedArrow].shader, ColoredNoteShader);
					shader.r.value = [parsedColor.redFloat];
					shader.g.value = [parsedColor.greenFloat];
					shader.b.value = [parsedColor.blueFloat];
				}
			}
		}
		updateChannels();

		for (channel=>e in [redChannel, greenChannel, blueChannel]) {
			for (e in e) {
				e.offset.y = FlxMath.lerp(e.offset.y, 0, 0.25 * 200 * elapsed);
			}
		}

		arrowSelectorThingy.x = FlxMath.lerp(arrowSelectorThingy.x, arrowSprites[selectedArrow].x + 10, 0.25 * 120 * elapsed);
	}
}