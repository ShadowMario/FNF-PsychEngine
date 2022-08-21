var tankmanRun:Array<FlxSprite> = [];
var tankmanSpawnTimes:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

GameOverSubstate.char = mod + ":bf-holding-gf-dead";
gfVersion = "pico-speakers";

function createPost() {
    for(i in 0...10) {
        var direction:Bool = (i % 2 == 0);
        var johnShotNumber = FlxG.random.int(1, 2);
        var tankmanThatIsRunning:FlxSprite = new FlxSprite(400 + (!direction ? -1250 : 1250), 250);
        tankmanThatIsRunning.frames = Paths.getSparrowAtlas('tank/tankmanKilled1');
        tankmanThatIsRunning.animation.addByPrefix("run", "tankman running", 24);
        tankmanThatIsRunning.animation.addByPrefix("shot", "John Shot " + johnShotNumber, 24, false);
        tankmanThatIsRunning.setGraphicSize(Std.int(tankmanThatIsRunning.width * 0.8));
        tankmanThatIsRunning.scrollFactor.set(0.95, 0.95);
        tankmanThatIsRunning.antialiasing = true;
        //tankmanThatIsRunning.velocity.x = !direction ? 400 : -400;
        tankmanThatIsRunning.flipX = !direction;
        tankmanThatIsRunning.alpha = 1;
        
        tankmanThatIsRunning.animation.play("run");
        PlayState.insert(PlayState.members.indexOf(global["tankGround"]), tankmanThatIsRunning);
        tankmanRun.push(tankmanThatIsRunning);
    }
}


function spawnTankmen() {
    var f = tankmanRun.pop();
    f.animation.play("run", true);
    f.visible = true;
    tankmanRun.insert(0, f);
    tankmanSpawnTimes.pop();
    tankmanSpawnTimes.insert(0, Conductor.songPosition);
}

function update(elapsed:Float) {
    var i = 0;
    for(e in tankmanRun) {
        e.updateHitbox();
        if (e.flipX) {
            e.offset.x += e.width;
        }
        if (e.visible) {
            var spawnTime = tankmanSpawnTimes[i];
            if (Conductor.songPosition < spawnTime + 1500) {
                var diff = Conductor.songPosition - spawnTime;
                if (e.flipX) {
                    e.x = FlxMath.lerp(-1500, 500, FlxMath.bound(diff / 1500, 0, 1));
                } else {
                    e.x = FlxMath.lerp(1500 + 850, 850, FlxMath.bound(diff / 1500, 0, 1));
                }
            } else {
                if (e.animation.curAnim.name != "shot") {
                    e.animation.play("shot");
                }
                if (e.animation.curAnim.finished) e.visible = false;
            }
        }
        i++;
    }
}
global["spawnTankmen"] = spawnTankmen;