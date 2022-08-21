function create() {
    character.frames = Paths.getCharacter('bf-pixel');
    character.animation.addByPrefix('idle', 'BF IDLE instance 1', 24, false);
    character.animation.addByPrefix('singUP', 'BF UP NOTE instance 1', 24, false);
    character.animation.addByPrefix('singLEFT', 'BF LEFT NOTE instance 1', 24, false);
    character.animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE instance 1', 24, false);
    character.animation.addByPrefix('singDOWN', 'BF DOWN NOTE instance 1', 24, false);
    character.animation.addByPrefix('singUPmiss', 'BF UP MISS instance 1', 24, false);
    character.animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS instance 1', 24, false);
    character.animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS instance 1', 24, false);
    character.animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS instance 1', 24, false);

    character.addOffset('idle');
    character.addOffset("singUP");
    character.addOffset("singRIGHT");
    character.addOffset("singLEFT");
    character.addOffset("singDOWN");
    character.addOffset("singUPmiss");
    character.addOffset("singRIGHTmiss");
    character.addOffset("singLEFTmiss");
    character.addOffset("singDOWNmiss");

    character.scale.set(6, 6);
    character.updateHitbox();

    character.width -= 100;
    character.height -= 100;
    character.charGlobalOffset.x = 150;
    character.charGlobalOffset.y = 550;
    character.camOffset.x = -200;
    character.camOffset.y = -200;

    character.antialiasing = false;

    character.flipX = true;

    character.playAnim('idle');
}

function dance() {
    if (character.lastHit <= Conductor.songPosition - 500 || character.lastHit == 0) {
        character.playAnim('idle');
    }
}

function getColors(altAnim) {
    return [
        0xFF7BD6F6
    ];
}

function healthIcon(icon) {
    icon.antialiasing = false;
    // [[Min health, Frame index (grid)]]
    icon.frameIndexes = [[0, 0]];
}