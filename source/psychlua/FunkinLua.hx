#if LUA_ALLOWED
package psychlua;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import openfl.Lib;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxObject;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

import cutscenes.DialogueBoxPsych;

import objects.StrumNote;
import objects.Note;
import objects.NoteSplash;
import objects.Character;

import states.MainMenuState;
import states.StoryMenuState;
import states.FreeplayState;

import substates.PauseSubState;
import substates.GameOverSubstate;

import psychlua.LuaUtils;
import psychlua.LuaUtils.LuaTweenOptions;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end
import psychlua.DebugLuaText;
import psychlua.ModchartSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import haxe.Json;

class FunkinLua {
	public var lua:State = null;
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var modFolder:String = null;
	public var closed:Bool = false;

	#if HSCRIPT_ALLOWED
	public var hscript:HScript = null;
	#end

	public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var customFunctions:Map<String, Dynamic> = new Map<String, Dynamic>();

	public function new(scriptName:String) {
		lua = LuaL.newstate();
		LuaL.openlibs(lua);

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		//LuaL.dostring(lua, CLENSE);

		this.scriptName = scriptName.trim();
		var game:PlayState = PlayState.instance;
		if(game != null) game.luaArray.push(this);

		var myFolder:Array<String> = this.scriptName.split('/');
		#if MODS_ALLOWED
		if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
			this.modFolder = myFolder[1];
		#end

		// Lua shit
		set('Function_StopLua', LuaUtils.Function_StopLua);
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);
		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('version', MainMenuState.psychEngineVersion.trim());
		set('modFolder', this.modFolder);

		// Song/Week shit
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('songPath', Paths.formatToSongPath(PlayState.SONG.song));
		set('loadedSongName', Song.loadedSongName);
		set('loadedSongPath', Paths.formatToSongPath(Song.loadedSongName));
		set('chartPath', Song.chartPath);
		set('startedCountdown', false);
		set('curStage', PlayState.SONG.stage);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);

		set('difficultyName', Difficulty.getString(false));
		set('difficultyPath', Paths.formatToSongPath(Difficulty.getString(false)));
		set('difficultyNameTranslation', Difficulty.getString(true));
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);
		set('hasVocals', PlayState.SONG.needsVoices);

		// Camera poo
		set('cameraX', 0);
		set('cameraY', 0);

		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);


		// PlayState-only variables
		if(game != null)
		{
			set('curSection', 0);
			set('curBeat', 0);
			set('curStep', 0);
			set('curDecBeat', 0);
			set('curDecStep', 0);
	
			set('score', 0);
			set('misses', 0);
			set('hits', 0);
			set('combo', 0);
	
			set('rating', 0);
			set('ratingName', '');
			set('ratingFC', '');

			set('inGameOver', false);
			set('mustHitSection', false);
			set('altAnim', false);
			set('gfSection', false);

			set('healthGainMult', game.healthGain);
			set('healthLossMult', game.healthLoss);
	
			#if FLX_PITCH
			set('playbackRate', game.playbackRate);
			#else
			set('playbackRate', 1);
			#end
	
			set('guitarHeroSustains', game.guitarHeroSustains);
			set('instakillOnMiss', game.instakillOnMiss);
			set('botPlay', game.cpuControlled);
			set('practice', game.practiceMode);
	
			for (i in 0...4) {
				set('defaultPlayerStrumX' + i, 0);
				set('defaultPlayerStrumY' + i, 0);
				set('defaultOpponentStrumX' + i, 0);
				set('defaultOpponentStrumY' + i, 0);
			}
	
			// Default character data
			set('defaultBoyfriendX', game.BF_X);
			set('defaultBoyfriendY', game.BF_Y);
			set('defaultOpponentX', game.DAD_X);
			set('defaultOpponentY', game.DAD_Y);
			set('defaultGirlfriendX', game.GF_X);
			set('defaultGirlfriendY', game.GF_Y);

			set('boyfriendName', PlayState.SONG.player1);
			set('dadName', PlayState.SONG.player2);
			set('gfName', PlayState.SONG.gfVersion);
		}

		// Other settings
		set('downscroll', ClientPrefs.data.downScroll);
		set('middlescroll', ClientPrefs.data.middleScroll);
		set('framerate', ClientPrefs.data.framerate);
		set('ghostTapping', ClientPrefs.data.ghostTapping);
		set('hideHud', ClientPrefs.data.hideHud);
		set('timeBarType', ClientPrefs.data.timeBarType);
		set('scoreZoom', ClientPrefs.data.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.data.camZooms);
		set('flashingLights', ClientPrefs.data.flashing);
		set('noteOffset', ClientPrefs.data.noteOffset);
		set('healthBarAlpha', ClientPrefs.data.healthBarAlpha);
		set('noResetButton', ClientPrefs.data.noReset);
		set('lowQuality', ClientPrefs.data.lowQuality);
		set('shadersEnabled', ClientPrefs.data.shaders);
		set('scriptName', scriptName);
		set('currentModDirectory', Mods.currentModDirectory);

		// Noteskin/Splash
		set('noteSkin', ClientPrefs.data.noteSkin);
		set('noteSkinPostfix', Note.getNoteSkinPostfix());
		set('splashSkin', ClientPrefs.data.splashSkin);
		set('splashSkinPostfix', NoteSplash.getSplashSkinPostfix());
		set('splashAlpha', ClientPrefs.data.splashAlpha);

		// build target (windows, mac, linux, etc.)
		set('buildTarget', LuaUtils.getBuildTarget());

		//
		Lua_helper.add_callback(lua, "getRunningScripts", function() {
			var runningScripts:Array<String> = [];
			for (script in game.luaArray)
				runningScripts.push(script.scriptName);

			return runningScripts;
		});

		addLocalCallback("setOnScripts", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
			game.setOnScripts(varName, arg, exclusions);
		});
		addLocalCallback("setOnHScript", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
			game.setOnHScript(varName, arg, exclusions);
		});
		addLocalCallback("setOnLuas", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
			game.setOnLuas(varName, arg, exclusions);
		});

		addLocalCallback("callOnScripts", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops=false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null) {
			if(excludeScripts == null) excludeScripts = [];
			if(ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
			game.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
			return true;
		});
		addLocalCallback("callOnLuas", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops=false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null) {
			if(excludeScripts == null) excludeScripts = [];
			if(ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
			game.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
			return true;
		});
		addLocalCallback("callOnHScript", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops=false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null) {
			if(excludeScripts == null) excludeScripts = [];
			if(ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
			game.callOnHScript(funcName, args, ignoreStops, excludeScripts, excludeValues);
			return true;
		});

		Lua_helper.add_callback(lua, "callScript", function(luaFile:String, funcName:String, ?args:Array<Dynamic> = null) {
			if(args == null){
				args = [];
			}

			var foundScript:String = findScript(luaFile);
			if(foundScript != null)
				for (luaInstance in game.luaArray)
					if(luaInstance.scriptName == foundScript)
					{
						luaInstance.call(funcName, args);
						return;
					}
		});

		Lua_helper.add_callback(lua, "getGlobalFromScript", function(luaFile:String, global:String) { // returns the global from a script
			var foundScript:String = findScript(luaFile);
			if(foundScript != null)
				for (luaInstance in game.luaArray)
					if(luaInstance.scriptName == foundScript)
					{
						Lua.getglobal(luaInstance.lua, global);
						if(Lua.isnumber(luaInstance.lua,-1))
							Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
						else if(Lua.isstring(luaInstance.lua,-1))
							Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
						else if(Lua.isboolean(luaInstance.lua,-1))
							Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
						else
							Lua.pushnil(lua);

						// TODO: table

						Lua.pop(luaInstance.lua,1); // remove the global

						return;
					}
		});
		Lua_helper.add_callback(lua, "setGlobalFromScript", function(luaFile:String, global:String, val:Dynamic) { // returns the global from a script
			var foundScript:String = findScript(luaFile);
			if(foundScript != null)
				for (luaInstance in game.luaArray)
					if(luaInstance.scriptName == foundScript)
						luaInstance.set(global, val);
		});
		/*Lua_helper.add_callback(lua, "getGlobals", function(luaFile:String) { // returns a copy of the specified file's globals
			var foundScript:String = findScript(luaFile);
			if(foundScript != null)
			{
				for (luaInstance in game.luaArray)
				{
					if(luaInstance.scriptName == foundScript)
					{
						Lua.newtable(lua);
						var tableIdx = Lua.gettop(lua);

						Lua.pushvalue(luaInstance.lua, Lua.LUA_GLOBALSINDEX);
						while(Lua.next(luaInstance.lua, -2) != 0) {
							// key = -2
							// value = -1

							var pop:Int = 0;

							// Manual conversion
							// first we convert the key
							if(Lua.isnumber(luaInstance.lua,-2)){
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -2));
								pop++;
							}else if(Lua.isstring(luaInstance.lua,-2)){
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -2));
								pop++;
							}else if(Lua.isboolean(luaInstance.lua,-2)){
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -2));
								pop++;
							}
							// TODO: table


							// then the value
							if(Lua.isnumber(luaInstance.lua,-1)){
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
								pop++;
							}else if(Lua.isstring(luaInstance.lua,-1)){
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
								pop++;
							}else if(Lua.isboolean(luaInstance.lua,-1)){
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
								pop++;
							}
							// TODO: table

							if(pop==2)Lua.rawset(lua, tableIdx); // then set it
							Lua.pop(luaInstance.lua, 1); // for the loop
						}
						Lua.pop(luaInstance.lua,1); // end the loop entirely
						Lua.pushvalue(lua, tableIdx); // push the table onto the stack so it gets returned

						return;
					}

				}
			}
		});*/
		Lua_helper.add_callback(lua, "isRunning", function(luaFile:String) {
			var foundScript:String = findScript(luaFile);
			if(foundScript != null)
				for (luaInstance in game.luaArray)
					if(luaInstance.scriptName == foundScript)
						return true;
			return false;
		});

		Lua_helper.add_callback(lua, "setVar", function(varName:String, value:Dynamic) {
			MusicBeatState.getVariables().set(varName, value);
			return value;
		});
		Lua_helper.add_callback(lua, "getVar", function(varName:String) {
			return MusicBeatState.getVariables().get(varName);
		});

		Lua_helper.add_callback(lua, "addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf.
			var foundScript:String = findScript(luaFile);
			if(foundScript != null)
			{
				if(!ignoreAlreadyRunning)
					for (luaInstance in game.luaArray)
						if(luaInstance.scriptName == foundScript)
						{
							luaTrace('addLuaScript: The script "' + foundScript + '" is already running!');
							return;
						}

				new FunkinLua(foundScript);
				return;
			}
			luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addHScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) {
			#if HSCRIPT_ALLOWED
			var foundScript:String = findScript(luaFile, '.hx');
			if(foundScript != null)
			{
				if(!ignoreAlreadyRunning)
					for (script in game.hscriptArray)
						if(script.origin == foundScript)
						{
							luaTrace('addHScript: The script "' + foundScript + '" is already running!');
							return;
						}

				PlayState.instance.initHScript(foundScript);
				return;
			}
			luaTrace("addHScript: Script doesn't exist!", false, false, FlxColor.RED);
			#else
			luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});
		Lua_helper.add_callback(lua, "removeLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) {
			var foundScript:String = findScript(luaFile);
			if(foundScript != null)
			{
				if(!ignoreAlreadyRunning)
					for (luaInstance in game.luaArray)
						if(luaInstance.scriptName == foundScript)
						{
							luaInstance.stop();
							trace('Closing script ' + luaInstance.scriptName);
							return true;
						}
			}
			luaTrace('removeLuaScript: Script $luaFile isn\'t running!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "removeHScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) {
			#if HSCRIPT_ALLOWED
			var foundScript:String = findScript(luaFile, '.hx');
			if(foundScript != null)
			{
				if(!ignoreAlreadyRunning)
					for (script in game.hscriptArray)	
						if(script.origin == foundScript)
						{
							trace('Closing script ' + (script.origin != null ? script.origin : luaFile));
							script.destroy();
							return true;
						}
			}
			luaTrace('removeHScript: Script $luaFile isn\'t running!', false, false, FlxColor.RED);
			return false;
			#else
			luaTrace("removeHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "loadSong", function(?name:String = null, ?difficultyNum:Int = -1) {
			if(name == null || name.length < 1)
				name = Song.loadedSongName;
			if (difficultyNum == -1)
				difficultyNum = PlayState.storyDifficulty;

			var poop = Highscore.formatSong(name, difficultyNum);
			Song.loadFromJson(poop, name);
			PlayState.storyDifficulty = difficultyNum;
			FlxG.state.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if(game != null && game.vocals != null)
			{
				game.vocals.pause();
				game.vocals.volume = 0;
			}
			FlxG.camera.followLerp = 0;
		});

		Lua_helper.add_callback(lua, "loadGraphic", function(variable:String, image:String, ?gridX:Int = 0, ?gridY:Int = 0) {
			var split:Array<String> = variable.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			var animated = gridX != 0 || gridY != 0;

			if(split.length > 1) {
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				spr.loadGraphic(Paths.image(image), animated, gridX, gridY);
			}
		});
		Lua_helper.add_callback(lua, "loadFrames", function(variable:String, image:String, spriteType:String = "sparrow") {
			var split:Array<String> = variable.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				LuaUtils.loadFrames(spr, image, spriteType);
			}
		});

		//shitass stuff for epic coders like me B)  *image of obama giving himself a medal*
		Lua_helper.add_callback(lua, "getObjectOrder", function(obj:String) {
			var split:Array<String> = obj.split('.');
			var leObj:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(leObj != null)
			{
				return LuaUtils.getTargetInstance().members.indexOf(leObj);
			}
			luaTrace("getObjectOrder: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return -1;
		});
		Lua_helper.add_callback(lua, "setObjectOrder", function(obj:String, position:Int) {
			var split:Array<String> = obj.split('.');
			var leObj:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(leObj != null) {
				LuaUtils.getTargetInstance().remove(leObj, true);
				LuaUtils.getTargetInstance().insert(position, leObj);
				return;
			}
			luaTrace("setObjectOrder: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});

		// gay ass tweens
		Lua_helper.add_callback(lua, "startTween", function(tag:String, vars:String, values:Any = null, duration:Float, options:Any = null) {
			var penisExam:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if(penisExam != null)
			{
				if(values != null)
				{
					var myOptions:LuaTweenOptions = LuaUtils.getLuaTween(options);
					if(tag != null)
					{
						var variables = MusicBeatState.getVariables();
						tag = 'tween_' + LuaUtils.formatVariable(tag);
						variables.set(tag, FlxTween.tween(penisExam, values, duration, {
							type: myOptions.type,
							ease: myOptions.ease,
							startDelay: myOptions.startDelay,
							loopDelay: myOptions.loopDelay,
	
							onUpdate: function(twn:FlxTween) {
								if(myOptions.onUpdate != null) game.callOnLuas(myOptions.onUpdate, [tag, vars]);
							},
							onStart: function(twn:FlxTween) {
								if(myOptions.onStart != null) game.callOnLuas(myOptions.onStart, [tag, vars]);
							},
							onComplete: function(twn:FlxTween) {
								if(twn.type == FlxTweenType.ONESHOT || twn.type == FlxTweenType.BACKWARD) variables.remove(tag);
								if(myOptions.onComplete != null) game.callOnLuas(myOptions.onComplete, [tag, vars]);
							}
						}));
					}
					else FlxTween.tween(penisExam, values, duration, {type: myOptions.type, ease: myOptions.ease, startDelay: myOptions.startDelay, loopDelay: myOptions.loopDelay});
				}
				else luaTrace('startTween: No values on 2nd argument!', false, false, FlxColor.RED);
			}
			else luaTrace('startTween: Couldnt find object: ' + vars, false, false, FlxColor.RED);
		});

		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			oldTweenFunction(tag, vars, {x: value}, duration, ease, 'doTweenX');
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			oldTweenFunction(tag, vars, {y: value}, duration, ease, 'doTweenY');
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			oldTweenFunction(tag, vars, {angle: value}, duration, ease, 'doTweenAngle');
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			oldTweenFunction(tag, vars, {alpha: value}, duration, ease, 'doTweenAlpha');
		});
		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			oldTweenFunction(tag, vars, {zoom: value}, duration, ease, 'doTweenZoom');
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String) {
			var penisExam:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if(penisExam != null) {
				var curColor:FlxColor = penisExam.color;
				curColor.alphaFloat = penisExam.alpha;
				
				if(tag != null)
				{
					var originalTag:String = tag;
					tag = LuaUtils.formatVariable('tween_$tag');
					var variables = MusicBeatState.getVariables();
					variables.set(tag, FlxTween.color(penisExam, duration, curColor, CoolUtil.colorFromString(targetColor), {ease: LuaUtils.getTweenEaseByString(ease),
						onComplete: function(twn:FlxTween)
						{
							variables.remove(tag);
							if (game != null) game.callOnLuas('onTweenCompleted', [originalTag, vars]);
						}
					}));
				}
				else FlxTween.color(penisExam, duration, curColor, CoolUtil.colorFromString(targetColor), {ease: LuaUtils.getTweenEaseByString(ease)});
			}
			else luaTrace('doTweenColor: Couldnt find object: ' + vars, false, false, FlxColor.RED);
		});

		//Tween shit, but for strums
		Lua_helper.add_callback(lua, "noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			noteTweenFunction(tag, note, {x: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			noteTweenFunction(tag, note, {y: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			noteTweenFunction(tag, note, {angle: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			noteTweenFunction(tag, note, {alpha: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			noteTweenFunction(tag, note, {direction: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "mouseClicked", function(button:String) {
			var click:Bool = FlxG.mouse.justPressed;
			switch(button.trim().toLowerCase())
			{
				case 'middle':
					click = FlxG.mouse.justPressedMiddle;
				case 'right':
					click = FlxG.mouse.justPressedRight;
			}
			return click;
		});
		Lua_helper.add_callback(lua, "mousePressed", function(button:String) {
			var press:Bool = FlxG.mouse.pressed;
			switch(button.trim().toLowerCase())
			{
				case 'middle':
					press = FlxG.mouse.pressedMiddle;
				case 'right':
					press = FlxG.mouse.pressedRight;
			}
			return press;
		});
		Lua_helper.add_callback(lua, "mouseReleased", function(button:String) {
			var released:Bool = FlxG.mouse.justReleased;
			switch(button.trim().toLowerCase())
			{
				case 'middle':
					released = FlxG.mouse.justReleasedMiddle;
				case 'right':
					released = FlxG.mouse.justReleasedRight;
			}
			return released;
		});

		Lua_helper.add_callback(lua, "cancelTween", function(tag:String) LuaUtils.cancelTween(tag));

		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
			LuaUtils.cancelTimer(tag);
			var variables = MusicBeatState.getVariables();
			
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('timer_$tag');
			variables.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer)
			{
				if(tmr.finished) variables.remove(tag);
				game.callOnLuas('onTimerCompleted', [originalTag, tmr.loops, tmr.loopsLeft]);
				//trace('Timer Completed: ' + tag);
			}, loops));
		});
		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String) LuaUtils.cancelTimer(tag));

		//stupid bietch ass functions
		Lua_helper.add_callback(lua, "addScore", function(value:Int = 0) {
			game.songScore += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addMisses", function(value:Int = 0) {
			game.songMisses += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addHits", function(value:Int = 0) {
			game.songHits += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setScore", function(value:Int = 0) {
			game.songScore = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setMisses", function(value:Int = 0) {
			game.songMisses = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setHits", function(value:Int = 0) {
			game.songHits = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "getScore", function() return game.songScore);
		Lua_helper.add_callback(lua, "getMisses", function() return game.songMisses);
		Lua_helper.add_callback(lua, "getHits", function() return game.songHits);

		Lua_helper.add_callback(lua, "setHealth", function(value:Float = 1) game.health = value);
		Lua_helper.add_callback(lua, "addHealth", function(value:Float = 0) game.health += value);
		Lua_helper.add_callback(lua, "getHealth", function() return game.health);

		//Identical functions
		Lua_helper.add_callback(lua, "FlxColor", function(color:String) return FlxColor.fromString(color));
		Lua_helper.add_callback(lua, "getColorFromName", function(color:String) return FlxColor.fromString(color));
		Lua_helper.add_callback(lua, "getColorFromString", function(color:String) return FlxColor.fromString(color));
		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String) return FlxColor.fromString('#$color'));

		// precaching
		Lua_helper.add_callback(lua, "addCharacterToList", function(name:String, type:String) {
			var charType:Int = 0;
			switch(type.toLowerCase()) {
				case 'dad': charType = 1;
				case 'gf' | 'girlfriend': charType = 2;
			}
			game.addCharacterToList(name, charType);
		});
		Lua_helper.add_callback(lua, "precacheImage", function(name:String, ?allowGPU:Bool = true) {
			Paths.image(name, allowGPU);
		});
		Lua_helper.add_callback(lua, "precacheSound", function(name:String) {
			Paths.sound(name);
		});
		Lua_helper.add_callback(lua, "precacheMusic", function(name:String) {
			Paths.music(name);
		});

		// others
		Lua_helper.add_callback(lua, "triggerEvent", function(name:String, arg1:Dynamic, arg2:Dynamic) {
			var value1:String = arg1;
			var value2:String = arg2;
			game.triggerEvent(name, value1, value2, Conductor.songPosition);
			//trace('Triggered event: ' + name + ', ' + value1 + ', ' + value2);
			return true;
		});

		Lua_helper.add_callback(lua, "startCountdown", function() {
			game.startCountdown();
			return true;
		});
		Lua_helper.add_callback(lua, "endSong", function() {
			game.KillNotes();
			game.endSong();
			return true;
		});
		Lua_helper.add_callback(lua, "restartSong", function(?skipTransition:Bool = false) {
			game.persistentUpdate = false;
			FlxG.camera.followLerp = 0;
			PauseSubState.restartSong(skipTransition);
			return true;
		});
		Lua_helper.add_callback(lua, "exitSong", function(?skipTransition:Bool = false) {
			if(skipTransition)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			if(PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			game.transitioning = true;
			FlxG.camera.followLerp = 0;
			Mods.loadTopMod();
			return true;
		});
		Lua_helper.add_callback(lua, "getSongPosition", function() {
			return Conductor.songPosition;
		});

		Lua_helper.add_callback(lua, "getCharacterX", function(type:String) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					return game.dadGroup.x;
				case 'gf' | 'girlfriend':
					return game.gfGroup.x;
				default:
					return game.boyfriendGroup.x;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterX", function(type:String, value:Float) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					game.dadGroup.x = value;
				case 'gf' | 'girlfriend':
					game.gfGroup.x = value;
				default:
					game.boyfriendGroup.x = value;
			}
		});
		Lua_helper.add_callback(lua, "getCharacterY", function(type:String) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					return game.dadGroup.y;
				case 'gf' | 'girlfriend':
					return game.gfGroup.y;
				default:
					return game.boyfriendGroup.y;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterY", function(type:String, value:Float) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					game.dadGroup.y = value;
				case 'gf' | 'girlfriend':
					game.gfGroup.y = value;
				default:
					game.boyfriendGroup.y = value;
			}
		});
		Lua_helper.add_callback(lua, "cameraSetTarget", function(target:String) {
			var isDad:Bool = false;
			if(target == 'dad') {
				isDad = true;
			}
			game.moveCamera(isDad);
			return isDad;
		});
		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, intensity:Float, duration:Float) {
			LuaUtils.cameraFromString(camera).shake(intensity, duration);
		});

		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, color:String, duration:Float,forced:Bool) {
			LuaUtils.cameraFromString(camera).flash(CoolUtil.colorFromString(color), duration, null,forced);
		});
		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, color:String, duration:Float,forced:Bool) {
			LuaUtils.cameraFromString(camera).fade(CoolUtil.colorFromString(color), duration, false,null,forced);
		});
		Lua_helper.add_callback(lua, "setRatingPercent", function(value:Float) {
			game.ratingPercent = value;
		});
		Lua_helper.add_callback(lua, "setRatingName", function(value:String) {
			game.ratingName = value;
		});
		Lua_helper.add_callback(lua, "setRatingFC", function(value:String) {
			game.ratingFC = value;
		});
		Lua_helper.add_callback(lua, "getMouseX", function(camera:String = 'game') {
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).x;
		});
		Lua_helper.add_callback(lua, "getMouseY", function(camera:String = 'game') {
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).y;
		});

		Lua_helper.add_callback(lua, "getMidpointX", function(variable:String) {
			var split:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}
			if(obj != null) return obj.getMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getMidpointY", function(variable:String) {
			var split:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}
			if(obj != null) return obj.getMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointX", function(variable:String) {
			var split:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointY", function(variable:String) {
			var split:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionX", function(variable:String, ?camera:String = 'game') {
			var split:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionY", function(variable:String, ?camera:String = 'game') {
			var split:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "characterDance", function(character:String) {
			switch(character.toLowerCase()) {
				case 'dad': game.dad.dance();
				case 'gf' | 'girlfriend': if(game.gf != null) game.gf.dance();
				default: game.boyfriend.dance();
			}
		});

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0) {
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);
			if(image != null && image.length > 0)
			{
				leSprite.loadGraphic(Paths.image(image));
			}
			MusicBeatState.getVariables().set(tag, leSprite);
			leSprite.active = true;
		});
		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?spriteType:String = "sparrow") {
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);

			LuaUtils.loadFrames(leSprite, image, spriteType);
			MusicBeatState.getVariables().set(tag, leSprite);
		});

		Lua_helper.add_callback(lua, "makeGraphic", function(obj:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF') {
			var spr:FlxSprite = LuaUtils.getObjectDirectly(obj);
			if(spr != null) spr.makeGraphic(width, height, CoolUtil.colorFromString(color));
		});
		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			var obj:FlxSprite = cast LuaUtils.getObjectDirectly(obj);
			if(obj != null && obj.animation != null)
			{
				obj.animation.addByPrefix(name, prefix, framerate, loop);
				if(obj.animation.curAnim == null)
				{
					var dyn:Dynamic = cast obj;
					if(dyn.playAnim != null) dyn.playAnim(name, true);
					else dyn.animation.play(name, true);
				}
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true) {
			var obj:FlxSprite = LuaUtils.getObjectDirectly(obj);
			if(obj != null && obj.animation != null)
			{
				obj.animation.add(name, frames, framerate, loop);
				if(obj.animation.curAnim == null)
				{
					var dyn:Dynamic = cast obj;
					if(dyn.playAnim != null) dyn.playAnim(name, true);
					else dyn.animation.play(name, true);
				}
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:Any, framerate:Int = 24, loop:Bool = false) {
			return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, loop);
		});

		Lua_helper.add_callback(lua, "playAnim", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0)
		{
			var obj:Dynamic = LuaUtils.getObjectDirectly(obj);
			if(obj.playAnim != null)
			{
				obj.playAnim(name, forced, reverse, startFrame);
				return true;
			}
			else
			{
				if(obj.anim != null) obj.anim.play(name, forced, reverse, startFrame); //FlxAnimate
				else obj.animation.play(name, forced, reverse, startFrame);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "addOffset", function(obj:String, anim:String, x:Float, y:Float) {
			var obj:Dynamic = LuaUtils.getObjectDirectly(obj);
			if(obj != null && obj.addOffset != null)
			{
				obj.addOffset(anim, x, y);
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
			if(game.getLuaObject(obj,false)!=null) {
				game.getLuaObject(obj,false).scrollFactor.set(scrollX, scrollY);
				return;
			}

			var object:FlxObject = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
			if(object != null) {
				object.scrollFactor.set(scrollX, scrollY);
			}
		});
		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String, front:Bool = false) {
			var mySprite:FlxSprite = MusicBeatState.getVariables().get(tag);
			if(mySprite == null) return false;

			var instance = LuaUtils.getTargetInstance();
			if(front)
				instance.add(mySprite);
			else
			{
				if(PlayState.instance == null || !PlayState.instance.isDead)
					instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), mySprite);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySprite);
			}
			return true;
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(obj:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			if(game.getLuaObject(obj)!=null) {
				var shit:FlxSprite = game.getLuaObject(obj);
				shit.setGraphicSize(x, y);
				if(updateHitbox) shit.updateHitbox();
				return;
			}

			var split:Array<String> = obj.split('.');
			var poop:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(poop != null) {
				poop.setGraphicSize(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			luaTrace('setGraphicSize: Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
			if(game.getLuaObject(obj)!=null) {
				var shit:FlxSprite = game.getLuaObject(obj);
				shit.scale.set(x, y);
				if(updateHitbox) shit.updateHitbox();
				return;
			}

			var split:Array<String> = obj.split('.');
			var poop:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(poop != null) {
				poop.scale.set(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			luaTrace('scaleObject: Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "updateHitbox", function(obj:String) {
			if(game.getLuaObject(obj)!=null) {
				var shit:FlxSprite = game.getLuaObject(obj);
				shit.updateHitbox();
				return;
			}

			var poop:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
			if(poop != null) {
				poop.updateHitbox();
				return;
			}
			luaTrace('updateHitbox: Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "updateHitboxFromGroup", function(group:String, index:Int) {
			if(Std.isOfType(Reflect.getProperty(LuaUtils.getTargetInstance(), group), FlxTypedGroup)) {
				Reflect.getProperty(LuaUtils.getTargetInstance(), group).members[index].updateHitbox();
				return;
			}
			Reflect.getProperty(LuaUtils.getTargetInstance(), group)[index].updateHitbox();
		});

		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String, destroy:Bool = true, ?group:String = null) {
			var obj:FlxSprite = LuaUtils.getObjectDirectly(tag);
			if(obj == null || obj.destroy == null)
				return;
			
			var groupObj:Dynamic = null;
			if(group == null) groupObj = LuaUtils.getTargetInstance();
			else groupObj = LuaUtils.getObjectDirectly(group);

			groupObj.remove(obj, true);
			if(destroy)
			{
				MusicBeatState.getVariables().remove(tag);
				obj.destroy();
			}
		});

		Lua_helper.add_callback(lua, "luaSpriteExists", function(tag:String) {
			var obj:FlxSprite = MusicBeatState.getVariables().get(tag);
			return (obj != null && Std.isOfType(obj, FlxSprite));
		});
		Lua_helper.add_callback(lua, "luaTextExists", function(tag:String) {
			var obj:FlxSprite = MusicBeatState.getVariables().get(tag);
			return (obj != null && Std.isOfType(obj, FlxText));
		});
		Lua_helper.add_callback(lua, "luaSoundExists", function(tag:String) {
			var obj:FlxSprite = MusicBeatState.getVariables().get(tag);
			return (obj != null && Std.isOfType(obj, FlxSound));
		});

		Lua_helper.add_callback(lua, "setHealthBarColors", function(left:String, right:String) {
			var left_color:Null<FlxColor> = null;
			var right_color:Null<FlxColor> = null;
			if (left != null && left != '')
				left_color = CoolUtil.colorFromString(left);
			if (right != null && right != '')
				right_color = CoolUtil.colorFromString(right);
			game.healthBar.setColors(left_color, right_color);
		});
		Lua_helper.add_callback(lua, "setTimeBarColors", function(left:String, right:String) {
			var left_color:Null<FlxColor> = null;
			var right_color:Null<FlxColor> = null;
			if (left != null && left != '')
				left_color = CoolUtil.colorFromString(left);
			if (right != null && right != '')
				right_color = CoolUtil.colorFromString(right);
			game.timeBar.setColors(left_color, right_color);
		});

		Lua_helper.add_callback(lua, "setObjectCamera", function(obj:String, camera:String = 'game') {
			var real = game.getLuaObject(obj);
			if(real!=null){
				real.cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}

			var split:Array<String> = obj.split('.');
			var object:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(object != null) {
				object.cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}
			luaTrace("setObjectCamera: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setBlendMode", function(obj:String, blend:String = '') {
			var real = game.getLuaObject(obj);
			if(real != null) {
				real.blend = LuaUtils.blendModeFromString(blend);
				return true;
			}

			var split:Array<String> = obj.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(spr != null) {
				spr.blend = LuaUtils.blendModeFromString(blend);
				return true;
			}
			luaTrace("setBlendMode: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "screenCenter", function(obj:String, pos:String = 'xy') {
			var spr:FlxSprite = game.getLuaObject(obj);

			if(spr==null){
				var split:Array<String> = obj.split('.');
				spr = LuaUtils.getObjectDirectly(split[0]);
				if(split.length > 1) {
					spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
				}
			}

			if(spr != null)
			{
				switch(pos.trim().toLowerCase())
				{
					case 'x':
						spr.screenCenter(X);
						return;
					case 'y':
						spr.screenCenter(Y);
						return;
					default:
						spr.screenCenter(XY);
						return;
				}
			}
			luaTrace("screenCenter: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "objectsOverlap", function(obj1:String, obj2:String) {
			var namesArray:Array<String> = [obj1, obj2];
			var objectsArray:Array<FlxSprite> = [];
			for (i in 0...namesArray.length)
			{
				var real = game.getLuaObject(namesArray[i]);
				if(real!=null) {
					objectsArray.push(real);
				} else {
					objectsArray.push(Reflect.getProperty(LuaUtils.getTargetInstance(), namesArray[i]));
				}
			}

			if(!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
			{
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPixelColor", function(obj:String, x:Int, y:Int) {
			var split:Array<String> = obj.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(spr != null) return spr.pixels.getPixel32(x, y);
			return FlxColor.BLACK;
		});
		Lua_helper.add_callback(lua, "startDialogue", function(dialogueFile:String, music:String = null) {
			var path:String;
			var songPath:String = Paths.formatToSongPath(Song.loadedSongName);
			#if TRANSLATIONS_ALLOWED
			path = Paths.getPath('data/$songPath/${dialogueFile}_${ClientPrefs.data.language}.json', TEXT);
			#if MODS_ALLOWED
			if(!FileSystem.exists(path))
			#else
			if(!Assets.exists(path, TEXT))
			#end
			#end
				path = Paths.getPath('data/$songPath/$dialogueFile.json', TEXT);

			luaTrace('startDialogue: Trying to load dialogue: ' + path);

			#if MODS_ALLOWED
			if(FileSystem.exists(path))
			#else
			if(Assets.exists(path, TEXT))
			#end
			{
				var shit:DialogueFile = DialogueBoxPsych.parseDialogue(path);
				if(shit.dialogue.length > 0)
				{
					game.startDialogue(shit, music);
					luaTrace('startDialogue: Successfully loaded dialogue', false, false, FlxColor.GREEN);
					return true;
				}
				else luaTrace('startDialogue: Your dialogue file is badly formatted!', false, false, FlxColor.RED);
			}
			else
			{
				luaTrace('startDialogue: Dialogue file not found', false, false, FlxColor.RED);
				if(game.endingSong)
					game.endSong();
				else
					game.startCountdown();
			}
			return false;
		});
		Lua_helper.add_callback(lua, "startVideo", function(videoFile:String, ?canSkip:Bool = true) {
			#if VIDEOS_ALLOWED
			if(FileSystem.exists(Paths.video(videoFile)))
			{
				if(game.videoCutscene != null)
				{
					game.remove(game.videoCutscene);
					game.videoCutscene.destroy();
				}
				game.videoCutscene = game.startVideo(videoFile, false, canSkip);
				return true;
			}
			else
			{
				luaTrace('startVideo: Video file not found: ' + videoFile, false, false, FlxColor.RED);
			}
			return false;

			#else
			PlayState.instance.inCutscene = true;
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				PlayState.instance.inCutscene = false;
				if(game.endingSong)
					game.endSong();
				else
					game.startCountdown();
			});
			return true;
			#end
		});

		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});
		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String = null, ?loop:Bool = false) {
			if(tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('sound_$tag');
				var variables = MusicBeatState.getVariables();
				var oldSnd = variables.get(tag);
				if(oldSnd != null)
				{
					oldSnd.stop();
					oldSnd.destroy();
				}

				variables.set(tag, FlxG.sound.play(Paths.sound(sound), volume, loop, null, true, function()
				{
					if(!loop) variables.remove(tag);
					if(game != null) game.callOnLuas('onSoundFinished', [originalTag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
		});
		Lua_helper.add_callback(lua, "stopSound", function(tag:String) {
			if(tag == null || tag.length < 1)
				if(FlxG.sound.music != null) FlxG.sound.music.stop();
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var variables = MusicBeatState.getVariables();
				var snd:FlxSound = variables.get(tag);
				if(snd != null)
				{
					snd.stop();
					variables.remove(tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "pauseSound", function(tag:String) {
			if(tag == null || tag.length < 1)
				if(FlxG.sound.music != null) FlxG.sound.music.pause();
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null) snd.pause();
			}
		});
		Lua_helper.add_callback(lua, "resumeSound", function(tag:String) {
			if(tag == null || tag.length < 1)
				if(FlxG.sound.music != null) FlxG.sound.music.play();
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null) snd.play();
			}
		});
		Lua_helper.add_callback(lua, "soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			if(tag == null || tag.length < 1)
			{
				if(FlxG.sound.music != null)
					FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			}
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null)
					snd.fadeIn(duration, fromValue, toValue);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0) {
			if(tag == null || tag.length < 1)
			{
				if(FlxG.sound.music != null)
					FlxG.sound.music.fadeOut(duration, toValue);
			}
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null)
					snd.fadeOut(duration, toValue);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeCancel", function(tag:String) {
			if(tag == null || tag.length < 1)
			{
				if(FlxG.sound.music != null && FlxG.sound.music.fadeTween != null)
					FlxG.sound.music.fadeTween.cancel();
			}
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null && snd.fadeTween != null)
					snd.fadeTween.cancel();
			}
		});
		Lua_helper.add_callback(lua, "getSoundVolume", function(tag:String) {
			if(tag == null || tag.length < 1)
			{
				if(FlxG.sound.music != null)
					return FlxG.sound.music.volume;
			}
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null) return snd.volume;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundVolume", function(tag:String, value:Float) {
			if(tag == null || tag.length < 1)
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				if(FlxG.sound.music != null)
				{
					FlxG.sound.music.volume = value;
					return;
				}
			}
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null) snd.volume = value;
			}
		});
		Lua_helper.add_callback(lua, "getSoundTime", function(tag:String) {
			if(tag == null || tag.length < 1)
			{
				return FlxG.sound.music != null ? FlxG.sound.music.time : 0;
			}
			tag = LuaUtils.formatVariable('sound_$tag');
			var snd:FlxSound = MusicBeatState.getVariables().get(tag);
			return snd != null ? snd.time : 0;
		});
		Lua_helper.add_callback(lua, "setSoundTime", function(tag:String, value:Float) {
			if(tag == null || tag.length < 1)
			{
				if(FlxG.sound.music != null)
				{
					FlxG.sound.music.time = value;
					return;
				}
			}
			else
			{
				tag = LuaUtils.formatVariable('sound_$tag');
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null) snd.time = value;
			}
		});
		#if FLX_PITCH
		Lua_helper.add_callback(lua, "getSoundPitch", function(tag:String) {
			tag = LuaUtils.formatVariable('sound_$tag');
			var snd:FlxSound = MusicBeatState.getVariables().get(tag);
			return snd != null ? snd.pitch : 0;
		});
		Lua_helper.add_callback(lua, "setSoundPitch", function(tag:String, value:Float, doPause:Bool = false) {
			tag = LuaUtils.formatVariable('sound_$tag');
			var snd:FlxSound = MusicBeatState.getVariables().get(tag);
			if(snd != null)
			{
				var wasResumed:Bool = snd.playing;
				if (doPause) snd.pause();
				snd.pitch = value;
				if (doPause && wasResumed) snd.play();
			}
			
			if(tag == null || tag.length < 1)
			{
				if(FlxG.sound.music != null)
				{
					var wasResumed:Bool = FlxG.sound.music.playing;
					if (doPause) FlxG.sound.music.pause();
					FlxG.sound.music.pitch = value;
					if (doPause && wasResumed) FlxG.sound.music.play();
					return;
				}
			}
			else
			{
				var snd:FlxSound = MusicBeatState.getVariables().get(tag);
				if(snd != null)
				{
					var wasResumed:Bool = snd.playing;
					if (doPause) snd.pause();
					snd.pitch = value;
					if (doPause && wasResumed) snd.play();
				}
			}
		});
		#end

		// mod settings
		#if MODS_ALLOWED
		addLocalCallback("getModSetting", function(saveTag:String, ?modName:String = null) {
			if(modName == null)
			{
				if(this.modFolder == null)
				{
					FunkinLua.luaTrace('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', false, false, FlxColor.RED);
					return null;
				}
				modName = this.modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		});
		#end
		//

		Lua_helper.add_callback(lua, "debugPrint", function(text:Dynamic = '', color:String = 'WHITE') PlayState.instance.addTextToDebug(text, CoolUtil.colorFromString(color)));

		addLocalCallback("close", function() {
			closed = true;
			trace('Closing script $scriptName');
			return closed;
		});

		#if DISCORD_ALLOWED DiscordClient.addLuaCallbacks(lua); #end
		#if ACHIEVEMENTS_ALLOWED Achievements.addLuaCallbacks(lua); #end
		#if TRANSLATIONS_ALLOWED Language.addLuaCallbacks(lua); #end
		#if HSCRIPT_ALLOWED HScript.implement(this); #end
		#if flxanimate FlxAnimateFunctions.implement(this); #end
		ReflectionFunctions.implement(this);
		TextFunctions.implement(this);
		ExtraFunctions.implement(this);
		CustomSubstate.implement(this);
		ShaderFunctions.implement(this);
		DeprecatedFunctions.implement(this);

		for (name => func in customFunctions)
		{
			if(func != null)
				Lua_helper.add_callback(lua, name, func);
		}

		try{
			var isString:Bool = !FileSystem.exists(scriptName);
			var result:Dynamic = null;
			if(!isString)
				result = LuaL.dofile(lua, scriptName);
			else
				result = LuaL.dostring(lua, scriptName);

			var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				trace(resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				luaTrace('$scriptName\n$resultStr', true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
			if(isString) scriptName = 'unknown';
		} catch(e:Dynamic) {
			trace(e);
			return;
		}
		trace('lua file loaded succesfully:' + scriptName);

		call('onCreate', []);
	}

	//main
	public var lastCalledFunction:String = '';
	public static var lastCalledScript:FunkinLua = null;
	public function call(func:String, args:Array<Dynamic>):Dynamic {
		if(closed) return LuaUtils.Function_Continue;

		lastCalledFunction = func;
		lastCalledScript = this;
		try {
			if(lua == null) return LuaUtils.Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.LUA_TFUNCTION) {
				if (type > Lua.LUA_TNIL)
					luaTrace("ERROR (" + func + "): attempt to call a " + LuaUtils.typeToString(type) + " value", false, false, FlxColor.RED);

				Lua.pop(lua, 1);
				return LuaUtils.Function_Continue;
			}

			for (arg in args) Convert.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.LUA_OK) {
				var error:String = getErrorMessage(status);
				luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
				return LuaUtils.Function_Continue;
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast Convert.fromLua(lua, -1);
			if (result == null) result = LuaUtils.Function_Continue;

			Lua.pop(lua, 1);
			if(closed) stop();
			return result;
		}
		catch (e:Dynamic) {
			trace(e);
		}
		return LuaUtils.Function_Continue;
	}

	public function set(variable:String, data:Dynamic) {
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function stop() {
		closed = true;

		if(lua == null) {
			return;
		}
		Lua.close(lua);
		lua = null;
		#if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			hscript.destroy();
			hscript = null;
		}
		#end
	}

	function oldTweenFunction(tag:String, vars:String, tweenValue:Any, duration:Float, ease:String, funcName:String)
	{
		var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
		var variables = MusicBeatState.getVariables();
		if(target != null)
		{
			if(tag != null)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');
				variables.set(tag, FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						variables.remove(tag);
						if(PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
		}
		else luaTrace('$funcName: Couldnt find object: $vars', false, false, FlxColor.RED);
	}

	function noteTweenFunction(tag:String, note:Int, data:Dynamic, duration:Float, ease:String)
	{
		if(PlayState.instance == null) return;

		var strumNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
		if(strumNote == null) return;

		if(tag != null)
		{
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');
			LuaUtils.cancelTween(tag);

			var variables = MusicBeatState.getVariables();
			variables.set(tag, FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(twn:FlxTween)
				{
					variables.remove(tag);
					if(PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag]);
				}
			}));
		}
		else FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
	}

	public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE) {
		if(ignoreCheck || getBool('luaDebugMode')) {
			if(deprecated && !getBool('luaDeprecatedWarnings')) {
				return;
			}
			PlayState.instance.addTextToDebug(text, color);
		}
	}

	public static function getBool(variable:String) {
		if(lastCalledScript == null) return false;

		var lua:State = lastCalledScript.lua;
		if(lua == null) return false;

		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if(result == null) {
			return false;
		}
		return (result == 'true');
	}

	function findScript(scriptFile:String, ext:String = '.lua')
	{
		if(!scriptFile.endsWith(ext)) scriptFile += ext;
		var preloadPath:String = Paths.getSharedPath(scriptFile);
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(scriptFile))
			return scriptFile;
		else if(FileSystem.exists(path))
			return path;

		if(FileSystem.exists(preloadPath))
		#else
		if(Assets.exists(preloadPath))
		#end
		{
			return preloadPath;
		}
		return null;
	}

	public function getErrorMessage(status:Int):String {
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null) v = v.trim();
		if (v == null || v == "") {
			switch(status) {
				case Lua.LUA_ERRRUN: return "Runtime Error";
				case Lua.LUA_ERRMEM: return "Memory Allocation Error";
				case Lua.LUA_ERRERR: return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		return null;
	}

	public function addLocalCallback(name:String, myFunction:Dynamic)
	{
		callbacks.set(name, myFunction);
		Lua_helper.add_callback(lua, name, null); //just so that it gets called
	}

	#if (MODS_ALLOWED && !flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	#end

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			var shaderData:Array<String> = runtimeShaders.get(name);
			if(shaderData != null && (shaderData[0] != null || shaderData[1] != null))
			{
				luaTrace('Shader $name was already initialized!');
				return true;
			}
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/shaders/'));

		for(mod in Mods.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if(FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
		#else
		luaTrace('This platform doesn\'t support Runtime Shaders!', false, false, FlxColor.RED);
		#end
		return false;
	}
}
#end