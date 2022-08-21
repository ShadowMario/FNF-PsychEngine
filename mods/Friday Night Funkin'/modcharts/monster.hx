var mask:FlxSprite = null;
var lerp:Float = 0;
var spookyToggled:Bool = false;
function createPost() {
    mask = new FlxSprite(-640, -360).loadGraphic(Paths.image('monster/mask'));
    mask.cameras = [PlayState.camHUD];
    mask.alpha = 1;
    PlayState.add(mask);

    PlayState.isWidescreen = false;
    lerp = FlxG.camera.followLerp;
    toggleSpooky("true");
}

function musicstart() {
    toggleSpooky("true");
}

function toggleSpooky(toggle:String) {
    if (spookyToggled = (toggle == "true")) {
        FlxG.camera.followLerp = lerp / 1.5;
        PlayState.defaultCamZoom = 1.05;
    } else {
        FlxG.camera.followLerp = lerp * 1.1;
        PlayState.defaultCamZoom = 0.95;
    }
}

function update(elapsed:Float) {
    mask.alpha = FlxMath.lerp(mask.alpha, spookyToggled ? 1 : (1 / 3), 0.125 * elapsed * 60);
}