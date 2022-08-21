import("LoadingState");

var char:Int = 0;

function update(elapsed:Float) {
    var controls = FlxControls.justPressed;
    var pressed = false;
    if (char == 0) pressed = controls.S;
    if (char == 1) pressed = controls.H;
    if (char == 2) pressed = controls.R;
    if (char == 3) pressed = controls.E;
    if (char == 4) pressed = controls.K;
    if (pressed) {
        char++;
    } else {
        if (controls.ANY) {
            char = 0;
        }
    }
    if (char >= 5) {
        CoolUtil.loadSong("Friday Night Funkin'", "MILF", "Sexy");
        LoadingState.loadAndSwitchState(new PlayState_());
    }
    
        
}