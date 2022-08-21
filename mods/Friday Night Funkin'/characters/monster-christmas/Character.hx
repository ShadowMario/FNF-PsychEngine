function create() {
    // GOTTA FIX OFFSET PROBLEMS
    var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : curCharacter);
    character.frames = tex;
    character.animation.addByPrefix('idle', 'monster idle', 24, false);
    character.animation.addByPrefix('singUP', 'monster up note', 24, false);
    character.animation.addByPrefix('singDOWN', 'monster down', 24, false);
    character.animation.addByPrefix('singLEFT', 'Monster Right note', 24, false);
    character.animation.addByPrefix('singRIGHT', 'Monster left note', 24, false);

    character.addOffset('idle');
    character.addOffset("singUP", -20, 50);
    character.addOffset("singRIGHT", -30);
    character.addOffset("singLEFT", -51);
    character.addOffset("singDOWN", -30, -40);
    character.charGlobalOffset.y = 100;
    character.playAnim('idle');
}

function getColors(altAnim) {
    return [
        0xFFF3FF6E,
        0xFFF3FF6E,
        0xFFF3FF6E,
        0xFFF3FF6E,
        0xFFF3FF6E
    ];
}

danced = true;
function dance() {
    if (!danced)
        character.playAnim("idle");
    danced = !danced;
}