function beatHit(curBeat) {
    if (curBeat >= 168 && curBeat < 200)
    {
        FlxG.camera.zoom += 0.015;
        PlayState.camHUD.zoom += 0.03;
    }
}