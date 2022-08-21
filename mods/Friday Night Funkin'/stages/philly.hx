var curLight:Int = 0;
var phillyTrain:FlxSprite = null;
var bg:FlxSprite = null;
var city:FlxSprite = null;
var street:FlxSprite = null;
var streetBehind:FlxSprite = null;
var trainSound:FlxSound = null;
var light:FlxSprite = null;
var phillyCityLights:Array<Int> = [
    0xFF31A2FD,
    0xFF31FD8C,
    0xFFFB33F5,
    0xFFFD4531,
    0xFFFBA633,
];

var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;

var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;
var startedMoving:Bool = false;
var triggeredAlready:Bool = false;

gfVersion = "gf-philly";

function musicstart() {
    beatHit(0);
}
function beatHit(curBeat) {
    if (curBeat % 4 == 0)
    {
        var c = phillyCityLights[FlxG.random.int(0, phillyCityLights.length - 1)];
        light.color = c;
        light.alpha = 1;
        if (PlayState.timerBar != null) PlayState.timerBar.createGradientBar([0xFF111111], [c, c - 0x00222222], 1, 90, true, 0xFF000000);
    }

    if (!trainMoving)
        trainCooldown += 1;

    if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
    {
        trainCooldown = FlxG.random.int(-4, 0);
        trainStart();
    }
}   
function create()
{
    bg = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
    bg.scrollFactor.set(0.1, 0.1);
    PlayState.add(bg);
    global["bg"] = bg;

    city = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
    city.scrollFactor.set(0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    city.antialiasing = true;
    PlayState.add(city);
    global["city"] = city;

    light = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win'));
    light.scrollFactor.set(0.3, 0.3);
    light.setGraphicSize(Std.int(light.width * 0.85));
    light.updateHitbox();
    light.antialiasing = true;
    light.alpha = 0;
    global["light"] = light;
    PlayState.add(light);

    streetBehind = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
    streetBehind.antialiasing = true;
    PlayState.add(streetBehind);
    global["streetBehind"] = streetBehind;

    phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
    phillyTrain.antialiasing = true;
    PlayState.add(phillyTrain);
    global["phillyTrain"] = phillyTrain;

    trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
    FlxG.sound.list.add(trainSound);
    // trainSound.play();

    // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0);

    street = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
    street.antialiasing = true;
    global["street"] = street;
    PlayState.add(street);
}
    

function update(elapsed) {

    if (trainMoving)
    {
        trainFrameTiming += elapsed;

        if (trainFrameTiming >= 1 / 24)
        {
            updateTrainPos();
            trainFrameTiming = 0;
        }
    }

    light.alpha = FlxMath.lerp(1, 0, ((Conductor.songPosition / Conductor.crochet / 4) % 1));
    
    // train cool shit
    if (global["blammedEffectOn"] == true) {
        for(c in [PlayState.boyfriend, PlayState.gf, PlayState.dad]) {
            c.colorTransform.redMultiplier = c.colorTransform.greenMultiplier = c.colorTransform.blueMultiplier = 1;
            c.colorTransform.redOffset = c.colorTransform.greenOffset = c.colorTransform.blueOffset = 0;
        }
        light.alpha = city.alpha = bg.alpha = 1;
    } else {
        var ratio = 0.25 * elapsed * 60;
        var theLerp = Math.abs(FlxMath.bound(FlxMath.remapToRange(phillyTrain.x, 0, -2000, 0, 1), 0, 100));
        var ogAlpha = phillyTrain.x > -2000 && phillyTrain.x < 0 ? 0 : 1;
        if (theLerp > 1) theLerp = 1 - (theLerp - 1);
        for(c in [PlayState.boyfriend, PlayState.gf, PlayState.dad, street, city, bg, streetBehind]) {
            c.colorTransform.redMultiplier = FlxMath.lerp(c.colorTransform.redMultiplier, FlxMath.lerp(ogAlpha, (118 / 255), theLerp), ratio);
            c.colorTransform.greenMultiplier = FlxMath.lerp(c.colorTransform.greenMultiplier, FlxMath.lerp(ogAlpha, (255 / 255), theLerp), ratio);
            c.colorTransform.blueMultiplier = FlxMath.lerp(c.colorTransform.blueMultiplier, FlxMath.lerp(ogAlpha, (111 / 255), theLerp), ratio);
        }
        city.alpha = FlxMath.lerp(city.alpha, (1 - theLerp) * (1 - theLerp), ratio);
        bg.alpha = Math.min(FlxMath.lerp(bg.alpha, ogAlpha, ratio), city.alpha);
        light.alpha *= city.alpha;
    }
}

function trainStart()
{
    if (global["blammedEffectOn"] == true || trainSound.playing) return;
    trace(trainSound);
    trainMoving = true;
    trainSound.play(true);
}

function updateTrainPos()
{
    if (trainSound.time >= 4700)
    {
        startedMoving = true;
        PlayState.gf.playAnim('hairBlow');
    }

    if (startedMoving)
    {
        phillyTrain.x -= 400;

        if (phillyTrain.x < -2000 && !trainFinishing)
        {
            phillyTrain.x = -1150;
            trainCars -= 1;

            if (trainCars <= 0)
                trainFinishing = true;
        }

        if (phillyTrain.x < -4000 && trainFinishing)
            trainReset();
    }
}

function trainReset()
{
    PlayState.gf.playAnim('hairFall');
    phillyTrain.x = FlxG.width + 200;
    trainMoving = false;
    // trainSound.stop();
    // trainSound.time = 0;
    trainCars = 8;
    trainFinishing = false;
    startedMoving = false;
}