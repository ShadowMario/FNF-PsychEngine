function create() {
    var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : "Friday Night Funkin':senpai");
    character.frames = tex;
    character.animation.addByPrefix('idle', 'Senpai Idle', 24, false);
	character.animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
	character.animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
	character.animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
    character.animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

    character.addOffset('idle');
    character.addOffset("singUP", 5, 37);
    character.addOffset("singRIGHT");
    character.addOffset("singLEFT", 40);
    character.addOffset("singDOWN", 14);


    character.setGraphicSize(Std.int(character.width * 6));
    character.updateHitbox();
    character.charGlobalOffset.x = 100;
    character.charGlobalOffset.y = 430;
    // character.charGlobalOffset.y = 180;
    character.camOffset.x = -150;
    character.camOffset.y = -100 - (character.height / 4);

    character.antialiasing = false;
    character.playAnim('idle');
}

function getColors(altAnim) {
    return [
        0xFFFFAA6F,
        0xFFA7B7F5,
        0xFFFF78BF,
        0xFFFF78BF,
        0xFFA7B7F5
    ];
}

function healthIcon(icon) {
    icon.antialiasing = false;
    // [[Min health, Frame index (grid)]]
    icon.frameIndexes = [[0, 0]];
}