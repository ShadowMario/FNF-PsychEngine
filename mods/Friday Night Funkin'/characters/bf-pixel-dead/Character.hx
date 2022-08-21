function create() {
    
    character.antialiasing = false;
    character.flipX = true;

    character.frames = Paths.getCharacter(mod + ':bf-pixel-dead');
    character.animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
    character.animation.addByPrefix('deathLoop', "Retry Loop", 24, false);
    character.animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

    // character.longAnims = ["firstDeath", "deathConfirm"];

    character.addOffset('firstDeath', 0, 0);
    character.addOffset('deathLoop', -37, 0);
    character.addOffset('deathConfirm', -37, 0);
    character.playAnim('firstDeath');
    
    // pixel bullshit
    character.setGraphicSize(Std.int(character.width * 6));
    character.updateHitbox();
    
    character.width -= 100;
    character.height -= 100;
    character.charGlobalOffset.x = 150;
    character.charGlobalOffset.y = 550;
    character.camOffset.x = -character.width / 2;
    character.camOffset.y = -character.height / 2;
}

function dance() {
    character.playAnim("deathLoop");
}