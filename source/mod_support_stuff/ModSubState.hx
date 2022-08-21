package mod_support_stuff;

import Script.DummyScript;
import flixel.addons.ui.FlxUITooltip;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxBasic;
import flixel.FlxG;
import Script.HScript;

class ModSubState extends MusicBeatSubstate {
    public var _mod:String = Settings.engineSettings.data.selectedMod;
    public var _scriptName:String = "main";
    public var script:Script = null;
    public var args:Array<Any> = [];

    // WILL NEED TO BE IN "Your Mod/substates/"
    public override function new(name:String, mod:String, ?args:Array<Any>) {
        super();
        if (args == null) args = [];
        if (name != null) _scriptName = name;
        if (mod != null) _mod = mod;

        var path = '${Paths.modsPath}/$_mod/substates/$_scriptName';

        script = Script.create(path);
        if (script == null) script = new DummyScript();

        
        script.setVariable("new", function(args) {});
        script.setVariable("create", function(args) {});
        script.setVariable("beatHit", function(curBeat:Int) {});
        script.setVariable("stepHit", function(curStep:Int) {});
        script.setVariable("destroy", function() {});
        script.setVariable("add", function(obj:FlxBasic) {add(obj);});
        script.setVariable("remove", function(obj:FlxBasic) {remove(obj);});
        script.setVariable("insert", function(i:Int, obj:FlxBasic) {insert(i, obj);});

        script.setVariable("state", this);

        ModSupport.setScriptDefaultVars(script, _mod, {});
        script.setScriptObject(this);
        script.loadFile(path);

        script.executeFunc("new", args);

        this.args = args;
    }

    public override function onDropFile(path:String) {
        script.executeFunc("onDropFile");
        super.onDropFile(path);
    }

    public override function onFocus() {
        script.executeFunc("onFocus");
        super.onFocus();
    }

    public override function onFocusLost() {
        script.executeFunc("onFocusLost");
        super.onFocusLost();
    }

    public override function onResize(width:Int, height:Int) {
        script.executeFunc("onResize", [width, height]);
        super.onResize(width, height);
    }

    public override function draw() {
        script.executeFunc("draw");
        super.draw();
        script.executeFunc("drawPost");
    }

    public override function create() {
        super.create();
        script.executeFunc("create", args);
    }

    public override function beatHit() {
        script.executeFunc("beatHit", [curBeat]);
        super.beatHit();
    }

    public override function stepHit() {
        script.executeFunc("stepHit", [curStep]);
        super.stepHit();
    }

    public override function update(elapsed:Float) {
        script.executeFunc("update", [elapsed]);
        super.update(elapsed);
        if (CoolUtil.isDevMode()) {
            if (FlxG.keys.justPressed.F5 && !FlxG.state.persistentUpdate) {
                if (FlxG.state is ModState) {
                    var state:ModState = cast FlxG.state;
                    FlxG.switchState(new ModState(state._scriptName, state._mod, state.args));
                } else
                    FlxG.resetState();
            } else if (FlxG.keys.justPressed.F4) {
                close();
            }
        }
    }

    public override function destroy() {
        script.executeFunc("destroy");
        super.destroy();
    }
}