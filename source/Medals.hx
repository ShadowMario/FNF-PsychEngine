import flixel.FlxG;

class Medals {
    public static function __getStates(mod:String):MedalStates {
        
        var save = ModSupport.modSaves[mod];
        if (save == null) {
            FlxG.log.error("Mod Save for " + mod + " not found.");
            return null;
        }
        var states:MedalStates = cast save.data.medalStates;
        if (states == null) {
            states = new MedalStates();
            save.data.medalStates = states;
        }
        return states;
    }
    public static function lock(mod:String, medal:String) {
        __getStates(mod)[medal] = MedalState.LOCKED;
    }

    public static function unlock(mod:String, medal:String) {
        var states = __getStates(mod);
        if (states[medal] != (states[medal] = MedalState.UNLOCKED)) {
            // show the small popup
            if (ModSupport.modMedals[mod] == null) return;
            if (ModSupport.modMedals[mod].medals == null) return;

            var state = FlxG.state;
            if (Std.isOfType(state, MusicBeatState)) {
                var state = cast(state, MusicBeatState);
                var m = null;
                for(e in ModSupport.modMedals[mod].medals) {
                    if (e.name == medal) {
                        m = e;
                        break;
                    }
                }
                if (m == null) return;
                CoolUtil.playMenuSFX(4);
                var popup = new MedalsOverlay(mod, m);
                MusicBeatState.medalOverlay.push(popup);
            }
            
        };
    }

    public static function getState(mod:String, medal:String):MedalState {
        var e = __getStates(mod);
        return e[medal] == null ? LOCKED : e[medal];
    }
}

typedef MedalStates = Map<String, MedalState>;
@:enum
abstract MedalState(Int) {
    var LOCKED = 0;
    var UNLOCKED = 1;
}