var tankmanTalk:FlxSprite;
var tankmanTalkAudio:FlxSound;
var distorto:FlxSound;
var oldZoom:Float;

function create() {

    oldZoom = PlayState.defaultCamZoom;
    PlayState.defaultCamZoom = 1;
    PlayState.dad.visible = false;
    distorto = FlxG.sound.play(Paths.music("DISTORTO"), 0.6);
    distorto.pause();

    tankmanTalkAudio = FlxG.sound.play(Paths.sound("tank/tankSong2"));
    tankmanTalkAudio.pause();

    tankmanTalk = new FlxSprite(PlayState.dad.x, PlayState.dad.y);
    tankmanTalk.frames = Paths.getSparrowAtlas('tank/cutscene/guns-talk');
    tankmanTalk.antialiasing = true;
    tankmanTalk.animation.addByPrefix("talk", "TANK TALK 2", 24, false);
    tankmanTalk.offset.set(0, 10);

    PlayState.insert(global["level"], tankmanTalk);

    distorto.fadeIn(5, 0, 0.4);
    distorto.play();
    tankmanTalkAudio.play();
    tankmanTalk.animation.play("talk");
}

function update(elapsed:Float) {
    PlayState.camFollow.setPosition(PlayState.dad.getMidpoint().x + 150 + PlayState.dad.camOffset.x, PlayState.dad.getMidpoint().y - 100 + PlayState.dad.camOffset.y);
    tankmanTalk.animation.curAnim.curFrame = Std.int(tankmanTalkAudio.time / tankmanTalkAudio.length * tankmanTalk.animation.curAnim.frames.length);
    if (tankmanTalkAudio.time > 4150) {
        // gf cries
        PlayState.gf.playAnim("sad");
        FlxG.camera.zoom = PlayState.defaultCamZoom + (Math.sin(FlxEase.quartOut(FlxMath.bound((tankmanTalkAudio.time - 4150) / 1500, 0, 1)) * Math.PI) * 0.1);
    }
    if (tankmanTalk.animation.curAnim.finished || !tankmanTalkAudio.playing) {
        PlayState.remove(tankmanTalk);
        tankmanTalk.destroy();
        distorto.fadeOut(0.5, 0, function() {
            distorto.stop();
        });
        PlayState.defaultCamZoom = oldZoom;
        PlayState.dad.visible = true;
        startCountdown();
    }
}