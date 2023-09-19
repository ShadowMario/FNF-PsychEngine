package psychlua;

import flixel.FlxBasic;
import objects.Character;
import psychlua.FunkinLua;
import psychlua.CustomSubstate;

#if HSCRIPT_ALLOWED
import hscript.Parser;
import hscript.Interp;
#end

class HScript
#if HSCRIPT_ALLOWED extends Interp #end
{
	public var active:Bool = true;

	public var parser:#if HSCRIPT_ALLOWED Parser #else Dynamic #end;

	public var parentLua:FunkinLua;

	public var exception:haxe.Exception;

	public static function initHaxeModule(parent:FunkinLua)
	{
		#if HSCRIPT_ALLOWED
		if(parent.hscript == null) {
			var times:Float = Date.now().getTime();
			parent.hscript = new HScript(parent);
			trace('initialized hscript interp successfully: ${parent.scriptName} (${Std.int(Date.now().getTime() - times)}ms)');
		}
		#end
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String)
	{
		initHaxeModule(parent);
		if (parent.hscript != null)
			parent.hscript.executeCode(code);
	}

	public static function hscriptTrace(text:String, color:FlxColor = FlxColor.WHITE) {
		PlayState.instance.addTextToDebug(text, color);
		trace(text);
	}

	public var origin:String;
	public function new(?parent:FunkinLua, ?file:String) {
		#if HSCRIPT_ALLOWED
		super();

		var content:String = null;
		if (file != null)
			content = Paths.getTextFromFile(file, false, true);

		parentLua = parent;
		if (parent != null)
			origin = parent.scriptName;
		if (content != null)
			origin = file;

		preset();
		executeCode(content);
		#end
	}

	function preset()
	{
		#if HSCRIPT_ALLOWED
		parser = new Parser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		scriptObject = PlayState.instance; // allow use vars from playstate without "game" thing

		// Some very commonly used classes
		setVar('FlxG', flixel.FlxG);
		setVar('FlxSprite', flixel.FlxSprite);
		setVar('FlxCamera', flixel.FlxCamera);
		setVar('FlxTimer', flixel.util.FlxTimer);
		setVar('FlxTween', flixel.tweens.FlxTween);
		setVar('FlxEase', flixel.tweens.FlxEase);
		setVar('FlxColor', CustomFlxColor);
		setVar('PlayState', PlayState);
		setVar('Paths', Paths);
		setVar('Conductor', Conductor);
		setVar('ClientPrefs', ClientPrefs);
		setVar('Character', Character);
		setVar('Alphabet', Alphabet);
		setVar('Note', objects.Note);
		setVar('CustomSubstate', CustomSubstate);
		setVar('Countdown', backend.BaseStage.Countdown);
		#if (!flash && sys)
		setVar('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		setVar('ShaderFilter', openfl.filters.ShaderFilter);
		setVar('StringTools', StringTools);

		// Functions & Variables
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
		setVar('debugPrint', function(text:String, ?color:FlxColor = null) {
			if(color == null) color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		});

		// For adding your own callbacks

		// not very tested but should work
		setVar('createGlobalCallback', function(name:String, func:Dynamic)
		{
			#if LUA_ALLOWED
			for (script in PlayState.instance.luaArray)
				if(script != null && script.lua != null && !script.closed)
					script.set(name, func);
			#end
			FunkinLua.customFunctions.set(name, func);
		});

		// tested
		setVar('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if(funk == null) funk = parentLua;
			
			if(parentLua != null) funk.addLocalCallback(name, func);
			else FunkinLua.luaTrace('createCallback ($name): 3rd argument is null', false, false, FlxColor.RED);
		});

		setVar('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			var str:String = '';
			if(libPackage.length > 0)
				str = libPackage + '.';

			setVar(libName, resolveClassOrEnum(str + libName));
		});
		setVar('parentLua', parentLua);
		setVar('this', this);
		setVar('game', PlayState.instance); // useless cuz u can get vars directly, backward compatibility ig
		setVar('buildTarget', FunkinLua.getBuildTarget());
		setVar('customSubstate', CustomSubstate.instance);
		setVar('customSubstateName', CustomSubstate.name);

		setVar('Function_Stop', FunkinLua.Function_Stop);
		setVar('Function_Continue', FunkinLua.Function_Continue);
		setVar('Function_StopLua', FunkinLua.Function_StopLua); //doesnt do much cuz HScript has a lower priority than Lua
		setVar('Function_StopHScript', FunkinLua.Function_StopHScript);
		setVar('Function_StopAll', FunkinLua.Function_StopAll);
		#end
	}

	public function executeCode(?codeToRun:String):Dynamic {
		#if HSCRIPT_ALLOWED
		if (codeToRun == null || !active) return null;

		try {
			return execute(parser.parseString(codeToRun, origin));
		}
		catch(e)
			exception = e;
		#end
		return null;
	}

	public function executeFunction(?funcToRun:String, ?funcArgs:Array<Dynamic>):Dynamic {
		#if HSCRIPT_ALLOWED
		if (funcToRun == null || !active) return null;

		if (variables.exists(funcToRun)) {
			if (funcArgs == null) funcArgs = [];
			try {
				return Reflect.callMethod(null, variables.get(funcToRun), funcArgs);
			}
			catch(e)
				exception = e;
		}
		#end
		return null;
	}

	public static function implement(funk:FunkinLua)
	{
		#if (LUA_ALLOWED && HSCRIPT_ALLOWED)
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
			initHaxeModule(funk);
			if (!funk.hscript.active) return null;

			if(varsToBring != null) {
				for (key in Reflect.fields(varsToBring)) {
					//trace('Key $key: ' + Reflect.field(varsToBring, key));
					funk.hscript.setVar(key, Reflect.field(varsToBring, key));
				}
			}

			var retVal:Dynamic = funk.hscript.executeCode(codeToRun);
			if (funcToRun != null) {
				var retFunc:Dynamic = funk.hscript.executeFunction(funcToRun, funcArgs);
				if (retFunc != null)
					retVal = retFunc;
			}

			if (funk.hscript.exception != null) {
				funk.hscript.active = false;
				FunkinLua.luaTrace('ERROR (${funk.lastCalledFunction}) - ${funk.hscript.exception}', false, false, FlxColor.RED);
			}

			return retVal;
		});

		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic>) {
			if (!funk.hscript.active) return null;

			var retVal:Dynamic = funk.hscript.executeFunction(funcToRun, funcArgs);

			if (funk.hscript.exception != null) {
				funk.hscript.active = false;
				FunkinLua.luaTrace('ERROR (${funk.lastCalledFunction}) - ${funk.hscript.exception}', false, false, FlxColor.RED);
			}

			return retVal;
		});
		// This function is unnecessary because import already exists in hscript-improved as a native feature
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			initHaxeModule(funk);
			if (!funk.hscript.active) return;

			var str:String = '';
			if(libPackage.length > 0)
				str = libPackage + '.';
			else if(libName == null)
				libName = '';

			var c:Dynamic = funk.hscript.resolveClassOrEnum(str + libName);

			try {
				funk.hscript.setVar(libName, c);
			}
			catch(e) {
				funk.hscript.active = false;
				FunkinLua.luaTrace('ERROR (${funk.lastCalledFunction}) - $e', false, false, FlxColor.RED);
			}
		});
		#end
	}

	function resolveClassOrEnum(name:String):Dynamic {
		var c:Dynamic = Type.resolveClass(name);
		if (c == null)
			c = Type.resolveEnum(name);
		return c;
	}

	public function destroy() {
		active = false;
		parser = null;
		origin = null;
		parentLua = null;
		#if HSCRIPT_ALLOWED
		__instanceFields = [];
		binops.clear();
		customClasses.clear();
		declared = [];
		importBlocklist = [];
		locals.clear();
		resetVariables();
		#end
	}
}

#if HSCRIPT_ALLOWED
class CustomFlxColor
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	public static function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
}
#end