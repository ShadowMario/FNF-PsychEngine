#if web
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
#else
import openfl.events.Event;
import vlc.VlcBitmap;
import openfl.display.BitmapData;
#end
import flixel.FlxBasic;
import flixel.FlxG;

class FlxVideo extends FlxBasic {
	#if VIDEOS_ALLOWED
	public var finishCallback:Void->Void = null;
	public var volume:Float = 1;
	public var muted:Bool = false;
	public var paused:Bool = false; //if it should be paused or playing
	public var isPaused:Bool = false; //internal variable, whether it is paused or playing
	var isSource:Bool = false;
	
	#if desktop
	public var bitmapData:BitmapData;
	public var vlcBitmap:VlcBitmap;
	public static var instances:Array<FlxVideo>;
	#end

	public function new(name:String, isBitmapSource:Bool = false) {
		super();

		isSource = isBitmapSource;

		#if web
		if (isSource) {
			//don't know how to access the bitmap data of web videos
			trace('Web builds do not support sourcing bitmap data from videos yet, only video cutscenes');
			return;
		}
		var player:Video = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		var netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function() {
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
			if(event.info.code == "NetStream.Play.Complete") {
				netStream.dispose();
				if(FlxG.game.contains(player)) FlxG.game.removeChild(player);

				if(finishCallback != null) finishCallback();
			}
		});
		netStream.play(name);

		#elseif desktop
		// by Polybius, check out PolyEngine! https://github.com/polybiusproxy/PolyEngine

		vlcBitmap = new VlcBitmap();
		vlcBitmap.set_height(FlxG.stage.stageHeight);
		vlcBitmap.set_width(FlxG.stage.stageHeight * (16 / 9));

		vlcBitmap.onComplete = onVLCComplete;
		vlcBitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, fixVolume);
		vlcBitmap.repeat = 0;
		vlcBitmap.inWindow = false;
		vlcBitmap.fullscreen = false;
		fixVolume(null);

		if (!isSource) {
			trace('sprite connected to video');
		} else {
			FlxG.addChildBelowMouse(vlcBitmap);
		}
		vlcBitmap.play(checkFile(name));
		
		instances.push(this);
		#end
	}

	#if desktop
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (vlcBitmap == null)
			return;
		
		if (playstatePaused() != isPaused)
		{
			if (isPaused && !paused) {
				vlcBitmap.resume();
				isPaused = false;
			} else if(!isPaused) {	
				vlcBitmap.pause();
				isPaused = true;
			}
		}

		bitmapData = vlcBitmap.bitmapData;
	}

	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}
	
	public static function playstatePaused():Bool {
		if (PlayState.instance != null)
			return PlayState.instance.paused;
		return false;
	}
	
	public function resume() {
		if(vlcBitmap != null && !playstatePaused()) {
			vlcBitmap.resume();
			paused = isPaused = false;
		}
	}
	
	public function pause() {
		if(vlcBitmap != null && !playstatePaused()) {
			vlcBitmap.pause();
			paused = isPaused = true;
		}
	}
	
	public static function onFocus() {
		for (instance in instances) {
			if(instance.vlcBitmap != null && !playstatePaused() && !instance.paused) {
				instance.vlcBitmap.resume();
				instance.isPaused = false;
			}
		}
	}
	
	public static function onFocusLost() {
		for (instance in instances) {
			if(instance.vlcBitmap != null && !playstatePaused()) {
				instance.vlcBitmap.pause();
				instance.isPaused = true;
			}
		}
	}

	public function fixVolume(e:Event)
	{
		// shitty volume fix
		vlcBitmap.volume = 0;
		if(!FlxG.sound.muted && FlxG.sound.volume > 0.01 && !muted && volume != 0) { //Kind of fixes the volume being too low when you decrease it
			vlcBitmap.volume = FlxG.sound.volume * 0.5 * volume + 0.5;
		}
	}

	public function onVLCComplete()
	{
		vlcBitmap.stop();

		// Clean player, just in case!
		vlcBitmap.dispose();

		if (FlxG.game.contains(vlcBitmap))
		{
			FlxG.game.removeChild(vlcBitmap);
		}

		if (finishCallback != null)
		{
			finishCallback();
		}
		
		instances.remove(this);
	}

	
	function onVLCError()
		{
			trace("An error has occured while trying to load the video.\nPlease, check if the file you're loading exists.");
			if (finishCallback != null) {
				finishCallback();
			}
		}
	#end
	#end
}
