package stage;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.Unserializer;
import lime.utils.Assets;
import dev_toolbox.stage_editor.FlxStageSprite;
import flixel.math.FlxPoint;
import haxe.io.Path;
import haxe.Json;
import flixel.FlxSprite;
import sys.FileSystem;

using StringTools;

class Stage {
	public static var templateStage:StageJSON = {
		defaultCamZoom: 1,
		bfOffset: [0, 0],
		gfOffset: [0, 0],
		dadOffset: [0, 0],
		sprites: [
			{
				name: "Girlfriend",
				type: "GF",
				scrollFactor: [0.95, 0.95]
			},
			{
				name: "Boyfriend",
				type: "BF",
				scrollFactor: [1, 1]
			},
			{
				name: "Dad",
				type: "Dad",
				scrollFactor: [1, 1]
			}
		],
        followLerp: 0.04
	};
	public var sprites:Map<String, FlxSprite> = [];
	public var onBeatAnimSprites:Array<OnBeatAnimSprite> = [];
	public var onBeatForceAnimSprites:Array<OnBeatAnimSprite> = [];
	public var onBeatTweenSprites:Array<OnBeatTweenSprite> = [];
	public function getSprite(name:String) {
		return sprites[name];
	}
	public function onBeat() {
		for (s in onBeatAnimSprites) {
			s.sprite.animation.play(s.anim);
		}
		for (s in onBeatForceAnimSprites) {
			s.sprite.animation.play(s.anim, true);
		}
	}
	public function new(path:String, mod:String) {
		var splitPath = path.split(":");
		if (splitPath[0].toLowerCase() == "yoshiengine") splitPath[0] = "YoshiCrafterEngine";
		var jsonMode = false;
		if (splitPath.length < 2) {
			if (Assets.exists(Paths.stage(Path.withoutExtension(splitPath[0]), 'mods/$mod'))) {
				jsonMode = true;
				splitPath.insert(0, mod);
			// psych users be hungry tonight
			} else if (Assets.exists(Paths.stage(Path.withoutExtension(splitPath[0]), 'mods/$mod', 'stage'))) {
				splitPath.insert(0, mod);
			} else if (Assets.exists(Paths.stage(Path.withoutExtension(splitPath[0]), 'mods/Friday Night Funkin\''))) {
				jsonMode = true;
				splitPath.insert(0, "Friday Night Funkin'");
			} else if (Assets.exists(Paths.stage(Path.withoutExtension(splitPath[0]), 'mods/Friday Night Funkin\'', 'stage'))) {
				splitPath.insert(0, "Friday Night Funkin'");
			}
		} else {
			if (Assets.exists(Paths.stage(Path.withoutExtension(splitPath[1]), 'mods/${splitPath[0]}', 'json'))) {
				jsonMode = true;
			}
		}
		if (splitPath.length < 2) {
			LogsOverlay.error('Stage not found for $path in $mod');
			return;
		}
		var json:StageJSON = null;
		if (jsonMode) {
			try {
				json = Json.parse(Assets.getText(Paths.stage(Path.withoutExtension(splitPath[1]), 'mods/$mod')));
			} catch(e) {
				LogsOverlay.error('Failed to parse JSON data at $path in $mod : $e');
			}
		} else {
			json = Unserializer.run(Assets.getText(Paths.stage(Path.withoutExtension(splitPath[1]), 'mods/$mod', 'stage')));
		}
		PlayState.current.devStage = splitPath.join(":");
		var PlayState = PlayState.current;
		if (json.defaultCamZoom != null) PlayState.defaultCamZoom = json.defaultCamZoom;
		if (json.bfOffset != null) {
			if (json.bfOffset.length > 0) {
				PlayState.boyfriend.x += json.bfOffset[0];
			}
			if (json.bfOffset.length > 1) {
				PlayState.boyfriend.y += json.bfOffset[1];
			}
		}
		if (json.dadOffset != null) {
			if (json.dadOffset.length > 0) {
				PlayState.dad.x += json.dadOffset[0];
			}
			if (json.dadOffset.length > 1) {
				PlayState.dad.y += json.dadOffset[1];
			}
		}
		if (json.gfOffset != null) {
			if (json.gfOffset.length > 0) {
				PlayState.gf.x += json.gfOffset[0];
			}
			if (json.gfOffset.length > 1) {
				PlayState.gf.y += json.gfOffset[1];
			}
		}

		if (json.sprites != null) {
			for(s in json.sprites) {
				var resultSprite:FlxStageSprite = null;
				switch(s.type) {
					case "SparrowAtlas":
						var sAtlas = generateSparrowAtlas(s, splitPath[0]);
						PlayState.add(sAtlas);
						if (s.name != null) sprites[s.name] = sAtlas;


						if (s.animation != null) {
							if (s.animation.type.toLowerCase() == "onbeat") {
								onBeatAnimSprites.push({
									anim: s.animation.name,
									sprite: sAtlas
								});
							} else if (s.animation.type.toLowerCase() == "onbeatforce") {
								onBeatForceAnimSprites.push({
									anim: s.animation.name,
									sprite: sAtlas
								});
							}
						}
						resultSprite = sAtlas;
					case "Bitmap":
						var bmap = generateBitmap(s, splitPath[0]);
						if (s.name != null) sprites[s.name] = bmap;
						PlayState.add(bmap);
						resultSprite = bmap;
					case "BF":
						doTheChar(PlayState.boyfriend, s, mod);
						PlayState.add(PlayState.boyfriend);
					case "GF":
						doTheChar(PlayState.gf, s, mod);
						PlayState.add(PlayState.gf);
					case "Dad":
						doTheChar(PlayState.dad, s, mod);
						PlayState.add(PlayState.dad);
				}
				if (resultSprite != null) {
					if (s.beatTween != null && ((s.beatTween.x != 0 && s.beatTween.x != null) || (s.beatTween.y != 0 && s.beatTween.y != null))) {
						if (s.beatTween.x == null) s.beatTween.x = 0;
						if (s.beatTween.y == null) s.beatTween.y = 0;
						var ease:Float->Float = function(v) {return v;}
						var requestedEase = Reflect.getProperty(FlxEase, s.beatTween.ease);
						if (Std.isOfType(requestedEase, Float->Float)) {
							ease = requestedEase;
						}

						onBeatTweenSprites.push({
							sprite: resultSprite,
							offset: s.beatTween,
							easeFunc: requestedEase
						});
					}
				}
			}
		}

		if (json.followLerp != null) PlayState.camFollowLerp = json.followLerp;
	}

	function doTheChar(char:Character, s:StageSprite, mod:String) {
		var scrollFactor = s.scrollFactor;
		if (scrollFactor == null) scrollFactor = [1, 1];
		while (scrollFactor.length < 2) scrollFactor.push(1);
		char.scrollFactor.set(scrollFactor[0], scrollFactor[1]);
		char.updateHitbox();

		doTheCharShader(char, s, mod);
	}
	public static function doTheCharShader(char:FlxSprite, s:StageSprite, mod:String) {
		if (s.shader != null) {
			var split = s.shader.split(":");
			if (split.length < 2) split.insert(0, mod);
			char.shader = new CustomShader(split.join(":"), split.join(":"), []);
			if (Std.isOfType(char, FlxStageSprite)) cast(char, FlxStageSprite).shaderName = s.shader;
		}
	}
	public static function doTheRest(sprite:FlxStageSprite, s:StageSprite, mod:String) {
		if (s.alpha != null) sprite.alpha = s.alpha;
		if (s.scale != null) {
			sprite.scale.set(s.scale, s.scale);
			sprite.updateHitbox();
		}
		if (s.shader != null && s.shader.trim() != "") {
			var split = s.shader.split(":");
			if (split.length < 2) split.insert(0, mod);
			sprite.shader = new CustomShader(split.join(":"), split.join(":"), []);
			sprite.shaderName = s.shader;
		}
		sprite.onBeatOffset = s.beatTween;
	}
	public static function generateSparrowAtlas(s:StageSprite, mod:String) {
		var pos:FlxPoint = new FlxPoint(0, 0);
		if (s.pos != null) {
			if (s.pos.length > 0) pos.x = s.pos[0];
			if (s.pos.length > 1) pos.y = s.pos[1];
		}
		var sprite = new FlxStageSprite(pos.x, pos.y);
		sprite.antialiasing = s.antialiasing != null ? s.antialiasing : true;

		sprite.name = s.name;
		sprite.type = "SparrowAtlas";

		var sf = new FlxPoint(1, 1);
		if (s.scrollFactor != null) {
			if (s.scrollFactor.length > 0) sf.x = s.scrollFactor[0];
			if (s.scrollFactor.length > 1) sf.y = s.scrollFactor[1];
		}
		sprite.scrollFactor.set(sf.x, sf.y);

		sprite.spritePath = s.src;
		if (s.src != null) {
			var sparrowAtlas = Paths.getSparrowAtlas(s.src, 'mods/$mod');
			if (sparrowAtlas != null) {
				sprite.frames = sparrowAtlas;

				if (s.animation != null) {
					var animName = "anim";
					var framerate = 24;
					var animType = "";
					if (s.animation.name != null) animName = s.animation.name;
					if (s.animation.fps != null) framerate = s.animation.fps;
					if (s.animation.type != null) animType = s.animation.type.toLowerCase();
					sprite.animType = animType;

					sprite.animation.addByPrefix(animName, animName, framerate, animType == "loop");
					sprite.animation.play(animName);
					sprite.anim = s.animation;
				}
			}
		}
		doTheRest(sprite, s, mod);
		return sprite;
	}

	public static function generateBitmap(s:StageSprite, mod:String) {
		var pos:FlxPoint = new FlxPoint(0, 0);
		if (s.pos != null) {
			if (s.pos.length > 0) pos.x = s.pos[0];
			if (s.pos.length > 1) pos.y = s.pos[1];
		}
		var sprite = new FlxStageSprite(pos.x, pos.y);
		sprite.name = s.name;
		sprite.type = "Bitmap";
		sprite.antialiasing = s.antialiasing != null ? s.antialiasing : true;

		var sf = new FlxPoint(1, 1);
		if (s.scrollFactor != null) {
			if (s.scrollFactor.length > 0) sf.x = s.scrollFactor[0];
			if (s.scrollFactor.length > 1) sf.y = s.scrollFactor[1];
		}
		sprite.scrollFactor.set(sf.x, sf.y);

		sprite.spritePath = s.src;
		if (s.src != null) {
			var bitmap = Paths.image(s.src, 'mods/$mod');
			if (Assets.exists(bitmap)) sprite.loadGraphic(bitmap);
		}
		doTheRest(sprite, s, mod);
		return sprite;
	}

	public function destroy() {
		for(s in sprites) {
			s.destroy();
			PlayState.current.remove(s);
		}
		sprites = [];
		onBeatAnimSprites = [];
		onBeatForceAnimSprites = [];
	}
	
	public function update(elapsed:Float) {
		for(e in onBeatTweenSprites) {
			if (Conductor.crochet == 0) {
				e.sprite.offset.set(0, 0);
			} else {
				var easeVar = e.easeFunc((Conductor.songPosition / Conductor.crochet) % 1);
				
				e.sprite.updateHitbox();
				e.sprite.offset.x += e.offset.x * easeVar;
				e.sprite.offset.y += e.offset.y * easeVar;
			}
		}
	}
}