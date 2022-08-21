if (EngineSettings.useStressMP4) {
    // USE MP4
    function create() {
        var wasWidescreen = PlayState.isWidescreen;
        var videoSprite:FlxSprite = null;
        videoSprite = MP4Video.playMP4(Paths.video('stressCutscene'), function() {
                PlayState.remove(videoSprite);
                PlayState.isWidescreen = wasWidescreen;
                startCountdown();
            }, false);
        videoSprite.cameras = [PlayState.camHUD];
        videoSprite.scrollFactor.set();
        PlayState.isWidescreen = false;
        PlayState.add(videoSprite);
    }

} else {
    // USE NEW ANIMATION
    var tankmanTalk1:FlxSprite;
    var tankmanTalk2:FlxSprite;
    var gf:FlxSprite;
    var gfTurn1:FlxSprite;
    var gfTurn2:FlxSprite;
    var gfTurn3:FlxSprite;
    var gfTurn4:FlxSprite;
    var gfTurn5:FlxSprite;
    var audio:FlxSound;
    var oldZoom:Float;
    var bf:FlxSprite;

    function create() {
        PlayState.gf.visible = false;
        PlayState.dad.visible = false;

        oldZoom = PlayState.defaultCamZoom;
        PlayState.defaultCamZoom = 1;
        // PlayState.defaultCamZoom /= 2;
        // PlayState.dad.alpha = 0.5;
        // PlayState.gf.alpha = 0.5;

        tankmanTalk1 = new FlxSprite(PlayState.dad.x, PlayState.dad.y);
        tankmanTalk1.frames = Paths.getSparrowAtlas('tank/cutscene/stress-talk-1');
        tankmanTalk1.antialiasing = true;
        tankmanTalk1.animation.addByPrefix("talk", "TANK TALK 3 P1 UNCUT", 24, false);
        tankmanTalk1.animation.play("talk");
        tankmanTalk1.offset.set(93, 33);

        tankmanTalk2 = new FlxSprite(PlayState.dad.x, PlayState.dad.y);
        tankmanTalk2.frames = Paths.getSparrowAtlas('tank/cutscene/stress-talk-2');
        tankmanTalk2.antialiasing = true;
        tankmanTalk2.animation.addByPrefix("talk", "TANK TALK 3 P2 UNCUT", 24, false);
        tankmanTalk2.animation.play("talk");
        tankmanTalk2.offset.set(4, 28);

        gf = new FlxSprite(PlayState.gf.x, PlayState.gf.y);
        gf.frames = Paths.getCharacter("Friday Night Funkin':gf-tankmen");
        gf.offset.set(99 * 1.1, -129 * 1.1);
        gf.scrollFactor.set(PlayState.gf.scrollFactor.x, PlayState.gf.scrollFactor.y);
        gf.animation.addByPrefix('dance', "GF Dancing at Gunpoint", 24, true);
        gf.antialiasing = true;
        gf.animation.play('dance');

        gfTurn1 = new FlxSprite(400, 130);
        gfTurn1.frames = Paths.getSparrowAtlas('tank/cutscene/gf-turn-1');
        gfTurn1.antialiasing = true;
        gfTurn1.animation.addByPrefix("turn", "GF STARTS TO TURN PART 1", 24, true);
        gfTurn1.animation.play("turn");
        gfTurn1.scrollFactor.set(PlayState.gf.scrollFactor.x, PlayState.gf.scrollFactor.y);
        gfTurn1.offset.set(124 * 1.1 + 1, 67 * 1.1 + 1);
        

        gfTurn2 = new FlxSprite(400, 130);
        gfTurn2.frames = Paths.getSparrowAtlas('tank/cutscene/gf-turn-2');
        gfTurn2.antialiasing = true;
        gfTurn2.animation.addByPrefix("turn", "GF STARTS TO TURN PART 2", 24, true);
        gfTurn2.animation.play("turn");
        gfTurn2.scrollFactor.set(PlayState.gf.scrollFactor.x, PlayState.gf.scrollFactor.y);
        gfTurn2.offset.set(326 * 1.1 + 4, 468 * 1.1 + 5);
        

        gfTurn3 = new FlxSprite(400, 130);
        gfTurn3.frames = Paths.getSparrowAtlas('tank/cutscene/pico-arrives-1');
        gfTurn3.antialiasing = true;
        gfTurn3.animation.addByPrefix("turn", "PICO ARRIVES PART 1", 24, true);
        gfTurn3.animation.play("turn");
        gfTurn3.scrollFactor.set(PlayState.gf.scrollFactor.x, PlayState.gf.scrollFactor.y);
        gfTurn3.offset.set(228 * 1.1, 227 * 1.1);
        

        gfTurn4 = new FlxSprite(400, 130);
        gfTurn4.frames = Paths.getSparrowAtlas('tank/cutscene/pico-arrives-2');
        gfTurn4.antialiasing = true;
        gfTurn4.animation.addByPrefix("turn", "PICO ARRIVES PART 2", 24, true);
        gfTurn4.animation.play("turn");
        gfTurn4.scrollFactor.set(PlayState.gf.scrollFactor.x, PlayState.gf.scrollFactor.y);
        gfTurn4.offset.set(500 + (342 * 1.1), 500 + (-80 * 1.1));
        

        gfTurn5 = new FlxSprite(400, 130);
        gfTurn5.frames = Paths.getSparrowAtlas('tank/cutscene/pico-arrives-3');
        gfTurn5.antialiasing = true;
        gfTurn5.animation.addByPrefix("turn", "PICO ARRIVES PART 3", 24, true);
        gfTurn5.animation.play("turn");
        gfTurn5.scrollFactor.set(PlayState.gf.scrollFactor.x, PlayState.gf.scrollFactor.y);
        gfTurn5.offset.set(500 + (312 * 1.1) + 1, 500 + (-265 * 1.1) - 7);
        gfTurn5.visible = true;

        bf = new FlxSprite(PlayState.boyfriend.x, PlayState.boyfriend.y).loadGraphic(Paths.image('tank/cutscene/bf'));
        bf.offset.set(PlayState.boyfriend.offset.x, PlayState.boyfriend.offset.y);
        bf.antialiasing = true;

        PlayState.boyfriend.visible = false;
        
        PlayState.insert(global["level"], tankmanTalk1);
        PlayState.insert(global["level"], tankmanTalk2);
        PlayState.insert(global["level"], bf);
        PlayState.insert(PlayState.members.indexOf(PlayState.gf), gf);
        PlayState.insert(PlayState.members.indexOf(PlayState.gf), gfTurn1);
        PlayState.insert(PlayState.members.indexOf(PlayState.gf), gfTurn2);
        PlayState.insert(PlayState.members.indexOf(PlayState.gf), gfTurn3);
        PlayState.insert(PlayState.members.indexOf(PlayState.gf), gfTurn4);
        PlayState.insert(PlayState.members.indexOf(PlayState.gf), gfTurn5);

        audio = FlxG.sound.play(Paths.sound('tank/stressCutscene'));
    }

    var doHug:Bool = true;
    var oldFollowLerp:Float = 0;
    function update(elapsed:Float) {
        /**
            CAMERA
        **/
        if (audio.time < 14750) {
            PlayState.camFollow.setPosition(PlayState.dad.getMidpoint().x + 150 + PlayState.dad.camOffset.x, PlayState.dad.getMidpoint().y - 100 + PlayState.dad.camOffset.y);
        } else if (audio.time < 17237) {
            var t = (audio.time - 14750) / (17237 - 14750);
            var gfCamPos = gf.getMidpoint();
            PlayState.camFollow.setPosition(gfCamPos.x - 100, gfCamPos.y);
            FlxG.camera.zoom = FlxMath.lerp(PlayState.defaultCamZoom, 1.25, FlxEase.quadInOut(t));
        } else if (audio.time < 20000) {
            PlayState.defaultCamZoom = oldZoom;
            FlxG.camera.zoom = oldZoom;
        } else if (audio.time < 31250) {
            PlayState.camFollow.setPosition(PlayState.dad.getMidpoint().x + 150 + PlayState.dad.camOffset.x + 200, PlayState.dad.getMidpoint().y - 100 + PlayState.dad.camOffset.y);
        } else if (audio.time < 32250) {
            for(e in global["tanks"]) e.visible = false;
            PlayState.boyfriend.playAnim("singUPmiss");
            PlayState.camFollow.setPosition(PlayState.boyfriend.getMidpoint().x, PlayState.boyfriend.getMidpoint().y);
            if (oldFollowLerp == 0) {
                oldFollowLerp = FlxG.camera.followLerp;
                FlxG.camera.followLerp = 1;
            }
            FlxG.camera.zoom = 1.25;
        } else {
            for(e in global["tanks"]) e.visible = true;
            
            PlayState.boyfriend.lastHit = -50000;
            PlayState.boyfriend.dance(true);
            PlayState.boyfriend.animation.curAnim.curFrame = PlayState.boyfriend.animation.curAnim.frames.length - 1;
            
            FlxG.camera.followLerp = 1;
            PlayState.camFollow.setPosition(PlayState.dad.getMidpoint().x + 150 + PlayState.dad.camOffset.x + 200, PlayState.dad.getMidpoint().y - 100 + PlayState.dad.camOffset.y);
            FlxG.camera.zoom = PlayState.defaultCamZoom;
        }

        /**
            TANKMAN
        **/
        if (audio.time < 17042) {
            tankmanTalk1.visible = true;
            tankmanTalk2.visible = false;
            tankmanTalk1.animation.curAnim.curFrame = Std.int(audio.time / 17042 * tankmanTalk1.animation.curAnim.frames.length);
        } else {
            if (audio.time > 19250) {
                tankmanTalk1.visible = false;
                tankmanTalk2.visible = true;
                tankmanTalk2.animation.curAnim.curFrame = Std.int((audio.time - 19250) / (361 / 24 * 1000) * tankmanTalk2.animation.curAnim.frames.length);
            }
        }

        /**
            GIRLFRIEND & PICO
        **/
        if (audio.playing) {
            if (audio.time > 21248) {
                gf.visible = false;
                gfTurn1.visible = false;
                gfTurn2.visible = false;
                gfTurn3.visible = false;
                gfTurn4.visible = false;
                gfTurn5.visible = false;
        
                PlayState.gf.visible = true;
                PlayState.gf.dance();
            } else if (audio.time > 19620) {
                gf.visible = false;
                gfTurn1.visible = false;
                gfTurn2.visible = false;
                gfTurn3.visible = false;
                gfTurn4.visible = false;
                gfTurn5.visible = true;
        
                var t = audio.time - 19620;
                gfTurn5.animation.curAnim.curFrame = Std.int(t / (21248 - 19620) * gfTurn5.animation.curAnim.frames.length);
            } else if (audio.time > 18245) {
                gf.visible = false;
                gfTurn1.visible = false;
                gfTurn2.visible = false;
                gfTurn3.visible = false;
                gfTurn4.visible = true;
                gfTurn5.visible = false;
        
                var t = audio.time - 18245;
                gfTurn4.animation.curAnim.curFrame = Std.int(t / (19620 - 18245) * 32);
            } else if (audio.time > 17237) {
                gf.visible = false;
                gfTurn1.visible = false;
                gfTurn2.visible = false;
                gfTurn3.visible = true;
                gfTurn4.visible = false;
                gfTurn5.visible = false;
                bf.visible = false;
                PlayState.boyfriend.visible = true;
                if (doHug) {
                    PlayState.boyfriend.playAnim("bfCatch");
                    doHug = false;
                } else {
                    if (PlayState.boyfriend.animation.curAnim.finished) {
                        PlayState.boyfriend.lastHit = -50000;
                        PlayState.boyfriend.dance(true);
                        PlayState.boyfriend.animation.curAnim.curFrame = PlayState.boyfriend.animation.curAnim.frames.length - 1;
                    }
                }
        
                var t = audio.time - 17237;
                gfTurn3.animation.curAnim.curFrame = Std.int(t / (18245 - 17237) * gfTurn3.animation.curAnim.frames.length);
            } else if (audio.time > 16284) {
                gf.visible = false;
                gfTurn1.visible = false;
                gfTurn2.visible = true;
                gfTurn3.visible = false;
                gfTurn4.visible = false;
                gfTurn5.visible = false;
        
                var t = audio.time - 16284;
                gfTurn2.animation.curAnim.curFrame = Std.int(t / (17237 - 16284) * gfTurn2.animation.curAnim.frames.length);
            } else if (audio.time > 14750) {
                gf.visible = false;
                gfTurn1.visible = true;
                gfTurn2.visible = false;
                gfTurn3.visible = false;
                gfTurn4.visible = false;
                gfTurn5.visible = false;
        
                var t = audio.time - 14750;
                gfTurn1.animation.curAnim.curFrame = Std.int(t / (16284 - 14750) * gfTurn1.animation.curAnim.frames.length);
            } else {
                gf.visible = true;
                gfTurn1.visible = false;
                gfTurn2.visible = false;
                gfTurn3.visible = false;
                gfTurn4.visible = false;
                gfTurn5.visible = false;
            }
        }
        

        if (!audio.playing) {
            PlayState.gf.visible = true;
            PlayState.dad.visible = true;

            for(e in [tankmanTalk1, tankmanTalk2, gfTurn1, gfTurn2, gfTurn3, gfTurn4, gfTurn5, gf]) {
                PlayState.remove(e);
                e.destroy();
            }

            FlxG.camera.followLerp = oldFollowLerp;
            startCountdown();
        }
    }
}