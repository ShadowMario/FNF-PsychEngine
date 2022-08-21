import haxe.Unserializer;
import flixel.FlxG;
import flixel.FlxSprite;
import linc.Linc;
import mod_support_stuff.ModScript;
import cpp.Reference;
import cpp.Lib;
import cpp.Pointer;
import cpp.RawPointer;
import cpp.Callable;

import haxe.Constraints.Function;
import haxe.DynamicAccess;
import lime.app.Application;
using StringTools;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.Exception;

// HSCRIPT
import hscript.Interp;

// LUA
#if ENABLE_LUA
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

class Script {
    public var fileName:String = "";
    public var mod:String = null;
    public var metadata:Dynamic = {};
    public function new() {

    }

    public static function fromPath(path:String):Script {
        var script = create(path);
        if (script != null) {
            script.loadFile(path);
            return script;
        } else {
            return null;
        }
    }

    public static function create(path:String):Script {
        var p = path.toLowerCase();
        var ext = Path.extension(p);

        var scriptExts = Main.supportedFileTypes;
        if (ext == "") {
            for (e in scriptExts) {
                if (FileSystem.exists('$p.$e')) {
                    p = '$p.$e';
                    ext = e;
                    break;
                }
            }
        }
        switch(ext.toLowerCase()) {
            case 'hhx':
                return new HardcodedHScript();
            case 'hx' | 'hscript' | 'hsc':
                return new HScript();
            #if ENABLE_LUA
            case 'lua':
                return new LuaScript();
            #end
        }
        return null;
    }


    public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        var ret = _executeFunc(funcName, args);
        executeFuncPost();
        return ret;
    }

    public function _executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        Paths.curSelectedMod = 'mods/${mod}';
        return null;
    }

    public function executeFuncPost() {
        Paths.curSelectedMod = null;
    }

    public function setVariable(name:String, val:Dynamic) {}

    public function getVariable(name:String):Dynamic {return null;}

    public function trace(text:String, error:Bool = false) {
        trace(text);
        if (CoolUtil.isDevMode()) {
            LogsOverlay.trace(text);
        }
    }

    public function loadFile(path:String) {
        Paths.curSelectedMod = 'mods/${mod}';
    }

    public function destroy() {

    }

    public function setScriptObject(obj:Dynamic) {}
}

class DummyScript extends Script {
    var variables:Map<String, Dynamic> = [];

    public function new() {super();}

    public override function _executeFunc(funcName:String, ?args:Array<Any>) {
        var f = variables[funcName];
        if (f != null) {
            try {
                if (args == null) {
                    var result = null;
                    try {
                        result = f();
                    } catch(e) {
                        this.trace('$e', true);
                    }
                    return result;
                } else {
                    var result = null;
                    try {
                        result = Reflect.callMethod(null, f, args);
                    } catch(e) {
                        this.trace('$e', true);
                    }
                    return result;
                }
            } catch(e) {
                this.trace('${e.toString()}');
            }
        }
        return null;
    }

    public override function setVariable(name:String, val:Dynamic) {variables.set(name, val);}
    public override function getVariable(name:String) {return variables.get(name);}
}

class ScriptPack {
    public var ogScripts:Array<Script> = [];
    public var scripts:Array<Script> = [];
    public var scriptModScripts:Array<ModScript> = [];
    public var __curScript:Script;
    public function new(scripts:Array<ModScript>) {
        for (s in scripts) {
            addScript(s.path, s.mod);
            scriptModScripts.push(s);
        }
        for(e in this.scripts) ogScripts.push(e);
    }

    public function addScript(path:String, ?mod:String) {
        if (mod == null) mod = Settings.engineSettings.data.selectedMod;

        var sc = Script.create('${Paths.modsPath}/${path}');
        if (sc == null) return;
        ModSupport.setScriptDefaultVars(sc, mod, {});
        sc.setVariable("scriptPack", this);
        sc.setVariable("setGlobal", function(name:String, value:Dynamic, alsoAffectThis:Bool = false) {
            for(e in scripts) {
                if (alsoAffectThis || e != __curScript) {
                    e.setVariable(name, value);
                }
            }
        });
        sc.setVariable("importScript", function(p:String) {
            if (p == null) return;
            var scriptPath = SongConf.getModScriptFromValue(sc.mod, p);
            addScript(scriptPath.path, scriptPath.mod);
            scriptModScripts.push(scriptPath);
        });
        this.scripts.push(sc);
    }

    public function loadFiles() {
        for (k=>sc in scripts) {
            var s = scriptModScripts[k];
            __curScript = sc;
            sc.loadFile('${Paths.modsPath}/${s.path}');
        }
    }

    public function executeFunc(funcName:String, ?args:Array<Any>, ?defaultReturnVal:Any) {
        var a = args;
        if (a == null) a = [];
        for (script in scripts) {
            __curScript = script;
            var returnVal = script.executeFunc(funcName, a);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) {
                return returnVal;
            }
        }

        return defaultReturnVal;
    }

    public function executeFuncMultiple(funcName:String, ?args:Array<Any>, ?defaultReturnVal:Array<Any>) {
        var a = args;
        if (a == null) a = [];
        if (defaultReturnVal == null) defaultReturnVal = [null];
        for (script in scripts) {
            __curScript = script;
            var returnVal = script.executeFunc(funcName, a);
            if (!defaultReturnVal.contains(returnVal)) {
                #if messTest trace("found"); #end
                return returnVal;
            }
        }
        return defaultReturnVal[0];
    }

    public function setVariable(name:String, val:Dynamic) {
        for (script in scripts) script.setVariable(name, val);
    }

    public function getVariable(name:String, defaultReturnVal:Any) {
        for (script in ogScripts) { // for gfVersion and shit like that
            var variable = script.getVariable(name);
            if (variable != defaultReturnVal) {
                return variable;
            }
        }
        return defaultReturnVal;
    }

    public function destroy() {
        for(script in scripts) script.destroy();
        scripts = null;
    }
}

class HScript extends Script {
    public var hscript:Interp;
    public function new() {
        hscript = new Interp();
        hscript.errorHandler = function(e) {
            this.trace('$e', true);
            if (Settings.engineSettings != null && Settings.engineSettings.data.showErrorsInMessageBoxes && !FlxG.keys.pressed.SHIFT) {
                var posInfo = hscript.posInfos();

                var lineNumber = Std.string(posInfo.lineNumber);
                var methodName = posInfo.methodName;
                var className = posInfo.className;

                Application.current.window.alert('Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nIf the message boxes blocks the engine, hold down SHIFT to bypass.', 'HScript error! - ${fileName}');
            }
        };
        super();
    }
    public override function setScriptObject(obj:Dynamic) {
        hscript.scriptObject = obj;
    }

    public override function _executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        super._executeFunc(funcName, args);
        if (hscript == null) {
            this.trace("hscript is null");
            return null;
        }
		if (hscript.variables.exists(funcName)) {
            var f = hscript.variables.get(funcName);
            if (args == null) {
                var result = null;
                try {
                    result = f();
                } catch(e) {
                    this.trace('$e', true);
                }
                return result;
            } else {
                var result = null;
                try {
                    result = Reflect.callMethod(null, f, args);
                } catch(e) {
                    this.trace('$e', true);
                }
                return result;
            }
		}
        executeFuncPost();
        return null;
    }

    public override function loadFile(path:String) {
        super.loadFile(path);
        if (path.trim() == "") return;
        fileName = Path.withoutDirectory(path);
        var p = path;
        if (Path.extension(p) == "") {
            var exts = ["hx", "hsc", "hscript"];
            for (e in exts) {
                if (FileSystem.exists('$p.$e')) {
                    p = '$p.$e';
                    fileName += '.$e';
                    break;
                }
            }
        }
        try {
            hscript.execute(ModSupport.getExpressionFromPath(p, false));
        } catch(e) {
            this.trace('${e.message}', true);
        }
    }
    public function bruh(path:String) {
        super.loadFile(path);
    }

    public override function trace(text:String, error:Bool = false) {
        var posInfo = hscript.posInfos();

        var lineNumber = Std.string(posInfo.lineNumber);
        var methodName = posInfo.methodName;
        var className = posInfo.className;

        if (!Settings.engineSettings.data.developerMode) return;
        
        (error ? LogsOverlay.error : LogsOverlay.trace)(('$fileName:${methodName == null ? "" : '$methodName:'}$lineNumber: $text').trim());
    }

    public override function setVariable(name:String, val:Dynamic) {
        hscript.variables.set(name, val);
        @:privateAccess
        hscript.locals.set(name, {r: val, depth: 0});
    }

    public override function getVariable(name:String):Dynamic {
        if (@:privateAccess hscript.locals.exists(name) && @:privateAccess hscript.locals[name] != null) {
            @:privateAccess
            return hscript.locals.get(name).r;
        } else if (hscript.variables.exists(name))
            return hscript.variables.get(name);

        return null;
    }
}

class HardcodedHScript extends HScript {
    public override function loadFile(path:String) {
        bruh(path);
        if (path.trim() == "") return;
        fileName = Path.withoutDirectory(path);
        var p = path;
        trace(p);
        if (Path.extension(p) == "") {
            if (FileSystem.exists('$p.hhx')) {
                p = '$p.hhx';
                fileName += '.hhx';
            }
        }
        trace(p);

        var code:String = null;
        var expr = null;
        var unserializer = null;
        try {
            code = sys.io.File.getContent(p);
            // {code: expr}
            unserializer = new Unserializer(code);
            expr = unserializer.unserialize();
        } catch(e) {
            this.trace('${e.message}', true);
            return;
        }

        if (expr == null)
            return;

        if (!Reflect.hasField(expr, "code")) {
            this.trace('Serialized code does not have "code" variable.', true);
            return;
        }
        try {
            this.hscript.execute(expr.code);
        } catch(e) {
            this.trace('${e.message}', true);
            return;
        }
    }
}
#if ENABLE_LUA
typedef LuaObject = {
    var varPath:String;
    var set:(String,String)->Void;
    var get:(String)->LuaObject;
}


class LuaScript extends Script {
    public var state:llua.State;
    public var variables:Map<String, Dynamic> = [];


    function setLuaVar(name:String, value:Dynamic) {
        switch(Type.typeof(value)) {
            case Type.ValueType.TNull | Type.ValueType.TBool | Type.ValueType.TInt | Type.ValueType.TFloat | Type.ValueType.TClass(String) | Type.ValueType.TObject:
                Convert.toLua(state, value);
                Lua.setglobal(state, name);
            case Type.ValueType.TFunction:
                Lua_helper.add_callback(state, name, value);
            case value:
                throw new Exception('Variable of type $value is not supported.');
        }
    }
    
    function getVar(v:String) {
        var splittedVar = v.split(".");
        if (splittedVar.length == 0) return null;
        var currentObj = variables[splittedVar[0]];
        for (i in 1...splittedVar.length) {
            var property = Reflect.getProperty(currentObj, splittedVar[i]);
            if (property != null) {
                currentObj = property;
            } else {
                try {
                    // try running getter
                    currentObj = Reflect.getProperty(currentObj, 'get_${splittedVar[i]}')();
                } catch(e) {
                    this.trace('Variable ${splittedVar[i]} in $v doesn\'t exist or is equal to null. Parent variable is of type ${Type.typeof(currentObj)}.', true);
                    return null;
                }
            }
        }
        return currentObj;
    }
    public function new() {
        super();
        state = LuaL.newstate();
        Lua.init_callbacks(state);
        LuaL.openlibs(state);
        Lua_helper.register_hxtrace(state);
        
        Lua_helper.add_callback(state, "set", function(v:String, value:Dynamic) {
            var splittedVar = v.split(".");
            if (splittedVar.length == 0) return false;
            if (splittedVar.length == 1) {
                variables[v] = value;
                return true;
            }
            var currentObj = variables[splittedVar[0]];
            for (i in 1...splittedVar.length - 1) {
                var property = Reflect.getProperty(currentObj, splittedVar[i]);
                if (property != null) {
                    currentObj = property;
                } else {
                    this.trace('Variable $v doesn\'t exist or is equal to null.');
                    return false;
                }
            }
            var finalVal = value;
            if (Std.isOfType(finalVal, String)) {
                var str = cast(finalVal, String);
                if (str.startsWith("${") && str.endsWith("}")) {
                    var v = getVar(str.substr(2, str.length - 3));
                    if (v != null) {
                        finalVal = v;
                    }
                }
            }
            try {
                Reflect.setProperty(currentObj, splittedVar[splittedVar.length - 1], finalVal);
                return true;
            } catch(e) {
                this.trace('Variable $v doesn\'t exist.', true);
                return false;
            }
        });
        Lua_helper.add_callback(state, "get", function(v:String, ?globalName:String) {
            var r = getVar(v);
            if (globalName != null && globalName != "") {
                variables[globalName] = r;
                return '$' + '{$globalName}';
            } else {
                return r;
            }
        });

        Lua_helper.add_callback(state, "sprite_create", function(v:String, x:Int, y:Int) {
            setVariable(v, new FlxSprite(x, y));
        });

        Lua_helper.add_callback(state, "sprite_loadSparrow", function(v:String, sparrowPath:String) {
            var v = variables[v];
            if (Std.isOfType(v, FlxSprite)) {
                cast(v, FlxSprite).frames = Paths.getSparrowAtlas(sparrowPath, 'mods/$mod');
            } else {
                trace('Variable $v is not a sprite.');
            }
        });
        Lua_helper.add_callback(state, "sprite_loadImage", function(v:String, imagePath:String, animated:Bool, width:Int, height:Int) {
            var v = variables[v];
            if (Std.isOfType(v, FlxSprite)) {
                cast(v, FlxSprite).loadGraphic(Paths.image(imagePath, 'mods/$mod'), animated, width, height);
            } else {
                trace('Variable $v is not a sprite.');
            }
        });
        Lua_helper.add_callback(state, "sprite_setInCamHUD", function(v:String, setInCamHud:Bool) {
            var v = variables[v];
            if (Std.isOfType(v, FlxSprite)) {
                if (PlayState.current != null) cast(v, FlxSprite).cameras = [setInCamHud ? PlayState.current.camHUD : FlxG.camera];
            } else {
                trace('Variable $v is not a sprite.');
            }
        });

        addClass(FlxSprite, new FlxSprite(), "sprite");
        addClass(PlayState, PlayState.current, "PlayState", true);
        /*
       
        Lua_helper.add_callback(state, "sprite_setAntialiasing", function(v:String, antialiasing:Bool) {
            var v = variables[v];
            if (Std.isOfType(v, FlxSprite)) {
                cast(v, FlxSprite).loadGraphic(Paths.image(imagePath, 'mods/$mod'), animated, width, height);
            } else {
                trace('Variable $v is not a {$prefix}.');
            }
        });
        */

        Lua_helper.add_callback(state, "getArray", function(array:String, key:Int, ?globalVar:String):Dynamic {
            if (array == null || array == "") {
                this.trace("getArray(): You need to type a variable name");
                return null;
            } else {
                var obj = getVar(array);
                switch(Type.typeof(obj)) {
                    case Type.ValueType.TClass(Array):
                        var arr:Array<Any> = obj;
                        var elem = arr[key];
    
                        if (globalVar == null || globalVar == "") {
                            return elem;
                        } else {
                            variables[globalVar] = elem;
                            return null;
                        }
                    default:
                        this.trace('getArray(): Variable is an ${Type.typeof(obj)} instead of an array');
                        return null;
                }
            }
        });
        Lua_helper.add_callback(state, "setArray", function(array:String, key:Int, newVar:Dynamic):Bool {
            if (array == null || array == "") {
                this.trace("setArray(): You need to type a variable name");
                return false;
            } else {
                var obj = getVar(array);
                switch(Type.typeof(obj)) {
                    case Type.ValueType.TClass(Array):
                        var arr:Array<Any> = obj;
                        arr[key] = newVar;
                        return true;
                    default:
                        this.trace('setArray(): Variable is an ${Type.typeof(obj)} instead of an array');
                        return false;
                }
            }
        });
        Lua_helper.add_callback(state, "v", function(c:String) {return '$' + '{$c}';});
        Lua_helper.add_callback(state, "call", function(v:String, ?resultName:String, ?args:Array<Dynamic>):Dynamic {
            if (args == null) args = [];
            var splittedVar = v.split(".");
            if (splittedVar.length == 0) return false;
            var currentObj = variables[splittedVar[0]];
            for (i in 1...splittedVar.length - 1) {
                var property = Reflect.getProperty(currentObj, splittedVar[i]);
                if (property != null) {
                    currentObj = property;
                } else {
                    this.trace('Variable $v doesn\'t exist or is equal to null.');
                    return false;
                }
            }
            var func = Reflect.getProperty(currentObj, splittedVar[splittedVar.length - 1]);

            var finalArgs = [];
            for (a in args) {
                if (Std.isOfType(a, String)) {
                    var str = cast(a, String);
                    if (str.startsWith("${") && str.endsWith("}")) {
                        var st = str.substr(2, str.length - 3);
                        trace(st);
                        var v = getVar(st);
                        if (v != null) {
                            finalArgs.push(v);
                        } else {
                            finalArgs.push(a);
                        }
                    } else {
                        finalArgs.push(a);
                    }
                } else {
                    finalArgs.push(a);
                }
            }
            if (func != null) {
                var result = null;
                try {
                    result = Reflect.callMethod(null, func, finalArgs);
                } catch(e) {
                    this.trace('$e', true);
                }
                if (resultName == null) {
                    return result;
                } else {
                    variables[resultName] = result;
                    return '$' + resultName;
                }
            } else {
                this.trace('Function $v doesn\'t exist or is equal to null.');
                return false;
            }
        });
        Lua_helper.add_callback(state, "createClass", function(name:String, className:String, params:Array<Dynamic>) {
            var cl = Type.resolveClass(className);
            if (cl == null) {
                if (variables[className] != null) {
                    if (Type.typeof(variables[className]) == Type.typeof(Class)) {
                        cl = cast(variables[className], Class<Dynamic>);
                    }
                }
            }
            variables[name] = Type.createInstance(cl, params);
        });
        Lua_helper.add_callback(state, "print", function(toPtr:Dynamic) {
            this.trace(Std.string(toPtr));
        });
    }

    public override function loadFile(path:String) {
        super.loadFile(path);
        var p = path;
        if (Path.extension(p) == "") {
            p = p + ".lua";
        }
        fileName = Path.withoutDirectory(p);
        if (FileSystem.exists(p)) {
            if (LuaL.dostring(state, File.getContent(p)) != 0) {
                var err = Lua.tostring(state, -1);
                this.trace('$err');
            }
        } else {
            this.trace("Lua script does not exist.");
        }
    }

    public function addClass(cl:Class<Dynamic>, instance:Dynamic, prefix:String, useGivenObj:Bool = false) {
        for(e in Type.getInstanceFields(cl)) {
            var v = Reflect.getProperty(instance, e);
            
            var name = e.charAt(0).toUpperCase() + e.substr(1);

            // sorry for this awful code
            switch(Type.typeof(v)) {
                case Type.ValueType.TBool:
                    Lua_helper.add_callback(state, '${prefix}_get$name', function(v:String) {
                        if (useGivenObj) {
                            return Reflect.getProperty(instance, e);
                        } else {
                            var v = variables[v];
                            if (Std.isOfType(v, cl)) {
                                return Reflect.getProperty(v, e);
                            } else {
                                trace('Variable $v is not a {$prefix}.', true);
                                return false;
                            }
                        }
                    });
                    Lua_helper.add_callback(state, '${prefix}_set$name', function(v:String, val:Bool) {
                        if (useGivenObj) {
                            Reflect.setProperty(instance, e, val);
                        } else {
                            var v = variables[v];
                            if (Std.isOfType(v, cl)) {
                                Reflect.setProperty(v, e, val);
                            } else {
                                trace('Variable $v is not a {$prefix}.', true);
                            }
                        }
                    });
                case Type.ValueType.TInt:
                    Lua_helper.add_callback(state, '${prefix}_get$name', function(v:String) {
                        var v = variables[v];
                        if (Std.isOfType(v, cl)) {
                            return Reflect.getProperty(v, e);
                        } else {
                            trace('Variable $v is not a {$prefix}.', true);
                            return -1;
                        }
                    });
                    Lua_helper.add_callback(state, '${prefix}_set$name', function(v:String, val:Int) {
                        if (useGivenObj) {
                            Reflect.setProperty(instance, e, val);
                        } else {
                            var v = variables[v];
                            if (Std.isOfType(v, cl)) {
                                Reflect.setProperty(v, e, val);
                            } else {
                                trace('Variable $v is not a {$prefix}.', true);
                            }
                        }
                    });
                case Type.ValueType.TFloat:
                    Lua_helper.add_callback(state, '${prefix}_get$name', function(v:String) {
                        var v = variables[v];
                        if (Std.isOfType(v, cl)) {
                            return Reflect.getProperty(v, e);
                        } else {
                            trace('Variable $v is not a {$prefix}.', true);
                            return -1.0;
                        }
                    });
                    Lua_helper.add_callback(state, '${prefix}_set$name', function(v:String, val:Float) {
                        if (useGivenObj) {
                            Reflect.setProperty(instance, e, val);
                        } else {
                            var v = variables[v];
                            if (Std.isOfType(v, cl)) {
                                Reflect.setProperty(v, e, val);
                            } else {
                                trace('Variable $v is not a {$prefix}.', true);
                            }
                        }
                    });
                case Type.ValueType.TClass(String):
                    Lua_helper.add_callback(state, '${prefix}_get$name', function(v:String) {
                        var v = variables[v];
                        if (Std.isOfType(v, cl)) {
                            return Reflect.getProperty(v, e);
                        } else {
                            trace('Variable $v is not a {$prefix}.', true);
                            return -1.0;
                        }
                    });
                    Lua_helper.add_callback(state, '${prefix}_set$name', function(v:String, val:String) {
                        if (useGivenObj) {
                            Reflect.setProperty(instance, e, val);
                        } else {
                            var v = variables[v];
                            if (Std.isOfType(v, cl)) {
                                Reflect.setProperty(v, e, val);
                            } else {
                                trace('Variable $v is not a {$prefix}.', true);
                            }
                        }
                    });
                default:
            }
        }
    }
    public override function trace(text:String, error:Bool = false)
    {
        var lua_debug:Lua_Debug = {

        }
        Lua.getinfo(state, "S", lua_debug);
        Lua.getinfo(state, "n", lua_debug);
        Lua.getinfo(state, "l", lua_debug);

        // Lua.getinfo
        var bText = '$fileName: ';
        if (lua_debug.name != null)  bText += '${lua_debug.name}()';
        if (lua_debug.currentline == -1)  {
            if (lua_debug.linedefined != -1) {
                bText += 'at line ${lua_debug.linedefined}: ';
            }
        } else {
            bText += 'at line ${lua_debug.currentline}: ';
        }

        (error ? LogsOverlay.error : LogsOverlay.trace)(bText + text);
        trace(bText + text);
    }

    public override function getVariable(name:String) {
        return variables[name];
    }

    public override function setVariable(name:String, v:Dynamic) {
        variables[name] = v;
    }

    public override function _executeFunc(funcName:String, ?args:Array<Any>) {
        super._executeFunc(funcName, args);
        
        Lua.settop(state, 0);
        if (args == null) args = [];
        Lua.getglobal(state, funcName);

        
        for (k=>val in args) {
            switch (Type.typeof(val)) {
                case Type.ValueType.TNull:
                    Lua.pushnil(state);
                case Type.ValueType.TBool:
                    Lua.pushboolean(state, val);
                case Type.ValueType.TInt:
                    Lua.pushinteger(state, cast(val, Int));
                case Type.ValueType.TFloat:
                    Lua.pushnumber(state, val);
                case Type.ValueType.TClass(String):
                    Lua.pushstring(state, cast(val, String));
                case Type.ValueType.TClass(Array):
                    Convert.arrayToLua(state, val);
                case Type.ValueType.TObject:
                    @:privateAccess
                    Convert.objectToLua(state, val); // {}
                default:
                    variables["parameter" + Std.string(k + 1)] = val;
                    Lua.pushnil(state);
            }
        }
        if (Lua.pcall(state, args.length, 1, 0) != 0) {
            var err = Lua.tostring(state, -1);
            if (err != "attempt to call a nil value") {
                this.trace('$err');
            }
            return null;
        }

        var value = Convert.fromLua(state, Lua.gettop(state));
        return value;
    }

    public override function destroy() {
        Lua.close(state);
    }
}
#end