var cpuStrums:Array<Float> = [0, 0, 0, 0];
var playerStrums:Array<Float> = [0, 0, 0, 0];
var doTheMario:Bool = false;

function musicstart() {
    doTheMario = true;
}

function update(elapsed) {
    if (!doTheMario || PlayState.strumLine == null) return;
    for (i in 0...4) {
        PlayState.cpuStrums.members[i].y = FlxMath.lerp(PlayState.cpuStrums.members[i].y, PlayState.strumLine.y, FlxMath.bound(0.25 * 60 * elapsed, 0, 1));

        PlayState.playerStrums.members[i].y = FlxMath.lerp(PlayState.playerStrums.members[i].y, PlayState.strumLine.y, FlxMath.bound(0.25 * 60 * elapsed, 0, 1));
    }
}

function beatHit(curBeat) {
    if (curBeat >= 168 && curBeat < 200)
    {
        for (i in 0...8) {
            var multiplicator = ((curBeat + i) % 2 == 0) ? 1 : -1;
            if (i < 4) {
                PlayState.cpuStrums.members[i].y = PlayState.strumLine.y + (25 * multiplicator);
            } else {
                PlayState.playerStrums.members[i - 4].y = PlayState.strumLine.y + (25 * multiplicator);
            }
        }
        FlxG.camera.zoom += 0.015;
        // PlayState.camHUD.zoom += 0.03;
    }
}