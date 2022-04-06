package;

import openfl.events.IOErrorEvent;
import openfl.events.ErrorEvent;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import openfl.system.System;
import sys.io.Process;
import openfl.events.Event;
import cpp.vm.Thread;
import flixel.ui.FlxBar;
import flixel.FlxG;
import openfl.net.URLLoader;
import openfl.net.URLStream;
import flixel.addons.ui.FlxUIInputText;
import flash.display.PNGEncoderOptions;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import sys.FileSystem;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.format.JsonParser;
import sys.io.FileInput;
import sys.io.File;
import haxe.io.BytesInput;
import openfl.display.BitmapData;
import sys.io.FileOutput;
import flixel.FlxSprite;
import flixel.FlxCamera;
import haxe.zip.Entry;
import haxe.zip.Uncompress;
import haxe.zip.Writer;
import haxe.io.Bytes;
import flixel.ui.FlxButton;
import haxe.io.Input;
import flixel.addons.ui.FlxUITabMenu;

using StringTools;

class ModDownloadState extends MusicBeatState
{
	public static var curID:String;
	public static var daList:Array<String> = [];
	public static var cleanedDirectory = [];
	public static var idInputText:FlxUIInputText;
	public static var directory:String;

	private var camMain:FlxCamera;
	private var camHUD:FlxCamera;
	private var camInput:FlxCamera;
	private var camBG:FlxCamera;

	public static var writer:Writer;

	public static var coolParsed = null;

	public static var coolText:FlxText;

	public static var canExit:Bool = true;

	public static var alreadyPressed:Bool = false;

	public static var completed:Bool = false;

	public static var finished:Bool = false;

	public static var alreadyExcecuted:Bool = false;
	
	public static var copier:Process;
	public static var deleter:Process;
	public static var cleaner:Process;
	public static var extractor:Process;

	public static var fileConfirmed:Bool = false;
	
	var UI_box:FlxUITabMenu;

	override public function create()
	{
		camMain = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camInput = new FlxCamera();
		camInput.bgColor.alpha = 0;
		camBG = new FlxCamera();
		camBG.bgColor.alpha = 0;
		camInput.zoom = 2;

		var tabs = [{name: 'Input Gamebanana Mod ID Here', label: 'Input Gamebanana Mod ID Here'},];

		FlxG.cameras.reset(camMain);
		FlxG.cameras.add(camBG);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camInput);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF665AFF;
		bg.cameras = [camBG];
		add(bg);

		var swagBG:FlxSprite = new FlxSprite().makeGraphic(700, 700, FlxColor.BLACK, false);
		swagBG.screenCenter();
		swagBG.scrollFactor.set();
		swagBG.alpha = 0.5;
		swagBG.cameras = [camBG];
		add(swagBG);

		idInputText = new FlxUIInputText(15, 40, 200, '', 15);

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camInput];

		UI_box.resize(idInputText.width + 50, idInputText.height + 70);
		UI_box.screenCenter();
		UI_box.scrollFactor.set();
		add(UI_box);

		idInputText.screenCenter();
		idInputText.cameras = [camInput];
		add(idInputText);

		coolText = new FlxText(0, 0, 1000);
		coolText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		coolText.borderSize = 1;
		coolText.scrollFactor.set();
		coolText.text = "Mod Installer";
		coolText.screenCenter(X);
		coolText.y += 200;
		coolText.cameras = [camHUD];
		add(coolText);

		var coolButton = new FlxButton(0, 0, "Install Mod", function()
		{
			if (idInputText.text != "" && !alreadyPressed)
			{
				alreadyPressed = true;
				downloadInputtedMod();
			}
			else
			{
				if (!alreadyPressed)
				{
					coolText.text = "No Mod Found!";
				}
			}
		});

		coolButton.setGraphicSize(150, 70);
		coolButton.updateHitbox();
		coolButton.color = FlxColor.GREEN;
		coolButton.label.setFormat(Paths.font("pixel.otf"), 12, FlxColor.WHITE);
		coolButton.label.fieldWidth = 135;
		setLabelOffset(coolButton, 5, 22);
		coolButton.screenCenter(X);
		coolButton.y += 500;
		coolButton.cameras = [camHUD];
		add(coolButton);

		super.create();
	}

	public static function downloadInputtedMod()
	{
		curID = idInputText.text;

		var modDownload = new URLLoader();
		modDownload.dataFormat = BINARY;

		var websiteJSON = new haxe.Http("https://gamebanana.com/apiv8/Mod/" + curID + "/DownloadPage");

		websiteJSON.onData = function(swagDat:String)
		{
			canExit = false;

			coolParsed = cast haxe.Json.parse(swagDat);

			var URL = new URLRequest('${coolParsed._aFiles[0]._sDownloadUrl}'.replace(" ", "%20"));

			var coolFile = 'mods/${coolParsed._aFiles[0]._sFile}';
			var coolerFile = 'mods\\${coolParsed._aFiles[0]._sFile}';

			if (coolParsed._aFiles[0]._sFile.endsWith(".7z")
				|| coolParsed._aFiles[0]._sFile.endsWith(".rar")
				|| coolParsed._aFiles[0]._sFile.endsWith(".bnp")
				|| coolParsed._aFiles[0]._sFile.endsWith(".json"))
			{
				coolText.text = 'Error! File Extension Must Be .zip!';
				canExit = true;
				alreadyPressed = false;
				return;
			}

			coolText.text = 'Downloading ${coolParsed._aFiles[0]._sFile}...';

			var writtenFile:FileOutput = File.write('mods/' + coolParsed._aFiles[0]._sFile, true);

			modDownload.addEventListener(IOErrorEvent.IO_ERROR, function(errorThrown)
			{
				coolText.text = 'Error! Could not download ${coolParsed._aFiles[0]._sFile}!';
			});
			modDownload.addEventListener(Event.COMPLETE, function(done)
			{
				var swagDate:ByteArray = new ByteArray();
				modDownload.data.readBytes(swagDate, 0, modDownload.data.length - modDownload.data.position);
				writtenFile.writeBytes(swagDate, 0, swagDate.length);
				writtenFile.flush();

				writtenFile.close();

				var coolFile = 'mods/${coolParsed._aFiles[0]._sFile}';
				var coolerFile = 'mods\\${coolParsed._aFiles[0]._sFile}';

				for (file in FileSystem.readDirectory('mods/'))
				{
					if (file.endsWith('.zip'))
					{
						coolText.text = 'Extracting .zip...';
						extractor = new Process('powershell -command "Expand-Archive $coolFile ${coolFile.replace('.zip', '')}" && del /q "$coolerFile"');
						extractor.close();
					}
				}
				completed = true;
			});

			modDownload.load(URL);
		}

		websiteJSON.onError = function(error)
		{
			coolText.text = "No Mod Found!";
		}
		websiteJSON.request();
	}

	function setLabelOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}

	override public function update(elapsed:Float)
	{
		if (coolParsed != null)
		{
			var coolFile = 'mods/${coolParsed._aFiles[0]._sFile}';
			var coolerFile = 'mods\\${coolParsed._aFiles[0]._sFile}';

			if (completed)
			{
				if (FileSystem.exists(coolFile.replace('.zip', ''))
					&& FileSystem.readDirectory(coolFile.replace('.zip', '') + '/') != null)
				{
					for (folder in FileSystem.readDirectory(coolFile.replace('.zip', '') + '/'))
					{
						// If the folder and zip file already exists, delete it, so we don't experience a crash
						if (FileSystem.exists('mods/$folder') && FileSystem.exists(coolFile.replace('.zip', '')) && !fileConfirmed)
						{
							coolText.text = 'You Already Have This Mod Installed!';

							if (!alreadyExcecuted)
							{
								cleaner = new Process('rmdir /s /q "${coolerFile.replace('.zip', '')}"');
                                cleaner.close();
								alreadyExcecuted = true;
							}
							canExit = true;
							alreadyPressed = false;

						}
						else
						{
							coolText.text = 'Cleaning Up...';

							if (!alreadyExcecuted)
							{
								// Only works on windows, sorry linux and mac users :(
								// Execute commands IN ORDER, so like, when the command is finished, the next command'll execute
								// Using process to stop command line floods
							    copier = new Process('robocopy "${coolerFile.replace('.zip', '')}/$folder" "mods/$folder" /e & rmdir /s /q "${coolerFile.replace('.zip', '')}"');
								copier.close();
								fileConfirmed = true;
								alreadyExcecuted = true;
							}

							coolText.text = 'Finished Downloading $folder\nLocated In: "mods/$folder"';

							finished = true;

							canExit = true;
							alreadyPressed = false;
						}
					}
				}
			}

			if (FileSystem.exists(coolFile.replace('.zip', '')) && finished && !fileConfirmed) 
			{
				for (folder in FileSystem.readDirectory(coolFile.replace('.zip', '') + '/'))
				{
					if (FileSystem.exists('mods/$folder'))
					{
						if (FileSystem.readDirectory('mods/$folder/') != null
							&& !FileSystem.readDirectory('mods/$folder/').contains('pack.json'))
						{
							coolText.text = 'This Is Not A Psych Engine Mod!';

							if (!alreadyExcecuted)
							{
								deleter = new Process('rmdir /s /q "mods/$folder"');
								deleter.close();
								alreadyExcecuted = true;
							}

							canExit = true;
							alreadyPressed = false;
						}
					}
				}
			}
		}

		if (controls.BACK && canExit && !idInputText.hasFocus)
		{
			MusicBeatState.switchState(new ModsMenuState());
		}

		super.update(elapsed);
	}
}
