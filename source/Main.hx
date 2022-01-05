package;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
		var timer = new haxe.Timer(1);
		timer.run = function() {
		coloring();
		if (fpsVar.textColor == 0) fpsVar.textColor = -4775566;} // needs to be done because textcolor becomes black for a frame
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		ClientPrefs.loadDefaultKeys();
		// fuck you, persistent caching stays ON during sex
		FlxGraphic.defaultPersist = true;
		// the reason for this is we're going to be handling our own cache smartly
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
	// Chroma Effect (12 Colors)
	var array:Array<FlxColor> = [
		FlxColor.fromRGB(216, 34, 83),
		FlxColor.fromRGB(255, 38, 0),
		FlxColor.fromRGB(255, 80, 0),
		FlxColor.fromRGB(255, 147, 0),
		FlxColor.fromRGB(255, 199, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(202, 255, 0),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(0, 146, 146),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(82, 40, 204),
		FlxColor.fromRGB(150, 33, 146)
	];
	var skippedFrames = 0;
	var currentColor = 0;

	// Event Handlers
	public function coloring():Void
	{
		// Hippity, Hoppity, your code is now my property (from KadeEngine)
		if (FlxG.save.data.fpsRainbow) {
		if (currentColor >= array.length)
			currentColor = 0;
		currentColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / ClientPrefs.framerate));
		(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
		currentColor++;
		skippedFrames++;
		if (skippedFrames > ClientPrefs.framerate)
			skippedFrames = 0;
		}
		else fpsVar.textColor = FlxColor.fromRGB(255, 255, 255);
	}
	public function changeFPSColor(color:FlxColor)
	{
		fpsVar.textColor = color;
	}
}
