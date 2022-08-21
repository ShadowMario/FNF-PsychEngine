
 var limo:FlxSprite = null;

var grpLimoDancers:Array<FlxSprite> = null;
var fastCar:FlxSprite = null;
var fastCarCanDrive:Bool = true;

gfVersion = "gf-car";

var danced = false;
function beatHit(curBeat)
{
    danced = !danced;
    for(dancer in grpLimoDancers) {
		if (danced)
			dancer.animation.play('danceRight', true);
		else
			dancer.animation.play('danceLeft', true);
    }

    if (FlxG.random.bool(10) && fastCarCanDrive)
        fastCarDrive();
}

function create()
{
    PlayState.defaultCamZoom = 0.7;

    var skyBG:FlxSprite = new FlxSprite(-300, -180).loadGraphic(Paths.image('limo/limoSunset'));
    skyBG.scrollFactor.set(0.1, 0.1);
    PlayState.add(skyBG);

    var bgLimo:FlxSprite = new FlxSprite(-200, 550);
    bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
    bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
    bgLimo.animation.play('drive');
    bgLimo.scrollFactor.set(0.4, 0.4);
    bgLimo.antialiasing = true;
    PlayState.add(bgLimo);
    grpLimoDancers = [];
    PlayState.add(grpLimoDancers);

    for (i in 0...5)
    {
        var dancer:FlxSprite = new FlxSprite((370 * i) + 130, bgLimo.y - 400);
        dancer.frames = Paths.getSparrowAtlas("limo/limoDancer");
		dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		dancer.animation.play('danceLeft');
		dancer.antialiasing = true;
        dancer.scrollFactor.set(0.4, 0.4);
        PlayState.add(dancer);
        grpLimoDancers.push(dancer);
    }

    var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
    overlayShit.alpha = 0.125;

    var limoTex = Paths.getSparrowAtlas(BackgroundDancer.shrek ? 'limo/shrekDrive' : 'limo/limoDrive');

    limo = new FlxSprite(-120, 550);
    limo.frames = limoTex;
    limo.animation.addByPrefix('drive', "Limo stage", 24);
    limo.animation.play('drive');
    limo.antialiasing = true;

    fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
    
    PlayState.boyfriend.y -= 220;
    PlayState.boyfriend.x += 260;

    // PlayState.boyfriend.camOffset -= 20;
    // PlayState.dad.camOffset += 40;

    if (PlayState.gf.curCharacter.toLowerCase() == "friday night funkin':gf-car") {
        PlayState.gf.y += 140;
        PlayState.gf.x -= 60;
        PlayState.gf.scale.x = 0.75;
        PlayState.gf.scale.y = 0.75;
        PlayState.gf.scrollFactor.set(0.4, 0.4);
    }
    PlayState.add(PlayState.gf);
    PlayState.add(overlayShit);


    resetFastCar();
    PlayState.add(fastCar);
    
    PlayState.add(limo);

}

var fancyStuff = false;
function musicstart() {
    fancyStuff = true;
}
function updatePost(elapsed) {
    PlayState.camFollowLerp = 0.02;

    var i = (Conductor.songPosition + 5000) / 1000 * 30;
    PlayState.defaultCamZoom = (Math.sin(i/40)*0.05) + 0.8;

    if (!fancyStuff) return;
    PlayState.camFollow.y += (Math.sin(i/14)*30) - 50;
    PlayState.camFollow.x += (Math.sin(i/7)*15);
    
}

function resetFastCar():Void
{
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
}

function fastCarDrive()
{
    trace("vroom");
    var r = FlxG.random.int(0, 1);
    FlxG.sound.play(Paths.sound('carPass' + r), 0.7);

    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer)
    {
        resetFastCar();
    });
}