package;

import openfl.display.BlendMode;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import Prompt;
import lime.app.Application;
import flixel.util.FlxTimer;
import haxe.zip.Compress;
import haxe.zip.Entry;
import haxe.zip.Reader;
import JSEZip;
import haxe.zip.Uncompress;
import sys.io.File;
import openfl.utils.ByteArray;
import lime.utils.Bytes;
import openfl.net.URLRequest;
import lime.app.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import haxe.zip.Writer;
import flixel.math.FlxMath;
import sys.FileSystem;
import haxe.Http;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import sys.io.Process;

using StringTools;

class UpdateState extends MusicBeatState
{
	var progressText:FlxText;
	var progBar_bg:FlxSprite;
	var progressBar:FlxBar;
	var entire_progress:Float = 0; // 0 to 100;
	var download_info:FlxText;

	public var online_url:String = "";

	var downloadedSize:Float = 0;
	var content:String = "";
	var maxFileSize:Float = 0;

	var zip:URLLoader;
	var text:FlxText;

	var currentTask:String = "download_update"; // download_update,install_update

	var checker:FlxBackdrop;
	override function create()
	{
		super.create();
		FlxG.sound.playMusic(Paths.music('updateSong', "shared"), 0);
		FlxG.sound.music.pitch = 1;

		FlxG.sound.music.fadeIn(4, 0, 0.7);
		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("aboutMenu", "preload"));
		bg.color = 0xFFFF8C19;
		bg.scale.set(1.1, 1.1);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		checker = new FlxBackdrop(Paths.image('checker', 'preload'), FlxAxes.XY);
		checker.scale.set(1.4, 1.4);
		checker.color = 0xFF006AFF;
		checker.blend = BlendMode.LAYER;
		add(checker);
		checker.scrollFactor.set(0, 0.07);
		checker.alpha = 0.2;
		checker.updateHitbox();

		text = new FlxText(0, 0, 0, "Please wait, JS Engine is updating...", 18);
		text.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(text);
		text.screenCenter(X);
		text.y = 290;

		progBar_bg = new FlxSprite(FlxG.width / 2, text.y + 50).makeGraphic(500, 20, FlxColor.BLACK);
		add(progBar_bg);
		progBar_bg.x -= 250;
		progressBar = new FlxBar(progBar_bg.x + 5, progBar_bg.y + 5, LEFT_TO_RIGHT, Std.int(progBar_bg.width - 10), Std.int(progBar_bg.height - 10), this,
			"entire_progress", 0, 100);
		progressBar.numDivisions = 3000;
		progressBar.createFilledBar(0xFF8F8F8F, 0xFFAD4E00);
		add(progressBar);

		progressText = new FlxText(progressBar.x, progressBar.y - 20, 0, "0%", 16);
		progressText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(progressText);

		download_info = new FlxText(progressBar.x + progBar_bg.width, progressBar.y + progBar_bg.height, 0, "0B / 0B", 16);
		download_info.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(download_info);

		zip = new URLLoader();
		zip.dataFormat = BINARY;
		zip.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
		zip.addEventListener(openfl.events.Event.COMPLETE, onDownloadComplete);

		getUpdateLink();
		prepareUpdate();
		startDownload();
	}

	var lastVare:Float = 0;

	var lastTrackedBytes:Float = 0;
	var lastTime:Float = 0;
	var time:Float = 0;
	var speed:Float = 0;

	var downloadTime:Float = 0;

	var currentFile:String = "";

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		checker.x += 0.45 / (ClientPrefs.framerate / 60);
		checker.y += (0.16 / (ClientPrefs.framerate / 60));
		switch (currentTask)
		{
			case "download_update":
				time += elapsed;
				if (time > 1)
				{
					speed = downloadedSize - lastTrackedBytes;
					lastTime = time;
					lastTrackedBytes = downloadedSize;
					time = 0;

					// Divide file size by data speed to obtain download time.
					downloadTime = ((maxFileSize-downloadedSize) / (speed));
				}

				if (downloadedSize != lastVare)
				{
					lastVare = downloadedSize;
					download_info.text = convert_size(Std.int(downloadedSize)) + " / " + convert_size(Std.int(maxFileSize));
					download_info.x = (progBar_bg.x + progBar_bg.width) - download_info.width;

					entire_progress = (downloadedSize / maxFileSize) * 100;
				}

				progressText.text = FlxMath.roundDecimal(entire_progress, 2) + "%" + " - " + convert_size(Std.int(speed)) + "/s" + " - "
					+ convert_time(downloadTime) + " remaining";
			case "install_update":
				entire_progress = (downloadedSize / maxFileSize) * 100;
				progressText.text = FlxMath.roundDecimal(entire_progress, 2) + "%";
				download_info.text = currentFile;
				download_info.x = (progBar_bg.x + progBar_bg.width) - download_info.width;
		}
	}

	function getUpdateLink()
	{
			online_url = "https://github.com/JordanSantiagoYT/FNF-PsychEngine-NoBotplayLag/releases/download/" + TitleState.updateVersion + "/FNF-JS-Engine.zip";
			trace("update url: " + online_url);
	}

	function prepareUpdate()
	{
		trace("preparing update...");
		trace("checking if update folder exists...");

		if (!FileSystem.exists("./update/"))
		{
			trace("update folder not found, creating the directory...");
			FileSystem.createDirectory("./update");
			FileSystem.createDirectory("./update/temp/");
			FileSystem.createDirectory("./update/raw/");
		}
		else
		{
			trace("update folder found");
		}
	}

	var httpHandler:Http;

	public function startDownload()
	{
		trace("starting download process...");

		zip.load(new URLRequest(online_url));

		/*var aa = new Http(online_url);
			aa.request();
			trace(aa.responseHeaders);
			trace(aa.responseHeaders.get("size"));

			maxFileSize = Std.parseInt(aa.responseHeaders.get("size")); 

			content = requestUrl(online_url);
			sys.io.File.write(path, true).writeString(content);
			trace(content.length + " bytes downloaded"); */
	}

	public function requestUrl(url:String):String
	{
		httpHandler = new Http(url);
		var r = null;
		httpHandler.onData = function(d)
		{
			r = d;
		}
		httpHandler.onError = function(e)
		{
			trace("error while downloading file, error: " + e);
		}
		httpHandler.request(false);
		return r;
	}

	function convert_size(bytes:Int)
	{
		// public static String readableFileSize(long size) {
		//	if(size <= 0) return "0";
		//	final String[] units = new String[] { "B", "kB", "MB", "GB", "TB" };
		//	int digitGroups = (int) (Math.log10(size)/Math.log10(1024));
		//	return new DecimalFormat("#,##0.#").format(size/Math.pow(1024, digitGroups)) + " " + units[digitGroups];
		// }
		if (bytes == 0)
		{
			return "0B";
		}

		var size_name:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
		var digit:Int = Std.int(Math.log(bytes) / Math.log(1024));
		return FlxMath.roundDecimal(bytes / Math.pow(1024, digit), 2) + " " + size_name[digit];
	}

function convert_time(time:Float)
{
    var seconds = Std.int(time % 60);
    var minutes = Std.int((time / 60) % 60);
    var hours = Std.int((time / (60 * 60)) % 24);

    var secStr:String = (seconds < 10) ? "0" + seconds : Std.string(seconds);
    var minStr:String = (minutes < 10) ? "0" + minutes : Std.string(minutes);
    var hoeStr:String = (hours < 10) ? "0" + hours : Std.string(hours);

    return hoeStr + ':' + minStr + ':' + secStr;
}

	function onDownloadProgress(result:ProgressEvent)
	{
		downloadedSize = result.bytesLoaded;
		maxFileSize = result.bytesTotal;
	}

	function onDownloadComplete(result:openfl.events.Event)
	{
		var path:String = './update/temp/'; // JS Engine ' + TitleState.onlineVer + ".zip";

		if (!FileSystem.exists(path))
		{
			FileSystem.createDirectory(path);
		}

		if (!FileSystem.exists("./update/raw/"))
		{
			FileSystem.createDirectory("./update/raw/");
		}

		var fileBytes:Bytes = cast(zip.data, ByteArray);
		text.text = "Update downloaded successfully, saving update file...";
		text.screenCenter(X);
		File.saveBytes(path + "JS Engine v" + TitleState.updateVersion + ".zip", fileBytes);
		text.text = "Unpacking update file...";
		text.screenCenter(X);
		// Uncompress.run(File.getBytes(path + "JS Engine v" + TitleState.updateVersion + ".zip"))
		JSEZip.unzip(path + "JS Engine v" + TitleState.updateVersion + ".zip", "./update/raw/");
		text.text = "Update has finished! The update will be installed shortly..";
		text.screenCenter(X);

		FlxG.sound.play(Paths.sound('confirmMenu'));

		new FlxTimer().start(3, function(e:FlxTimer)
		{
			installUpdate("./update/raw/");
		});
	}

	function installUpdate(updateFolder:String)
	{
		CoolUtil.updateTheEngine();
	}
}