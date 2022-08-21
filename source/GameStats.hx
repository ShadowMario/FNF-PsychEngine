import flixel.FlxG;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl.text.TextFormat;
import openfl.system.System;
import openfl.text.TextField;

class GameStats extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):UInt;

    var peak:UInt = 0;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	var textShader = new Shader();
	var wasPressed:Bool = false;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		
		textShader.glFragmentSource = "varying float vAlpha;
			varying vec2 vTexCoord;
			uniform sampler2D uImage0;

			uniform int width;
			uniform int height;
			
			void main(void) {
				
				vec4 color = texture2D(uImage0, vTexCoord);
				vec4 left = texture2D(uImage0, vTexCoord - vec2(-1.0 / width, 0));
				vec4 right = texture2D(uImage0, vTexCoord - vec2(1.0 / width, 0));
				vec4 up = texture2D(uImage0, vTexCoord - vec2(0, -1.0 / height));
				vec4 down = texture2D(uImage0, vTexCoord - vec2(0, 1.0 / height));

				float alpha = color.a;
				if (left.a > alpha) alpha = left.a;
				if (right.a > alpha) alpha = right.a;
				if (up.a > alpha) alpha = up.a;
				if (down.a > alpha) alpha = down.a;
				gl_FragColor = vec4(
					color.r * color.a,
					color.g * color.a,
					color.b * color.a,
					color.a
					);
				
			}";


		filters = [new ShaderFilter(textShader)];
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		autoSize = LEFT;
		backgroundColor = 0;

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end

		width = 350;
	}

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

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (Settings.engineSettings != null && Settings.engineSettings.data != null)
		{
			if (visible = (Settings.engineSettings.data.fps_showFPS || Settings.engineSettings.data.fps_showMemory || Settings.engineSettings.data.fps_showMemoryPeak)) {
				text = "";
				if (Settings.engineSettings.data.fps_showFPS)
					text += "FPS: " + currentFPS + "\n";
	
				//opaqueBackground = 0;
				#if (gl_stats && !disable_cffi && (!html5 || !canvas))
				text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
				text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
				text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
				#end
				var mem = System.totalMemory;
				if (mem > peak) peak = mem;
				if (Settings.engineSettings != null) {
					if (Settings.engineSettings.data.fps_showMemory)
						text += "Memory: " + CoolUtil.getSizeLabel(System.totalMemory) + "\n";
					if (Settings.engineSettings.data.fps_showMemoryPeak)
						text += "Mem Peak: " + CoolUtil.getSizeLabel(peak) + "\n";
					if (Settings.engineSettings.data.fps_showYoshiCrafterEngineVer)
						text += 'YoshiCrafter Engine v${Main.engineVer}\n';
					if (CoolUtil.isDevMode() && LogsOverlay.tracedShit > LogsOverlay.lastPos) {
						var traced = LogsOverlay.tracedShit - LogsOverlay.lastPos;
						text += '${traced} traced line${traced > 0 ? "s" : ""}';
						if (LogsOverlay.errors > LogsOverlay.lastErrors) {
							var errors = LogsOverlay.errors - LogsOverlay.lastErrors;
							text += ' | ${errors} error${errors > 0 ? "s" : ""}';
						}
						text += " (F6 to open)\n";
					}
				}
			} else {
				text = "";
			}
		} else {
			text = "FPS: " + currentFPS + "\n";
		}
		if (!wasPressed && (wasPressed = FlxG.keys.pressed.F3)) {
			background = !background;
		} else
			wasPressed = FlxG.keys.pressed.F3;
		


		cacheCount = currentCount;
	}
}
