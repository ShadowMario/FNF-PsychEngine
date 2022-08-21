function create() {
    character.frames = Paths.getCharacter(character.curCharacter);

    character.animation.addByPrefix('firstDeath', "BF dies", 24, false);
    character.animation.addByPrefix('deathLoop', "BF Dead Loop", 24, false);
    character.animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

    character.addOffset('firstDeath', 37, 11);
    character.addOffset('deathLoop', 37, 5);
    character.addOffset('deathConfirm', 37, 69);

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