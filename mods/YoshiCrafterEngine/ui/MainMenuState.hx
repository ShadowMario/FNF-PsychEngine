function create() {
    state.optionShit.add('dvd', function() {
        FlxG.switchState(new ModState("dvd", mod));
    }, Paths.getSparrowAtlas('dvdMenu'), 'dvd basic', 'dvd white');
}