var upperBoppers:FlxSprite = null;
var bottomBoppers:FlxSprite = null;
var santa:FlxSprite = null;

var snowSprite:FlxSprite = null;

gfVersion = "gf-christmas";

function createAfterChars() {
    PlayState.boyfriend.x += 200;
}
function create() {
    gfVersion = "gf-christmas";
    PlayState.defaultCamZoom = 0.80;

    var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.2, 0.2);
    bg.active = false;
    bg.setGraphicSize(Std.int(bg.width * 0.8));
    bg.updateHitbox();
    PlayState.add(bg);

    upperBoppers = new FlxSprite(-240, -90);
    upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
    upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
    upperBoppers.antialiasing = true;
    upperBoppers.scrollFactor.set(0.33, 0.33);
    upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
    upperBoppers.updateHitbox();
    PlayState.add(upperBoppers);

    var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
    bgEscalator.antialiasing = true;
    bgEscalator.scrollFactor.set(0.3, 0.3);
    bgEscalator.active = false;
    bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
    bgEscalator.updateHitbox();
    PlayState.add(bgEscalator);

    var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
    tree.antialiasing = true;
    tree.scrollFactor.set(0.40, 0.40);
    PlayState.add(tree);

    bottomBoppers = new FlxSprite(-300, 140);
    bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
    bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
    bottomBoppers.antialiasing = true;
    bottomBoppers.scrollFactor.set(0.9, 0.9);
    bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
    bottomBoppers.updateHitbox();
    PlayState.add(bottomBoppers);

    var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
    fgSnow.active = false;
    fgSnow.antialiasing = true;
    PlayState.add(fgSnow);

    santa = new FlxSprite(-840, 150);
    santa.frames = Paths.getSparrowAtlas('christmas/santa');
    santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
    santa.antialiasing = true;
    PlayState.add(santa);

    PlayState.boyfriend.camOffset.y -= 100;


    snow = new FlxSprite();
    snow.loadGraphic(Paths.image('christmas/snow'));
    snow.antialiasing = true;
    snow.scrollFactor.set();
    snow.shader = new CustomShader(Paths.shader("snow"));
    // snow.cameras = [PlayState.camHUD];
}

function createPost() {
    PlayState.add(snow);
}

var t:Float = 0;
function update(elapsed:Float) {
    t += elapsed;
    snow.shader.shaderData.uTime.value = [t];

    if (PlayState.section != null && PlayState.section.duetCamera) {
        PlayState.defaultCamZoom = 0.65;
        PlayState.camFollow.y -= 100;
    }
    else {
        PlayState.defaultCamZoom = 0.80;
    }
    
    snow.setGraphicSize(FlxG.width / FlxG.camera.zoom, FlxG.height / FlxG.camera.zoom);
    var m = Math.max(snow.scale.x, snow.scale.y);
    snow.scale.set(m, m);
    snow.updateHitbox();
    snow.screenCenter();
}

function beatHit(curBeat) {
    upperBoppers.animation.play('bop', true);
    bottomBoppers.animation.play('bop', true);
    santa.animation.play('idle', true);
}