package;

import flixel.text.FlxText;
import flixel.FlxG;

class WarningState extends MusicBeatState {
    var warningTxt:FlxText;

    var keybind:String;

    public function new(){
        var key = ClientPrefs.keybinds.copy();

        warning = new FlxText(0, 0, 0, 
        "WARNING: you're PC might not be powerful enough to run the mod,\nare you sure you want to continue?" + key[10] + " for YES\n" + key[11] + " for NO", 
        32);
        add(warning);

        super();
    }

    override function update(elapsed:Float){
        if (controls.BACK){
            openfl.system.System.exit(0); // idk what to do with this
        }

        if (controls.ACCEPT){
            MusicBeatState.switchState(new TitleState());
            FlxG.sound.play(Paths.sound("confirmMenu"));
        }

        super.update(elapsed);
    }

    override function destroy(){
        if (key != null) // just to prevent a crash
            key = null;
        if (warning != null)
            warning = null;
        return super.destroy();
    }
}