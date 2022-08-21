enableRating = false;

function create() {
    note.hitOnBotplay = false;
    note.frames = Paths.getSparrowAtlas("notes/NOTE_assets_damage");
    note.colored = false;
    switch(note.noteDirection) {
        case 0:
            note.animation.addByPrefix("scroll", "purple");
        case 1:
            note.animation.addByPrefix("scroll", "blue");
        case 2:
            note.animation.addByPrefix("scroll", "green");
        case 3:
            note.animation.addByPrefix("scroll", "red");
    }
    note.splashColor = 0xFFFF0000;
    note.animation.addByPrefix("holdpiece", "hold piece");
    note.animation.addByPrefix("holdend", "hold end");
    
    note.scale.set(0.7, 0.7);
    note.updateHitbox();
    note.maxEarlyDiff *= 0.5;
    note.maxLateDiff *= 0.5;
    note.cpuIgnore = true;
}

function onMiss() {}

function onPlayerHit(direction:Int) {
    playBFsAnim("hit", true);
    if (note.isSustainNote) {
        PlayState.currentSustains.push({
            time: note.strumTime,
            healthVal: -0.125
        });
    } else {
        PlayState.health -= 0.25;
    }
}