import("openfl.utils.Assets");

var box:FlxSprite = null;
var curCharacter:String = '';
var dialogue:Alphabet = null;
var dialogueList:Array<String> = [];
var swagDialogue:FlxTypeText = null;
var dropText:FlxText = null;
var finishThing:Void->Void = null;
var portraitLeft:FlxSprite = null;
var portraitRight:FlxSprite = null;
var handSelect:FlxSprite = null;
var bgFade:FlxSprite = null;
var dialogueOpened:Bool = false;
var dialogueStarted:Bool = false;
var isEnding:Bool = false;
var face:FlxSprite = null;
function addDialogue() {
    var hasDialog = false;
	switch (PlayState.song.song.toLowerCase())
	{
		case 'senpai':
			hasDialog = true;
			box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
			box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
			box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
		case 'roses':
			hasDialog = true;

			box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
			box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
			box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

		case 'thorns':
			hasDialog = true;
			box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
			box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
			box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

			face = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
			face.setGraphicSize(Std.int(face.width * 6));
            face.scrollFactor.set();
			PlayState.add(face);
	}
    
		
    portraitLeft = new FlxSprite(-20, 40);
    portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
    portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
    portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState_.daPixelZoom * 0.9));
    portraitLeft.updateHitbox();
    portraitLeft.scrollFactor.set();
    PlayState.add(portraitLeft);
    portraitLeft.visible = false;

    portraitRight = new FlxSprite(0, 40);
    portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
    portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
    portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState_.daPixelZoom * 0.9));
    portraitRight.updateHitbox();
    portraitRight.scrollFactor.set();
    PlayState.add(portraitRight);
    portraitRight.visible = false;
    
    box.animation.play('normalOpen');
    box.setGraphicSize(Std.int(box.width * PlayState_.daPixelZoom * 0.9));
    box.scrollFactor.set();
    box.updateHitbox();
    PlayState.add(box);

    box.screenCenter(FlxAxes.X);
    portraitLeft.screenCenter(FlxAxes.X);

    handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
    handSelect.scrollFactor.set();
    PlayState.add(handSelect);

    dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
    dropText.font = 'Pixel Arial 11 Bold';
    dropText.color = 0xFFD89494;
    dropText.scrollFactor.set();
    PlayState.add(dropText);

    swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "sex", 32);
    swagDialogue.font = 'Pixel Arial 11 Bold';
    swagDialogue.color = 0xFF3F2021;
    swagDialogue.scrollFactor.set();
    swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
    PlayState.add(swagDialogue);
}
function create()
{
    if (PlayState.song.song.toLowerCase() == "roses") {
		FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
    }
    dialogueList = Assets.getText(Paths.txt(PlayState.song.song.toLowerCase() + "/" + PlayState.song.song.toLowerCase() + "Dialogue")).split("\n");
    for (i in 0...dialogueList.length)
        dialogueList[i] = StringTools.trim(dialogueList[i]);
    trace(dialogueList);

	var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
	black.scrollFactor.set();
	PlayState.add(black);

	var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
	red.scrollFactor.set();

	var senpaiEvil:FlxSprite = new FlxSprite();
	senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
	senpaiEvil.scrollFactor.set();
	senpaiEvil.updateHitbox();
	senpaiEvil.screenCenter();

	if (PlayState.song.song.toLowerCase() == 'roses' || PlayState.song.song.toLowerCase() == 'thorns')
	{
		PlayState.remove(black);

		if (PlayState.song.song.toLowerCase() == 'thorns')
		{
			PlayState.add(red);
		}
	}

	// CREATE DIALOGUE
	switch (PlayState.song.song.toLowerCase())
	{
		case 'senpai':
			FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		case 'thorns':
			FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
	}

	

	box = new FlxSprite(-20, 45);
    bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
    bgFade.scrollFactor.set();
    bgFade.alpha = 0;
    PlayState.add(bgFade);

	

	new FlxTimer().start(0.3, function(tmr:FlxTimer)
	{
		black.alpha -= 0.15;

		if (black.alpha > 0)
		{
			tmr.reset(0.3);
		}
		else
		{
			if (PlayState.song.song.toLowerCase() == 'thorns')
			{
				PlayState.add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
					{
						swagTimer.reset();
					}
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							PlayState.remove(senpaiEvil);
							PlayState.remove(red);
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								addDialogue();
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			} else {

                new FlxTimer().start(0.83, function(tmr:FlxTimer)
                {
                    bgFade.alpha += (1 / 5) * 0.7;
                    if (bgFade.alpha > 0.7)
                        bgFade.alpha = 0.7;
                }, 5);
				addDialogue();
            }

			PlayState.remove(black);
		}
	});
}

function update(elapsed) {
    PlayState.camFollow.x = PlayState.gf.getMidpoint().x;
    PlayState.camFollow.y = PlayState.gf.getMidpoint().y;
    FlxG.camera.scroll.x = PlayState.camFollow.x - (FlxG.width / 2);
    FlxG.camera.scroll.y = PlayState.camFollow.y - (FlxG.height / 2);

    
    FlxG.camera.scroll.x -= FlxG.camera.scroll.x % 6;
    FlxG.camera.scroll.y -= FlxG.camera.scroll.y % 6;

    global["shader"].shaderData.uBlocksize.value = [1, 1];

    if (PlayState.song.song.toLowerCase() == 'roses' && portraitLeft != null)
        portraitLeft.visible = false;
    if (PlayState.song.song.toLowerCase() == 'thorns')
    {
        if (portraitLeft != null) portraitLeft.color = 0x00000000;
        swagDialogue.color = 0xFFFFFFFF;
        dropText.color = 0xFF000000;
    }

    if (dropText != null)
        dropText.text = swagDialogue.text;

    if (box != null)
        if (box.animation.curAnim != null)
        {
            if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
            {
                box.animation.play('normal');
                dialogueOpened = true;
            }
        }

    if (dialogueOpened && !dialogueStarted)
    {
        startDialogue();
        dialogueStarted = true;
    }

    if (FlxControls.justPressed.ANY  && dialogueStarted == true)
    {
        PlayState.remove(dialogue);
            
        FlxG.sound.play(Paths.sound('clickText'), 0.8);

        if (dialogueList[1] == null && dialogueList[0] != null)
        {
            if (!isEnding)
            {
                isEnding = true;

                if (PlayState.song.song.toLowerCase() == 'senpai' || PlayState.song.song.toLowerCase() == 'thorns')
                    FlxG.sound.music.fadeOut(2.2, 0);

                new FlxTimer().start(0.2, function(tmr:FlxTimer)
                {
                    box.alpha -= 1 / 5;
                    bgFade.alpha -= 1 / 5 * 0.7;
                    portraitLeft.visible = false;
                    portraitRight.visible = false;
                    swagDialogue.alpha -= 1 / 5;
                    dropText.alpha = swagDialogue.alpha;
                }, 5);

                new FlxTimer().start(1.2, function(tmr:FlxTimer)
                {
                    startCountdown();
                    var shitToRemove = [box, bgFade, portraitLeft, portraitRight, swagDialogue, dropText, handSelect];
                    if (face != null) shitToRemove.push(face);
                    for (s in shitToRemove) {
                        PlayState.remove(s);
                        s.destroy();
                    }
                });
            }
        }
        else
        {
            dialogueList.remove(dialogueList[0]);
            startDialogue();
        }
    }

}

function startDialogue():Void
{
    cleanDialog();

    swagDialogue.resetText(dialogueList[0]);
    swagDialogue.start(0.04, true);

    switch (curCharacter)
    {
        case 'dad':
            portraitRight.visible = false;
            if (!portraitLeft.visible && PlayState.song.song.toLowerCase() != "thorns")
            {
                portraitLeft.visible = true;
                portraitLeft.animation.play('enter');
            }
        case 'bf':
            portraitLeft.visible = false;
            if (!portraitRight.visible)
            {
                portraitRight.visible = true;
                portraitRight.animation.play('enter');
            }
    }
}

function cleanDialog():Void
{
    var splitName:Array<String> = dialogueList[0].split(":");
    if (splitName.length < 2) return;
    curCharacter = splitName[1];
    dialogueList[0] = StringTools.trim(dialogueList[0].substr(splitName[1].length + 2));
}
