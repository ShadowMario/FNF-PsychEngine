package mod_support_stuff;

import flixel.FlxG;

// state that can be entirely rewritten
class FullyModState extends MusicBeatState {
    public function className() {return "FullyModState";}
    public var entirelyCustom:Bool = true; // prevent EVERYTHING DEFAULT!!!
    public var script:Script = null;

    public function new() {
        super();    
    }
    public override function create() {
        super.create();
        var path = '${Paths.modsPath}/${Settings.engineSettings.data.selectedMod}/states/${className()}';
        script = Script.create(path);
        if (entirelyCustom = (script != null)) {
            ModSupport.setScriptDefaultVars(script, Settings.engineSettings.data.selectedMod, {});
            script.setScriptObject(this);
            script.loadFile(path);
            script.executeFunc("create");
        } else {
            normalCreate();
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (entirelyCustom)
            script.executeFunc("update", [elapsed]);
        else
            normalUpdate(elapsed);
        
                
        if (FlxControls.justPressed.F5) FlxG.resetState();
        if (FlxControls.justPressed.TAB) openSubState(new SwitchModSubstate());
    }

    public override function destroy() {
        super.destroy();
        if (entirelyCustom)
            script.executeFunc("destroy");
        else
            normalDestroy();
    }
    public override function beatHit() {
        super.beatHit();
        if (entirelyCustom)
            script.executeFunc("beatHit", [curBeat]);
        else
            normalBeatHit();
    }

    public override function stepHit() {
        super.stepHit();
        if (entirelyCustom)
            script.executeFunc("stepHit", [curStep]);
        else
            normalStepHit();
    }


    function normalCreate() {}
    function normalUpdate(elapsed:Float) {}
    function normalBeatHit() {}
    function normalStepHit() {}
    function normalDestroy() {}
}