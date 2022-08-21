import("openfl.filters.ShaderFilter");

var phillyTrain:FlxSprite = null;
var bg:FlxSprite = null;
var city:FlxSprite = null;
var streetBehind:FlxSprite = null;
var street:FlxSprite = null;
var light:FlxSprite = null;

var camShader:CustomShader;
var camShader2:CustomShader;

var bgParticlesBF:FlxSprite;
var bgParticlesPico:FlxSprite;
var transitionTrain:FlxSprite;


function destroy() {
    FlxG.camera.bgColor = 0xFF000000;
}

function create() {
    stage = PlayState_.stage;
    
    phillyTrain = global['phillyTrain'];
    bg = global['bg'];
    city = global['city'];
    street = global['street'];
    streetBehind = global['streetBehind'];
    light = global['light'];

    camShader = new CustomShader(Paths.shader("blammedhud"));
    camShader2 = new CustomShader(Paths.shader("blammedhud"));
    camShader.shaderData.isUI.value = [false];
    camShader2.shaderData.isUI.value = [true];

    PlayState.camHUD.setFilters([new ShaderFilter(camShader2)]);
    PlayState.camHUD.filtersEnabled = false;

    FlxG.camera.setFilters([new ShaderFilter(camShader)]);
    FlxG.camera.filtersEnabled = false;

    bgParticlesBF = new FlxSprite(-100);
    bgParticlesPico = new FlxSprite(-400);

    for(bgParticles in [bgParticlesBF, bgParticlesPico]) {
        bgParticles.loadGraphic(Paths.image("philly/particles"));
        bgParticles.antialiasing = true;
        bgParticles.scale.x *= 1.5;
        bgParticles.scale.y *= 1.5;
        bgParticles.updateHitbox();
        bgParticles.shader = new CustomShader(Paths.shader("blammedparticles"));
        bgParticles.shader.shaderData.horizontalDistort.value = [0];
        bgParticles.shader.shaderData.verticalScroll.value = [0];
        bgParticles.visible = false;
    }

    
    bgParticlesBF.angle = 270;
    bgParticlesPico.angle = 90;

    transitionTrain = new FlxSprite(3000, 150);
    transitionTrain.loadGraphic(Paths.image("philly/train"));
    transitionTrain.scrollFactor.set(1.5, 1);
    transitionTrain.scale.set(2.25, 2.25);
    transitionTrain.updateHitbox();
    transitionTrain.antialiasing = true;


    PlayState.insert(PlayState.members.indexOf(streetBehind), bgParticlesBF);
    PlayState.insert(PlayState.members.indexOf(streetBehind), bgParticlesPico);

    camShader.shaderData.enabled.value = [true];
    camShader2.shaderData.enabled.value = [true];
    camShader.shaderData.diff.value = [0];
    camShader2.shaderData.diff.value = [0];

    // if (CoolUtil.isDevMode()) PlayState.defaultCamZoom = 0.5; // debug shit
}

function createPost() {
    PlayState.add(transitionTrain);
}

function updatePost(elapsed:Float) {
    var color = new FlxColor(light.color);
    for (i in [camShader, camShader2]) {
        i.shaderData.r.value = [color.redFloat];
        i.shaderData.g.value = [color.greenFloat];
        i.shaderData.b.value = [color.blueFloat];
    }
    if (PlayState.curBeat >= 128 && PlayState.curBeat < 192) {
        light.colorTransform.redMultiplier = light.colorTransform.greenMultiplier = light.colorTransform.blueMultiplier = 0;
    }
}

var particlesFloatSpeed:Float = 0;

function update(elapsed:Float) {
    camShader.shaderData.diff.value = [FlxMath.lerp(camShader.shaderData.diff.value[0], 0, 0.125 * elapsed * 60)];
    camShader2.shaderData.diff.value =  [camShader.shaderData.diff.value] * 2;
    particlesFloatSpeed = FlxMath.lerp(particlesFloatSpeed, 0.1, 0.125 * elapsed * 60);
    bgParticlesPico.shader.shaderData.verticalScroll.value = bgParticlesBF.shader.shaderData.verticalScroll.value = [(bgParticlesBF.shader.shaderData.verticalScroll.value[0] + (particlesFloatSpeed * elapsed)) % 1];
    bgParticlesPico.shader.shaderData.horizontalDistort.value = bgParticlesBF.shader.shaderData.horizontalDistort.value = [bgParticlesBF.shader.shaderData.horizontalDistort.value[0] + elapsed];
    if (PlayState.curBeat >= 128 && PlayState.curBeat < 192) {
        PlayState.defaultCamZoom = FlxMath.lerp(1.05, 1.25, Math.floor((PlayState.curBeat - 128) / 4) % 4 / 4);
    } else {
        PlayState.defaultCamZoom = 1;
    }
    if (PlayState.section != null) {
        bgParticlesBF.alpha = FlxMath.lerp(bgParticlesBF.alpha, PlayState.section.mustHitSection ? 1 : 0, 0.125 * elapsed * 60);
        bgParticlesPico.alpha = FlxMath.lerp(bgParticlesPico.alpha, PlayState.section.mustHitSection ? 0 : 1, 0.125 * elapsed * 60);
    }
}
function stepHit(curStep:Int) {
    if (!(PlayState.autoCamZooming = (curStep < (128 * 4) || curStep >= (192 * 4)))) {
        // boom
        switch(curStep % 64) {
            case 0, 12, 20, 32, 38, 40, 44, 52:
                FlxG.camera.zoom += 0.015;
				PlayState.camHUD.zoom += 0.03;
                camShader2.shaderData.diff.value = [0.0075];
                particlesFloatSpeed = 1;
                fadeThing = -0.5;
        }
        if (curStep % 16 == 8)
            PlayState.gf.playAnim("cheer");
        if (curStep % 16 == 0)
            PlayState.gf.dance(true);
    }
}
function beatHit(curBeat:Int) {
    if (curBeat == 96) PlayState.defaultCamZoom = 1.15;
    if (curBeat == 127) {
        transitionTrain.visible = true;
        transitionTrain.velocity.x = -30000;
        transitionTrain.color = 0xFF333333;
    }
    if (curBeat == 128) {
        global["blammedEffectOn"] = true; // to prevent train cool shit to override colors
        for(char in [PlayState.boyfriend, PlayState.dad]) {
            char.addCameraOffset("singLEFT", -25, 0);
            char.addCameraOffset("singDOWN", 0, 25);
            char.addCameraOffset("singUP", 0, -25);
            char.addCameraOffset("singRIGHT", 25, 0);
        }
        transitionTrain.colorTransform.redMultiplier = transitionTrain.colorTransform.greenMultiplier = transitionTrain.colorTransform.blueMultiplier = 0;
        transitionTrain.colorTransform.redOffset = transitionTrain.colorTransform.greenOffset = transitionTrain.colorTransform.blueOffset = 255;
        // FlxG.camera.flash(0xFF000000, 2);
        FlxG.camera.bgColor = 0xFFFFFFFF;

        bgParticlesPico.visible = bgParticlesBF.visible = PlayState.camHUD.filtersEnabled = FlxG.camera.filtersEnabled = true;

        PlayState.healthBar.visible = false;
        PlayState.camFollowLerp = 0.06;

        phillyTrain.visible = false;
        bg.visible = false;
        city.visible = false;
        // street.visible = false;
    }
    if (curBeat == 192) {
        global["blammedEffectOn"] = false; // to prevent train cool shit to override colors
        for(char in [PlayState.boyfriend, PlayState.dad]) {
            char.addCameraOffset("singLEFT", 0, 0);
            char.addCameraOffset("singDOWN", 0, 0);
            char.addCameraOffset("singUP", 0, 0);
            char.addCameraOffset("singRIGHT", 0, 0);
        }
        FlxG.camera.flash(0xFF000000, 2);
        FlxG.camera.bgColor = 0xFF000000;
        
        phillyTrain.visible = true;
        bg.visible = true;
        city.visible = true;
        
        bgParticlesPico.visible = bgParticlesBF.visible = PlayState.camHUD.filtersEnabled = FlxG.camera.filtersEnabled = false;

        PlayState.healthBar.visible = true;
        PlayState.camFollowLerp = 0.04;
    }
}