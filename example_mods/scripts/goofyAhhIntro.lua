
local introShit = {{'ready', 'set', 'go'}, {'pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel'}} -- booo, had to use lua >:( oh well
local introScales = {{0.7, 0.9, 1.4}, {5.8, 6.0, 6.5}}
function onCreatePost() -- was initally in source code haha
    luaDebugMode = true;
    if getPropertyFromClass('PlayState', 'isPixelStage') == true then
        for i = 1, 3 do
            makeLuaSprite('fakeCountdown'.. introShit[1][i], introShit[2][i], 0, 0)
            setObjectCamera('fakeCountdown'.. introShit[1][i], 'hud')
            setProperty('fakeCountdown'.. introShit[1][i]..'.antialiasing', false)
            addLuaSprite('fakeCountdown'.. introShit[1][i])
            scaleObject('fakeCountdown'..introShit[1][i], 0, 0)
            screenCenter('fakeCountdown'.. introShit[1][i], 'xy')
        end
    else
        for i = 1, 3 do
            makeLuaSprite('fakeCountdown'.. introShit[1][i], introShit[1][i], 0, 0)
            setObjectCamera('fakeCountdown'.. introShit[1][i], 'hud')
            addLuaSprite('fakeCountdown'.. introShit[1][i])
            scaleObject('fakeCountdown'..introShit[1][i], 0, 0)
            screenCenter('fakeCountdown'.. introShit[1][i], 'xy')
        end
    end

    local go = 0
    if downscroll then go = -900 else go = 1500 end
    for i = 0, 3 do
        setPropertyFromGroup('playerStrums', i, 'y', go)
        setPropertyFromGroup('opponentStrums', i, 'y', go)
    end

    addHaxeLibrary('ClientPrefs') -- downscroll shiz
    addHaxeLibrary('Conductor')   -- ay yo?
    addHaxeLibrary('StrumNote')

	runHaxeCode([[
        // below or above healthbar
        
        if (ClientPrefs.downScroll){
            game.iconP1.y = game.healthBar.y - 300; 
            game.iconP2.y = game.healthBar.y - 300;
            game.scoreTxt.y = game.healthBar.y - 100;
        } else {
            game.iconP1.y = game.healthBar.y + 100;
            game.iconP2.y = game.healthBar.y + 100;
            game.scoreTxt.y = game.healthBar.y + 100;
        }

        if (ClientPrefs.downScroll){
            game.scoreTxt.y = game.scoreTxt.y - 300;
        } else {
            game.scoreTxt.y = game.scoreTxt.y + 100;
        }
	]]);
end

local stop = false
function onCountdownTick(counter)
    -- dunno why I'm doin it like this | Patented fnf ripoff ass countdown
    if getPropertyFromClass('PlayState', 'isPixelStage') then lol = 2 else lol = 1 end
    if counter == 0 then
        for i = 0, 3 do
            noteTweenY('hopIn'..i, i, getProperty('strumLine.y'), 1 + (0.4 + (0.2 * i)), 'backOut')
            noteTweenY('hopIn'..i+4, i+4, getProperty('strumLine.y'), 1 + (0.4 + (0.2 * i)), 'backOut')
        end

        runHaxeCode([[
            FlxTween.tween(game.scoreTxt, {y: game.healthBarBG.y + 36}, Conductor.crochet / 1000, {ease: FlxEase.backOut});
        ]])
    end
    if counter == 1 then
        runTimer('readyGo', crochet/1500)
        doTweenX('readyInX', 'fakeCountdownready.scale', introScales[lol][counter], crochet/1500, 'cubeInOut')
        doTweenY('readyInY', 'fakeCountdownready.scale', introScales[lol][counter], crochet/1500, 'cubeInOut')
        runHaxeCode([[
            FlxTween.tween(game.iconP1, {y: game.healthBar.y - 75}, Conductor.crochet / 1000, {ease: FlxEase.backOut});
        ]])
    end
    if counter == 2 then
        runTimer('setGo', crochet/1500)
        doTweenX('setInX', 'fakeCountdownset.scale', introScales[lol][counter], crochet/1500, 'cubeInOut')
        doTweenY('setInY', 'fakeCountdownset.scale', introScales[lol][counter], crochet/1500, 'cubeInOut')
        runHaxeCode([[
            //game.countdownSet.scale.set(0.4, 0.4);
            //FlxTween.tween(game.countdownSet.scale, {x: 1, y: 1}, Conductor.crochet / 1500, {ease: FlxEase.cubeInOut});

            FlxTween.tween(game.iconP2, {y: game.healthBar.y - 75}, Conductor.crochet / 1000, {ease: FlxEase.backOut});
        ]])
    end
    if counter == 3 then
        runTimer('goGo', crochet/1500)
        doTweenX('goInX', 'fakeCountdowngo.scale', introScales[lol][counter], crochet/2000, 'backOut')
        doTweenY('goInY', 'fakeCountdowngo.scale', introScales[lol][counter], crochet/2000, 'backOut')
        runHaxeCode([[
            //game.countdownGo.scale.set(0.4, 0.4);
            //FlxTween.tween(game.countdownGo.scale, {x: 1.4, y:1.4}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});

            FlxTween.tween(game.iconP1, {angle: -360}, Conductor.crochet / 1500, {ease: FlxEase.backOut});
            FlxTween.tween(game.iconP2, {angle: 360}, Conductor.crochet / 1500, {ease: FlxEase.backOut});
	    ]]);
    end
end

function onSongStart()
    stop = true
    runHaxeCode([[
        game.iconP1.angle = 0; // just to reset angles
        game.iconP2.angle = 0;
    ]])
end

function onUpdate()
    --debugPrint(testVar)
    runHaxeCode([[
        //game.camHUD.zoom = 0.2; 

        game.countdownReady.visible = false; // Fuck it, gonna make my own >:(
        game.countdownSet.visible = false;
        game.countdownGo.visible = false;
    ]])
    
    if not stop then
        --[[for i = 0, 3 do
            setPropertyFromGroup('playerStrums', i, 'alpha', 1)
            if not middlescroll then
                setPropertyFromGroup('opponentStrums', i, 'alpha', 1)
            end
        end]]
    end
end

function onTimerCompleted(t, l, ll) -- coulda used "onTweenCompleted", but nah
    if t == 'readyGo' then
        doTweenX('readyOutX', 'fakeCountdownready.scale', 0, crochet/1500, 'cubeInOut')
        doTweenY('readyOutY', 'fakeCountdownready.scale', 0, crochet/1500, 'cubeInOut')
        --setProperty('fakeCountdownready.velocity.y', -500)
        --setProperty('fakeCountdownready.acceleration.y', 550)
        --setProperty('fakeCountdownready.velocity.x', math.random(0,10))
    end

    if t == 'setGo' then
        doTweenX('setOutX', 'fakeCountdownset.scale', 0, crochet/1500, 'cubeInOut')
        doTweenY('setOutY', 'fakeCountdownset.scale', 0, crochet/1500, 'cubeInOut')
        --setProperty('fakeCountdownset.velocity.y', -500)
        --setProperty('fakeCountdownset.acceleration.y', 550)
        --setProperty('fakeCountdownset.velocity.x', math.random(0,10))
    end

    if t == 'goGo' then
        doTweenY('goOutY', 'fakeCountdowngo', 1200, crochet/1000, 'cubeInOut')
        --setProperty('fakeCountdowngo.velocity.y', -500)
        --setProperty('fakeCountdowngo.acceleration.y', 550)
        --setProperty('fakeCountdowngo.velocity.x', math.random(0,10))
    end
end

function onTweenCompleted(t) -- Idk if ya even need this, countdown sprites aint that demandin
    if t == 'goOutY' then
        removeLuaSprite('fakeCountdownready', true)
        removeLuaSprite('fakeCountdownset', true)
        removeLuaSprite('fakeCountdowngo', true)
    end
end
