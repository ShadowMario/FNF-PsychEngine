function create() {
    character.frames = Paths.getCharacter(curCharacter);

    character.animation.addByPrefix('firstDeath', "BF Dies with GF", 24, false);
    character.animation.addByPrefix('deathLoop', "BF Dead with GF Loop", 24, false);
    character.animation.addByPrefix('deathConfirm', "RETRY confirm holding gf", 24, false);

    character.addOffset('firstDeath', 37, 14);
    character.addOffset('deathLoop', 37, -3);
    character.addOffset('deathConfirm', 37, 28);

    character.charGlobalOffset.y = 350;
    character.flipX = true;
}

function dance() {
    character.playAnim("deathLoop");
}

function getColors(altAnim) {
    return [
        0xFF31B0D1,
        EngineSettings.arrowColor0,
        EngineSettings.arrowColor1,
        EngineSettings.arrowColor2,
        EngineSettings.arrowColor3
    ];
}