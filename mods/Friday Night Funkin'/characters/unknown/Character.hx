import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;

function create() {
    if (isPlayer) {
        frames = Paths.getSparrowAtlas("characters/unknown/bf_spritesheet", "mods/" + mod, false);

        animation.addByPrefix('idle', 'BF idle dance', 24, false);
        animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
        animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
        animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
        animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);

        addOffset('idle', -5);
        addOffset("singUP", -29, 27);
        addOffset("singRIGHT", -38, -7);
        addOffset("singLEFT", 12, -6);
        addOffset("singDOWN", -10, -50);

        flipX = true;
        charGlobalOffset.y = 350;
    } else {
        frames = Paths.getCharacter(curCharacter);

        animation.addByPrefix('idle', 'Dad idle dance', 24, false);
        animation.addByPrefix('singUP', 'Dad Sing note UP', 24);
        animation.addByPrefix('singRIGHT', 'dad sing note right', 24);
        animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
        animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);
    
        addOffset('idle');
        addOffset("singUP", -6, 50);
        addOffset("singRIGHT", 0, 27);
        addOffset("singLEFT", -10, 10);
        addOffset("singDOWN", 0, -30);
    }
    playAnim('idle');
}

function healthIcon(h:HealthIcon) {
    if (isPlayer) {
        h.frameIndexes = [[20, 2], [0, 3]];
    } else {
        h.frameIndexes = [[20, 0], [0, 1]];
    }
}

function getColors(altAnim) {
    return [
        0xFFCECECE,
        0xFFCECECE,
        0xFFCECECE,
        0xFFCECECE,
        0xFFCECECE
    ];
}