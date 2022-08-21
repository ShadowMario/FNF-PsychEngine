function create() {
    frames = Paths.getCharacter(textureOverride != "" ? textureOverride : 'gf-pixel');
    animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
    animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

    setGraphicSize(Std.int(character.width * 6));
    updateHitbox();
    

    addOffset('danceLeft', -character.width / 2, -character.height / 2);
    addOffset('danceRight', -character.width / 2, -character.height / 2);
    
    antialiasing = false;
    playAnim('danceRight');
    charGlobalOffset.x -= 150;
}

danced = false;
function dance() {
    if (danced)
        playAnim("danceLeft");
    else
        playAnim("danceRight");
    danced = !danced;
}

function getColors(altAnim) {
    return [
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D)
    ];
}