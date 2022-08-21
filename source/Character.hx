package;

// import sys.io.File;
import Script.DummyScript;
import psychstuff.PsychCharacter;
import dev_toolbox.stage_editor.FlxStageSprite;
import mod_support_stuff.FlxColor_Helper;
import Script.HScript;
import openfl.utils.Assets;
import haxe.macro.ExprTools.ExprArrayTools;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import PlayState.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

using StringTools;
/**
* Main Character class for Characters as BF, GF, Daddy Dearest, Mommy Mearest, etc...
* Also this is based off FlxStageSprite BUT since it doesn't override anything it won't interfere with anything so we good
*/
class Character extends FlxStageSprite
{
	/**
	 * Animation Offsets.
	 */
	public var animOffsets:Map<String, Array<Float>>;

	/**
     * Camera Offsets
	 */
	public var cameraOffsets:Map<String, Array<Float>>;
	
	/**
	 * If true, character's animations will be disabled, preventing the game from crashing and allowing debugging of the sprite
	 */
	public var debugMode:Bool = false;
	/**
	 * Character's global offset
	 */
	public var charGlobalOffset:FlxPoint = new FlxPoint(0, 0);
	/**
	 * Camera Offset, at the beginning of the song
	 */
	public var camOffset:FlxPoint = new FlxPoint(0, 0);

	/**
	 * Beat used for the animation (barely used)
	 */
	var curBeat:Int = 0;

	/**
	 * Whenever the character is the player or not
	 */
	public var isPlayer:Bool = false;
	/**
	 * Character name
	 */
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var longAnims:Array<String> = [];

	/**
	 * DO NOT USE, always results to null unless loadJSON is called.
	 */
	public var json:dev_toolbox.CharacterJSON = null;

	/**
		Only not equal to null if it's a Psych Engine character
	**/
	public var psychJson:dev_toolbox.CharacterJSON = null;

	public var healthIcon(default, set):HealthIcon;
	public function set_healthIcon(h:HealthIcon):HealthIcon {
		healthIcon = h;
		if (characterScript != null) characterScript.executeFunc("healthIcon", [h]);
		return h;
	}

	public var characterScript:Script;

	/**
	 * Gets camera position for the character
	 */
	 public function getCamPos() {
		var midpoint = getMidpoint();
		var pos:FlxPoint = null;
		if (isPlayer) {
			pos = new FlxPoint(midpoint.x - 100 + camOffset.x, midpoint.y - 100 + camOffset.y);
		} else {
			pos = new FlxPoint(midpoint.x + 150 + camOffset.x, midpoint.y - 100 + camOffset.y);
		}
		var camOffset:Array<Float>;
		if ((camOffset = cameraOffsets[getAnimName()]) != null) {
			pos.x += camOffset[0];
			pos.y += camOffset[1];
		}
		return pos;
	 }

	/**
	 * Creates a new character at the specified location. Please note that the location will be altered by the character's global offsets.
	 * @param x					X position of the character
	 * @param y					Y position of the character
	 * @param character			Character (ex : `bf`, `gf`, `dad`), not identical as the spritesheet
	 * @param isPlayer			Whenever the character is the player or not.
	 * @param textureOverride 	Optional, allows you to override the texture. (ex : `bf` as char for Boyfriend's anims and assets, and `blammed` for the Boyfriend blammed appearance)
	 */
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, cloneBitmap:Bool = false, ?textureOverride:String = "")
	{
		super(x, y);


		animOffsets = new Map<String, Array<Float>>();
		cameraOffsets = new Map<String, Array<Float>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;


		
		if (!loadPsychJSON()) {// for psych compatibility
			var p = Paths.getCharacterFolderPath(curCharacter) + "/Character";
			characterScript = Script.create(p);
			if (characterScript == null) {
				LogsOverlay.error(Paths.getCharacterFolderPath(curCharacter) + "/Character is missing");
				characterScript = new DummyScript();
			}
			characterScript.setVariable("curCharacter", curCharacter);
			characterScript.setVariable("character", this);
			characterScript.setVariable("textureOverride", textureOverride);
			characterScript.setVariable("dance", function() {
				if (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null) {
					playAnim(danced ? "danceLeft" : "danceRight");
					danced = !danced;
				} else {
					playAnim("idle");
				}
			});
			characterScript.setVariable("create", function() {});
			characterScript.setVariable("update", function(elapsed:Float) {});
			characterScript.setVariable("onAnim", function(animName:String) {});
			characterScript.setVariable("getColors", function(altAnim:Bool) {
				return [
					(this.isPlayer ? new FlxColor(0xFF66FF33) : new FlxColor(0xFFFF0000)),
					new FlxColor(Settings.engineSettings.data.arrowColor0),
					new FlxColor(Settings.engineSettings.data.arrowColor1),
					new FlxColor(Settings.engineSettings.data.arrowColor2),
					new FlxColor(Settings.engineSettings.data.arrowColor3)
				];
			});
			var sName = curCharacter.split(":");
			ModSupport.setScriptDefaultVars(characterScript, sName.length > 1 ? sName[0] : "Friday Night Funkin'", {"cloneBitmap" : cloneBitmap});
			try {
				characterScript.setScriptObject(this);
				characterScript.loadFile(p);
			} catch(e) {
				return;
			}


			try {
				characterScript.executeFunc("create");
			} catch(ex) {
				trace(ex);
			}
			this.animation.add("", [0], 24, true);
		} 

		dance();

		this.x += charGlobalOffset.x;
		this.y += charGlobalOffset.y;

		if (isPlayer)
		{
			flipX = !flipX;
		}
	}

	
	public function loadPsychJSON(overrideFuncs:Bool = true):Bool {
		var char = curCharacter.split(":");
		var c = char[char.length - 1];
		var psychCharPath = Paths.file('characters/${c}.json');

		if (Assets.exists(psychCharPath)) {
			characterScript = new DummyScript();
			var json:PsychCharacter = null;
			try {
				json = Json.parse(Assets.getText(psychCharPath));
			} catch(e) {
				// dumb fuck
				LogsOverlay.error(e);
				return false;
			}
			frames = Paths.getSparrowAtlas(json.image);
			if (json.animations != null) {
				for(a in json.animations) {
					if (a.fps == null) a.fps = 24;
					if (a.indices != null && a.indices.length > 0) {
						animation.addByIndices(a.anim, a.name, a.indices, "", a.fps, a.loop);
					} else {
						animation.addByPrefix(a.anim, a.name, a.fps, a.loop);
					}
					if (a.offsets != null) {
						addOffset(a.anim, a.offsets[0], a.offsets[1]);
					}
				}
			}
			antialiasing = !json.no_antialiasing;
			flipX = json.flip_x;

			var healthBarColor:FlxColor = 0xFFFF0000;

			if (json.position != null)
				charGlobalOffset = new FlxPoint(json.position[0], json.position[1]);
			if (json.healthbar_colors != null)
				healthBarColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
			if (json.camera_position != null)
				camOffset = new FlxPoint(json.camera_position[0], json.camera_position[1]);
			if (json.sing_duration != null)
				dadVar = json.sing_duration;
			if (json.scale != null) {
				scale.set(json.scale, json.scale);
				updateHitbox();
			}
			if (overrideFuncs) {
				characterScript.setVariable("dance", function() {
					if (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null) {
						playAnim(danced ? "danceLeft" : "danceRight");
						danced = !danced;
					} else {
						playAnim("idle");
					}
				});
				characterScript.setVariable("getColors", function() {return [healthBarColor];});
				var char = curCharacter.split(":");

				if (json.healthicon != null && json.healthicon != char[char.length - 1] && char.length > 1) {
					characterScript.setVariable("healthIcon", function(h) {
						cast(h, HealthIcon).changeCharacter(json.healthicon, char[0]);
					});
				}
			}
			return true;
		}
		return false;
	}

	/**
	 * Get the character's note colors and healthbar animation.
	 *
	 * The four first elements of the `Array<FlxColor>` returned are note color in order, while the 5th parameter (if existent), will return the health bar color.
	 *
	 * @param character			The character (`bf`, `gf`...)
	 * @param altAnim			Y position of the character
	 */

	public function loadJSON(overrideFuncs:Bool) {
		
		var mod = null;
		var charFull = curCharacter.split(":");
		if (charFull.length < 2) charFull.insert(0, null);

		var path = Paths.getPath('characters/${CoolUtil.getLastOfArray(curCharacter.split(":"))}/character.json', TEXT, charFull[0] == null ? null : 'mods/${charFull[0]}');
		if (!Assets.exists(path)) {
			if (charFull[0] == null) charFull.shift();
			LogsOverlay.error('Character JSON for ${charFull.join(":")} doesn\'t exist.');
			return;
		}
		try {
			json = Json.parse(Assets.getText(path));
		} catch(e) {
			if (charFull[0] == null) charFull.shift();
			LogsOverlay.error('Character JSON for ${charFull.join(":")} is invalid\n\n$e.');
			return;
		}
		load(overrideFuncs);
	}

	public function load(overrideFuncs:Bool) {
		if (overrideFuncs) {
			var anims = [];
			@:privateAccess
			var it = animation._animations.keys();
			while (it.hasNext()) {
				anims.push(it.next());
			}
			for(a in anims) animation.remove(a);
		}
		this.antialiasing = json.antialiasing;
		if (json.camOffset != null) {
			this.camOffset.x = json.camOffset.x;
			this.camOffset.y = json.camOffset.y;
		}
		if (json.globalOffset != null) {
			this.charGlobalOffset.x = json.globalOffset.x;
			this.charGlobalOffset.y = json.globalOffset.y;
		}
		if (overrideFuncs) {
			var i = 0;
			if (json.danceSteps != null) {
				characterScript.setVariable("dance", function() {
					playAnim(json.danceSteps[i]);
					i++;
					i = i % json.danceSteps.length;
				});
			}
			if (json.healthIconSteps != null && (json.healthIconSteps.length != 2 || json.healthIconSteps[0][0] != 20 || json.healthIconSteps[1][0] != 0)) characterScript.setVariable("healthIcon", function(e) {
				e.frameIndexes = json.healthIconSteps;
			});
		}
		if (healthIcon != null) healthIcon.frameIndexes = json.healthIconSteps != null ? json.healthIconSteps : [[20, 0], [0, 1]];
		for (anim in json.anims) {
			if (anim.indices == null || anim.indices.length == 0) {
				animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);
			} else {
				animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
			}
			addOffset(anim.name, anim.x, anim.y);
		}
		playAnim(json.danceSteps[0]);
		if (json.scale != 1) setGraphicSize(Std.int(width * json.scale));
		if (json.flipX) flipX = !flipX;
		
		var healthColor = FlxColor.fromString(json.healthbarColor);
		if (healthColor == null) healthColor = 0xFFFF0000;
		var returnArray = [healthColor];
		var array = [];
		if (PlayState.current != null) {
			var array = [
				PlayState.current.engineSettings.arrowColor0,
				PlayState.current.engineSettings.arrowColor1,
				PlayState.current.engineSettings.arrowColor2,
				PlayState.current.engineSettings.arrowColor3
			];
		} else {
			var array = [
				Settings.engineSettings.data.arrowColor0,
				Settings.engineSettings.data.arrowColor1,
				Settings.engineSettings.data.arrowColor2,
				Settings.engineSettings.data.arrowColor3
			];
		}
		if (json.arrowColors != null) {
			if (json.arrowColors.length > 0) {
				array = [];
				for (k=>c in json.arrowColors) {
					var nC = FlxColor.fromString(c);
					if (nC != null) array[k] = nC;
				}
			}
		}
		for (e in array) {
			returnArray.push(e);
		}
		if (overrideFuncs) {
			characterScript.setVariable("getColors", function(altAnim) {
				return returnArray;
			});
		}
		scale.set(json.scale, json.scale);
	}

	public function getColors(altAnim:Bool = false):Array<FlxColor>
	{
		var defNoteColors = [
			Settings.engineSettings.data.arrowColor0,
			Settings.engineSettings.data.arrowColor1,
			Settings.engineSettings.data.arrowColor2,
			Settings.engineSettings.data.arrowColor3
		];
		var c2:Array<Dynamic> = characterScript.executeFunc("getColors", [altAnim]);
		if (c2 == null) c2 = [];
		var c:Array<Int> = [];
		for(e in c2) {
			if (Std.isOfType(e, Int)) {
				c.push(e);
			} else if (Std.isOfType(e, FlxColor_Helper)) {
				c.push(cast(e, FlxColor_Helper).color);
			}
		}
		var invalid = false;
		invalid = c == null;
		if (!invalid) invalid = c.length < 1;
		if (invalid) c = [
			(this.isPlayer ? 0xFF66FF33 : 0xFFFF0000),
			Settings.engineSettings.data.arrowColor0,
			Settings.engineSettings.data.arrowColor1,
			Settings.engineSettings.data.arrowColor2,
			Settings.engineSettings.data.arrowColor3
		];
		if (c.length < 5) {
			for (i in c.length...5) {
				c.push(switch(i) {
					case 0:
						(this.isPlayer ? 0xFF66FF33 : 0xFFFF0000);
					case 1:
						Settings.engineSettings.data.arrowColor0;
					case 2:
						Settings.engineSettings.data.arrowColor1;
					case 3:
						Settings.engineSettings.data.arrowColor2;
					case 4:
						Settings.engineSettings.data.arrowColor3;
					default:
						0xFFFFFFFF;
				});
			}
		}

		return c;
	}

	var dadVar:Float = 4;

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null) {
			if (!isPlayer)
			{
					if (animation.curAnim.name.startsWith('sing'))
					{
						holdTimer += elapsed;
					}
		
					if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
					{
						dance();
						holdTimer = 0;
					}
			}
		
			switch (curCharacter)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight');
			}
		}
		

		characterScript.executeFunc("update", [elapsed]);
		super.update(elapsed);

		if (animation.curAnim != null) {
			if (animOffsets.exists(animation.curAnim.name))
			{
				var daOffset = animOffsets[animation.curAnim.name];
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
		}
	}

	

	/**
	 * Useful for character with two dancing animations (Girlfriend or Skid & Pump).
	 */
	private var danced:Bool = false;

	/**
	 * "FOR GF DANCING SHIT"
	 * Make the character dance
	 * @param left				Unused.
	 * @param down				Unused.
	 * @param up				Unused.
	 * @param right				Unused.
	 */
	public function dance(force:Bool = false, left:Bool = false, down:Bool = false, up:Bool = false, right:Bool = false)
	{
		if (lastNoteHitTime + 250 > Conductor.songPosition) return; // 250 ms until dad dances
		var dontDance = ["firstDeath", "deathLoop", "deathConfirm"];
		if (animation.curAnim != null && !force) if (!animation.curAnim.name.startsWith("sing") &&!animation.curAnim.name.startsWith("dance") && !animation.curAnim.finished) return;
		if (!debugMode)
			characterScript.executeFunc("dance");		
	}

	public var lastHit:Float = -60000;


	/**
	 * Plays the specified animation.
	 * If the animation doesn't exist, the animation name is traced, preventing exceptions.
	 * @param AnimName			Animation Name
	 * @param Force				Whenever it should restart the animation or not if it's already playinh
	 * @param Reversed			Whenever it should play the animation backwards or not
	 * @param Frame				Frame to begin with
	 */

	public var lastNoteHitTime:Float = -60000;
	private var unknownAnimsAlerted:Array<String> = [];
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName.startsWith("sing")) {
			lastNoteHitTime = Conductor.songPosition;
		}
		var blockAnim:Null<Bool> = characterScript.executeFunc("onAnim", [AnimName, Force, Reversed, Frame]);

		if (blockAnim != true) {
			// will obviously not play the animation and "pause it", to prevent null exception. it will keep the current frame and not set the offset.
			animation.play(AnimName, Force, Reversed, Frame);
			if (animation.getByName(AnimName) == null) {
				if (!unknownAnimsAlerted.contains(AnimName)) {
					LogsOverlay.error('Character.playAnim: $AnimName doesn\'t exist on character $curCharacter');
					unknownAnimsAlerted.push(AnimName);
				}
				return;
			}
			if (isPlayer && AnimName == "singLEFT" && flipX)
				AnimName = "singRIGHT";
			else if (isPlayer && AnimName == "singRIGHT" && flipX)
				AnimName = "singLEFT";
	
			var daOffset = animOffsets.get(AnimName);
			if (isPlayer && AnimName != "idle")
			{
				lastHit = Conductor.songPosition;
			}
			if (daOffset != null)
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
	
			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}
	
				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}

	

	/**
	 * Add an offset
	 * @param name Name of the offset
	 * @param x X offset
	 * @param y Y offset
	 */
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}


	/**
	 * Add a camera offset
	 * @param name Name of the offset
	 * @param x X offset
	 * @param y Y offset
	 */
	public function addCameraOffset(name:String, x:Float = 0, y:Float = 0) {
		cameraOffsets[name] = [x, y];
	}

	/**
	 Prevents null ref exceptions
	 */
	public function getAnimName() {
		return animation.curAnim == null ? "" : animation.curAnim.name;
	}
}