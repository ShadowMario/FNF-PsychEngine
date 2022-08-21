var roast:FlxSound;
var availableRoasts:Array<Int> = [2, 4, 5, 6, 7, 9, 10, 11, 12, 14, 15, 16, 18, 19, 20, 22, 23, 24, 25];


function update(elapsed:Float) {
    if (state.bf.animation.curAnim.name == 'deathLoop' && roast == null) {
        var s = 'tank/jeffGameover/jeffGameover-' + Std.string(availableRoasts[FlxG.random.int(0, availableRoasts.length)]);
        roast = FlxG.sound.play(Paths.sound(s), 1);
    }
    if (FlxG.sound.music != null) {
        if (roast != null) {
            if (roast.playing) {
                FlxG.sound.music.volume = 0.4;
            } else {
                FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume, 1, 0.125 * 60 * elapsed);
            }
        } else {
            FlxG.sound.music.volume = 0.4;
        }
    }
}