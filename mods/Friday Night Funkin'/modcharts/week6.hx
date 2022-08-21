import("openfl.filters.ShaderFilter");

var three:FlxSound = null;
var ready:FlxSound = null;
var set:FlxSound = null;
var date:FlxSound = null;

var shader = null;
function create() {
    FlxG.camera.addShader(shader = new CustomShader(Paths.shader("mosaic")));
    FlxG.camera.filtersEnabled = true;
    PlayState.isWidescreen = false;
    
    three = Paths.sound("intro3-pixel");
    ready = Paths.sound("intro2-pixel");
    set = Paths.sound("intro1-pixel");
    date = Paths.sound("introGo-pixel");

    PlayState.gf.scrollFactor.set(5 / 6, 5 / 6);
    global["shader"] = shader;
    FlxG.camera.antialiasing = false;
    FlxG.camera.pixelPerfectRender = true;
    FlxG.game.stage.quality = 2;
}
var smallCamX:Float = 0;
var smallCamY:Float = 0;
function update(elapsed) {

    FlxG.camera.antialiasing = false;
    FlxG.camera.pixelPerfectRender = true;
    FlxG.game.stage.quality = 2;

    PlayState.camFollow.x -= (PlayState.camFollow.x) % 6;
    PlayState.camFollow.y -= (PlayState.camFollow.y) % 6;


    shader.shaderData.uBlocksize.value = [6 / FlxG.scaleMode.width * (FlxG.scaleMode.gameSize.x), 6 / FlxG.scaleMode.height * FlxG.scaleMode.gameSize.y];

    var small = FlxG.scaleMode.gameSize.x < FlxG.scaleMode.width || FlxG.scaleMode.gameSize.y < FlxG.scaleMode.height;
    if (small) {
        shader.shaderData.size.value = [FlxG.scaleMode.gameSize.x < (FlxG.scaleMode.width / 2) ? 0 : 1];
        FlxG.camera.scroll.x = Math.floor(smallCamX / 6) * 6;
        FlxG.camera.scroll.y = Math.floor(smallCamY / 6) * 6;
    } else {
        shader.shaderData.size.value = [2];
        smallCamX = FlxG.camera.scroll.x;
        smallCamY = FlxG.camera.scroll.y;
    }
    
    smallCamX = FlxMath.lerp(smallCamX, PlayState.camFollow.x + FlxG.camera.targetOffset.x - 640, CoolUtil.wrapFloat(0.04 * 60 * elapsed, 0, 1));
    smallCamY = FlxMath.lerp(smallCamY, PlayState.camFollow.y + FlxG.camera.targetOffset.y - 360, CoolUtil.wrapFloat(0.04 * 60 * elapsed, 0, 1));
    
    FlxG.camera.zoom = 1;
    if (PlayState.health < 0) { // YOU WILL DIE!!!
        shader.shaderData.uBlocksize.value = [1, 1];
    }

    
    for (s in PlayState.members) {
        if (Std.isOfType(s, FlxSprite) && !Std.isOfType(s, Note)) {
            if (s.velocity != null && s.velocity.x == 0 && s.velocity.y == 0 && !s.cameras.contains(PlayState.camHUD)) {
                s.x -= s.x % 6;
                s.y -= s.y % 6;
                if (s.offset != null) {
                    s.offset.x -= s.offset.x % 6;
                    s.offset.y -= s.offset.y % 6;
                }
            }
        }
    }
}

function onGuiPopup() {
    for(m in PlayState.members) {
        if (Std.isOfType(m, FlxSprite)) {
            m.antialiasing = false;
            if (Std.isOfType(m, FlxText)) {
                // lol it's actually a built in flixel font
                m.setFormat("Nokia Cellphone FC Small", m.size, m.color, m.alignment, m.borderStyle, 0xFF222222);
                m.borderSize = 2;
            }
        }
    }
    // PlayState.msScoreLabel.size = 24;
}

function onCountdown(countdown:Int) {
    switch(countdown) {
        case 3:
            FlxG.sound.play(three);
        case 2:
            FlxG.sound.play(ready);

            var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image("weeb/pixelUI/ready-pixel"));
            ready.scrollFactor.set();
            ready.updateHitbox();
            ready.setGraphicSize(Std.int(ready.width * 6));
            ready.screenCenter();
            PlayState.add(ready);

            FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
                ease: FlxEase.cubeInOut,
                onComplete: function(twn:FlxTween)
                {
                    ready.destroy();
                }
            });

        case 1:
            FlxG.sound.play(set);

            var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("weeb/pixelUI/set-pixel"));
            set.scrollFactor.set();
            set.updateHitbox();
            set.setGraphicSize(Std.int(set.width * 6));
            set.screenCenter();
            PlayState.add(set);

            FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
                ease: FlxEase.cubeInOut,
                onComplete: function(twn:FlxTween)
                {
                    set.destroy();
                }
            });
        case 0:
            FlxG.sound.play(date);

            var date:FlxSprite = new FlxSprite().loadGraphic(Paths.image("weeb/pixelUI/date-pixel"));
            date.scrollFactor.set();
            date.updateHitbox();
            date.setGraphicSize(Std.int(date.width * 6));
            date.screenCenter();
            PlayState.add(date);

            FlxTween.tween(date, {y: date.y += 100, alpha: 0}, Conductor.crochet / 1000, {
                ease: FlxEase.cubeInOut,
                onComplete: function(twn:FlxTween)
                {
                    date.destroy();
                }
            });
            
    }
    return false;
}

function onShowCombo(combo:Int, coolText:FlxText) {
    
    if (!(combo >= 10 || combo == 0))
        return;

    var seperatedScore:Array<Int> = [];

    var stringCombo = Std.string(combo);
    for(i in 0...stringCombo.length) {
        seperatedScore.push(Std.parseInt(stringCombo.charAt(i)));
    }

    while(seperatedScore.length < 3) seperatedScore.insert(0, 0);
    

    var daLoop:Int = 0;
    for (i in seperatedScore)
    {
        var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('weeb/pixelUI/num' + Std.int(i) + '-pixel'));
        numScore.screenCenter();
        numScore.x = coolText.x + (43 * daLoop) - 90;
        numScore.y += 80;

        
        numScore.scale.set(6, 6);
        numScore.updateHitbox();

        numScore.acceleration.y = FlxG.random.int(200, 300);
        numScore.velocity.y -= FlxG.random.int(140, 160);
        numScore.velocity.x = FlxG.random.float(-5, 5);

        PlayState.add(numScore);

        FlxTween.tween(numScore, {alpha: 0}, 0.2, {
            onComplete: function(tween:FlxTween)
            {
                numScore.destroy();
            },
            startDelay: Conductor.crochet * 0.002
        });

        daLoop++;
    }

    return false;
}