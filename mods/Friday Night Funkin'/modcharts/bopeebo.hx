function beatHit(curBeat) {
    if (curBeat % 8 == 7)
    {
        PlayState.boyfriend.playAnim('hey', true);
    }
    if (curBeat == 128 || curBeat == 129 || curBeat == 130)
        PlayState.vocals.volume = 0;
}