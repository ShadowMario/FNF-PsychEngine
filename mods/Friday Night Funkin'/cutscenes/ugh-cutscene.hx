var tankmanTalk1:FlxSprite;
var tankmanTalk1Audio:FlxSound;
var tankmanTalk2:FlxSprite;
var tankmanTalk2Audio:FlxSound;
var bfBeep:FlxSound;
var distorto:FlxSound;
var oldCamZoom:Float;
var step:Int = 0;
function create() {
    oldCamZoom = PlayState.defaultCamZoom;
    PlayState.dad.visible = false;
    PlayState.defaultCamZoom = 1.1;

    distorto = FlxG.sound.play(Paths.music("DISTORTO"), 0.6);
    distorto.pause();

    tankmanTalk1 = new FlxSprite(PlayState.dad.x, PlayState.dad.y);
    tankmanTalk1.frames = Paths.getSparrowAtlas('tank/cutscene/ugh-talk-1');
    tankmanTalk1.antialiasing = true;
    tankmanTalk1.animation.addByPrefix("talk", "TANK TALK 1 P1", 24, false);
    tankmanTalk1.offset.set(0, 5);
    
    
    PlayState.insert(global["level"], tankmanTalk1);

    tankmanTalk2 = new FlxSprite(PlayState.dad.x, PlayState.dad.y);
    tankmanTalk2.frames = Paths.getSparrowAtlas('tank/cutscene/ugh-talk-2');
    tankmanTalk2.antialiasing = true;
    tankmanTalk2.animation.addByPrefix("talk", "TANK TALK 1 P2", 24, false);
    tankmanTalk2.visible = false;
    tankmanTalk2.offset.set(35, 15);
    
    PlayState.insert(global["level"], tankmanTalk2);

    tankmanTalk1Audio = FlxG.sound.play(Paths.sound("tank/wellWellWell"));
    tankmanTalk1Audio.pause();

    tankmanTalk2Audio = FlxG.sound.play(Paths.sound("tank/killYou"));
    tankmanTalk2Audio.pause();

    bfBeep = FlxG.sound.play(Paths.sound("tank/bfBeep"));
    bfBeep.pause();
    
    distorto.fadeIn(5, 0, 0.4);
    distorto.play();
}

var eTime:Float = 0;
function update(elapsed:Float) {
    if (step == 0) {
        var targetPos = tankmanTalk1.getMidpoint();
        if (tankmanTalk1.animation.curAnim == null) {
            tankmanTalk1.animation.play("talk");
            tankmanTalk1Audio.play();
            PlayState.camFollow.setPosition(PlayState.dad.getMidpoint().x + 150 + PlayState.dad.camOffset.x, PlayState.dad.getMidpoint().y - 100 + PlayState.dad.camOffset.y);
        }
        if (tankmanTalk1.animation.curAnim.finished) {
            step++;
        }
    } else if (step == 1) {
        eTime += elapsed;
        PlayState.camFollow.setPosition(PlayState.boyfriend.getMidpoint().x - 100 + PlayState.boyfriend.camOffset.x, PlayState.boyfriend.getMidpoint().y - 100 + PlayState.boyfriend.camOffset.y);
        if (eTime > 1) {
            bfBeep.play();
            PlayState.boyfriend.playAnim("singUP");
            eTime = 0;
            step++;
        }
    } else if (step == 2) {
        eTime += elapsed;
        if (!bfBeep.playing) {
            PlayState.boyfriend.playAnim("idle");
            eTime = 0;
            step++;
        }
    } else if (step == 3) {
        eTime += elapsed;
        tankmanTalk1.visible = false;
        tankmanTalk2.visible = true;
        if (eTime > 1) {
            eTime = 0;
            step++;
        }
    } else if (step == 4) {
        if (tankmanTalk2.animation.curAnim == null) {
            tankmanTalk2.animation.play("talk");
            tankmanTalk2Audio.play();
            PlayState.camFollow.setPosition(PlayState.dad.getMidpoint().x + 150 + PlayState.dad.camOffset.x, PlayState.dad.getMidpoint().y - 100 + PlayState.dad.camOffset.y);
        }
        if (tankmanTalk2.animation.curAnim.finished) {
            step++;
        }

    } else {
        distorto.fadeOut(0.5, 0, function() {
            distorto.stop();
        });
        PlayState.defaultCamZoom = oldCamZoom;

        startCountdown();

        PlayState.dad.visible = true;
        PlayState.remove(tankmanTalk1);
        tankmanTalk1.destroy();
        
        PlayState.remove(tankmanTalk2);
        tankmanTalk2.destroy();
        bfBeep.destroy();
        // done
    }
}