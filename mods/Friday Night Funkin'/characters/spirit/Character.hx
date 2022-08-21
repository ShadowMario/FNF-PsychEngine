function create() {
    var tex = Paths.getCharacterPacker(textureOverride != "" ? textureOverride : "Friday Night Funkin':spirit");
    character.frames = tex;
    character.animation.addByPrefix('idle', "idle spirit_", 24, false);
    character.animation.addByPrefix('singUP', "up_", 24, false);
    character.animation.addByPrefix('singRIGHT', "right_", 24, false);
    character.animation.addByPrefix('singLEFT', "left_", 24, false);
    character.animation.addByPrefix('singDOWN', "spirit down_", 24, false);

    character.addOffset('idle', -220, -280);
    character.addOffset('singUP', -220, -240);
    character.addOffset("singRIGHT", -220, -280);
    character.addOffset("singLEFT", -200, -280);
    character.addOffset("singDOWN", 170, 110);
    character.charGlobalOffset.x = -150;
    character.charGlobalOffset.y = 100;
    // character.camOffset.x = 300;
    character.setGraphicSize(Std.int(character.width * 6));
    character.updateHitbox();

    character.playAnim('idle');


    character.antialiasing = false;
}

function getColors(alt:Bool) {
    return [
        0xFFFF3C6E,
        0xFFFF3C6E,
        0xFFFF3C6E,
        0xFFFF3C6E,
        0xFFFF3C6E
    ];
}

function healthIcon(icon) {
    icon.antialiasing = false;
    // [[Min health, Frame index (grid)]]
    icon.frameIndexes = [[0, 0]];
}