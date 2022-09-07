package;

import haxe.Constraints.Function;
#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxAssets.FlxShader;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import Type.ValueType;
import Controls;
import DialogueBoxPsych;

#if hscript
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
#end

#if desktop
import Discord;
#end

using StringTools;

class FunkinLua {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;
	public static var Function_StopLua:Dynamic = 2;

	//public var errorHandler:String->Void;
	#if LUA_ALLOWED
	public var lua:State = null;
	#end
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var closed:Bool = false;

	#if hscript
	public var hscript:HScript;
	public static var hscriptVars:Map<String, Dynamic> = new Map();
	#end
	
	public function new(script:String) 
	{
		#if LUA_ALLOWED
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		//LuaL.dostring(lua, CLENSE);
		try{
			var result:Dynamic = LuaL.dofile(lua, script);
			var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				trace('Error on lua script! ' + resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				luaTrace('Error loading lua script: "$script"\n' + resultStr, true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
		} catch(e:Dynamic) {
			trace(e);
			return;
		}
		scriptName = script;
		initHaxeModule();

		trace('lua file loaded succesfully:' + script);

		// Lua shit
		set('Function_StopLua', Function_StopLua);
		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('inChartEditor', false);

		// Song/Week shit
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('songPath', Paths.formatToSongPath(PlayState.SONG.song));
		set('startedCountdown', false);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);

		var difficultyName:String = CoolUtil.difficulties[PlayState.storyDifficulty];
		set('difficultyName', difficultyName);
		set('difficultyPath', Paths.formatToSongPath(difficultyName));
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);

		// Camera poo
		set('cameraX', 0);
		set('cameraY', 0);

		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);

		// PlayState cringe ass nae nae bullcrap
		set('curBeat', 0);
		set('curStep', 0);
		set('curDecBeat', 0);
		set('curDecStep', 0);

		set('score', 0);
		set('misses', 0);
		set('hits', 0);

		set('rating', 0);
		set('ratingName', '');
		set('ratingFC', '');
		set('version', MainMenuState.psychEngineVersion.trim());

		set('inGameOver', false);
		set('mustHitSection', false);
		set('altAnim', false);
		set('gfSection', false);

		// Gameplay settings
		set('healthGainMult', PlayState.instance.healthGain);
		set('healthLossMult', PlayState.instance.healthLoss);
		set('instakillOnMiss', PlayState.instance.instakillOnMiss);
		set('botPlay', PlayState.instance.cpuControlled);
		set('practice', PlayState.instance.practiceMode);

		for (i in 0...4) {
			set('defaultPlayerStrumX' + i, 0);
			set('defaultPlayerStrumY' + i, 0);
			set('defaultOpponentStrumX' + i, 0);
			set('defaultOpponentStrumY' + i, 0);
		}

		// Default character positions woooo
		set('defaultBoyfriendX', PlayState.instance.BF_X);
		set('defaultBoyfriendY', PlayState.instance.BF_Y);
		set('defaultOpponentX', PlayState.instance.DAD_X);
		set('defaultOpponentY', PlayState.instance.DAD_Y);
		set('defaultGirlfriendX', PlayState.instance.GF_X);
		set('defaultGirlfriendY', PlayState.instance.GF_Y);

		// Character shit
		set('boyfriendName', PlayState.SONG.player1);
		set('dadName', PlayState.SONG.player2);
		set('gfName', PlayState.SONG.gfVersion);

		// Some settings, no jokes
		set('downscroll', ClientPrefs.downScroll);
		set('middlescroll', ClientPrefs.middleScroll);
		set('framerate', ClientPrefs.framerate);
		set('ghostTapping', ClientPrefs.ghostTapping);
		set('hideHud', ClientPrefs.hideHud);
		set('timeBarType', ClientPrefs.timeBarType);
		set('scoreZoom', ClientPrefs.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.camZooms);
		set('flashingLights', ClientPrefs.flashing);
		set('noteOffset', ClientPrefs.noteOffset);
		set('healthBarAlpha', ClientPrefs.healthBarAlpha);
		set('noResetButton', ClientPrefs.noReset);
		set('lowQuality', ClientPrefs.lowQuality);
		set('shadersEnabled', ClientPrefs.shaders);
		set('scriptName', scriptName);
		set('currentModDirectory', Paths.currentModDirectory);

		#if windows
		set('buildTarget', 'windows');
		#elseif linux
		set('buildTarget', 'linux');
		#elseif mac
		set('buildTarget', 'mac');
		#elseif html5
		set('buildTarget', 'browser');
		#elseif android
		set('buildTarget', 'android');
		#else
		set('buildTarget', 'unknown');
		#end

		// custom substate
		addCallback("openCustomSubstate", function(name:String, pauseGame:Bool = false) {
			if(pauseGame)
			{
				PlayState.instance.persistentUpdate = false;
				PlayState.instance.persistentDraw = true;
				PlayState.instance.paused = true;
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					PlayState.instance.vocals.pause();
				}
			}
			PlayState.instance.openSubState(new CustomSubstate(name));
		});

		addCallback("closeCustomSubstate", function() {
			if(CustomSubstate.instance != null)
			{
				PlayState.instance.closeSubState();
				CustomSubstate.instance = null;
				return true;
			}
			return false;
		});

		// shader shit
		addCallback("initLuaShader", function(name:String, glslVersion:Int = 120) {
			if(!ClientPrefs.shaders) return false;

			#if (!flash && MODS_ALLOWED && sys)
			return initLuaShader(name, glslVersion);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
			return false;
		});
		
		addCallback("setSpriteShader", function(obj:String, shader:String) {
			if(!ClientPrefs.shaders) return false;

			#if (!flash && MODS_ALLOWED && sys)
			if(!PlayState.instance.runtimeShaders.exists(shader) && !initLuaShader(shader))
			{
				luaTrace('Shader $shader is missing!', false, false, FlxColor.RED);
				return false;
			}

			var killMe:Array<String> = obj.split('.');
			var leObj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(leObj != null) {
				var arr:Array<String> = PlayState.instance.runtimeShaders.get(shader);
				leObj.shader = new FlxRuntimeShader(arr[0], arr[1]);
				return true;
			}
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
			return false;
		});
		addCallback("removeSpriteShader", function(obj:String) {
			var killMe:Array<String> = obj.split('.');
			var leObj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(leObj != null) {
				leObj.shader = null;
				return true;
			}
			return false;
		});


		addCallback("getShaderBool", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				Lua.pushnil(lua);
				return null;
			}
			return shader.getBool(prop);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			Lua.pushnil(lua);
			return null;
			#end
		});
		addCallback("getShaderBoolArray", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				Lua.pushnil(lua);
				return null;
			}
			return shader.getBoolArray(prop);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			Lua.pushnil(lua);
			return null;
			#end
		});
		addCallback("getShaderInt", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				Lua.pushnil(lua);
				return null;
			}
			return shader.getInt(prop);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			Lua.pushnil(lua);
			return null;
			#end
		});
		addCallback("getShaderIntArray", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				Lua.pushnil(lua);
				return null;
			}
			return shader.getIntArray(prop);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			Lua.pushnil(lua);
			return null;
			#end
		});
		addCallback("getShaderFloat", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				Lua.pushnil(lua);
				return null;
			}
			return shader.getFloat(prop);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			Lua.pushnil(lua);
			return null;
			#end
		});
		addCallback("getShaderFloatArray", function(obj:String, prop:String) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				Lua.pushnil(lua);
				return null;
			}
			return shader.getFloatArray(prop);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			Lua.pushnil(lua);
			return null;
			#end
		});


		addCallback("setShaderBool", function(obj:String, prop:String, value:Bool) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setBool(prop, value);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
		});
		addCallback("setShaderBoolArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setBoolArray(prop, values);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
		});
		addCallback("setShaderInt", function(obj:String, prop:String, value:Int) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setInt(prop, value);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
		});
		addCallback("setShaderIntArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setIntArray(prop, values);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
		});
		addCallback("setShaderFloat", function(obj:String, prop:String, value:Float) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setFloat(prop, value);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
		});
		addCallback("setShaderFloatArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null) return;

			shader.setFloatArray(prop, values);
			#else
			luaTrace("Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
			#end
		});


		//
		addCallback("getRunningScripts", function(){
			var runningScripts:Array<String> = [];
			for (idx in 0...PlayState.instance.luaArray.length)
				runningScripts.push(PlayState.instance.luaArray[idx].scriptName);


			return runningScripts;
		});

		addCallback("callOnLuas", function(?funcName:String, ?args:Array<Dynamic>, ignoreStops=false, ignoreSelf=true, ?exclusions:Array<String>){
			if(funcName==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callOnLuas' (string expected, got nil)");
				#end
				return;
			}
			if(args==null)args = [];

			if(exclusions==null)exclusions=[];

			Lua.getglobal(lua, 'scriptName');
			var daScriptName = Lua.tostring(lua, -1);
			Lua.pop(lua, 1);
			if(ignoreSelf && !exclusions.contains(daScriptName))exclusions.push(daScriptName);
			PlayState.instance.callOnLuas(funcName, args, ignoreStops, exclusions);
		});

		addCallback("callScript", function(?luaFile:String, ?funcName:String, ?args:Array<Dynamic>){
			if(luaFile==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(funcName==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #2 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(args==null){
				args = [];
			}
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						luaInstance.call(funcName, args);

						return;
					}

				}
			}
			Lua.pushnil(lua);

		});

		addCallback("getGlobalFromScript", function(?luaFile:String, ?global:String){ // returns the global from a script
			if(luaFile==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'getGlobalFromScript' (string expected, got nil)");
				#end
				return;
			}
			if(global==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #2 to 'getGlobalFromScript' (string expected, got nil)");
				#end
				return;
			}
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						Lua.getglobal(luaInstance.lua, global);
						if(Lua.isnumber(luaInstance.lua,-1)){
							Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
						}else if(Lua.isstring(luaInstance.lua,-1)){
							Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
						}else if(Lua.isboolean(luaInstance.lua,-1)){
							Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
						}else{
							Lua.pushnil(lua);
						}
						// TODO: table

						Lua.pop(luaInstance.lua,1); // remove the global

						return;
					}

				}
			}
			Lua.pushnil(lua);
		});
		addCallback("setGlobalFromScript", function(luaFile:String, global:String, val:Dynamic){ // returns the global from a script
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						luaInstance.set(global, val);
					}

				}
			}
			Lua.pushnil(lua);
		});
		/*addCallback("getGlobals", function(luaFile:String){ // returns a copy of the specified file's globals
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						Lua.newtable(lua);
						var tableIdx = Lua.gettop(lua);

						Lua.pushvalue(luaInstance.lua, Lua.LUA_GLOBALSINDEX);
						Lua.pushnil(luaInstance.lua);
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
			Lua.pushnil(lua);
		});*/
		addCallback("isRunning", function(luaFile:String){
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end

			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
						return true;

				}
			}
			return false;
		});


		addCallback("addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf.
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end

			if(doPush)
			{
				if(!ignoreAlreadyRunning)
				{
					for (luaInstance in PlayState.instance.luaArray)
					{
						if(luaInstance.scriptName == cervix)
						{
							luaTrace('The script "' + cervix + '" is already running!');
							return;
						}
					}
				}
				PlayState.instance.luaArray.push(new FunkinLua(cervix));
				return;
			}
			luaTrace("Script doesn't exist!", false, false, FlxColor.RED);
		});
		addCallback("removeLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf.
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end

			if(doPush)
			{
				if(!ignoreAlreadyRunning)
				{
					for (luaInstance in PlayState.instance.luaArray)
					{
						if(luaInstance.scriptName == cervix)
						{
							//luaTrace('The script "' + cervix + '" is already running!');

								PlayState.instance.luaArray.remove(luaInstance);
							return;
						}
					}
				}
				return;
			}
			luaTrace("Script doesn't exist!", false, false, FlxColor.RED);
		});

		addCallback("runHaxeCode", function(codeToRun:String) {
			var retVal:Dynamic = null;

			#if hscript
			initHaxeModule();
			try {
				retVal = hscript.execute(codeToRun);
			}
			catch (e:Dynamic) {
				luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#else
			luaTrace("HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end

			if(retVal != null && !isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
			if(retVal == null) Lua.pushnil(lua);
			return retVal;
		});

		addCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			#if hscript
			initHaxeModule();
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				hscript.setVar(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#end
		});

		addCallback("loadSong", function(?name:String = null, ?difficultyNum:Int = -1) {
			if(name == null || name.length < 1)
				name = PlayState.SONG.song;
			if (difficultyNum == -1)
				difficultyNum = PlayState.storyDifficulty;

			var poop = Highscore.formatSong(name, difficultyNum);
			PlayState.SONG = Song.loadFromJson(poop, name);
			PlayState.storyDifficulty = difficultyNum;
			PlayState.instance.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if(PlayState.instance.vocals != null)
			{
				PlayState.instance.vocals.pause();
				PlayState.instance.vocals.volume = 0;
			}
		});

		addCallback("loadGraphic", function(variable:String, image:String, ?gridX:Int, ?gridY:Int) {
			var killMe:Array<String> = variable.split('.');
			var spr:FlxSprite = getObjectDirectly(killMe[0]);
			var gX = gridX==null?0:gridX;
			var gY = gridY==null?0:gridY;
			var animated = gX!=0 || gY!=0;

			if(killMe.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				spr.loadGraphic(Paths.image(image), animated, gX, gY);
			}
		});
		addCallback("loadFrames", function(variable:String, image:String, spriteType:String = "sparrow") {
			var killMe:Array<String> = variable.split('.');
			var spr:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				loadFrames(spr, image, spriteType);
			}
		});

		addCallback("getProperty", function(variable:String) {
			var result:Dynamic = null;
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1)
				result = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			else
				result = getVarInArray(getInstance(), variable);

			if(result == null) Lua.pushnil(lua);
			return result;
		});
		addCallback("setProperty", function(variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				setVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1], value);
				return true;
			}
			setVarInArray(getInstance(), variable, value);
			return true;
		});
		addCallback("getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(getInstance(), obj);
			if(shitMyPants.length>1)
				realObject = getPropertyLoopThingWhatever(shitMyPants, true, false);


			if(Std.isOfType(realObject, FlxTypedGroup))
			{
				var result:Dynamic = getGroupStuff(realObject.members[index], variable);
				if(result == null) Lua.pushnil(lua);
				return result;
			}


			var leArray:Dynamic = realObject[index];
			if(leArray != null) {
				var result:Dynamic = null;
				if(Type.typeof(variable) == ValueType.TInt)
					result = leArray[variable];
				else
					result = getGroupStuff(leArray, variable);

				if(result == null) Lua.pushnil(lua);
				return result;
			}
			luaTrace("Object #" + index + " from group: " + obj + " doesn't exist!", false, false, FlxColor.RED);
			Lua.pushnil(lua);
			return null;
		});
		addCallback("setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(getInstance(), obj);
			if(shitMyPants.length>1)
				realObject = getPropertyLoopThingWhatever(shitMyPants, true, false);

			if(Std.isOfType(realObject, FlxTypedGroup)) {
				setGroupStuff(realObject.members[index], variable, value);
				return;
			}

			var leArray:Dynamic = realObject[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					leArray[variable] = value;
					return;
				}
				setGroupStuff(leArray, variable, value);
			}
		});
		addCallback("removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false) {
			if(Std.isOfType(Reflect.getProperty(getInstance(), obj), FlxTypedGroup)) {
				var sex = Reflect.getProperty(getInstance(), obj).members[index];
				if(!dontDestroy)
					sex.kill();
				Reflect.getProperty(getInstance(), obj).remove(sex, true);
				if(!dontDestroy)
					sex.destroy();
				return;
			}
			Reflect.getProperty(getInstance(), obj).remove(Reflect.getProperty(getInstance(), obj)[index]);
		});

		addCallback("getPropertyFromClass", function(classVar:String, variable:String) {
			@:privateAccess
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = getVarInArray(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = getVarInArray(coverMeInPiss, killMe[i]);
				}
				return getVarInArray(coverMeInPiss, killMe[killMe.length-1]);
			}
			return getVarInArray(Type.resolveClass(classVar), variable);
		});
		addCallback("setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic) {
			@:privateAccess
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = getVarInArray(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = getVarInArray(coverMeInPiss, killMe[i]);
				}
				setVarInArray(coverMeInPiss, killMe[killMe.length-1], value);
				return true;
			}
			setVarInArray(Type.resolveClass(classVar), variable, value);
			return true;
		});

		//shitass stuff for epic coders like me B)  *image of obama giving himself a medal*
		addCallback("getObjectOrder", function(obj:String) {
			var killMe:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(leObj != null)
			{
				return getInstance().members.indexOf(leObj);
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return -1;
		});
		addCallback("setObjectOrder", function(obj:String, position:Int) {
			var killMe:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(leObj != null) {
				getInstance().remove(leObj, true);
				getInstance().insert(position, leObj);
				return;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});

		// gay ass tweens
		addCallback("doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {x: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		addCallback("doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {y: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		addCallback("doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		addCallback("doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {alpha: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		addCallback("doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {zoom: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		addCallback("doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				var color:Int = Std.parseInt(targetColor);
				if(!targetColor.startsWith('0x')) color = Std.parseInt('0xff' + targetColor);

				var curColor:FlxColor = penisExam.color;
				curColor.alphaFloat = penisExam.alpha;
				PlayState.instance.modchartTweens.set(tag, FlxTween.color(penisExam, duration, curColor, color, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});

		//Tween shit, but for strums
		addCallback("noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {x: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		addCallback("noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {y: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		addCallback("noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		addCallback("noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {direction: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		addCallback("mouseClicked", function(button:String) {
			var boobs = FlxG.mouse.justPressed;
			switch(button){
				case 'middle':
					boobs = FlxG.mouse.justPressedMiddle;
				case 'right':
					boobs = FlxG.mouse.justPressedRight;
			}


			return boobs;
		});
		addCallback("mousePressed", function(button:String) {
			var boobs = FlxG.mouse.pressed;
			switch(button){
				case 'middle':
					boobs = FlxG.mouse.pressedMiddle;
				case 'right':
					boobs = FlxG.mouse.pressedRight;
			}
			return boobs;
		});
		addCallback("mouseReleased", function(button:String) {
			var boobs = FlxG.mouse.justReleased;
			switch(button){
				case 'middle':
					boobs = FlxG.mouse.justReleasedMiddle;
				case 'right':
					boobs = FlxG.mouse.justReleasedRight;
			}
			return boobs;
		});
		addCallback("noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		addCallback("noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {alpha: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});

		addCallback("cancelTween", function(tag:String) {
			cancelTween(tag);
		});

		addCallback("runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
			cancelTimer(tag);
			PlayState.instance.modchartTimers.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
				if(tmr.finished) {
					PlayState.instance.modchartTimers.remove(tag);
				}
				PlayState.instance.callOnLuas('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft]);
				//trace('Timer Completed: ' + tag);
			}, loops));
		});
		addCallback("cancelTimer", function(tag:String) {
			cancelTimer(tag);
		});

		/*addCallback("getPropertyAdvanced", function(varsStr:String) {
			var variables:Array<String> = varsStr.replace(' ', '').split(',');
			var leClass:Class<Dynamic> = Type.resolveClass(variables[0]);
			if(variables.length > 2) {
				var curProp:Dynamic = Reflect.getProperty(leClass, variables[1]);
				if(variables.length > 3) {
					for (i in 2...variables.length-1) {
						curProp = Reflect.getProperty(curProp, variables[i]);
					}
				}
				return Reflect.getProperty(curProp, variables[variables.length-1]);
			} else if(variables.length == 2) {
				return Reflect.getProperty(leClass, variables[variables.length-1]);
			}
			return null;
		});
		addCallback("setPropertyAdvanced", function(varsStr:String, value:Dynamic) {
			var variables:Array<String> = varsStr.replace(' ', '').split(',');
			var leClass:Class<Dynamic> = Type.resolveClass(variables[0]);
			if(variables.length > 2) {
				var curProp:Dynamic = Reflect.getProperty(leClass, variables[1]);
				if(variables.length > 3) {
					for (i in 2...variables.length-1) {
						curProp = Reflect.getProperty(curProp, variables[i]);
					}
				}
				return Reflect.setProperty(curProp, variables[variables.length-1], value);
			} else if(variables.length == 2) {
				return Reflect.setProperty(leClass, variables[variables.length-1], value);
			}
		});*/

		//stupid bietch ass functions
		addCallback("addScore", function(value:Int = 0) {
			PlayState.instance.songScore += value;
			PlayState.instance.RecalculateRating();
		});
		addCallback("addMisses", function(value:Int = 0) {
			PlayState.instance.songMisses += value;
			PlayState.instance.RecalculateRating();
		});
		addCallback("addHits", function(value:Int = 0) {
			PlayState.instance.songHits += value;
			PlayState.instance.RecalculateRating();
		});
		addCallback("setScore", function(value:Int = 0) {
			PlayState.instance.songScore = value;
			PlayState.instance.RecalculateRating();
		});
		addCallback("setMisses", function(value:Int = 0) {
			PlayState.instance.songMisses = value;
			PlayState.instance.RecalculateRating();
		});
		addCallback("setHits", function(value:Int = 0) {
			PlayState.instance.songHits = value;
			PlayState.instance.RecalculateRating();
		});
		addCallback("getScore", function() {
			return PlayState.instance.songScore;
		});
		addCallback("getMisses", function() {
			return PlayState.instance.songMisses;
		});
		addCallback("getHits", function() {
			return PlayState.instance.songHits;
		});

		addCallback("setHealth", function(value:Float = 0) {
			PlayState.instance.health = value;
		});
		addCallback("addHealth", function(value:Float = 0) {
			PlayState.instance.health += value;
		});
		addCallback("getHealth", function() {
			return PlayState.instance.health;
		});

		addCallback("getColorFromHex", function(color:String) {
			if(!color.startsWith('0x')) color = '0xff' + color;
			return Std.parseInt(color);
		});

		addCallback("keyboardJustPressed", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.justPressed, name);
		});
		addCallback("keyboardPressed", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.pressed, name);
		});
		addCallback("keyboardReleased", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.justReleased, name);
		});

		addCallback("anyGamepadJustPressed", function(name:String)
		{
			return FlxG.gamepads.anyJustPressed(name);
		});
		addCallback("anyGamepadPressed", function(name:String)
		{
			return FlxG.gamepads.anyPressed(name);
		});
		addCallback("anyGamepadReleased", function(name:String)
		{
			return FlxG.gamepads.anyJustReleased(name);
		});

		addCallback("gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return 0.0;
			}
			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		addCallback("gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return 0.0;
			}
			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		addCallback("gamepadJustPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		addCallback("gamepadPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.pressed, name) == true;
		});
		addCallback("gamepadReleased", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		addCallback("keyJustPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT_P');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN_P');
				case 'up': key = PlayState.instance.getControl('NOTE_UP_P');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT_P');
				case 'accept': key = PlayState.instance.getControl('ACCEPT');
				case 'back': key = PlayState.instance.getControl('BACK');
				case 'pause': key = PlayState.instance.getControl('PAUSE');
				case 'reset': key = PlayState.instance.getControl('RESET');
				case 'space': key = FlxG.keys.justPressed.SPACE;//an extra key for convinience
			}
			return key;
		});
		addCallback("keyPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN');
				case 'up': key = PlayState.instance.getControl('NOTE_UP');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT');
				case 'space': key = FlxG.keys.pressed.SPACE;//an extra key for convinience
			}
			return key;
		});
		addCallback("keyReleased", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT_R');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN_R');
				case 'up': key = PlayState.instance.getControl('NOTE_UP_R');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT_R');
				case 'space': key = FlxG.keys.justReleased.SPACE;//an extra key for convinience
			}
			return key;
		});
		addCallback("addCharacterToList", function(name:String, type:String) {
			var charType:Int = 0;
			switch(type.toLowerCase()) {
				case 'dad': charType = 1;
				case 'gf' | 'girlfriend': charType = 2;
			}
			PlayState.instance.addCharacterToList(name, charType);
		});
		addCallback("precacheImage", function(name:String) {
			Paths.returnGraphic(name);
		});
		addCallback("precacheSound", function(name:String) {
			CoolUtil.precacheSound(name);
		});
		addCallback("precacheMusic", function(name:String) {
			CoolUtil.precacheMusic(name);
		});
		addCallback("triggerEvent", function(name:String, arg1:Dynamic, arg2:Dynamic) {
			var value1:String = arg1;
			var value2:String = arg2;
			PlayState.instance.triggerEventNote(name, value1, value2);
			//trace('Triggered event: ' + name + ', ' + value1 + ', ' + value2);
			return true;
		});

		addCallback("startCountdown", function() {
			PlayState.instance.startCountdown();
			return true;
		});
		addCallback("endSong", function() {
			PlayState.instance.KillNotes();
			PlayState.instance.endSong();
			return true;
		});
		addCallback("restartSong", function(?skipTransition:Bool = false) {
			PlayState.instance.persistentUpdate = false;
			PauseSubState.restartSong(skipTransition);
			return true;
		});
		addCallback("exitSong", function(?skipTransition:Bool = false) {
			if(skipTransition)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			PlayState.cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = PlayState.instance.camOther;
			if(FlxTransitionableState.skipNextTransIn)
				CustomFadeTransition.nextCamera = null;

			if(PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			PlayState.instance.transitioning = true;
			WeekData.loadTheFirstEnabledMod();
			return true;
		});
		addCallback("getSongPosition", function() {
			return Conductor.songPosition;
		});

		addCallback("getCharacterX", function(type:String) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					return PlayState.instance.dadGroup.x;
				case 'gf' | 'girlfriend':
					return PlayState.instance.gfGroup.x;
				default:
					return PlayState.instance.boyfriendGroup.x;
			}
		});
		addCallback("setCharacterX", function(type:String, value:Float) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					PlayState.instance.dadGroup.x = value;
				case 'gf' | 'girlfriend':
					PlayState.instance.gfGroup.x = value;
				default:
					PlayState.instance.boyfriendGroup.x = value;
			}
		});
		addCallback("getCharacterY", function(type:String) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					return PlayState.instance.dadGroup.y;
				case 'gf' | 'girlfriend':
					return PlayState.instance.gfGroup.y;
				default:
					return PlayState.instance.boyfriendGroup.y;
			}
		});
		addCallback("setCharacterY", function(type:String, value:Float) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					PlayState.instance.dadGroup.y = value;
				case 'gf' | 'girlfriend':
					PlayState.instance.gfGroup.y = value;
				default:
					PlayState.instance.boyfriendGroup.y = value;
			}
		});
		addCallback("cameraSetTarget", function(target:String) {
			var isDad:Bool = false;
			if(target == 'dad') {
				isDad = true;
			}
			PlayState.instance.moveCamera(isDad);
			return isDad;
		});
		addCallback("cameraShake", function(camera:String, intensity:Float, duration:Float) {
			cameraFromString(camera).shake(intensity, duration);
		});

		addCallback("cameraFlash", function(camera:String, color:String, duration:Float,forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).flash(colorNum, duration,null,forced);
		});
		addCallback("cameraFade", function(camera:String, color:String, duration:Float,forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).fade(colorNum, duration,false,null,forced);
		});
		addCallback("setRatingPercent", function(value:Float) {
			PlayState.instance.ratingPercent = value;
		});
		addCallback("setRatingName", function(value:String) {
			PlayState.instance.ratingName = value;
		});
		addCallback("setRatingFC", function(value:String) {
			PlayState.instance.ratingFC = value;
		});
		addCallback("getMouseX", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).x;
		});
		addCallback("getMouseY", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).y;
		});

		addCallback("getMidpointX", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			if(obj != null) return obj.getMidpoint().x;

			return 0;
		});
		addCallback("getMidpointY", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			if(obj != null) return obj.getMidpoint().y;

			return 0;
		});
		addCallback("getGraphicMidpointX", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().x;

			return 0;
		});
		addCallback("getGraphicMidpointY", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().y;

			return 0;
		});
		addCallback("getScreenPositionX", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().x;

			return 0;
		});
		addCallback("getScreenPositionY", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().y;

			return 0;
		});
		addCallback("characterDance", function(character:String) {
			switch(character.toLowerCase()) {
				case 'dad': PlayState.instance.dad.dance();
				case 'gf' | 'girlfriend': if(PlayState.instance.gf != null) PlayState.instance.gf.dance();
				default: PlayState.instance.boyfriend.dance();
			}
		});

		addCallback("makeLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);
			if(image != null && image.length > 0)
			{
				leSprite.loadGraphic(Paths.image(image));
			}
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
			leSprite.active = true;
		});
		addCallback("makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float, ?spriteType:String = "sparrow") {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);

			loadFrames(leSprite, image, spriteType);
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
		});

		addCallback("makeLuaSpriteGroup", function(tag:String, ?x:Float = 0, ?y:Float = 0, ?maxSize:Int = 0)
		{
			tag = tag.replace('.', '');
			resetSpriteTag(tag);

			var leGroup:ModchartGroup = new ModchartGroup(x, y, maxSize);
			PlayState.instance.modchartGroups.set(tag, leGroup);
		});

		addCallback("makeGraphic", function(obj:String, width:Int, height:Int, color:String) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

			var spr:FlxSprite = PlayState.instance.getLuaObject(obj,false);
			if(spr!=null) {
				PlayState.instance.getLuaObject(obj,false).makeGraphic(width, height, colorNum);
				return;
			}

			var object:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(object != null) {
				object.makeGraphic(width, height, colorNum);
			}
		});

		addCallback("addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				var cock:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
				return;
			}

			var cock:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(cock != null) {
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});

		addCallback("addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				var cock:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				cock.animation.add(name, frames, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
				return;
			}

			var cock:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(cock != null) {
				cock.animation.add(name, frames, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});

		addCallback("addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			return addAnimByIndices(obj, name, prefix, indices, framerate, false);
		});
		addCallback("addAnimationByIndicesLoop", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			return addAnimByIndices(obj, name, prefix, indices, framerate, true);
		});
		
		addCallback("playAnim", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0)
		{
			if(PlayState.instance.getLuaObject(obj, false) != null) {
				var luaObj:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				if(luaObj.animation.getByName(name) != null)
				{
					luaObj.animation.play(name, forced, reverse, startFrame);
					if(Std.isOfType(luaObj, ModchartSprite))
					{
						//convert luaObj to ModchartSprite
						var obj:Dynamic = luaObj;
						var luaObj:ModchartSprite = obj;

						var daOffset = luaObj.animOffsets.get(name);
						if (luaObj.animOffsets.exists(name))
						{
							luaObj.offset.set(daOffset[0], daOffset[1]);
						}
						else
							luaObj.offset.set(0, 0);
					}
				}
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(spr != null) {
				if(spr.animation.getByName(name) != null)
				{
					if(Std.isOfType(spr, Character))
					{
						//convert spr to Character
						var obj:Dynamic = spr;
						var spr:Character = obj;
						spr.playAnim(name, forced, reverse, startFrame);
					}
					else
						spr.animation.play(name, forced, reverse, startFrame);
				}
				return true;
			}
			return false;
		});
		addCallback("playAnimGroup", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0) 
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(obj);

			if (leGroup != null)
			{
				leGroup.forEach(function(spr:ModchartSprite)
				{
					var offsetX:Float = 0;
					var offsetY:Float = 0;

					if (spr.animOffsets.exists(name))
					{
						offsetX = spr.animOffsets.get(name)[0];
						offsetY = spr.animOffsets.get(name)[1];
					}

					#if (flixel >= "4.11.0")
					if (spr.animation.exists(name))
					#else
					if (spr.animation.getByName(name) != null)
					#end
					{
						spr.animation.play(name, forced, reverse, startFrame);
						spr.offset.set(offsetX, offsetY);
					}
				});

				return true;	
			}

			return false;
		});
		addCallback("addOffset", function(obj:String, anim:String, x:Float, y:Float) {
			if(PlayState.instance.modchartSprites.exists(obj)) {
				PlayState.instance.modchartSprites.get(obj).animOffsets.set(anim, [x, y]);
				return true;
			}

			var char:Character = Reflect.getProperty(getInstance(), obj);
			if(char != null) {
				char.addOffset(anim, x, y);
				return true;
			}
			return false;
		});

		addCallback("setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				PlayState.instance.getLuaObject(obj,false).scrollFactor.set(scrollX, scrollY);
				return;
			}

			var object:FlxObject = Reflect.getProperty(getInstance(), obj);
			if(object != null) {
				object.scrollFactor.set(scrollX, scrollY);
			}
		});

		addCallback("setGroupScrollFactor", function(obj:String, ?scrollX:Float = 0, ?scrollY:Float = 0)
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(obj);

			if (leGroup != null)
			{	
				leGroup.scrollFactor.set(scrollX, scrollY);
			}
		});

		addCallback("addSpriteToGroup", function(tag:String, spr:String)
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(tag);

			if (leGroup != null)
			{
				var leSprite:ModchartSprite = PlayState.instance.modchartSprites.get(spr);

				if (leSprite != null)
				{
					leGroup.add(leSprite);
				}
			}
		});

		addCallback("addLuaSpriteGroup", function(tag:String, front:Bool = false)
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(tag);

			if (leGroup != null)
			{
				if (!leGroup.wasAdded)
				{
					if (front)
						getInstance().add(leGroup);
					else
					{
						if(PlayState.instance.isDead)
						{
							GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), leGroup);
						}
						else
						{
							var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
							if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
								position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
							} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
								position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
							}
							PlayState.instance.insert(position, leGroup);
						}
					}

					leGroup.wasAdded = true;
				}
			}
		});

		addCallback("addLuaSprite", function(tag:String, front:Bool = false) {
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var shit:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				if(!shit.wasAdded) {
					if(front)
					{
						getInstance().add(shit);
					}
					else
					{
						if(PlayState.instance.isDead)
						{
							GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), shit);
						}
						else
						{
							var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
							if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
								position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
							} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
								position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
							}
							PlayState.instance.insert(position, shit);
						}
					}
					shit.wasAdded = true;
					//trace('added a thing: ' + tag);
				}
			}
		});
		addCallback("setGraphicSize", function(obj:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			if(PlayState.instance.getLuaObject(obj)!=null) {
				var shit:FlxSprite = PlayState.instance.getLuaObject(obj);
				shit.setGraphicSize(x, y);
				if(updateHitbox) shit.updateHitbox();
				return;
			}

			var killMe:Array<String> = obj.split('.');
			var poop:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				poop = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(poop != null) {
				poop.setGraphicSize(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		addCallback("setGroupGraphicSize", function(tag:String, x:Int, y:Int = 0, updateHitbox:Bool = true)
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(tag);

			if (leGroup != null)
			{
				leGroup.setGraphicSize(x, y);
				if (updateHitbox)
					leGroup.updateHitbox();
			}
		});
		addCallback("scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
			if(PlayState.instance.getLuaObject(obj)!=null) {
				var shit:FlxSprite = PlayState.instance.getLuaObject(obj);
				shit.scale.set(x, y);
				if(updateHitbox) shit.updateHitbox();
				return;
			}

			var killMe:Array<String> = obj.split('.');
			var poop:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				poop = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(poop != null) {
				poop.scale.set(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		addCallback("scaleGroup", function(tag:String, x:Float, y:Float, updateHitbox:Bool = true)
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(tag);

			if (leGroup != null)
			{
				leGroup.scale.set(x, y);
				if (updateHitbox)
					leGroup.updateHitbox();
			}
		});
		addCallback("updateGroupHitbox", function(tag:String)
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(tag);

			if (leGroup != null)
			{
				leGroup.updateHitbox();	
			}
		});
		addCallback("updateHitbox", function(obj:String) {
			if(PlayState.instance.getLuaObject(obj)!=null) {
				var shit:FlxSprite = PlayState.instance.getLuaObject(obj);
				shit.updateHitbox();
				return;
			}

			var poop:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(poop != null) {
				poop.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		addCallback("updateHitboxFromGroup", function(group:String, index:Int) {
			if(Std.isOfType(Reflect.getProperty(getInstance(), group), FlxTypedGroup)) {
				Reflect.getProperty(getInstance(), group).members[index].updateHitbox();
				return;
			}
			Reflect.getProperty(getInstance(), group)[index].updateHitbox();
		});

		addCallback("isNoteChild", function(parentID:Int, childID:Int){
			var parent: Note = cast PlayState.instance.getLuaObject('note${parentID}',false);
			var child: Note = cast PlayState.instance.getLuaObject('note${childID}',false);
			if(parent!=null && child!=null)
				return parent.tail.contains(child);

			luaTrace('${parentID} or ${childID} is not a valid note ID', false, false, FlxColor.RED);
			return false;
		});

		addCallback("removeSpriteFromGroup", function(tag:String, spr:String, destroy:Bool = true)
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(tag);

			if (leGroup != null)
			{
				var leSprite:ModchartSprite = PlayState.instance.modchartSprites.get(spr);
				if (leSprite != null && leGroup.members.contains(leSprite))
				{
					leGroup.remove(leSprite);

					if (destroy)
						leGroup.destroy();
				}
			}
		});
		addCallback("removeLuaSprite", function(tag:String, destroy:Bool = true) {
			if(!PlayState.instance.modchartSprites.exists(tag)) {
				return;
			}

			var pee:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
			if(destroy) {
				pee.kill();
			}

			if(pee.wasAdded) {
				getInstance().remove(pee, true);
				pee.wasAdded = false;
			}

			if(destroy) {
				pee.destroy();
				PlayState.instance.modchartSprites.remove(tag);
			}
		});

		addCallback("luaSpriteExists", function(tag:String) {
			return PlayState.instance.modchartSprites.exists(tag);
		});
		addCallback("luaTextExists", function(tag:String) {
			return PlayState.instance.modchartTexts.exists(tag);
		});
		addCallback("luaSoundExists", function(tag:String) {
			return PlayState.instance.modchartSounds.exists(tag);
		});

		addCallback("setHealthBarColors", function(leftHex:String, rightHex:String) {
			var left:FlxColor = Std.parseInt(leftHex);
			if(!leftHex.startsWith('0x')) left = Std.parseInt('0xff' + leftHex);
			var right:FlxColor = Std.parseInt(rightHex);
			if(!rightHex.startsWith('0x')) right = Std.parseInt('0xff' + rightHex);

			PlayState.instance.healthBar.createFilledBar(left, right);
			PlayState.instance.healthBar.updateBar();
		});
		addCallback("setTimeBarColors", function(leftHex:String, rightHex:String) {
			var left:FlxColor = Std.parseInt(leftHex);
			if(!leftHex.startsWith('0x')) left = Std.parseInt('0xff' + leftHex);
			var right:FlxColor = Std.parseInt(rightHex);
			if(!rightHex.startsWith('0x')) right = Std.parseInt('0xff' + rightHex);

			PlayState.instance.timeBar.createFilledBar(right, left);
			PlayState.instance.timeBar.updateBar();
		});

		addCallback("setObjectCamera", function(obj:String, camera:String = '') {
			/*if(PlayState.instance.modchartSprites.exists(obj)) {
				PlayState.instance.modchartSprites.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}
			else if(PlayState.instance.modchartTexts.exists(obj)) {
				PlayState.instance.modchartTexts.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}*/
			var real = PlayState.instance.getLuaObject(obj);
			if(real!=null){
				real.cameras = [cameraFromString(camera)];
				return true;
			}

			var killMe:Array<String> = obj.split('.');
			var object:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				object = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(object != null) {
				object.cameras = [cameraFromString(camera)];
				return true;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		addCallback("setBlendMode", function(obj:String, blend:String = '') {
			var real = PlayState.instance.getLuaObject(obj);
			if(real!=null) {
				real.blend = blendModeFromString(blend);
				return true;
			}

			var killMe:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(spr != null) {
				spr.blend = blendModeFromString(blend);
				return true;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		addCallback("screenCenterGroup", function(tag:String, pos:String = 'xy')
		{
			var leGroup:ModchartGroup = PlayState.instance.modchartGroups.get(tag);

			if (leGroup != null)
			{
				switch (pos.toLowerCase().trim())
				{
					case 'x': leGroup.screenCenter(X);
					case 'y': leGroup.screenCenter(Y);
					case 'xy': leGroup.screenCenter();
					default: return;
				}
			}
		});
		addCallback("screenCenter", function(obj:String, pos:String = 'xy') {
			var spr:FlxSprite = PlayState.instance.getLuaObject(obj);

			if(spr==null){
				var killMe:Array<String> = obj.split('.');
				spr = getObjectDirectly(killMe[0]);
				if(killMe.length > 1) {
					spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
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
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});
		addCallback("objectsOverlap", function(obj1:String, obj2:String) {
			var namesArray:Array<String> = [obj1, obj2];
			var objectsArray:Array<FlxSprite> = [];
			for (i in 0...namesArray.length)
			{
				var real = PlayState.instance.getLuaObject(namesArray[i]);
				if(real!=null) {
					objectsArray.push(real);
				} else {
					objectsArray.push(Reflect.getProperty(getInstance(), namesArray[i]));
				}
			}

			if(!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
			{
				return true;
			}
			return false;
		});
		addCallback("getPixelColor", function(obj:String, x:Int, y:Int) {
			var killMe:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(spr != null)
			{
				if(spr.framePixels != null) spr.framePixels.getPixel32(x, y);
				return spr.pixels.getPixel32(x, y);
			}
			return 0;
		});
		addCallback("getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		addCallback("getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		addCallback("getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});
		addCallback("startDialogue", function(dialogueFile:String, music:String = null) {
			var path:String;
			#if MODS_ALLOWED
			path = Paths.modsJson(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);
			if(!FileSystem.exists(path))
			#end
				path = Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);

			luaTrace('Trying to load dialogue: ' + path);

			#if MODS_ALLOWED
			if(FileSystem.exists(path))
			#else
			if(Assets.exists(path))
			#end
			{
				var shit:DialogueFile = DialogueBoxPsych.parseDialogue(path);
				if(shit.dialogue.length > 0) {
					PlayState.instance.startDialogue(shit, music);
					luaTrace('Successfully loaded dialogue', false, false, FlxColor.GREEN);
					return true;
				} else {
					luaTrace('Your dialogue file is badly formatted!', false, false, FlxColor.RED);
				}
			} else {
				luaTrace('Dialogue file not found', false, false, FlxColor.RED);
				if(PlayState.instance.endingSong) {
					PlayState.instance.endSong();
				} else {
					PlayState.instance.startCountdown();
				}
			}
			return false;
		});
		addCallback("startVideo", function(videoFile:String) {
			#if VIDEOS_ALLOWED
			if(FileSystem.exists(Paths.video(videoFile))) {
				PlayState.instance.startVideo(videoFile);
				return true;
			} else {
				luaTrace('Video file not found: ' + videoFile, false, false, FlxColor.RED);
			}
			return false;

			#else
			if(PlayState.instance.endingSong) {
				PlayState.instance.endSong();
			} else {
				PlayState.instance.startCountdown();
			}
			return true;
			#end
		});

		addCallback("playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});
		addCallback("playSound", function(sound:String, volume:Float = 1, ?tag:String = null) {
			if(tag != null && tag.length > 0) {
				tag = tag.replace('.', '');
				if(PlayState.instance.modchartSounds.exists(tag)) {
					PlayState.instance.modchartSounds.get(tag).stop();
				}
				PlayState.instance.modchartSounds.set(tag, FlxG.sound.play(Paths.sound(sound), volume, false, function() {
					PlayState.instance.modchartSounds.remove(tag);
					PlayState.instance.callOnLuas('onSoundFinished', [tag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
		});
		addCallback("stopSound", function(tag:String) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).stop();
				PlayState.instance.modchartSounds.remove(tag);
			}
		});
		addCallback("pauseSound", function(tag:String) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).pause();
			}
		});
		addCallback("resumeSound", function(tag:String) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).play();
			}
		});
		addCallback("soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).fadeIn(duration, fromValue, toValue);
			}

		});
		addCallback("soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeOut(duration, toValue);
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).fadeOut(duration, toValue);
			}
		});
		addCallback("soundFadeCancel", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music.fadeTween != null) {
					FlxG.sound.music.fadeTween.cancel();
				}
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				var theSound:FlxSound = PlayState.instance.modchartSounds.get(tag);
				if(theSound.fadeTween != null) {
					theSound.fadeTween.cancel();
					PlayState.instance.modchartSounds.remove(tag);
				}
			}
		});
		addCallback("getSoundVolume", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					return FlxG.sound.music.volume;
				}
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				return PlayState.instance.modchartSounds.get(tag).volume;
			}
			return 0;
		});
		addCallback("setSoundVolume", function(tag:String, value:Float) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					FlxG.sound.music.volume = value;
				}
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).volume = value;
			}
		});
		addCallback("getSoundTime", function(tag:String) {
			if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
				return PlayState.instance.modchartSounds.get(tag).time;
			}
			return 0;
		});
		addCallback("setSoundTime", function(tag:String, value:Float) {
			if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
				var theSound:FlxSound = PlayState.instance.modchartSounds.get(tag);
				if(theSound != null) {
					var wasResumed:Bool = theSound.playing;
					theSound.pause();
					theSound.time = value;
					if(wasResumed) theSound.play();
				}
			}
		});

		addCallback("debugPrint", function(text1:Dynamic = '', text2:Dynamic = '', text3:Dynamic = '', text4:Dynamic = '', text5:Dynamic = '') {
			if (text1 == null) text1 = '';
			if (text2 == null) text2 = '';
			if (text3 == null) text3 = '';
			if (text4 == null) text4 = '';
			if (text5 == null) text5 = '';
			luaTrace('' + text1 + text2 + text3 + text4 + text5, true, false);
		});
		
		addCallback("close", function() {
			closed = true;
			return closed;
		});

		addCallback("changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			#if desktop
			DiscordClient.changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
			#end
		});


		// LUA TEXTS
		addCallback("makeLuaText", function(tag:String, text:String, width:Int, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetTextTag(tag);
			var leText:ModchartText = new ModchartText(x, y, text, width);
			PlayState.instance.modchartTexts.set(tag, leText);
		});

		addCallback("setTextString", function(tag:String, text:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.text = text;
			}
		});
		addCallback("setTextSize", function(tag:String, size:Int) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.size = size;
			}
		});
		addCallback("setTextWidth", function(tag:String, width:Float) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.fieldWidth = width;
			}
		});
		addCallback("setTextBorder", function(tag:String, size:Int, color:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.borderSize = size;
				obj.borderColor = colorNum;
			}
		});
		addCallback("setTextColor", function(tag:String, color:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.color = colorNum;
			}
		});
		addCallback("setTextFont", function(tag:String, newFont:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.font = Paths.font(newFont);
			}
		});
		addCallback("setTextItalic", function(tag:String, italic:Bool) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.italic = italic;
			}
		});
		addCallback("setTextAlignment", function(tag:String, alignment:String = 'left') {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.alignment = LEFT;
				switch(alignment.trim().toLowerCase())
				{
					case 'right':
						obj.alignment = RIGHT;
					case 'center':
						obj.alignment = CENTER;
				}
			}
		});

		addCallback("getTextString", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null && obj.text != null)
			{
				return obj.text;
			}
			Lua.pushnil(lua);
			return null;
		});
		addCallback("getTextSize", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.size;
			}
			return -1;
		});
		addCallback("getTextFont", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.font;
			}
			Lua.pushnil(lua);
			return null;
		});
		addCallback("getTextWidth", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.fieldWidth;
			}
			return 0;
		});

		addCallback("addLuaText", function(tag:String) {
			if(PlayState.instance.modchartTexts.exists(tag)) {
				var shit:ModchartText = PlayState.instance.modchartTexts.get(tag);
				if(!shit.wasAdded) {
					getInstance().add(shit);
					shit.wasAdded = true;
					//trace('added a thing: ' + tag);
				}
			}
		});
		addCallback("removeLuaText", function(tag:String, destroy:Bool = true) {
			if(!PlayState.instance.modchartTexts.exists(tag)) {
				return;
			}

			var pee:ModchartText = PlayState.instance.modchartTexts.get(tag);
			if(destroy) {
				pee.kill();
			}

			if(pee.wasAdded) {
				getInstance().remove(pee, true);
				pee.wasAdded = false;
			}

			if(destroy) {
				pee.destroy();
				PlayState.instance.modchartTexts.remove(tag);
			}
		});

		addCallback("initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
			if(!PlayState.instance.modchartSaves.exists(name))
			{
				var save:FlxSave = new FlxSave();
				save.bind(name, folder);
				PlayState.instance.modchartSaves.set(name, save);
				return;
			}
			luaTrace('Save file already initialized: ' + name);
		});
		addCallback("flushSaveData", function(name:String) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).flush();
				return;
			}
			luaTrace('Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		addCallback("getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic = null) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				var retVal:Dynamic = Reflect.field(PlayState.instance.modchartSaves.get(name).data, field);
				return retVal;
			}
			luaTrace('Save file not initialized: ' + name, false, false, FlxColor.RED);
			return defaultValue;
		});
		addCallback("setDataFromSave", function(name:String, field:String, value:Dynamic) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				Reflect.setField(PlayState.instance.modchartSaves.get(name).data, field, value);
				return;
			}
			luaTrace('Save file not initialized: ' + name, false, false, FlxColor.RED);
		});

		addCallback("checkFileExists", function(filename:String, ?absolute:Bool = false) {
			#if MODS_ALLOWED
			if(absolute)
			{
				return FileSystem.exists(filename);
			}

			var path:String = Paths.modFolders(filename);
			if(FileSystem.exists(path))
			{
				return true;
			}
			return FileSystem.exists(Paths.getPath('assets/$filename', TEXT));
			#else
			if(absolute)
			{
				return Assets.exists(filename);
			}
			return Assets.exists(Paths.getPath('assets/$filename', TEXT));
			#end
		});
		addCallback("saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try {
				if(!absolute)
					File.saveContent(Paths.mods(path), content);
				else
					File.saveContent(path, content);

				return true;
			} catch (e:Dynamic) {
				luaTrace("Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		addCallback("deleteFile", function(path:String, ?ignoreModFolders:Bool = false)
		{
			try {
				#if MODS_ALLOWED
				if(!ignoreModFolders)
				{
					var lePath:String = Paths.modFolders(path);
					if(FileSystem.exists(lePath))
					{
						FileSystem.deleteFile(lePath);
						return true;
					}
				}
				#end

				var lePath:String = Paths.getPath(path, TEXT);
				if(Assets.exists(lePath))
				{
					FileSystem.deleteFile(lePath);
					return true;
				}
			} catch (e:Dynamic) {
				luaTrace("Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		addCallback("getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
			return Paths.getTextFromFile(path, ignoreModFolders);
		});

		// DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
		addCallback("objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.getLuaObject(obj,false) != null) {
				PlayState.instance.getLuaObject(obj,false).animation.play(name, forced, false, startFrame);
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(spr != null) {
				spr.animation.play(name, forced, false, startFrame);
				return true;
			}
			return false;
		});
		addCallback("characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
			luaTrace("characterPlayAnim is deprecated! Use playAnim instead", false, true);
			switch(character.toLowerCase()) {
				case 'dad':
					if(PlayState.instance.dad.animOffsets.exists(anim))
						PlayState.instance.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if(PlayState.instance.gf != null && PlayState.instance.gf.animOffsets.exists(anim))
						PlayState.instance.gf.playAnim(anim, forced);
				default:
					if(PlayState.instance.boyfriend.animOffsets.exists(anim))
						PlayState.instance.boyfriend.playAnim(anim, forced);
			}
		});
		addCallback("luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String) {
			luaTrace("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				PlayState.instance.modchartSprites.get(tag).makeGraphic(width, height, colorNum);
			}
		});
		addCallback("luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			luaTrace("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var cock:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});
		addCallback("luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			luaTrace("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var strIndices:Array<String> = indices.trim().split(',');
				var die:Array<Int> = [];
				for (i in 0...strIndices.length) {
					die.push(Std.parseInt(strIndices[i]));
				}
				var pussy:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});
		addCallback("luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
			luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).animation.play(name, forced);
			}
		});
		addCallback("setLuaSpriteCamera", function(tag:String, camera:String = '') {
			luaTrace("setLuaSpriteCamera is deprecated! Use setObjectCamera instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).cameras = [cameraFromString(camera)];
				return true;
			}
			luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		addCallback("setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float) {
			luaTrace("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		addCallback("scaleLuaSprite", function(tag:String, x:Float, y:Float) {
			luaTrace("scaleLuaSprite is deprecated! Use scaleObject instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var shit:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return true;
			}
			return false;
		});
		addCallback("getPropertyLuaSprite", function(tag:String, variable:String) {
			luaTrace("getPropertyLuaSprite is deprecated! Use getProperty instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
				}
				return Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), variable);
			}
			return null;
		});
		addCallback("setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic) {
			luaTrace("setPropertyLuaSprite is deprecated! Use setProperty instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
					return true;
				}
				Reflect.setProperty(PlayState.instance.modchartSprites.get(tag), variable, value);
				return true;
			}
			luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		addCallback("musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);

		});
		addCallback("musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
			luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
		});

		// Other stuff
		addCallback("stringStartsWith", function(str:String, start:String) {
			return str.startsWith(start);
		});
		addCallback("stringEndsWith", function(str:String, end:String) {
			return str.endsWith(end);
		});
		addCallback("stringSplit", function(str:String, split:String) {
			return str.split(split);
		});
		addCallback("stringTrim", function(str:String) {
			return str.trim();
		});
		
		addCallback("directoryFileList", function(folder:String) {
			var list:Array<String> = [];
			#if sys
			if(FileSystem.exists(folder)) {
				for (folder in FileSystem.readDirectory(folder)) {
					if (!list.contains(folder)) {
						list.push(folder);
					}
				}
			}
			#end
			return list;
		});

		call('onCreate', []);
		#end
	}

	public static function isOfTypes(value:Any, types:Array<Dynamic>)
	{
		for (type in types)
		{
			if(Std.isOfType(value, type)) return true;
		}
		return false;
	}

	#if hscript
	public function initHaxeModule()
	{
		if(hscript == null)
		{
			trace('initializing haxe interp for: $scriptName');
			hscript = new HScript(); //TO DO: Fix issue with 2 scripts not being able to use the same variable names
		}
	}
	#end

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Any
	{
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1)
		{
			var blah:Dynamic = null;
			if(PlayState.instance.variables.exists(shit[0]))
			{
				var retVal:Dynamic = PlayState.instance.variables.get(shit[0]);
				if(retVal != null)
					blah = retVal;
			}
			else
				blah = Reflect.getProperty(instance, shit[0]);

			for (i in 1...shit.length)
			{
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				if(i >= shit.length-1) //Last array
					blah[leNum] = value;
				else //Anything else
					blah = blah[leNum];
			}
			return blah;
		}
		/*if(Std.isOfType(instance, Map))
			instance.set(variable,value);
		else*/
			
		if(PlayState.instance.variables.exists(variable))
		{
			PlayState.instance.variables.set(variable, value);
			return true;
		}

		Reflect.setProperty(instance, variable, value);
		return true;
	}
	public static function getVarInArray(instance:Dynamic, variable:String):Any
	{
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1)
		{
			var blah:Dynamic = null;
			if(PlayState.instance.variables.exists(shit[0]))
			{
				var retVal:Dynamic = PlayState.instance.variables.get(shit[0]);
				if(retVal != null)
					blah = retVal;
			}
			else
				blah = Reflect.getProperty(instance, shit[0]);

			for (i in 1...shit.length)
			{
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				blah = blah[leNum];
			}
			return blah;
		}

		if(PlayState.instance.variables.exists(variable))
		{
			var retVal:Dynamic = PlayState.instance.variables.get(variable);
			if(retVal != null)
				return retVal;
		}

		return Reflect.getProperty(instance, variable);
	}

	inline static function getTextObject(name:String):FlxText
	{
		return PlayState.instance.modchartTexts.exists(name) ? PlayState.instance.modchartTexts.get(name) : Reflect.getProperty(PlayState.instance, name);
	}

	public function getShader(obj:String):FlxRuntimeShader
	{
		var killMe:Array<String> = obj.split('.');
		var leObj:FlxSprite = getObjectDirectly(killMe[0]);
		if(killMe.length > 1) {
			leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
		}

		if(leObj != null) {
			var shader:Dynamic = leObj.shader;
			var shader:FlxRuntimeShader = shader;
			return shader;
		}
		return null;
	}
	
	function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(PlayState.instance.runtimeShaders.exists(name))
		{
			luaTrace('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
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

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					PlayState.instance.runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
		return false;
	}

	function getGroupStuff(leArray:Dynamic, variable:String) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			switch(Type.typeof(coverMeInPiss)){
				case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
					return coverMeInPiss.get(killMe[killMe.length-1]);
				default:
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			};
		}
		switch(Type.typeof(leArray)){
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				return leArray.get(variable);
			default:
				return Reflect.getProperty(leArray, variable);
		};
	}

	function loadFrames(spr:FlxSprite, image:String, spriteType:String)
	{
		switch(spriteType.toLowerCase().trim())
		{
			case "texture" | "textureatlas" | "tex":
				spr.frames = AtlasFrameMaker.construct(image);

			case "texture_noaa" | "textureatlas_noaa" | "tex_noaa":
				spr.frames = AtlasFrameMaker.construct(image, null, true);

			case "packer" | "packeratlas" | "pac":
				spr.frames = Paths.getPackerAtlas(image);

			default:
				spr.frames = Paths.getSparrowAtlas(image);
		}
	}

	function addCallback(name:String, func:Function)
	{
		return Lua_helper.add_callback(lua, name, func);
	}

	function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			return;
		}
		Reflect.setProperty(leArray, variable, value);
	}

	function resetTextTag(tag:String) {
		if(!PlayState.instance.modchartTexts.exists(tag)) {
			return;
		}

		var pee:ModchartText = PlayState.instance.modchartTexts.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			PlayState.instance.remove(pee, true);
		}
		pee.destroy();
		PlayState.instance.modchartTexts.remove(tag);
	}

	function resetSpriteTag(tag:String) {
		if(!PlayState.instance.modchartSprites.exists(tag)) {
			return;
		}

		var pee:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			PlayState.instance.remove(pee, true);
		}
		pee.destroy();
		PlayState.instance.modchartSprites.remove(tag);
	}

	function cancelTween(tag:String) {
		if(PlayState.instance.modchartTweens.exists(tag)) {
			PlayState.instance.modchartTweens.get(tag).cancel();
			PlayState.instance.modchartTweens.get(tag).destroy();
			PlayState.instance.modchartTweens.remove(tag);
		}
	}

	function tweenShit(tag:String, vars:String) {
		cancelTween(tag);
		var variables:Array<String> = vars.split('.');
		var sexyProp:Dynamic = getObjectDirectly(variables[0]);
		if(variables.length > 1) {
			sexyProp = getVarInArray(getPropertyLoopThingWhatever(variables), variables[variables.length-1]);
		}
		return sexyProp;
	}

	function cancelTimer(tag:String) {
		if(PlayState.instance.modchartTimers.exists(tag)) {
			var theTimer:FlxTimer = PlayState.instance.modchartTimers.get(tag);
			theTimer.cancel();
			theTimer.destroy();
			PlayState.instance.modchartTimers.remove(tag);
		}
	}

	//Better optimized than using some getProperty shit or idk
	function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	function blendModeFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

	function cameraFromString(cam:String):FlxCamera {
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': return PlayState.instance.camHUD;
			case 'camother' | 'other': return PlayState.instance.camOther;
		}
		return PlayState.instance.camGame;
	}

	public function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE) {
		#if LUA_ALLOWED
		if(ignoreCheck || getBool('luaDebugMode')) {
			if(deprecated && !getBool('luaDeprecatedWarnings')) {
				return;
			}
			PlayState.instance.addTextToDebug(text, color);
			trace(text);
		}
		#end
	}

	function getErrorMessage() {
		#if LUA_ALLOWED
		var v:String = Lua.tostring(lua, -1);
		if(!isErrorAllowed(v)) v = null;
		return v;
		#end
	}

	// some fuckery fucks with linc_luajit
	function getResult(l:State, result:Int):Any {
		var ret:Any = null;

		switch(Lua.type(l, result)) {
			case Lua.LUA_TNIL:
				ret = null;
			case Lua.LUA_TBOOLEAN:
				ret = Lua.toboolean(l, -1);
			case Lua.LUA_TNUMBER:
				ret = Lua.tonumber(l, -1);
			case Lua.LUA_TSTRING:
				ret = Lua.tostring(l, -1);
		}
		
		return ret;
	}

	var lastCalledFunction:String = '';
	public function call(func:String, args:Array<Dynamic>): Dynamic
	{
		#if LUA_ALLOWED
		if(closed) return Function_Continue;

		lastCalledFunction = func;
		try {
			if(lua == null) return Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);
			if (type != Lua.LUA_TFUNCTION) {
				return Function_Continue;
			}
			
			for(arg in args) {
				Convert.toLua(lua, arg);
			}

			var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
			var hscriptResult:Dynamic = hscript.call(func, args);

			if (hscriptResult == -1)
			{
				//trace('$func does not exist!');
			}

			var error:Dynamic = getErrorMessage();
			if(!resultIsAllowed(lua, result))
			{
				Lua.pop(lua, 1);
				if(error != null) luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
			}
			else
			{
				var conv:Dynamic = cast getResult(lua, result);
				Lua.pop(lua, 1);
				if(conv == null) conv = Function_Continue;
				return conv;
			}
			return Function_Continue;
		}
		catch (e:haxe.Exception) {
			trace(e.stack);
		}
		#end
		return Function_Continue;
	}

	static function addAnimByIndices(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24, loop:Bool = false)
	{
		var strIndices:Array<String> = indices.trim().split(',');
		var die:Array<Int> = [];
		for (i in 0...strIndices.length) {
			die.push(Std.parseInt(strIndices[i]));
		}

		if(PlayState.instance.getLuaObject(obj, false)!=null) {
			var pussy:FlxSprite = PlayState.instance.getLuaObject(obj, false);
			pussy.animation.addByIndices(name, prefix, die, '', framerate, loop);
			if(pussy.animation.curAnim == null) {
				pussy.animation.play(name, true);
			}
			return true;
		}

		var pussy:FlxSprite = Reflect.getProperty(getInstance(), obj);
		if(pussy != null) {
			pussy.animation.addByIndices(name, prefix, die, '', framerate, loop);
			if(pussy.animation.curAnim == null) {
				pussy.animation.play(name, true);
			}
			return true;
		}
		return false;
	}

	public static function getPropertyLoopThingWhatever(killMe:Array<String>, ?checkForTextsToo:Bool = true, ?getProperty:Bool=true):Dynamic
	{
		var coverMeInPiss:Dynamic = getObjectDirectly(killMe[0], checkForTextsToo);
		var end = killMe.length;
		if(getProperty)end=killMe.length-1;

		for (i in 1...end) {
			coverMeInPiss = getVarInArray(coverMeInPiss, killMe[i]);
		}
		return coverMeInPiss;
	}

	public static function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true):Dynamic
	{
		var coverMeInPiss:Dynamic = PlayState.instance.getLuaObject(objectName, checkForTextsToo);
		if(coverMeInPiss==null)
			coverMeInPiss = getVarInArray(getInstance(), objectName);

		return coverMeInPiss;
	}


	#if LUA_ALLOWED
	function resultIsAllowed(leLua:State, leResult:Null<Int>) { //Makes it ignore warnings
		var type:Int = Lua.type(leLua, leResult);
		return type >= Lua.LUA_TNIL && type < Lua.LUA_TTABLE && type != Lua.LUA_TLIGHTUSERDATA;
	}

	function isErrorAllowed(error:String) {
		switch(error)
		{
			case 'attempt to call a nil value' | 'C++ exception':
				return false;
		}
		return true;
	}
	#end

	public function set(variable:String, data:Dynamic) {
		#if LUA_ALLOWED
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
		#end
	}

	#if LUA_ALLOWED
	public function getBool(variable:String) {
		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if(result == null) {
			return false;
		}
		return (result == 'true');
	}
	#end

	public function stop() {
		#if LUA_ALLOWED
		if(lua == null) {
			return;
		}

		hscript = null;
		Lua.close(lua);
		lua = null;
		#end
	}

	public static inline function getInstance()
	{
		return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
	}
}

class ModchartSprite extends FlxSprite
{
	public var wasAdded:Bool = false;
	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	//public var isInFront:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
		antialiasing = ClientPrefs.globalAntialiasing;
	}
}

class ModchartText extends FlxText
{
	public var wasAdded:Bool = false;
	public function new(x:Float, y:Float, text:String, width:Float)
	{
		super(x, y, width, text, 16);
		setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		cameras = [PlayState.instance.camHUD];
		scrollFactor.set();
		borderSize = 2;
	}
}

final class ModchartGroup extends FlxTypedSpriteGroup<ModchartSprite>
{
	public var wasAdded:Bool;
	public function new(x:Float, y:Float, maxSize:Int)
	{
		super(x, y, maxSize);

		antialiasing = ClientPrefs.globalAntialiasing;
	}
}

class DebugLuaText extends FlxText
{
	private var disableTime:Float = 6;
	public var parentGroup:FlxTypedGroup<DebugLuaText>;
	public function new(text:String, parentGroup:FlxTypedGroup<DebugLuaText>, color:FlxColor) {
		this.parentGroup = parentGroup;
		super(10, 10, 0, text, 16);
		setFormat(Paths.font("vcr.ttf"), 20, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		disableTime -= elapsed;
		if(disableTime < 0) disableTime = 0;
		if(disableTime < 1) alpha = disableTime;
	}
}

class CustomSubstate extends MusicBeatSubstate
{
	public static var name:String = 'unnamed';
	public static var instance:CustomSubstate;

	override function create()
	{
		instance = this;

		PlayState.instance.callOnLuas('onCustomSubstateCreate', [name]);
		super.create();
		PlayState.instance.callOnLuas('onCustomSubstateCreatePost', [name]);
	}
	
	public function new(name:String)
	{
		CustomSubstate.name = name;
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	override function update(elapsed:Float)
	{
		PlayState.instance.callOnLuas('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		PlayState.instance.callOnLuas('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy()
	{
		PlayState.instance.callOnLuas('onCustomSubstateDestroy', [name]);
		super.destroy();
	}
}

#if hscript
class HScript
{
	static var parser:Parser = new Parser();
	public var interp:Interp;

	public function new()
	{
		interp = new Interp();
		setVars();
	}

	public function setVar(key:String, data:Dynamic):Map<String, Dynamic>
	{
		FunkinLua.hscriptVars.set(key, data);
		return interp.variables = FunkinLua.hscriptVars.copy();
	}

	public function call(key:String, args:Array<Dynamic>):Dynamic
	{
		if (!interp.variables.exists(key))
			return -1;

		var functionField:Function = interp.variables.get(key);
		return Reflect.callMethod(this, functionField, args);
	}

	public function execute(codeToRun:String):Dynamic
	{
		@:privateAccess
		HScript.parser.line = 1;
		HScript.parser.allowTypes = true;
		return interp.execute(HScript.parser.parseString(codeToRun));
	}

	public function setVars():Void
	{
		setVar('FlxG', FlxG);
		setVar('FlxSprite', FlxSprite);
		setVar('FlxCamera', FlxCamera);
		setVar('FlxTimer', FlxTimer);
		setVar('FlxTween', FlxTween);
		setVar('FlxEase', FlxEase);
		setVar('PlayState', PlayState);
		setVar('game', PlayState.instance);
		setVar('Paths', Paths);
		setVar('Conductor', Conductor);
		setVar('ClientPrefs', ClientPrefs);
		setVar('Character', Character);
		setVar('Alphabet', Alphabet);
		setVar('CustomSubstate', CustomSubstate);
		#if !flash
		setVar('FlxRuntimeShader', FlxRuntimeShader);
		setVar('ShaderFilter', openfl.filters.ShaderFilter);
		#end
		setVar('StringTools', StringTools);

		setVar('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		setVar('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		setVar('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
	}
}
#end