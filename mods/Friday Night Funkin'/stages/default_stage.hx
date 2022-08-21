var stageFront:FlxSprite = null;

function create() {
    PlayState.defaultCamZoom = 0.8;

    var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('default_stage/stageback'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.9, 0.9);
    bg.active = false;
    PlayState.add(bg);

    stageFront = new FlxSprite(-690, 600).loadGraphic(Paths.image('default_stage/stagefront'));
    stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
    stageFront.updateHitbox();
    stageFront.antialiasing = true;
    stageFront.scrollFactor.set(1, 1);
    stageFront.active = false;
	stageFront.shader = new CustomShader(mod + ':3D Floor');
    PlayState.add(stageFront);

    var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('default_stage/stagecurtains'));
    stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
    stageCurtains.updateHitbox();
    stageCurtains.antialiasing = true;
    stageCurtains.scrollFactor.set(1.4, 0.9);
    stageCurtains.active = false;
    PlayState.add(stageCurtains);

    PlayState.gf.scrollFactor.set(1.125, 1.05);
    PlayState.boyfriend.scrollFactor.set(1.15, 1.1);
    PlayState.dad.scrollFactor.set(1.15, 1.1);

}

function update(elapsed:Float) {
	stageFront.shader.shaderData.curveX.value = [(((FlxG.camera.scroll.x + (FlxG.width / 2)) - stageFront.getMidpoint().x) / 0.6) / Math.PI / stageFront.width];
    stageFront.shader.shaderData.curveY.value = [(((FlxG.camera.scroll.y + (FlxG.height / 2)) - stageFront.getMidpoint().y) * stageFront.scrollFactor.y) / Math.PI / stageFront.height];
}
