package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
import flixel.FlxG;
#if flash
import openfl.Lib;
#end
import external.memory.Memory;
#if openfl
import openfl.system.System;
#end
import Main;
import flixel.util.FlxColor;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public static var instance:FPS;
	public var currentFPS(default, null):Float;

	@:noCompletion private var cacheCount:Float;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public static var mainThing:Main;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 12, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// All the colors:		  Red,	      Orange,     Yellow,     Green,      Blue,       Violet/Purple
    	final rainbowColors:Array<Int> = [0xFFFF0000, 0xFFFFA500, 0xFFFFFF00, 0xFF00FF00, 0xFF0000FF, 0xFFFF00FF];
	var colorInterp:Float = 0;
	var currentColor:Int = 0;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		//Literally the stupidest thing i've done for the FPS counter but it allows it to update correctly when on 60 FPS??
		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.framerate) currentFPS = ClientPrefs.framerate;

			text = (ClientPrefs.showFPS ? "FPS: " + currentFPS : "");
			
			if (ClientPrefs.showRamUsage) text += "\nMemory: " + CoolUtil.formatBytes(Memory.getCurrentUsage(), false, 2) + (ClientPrefs.showMaxRamUsage ? " / " + CoolUtil.formatBytes(Memory.getPeakUsage(), false, 2) : "");

			if (ClientPrefs.debugInfo) {
				text += '\nState: ${Type.getClassName(Type.getClass(FlxG.state))}';
				if (FlxG.state.subState != null)
					text += '\nSubstate: ${Type.getClassName(Type.getClass(FlxG.state.subState))}';
				text += "\nSystem: " + '${lime.system.System.platformLabel} ${lime.system.System.platformVersion}';
				text += "\nText bitmaps generated: " + Main.textGenerations;
			}

    			if (ClientPrefs.rainbowFPS)
    			{
		 			colorInterp += deltaTime / 330; // Division so that it doesn't give you a seizure on 60 FPS
					var colorIndex1:Int = Math.floor(colorInterp);
					var colorIndex2:Int = (colorIndex1 + 1) % rainbowColors.length;

					var startColor:Int = rainbowColors[colorIndex1];
					var endColor:Int = rainbowColors[colorIndex2];

					var segmentInterp:Float = colorInterp - colorIndex1;

					var interpolatedColor:Int = interpolateColor(startColor, endColor, segmentInterp);

					textColor = interpolatedColor;

					// Check if the current color segment interpolation is complete
					if (colorInterp >= rainbowColors.length) {
						// Reset colorInterp to start the interpolation cycle again
					textColor = rainbowColors[0];
					colorInterp = 0;
					}
    			}
			else
			{
				textColor = 0xFFFFFFFF;
				if (currentFPS <= ClientPrefs.framerate / 2)
				{
					textColor = 0xFFFF0000;
				}
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";

		cacheCount = currentCount;
	}
    private function interpolateColor(startColor:Int, endColor:Int, t:Float):Int {
        // Extract color components (RGBA) from startColor
        var startR:Int = (startColor >> 16) & 0xFF;
        var startG:Int = (startColor >> 8) & 0xFF;
        var startB:Int = startColor & 0xFF;
        var startA:Int = (startColor >> 24) & 0xFF;

        // Extract color components (RGBA) from endColor
        var endR:Int = (endColor >> 16) & 0xFF;
        var endG:Int = (endColor >> 8) & 0xFF;
        var endB:Int = endColor & 0xFF;
        var endA:Int = (endColor >> 24) & 0xFF;

        // Perform linear interpolation for each color component
        var interpolatedR:Int = Math.round(startR + t * (endR - startR));
        var interpolatedG:Int = Math.round(startG + t * (endG - startG));
        var interpolatedB:Int = Math.round(startB + t * (endB - startB));
        var interpolatedA:Int = Math.round(startA + t * (endA - startA));

        // Combine interpolated color components into a single color value
        var interpolatedColor:Int = (interpolatedA << 24) | (interpolatedR << 16) | (interpolatedG << 8) | interpolatedB;

        return interpolatedColor;
    }
}
