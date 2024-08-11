package objects;

import states.editors.NoteSplashEditorState;
import haxe.Json;
import backend.animation.PsychAnimationController;

import shaders.RGBPalette;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

private typedef RGB = {
	r:Null<Int>,
	g:Null<Int>,
	b:Null<Int>
}

private typedef NoteSplashAnim = {
	name:String,
	prefix:String,
	maxFps:Int,
	minFps:Int,
	noteData:Int,
	offsets:Array<Int>,
	indices:Array<Int>,
}

typedef NoteSplashConfig = {
	animations:Map<String, NoteSplashAnim>,
	scale:Array<Float>,
	affectedByShader:Bool,
	rgb:Array<Null<RGB>>
}

class NoteSplash extends FlxSprite
{
	public var skin:String;
	public var config(default, set):NoteSplashConfig;
	public static var DEFAULT_SKIN:String = "noteSplashes";
	public static var configs:Map<String, NoteSplashConfig> = new Map();

	public var babyArrow:StrumNote;

	var noteDataMap:Map<Int, String> = new Map();
	var rgbShader:PixelSplashShaderRef;

	public function new(?splash:String)
	{
		super();
        animation = new PsychAnimationController(this);
		rgbShader = new PixelSplashShaderRef();
		shader = rgbShader.shader;

		loadSplash(splash);
	}

	function loadSplash(?splash:String)
	{
		config = null; // Reset config to the default so when reloaded it can be set properly
		skin = null;
		
		var skin:String = splash;
		
		if (skin == null || skin.length < 1)
			skin = try PlayState.SONG.splashSkin catch(e) null;

		if (skin == null || skin.length < 1)
			skin = DEFAULT_SKIN + getSplashSkinPostfix();
		
		this.skin = skin;

		try frames = Paths.getSparrowAtlas("noteSplashes/" + skin) catch (e) {
			skin = DEFAULT_SKIN; // The splash skin was not found, return to the default
			this.skin = skin;
			try frames = Paths.getSparrowAtlas("noteSplashes/" + skin) catch (e) {
				active = visible = false;
			}
		}

		var path:String = 'images/noteSplashes/$skin.json';
		if (configs.exists(path))
			this.config = configs.get(path);
		else if (Paths.fileExists(path, TEXT))
		{
			var config:Dynamic = Json.parse(Paths.getTextFromFile(path));

			if (config != null)
			{
				var tempConfig:NoteSplashConfig = {
					animations: new Map(),
					scale: config.scale,
					affectedByShader: config.affectedByShader,
					rgb: config.rgb
				}
				for (i in Reflect.fields(config.animations))
				{
					tempConfig.animations.set(i, Reflect.field(config.animations, i));
				}

				this.config = tempConfig;
				configs.set(path, tempConfig);
			}
		}
	}

	public function spawnSplashNote(note:Note, ?noteData:Int, ?randomize:Bool = true)
	{	
		if (note != null && note.noteSplashData.texture != null)
			loadSplash(note.noteSplashData.texture);

		if (note != null && note.noteSplashData.disabled)
			return;

		if (babyArrow != null)
			setPosition(babyArrow.x, babyArrow.y); // To prevent it from being misplaced for one game tick

		var noteData:Null<Int> = noteData;
		if (noteData == null)
			noteData = note != null ? note.noteData : 0;

		if (randomize)
		{
			var anims:Int = 0;
			var datas:Int = 0;
			var animArray:Array<Int> = [];
			while (true)
			{
				var data:Int = noteData % 4 + (datas * 4); 
				if (!noteDataMap.exists(data) || !animation.exists(noteDataMap[data]))
					break;
				datas++;
				anims++;
			}
			if (anims > 1)
			{
				for (i in 0...anims)
				{
					var data = noteData % 4 + (i * 4);
					if (!animArray.contains(data))
						animArray.push(data);
				}
			}

			if (animArray.length > 1)
				noteData = animArray[FlxG.random.bool() ? 0 : 1];
		}

		var anim:String = null;
		function playDefaultAnim()
		{
			var animation:String = noteDataMap.get(noteData);
			if (animation != null && this.animation.exists(animation))
			{
				this.animation.play(animation);
				anim = animation;
			}
			else
				visible = false;
		}

		playDefaultAnim();

		var tempShader:RGBPalette = null;
		if (note == null)
			note = new Note(0, noteData);

		Note.initializeGlobalRGBShader(noteData % 4);
		function useDefault()
		{
			tempShader = Note.globalRgbShaders[noteData % 4];
		}

		if(((cast FlxG.state) is NoteSplashEditorState) || 
			((note.noteSplashData.useRGBShader) && (PlayState.SONG == null || !PlayState.SONG.disableNoteRGB)))
		{
			// If Note RGB is enabled:
			if((!note.noteSplashData.useGlobalShader || ((cast FlxG.state) is NoteSplashEditorState)))
			{
				var colors = config.rgb;
				if (colors != null)
				{
					tempShader = new RGBPalette();
					for (i in 0...colors.length)
					{
						if (i > 2)
							break;

						var rgb = colors[i];
						var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData % 4];
						if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[noteData % 4];
						if (rgb == null)
						{
							if (i == 0)
								tempShader.r = arr[0];
							else if (i == 1)
								tempShader.g = arr[1];
							else if (i == 2)
								tempShader.b = arr[2];
							continue;
						}

						var r:Null<Int> = rgb.r; 
						var g:Null<Int> = rgb.g;
						var b:Null<Int> = rgb.b;

						if (r == null || Math.isNaN(r) || r < 0)
							r = arr[0];
						if (g == null || Math.isNaN(g) || g < 0)
							g = arr[1];
						if (b == null || Math.isNaN(b) || b < 0)
							b = arr[2];

						var color:FlxColor = FlxColor.fromRGB(r, g, b);
						if (i == 0)
							tempShader.r = color;
						else if (i == 1)
							tempShader.g = color;
						else if (i == 2)
							tempShader.b = color;
					} 
				}
				else
					useDefault();
			}
			else 
			{	
				useDefault();
			}
		}

		if (config.affectedByShader)
			rgbShader.copyValues(tempShader);
		else 
			rgbShader.reset();

		var conf = config.animations.get(anim);
		var offsets = [0, 0];
		if (conf != null)
			offsets = conf.offsets;
		if (offsets != null)
		{
			centerOffsets();
			offset.set(offsets[0], offsets[1]);
		}
		animation.finishCallback = function(name:String)
		{
			kill();
		};
		
        alpha = ClientPrefs.data.splashAlpha;
		if(note != null) alpha = note.noteSplashData.a;

		if(note != null) antialiasing = note.noteSplashData.antialiasing;
		if(PlayState.isPixelStage) antialiasing = false;

		if(animation.curAnim != null && conf != null)
		{
			var minFps = conf.minFps;
			if (minFps < 0)
				minFps = 0;
			var maxFps = conf.maxFps;
			if (maxFps < 0)
				maxFps = 0;
			animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (babyArrow != null)
		{
			//cameras = babyArrow.cameras;
			setPosition(babyArrow.x, babyArrow.y);
		}
	}

    public static function getSplashSkinPostfix()
	{
		var skin:String = '';
		if(ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin)
			skin = '-' + ClientPrefs.data.splashSkin.trim().toLowerCase().replace(' ', '-');
		return skin;
	}

	public static function createConfig():NoteSplashConfig
	{
		return {
			animations: new Map(),
			scale: [1, 1],
			affectedByShader: true,
			rgb: null
		}
	}

	public static function addAnimationToConfig(scale:Array<Float>, config:NoteSplashConfig, name:String, prefix:String, minFps:Int, maxFps:Int, offsets:Array<Int>, indices:Array<Int>, noteData:Int):NoteSplashConfig
	{
		if (config == null)
			config = createConfig();

		config.animations.set(name, {name: name, prefix: prefix, indices: indices, minFps: minFps, maxFps: maxFps, offsets: offsets, noteData: noteData});
		config.scale = scale;
		return config;
	}

	function set_config(value:NoteSplashConfig):NoteSplashConfig 
	{
		if (value == null)
			value = createConfig();

		noteDataMap.clear();

		for (i in value.animations)
		{
			var key:String = i.name;
			if (i.prefix.length > 0 && key != null && key.length > 0)
			{
				if (i.indices != null && i.indices.length > 0 && key != null && key.length > 0)
					animation.addByIndices(key, i.prefix, i.indices, "", i.maxFps, false);
				else
					animation.addByPrefix(key, i.prefix, i.maxFps, false);
				noteDataMap.set(i.noteData, key);
			}
		}
		scale.set(value.scale[0], value.scale[1]);
		return config = value;
	}
}

class PixelSplashShaderRef 
{
	public var shader:PixelSplashShader = new PixelSplashShader();

	public function copyValues(tempShader:RGBPalette)
	{
		var enabled:Bool = false;
		if(tempShader != null)
			enabled = true;

		if(enabled)
		{
			for (i in 0...3)
			{
				shader.r.value[i] = tempShader.shader.r.value[i];
				shader.g.value[i] = tempShader.shader.g.value[i];
				shader.b.value[i] = tempShader.shader.b.value[i];
			}
			shader.mult.value[0] = tempShader.shader.mult.value[0];
		}
		else shader.mult.value[0] = 0.0;
	}

	public function set(enabled:Bool = true)
	{
		shader.mult.value = [enabled ? 1 : 0];
	}

	public function reset()
	{
		shader.r.value = [0, 0, 0];
		shader.g.value = [0, 0, 0];
		shader.b.value = [0, 0, 0];
	}

	public function new()
	{
		reset();
		set();

		var pixel:Float = 1;
		if(PlayState.isPixelStage) pixel = PlayState.daPixelZoom;
		shader.uBlocksize.value = [pixel, pixel];
		//trace('Created shader ' + Conductor.songPosition);
	}
}

class PixelSplashShader extends FlxShader
{
	@:glFragmentHeader('
		#pragma header
		
		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;
		uniform vec2 uBlocksize;

		vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 coord) {
			vec2 blocks = openfl_TextureSize / uBlocksize;
			vec4 color = flixel_texture2D(bitmap, floor(coord * blocks) / blocks);
			if (!hasTransform) {
				return color;
			}

			if(color.a == 0.0 || mult == 0.0) {
				return color * openfl_Alphav;
			}

			vec4 newColor = color;
			newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
			newColor.a = color.a;
			
			color = mix(color, newColor, mult);
			
			if(color.a > 0.0) {
				return vec4(color.rgb, color.a);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}')

	@:glFragmentSource('
		#pragma header

		void main() {
			gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
		}')

	public function new()
	{
		super();
	}
}