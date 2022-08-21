function create() {
    var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
        -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
    blackShit.scrollFactor.set();
    PlayState.add(blackShit);
    PlayState.camHUD.visible = false;

    FlxG.sound.play(Paths.sound('Lights_Shut_off'));
}

function update(elapsed) {
    end();
}