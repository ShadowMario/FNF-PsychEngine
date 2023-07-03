package psychlua;

#if hscript
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
#end

#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

import haxe.Exception;

import objects.Character;

class HScript
{
	#if hscript
	public static var parser:Parser = new Parser();
	public var interp:Interp;

	public var variables(get, never):Map<String, Dynamic>;
	public var parentLua:FunkinLua;

	public function get_variables()
	{
		return interp.variables;
	}
	
	public static function initHaxeModule(parent:FunkinLua)
	{
		#if hscript
		if(parent.hscript == null)
		{
			//trace('initializing haxe interp for: $scriptName');
			parent.hscript = new HScript(parent); //TO DO: Fix issue with 2 scripts not being able to use the same variable names
		}
		#end
	}

	public function new(parent:FunkinLua)
	{
		interp = new Interp();
		parentLua = parent;
		interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Conductor', Conductor);
		interp.variables.set('ClientPrefs', ClientPrefs);
		interp.variables.set('Character', Character);
		interp.variables.set('Alphabet', Alphabet);
		interp.variables.set('CustomSubstate', psychlua.CustomSubstate);
		#if (!flash && sys)
		interp.variables.set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		interp.variables.set('ShaderFilter', openfl.filters.ShaderFilter);
		interp.variables.set('StringTools', StringTools);

		interp.variables.set('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		interp.variables.set('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		interp.variables.set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
		interp.variables.set('debugPrint', function(text:String, ?color:FlxColor = null) {
			if(color == null) color = FlxColor.WHITE;
			parentLua.luaTrace(text, true, false, color);
		});

		// For adding your own callbacks
		interp.variables.set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if(funk == null) funk = parentLua;
			Lua_helper.add_callback(funk.lua, name, func);
		});
		interp.variables.set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				interp.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				parentLua.luaTrace(parentLua.scriptName + ":" + parentLua.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
		});
		interp.variables.set('parentLua', parentLua);
	}

	public function execute(codeToRun:String, ?funcToRun:String = null, ?funcArgs:Array<Dynamic>):Dynamic
	{
		@:privateAccess
		parser.line = 1;
		parser.allowTypes = true;
		var expr:Expr = parser.parseString(codeToRun);
		try {
			var value:Dynamic = interp.execute(parser.parseString(codeToRun));
			return (funcToRun != null) ? executeFunction(funcToRun, funcArgs) : value;
		}
		catch(e:Exception)
		{
			trace(e);
			return null;
		}
	}

	public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic>)
	{
		if(funcToRun != null)
		{
			//trace('Executing $funcToRun');
			if(interp.variables.exists(funcToRun))
			{
				//trace('$funcToRun exists, executing...');
				if(funcArgs == null) funcArgs = [];
				return Reflect.callMethod(null, interp.variables.get(funcToRun), funcArgs);
			}
		}
		return null;
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		Lua_helper.add_callback(lua, "runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null) {
			var retVal:Dynamic = null;

			#if hscript
			HScript.initHaxeModule(funk);
			try {
				if(varsToBring != null)
				{
					for (key in Reflect.fields(varsToBring))
					{
						//trace('Key $key: ' + Reflect.field(varsToBring, key));
						funk.hscript.interp.variables.set(key, Reflect.field(varsToBring, key));
					}
				}
				retVal = funk.hscript.execute(codeToRun, funcToRun, funcArgs);
			}
			catch (e:Dynamic) {
				funk.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#else
			funk.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end

			if(retVal != null && !LuaUtils.isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
			return retVal;
		});
		
		Lua_helper.add_callback(lua, "runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			try {
				return funk.hscript.executeFunction(funcToRun, funcArgs);
			}
			catch(e:Exception)
			{
				funk.luaTrace(Std.string(e));
				return null;
			}
		});

		Lua_helper.add_callback(lua, "addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			#if hscript
			HScript.initHaxeModule(funk);
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				funk.hscript.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				funk.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#end
		});
		#end
	}
	#end
}