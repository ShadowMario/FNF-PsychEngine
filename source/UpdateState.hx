package ;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import openfl.events.IOErrorEvent;
import openfl.events.ErrorEvent;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import openfl.system.System;
import sys.io.Process;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import sys.Http;
import cpp.vm.Thread;
import flixel.ui.FlxBar;
import flixel.FlxG;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLStream;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;
/**
 * ...
 * @author YoshiCrafter29
 */
class UpdateState extends MusicBeatState
{
	public var fileList:Array<String> = [];
	public var baseURL:String;
	public var downloadedFiles:Int = 0;
	public var percentLabel:FlxText;
	public var currentFileLabel:FlxText;
	public var totalFiles:Int = 0;
	
    var bg:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup<FlxSprite>();

	var bf:FlxSprite;

	var error:Bool = false;
	
	public function new(baseURL:String = "http://raw.githubusercontent.com/YoshiCrafter29/YC29Engine-Latest/main/", fileList:Array<String>) 
	{
		super();
		this.baseURL = baseURL;
		this.fileList = fileList;
		totalFiles = fileList.length;
	}

	var currentLoadedStream:URLLoader = null;
	var currentFile:String;
    
    var w = 775;
    var h = 550;

	function alright() {
		downloadedFiles++;
		percentLabel.text = '${Math.floor(downloadedFiles / totalFiles * 100)}%';
		if (fileList.length > 0) {
			doFile();
		} else {
			applyUpdate();
		}
	}

	function doFile() {
		oldBytesLoaded = 0;
		var f = fileList.shift();
		currentFile = f;
		if (f == null) {
			applyUpdate();
			return;
		};
		if (FileSystem.exists('./_cache/$f') && FileSystem.stat('./_cache/$f').size > 0) { // prevents redownloading of the entire thing after it failed
			alright();
			return;
		}
		var downloadStream = new URLLoader();
		currentLoadedStream = downloadStream;
		downloadStream.dataFormat = BINARY;

		//dumbass
		var request = new URLRequest('$baseURL/$f'.replace(" ", "%20"));

		
		
		
		var good = true;

		var label1 = '(${totalFiles - fileList.length}/${totalFiles})';
		var label2 = '( - / - )';
		var maxLength:Int = Std.int(Math.max(label1.length, label2.length));
		while(label1.length < maxLength) label1 = " " + label1;
		while(label2.length < maxLength) label2 += " ";
		currentFileLabel.text = 'Downloading File: $f\n$label1 | $label2';
		
		downloadStream.addEventListener(IOErrorEvent.IO_ERROR, function(e) {
			if (e.text.contains("404")) {
				
				trace('File not found: $f');
				alright();
			} else {
				openSubState(new MenuMessage('Failed to download $f. Make sure you have a working internet connection, and try again.\n\nError ID: ${e.errorID}\n${e.text}', [
					{
						label: "Retry",
						callback: function() {
							fileList.insert(0, f);
							doFile();
						}
					},
					{
						label: "Skip",
						callback: function() {
							doFile();
						}
					},
					{
						label: "Cancel",
						callback: function() {
							FlxG.switchState(new MainMenuState());
						}
					}
				]));
				persistentUpdate = false;
			}
		});
		downloadStream.addEventListener(Event.COMPLETE, function(e) {
			var array = [];
			var dir = [for (k => e in (array = f.replace("\\", "/").split("/"))) if (k < array.length - 1) e].join("/");
			FileSystem.createDirectory('./_cache/$dir');
			var fileOutput:FileOutput = File.write('./_cache/$f', true);

			var data:ByteArray = new ByteArray();
			downloadStream.data.readBytes(data, 0, downloadStream.data.length - downloadStream.data.position);
			fileOutput.writeBytes(data, 0, data.length);
			fileOutput.flush();

			fileOutput.close();
			alright();
		});
		downloadStream.addEventListener(ProgressEvent.PROGRESS, function(e) {
			var label1 = '(${totalFiles - fileList.length}/${totalFiles})';
			var label2 = '(${CoolUtil.getSizeLabel(Std.int(e.bytesLoaded))} / ${CoolUtil.getSizeLabel(Std.int(e.bytesTotal))})';
			
			var ll = CoolUtil.getSizeLabel(Std.int((e.bytesLoaded - oldBytesLoaded) / (t - oldTime)));
			percentLabel.text = '${[for(i in 0...ll.length) " "].join("")}     ${Math.floor(((downloadedFiles / totalFiles) + (e.bytesLoaded / e.bytesTotal / totalFiles)) * 100)}% (${ll}/s)';
			var maxLength:Int = Std.int(Math.max(label1.length, label2.length));
			while(label1.length < maxLength) label1 = " " + label1;
			while(label2.length < maxLength) label2 += " ";
			currentFileLabel.text = 'Downloading File: $f\n$label1 | $label2';
			
			oldTime = t;
			oldBytesLoaded = e.bytesLoaded;
		});


		downloadStream.load(request);

		
	}

	public function applyUpdate() {
		// apply update

		// copy file to prevent overriding issues
		File.copy('YoshiCrafterEngine.exe', 'temp.exe');

		// launch that file
		new Process('start /B temp.exe update', null);
		System.exit(0);
	}
	public override function create() {
		super.create();
		FlxG.autoPause = false;

		var loadingThingy = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, true);
        loadingThingy.pixels.lock();
        var color1 = FlxColor.fromRGB(0, 66, 119);
        var color2 = FlxColor.fromRGB(86, 0, 151);
        for(x in 0...loadingThingy.pixels.width) {
            for(y in 0...loadingThingy.pixels.height) {
                loadingThingy.pixels.setPixel32(x, y, FlxColor.fromRGB(
                    Std.int(FlxMath.remapToRange(((y / loadingThingy.pixels.height) * 1), 0, 1, color1.red, color2.red)),
                    Std.int(FlxMath.remapToRange(((y / loadingThingy.pixels.height) * 1), 0, 1, color1.green, color2.green)),
                    Std.int(FlxMath.remapToRange(((y / loadingThingy.pixels.height) * 1), 0, 1, color1.blue, color2.blue))
                ));
            }
        }
        loadingThingy.pixels.unlock();
        add(loadingThingy);
		

		for(x in 0...Math.ceil(FlxG.width / w)+1) {
            for(y in 0...(Math.ceil(FlxG.height / h)+1)) {
                // bg pattern
                var pattern = new FlxSprite(x * w, y * h);
                pattern.loadGraphic(Paths.image("loading/bgpattern", "preload"));
                pattern.antialiasing = true;
                bg.add(pattern);
            }
        }
        add(bg);

		bf = new FlxSprite(337.60, 27.30).loadGraphic(Paths.image("loading/bf", "preload"));
		bf.antialiasing = true;
        bf.screenCenter(X);
        add(bf);

        var loading = new FlxSprite().loadGraphic(Paths.image("loading/updating"));
        loading.scale.set(0.85, 0.85);
        loading.updateHitbox();
        loading.y = FlxG.height - (loading.height * 1.15);
        loading.screenCenter(X);
        loading.antialiasing = true;
        add(loading);


		
		var downloadBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 30, this, "downloadedFiles", 0, fileList.length);
		downloadBar.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);
		downloadBar.screenCenter(X);
		downloadBar.y = FlxG.height - 45;
		downloadBar.scrollFactor.set(0, 0);
		add(downloadBar);
		
		percentLabel = new FlxText(downloadBar.x, downloadBar.y + (downloadBar.height / 2), downloadBar.width, "0%");
		percentLabel.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		percentLabel.y -= percentLabel.height / 2;
		add(percentLabel);
		
		currentFileLabel = new FlxText(0, downloadBar.y - 10, FlxG.width, "");
		currentFileLabel.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		currentFileLabel.y -= percentLabel.height * 2;
		add(currentFileLabel);
	
		doFile();
	}

	var t:Float = 0;
	var oldTime:Float = 0;
	var oldBytesLoaded:Float = 0;
	public override function update(elapsed:Float) {
		t += elapsed; // for speed calculations

		bg.x = -(w * t / 4) % w;
		bg.y = -(h * t / 4) % h;
        super.update(elapsed);

		bf.angle = Math.sin(t / 10) * 10;
		
		super.update(elapsed);
	}
}