function create() {
    var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'spooky');
    character.frames = tex;
    character.animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
    character.animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
    character.animation.addByPrefix('singLEFT', 'note sing left', 24, false);
    character.animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
    character.animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
    character.animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

    character.addOffset('danceLeft');
    character.addOffset('danceRight');

    character.addOffset("singUP", -20, 26);
    character.addOffset("singRIGHT", -130, -14);
    character.addOffset("singLEFT", 130, -10);
    character.addOffset("singDOWN", -50, -130);

    character.playAnim('danceRight');
    character.charGlobalOffset.y = 200;
}

danced = false;
function dance() {
    if (danced)
        character.playAnim("danceLeft");
    else
        character.playAnim("danceRight");
    danced = !danced;
}

function getColors(altAnim) {
    return [
        0xFFD57E00,
        0xFFCEE4FF,
        0xFFD57E00,
        0xFFCEE4FF,
        0xFFD57E00
    ];
}