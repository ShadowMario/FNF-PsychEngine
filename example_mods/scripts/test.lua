function onCreatePost()
    addHaxeLibrary('Paths')
    addHaxeLibrary('Map', 'haxe.ds');
    addHaxeLibrary('Bytes', 'haxe.io');
    addHaxeLibrary('BitmapData', 'flash.display');
    luaDebugMode = true;
    runHaxeCode([[ 
        myeyes = Paths.loadGraphicFromURL('https://tenor.com/view/reaction-my-eyes-cant-unsee-burn-gif-7225082');
        myeyes.cameras = [game.camHUD];
        game.add(myeyes);
        
        image = new FlxSprite();
        image.frames = Paths.loadSparrowAtlasFromURL('https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/assets/shared/images/characters/tankmanCaptain.xml', 'https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/assets/shared/images/characters/tankmanCaptain.png');

        image.animation.addByPrefix('idle', 'Tankman Idle Dance 1', 24, false);
        image.animation.addByPrefix('singLEFT', 'Tankman Note Left 1', 24, false);
        image.animation.addByPrefix('singDOWN', 'Tankman DOWN note 1', 24, false);
        image.animation.addByPrefix('singUP', 'Tankman UP note 1', 24, false);
        image.animation.addByPrefix('singRIGHT', 'Tankman Right Note 1', 24, false);
        image.animation.play('idle');
        image.x = game.boyfriend.x + 200;
        image.y = game.boyfriend.y - 200;
        image.antialiasing = true;
        game.insert(12, image);
        setVar(image, image);
    ]]);
end

function onUpdatePost(elapsed)
    runHaxeCode([[
        fakeBF = getVar(image);
        fakeBF.animation.play(game.boyfriend.animation.name);
        switch (fakeBF.animation.name) {
            case 'idle': 
                fakeBF.offset.set(0, 0);
            case 'singLEFT': 
                fakeBF.offset.set(91, -23);
            case 'singDOWN': 
                fakeBF.offset.set(66, -107);
            case 'singUP': 
                fakeBF.offset.set(28, 54);
            case 'singRIGHT': 
                fakeBF.offset.set(-21, -11);
            default:
                fakeBF.offset.set(0, 0);
        }
        fakeBF.animation.curAnim.curFrame = game.boyfriend.animation.curAnim.curFrame;
    ]])
end
