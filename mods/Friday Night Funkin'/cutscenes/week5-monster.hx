var blackScreen:FlxSprite = null;
var t:Float = 0;
var phase = 0;
function create() {
    blackScreen = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
    PlayState.add(blackScreen);
    blackScreen.scrollFactor.set();
    PlayState.camFollow.y = -2050;
    PlayState.camFollow.x = 200;
    FlxG.camera.focusOn(PlayState.camFollow.getPosition());
    FlxG.camera.zoom = 1.5;
}
function update(elapsed) {
    t += elapsed;

    if (phase == 0 && t > 0.8) {
        FlxG.sound.play(Paths.sound('Lights_Turn_On'));
        PlayState.remove(blackScreen);
        phase = 1;
        FlxTween.tween(FlxG.camera, {zoom: PlayState.defaultCamZoom}, 2.5, {
                        ease: FlxEase.quadInOut,
                        onComplete: function(twn:FlxTween)
                        {
                            startCountdown();
                        }
                    });
    }
}