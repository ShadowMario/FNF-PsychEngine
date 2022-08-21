function onPreEndSong() {
    if (PlayState.isStoryMode)
        Medals.unlock("SPOOKY TIME");
}