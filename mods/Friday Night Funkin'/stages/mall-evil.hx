gfVersion = "gf-christmas";

function createAfterChars() {
    PlayState.boyfriend.x += 320;
    PlayState.dad.y -= 80;
}

function create()
{
    var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.2, 0.2);
    bg.active = false;
    bg.setGraphicSize(Std.int(bg.width * 0.8));
    bg.updateHitbox();
    PlayState.add(bg);

    var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
    evilTree.antialiasing = true;
    evilTree.scrollFactor.set(0.2, 0.2);
    PlayState.add(evilTree);

    var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
    evilSnow.antialiasing = true;
    PlayState.add(evilSnow);
}