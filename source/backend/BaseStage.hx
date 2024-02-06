package backend;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import backend.MusicBeatState;

import objects.Note.EventNote;
import objects.Character;

enum Countdown
{
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

class BaseStage extends FlxBasic
{
	private var game(default, set):Dynamic = PlayState.instance;
	public var onPlayState:Bool = false;

	// some variables for convenience
	public var paused(get, never):Bool;
	public var songName(get, never):String;
	public var isStoryMode(get, never):Bool;
	public var seenCutscene(get, never):Bool;
	public var inCutscene(get, set):Bool;
	public var canPause(get, set):Bool;
	public var members(get, never):Dynamic;

	public var boyfriend(get, never):Character;
	public var dad(get, never):Character;
	public var gf(get, never):Character;
	public var boyfriendGroup(get, never):FlxSpriteGroup;
	public var dadGroup(get, never):FlxSpriteGroup;
	public var gfGroup(get, never):FlxSpriteGroup;
	
	public var camGame(get, never):FlxCamera;
	public var camHUD(get, never):FlxCamera;
	public var camOther(get, never):FlxCamera;

	public var defaultCamZoom(get, set):Float;
	public var camFollow(get, never):FlxObject;

	public function new()
	{
		this.game = MusicBeatState.getState();
		if(this.game == null)
		{
			FlxG.log.warn('Invalid state for the stage added!');
			destroy();
		}
		else 
		{
			this.game.stages.push(this);
			super();
			create();
		}
	}

	//main callbacks
	public function create() {}
	public function createPost() {}
	//public function update(elapsed:Float) {}
	public function countdownTick(count:Countdown, num:Int) {}

	// FNF steps, beats and sections
	public var curBeat:Int = 0;
	public var curDecBeat:Float = 0;
	public var curStep:Int = 0;
	public var curDecStep:Float = 0;
	public var curSection:Int = 0;
	public function beatHit() {}
	public function stepHit() {}
	public function sectionHit() {}

	// Substate close/open, for pausing Tweens/Timers
	public function closeSubState() {}
	public function openSubState(SubState:FlxSubState) {}

	// Events
	public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {}
	public function eventPushed(event:EventNote) {}
	public function eventPushedUnique(event:EventNote) {}

	// Things to replace FlxGroup stuff and inject sprites directly into the state
	function add(object:FlxBasic) game.add(object);
	function remove(object:FlxBasic) game.remove(object);
	function insert(position:Int, object:FlxBasic) game.insert(position, object);
	
	public function addBehindGF(obj:FlxBasic) insert(members.indexOf(game.gfGroup), obj);
	public function addBehindBF(obj:FlxBasic) insert(members.indexOf(game.boyfriendGroup), obj);
	public function addBehindDad(obj:FlxBasic) insert(members.indexOf(game.dadGroup), obj);
	public function setDefaultGF(name:String) //Fix for the Chart Editor on Base Game stages
	{
		var gfVersion:String = PlayState.SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = name;
			PlayState.SONG.gfVersion = gfVersion;
		}
	}

	//start/end callback functions
	public function setStartCallback(myfn:Void->Void)
	{
		if(!onPlayState) return;
		PlayState.instance.startCallback = myfn;
	}
	public function setEndCallback(myfn:Void->Void)
	{
		if(!onPlayState) return;
		PlayState.instance.endCallback = myfn;
	}

	// overrides
	function startCountdown() if(onPlayState) return PlayState.instance.startCountdown(); else return false;
	function endSong() if(onPlayState)return PlayState.instance.endSong(); else return false;
	function moveCameraSection() if(onPlayState) moveCameraSection();
	function moveCamera(isDad:Bool) if(onPlayState) moveCamera(isDad);
	inline private function get_paused() return game.paused;
	inline private function get_songName() return game.songName;
	inline private function get_isStoryMode() return PlayState.isStoryMode;
	inline private function get_seenCutscene() return PlayState.seenCutscene;
	inline private function get_inCutscene() return game.inCutscene;
	inline private function set_inCutscene(value:Bool)
	{
		game.inCutscene = value;
		return value;
	}
	inline private function get_canPause() return game.canPause;
	inline private function set_canPause(value:Bool)
	{
		game.canPause = value;
		return value;
	}
	inline private function get_members() return game.members;
	inline private function set_game(value:MusicBeatState)
	{
		onPlayState = (Std.isOfType(value, states.PlayState));
		game = value;
		return value;
	}

	inline private function get_boyfriend():Character return game.boyfriend;
	inline private function get_dad():Character return game.dad;
	inline private function get_gf():Character return game.gf;

	inline private function get_boyfriendGroup():FlxSpriteGroup return game.boyfriendGroup;
	inline private function get_dadGroup():FlxSpriteGroup return game.dadGroup;
	inline private function get_gfGroup():FlxSpriteGroup return game.gfGroup;
	
	inline private function get_camGame():FlxCamera return game.camGame;
	inline private function get_camHUD():FlxCamera return game.camHUD;
	inline private function get_camOther():FlxCamera return game.camOther;

	inline private function get_defaultCamZoom():Float return game.defaultCamZoom;
	inline private function set_defaultCamZoom(value:Float):Float
	{
		game.defaultCamZoom = value;
		return game.defaultCamZoom;
	}
	inline private function get_camFollow():FlxObject return game.camFollow;
}