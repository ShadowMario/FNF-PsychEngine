package;

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var playerposition:Array<Float>; //bcuz dammit some of em don't exactly flip right
	var camera_position:Array<Float>;
	var player_camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var isPlayerChar:Bool;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
	var playerOffsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animPlayerOffsets:Map<String, Array<Dynamic>>; //for saving as jsons lol
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var daZoom:Float = 1;
	public var isCustom:Bool = false;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var isPsychPlayer:Bool;

	public var healthIcon:String = 'face';
	public var doMissThing:Bool = false;
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var playerPositionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var playerCameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		animPlayerOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		animPlayerOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':

			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';

				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);

				if (json.isPlayerChar)
					isPsychPlayer = json.isPlayerChar;

				var spriteType = "sparrow";
				//sparrow
				//packer
				//texture
				#if MODS_ALLOWED
				var modTxtToFind:String = Paths.modsTxt(json.image);
				var txtToFind:String = Paths.getPath('images/' + json.image + '.txt', TEXT);
				
				//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
				//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
				
				if (FileSystem.exists(modTxtToFind) || FileSystem.exists(txtToFind) || Assets.exists(txtToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
				#end
				{
					spriteType = "packer";
				}
				
				#if MODS_ALLOWED
				var modAnimToFind:String = Paths.modFolders('images/' + json.image + '/Animation.json');
				var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
				
				//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
				//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
				
				if (FileSystem.exists(modAnimToFind) || FileSystem.exists(animToFind) || Assets.exists(animToFind))
				#else
				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
				#end
				{
					spriteType = "texture";
				}

				switch (spriteType){
					
					case "packer":
						frames = Paths.getPackerAtlas(json.image);
					
					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image);
					
					case "texture":
						frames = AtlasFrameMaker.construct(json.image);
				}
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				healthIcon = json.healthicon;

				if (isPlayer && json.playerposition != null)
					positionArray = json.playerposition;
				else
					positionArray = json.position;

				if (json.playerposition != null)
					playerPositionArray = json.playerposition;
				else
					playerPositionArray = json.position;

				if (isPlayer && json.player_camera_position != null)
					cameraPosition = json.player_camera_position;
				else
					cameraPosition = json.camera_position;

				if (json.player_camera_position != null)
					playerCameraPosition = json.player_camera_position;
				else
					playerCameraPosition = json.camera_position;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if (isPlayer)
						{
							if(anim.playerOffsets != null && anim.playerOffsets.length > 1) {
								addOffset(anim.anim, anim.playerOffsets[0], anim.playerOffsets[1]);
							}
							else if(anim.offsets != null && anim.offsets.length > 1) {
								addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
							}
						}
						else
						{
							if(anim.offsets != null && anim.offsets.length > 1) {
								addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
							}
						}

						if(anim.playerOffsets != null && anim.playerOffsets.length > 1) {
							addPlayerOffset(anim.anim, anim.playerOffsets[0], anim.playerOffsets[1]);
						}
					
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
					quickAnimAdd('singUP', 'BF idle dance');
					quickAnimAdd('singDOWN', 'BF idle dance');
					quickAnimAdd('singLEFT', 'BF idle dance');
					quickAnimAdd('singRIGHT', 'BF idle dance');
				}

				if (animOffsets.exists('danceRight'))
					playAnim('danceRight');
				else
					playAnim('idle');
		}

		if(animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
			danceIdle = true;

		if(animation.getByName('singUPmiss') == null)
			doMissThing = true; //if for some reason you only have an up miss, why?

		originalFlipX = flipX;

		if (curCharacter.contains('dad'))
			singDuration = 6.1;

		//if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		//recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && !isPsychPlayer)
				flipAnims();
		}

		if (!isPlayer)
		{
			// Flip for just bf
			if (curCharacter.startsWith('bf') || isPsychPlayer)
				flipAnims();
		}

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}
	}

	public function flipAnims()
	{
		// var animArray
		if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
			{
				var oldSing = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldSing;
			}

			if(animation.getByName('singLEFT-alt') != null && animation.getByName('singRIGHT-alt') != null)
			{
				var oldSingAlt = animation.getByName('singRIGHT-alt').frames;
				animation.getByName('singRIGHT-alt').frames = animation.getByName('singLEFT-alt').frames;
				animation.getByName('singLEFT-alt').frames = oldSingAlt;
			}

			if(animation.getByName('singLEFT-loop') != null && animation.getByName('singRIGHT-loop') != null)
			{
				var oldSingLoop = animation.getByName('singRIGHT-loop').frames;
				animation.getByName('singRIGHT-loop').frames = animation.getByName('singLEFT-loop').frames;
				animation.getByName('singLEFT-loop').frames = oldSingLoop;
			}

			if(animation.getByName('singLEFT-alt-loop') != null && animation.getByName('singRIGHT-alt-loop') != null)
			{
				var oldSingAltLoop = animation.getByName('singRIGHT-alt-loop').frames;
				animation.getByName('singRIGHT-alt-loop').frames = animation.getByName('singLEFT-alt-loop').frames;
				animation.getByName('singLEFT-alt-loop').frames = oldSingAltLoop;
			}

			// IF THEY HAVE MISS ANIMATIONS??
			if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
			{
				var oldMiss = animation.getByName('singRIGHTmiss').frames;
				animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
				animation.getByName('singLEFTmiss').frames = oldMiss;
			}

			if (animation.getByName('singLEFTmiss-alt') != null && animation.getByName('singRIGHTmiss-alt') != null)
			{
				var oldMissAlt = animation.getByName('singRIGHTmiss-alt').frames;
				animation.getByName('singRIGHTmiss-alt').frames = animation.getByName('singLEFTmiss-alt').frames;
				animation.getByName('singLEFTmiss-alt').frames = oldMissAlt;
			}

			// DanceLeft Or DanceRight Shit
			if(animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
			{
				var oldDance = animation.getByName('danceRight').frames;
				animation.getByName('danceRight').frames = animation.getByName('danceLeft').frames;
				animation.getByName('danceLeft').frames = oldDance;
			}

			if(animation.getByName('danceLeft-alt') != null && animation.getByName('danceRight-alt') != null)
			{
				var oldDanceAlt = animation.getByName('danceRight-alt').frames;
				animation.getByName('danceRight-alt').frames = animation.getByName('danceLeft-alt').frames;
				animation.getByName('danceLeft-alt').frames = oldDanceAlt;
			}

			if(animation.getByName('danceLeft-loop') != null && animation.getByName('danceRight-loop') != null)
			{
				var oldDanceLoop = animation.getByName('danceRight-loop').frames;
				animation.getByName('danceRight-loop').frames = animation.getByName('danceLeft-loop').frames;
				animation.getByName('danceLeft-loop').frames = oldDanceLoop;
			}

			if(animation.getByName('danceLeft-alt-loop') != null && animation.getByName('danceRight-alt-loop') != null)
			{
				var oldDanceAltLoop = animation.getByName('danceRight-alt-loop').frames;
				animation.getByName('danceRight-alt-loop').frames = animation.getByName('danceLeft-alt-loop').frames;
				animation.getByName('danceLeft-alt-loop').frames = oldDanceAltLoop;
			}
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}
			
			switch(curCharacter)
			{
				case 'pico-speaker':
					if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						var noteData:Int = 1;
						if(animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	var missed:Bool = false;

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		if (missed)
			color = 0xCFAFFF;
		else if (color != FlxColor.WHITE && doMissThing)
			color = FlxColor.WHITE;

		var daOffset = animOffsets.get(AnimName);

		if (debugMode && isPlayer)
			daOffset = animPlayerOffsets.get(AnimName);
		
		if (debugMode)
		{
			if (animOffsets.exists(AnimName) && !isPlayer || animPlayerOffsets.exists(AnimName) && isPlayer)
				offset.set(daOffset[0] * daZoom, daOffset[1] * daZoom);
			else
				offset.set(0, 0);
		}
		else
		{
			if (animOffsets.exists(AnimName))
				offset.set(daOffset[0] * daZoom, daOffset[1] * daZoom);
			else
				offset.set(0, 0);
		}

		if (curCharacter.startsWith('gf'))
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
	
	function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				animationNotes.push(songNotes);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function addPlayerOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animPlayerOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
