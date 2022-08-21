import("LoadingState");

var crafterEngineLogo:FlxSprite = null;
var gfDancing:FlxSprite = null;

function create() {
    var a:Array<Character> = [];
    gfDancing = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
    gfDancing.frames = Paths.getSparrowAtlas('titlescreen/gfDanceTitle');
    gfDancing.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    gfDancing.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
    gfDancing.antialiasing = true;
    add(gfDancing);

    crafterEngineLogo = new FlxSprite(-50, -35);
    crafterEngineLogo.frames = Paths.getSparrowAtlas('titlescreen/logoBumpin');
    crafterEngineLogo.antialiasing = true;
    crafterEngineLogo.animation.addByPrefix('bump', 'logo bumpin', 24);
    crafterEngineLogo.animation.play('bump');
    crafterEngineLogo.updateHitbox();
    crafterEngineLogo.scale.x = crafterEngineLogo.scale.y = 0.95;
    add(crafterEngineLogo);
}

var danced = false;
function beatHit() {
    gfDancing.animation.play(danced ? "danceLeft" : "danceRight");
    danced = !danced;
}

function update(elapsed:Float) {
    if (FlxG.mouse.justPressed) {
        var pos = FlxG.mouse.getScreenPosition();
        if (pos.x >= 9 && pos.x < 186 && pos.y >= 238 && pos.y < 411) {
            // gray you fucking genius
            CoolUtil.loadSong("YoshiCrafterEngine", "yoshi", "normal");
            LoadingState.loadAndSwitchState(new PlayState_());
        }
    }
}