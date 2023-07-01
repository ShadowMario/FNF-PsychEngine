package objects;

import shaders.RGBPalette;

typedef NoteSplashConfig = {
	anim:String,
	minFps:Int,
	maxFps:Int,
	offsets:Array<Array<Float>>
}

class NoteSplash extends FlxSprite
{
	public var rgbShader:RGBPalette = null;
	private var idleAnim:String;
	private var _textureLoaded:String = null;

	private static var defaultNoteSplash:String = 'noteSplashes/noteSplashes';
	public static var configs:Map<String, NoteSplashConfig> = new Map<String, NoteSplashConfig>();

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);

		var skin:String = null;
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		else skin = getSplashSkin();

		precacheConfig(skin);
		//setupNoteSplash(x, y, 0);
	}

	override function destroy()
	{
		configs.clear();
		super.destroy();
	}

	var maxAnims:Int = 2;
	public function setupNoteSplash(x:Float, y:Float, direction:Int = 0, ?note:Note = null) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;
		aliveTime = 0;

		var texture:String = null;
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		else texture = getSplashSkin();
		
		var config:NoteSplashConfig = precacheConfig(texture);
		if(_textureLoaded != texture)
			config = loadAnims(texture, config);

		shader = null;
		if(note != null && !note.noteSplashGlobalShader)
			rgbShader = note.rgbShader.parent;
		else
			rgbShader = Note.globalRgbShaders[direction];

		if(rgbShader != null) shader = rgbShader.shader;

		_textureLoaded = texture;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, maxAnims);
		animation.play('note' + direction + '-' + animNum, true);
		
		var minFps:Int = 22;
		var maxFps:Int = 26;
		if(config != null)
		{
			var animID:Int = direction + ((animNum - 1) * Note.colArray.length);
			//trace('anim: ${animation.curAnim.name}, $animID');
			var offs:Array<Float> = config.offsets[FlxMath.wrap(animID, 0, config.offsets.length-1)];
			offset.x += offs[0];
			offset.y += offs[1];
			minFps = config.minFps;
			maxFps = config.maxFps;
		}

		if(animation.curAnim != null)
			animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
	}

	public static function getSplashSkin()
	{
		var skin:String = defaultNoteSplash;
		if(ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin)
			skin += '-' + ClientPrefs.data.splashSkin.trim().toLowerCase().replace(' ', '_');
		return skin;
	}

	function loadAnims(skin:String, ?config:NoteSplashConfig = null, ?animName:String = null):NoteSplashConfig {
		maxAnims = 0;
		frames = Paths.getSparrowAtlas(skin);

		if(animName == null)
			animName = config != null ? config.anim : 'note splash';

		var config:NoteSplashConfig = precacheConfig(skin);
		while(true) {
			var animID:Int = maxAnims + 1;
			for (i in 0...Note.colArray.length) {
				if (!addAnimAndCheck('note$i-$animID', '$animName ${Note.colArray[i]} $animID', 24, false)) {
					//trace('maxAnims: $maxAnims');
					return config;
				}
			}
			maxAnims++;
			//trace('currently: $maxAnims');
		}
	}

	public static function precacheConfig(skin:String)
	{
		if(configs.exists(skin)) return configs.get(skin);

		var path:String = Paths.getPath('images/$skin.txt', TEXT);
		var configFile:Array<String> = CoolUtil.coolTextFile(path);
		if(configFile.length < 1) return null;
		
		var framerates:Array<String> = configFile[1].split(' ');
		var offs:Array<Array<Float>> = [];
		for (i in 2...configFile.length)
		{
			var animOffs:Array<String> = configFile[i].split(' ');
			offs.push([Std.parseFloat(animOffs[0]), Std.parseFloat(animOffs[1])]);
		}

		var config:NoteSplashConfig = {
			anim: configFile[0],
			minFps: Std.parseInt(framerates[0]),
			maxFps: Std.parseInt(framerates[1]),
			offsets: offs
		};
		//trace(config);
		configs.set(skin, config);
		return config;
	}

	function addAnimAndCheck(name:String, anim:String, ?framerate:Int = 24, ?loop:Bool = false)
	{
		animation.addByPrefix(name, anim, framerate, loop);
		return animation.getByName(name) != null;
	}

	static var aliveTime:Float = 0;
	static var buggedKillTime:Float = 0.5; //automatically kills note splashes if they break to prevent it from flooding your HUD
	override function update(elapsed:Float) {
		aliveTime += elapsed;
		if((animation.curAnim != null && animation.curAnim.finished) ||
			(animation.curAnim == null && aliveTime >= buggedKillTime)) kill();

		super.update(elapsed);
	}
}