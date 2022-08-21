function beatHit(curBeat:Int) {
    switch (curBeat)
    {
        case 16:
            PlayState.camZooming = true;
            PlayState.gfSpeed = 2;
        case 48:
            PlayState.gfSpeed = 1;
        case 80:
            PlayState.gfSpeed = 2;
        case 112:
            PlayState.gfSpeed = 1;
        case 163:
            // FlxG.sound.music.stop();
            // FlxG.switchState(new TitleState());
    }
}