package states.editors.content;

import haxe.io.Path;
import flixel.util.FlxDestroyUtil;
import flash.net.FileFilter;

import backend.StageData;
import backend.ui.PsychUIButton;
import backend.ui.PsychUIRadioGroup;
import backend.ui.PsychUICheckBox;
import backend.ui.PsychUIEventHandler;
import states.editors.content.FileDialogHandler;

class PreloadListSubState extends MusicBeatSubstate implements PsychUIEvent
{
	var lockedList:Array<String>;
	var preloadList:Map<String, LoadFilters>;
	var preloadListKeys:Array<String> = [];
	var saveCallback:Map<String, LoadFilters>->Void;
	public function new(saveCallback:Map<String, LoadFilters>->Void, locked:Array<String> = null, list:Map<String, LoadFilters> = null)
	{
		this.saveCallback = saveCallback;
		lockedList = (lockedList != null) ? locked : [];
		preloadList = (list != null) ? list : [];
		
		for (k => v in preloadList)
			preloadListKeys.push(k);

		super();
	}

	var outputTxt:FlxText;
	var fileDialog:FileDialogHandler = new FileDialogHandler();
	var radioGrp:PsychUIRadioGroup;
	
	var removeButton:PsychUIButton;
	var lqCheckBox:PsychUICheckBox;
	var hqCheckBox:PsychUICheckBox;
	var smCheckBox:PsychUICheckBox;
	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.alpha = 0.8;
		bg.scale.set(520, 520);
		bg.updateHitbox();
		bg.screenCenter();
		bg.cameras = cameras;
		add(bg);

		var titleText:FlxText = new FlxText(0, bg.y + 30, 400, 'Preload List', 24);
		titleText.screenCenter(X);
		titleText.alignment = CENTER;
		titleText.cameras = cameras;
		add(titleText);

		var btn:PsychUIButton = new PsychUIButton(bg.x + bg.width - 40, bg.y, 'X', close, 40);
		btn.cameras = cameras;
		add(btn);
		
		outputTxt = new FlxText(24, 640, 800, '', 24);
		outputTxt.borderStyle = OUTLINE_FAST;
		outputTxt.borderSize = 1;
		outputTxt.cameras = cameras;
		outputTxt.alpha = 0;
		add(outputTxt);

		removeButton = new PsychUIButton(0, 0, 'X', function()
		{
			if(radioGrp.checked < 0) return;

			var name:String = getCurCheckedName();
			if(!preloadList.exists(name)) return;

			preloadList.remove(name);
			preloadListKeys.remove(name);
			radioGrp.labels = preloadListKeys;
			updateButtons();
		}, 20);
		removeButton.cameras = cameras;
		removeButton.normalStyle.bgColor = FlxColor.RED;
		removeButton.normalStyle.textColor = FlxColor.WHITE;
		add(removeButton);

		function updateFilters()
		{
			var name:String = getCurCheckedName();
			if(!preloadList.exists(name)) return;

			var filters:LoadFilters = 0;
			if(lqCheckBox.checked) filters |= LOW_QUALITY;
			if(hqCheckBox.checked) filters |= HIGH_QUALITY;
			if(smCheckBox.checked) filters |= STORY_MODE;
			preloadList.set(name, filters);
		}
		lqCheckBox = new PsychUICheckBox(bg.x + bg.width - 100, bg.y + bg.height - 130, 'Low Qual.', 0, updateFilters);
		hqCheckBox = new PsychUICheckBox(lqCheckBox.x, lqCheckBox.y + 22, 'High Qual.', 0, updateFilters);
		smCheckBox = new PsychUICheckBox(hqCheckBox.x, hqCheckBox.y + 22, 'Story Mode', 0, updateFilters);
		lqCheckBox.cameras = cameras;
		hqCheckBox.cameras = cameras;
		smCheckBox.cameras = cameras;
		add(lqCheckBox);
		add(hqCheckBox);
		add(smCheckBox);

		radioGrp = new PsychUIRadioGroup(bg.x + 60, bg.y + 80, preloadListKeys, 25, 15, false, 280);
		radioGrp.cameras = cameras;
		add(radioGrp);

		removeButton.x = radioGrp.x - 30;

		function addToList(path:Path, isFolder:Bool)
		{
			var exePath:String = Sys.getCwd().replace('\\', '/');
			if(path.dir.startsWith(exePath))
			{
				var pathStr:String = path.dir.substr(exePath.length);
				var split:Array<String> = pathStr.split('/');
				switch(split[0])
				{
					case 'assets', 'mods':
						for (i in 1...3)
						{
							switch(split[i])
							{
								case 'sounds', 'music', 'songs', 'images':
									split.shift();
									if(i == 2) split.shift();

									pathStr = split.join('/') + '/' + path.file;
									if(isFolder && !pathStr.endsWith('/')) pathStr += '/';

									if(!lockedList.contains(pathStr))
									{
										preloadList.set(pathStr, LOW_QUALITY|HIGH_QUALITY);
										preloadListKeys.push(pathStr);
										radioGrp.labels = preloadListKeys;
										showOutput('File added to preload: $pathStr');
									}
									else showOutput('File is already preloaded automatically!', true);
									return;
							}
						}
						showOutput('File must be inside images/music/songs subfolder!', true);
					default:
						showOutput('File must be inside assets/mods folder!', true);
				}
			}
			else showOutput('File is not inside Psych Engine\'s folder!', true);
		}

		var loadFileBtn:PsychUIButton = new PsychUIButton(0, bg.y + bg.height - 40, 'Load File', function()
		{
			if(!fileDialog.completed) return;
			
			fileDialog.open(null, 'Load a .PNG/.OGG File...', [new FileFilter('Image/Audio', '*.png;*.ogg')], function()
			{
				var path:Path = new Path(fileDialog.path.replace('\\', '/'));
	
				var ext:String = path.ext;
				if(ext != null) ext = ext.toLowerCase();
	
				switch(ext)
				{
					case 'png', 'ogg':
						addToList(path, false);
					default:
						showOutput('Unsupported Extension: $ext', true);
				}
			});
		});
		loadFileBtn.screenCenter(X);
		loadFileBtn.cameras = cameras;
		loadFileBtn.x -= 120;
		add(loadFileBtn);

		var loadFolderBtn:PsychUIButton = new PsychUIButton(0, bg.y + bg.height - 40, 'Load Folder', function()
		{
			if(!fileDialog.completed) return;

			fileDialog.openDirectory('Load a folder...', function()
			{
				addToList(new Path(fileDialog.path.replace('\\', '/')), true);
			});
		});
		loadFolderBtn.screenCenter(X);
		loadFolderBtn.cameras = cameras;
		add(loadFolderBtn);

		var saveBtn:PsychUIButton = new PsychUIButton(0, bg.y + bg.height - 40, 'Save', function()
		{
			if(!fileDialog.completed) return;

			if(saveCallback != null) saveCallback(preloadList);
			close();
		});
		saveBtn.screenCenter(X);
		saveBtn.cameras = cameras;
		saveBtn.x += 120;
		saveBtn.normalStyle.bgColor = FlxColor.GREEN;
		saveBtn.normalStyle.textColor = FlxColor.WHITE;
		add(saveBtn);

		updateButtons();
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		outputTime = Math.max(0, outputTime - elapsed);
		outputTxt.alpha = outputTime;
		if(!fileDialog.completed) return;
			
		if(controls.BACK)
		{
			close();
		}
		
		var checked:PsychUIRadioItem = radioGrp.checkedRadio;
		if(checked != null)
			removeButton.y = checked.y - 1;
	}

	public function UIEvent(id:String, sender:Dynamic)
	{
		//trace(id, sender);
		switch(id)
		{
			case PsychUIRadioGroup.CLICK_EVENT:
				updateButtons();
		}
	}

	function updateButtons()
	{
		var checked:PsychUIRadioItem = radioGrp.checkedRadio;
		if(checked != null)
		{
			var filters:LoadFilters = getCurLoadFilters();
			lqCheckBox.checked = (filters & LOW_QUALITY == LOW_QUALITY);
			hqCheckBox.checked = (filters & HIGH_QUALITY == HIGH_QUALITY);
			smCheckBox.checked = (filters & STORY_MODE == STORY_MODE);
		}

		var vis:Bool = (checked != null);
		removeButton.visible = removeButton.active = vis;
		lqCheckBox.visible = lqCheckBox.active = vis;
		hqCheckBox.visible = hqCheckBox.active = vis;
		smCheckBox.visible = smCheckBox.active = vis;
	}

	inline function getCurLoadFilters():LoadFilters
	{
		return (radioGrp.checkedRadio != null) ? preloadList.get(getCurCheckedName()) : 0;
	}

	inline function getCurCheckedName():String
	{
		return (radioGrp.checkedRadio != null) ? radioGrp.checkedRadio.text.text : '';
	}
	
	var outputTime:Float = 0;
	function showOutput(txt:String, isError:Bool = false)
	{
		outputTxt.color = isError ? FlxColor.RED : FlxColor.WHITE;
		outputTxt.text = txt;
		outputTime = 3;
		
		if(isError) FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
		else FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
	
	override function destroy()
	{
		for (member in members) FlxDestroyUtil.destroy(member);
		fileDialog = FlxDestroyUtil.destroy(fileDialog);
		super.destroy();
	}
}