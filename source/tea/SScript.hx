package tea;

import ex.*;
import haxe.Exception;
import haxe.Timer;
import hscriptBase.*;
import hscriptBase.Expr;
#if openflPos
import openfl.Assets;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import tea.backend.*;
import tea.backend.crypto.Base32;

using StringTools;

typedef SCall =
{
	public var ?fileName(default, null):String;
	public var ?className(default, null):String;
	public var succeeded(default, null):Bool;
	public var calledFunction(default, null):String;
	public var returnValue(default, null):Null<Dynamic>;
	public var exceptions(default, null):Array<Exception>;
}

/**
	The base class for dynamic Haxe scripts.

	A SScript can be a class script or a Haxe Script. 

	Once a SScript instance is created, it can't switch back to a class or Haxe script.
**/
@:structInit
@:access(hscriptBase.Interp)
@:access(hscriptBase.Parser)
@:access(tea.backend.SScriptX)
@:access(tea.backend.PrinterTool)
@:access(ScriptClass)
@:access(AbstractScriptClass)
class SScript
{
	/**
		SScript version abstract, used for version checker.  
	**/
	public static var VERSION(default, null):SScriptVer = new SScriptVer(4, 1, 0);

	/**
		If not null, assigns all scripts to check or ignore type declarations.
	**/
	public static var defaultTypeCheck(default, set):Null<Bool> = true;

	/**
		If not null, switches EX mode support for all scripts.
	**/
	public static var defaultClassSupport(default, set):Null<Bool> = null;

	/**
		If not null, switches traces from `doString` and `new()`. 
	**/
	public static var defaultDebug(default, set):Null<Bool> = #if debug true #else null #end;

	#if openflPos
	/**
		`WARNING`: For `openfl` targets, you need to clear this map before switching states otherwise this map
		will cause memory leaks!

		This map is used for Ex scripts (scripts with classes).

		If a class is extended, this map will be checked if there is an instance of the super class.
		If an instance is found, the instance will be used for super class.

		Example:

		```haxe
		var tea:SScript = {};
		var superClass:ExampleClass = new ExampleClass();
		SScript.superClassInstances["ExampleClass"] = superClass;
		tea.doString('class ChildClass extends ExampleClass {}'); // Variable `superClass` is used for this script.
		```
	**/
	#else
	/**
		This map is used for Ex scripts (scripts with classes).

		If a class is extended, this map will be checked if there is an instance of the super class.
		If an instance is found, the instance will be used for super class.

		Example:

		```haxe
		var tea:SScript = {};
		var superClass:ExampleClass = new ExampleClass();
		SScript.superClassInstances["ExampleClass"] = superClass;
		tea.doString('class ChildClass extends ExampleClass {}'); // Variable `superClass` is used for this script.
		```
	**/
	#end
	public static var superClassInstances(default, null):Map<String, Dynamic> = [];

	#if openflPos
	/**
		Variables in this map will be set to every SScript instance. 

		You need to clear this map at every state switch to avoid memory leaks!
	**/
	#else
	/**
		Variables in this map will be set to every SScript instance. 
	**/
	#end
	public static var globalVariables:Map<String, Dynamic> = [];

	/**
		Every created SScript will be mapped to this map. 
	**/
	public static var global(default, null):Map<String, SScript> = [];

	static var BlankReg(get, never):EReg;

	#if hscriptPos
	/**
		This is a custom origin you can set.

		If not null, this will act as file path.
	**/
	public var customOrigin(default, set):String;
	#end

	/**
		Script's own return value.

		This is not to be messed up with function's return value.
	**/
	public var returnValue(default, null):Null<Dynamic>;

	/**
		Whether the type checker should be enabled.
	**/
	public var typeCheck:Bool = false;

	/**
		Whether EX mode support should be enabled.
	**/
	public var classSupport:Bool = false;

	/**
		Reports how many seconds it took to execute this script. 

		It will be -1 if it failed to execute.
	**/
	public var lastReportedTime(default, null):Float = -1;

	/**
		Report how many seconds it took to call the latest function in this script.

		It will be -1 if it failed to execute.
	**/
	public var lastReportedCallTime(default, null):Float = -1;

	/**
		Used in `set`. If a class is set in this script while being in this array, an exception will be thrown.
	**/
	public var notAllowedClasses(default, null):Array<Class<Dynamic>> = [];

	/**
		Use this to access to interpreter's variables!
	**/
	public var variables(get, never):Map<String, Dynamic>;

	/**
		Main interpreter and executer. 

		Do not use `interp.variables.set` to set variables!
		Instead, use `set`.
	**/
	public var interp(default, null):Interp;

	/**
		An unique parser for the script to parse strings.
	**/
	public var parser(default, null):Parser;

	/**
		The script to execute. Gets set automatically if you create a `new` SScript.
	**/
	public var script(default, null):String = "";

	/**
		This variable tells if this script is active or not.

		Set this to false if you do not want your script to get executed!
	**/
	public var active:Bool = true;

	/**
		This string tells you the path of your script file as a read-only string.
	**/
	public var scriptFile(default, null):String = "";

	/**
		If true, enables error traces from the functions.
	**/
	public var traces:Bool = false;

	/**
		If true, enables some traces from `doString` and `new()`.
	**/
	public var debugTraces:Bool = false;

	/**
		Tells if this script is in EX mode, in EX mode you can only use `class`, `import` and `package`.
	**/
	public var exMode(get, never):Bool;

	/**
		Package path of this script. Gets set automatically when you use `package`.
	**/
	public var packagePath(get, null):String = "";

	/**
		A list of classes in the current script.

		Will be null if there are no classes in this script.
	**/
	public var classes(get, never):Map<String, AbstractScriptClass>;

	/**
		The name of the current class in this script.

		When a script created, `currentClass` becomes the first class in that script (if there are any classes in script).
	**/
	public var currentClass(get, set):String;

	/**
		Reference to script class in this script.

		To change, change `currentClass`.
	**/
	public var currentScriptClass(get, never):AbstractScriptClass;

	/**
		Reference to super class of `currentScriptClass`.
	**/
	public var currentSuperClass(get, never):Class<Dynamic>;

	@:noPrivateAccess static var defines(default, null):Map<String, String>;

	var parsingExceptions(default, null):Array<Exception> = new Array();
	@:noPrivateAccess var scriptX(default, null):SScriptX;
	@:noPrivateAccess var _destroyed(default, null):Bool;

	/**
		Creates a new SScript instance.

		@param scriptPath The script path or the script itself (Files are recommended).
		@param Preset If true, SScript will set some useful variables to interp. Override `preset` to customize the settings.
		@param startExecute If true, script will execute itself. If false, it will not execute.	
	**/
	public function new(?scriptPath:String = "", ?preset:Bool = true, ?startExecute:Bool = true)
	{
		var time = Timer.stamp();

		#if sys
		if (defines == null)
		{
			defines = new Map();

			var contents:String = null;
			var path:String = macro.Macro.definePath;

			if (FileSystem.exists(path))
			{
				contents = new Base32().decodeString(File.getContent(path));
				FileSystem.deleteFile(path);

				for (i in contents.split('\n'))
				{
					i = i.trim();

					var d1 = null, d2 = null;
					var define:Array<String> = i.split('|');
					if (define.length == 2)
					{
						d1 = define[0];
						d2 = define[1];
					}
					else if (define.length == 1)
					{
						d1 = define[0];
						d2 = '1';
					}

					if (d1 != null)
						defines[d1] = d2 != null ? d2 : '1';
				}
			}
			else
			{
				defines["true"] = "1";
				defines["haxe"] = "1";
				defines["sys"] = "1";

				#if hscriptPos
				defines["hscriptPos"] = "1";
				#end
			}
		}
		#else
		if (defines == null)
			defines = new Map();

		defines["true"] = "1";
		defines["haxe"] = "1";

		#if hscriptPos
		defines["hscriptPos"] = "1";
		#end
		#end

		if (defaultTypeCheck != null)
			typeCheck = defaultTypeCheck;
		if (defaultClassSupport != null)
			classSupport = defaultClassSupport;
		if (defaultDebug != null)
			debugTraces = defaultDebug;

		interp = new Interp();
		interp.typecheck = typeCheck;
		interp.setScr(this);

		parser = new Parser();
		parser.script = this;
		parser.setIntrp(interp);
		interp.setPsr(parser);

		if (preset)
			this.preset();

		for (i => k in globalVariables)
			if (i != null)
				set(i, k);

		try
		{
			doFile(scriptPath);
			if (startExecute)
				execute();

			if (scriptX != null)
			{
				if (scriptX.scriptFile != null && scriptX.scriptFile.length > 0)
					global[scriptX.scriptFile] = this;
			}
			else if (scriptFile != null && scriptFile.length > 0)
				global[scriptFile] = this;
			else if (script != null && script.length > 0)
				global[script] = this;

			lastReportedTime = Timer.stamp() - time;

			if (debugTraces && scriptPath != null && scriptPath.length > 0)
			{
				if (lastReportedTime == 0)
					trace('SScript instance created instantly (0s)');
				else
					trace('SScript instance created in ${lastReportedTime}s');
			}
		}
		catch (e)
		{
			lastReportedTime = -1;
		}
	}

	/**
		Executes this script once.

		Executing scripts with classes will not do anything.
	**/
	public function execute():Void
	{
		if (_destroyed)
			return;

		if (scriptX != null)
			return;

		if (interp == null || !active)
			return;

		var origin:String =
			#if hscriptPos
			{
				if (customOrigin != null && customOrigin.length > 0)
					customOrigin;
				else if (scriptFile != null && scriptFile.length > 0)
					scriptFile;
				else
					"SScript";
			}
			#else
			null
			#end;

		if (script != null && script.length > 0)
		{
			var expr:Expr = parser.parseString(script #if hscriptPos, origin #end);
			var r = interp.execute(expr);
			returnValue = r;
		}
	}

	/**
		Sets a variable to this script. 

		If `key` already exists it will be replaced.
		@param key Variable name.
		@param obj The object to set. If the object is a macro class, function will be aborted.
		@return Returns this instance for chaining.
	**/
	public function set(key:String, obj:Dynamic):SScript
	{
		if (_destroyed)
			return null;

		if (obj != null && (obj is Class) && notAllowedClasses.contains(obj))
			throw 'Tried to set ${Type.getClassName(obj)} which is not allowed.';

		function setVar(key:String, obj:Dynamic):Void
		{
			if (key == null)
				return;

			if (Tools.keys.contains(key))
				throw '$key is a keyword, set something else';
			else if (obj != null && macro.Macro.macroClasses.contains(obj))
				throw '$key cannot be a Macro class (tried to set ${Type.getClassName(obj)})';

			if (classSupport)
				SScriptX.variables[key] = obj;

			if (scriptX != null)
			{
				var value:Dynamic = obj;
				scriptX.set(key, value);
			}
			else
			{
				if (interp == null || !active)
				{
					if (traces)
					{
						if (interp == null)
							trace("This script is unusable!");
						else
							trace("This script is not active!");
					}
				}
				else
					interp.variables[key] = obj;
			}
		}

		setVar(key, obj);
		return this;
	}

	/**
		This is a helper function to set classes easily.
		For example; if `cl` is `sys.io.File` class, it'll be set as `File`.
		@param cl The class to set. It cannot be macro classes.
		@return this instance for chaining.
	**/
	public function setClass(cl:Class<Dynamic>):SScript
	{
		if (_destroyed)
			return null;

		if (cl == null)
		{
			if (traces)
			{
				trace('Class cannot be null');
			}

			return null;
		}

		var clName:String = Type.getClassName(cl);
		if (clName != null)
		{
			var splitCl:Array<String> = clName.split('.');
			if (splitCl.length > 1)
			{
				clName = splitCl[splitCl.length - 1];
			}

			set(clName, cl);
		}
		return this;
	}

	/**
		Sets a class to this script from a string.
		`cl` will be formatted, for example: `sys.io.File` -> `File`.
		@param cl The class to set. It cannot be macro classes.
		@return this instance for chaining.
	**/
	public function setClassString(cl:String):SScript
	{
		if (_destroyed)
			return null;

		if (cl == null || cl.length < 1)
		{
			if (traces)
				trace('Class cannot be null');

			return null;
		}

		var cls:Class<Dynamic> = Type.resolveClass(cl);
		if (cls != null)
		{
			if (cl.split('.').length > 1)
			{
				cl = cl.split('.')[cl.split('.').length - 1];
			}

			set(cl, cls);
		}
		return this;
	}

	/**
		Returns the local variables in this script as a fresh map.

		Changing any value in returned map will not change the script's variables.
	**/
	public function locals():Map<String, Dynamic>
	{
		if (_destroyed)
			return null;

		if (scriptX != null)
		{
			var newMap:Map<String, Dynamic> = new Map();
			if (scriptX.interpEX.locals != null)
				for (i in scriptX.interpEX.locals.keys())
				{
					var v = scriptX.interpEX.locals[i];
					if (v != null)
						newMap[i] = v.r;
				}
			return newMap;
		}

		var newMap:Map<String, Dynamic> = new Map();
		for (i in interp.locals.keys())
		{
			var v = interp.locals[i];
			if (v != null)
				newMap[i] = v.r;
		}
		return newMap;
	}

	/**
		Unsets a variable from this script. 

		If a variable named `key` doesn't exist, unsetting won't do anything.
		@param key Variable name to unset.
		@return Returns this instance for chaining.
	**/
	public function unset(key:String):SScript
	{
		if (_destroyed)
			return null;

		if (scriptX != null)
		{
			scriptX.interpEX.variables.remove(key);
			SScriptX.variables.remove(key);
			for (i in InterpEx.interps)
			{
				if (i.variables != null && i.variables.exists(key))
					i.variables.remove(key);
				else if (i.locals != null && i.locals.exists(key))
					i.locals.remove(key);
			}
		}
		else
		{
			if (interp == null || !active || key == null || !interp.variables.exists(key))
				return null;

			interp.variables.remove(key);
		}

		return this;
	}

	/**
		Gets a variable by name. 

		If a variable named as `key` does not exists return is null.
		@param key Variable name.
		@return The object got by name.
	**/
	public function get(key:String):Dynamic
	{
		if (_destroyed)
			return null;

		if (scriptX != null)
		{
			return
			{
				var l = locals();
				if (l.exists(key))
					l[key];
				else if (scriptX.interpEX.variables.exists(key))
					scriptX.interpEX.variables[key];
				else if (classes != null) // script with classes will return hscriptBase.Expr if a function is searched
				{
					for (k => i in classes)
					{
						if (i != null && i.listFunctions().exists(key) && i.listFunctions()[key] != null)
							return '#fun';
					}
					null;
				}
				else if (SScriptX.variables.exists(key))
					SScriptX.variables[key];
				else
					null;
			}
		}

		if (interp == null || !active)
		{
			if (traces)
			{
				if (interp == null)
					trace("This script is unusable!");
				else
					trace("This script is not active!");
			}

			return null;
		}

		var l = locals();
		if (l.exists(key))
			return l[key];

		return if (exists(key)) interp.variables[key] else null;
	}

	/**
		Calls a function from the script file.

		`WARNING:` You MUST execute the script at least once to get the functions to script's interpreter.
		If you do not execute this script and `call` a function, script will ignore your call.

		@param func Function name in script file. 
		@param args Arguments for the `func`. If the function does not require arguments, leave it null.
		@param className If provided, searches the specific class. If the function is not found, other classes will be searched.
		@return Returns an unique structure that contains called function, returned value etc. Returned value is at `returnValue`.
	**/
	public function call(func:String, ?args:Array<Dynamic>, ?className:String):SCall
	{
		if (_destroyed)
			return null;

		var time:Float = Timer.stamp();

		var scriptFile:String = if (scriptFile != null && scriptFile.length > 0) scriptFile else "";
		var caller:SCall = {
			exceptions: [],
			calledFunction: func,
			succeeded: false,
			returnValue: null
		}
		if (scriptFile != null && scriptFile.length > 0)
			caller = {
				fileName: scriptFile,
				exceptions: [],
				calledFunction: func,
				succeeded: false,
				returnValue: null
			}
		if (args == null)
			args = new Array();

		var pushedExceptions:Array<String> = new Array();
		function pushException(e:String)
		{
			if (!pushedExceptions.contains(e))
				caller.exceptions.push(new Exception(e));

			pushedExceptions.push(e);
		}
		if (func == null)
		{
			if (traces)
				trace('Function name cannot be null for $scriptFile!');

			pushException('Function name cannot be null for $scriptFile!');
			return caller;
		}
		var callX:SCall = null;
		if (scriptX != null)
		{
			callX = scriptX.callFunction(func);
		}
		else
		{
			if (exists(func) && Type.typeof(get(func)) != TFunction)
			{
				if (traces)
					trace('$func is not a function');

				pushException('$func is not a function');
			}
			else if (interp == null || !exists(func))
			{
				if (interp == null)
				{
					if (traces)
						trace('Interpreter is null!');

					pushException('Interpreter is null!');
				}
				else
				{
					if (traces)
						trace('Function $func does not exist in $scriptFile.');

					if (scriptFile != null && scriptFile.length > 1)
						pushException('Function $func does not exist in $scriptFile.');
					else
						pushException('Function $func does not exist in SScript instance.');
				}
			}
			else
			{
				var oldCaller = caller;
				try
				{
					var functionField:Dynamic = Reflect.callMethod(this, get(func), args);
					caller = {
						exceptions: caller.exceptions,
						calledFunction: func,
						succeeded: true,
						returnValue: functionField
					};
					if (scriptFile != null && scriptFile.length > 0)
						caller = {
							fileName: scriptFile,
							exceptions: caller.exceptions,
							calledFunction: func,
							succeeded: true,
							returnValue: functionField
						};
				}
				catch (e)
				{
					caller = oldCaller;
					pushException(e.details());
				}
			}
		}
		lastReportedCallTime = Timer.stamp() - time;

		if (!caller.succeeded && (callX == null || !callX.succeeded))
		{
			lastReportedCallTime = -1;
			for (i in parsingExceptions)
			{
				pushException(i.details());

				if (callX != null)
					callX.exceptions.push(new Exception(i.details()));
			}
		}

		return if (scriptX != null) callX else caller;
	}

	/**
		Clears all of the keys assigned to this script.

		@return Returns this instance for chaining.
	**/
	public function clear():SScript
	{
		if (_destroyed)
			return null;

		if (scriptX != null)
		{
			scriptX.interpEX.variables = new Map();
			return this;
		}

		if (interp == null)
			return this;

		var importantThings:Array<String> = ['true', 'false', 'null', 'trace'];

		for (i in interp.variables.keys())
			if (!importantThings.contains(i))
				interp.variables.remove(i);

		return this;
	}

	/**
		Tells if the `key` exists in this script's interpreter.
		@param key The string to look for.
		@return Returns true if `key` is found in interpreter.
	**/
	public function exists(key:String):Bool
	{
		if (_destroyed)
			return false;

		if (scriptX != null)
		{
			if (scriptX.currentScriptClass != null
				&& scriptX.currentScriptClass.listFunctions() != null
				&& scriptX.currentScriptClass.listFunctions().exists(key))
				return true;

			var l = locals();
			var v = scriptX.interpEX.variables;
			return if (l != null && l.exists(key)) true else if (v != null && v.exists(key)) true else false;
		}

		if (interp == null)
			return false;
		var l = locals();
		if (l.exists(key))
			return l.exists(key);

		return interp.variables.exists(key);
	}

	/**
		Sets some useful variables to interp to make easier using this script.
		Override this function to set your custom sets aswell.
	**/
	public function preset():Void
	{
		if (_destroyed)
			return;

		setClass(Date);
		setClass(DateTools);
		setClass(Math);
		setClass(Std);
		setClass(SScript);
		setClass(StringTools);

		#if sys
		setClass(File);
		setClass(FileSystem);
		setClass(Sys);
		#end

		#if openflPos
		setClass(Assets);
		#end

		set('this', this);
		/*set('getDefine', function(def:String):String
			{
				if (defines == null)
					return null;
				if (!defines.exists(def))
					return null;

				return defines[def];
		});*/
	}

	function doFile(scriptPath:String):Void
	{
		if (_destroyed)
			return;

		if (scriptPath == null || scriptPath.length < 1 || BlankReg.match(scriptPath))
			return;

		if (classSupport)
		{
			if (scriptPath != null && scriptPath.length > 0)
				try
					scriptX = new SScriptX(scriptPath, this)
				catch (e)
				{
					parsingExceptions.push(new Exception(e.details()));
					scriptX = null;
				}
		}

		if (scriptPath != null && scriptPath.length > 0)
		{
			#if sys
			#if openflPos
			if (Assets.exists(scriptPath))
			{
				scriptFile = scriptPath;
				script = Assets.getText(scriptPath);
			}
			if (FileSystem.exists(scriptPath))
			{
				scriptFile = scriptPath;
				script = File.getContent(scriptPath);
			}
			#else
			if (Assets.exists(scriptPath))
			{
				scriptFile = scriptPath;
				script = Assets.getText(scriptPath);
			}
			#end
			else
			{
				scriptFile = "";
				script = scriptPath;
			}
			#else
			#if openflPos
			if (Assets.exists(scriptPath))
			{
				scriptFile = scriptPath;
				script = Assets.getText(scriptPath);
			}
			else
			{
				script = scriptPath;
				scriptFile = "";
			}
			#else
			script = scriptPath;
			scriptFile = "";
			#end
			#end
		}
	}

	/**
		Executes a string once instead of a script file.

		This does not change your `scriptFile` but it changes `script`.

		Even though this function is faster,
		it should be avoided whenever possible.
		Always try to use a script file.
		@param string String you want to execute.
		@param origin Optional origin to use for this script, it will appear on traces.
		@return Returns this instance for chaining. Will return `null` if failed.
	**/
	public function doString(string:String #if hscriptPos, ?origin:String #end):SScript
	{
		if (_destroyed)
			return null;

		var time = Timer.stamp();
		try
		{
			#if hscriptPos
			var og:String = origin;
			if (og != null && og.length > 0)
				customOrigin = og;
			if (og == null || og.length < 1)
				og = "SScript";
			#end
			if (string == null || string.length < 1 || BlankReg.match(string))
				return this;
			#if sys
			else
				#if openflPos if (Assets.exists(string) || FileSystem.exists(string)) #else if (FileSystem.exists(string)) #end
			{
				#if hscriptPos
				og = "" + string;
				#end
				scriptFile = string;
				string = File.getContent(string);
			}
			#elseif openflPos
			if (Assets.exists(string))
			{
				#if hscriptPos
				og = "" + string;
				#end
				scriptFile = string;
				string = Assets.getText(string);
			}
			#end
			if (scriptX != null)
			{
				global[string] = this;

				scriptX.doString(string #if hscriptPos, og #end);
				return this;
			}
			if (!active || interp == null)
				return null;

			if (scriptX == null)
			{
				try
				{
					script = string;

					if (script != null && script.length > 0)
						global[script] = this;

					var expr:Expr = parser.parseString(script #if hscriptPos, og #end);
					var r = interp.execute(expr);
					returnValue = r;
				}
				catch (e)
				{
					script = "";
					returnValue = null;

					var e = e.details();
					parsingExceptions.push(new Exception(e));
					if (debugTraces)
						trace(e);

					if (classSupport)
					{
						try
							scriptX = new SScriptX(string, this)
						catch (e)
						{
							scriptX = null;
						}
					}
				}
			}

			lastReportedTime = Timer.stamp() - time;

			if (debugTraces)
			{
				if (lastReportedTime == 0)
					trace('SScript instance created instantly (0s)');
				else
					trace('SScript instance created in ${lastReportedTime}s');
			}
		}
		catch (e)
			lastReportedTime = -1;

		return this;
	}

	inline function toString():String
	{
		if (_destroyed)
			return "null";

		if (scriptFile != null && scriptFile.length > 0)
			return scriptFile;

		return scriptX != null ? "[SScriptX SScriptX]" : "[SScript SScript]";
	}

	#if (sys || openflPos)
	/**
		Checks for scripts in the provided path and returns them as an array.

		Make sure `path` is a directory!

		If `extensions` is not `null`, files' extensions will be checked.
		Otherwise, only files with the `.hx` extensions will be checked and listed.

		@param path The directory to check for. Nondirectory paths will be ignored.
		@param extensions Optional extension to check in file names.
		@return The script array.
	**/
	#else
	/**
		Checks for scripts in the provided path and returns them as an array.

		This function will always return an empty array, because you are targeting an unsupported target.
		@return An empty array.
	**/
	#end
	public static function listScripts(path:String, ?extensions:Array<String>):Array<SScript>
	{
		if (!path.endsWith('/'))
			path += '/';

		if (extensions == null || extensions.length < 1)
			extensions = ['hx'];

		var list:Array<SScript> = [];
		#if sys
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			var files:Array<String> = FileSystem.readDirectory(path);
			for (i in files)
			{
				var hasExtension:Bool = false;
				for (l in extensions)
				{
					if (i.endsWith(l))
					{
						hasExtension = true;
						break;
					}
				}
				if (hasExtension && FileSystem.exists(path + i))
					list.push(new SScript(path + i));
			}
		}
		#elseif openflPos
		function readDirectory(path:String):Array<String>
		{
			if (path.endsWith('/') && path.length > 1)
				path = path.substring(0, path.length - 1);

			var assetsLibrary:Array<String> = [];
			for (folder in Assets.list().filter(list -> list.contains(path)))
			{
				var myFolder:String = folder;
				myFolder = myFolder.replace('${path}/', '');

				if (myFolder.contains('/'))
					myFolder = myFolder.replace(myFolder.substring(myFolder.indexOf('/'), myFolder.length), '');

				myFolder = '$path/${myFolder}';

				if (!myFolder.startsWith('.') && !assetsLibrary.contains(myFolder))
					assetsLibrary.push(myFolder);

				assetsLibrary.sort((a, b) -> ({
					a = a.toUpperCase();
					b = b.toUpperCase();
					return a < b ? -1 : a > b ? 1 : 0;
				}));
			}

			return assetsLibrary;
		}
		for (i in readDirectory(path))
		{
			var hasExtension:Bool = false;
			for (l in extensions)
			{
				if (i.endsWith(l))
				{
					hasExtension = true;
					break;
				}
			}
			if (hasExtension && Assets.exists(i))
				list.push(new SScript(i));
		}
		#end

		return list;
	}

	/**
		This function makes this script **COMPLETELY** unusable and unrestorable.

		If you don't want to destroy your script just yet, just set `active` to false!
	**/
	public function destroy():Void
	{
		if (global.exists(script))
			global.remove(script);
		if (global.exists(scriptFile))
			global.remove(scriptFile);

		if (classSupport)
			for (i => k in interp.variables)
				if (SScriptX.variables.exists(i))
					SScriptX.variables.remove(i);

		interp.variables.clear();
		if (scriptX != null)
			scriptX.interpEX.variables.clear();

		parser = null;
		interp = null;
		scriptX = null;
		script = null;
		scriptFile = null;
		active = false;
		notAllowedClasses = null;
		lastReportedCallTime = -1;
		lastReportedTime = -1;
		_destroyed = true;
	}

	function get_variables():Map<String, Dynamic>
	{
		if (_destroyed)
			return null;

		return if (scriptX != null) scriptX.interpEX.variables else interp.variables;
	}

	function setPackagePath(p):String
	{
		if (_destroyed)
			return null;

		return packagePath = p;
	}

	function get_packagePath():String
	{
		if (_destroyed)
			return null;

		return if (scriptX != null) scriptX.interpEX.pkg else packagePath;
	}

	function get_classes():Map<String, AbstractScriptClass>
	{
		if (_destroyed)
			return null;

		return if (scriptX != null)
		{
			var newMap:Map<String, AbstractScriptClass> = new Map();
			for (i => k in scriptX.classes)
				if (i != null && k != null)
					newMap[i] = k;
			newMap;
		}
		else [];
	}

	function get_currentScriptClass():AbstractScriptClass
	{
		if (_destroyed)
			return null;

		return if (scriptX != null) scriptX.currentScriptClass else null;
	}

	function get_currentSuperClass():Class<Dynamic>
	{
		if (_destroyed)
			return null;

		return if (scriptX != null) scriptX.currentSuperClass else null;
	}

	function set_currentClass(value:String):String
	{
		if (_destroyed)
			return null;

		return if (scriptX != null) scriptX.currentClass = value else null;
	}

	function get_currentClass():String
	{
		if (_destroyed)
			return null;

		return if (scriptX != null) scriptX.currentClass else null;
	}

	function get_exMode():Bool
	{
		if (_destroyed)
			return false;

		return scriptX != null;
	}

	static function get_BlankReg():EReg
	{
		return ~/^[\n\r\t]$/;
	}

	#if hscriptPos
	function set_customOrigin(value:String):String
	{
		if (_destroyed)
			return null;

		@:privateAccess parser.origin = value;
		return customOrigin = value;
	}
	#end

	static function set_defaultTypeCheck(value:Null<Bool>):Null<Bool>
	{
		for (i in global)
		{
			i.typeCheck = value == null ? false : value;
			// i.execute();
		}

		return defaultTypeCheck = value;
	}

	static function set_defaultClassSupport(value:Null<Bool>):Null<Bool>
	{
		for (i in global)
		{
			i.classSupport = value == null ? false : value;
			// i.execute();
		}

		return defaultClassSupport = value;
	}

	static function set_defaultDebug(value:Null<Bool>):Null<Bool>
	{
		for (i in global)
		{
			i.debugTraces = value == null ? false : value;
			// i.execute();
		}

		return defaultDebug = value;
	}
}
