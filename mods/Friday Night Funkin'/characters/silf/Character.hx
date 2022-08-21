function create() {
    // GOTTA FIX OFFSET PROBLEMS
    var tex = Paths.getCharacter(character.curCharacter);
    character.frames = tex;
    character.animation.addByPrefix('idle', "Mom Idle", 24, false);
    character.animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
    character.animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
    character.animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
    // ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
    // CUZ DAVE IS DUMB!
    character.animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

    character.addOffset('idle');
    character.addOffset("singUP", 14, 71);
    character.addOffset("singRIGHT", 10, -60);
    character.addOffset("singLEFT", 250, -23);
    character.addOffset("singDOWN", 20, -160);

    character.playAnim('idle');
}

function getColors(altAnim) {
    return [
        0xFFCDB02C,
        0xFFCDB02C,
        0xFFCDB02C,
        0xFFCDB02C,
        0xFFCDB02C
    ];
}

function healthIcon(h) {
    h.frameIndexes = [
        [75, 2],
        [20, 0],
        [0, 1]];
}