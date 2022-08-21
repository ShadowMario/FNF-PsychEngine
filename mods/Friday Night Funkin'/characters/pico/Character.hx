function create() {
    var isPlayer = false; // NEED TO BE FIXED !!!!
    var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'pico');
    character.frames = tex;
    character.animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
    character.animation.addByPrefix('singUP', 'pico Up note0', 24, false);
    character.animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
    if (isPlayer)
    {
        character.animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
        character.animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
        character.animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
        character.animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
    }
    else
    {
        // Need to be flipped! REDO THIS LATER!
        character.animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
        character.animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
        character.animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
        character.animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
    }

    character.animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
    character.animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

    character.addOffset('idle');
    character.addOffset("singUP", -29, 27);
    character.addOffset("singRIGHT", -68, -7);
    character.addOffset("singLEFT", 65, 9);
    character.addOffset("singDOWN", 200, -70);
    character.addOffset("singUPmiss", -19, 67);
    character.addOffset("singRIGHTmiss", -60, 41);
    character.addOffset("singLEFTmiss", 62, 64);
    character.addOffset("singDOWNmiss", 210, -28);

    character.playAnim('idle');

    character.flipX = true;
    // character.camOffset.y = character.x - 600;
    character.charGlobalOffset.y = 300;
}

var danced = false;
function dance() {
    if (!danced) {
        character.playAnim("idle", true);
    }
    danced = !danced;
}
function getColors(altAnim) {
    return [
        0xFFB7D855,
        0xFFFD6922,
        0xFF55E858,
        0xFF55E858,
        0xFFFD6922
    ];
}