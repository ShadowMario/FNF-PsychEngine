package mod_support_stuff;

import Script.DummyScript;
import Script.HScript;

class ModClass {
    public var _mod:String = Settings.engineSettings.data.selectedMod;
    public var _scriptName:String = "main";
    public var script:Script = null;
    public var args:Array<Any> = [];

    public dynamic function new(name:String, args:Array<Dynamic>, ?mod:String) {
        if (args == null) args = [];
        if (name != null) _scriptName = name;
        if (mod != null) _mod = mod;

        var path = '${Paths.modsPath}/$_mod/classes/$_scriptName';

        script = Script.create(path);
        if (script != null) script = new DummyScript();
        ModSupport.setScriptDefaultVars(script, mod, {});
        script.setVariable("this", this);
        script.loadFile(path);
        script.executeFunc("new", args);
        script.executeFunc("create", args);
    }

    public function set(name:String, val:Dynamic) {
        script.setVariable(name, val);
    }

    public function get(name:String) {
        return script.getVariable(name);
    }
}