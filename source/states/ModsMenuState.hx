package states;

import backend.WeekData;
import backend.Mods;

import flixel.ui.FlxButton;
import flixel.FlxBasic;
import openfl.display.BitmapData;
import flash.geom.Rectangle;
import lime.utils.Assets;
import tjson.TJSON as Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import flixel.util.FlxSpriteUtil;
import objects.AttachedSprite;
import flixel.addons.transition.FlxTransitionableState;

class ModsMenuState extends MusicBeatState
{
	var bg:FlxSprite;
	var icon:FlxSprite;
	var modName:Alphabet;
	var modDesc:FlxText;
	var modRestartText:FlxText;
	var modsList:ModsList = null;

	var bgList:FlxSprite;
	var buttonReload:MenuButton;
	//var buttonModFolder:MenuButton;
	var buttonEnableAll:MenuButton;
	var buttonDisableAll:MenuButton;
	var buttons:Array<MenuButton> = [];
	var toggleButton:MenuButton;

	var bgTitle:FlxSprite;
	var bgDescription:FlxSprite;
	var bgButtons:FlxSprite;

	var modsGroup:FlxTypedGroup<ModItem>;
	var curSelectedMod:Int = 0;
	
	var hoveringOnMods:Bool = true;
	var curSelectedButton:Int = 0;
	var modNameInitialY:Float = 0;

	var noModsSine:Float = 0;
	var noModsTxt:FlxText;

	public static var defaultColor:FlxColor = 0xFF665AFF;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		persistentUpdate = false;

		modsList = Mods.parseList();
		Mods.currentModDirectory = modsList.all[0] != null ? modsList.all[0] : '';

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = defaultColor;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		bgList = FlxSpriteUtil.drawRoundRect(new FlxSprite(40, 40).makeGraphic(340, 440, FlxColor.TRANSPARENT), 0, 0, 340, 440, 15, 15, FlxColor.BLACK);
		bgList.alpha = 0.6;
		add(bgList);

		modsGroup = new FlxTypedGroup<ModItem>();
		add(modsGroup);

		for (mod in modsList.all)
		{
			var modItem:ModItem = new ModItem(mod);
			if(modsList.disabled.contains(mod)) modItem.color = FlxColor.RED;
			modsGroup.add(modItem);
		}

		var mod:ModItem = modsGroup.members[curSelectedMod];
		if(mod != null) bg.color = mod.bgColor;

		//
		var buttonX = bgList.x;
		var buttonWidth = Std.int(bgList.width);
		var buttonHeight = 80;

		buttonReload = new MenuButton(buttonX, bgList.y + bgList.height + 20, buttonWidth, buttonHeight, "RELOAD", reload);
		add(buttonReload);
		
		var myY = buttonReload.y + buttonReload.bg.height + 20;
		/*buttonModFolder = new MenuButton(buttonX, myY, buttonWidth, buttonHeight, "MODS FOLDER", function() {
			var modFolder = Paths.mods();
			if(!FileSystem.exists(modFolder))
			{
				trace('created missing folder');
				FileSystem.createDirectory(modFolder);
			}
			CoolUtil.openFolder(modFolder);
		});
		add(buttonModFolder);*/

		buttonEnableAll = new MenuButton(buttonX, myY, buttonWidth, buttonHeight, "ENABLE ALL", function() {
			for (mod in modsGroup.members)
			{
				if(modsList.disabled.contains(mod.folder))
				{
					modsList.disabled.remove(mod.folder);
					modsList.enabled.push(mod.folder);
					mod.color = FlxColor.WHITE;
				}
			}
			updateModDisplayData();
			checkToggleButtons();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		});
		buttonEnableAll.bg.color = FlxColor.GREEN;
		buttonEnableAll.focusChangeCallback = function(focus:Bool) if(!focus) buttonEnableAll.bg.color = FlxColor.GREEN;
		add(buttonEnableAll);

		buttonDisableAll = new MenuButton(buttonX, myY, buttonWidth, buttonHeight, "DISABLE ALL", function() {
			for (mod in modsGroup.members)
			{
				if(modsList.enabled.contains(mod.folder))
				{
					modsList.enabled.remove(mod.folder);
					modsList.disabled.push(mod.folder);
					mod.color = FlxColor.RED;
				}
			}
			updateModDisplayData();
			checkToggleButtons();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		});
		buttonDisableAll.bg.color = FlxColor.RED;
		buttonDisableAll.focusChangeCallback = function(focus:Bool) if(!focus) buttonDisableAll.bg.color = FlxColor.RED;
		add(buttonDisableAll);
		checkToggleButtons();

		if(modsList.all.length < 1)
		{
			buttonDisableAll.visible = buttonDisableAll.enabled = false;
			buttonEnableAll.visible = true;
			buttonEnableAll.alpha = 0.4;

			var myX = bgList.x + bgList.width + 20;
			noModsTxt = new FlxText(myX, 0, FlxG.width - myX - 20, "NO MODS INSTALLED\nPRESS BACK TO EXIT OR INSTALL A MOD", 48);
			if(FlxG.random.bool(0.1)) noModsTxt.text += '\nBITCH.'; //meanie
			noModsTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			noModsTxt.borderSize = 2;
			add(noModsTxt);
			noModsTxt.screenCenter(Y);

			var txt = new FlxText(bgList.x + 15, bgList.y + 15, bgList.width - 30, "No Mods found.", 16);
			txt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE);
			add(txt);

			FlxG.autoPause = false;
			FlxG.mouse.visible = true;
			changeSelectedMod();
			return super.create();
		}
		//

		bgTitle = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite(bgList.x + bgList.width + 20, 40).makeGraphic(840, 180, FlxColor.TRANSPARENT), 0, 0, 840, 180, 15, 15, 0, 0, FlxColor.BLACK);
		bgTitle.alpha = 0.6;
		add(bgTitle);

		icon = new FlxSprite(bgTitle.x + 15, bgTitle.y + 15);
		add(icon);

		modNameInitialY = icon.y + 80;
		modName = new Alphabet(icon.x + 165, modNameInitialY, "", true);
		modName.scaleY = 0.8;
		add(modName);

		bgDescription = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite(bgTitle.x, bgTitle.y + 200).makeGraphic(840, 450, FlxColor.TRANSPARENT), 0, 0, 840, 450, 0, 0, 15, 15, FlxColor.BLACK);
		bgDescription.alpha = 0.6;
		add(bgDescription);
		
		modDesc = new FlxText(bgDescription.x + 15, bgDescription.y + 15, bgDescription.width - 30, "", 24);
		modDesc.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
		add(modDesc);

		var myHeight = 100;
		modRestartText = new FlxText(bgDescription.x + 15, bgDescription.y + bgDescription.height - myHeight - 25, bgDescription.width - 30, "* Moving or Toggling On/Off this Mod will restart the game.", 16);
		modRestartText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		add(modRestartText);

		bgButtons = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite(bgDescription.x, bgDescription.y + bgDescription.height - myHeight).makeGraphic(840, myHeight, FlxColor.TRANSPARENT), 0, 0, 840, myHeight, 0, 0, 15, 15, FlxColor.BLACK);
		bgButtons.alpha = 0.2;
		add(bgButtons);

		var buttonsX = bgButtons.x + 320;
		var buttonsY = bgButtons.y + 10;

		var button = new MenuButton(buttonsX, buttonsY, 80, 80, "TOP", function() moveModToPosition(0)); //Move to the top
		add(button);
		buttons.push(button);

		var button = new MenuButton(buttonsX + 100, buttonsY, 80, 80, "/\\", function() moveModToPosition(curSelectedMod - 1)); //Move up
		add(button);
		buttons.push(button);

		var button = new MenuButton(buttonsX + 200, buttonsY, 80, 80, "\\/", function() moveModToPosition(curSelectedMod + 1)); //Move down
		add(button);
		buttons.push(button);

		var button = new MenuButton(buttonsX + 300, buttonsY, 80, 80, "CFG", function() {}); //Config - TO DO
		button.enabled = false;
		button.alpha = 0.4;
		add(button);
		buttons.push(button);
		
		if(modsList.all.length < 2)
		{
			for (button in buttons)
			{
				button.enabled = false;
				button.alpha = 0.4;
			}
		}

		toggleButton = new MenuButton(buttonsX + 400, buttonsY, 80, 80, "?", function() //On/Off
		{
			var curMod:ModItem = modsGroup.members[curSelectedMod];
			var mod:String = curMod.folder;
			if(!modsList.disabled.contains(mod)) //Enable
			{
				modsList.enabled.remove(mod);
				modsList.disabled.push(mod);
			}
			else //Disable
			{
				modsList.disabled.remove(mod);
				modsList.enabled.push(mod);
			}
			curMod.color = modsList.disabled.contains(mod) ? FlxColor.RED : FlxColor.WHITE;

			if(curMod.mustRestart) waitingToRestart = true;
			updateModDisplayData();
			checkToggleButtons();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		});
		add(toggleButton);
		buttons.push(toggleButton);
		toggleButton.focusChangeCallback = function(focus:Bool) {
			if(!focus)
				toggleButton.bg.color = toggleButton.textOn.text == "ON" ? FlxColor.GREEN : FlxColor.RED;
		};

		if(modsList.all.length < 1)
		{
			for (button in buttons)
			{
				button.enabled = false;
				button.alpha = 0.4;
			}
			toggleButton.focusChangeCallback = null;
		}

		FlxG.mouse.visible = true;
		changeSelectedMod();
		super.create();
	}
	
	var nextAttempt:Float = 1;
	override function update(elapsed:Float)
	{
		if(controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			saveTxt();
			FlxG.mouse.visible = false;

			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(waitingToRestart)
			{
				//MusicBeatState.switchState(new TitleState());
				TitleState.initialized = false;
				TitleState.closedState = false;
				FlxG.sound.music.fadeOut(0.3);
				if(FreeplayState.vocals != null)
				{
					FreeplayState.vocals.fadeOut(0.3);
					FreeplayState.vocals = null;
				}
				FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
			}
			else MusicBeatState.switchState(new MainMenuState());
			return;
		}

		if(modsList.all.length > 0)
		{
			if(hoveringOnMods && modsList.all.length > 1)
			{
				var shiftMult:Int = FlxG.keys.pressed.SHIFT ? 4 : 1;
				if(controls.UI_DOWN_P)
					changeSelectedMod(shiftMult);
				else if(controls.UI_UP_P)
					changeSelectedMod(-shiftMult);
				else if(FlxG.mouse.wheel != 0)
					changeSelectedMod(-FlxG.mouse.wheel * shiftMult);
				else if(FlxG.keys.justPressed.END || FlxG.keys.justPressed.HOME)
				{
					if(FlxG.keys.justPressed.END) curSelectedMod = modsList.all.length-1;
					else curSelectedMod = 0;
					updateModDisplayData();
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					changeSelectedMod();
				}
			}

			if(hoveringOnMods)
			{
				if(controls.UI_RIGHT_P || controls.ACCEPT)
				{
					hoveringOnMods = false;
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				}
			}
			else if(controls.UI_LEFT_P)
			{
				hoveringOnMods = true;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
		}
		else
		{
			noModsSine += 180 * elapsed;
			noModsTxt.alpha = 1 - Math.sin((Math.PI * noModsSine) / 180);
			
			// Keep refreshing mods list every 2 seconds until you add a mod on the folder
			nextAttempt -= elapsed;
			if(nextAttempt < 0)
			{
				nextAttempt = 1;
				@:privateAccess
				Mods.updateModList();
				modsList = Mods.parseList();
				if(modsList.all.length > 0)
				{
					trace('mod(s) found! reloading');
					reload();
				}
			}
		}
		super.update(elapsed);
	}

	function changeSelectedMod(add:Int = 0)
	{
		var max = modsList.all.length - 1;
		if(max < 0) return;

		curSelectedMod += add;
		if(curSelectedMod < 0) curSelectedMod = max;
		else if(curSelectedMod > max) curSelectedMod = 0;
		
		updateModDisplayData();
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
	}

	var colorTween:FlxTween = null;
	function updateModDisplayData()
	{
		var curMod:ModItem = modsGroup.members[curSelectedMod];
		if(curMod == null)
		{
			return;
		}

		if(colorTween != null)
		{
			colorTween.cancel();
			colorTween.destroy();
		}
		colorTween = FlxTween.color(bg, 1, bg.color, curMod.bgColor, {onComplete: function(twn:FlxTween) colorTween = null});

		if(Math.abs(centerMod - curSelectedMod) > 2)
		{
			if(centerMod < curSelectedMod)
				centerMod = curSelectedMod - 2;
			else centerMod = curSelectedMod + 2;
		}
		updateItemPositions();

		icon.loadGraphic(curMod.icon.graphic, true, 150, 150);
		icon.antialiasing = curMod.icon.antialiasing;

		if(curMod.totalFrames > 0)
		{
			icon.animation.add("icon", [for (i in 0...curMod.totalFrames) i], curMod.iconFps);
			icon.animation.play("icon");
			icon.animation.curAnim.curFrame = curMod.icon.animation.curAnim.curFrame;
		}

		if(modName.scaleX != 0.8) modName.setScale(0.8);
		modName.text = curMod.name;
		var newScale = Math.min(620 / (modName.width / 0.8), 0.8);
		modName.setScale(newScale, Math.min(newScale * 1.35, 0.8));
		modName.y = modNameInitialY - (modName.height / 2);
		modRestartText.visible = curMod.mustRestart;
		modDesc.text = curMod.desc;

		if (modsList.disabled.contains(curMod.folder))
		{
			toggleButton.textOn.text = "OFF";
			toggleButton.textOff.text = "OFF";
		}
		else
		{
			toggleButton.textOn.text = "ON";
			toggleButton.textOff.text = "ON";
		}
		toggleButton.centerOnBg(toggleButton.textOn);
		toggleButton.textOn.x += toggleButton.x;
		toggleButton.textOn.y += toggleButton.y - 30;
		toggleButton.centerOnBg(toggleButton.textOff);
		toggleButton.textOff.x += toggleButton.x;
		toggleButton.textOff.y += toggleButton.y;
		toggleButton.focusChangeCallback(toggleButton.onFocus);
	}

	var centerMod:Int = 2;
	function updateItemPositions()
	{
		var maxVisible = Math.max(4, centerMod + 2);
		var minVisible = Math.max(0, centerMod - 2);
		for (i => mod in modsGroup.members)
		{
			if(mod == null)
			{
				trace('Mod #$i is null, maybe it was ' + modsList.all[i]);
				continue;
			}

			mod.visible = (i >= minVisible && i <= maxVisible);
			mod.x = bgList.x + 10;
			mod.y = bgList.y + (86 * (i - centerMod + 2)) + 10;
			
			mod.alpha = 0.6;
			if(i == curSelectedMod) mod.alpha = 1;
		}
	}

	var waitingToRestart:Bool = false;
	function moveModToPosition(?mod:String = null, position:Int = 0)
	{
		if(mod == null) mod = modsList.all[curSelectedMod];
		if(position >= modsList.all.length) position = 0;
		else if(position < 0) position = modsList.all.length-1;

		trace('Moved mod $mod to position $position');
		var id:Int = modsList.all.indexOf(mod);
		if(position == id) return;

		var curMod:ModItem = modsGroup.members[id];
		if(curMod == null) return;

		if(curMod.mustRestart || modsGroup.members[position].mustRestart) waitingToRestart = true;

		modsGroup.remove(curMod, true);
		modsList.all.remove(mod);
		//if(position > id) position--;
		modsGroup.insert(position, curMod);
		modsList.all.insert(position, mod);

		curSelectedMod = position;
		updateModDisplayData();
		updateItemPositions();
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
	}

	function checkToggleButtons()
	{
		buttonEnableAll.visible = buttonEnableAll.enabled = modsList.disabled.length > 0;
		buttonDisableAll.visible = buttonDisableAll.enabled = !buttonEnableAll.visible;
	}

	function reload()
	{
		saveTxt();
		FlxG.autoPause = ClientPrefs.data.autoPause;
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.resetState();
	}
	
	function saveTxt()
	{
		var fileStr:String = '';
		for (mod in modsList.all)
		{
			if(mod.trim().length < 1) continue;

			if(fileStr.length > 0) fileStr += '\n';

			var on = '1';
			if(modsList.disabled.contains(mod)) on = '0';
			fileStr += '$mod|$on';
		}

		var path:String = 'modsList.txt';
		File.saveContent(path, fileStr);
	}
}

class ModItem extends FlxSpriteGroup
{
	public var icon:FlxSprite;
	public var text:FlxText;
	public var totalFrames:Int = 0;

	// options
	public var name:String = 'Unknown Mod';
	public var desc:String = 'No description provided.';
	public var iconFps:Int = 10;
	public var bgColor:FlxColor = ModsMenuState.defaultColor;
	public var pack:Dynamic = null;
	public var folder:String = 'unknownMod';
	public var mustRestart:Bool = false;

	public function new(folder:String)
	{
		super();

		this.folder = folder;
		pack = Mods.getPack(folder);

		icon = new FlxSprite();
		icon.antialiasing = ClientPrefs.data.antialiasing;
		add(icon);

		text = new FlxText(90, 32, 230, "", 16);
		text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 2;
		text.y -= Std.int(text.height / 2);
		add(text);

		var isPixel = false;
		var bmp = Paths.cacheBitmap(Paths.mods('$folder/pack.png'));
		if(bmp == null)
		{
			bmp = Paths.cacheBitmap(Paths.mods('$folder/pack-pixel.png'));
			isPixel = true;
		}

		if(bmp != null)
		{
			icon.loadGraphic(bmp, true, 150, 150);
			if(isPixel) icon.antialiasing = false;
		}
		else icon.loadGraphic(Paths.image('unknownMod'), true, 150, 150);
		icon.scale.set(0.5, 0.5);
		icon.updateHitbox();
		
		this.name = folder;
		if(pack != null)
		{
			if(pack.name != null) this.name = pack.name;
			if(pack.description != null) this.desc = pack.description;
			if(pack.iconFramerate != null) this.iconFps = pack.iconFramerate;
			if(pack.color != null)
			{
				this.bgColor = FlxColor.fromRGB(pack.color[0] != null ? pack.color[0] : 170,
											  pack.color[1] != null ? pack.color[1] : 0,
											  pack.color[2] != null ? pack.color[2] : 255);
			}
			this.mustRestart = (pack.restart == true);
		}
		text.text = this.name;

		if(bmp != null)
		{
			totalFrames = Math.floor(bmp.width / 150) * Math.floor(bmp.height / 150);
			icon.animation.add("icon", [for (i in 0...totalFrames) i], iconFps);
			icon.animation.play("icon");
		}
	}
}

class MenuButton extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var textOn:Alphabet;
	public var textOff:Alphabet;
	public var icon:FlxSprite;
	public var onClick:Void->Void = null;
	public var enabled(default, set):Bool = true;
	public function new(x:Float, y:Float, width:Int, height:Int, ?text:String = null, ?img:BitmapData = null, onClick:Void->Void = null)
	{
		super(x, y);
		
		bg = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(width, height, FlxColor.TRANSPARENT), 0, 0, width, height, 15, 15, FlxColor.WHITE);
		bg.color = FlxColor.BLACK;
		bg.alpha = 0.6;
		add(bg);

		if(text != null)
		{
			textOn = new Alphabet(0, 0, "", false);
			textOn.setScale(0.6);
			textOn.text = text;
			textOn.alpha = 0.6;
			textOn.visible = false;
			centerOnBg(textOn);
			textOn.y -= 30;
			add(textOn);
			
			textOff = new Alphabet(0, 0, "", true);
			textOff.setScale(0.52);
			textOff.text = text;
			textOff.alpha = 0.6;
			centerOnBg(textOff);
			add(textOff);
		}
		else if(img != null)
		{
			icon = new FlxSprite().loadGraphic(img);
			centerOnBg(icon);
			add(icon);
		}

		this.onClick = onClick;
	}

	public var focusChangeCallback:Bool->Void = null;
	public var onFocus(default, set):Bool = false;
	public var ignoreCheck:Bool = false;
	private var _needACheck:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(!enabled)
		{
			onFocus = false;
			return;
		}

		if(!Controls.instance.controllerMode && FlxG.mouse.justMoved)
			onFocus = FlxG.mouse.overlaps(this);

		if(onFocus && onClick != null && FlxG.mouse.justPressed)
			onClick();

		if(_needACheck)
		{
			_needACheck = false;
			if(!Controls.instance.controllerMode)
				onFocus = FlxG.mouse.overlaps(this);
		}
	}

	function set_onFocus(newValue:Bool)
	{
		var lastFocus:Bool = onFocus;
		onFocus = newValue;
		if(onFocus != lastFocus)
		{
			bg.color = onFocus ? FlxColor.WHITE : FlxColor.BLACK;
			bg.alpha = onFocus ? 0.8 : 0.6;

			var focusAlpha = onFocus ? 1 : 0.6;
			if(textOn != null && textOff != null)
			{
				textOn.alpha = textOff.alpha = focusAlpha;
				textOn.visible = onFocus;
				textOff.visible = !onFocus;
			}
			else if(icon != null) icon.alpha = focusAlpha;
			if(focusChangeCallback != null) focusChangeCallback(newValue);
		}
		return newValue;
	}

	function set_enabled(newValue:Bool)
	{
		enabled = newValue;
		if(enabled) _needACheck = true;
		return newValue;
	}

	public function centerOnBg(spr:FlxSprite)
	{
		spr.x = bg.width/2 - spr.width/2;
		spr.y = bg.height/2 - spr.height/2;
	}
}