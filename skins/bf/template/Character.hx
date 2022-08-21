function create() {
    // DONT FORGET TO CHANGE HERE !
    character.frames = Paths.getCharacter(character.curCharacter);

    character.longAnims = ["dodge"];

    character.animation.addByPrefix('idle', 'BF idle dance', 24, false);
    character.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
    character.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
    character.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
    character.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
    character.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
    character.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
    character.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
    character.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
    character.animation.addByPrefix('hey', 'BF HEY', 24, false);
    character.animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);
    character.animation.addByPrefix('hit', 'BF hit', 24, false);
    character.animation.addByPrefix('firstDeath', 'BF dies', 24, false);
    character.animation.addByPrefix('deathLoop', 'BF Dead Loop', 24, true);
    character.animation.addByPrefix('deathConfirm', 'BF Dead confirm', 24, false);
    character.animation.addByPrefix('scared', 'BF idle shaking', 24, false);

    character.addOffset('singUP', -29, 27);
    character.addOffset('singRIGHT', -38, -7);
    character.addOffset('singLEFT', 12, -6);
    character.addOffset('singDOWN', -10, -50);
    character.addOffset('singUPmiss', -29, 27);
    character.addOffset('singRIGHTmiss', -30, 21);
    character.addOffset('singLEFTmiss', 12, 24);
    character.addOffset('singDOWNmiss', -11, -19);
    character.addOffset('hey', 7, 4);
    character.addOffset('firstDeath', 37, 11);
    character.addOffset('deathLoop', 37, 5);
    character.addOffset('deathConfirm', 37, 69);
    character.addOffset('scared', -4, 0);


    character.playAnim('idle');
    character.charGlobalOffset.y = 350;
    character.flipX = true;
}

function dance() {
    if (character.lastHit <= Conductor.songPosition - 500 || character.lastHit == 0) {
        character.playAnim('idle');
    }
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