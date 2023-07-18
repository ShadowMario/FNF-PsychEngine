package cutscenes;

import tjson.TJSON as Json;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

typedef DialogueAnimArray = {
	var anim:String;
	var loop_name:String;
	var loop_offsets:Array<Int>;
	var idle_name:String;
	var idle_offsets:Array<Int>;
}

typedef DialogueCharacterFile = {
	var image:String;
	var dialogue_pos:String;
	var no_antialiasing:Bool;

	var animations:Array<DialogueAnimArray>;
	var position:Array<Float>;
	var scale:Float;
}

class DialogueCharacter extends FlxSprite
{
	private static var IDLE_SUFFIX:String = '-IDLE';
	public static var DEFAULT_CHARACTER:String = 'bf';
	public static var DEFAULT_SCALE:Float = 0.7;

	public var jsonFile:DialogueCharacterFile = null;
	public var dialogueAnimations:Map<String, DialogueAnimArray> = new Map<String, DialogueAnimArray>();

	public var startingPos:Float = 0; //For center characters, it works as the starting Y, for everything else it works as starting X
	public var isGhost:Bool = false; //For the editor
	public var curCharacter:String = 'bf';
	public var skiptimer = 0;
	public var skipping = 0;
	public function new(x:Float = 0, y:Float = 0, character:String = null)
	{
		super(x, y);

		if(character == null) character = DEFAULT_CHARACTER;
		this.curCharacter = character;

		reloadCharacterJson(character);
		frames = Paths.getSparrowAtlas('dialogue/' + jsonFile.image);
		reloadAnimations();

		antialiasing = ClientPrefs.data.antialiasing;
		if(jsonFile.no_antialiasing == true) antialiasing = false;
	}

	public function reloadCharacterJson(character:String) {
		var characterPath:String = 'images/dialogue/' + character + '.json';
		var rawJson = null;

		#if MODS_ALLOWED
		var path:String = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path)) {
			path = Paths.getPreloadPath(characterPath);
		}

		if(!FileSystem.exists(path)) {
			path = Paths.getPreloadPath('images/dialogue/' + DEFAULT_CHARACTER + '.json');
		}
		rawJson = File.getContent(path);

		#else
		var path:String = Paths.getPreloadPath(characterPath);
		rawJson = Assets.getText(path);
		#end
		
		jsonFile = cast Json.parse(rawJson);
	}

	public function reloadAnimations() {
		dialogueAnimations.clear();
		if(jsonFile.animations != null && jsonFile.animations.length > 0) {
			for (anim in jsonFile.animations) {
				animation.addByPrefix(anim.anim, anim.loop_name, 24, isGhost);
				animation.addByPrefix(anim.anim + IDLE_SUFFIX, anim.idle_name, 24, true);
				dialogueAnimations.set(anim.anim, anim);
			}
		}
	}

	public function playAnim(animName:String = null, playIdle:Bool = false) {
		var leAnim:String = animName;
		if(animName == null || !dialogueAnimations.exists(animName)) { //Anim is null, get a random animation
			var arrayAnims:Array<String> = [];
			for (anim in dialogueAnimations) {
				arrayAnims.push(anim.anim);
			}
			if(arrayAnims.length > 0) {
				leAnim = arrayAnims[FlxG.random.int(0, arrayAnims.length-1)];
			}
		}

		if(dialogueAnimations.exists(leAnim) &&
		(dialogueAnimations.get(leAnim).loop_name == null ||
		dialogueAnimations.get(leAnim).loop_name.length < 1 ||
		dialogueAnimations.get(leAnim).loop_name == dialogueAnimations.get(leAnim).idle_name)) {
			playIdle = true;
		}
		animation.play(playIdle ? leAnim + IDLE_SUFFIX : leAnim, false);

		if(dialogueAnimations.exists(leAnim)) {
			var anim:DialogueAnimArray = dialogueAnimations.get(leAnim);
			if(playIdle) {
				offset.set(anim.idle_offsets[0], anim.idle_offsets[1]);
				//trace('Setting idle offsets: ' + anim.idle_offsets);
			} else {
				offset.set(anim.loop_offsets[0], anim.loop_offsets[1]);
				//trace('Setting loop offsets: ' + anim.loop_offsets);
			}
		} else {
			offset.set(0, 0);
			trace('Offsets not found! Dialogue character is badly formatted, anim: ' + leAnim + ', ' + (playIdle ? 'idle anim' : 'loop anim'));
		}
	}

	public function animationIsLoop():Bool {
		if(animation.curAnim == null) return false;
		return !animation.curAnim.name.endsWith(IDLE_SUFFIX);
	}
}