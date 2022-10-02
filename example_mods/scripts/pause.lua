local Paused = false
local tweentime = 0.2
local UIname = 'LuaPauseUI'
local UIselpos = 300;
local UIselposs = 20;
local UIselmov = 10;
local UIseltweenn = 'circInOut'
local UIseltweent = 1;
local UIseltweenys = 15;
local UIseltweents = 0.2;
local UIselposxhide = -900;
local UIselposxshow = 100;

local SelectFiles = {
    {name = 'RESUME', tag = 'Resume', xrum = 0, xof = 200, yof = 380};
    {name = 'RESTART SONG', tag = 'Restart', xrum = 0, xof = 200, yof = 380};
    --{name = 'Quick OPTION', tag = 'Option', xrum = 0, xof = 200, yof = 380};
    {name = 'EXIT TO MENU', tag = 'Exit', xrum = 0, xof = 200, yof = 380};
};

local CustomSelectFiles = {
    ['optionMain']={
        {name = 'Graphics', tag = 'open-Graphics', xrum = 0, xof = 300, yof = 350};
        {name = 'Visuals And UI', tag = 'open-Visuals', xrum = 0, xof = 300, yof = 350};
        {name = 'GAMEPLAY', tag = 'open-Gameplay', xrum = 0, xof = 300, yof = 350};
        {name = 'SAVE AND RESTART', tag = 'SavRes', xrum = 0, xof = 300, yof = 350};
    };
};

local CustomSelectTarget = {
    ['optionMain']={select = 1, ftag = 'optionMain'};
    ['Graphics']={select = 1, ftag = 'Graphics'};
}

local curSelectTarget = 'optionMain';
local curSelectTargetxt = 'option-text';

--[=[local OptionFiles = {
    --[[{name = 'CONTROLS', tag = 'Controls', xof = 300, yof = 350
    {name = 'EXIT TO MENU', tag = 'Exit', xrum = 0, xof = 300, yof = 350 , xs = 80 ,ys = 300};
    };]]
    {name = 'GRAPHICS', tag = 'Graphics', xof = 300, yof = 350
    {name = 'Low Quality',   savetag = 'lowQuality',         settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Anti-Aliasing', savetag = 'globalAntialiasing', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Framerate',     savetag = 'framerate',          settingtag = 'int', Min = 60, Max = 240, xof = 300, yof = 350};    
    };
    {name = 'VISUALS AND UI', tag = 'Visuals', xof = 300, yof = 350
    {name = 'Note Splashes', savetag = 'noteSplashes', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Hide HUD', savetag = 'noteSplashes', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Time Bar', savetag = 'noteSplashes', settingtag = 'string', xrum = 0, xof = 300, yof = 350};
    {name = 'Flashing Lights', savetag = 'noteSplashes', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Camera Zooms', savetag = 'noteSplashes', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Score Text Zoom on Hit', savetag = 'noteSplashes', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Health Bar Transparency', savetag = 'noteSplashes', settingtag = 'percent', Min = 0.0, Max = 1, chval = 0.1, xrum = 0, xof = 300, yof = 350};
    {name = 'FPS Counter', savetag = 'noteSplashes', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    {name = 'Pause Screen Song', savetag = 'noteSplashes', settingtag = 'string', Settinglist == {'None', 'Breakfast', 'Tea Time'}, xrum = 0, xof = 300, yof = 350};
    {name = 'Check for Updates', savetag = 'noteSplashes', settingtag = 'bool', xrum = 0, xof = 300, yof = 350};
    };
    {name = 'GAMEPLAY', tag = 'GamePlay', xof = 300, yof = 350
    {name = 'OPTION', tag = 'Option', xrum = 0, xof = 300, yof = 350 , xs = 40 ,ys = 150};
    };
};]=]

local TextSpace = {xs = 40, xy = 150};
local TextFont = 'vcr.ttf'
local SelectTarget = 1;
local PauseMode = true;
local PauseState = 'PauseMenu';
local jumpinText = true;
local JumpinX = 120;
local AlphaMode = true;
local Alphavalue = 0.5;
local selectmenubg = true;

function onCreate()
    precacheImage('PauseUI/bg')
    precacheImage('PauseUI/select0')

    makeLuaSprite(UIname .. 'Black', '', 0, 0)
    makeGraphic(UIname .. 'Black', screenWidth, screenHeight, '000000')
    setObjectCamera(UIname .. 'Black', 'camOther')
	addLuaSprite(UIname .. 'Black', false)
    setProperty(UIname .. 'Black.alpha', 0)

    makeLuaSprite(UIname .. 'bg', 'PauseUI/bg', -850, 0)
    setObjectCamera(UIname .. 'bg', 'camOther')
	addLuaSprite(UIname .. 'bg', false)
    setProperty(UIname .. 'bg.visible', true)
    --setProperty(UIname .. 'bg.scale.x', 0.5)
    --setProperty(UIname .. 'bg.scale.y', 0.5)

    
    if selectmenubg == true then
    makeLuaSprite(UIname .. 'uis0', 'PauseUI/select0', UIselposxhide, UIselpos)
    setObjectCamera(UIname .. 'uis0', 'camOther')
	addLuaSprite(UIname .. 'uis0', false)
    setProperty(UIname .. 'uius0.visible', true)
    setProperty(UIname .. 'uis0.scale.x', 0.8)
    setProperty(UIname .. 'uis0.scale.y', 0.8)
    doTweenY('uis0tweeny0', UIname .. 'uis0', UIselpos+UIselmov+UIseltweenys*2, UIseltweent+UIseltweents*2, UIseltweenn)
    end


    --[=[for i = 1 , #SelectFiles do
        --debugPrint(SelectFiles[i].name)
        local Tempdatas = SelectTarget-i
        --if 1 == i then
        if SelectTarget == i then
            if jumpinText == true then
                makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name--[[ .. '(' .. SelectFiles[i].tag .. ')']], 0, SelectFiles[i].xof+JumpinX, SelectFiles[i].yof)
            else
                makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name--[[ .. '(' .. SelectFiles[i].tag .. ')']], 0, SelectFiles[i].xof, SelectFiles[i].yof)
            end
        else
            makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name--[[ .. '(' .. SelectFiles[i].tag .. ')']], 0, SelectFiles[i].xof-TextSpace.xs*Tempdatas, SelectFiles[i].yof-TextSpace.xy*Tempdatas)
        end
        --makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name, 0, SelectFiles[i].xof+SelectFiles[i].xs, SelectFiles[i].yof+SelectFiles[i].ys)
	    setTextFont(SelectFiles[i].tag .. 'm_Text' .. i, TextFont)
	    setTextColor(SelectFiles[i].tag .. 'm_Text' .. i, 'ffffff')
	    setTextSize(SelectFiles[i].tag .. 'm_Text' .. i, 70)
	    setTextAlignment(SelectFiles[i].tag .. 'm_Text' .. i, 'left')
	    setTextBorder(SelectFiles[i].tag .. 'm_Text' .. i, 3, '000000')
	    addLuaText(SelectFiles[i].tag .. 'm_Text' .. i)
	    setObjectCamera(SelectFiles[i].tag .. 'm_Text' .. i, 'camOther')
	    addLuaSprite(SelectFiles[i].tag .. 'm_Text' .. i, false)

        setProperty(SelectFiles[i].tag .. 'm_Text' .. i .. '.visible', false)

        --[[local Tempdatas = SelectTarget-i
        if 1 == i then
            doTweenY('pausetexttweeny' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].yof, UIseltweent/3, UIseltweenn)
        else
            doTweenY('pausetexttweeny' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].yof-SelectFiles[i].txy*Tempdatas, 0.02, UIseltweenn)
        end]]
        if SelectTarget == i then
            if AlphaMode == true then
                doTweenAlpha('pausetexttweenAngle' .. i, SelectFiles[i].tag .. 'm_Text' .. i, 1, 0.02, 'quartOut')
            end
        else
            if AlphaMode == true then
                doTweenAlpha('pausetexttweenAngle' .. i, SelectFiles[i].tag .. 'm_Text' .. i, Alphavalue, 0.02, 'quartOut')
            end
        end
    end]=]

    for i = 1 , #SelectFiles do
        --debugPrint(SelectFiles[i].name)
        local Tempdatas = SelectTarget-i
        --if 1 == i then
        if SelectTarget == i then
            if jumpinText == true then
                makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name--[[ .. '(' .. SelectFiles[i].tag .. ')']], 0, SelectFiles[i].xof+JumpinX, SelectFiles[i].yof)
            else
                makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name--[[ .. '(' .. SelectFiles[i].tag .. ')']], 0, SelectFiles[i].xof, SelectFiles[i].yof)
            end
        else
            makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name--[[ .. '(' .. SelectFiles[i].tag .. ')']], 0, SelectFiles[i].xof-TextSpace.xs*Tempdatas, SelectFiles[i].yof-TextSpace.xy*Tempdatas)
        end
        --makeLuaText(SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].name, 0, SelectFiles[i].xof+SelectFiles[i].xs, SelectFiles[i].yof+SelectFiles[i].ys)
	    setTextFont(SelectFiles[i].tag .. 'm_Text' .. i, TextFont)
	    setTextColor(SelectFiles[i].tag .. 'm_Text' .. i, 'ffffff')
	    setTextSize(SelectFiles[i].tag .. 'm_Text' .. i, 70)
	    setTextAlignment(SelectFiles[i].tag .. 'm_Text' .. i, 'left')
	    setTextBorder(SelectFiles[i].tag .. 'm_Text' .. i, 3, '000000')
	    addLuaText(SelectFiles[i].tag .. 'm_Text' .. i)
	    setObjectCamera(SelectFiles[i].tag .. 'm_Text' .. i, 'camOther')
	    addLuaSprite(SelectFiles[i].tag .. 'm_Text' .. i, false)

        setProperty(SelectFiles[i].tag .. 'm_Text' .. i .. '.visible', false)
        setProperty(SelectFiles[i].tag .. 'm_Text' .. i .. '.antialiasing', true)

        --[[local Tempdatas = SelectTarget-i
        if 1 == i then
            doTweenY('pausetexttweeny' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].yof, UIseltweent/3, UIseltweenn)
        else
            doTweenY('pausetexttweeny' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].yof-SelectFiles[i].txy*Tempdatas, 0.02, UIseltweenn)
        end]]
        if SelectTarget == i then
            if AlphaMode == true then
                doTweenAlpha('pausetexttweenAngle' .. i, SelectFiles[i].tag .. 'm_Text' .. i, 1, 0.02, 'quartOut')
            end
        else
            if AlphaMode == true then
                doTweenAlpha('pausetexttweenAngle' .. i, SelectFiles[i].tag .. 'm_Text' .. i, Alphavalue, 0.02, 'quartOut')
            end
        end
    end
end

function onTweenCompleted(tag)
    if selectmenubg == true then
    if tag == 'uis0tweeny0' then
        doTweenY('uis0tweeny1', UIname .. 'uis0', UIselpos-UIselmov+UIseltweenys*2, UIseltweent, UIseltweenn)
    end
    if tag == 'uis0tweeny1' then
        doTweenY('uis0tweeny0', UIname .. 'uis0', UIselpos+UIselmov+UIseltweenys*2, UIseltweent, UIseltweenn)
    end
    end
end

--[[function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'uistween0' then
        if loops == 0 then
        doTweenY('uis1tweeny0', UIname .. 'uis1', UIselpos+UIselmov+UIseltweenys, UIseltweent, UIseltweenn)
        else
        doTweenY('uis0tweeny0', UIname .. 'uis0', UIselpos+UIselmov+UIseltweenys*2, UIseltweent, UIseltweenn)
        end
    end

    if tag == 'uistween1' then
        if loops == 0 then
            doTweenY('uis1tweeny1', UIname .. 'uis1', UIselpos-UIselmov+UIseltweenys, UIseltweent, UIseltweenn)
        else
            doTweenY('uis0tweeny1', UIname .. 'uis0', UIselpos-UIselmov+UIseltweenys*2, UIseltweent, UIseltweenn)
        end
    end
end]]

function SelectFunction(tag, fi)
    if PauseState == 'PauseMenu' then
        if tag == 'Resume' then
            doTweenAlpha('BlackTween', UIname .. 'Black', 0, tweentime, 'linear')
            doTweenAlpha('bgTweenalpha', UIname .. 'bg', 0, tweentime, 'linear')
            doTweenX('bgtweenx', UIname .. 'bg', -850, tweentime*2, 'circOut')

            if selectmenubg == true then
            doTweenX('uistweenx0', UIname .. 'uis0', UIselposxhide, tweentime*3.5, 'circOut')
            end

            setProperty("boyfriend.animation.curAnim.paused", false)
            setProperty("dad.animation.curAnim.paused", false)
            setProperty("gf.animation.curAnim.paused", false)
            setProperty("playerStrums.animation.curAnim.paused", false)
            setPropertyFromClass('flixel.FlxG', 'sound.music.volume', 1)
            setProperty('vocals.volume', 1)
            Paused = false
            stopSound('pausemenusound')

            for i = 1 , #SelectFiles do
                setProperty(SelectFiles[i].tag .. 'm_Text' .. i .. '.visible', false)
            end

            for a = 0, getProperty('notes.length') - 1 do
                setPropertyFromGroup('notes', i, 'canBeHit', true)
            end
        end
        if tag == 'Restart' then
            restartSong(false)
            playSound('confirmMenu',2)
        end
        if tag == 'Exit' then
            exitSong(false);
            playSound('confirmMenu',2)
        end
        if tag == 'Option' then
            playSound('confirmMenu',2)
            PauseState = 'OptionMenu';
            for i = 1 , #SelectFiles do
                setProperty(SelectFiles[i].tag .. 'm_Text' .. i .. '.visible', false)
            end
            ListCreate('option', 'optionMain', 'option-text')
        end
    elseif PauseState == 'OptionMenu' then
        if tag == 'BackOption' then
            PauseMode = false;
            runTimer('waitpause', 0.05, 1)
            playSound('confirmMenu',2)
            for i = 1 , #SelectFiles do
                setProperty(SelectFiles[i].tag .. 'm_Text' .. i .. '.visible', true)
            end
            for i = 1 , #CustomSelectFiles['optionMain'] do
                --removeLuaSprite(CustomSelectFiles['optionMain'][i].tag .. 'option-text' .. i, true)
                setProperty(CustomSelectFiles['optionMain'][i].tag .. 'option-text' .. i .. '.visible', false)
            end
            PauseState = 'PauseMenu';
        end
        if tag == 'SavRes' then 
            restartSong(false)
            playSound('confirmMenu',2)
        end

        if tag == 'Graphics' then
            playSound('confirmMenu',2)
            PauseState = 'GraphicsMenu';
            for i = 1 , #CustomSelectFiles['optionMain'] do
                --removeLuaSprite(CustomSelectFiles['optionMain'][i].tag .. 'option-text' .. i, true)
                setProperty(CustomSelectFiles['optionMain'][i].tag .. 'option-text' .. i .. '.visible', false)
            end
            ListCreate('option-graphics', 'Graphics', 'graphic-text', true)
        end
    end
end

function onUpdatePost()
	if Paused == true then
        setPropertyFromClass('Conductor', 'songPosition', pos) -- it is counted by milliseconds, 1000 = 1 second
		setPropertyFromClass('flixel.FlxG', 'sound.music.time', pos)
		setProperty('vocals.time', pos)
		setPropertyFromClass('flixel.FlxG', 'sound.music.volume', 0)
		setProperty('vocals.volume', 0)
        setProperty("boyfriend.animation.curAnim.paused", true)
		setProperty("dad.animation.curAnim.paused", true)
		setProperty("gf.animation.curAnim.paused", true)
		setProperty("playerStrums.animation.curAnim.paused", true)
        setProperty("boyfriend.heyTimer", 0)
		setProperty("dad.heyTimer", 0)
		setProperty("gf.heyTimer", 0)
        if PauseMode == true then
            if PauseState == 'PauseMenu' then

                if keyJustPressed('accept') then
                    SelectFunction(SelectFiles[SelectTarget].tag, SelectTarget)
                end
                if keyJustPressed('up') then
                    playSound('scrollMenu',2)
                    SelectTarget = SelectTarget-1;
                    pauseselectcm = true

                end
                if keyJustPressed('down') then
                    playSound('scrollMenu',2)
                    SelectTarget = SelectTarget+1;
                    pauseselectcm = true
            
                end
                if keyJustPressed('right') then
                    --restartSong(false)
                    --playSound('confirmMenu',2)

                end
                if keyJustPressed('left') then
                    --exitSong(false);
                    --playSound('confirmMenu',2)

                end
                if keyJustPressed('back') then
                    SelectFunction('Resume', SelectTarget)
                end
            elseif PauseState == 'OptionMenu' then
                if keyJustPressed('accept') then
                    SelectFunction(CustomSelectFiles[curSelectTarget][CustomSelectTarget[curSelectTarget].select].tag, CustomSelectTarget[curSelectTarget].select)
                end

                if keyJustPressed('back') then
                    SelectFunction('BackOption', SelectTarget)
                end
                if keyJustPressed('up') then
                    playSound('scrollMenu',2)
                    CustomSelectTarget[curSelectTarget].select = CustomSelectTarget[curSelectTarget].select-1;
                    pauseselectcmop = true

                end
                if keyJustPressed('down') then
                    playSound('scrollMenu',2)
                    CustomSelectTarget[curSelectTarget].select = CustomSelectTarget[curSelectTarget].select+1;
                    pauseselectcmop = true
            
                end
            end
        end

        
        if pauseselectcm == true then
            if SelectTarget > #SelectFiles then
                SelectTarget = 1
            end
    
            if SelectTarget < 1 then
                SelectTarget = #SelectFiles
            end

            --debugPrint('select' .. SelectTarget)
            for i = 1 , #SelectFiles do
                --debugPrint(i)
                if SelectTarget == i then
                    --debugPrint('true')
                    doTweenY('pausetexttweeny' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].yof, UIseltweent/3, 'quartOut')

                    if AlphaMode == true then
                        doTweenAlpha('pausetexttweenAngle' .. i, SelectFiles[i].tag .. 'm_Text' .. i, 1, UIseltweent/3, 'quartOut')
                    end

                    if jumpinText == true then
                        doTweenX('pausetexttweenx' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].xof+JumpinX, UIseltweent/3, 'quartOut')
                    else
                        doTweenX('pausetexttweenx' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].xof, UIseltweent/3, 'quartOut')
                    end
                end
                if SelectTarget ~= i then
                    SelectTargetMode(i)
                end
                --SelectTargetMode(i)
            end
            pauseselectcm = false
        end

        if pauseselectcmop == true then
            if CustomSelectTarget[curSelectTarget].select > #CustomSelectFiles[curSelectTarget] then
                CustomSelectTarget[curSelectTarget].select = 1
            end
    
            if CustomSelectTarget[curSelectTarget].select < 1 then
                CustomSelectTarget[curSelectTarget].select = #CustomSelectFiles[curSelectTarget]
            end

            --debugPrint('select' .. SelectTarget)
            for i = 1 , #CustomSelectFiles[curSelectTarget] do
                --debugPrint(i)
                if CustomSelectTarget[curSelectTarget].select == i then
                    --debugPrint('true')
                    doTweenY(curSelectTarget .. 'pausetexttweeny' .. i, CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, CustomSelectFiles[curSelectTarget][i].yof, UIseltweent/3, 'quartOut')

                    if AlphaMode == true then
                        doTweenAlpha(curSelectTarget .. 'pausetexttweenAngle' .. i, CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, 1, UIseltweent/3, 'quartOut')
                    end

                    if jumpinText == true then
                        doTweenX(curSelectTarget .. 'pausetexttweenx' .. i, CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, CustomSelectFiles[curSelectTarget][i].xof+JumpinX, UIseltweent/3, 'quartOut')
                    else
                        doTweenX(curSelectTarget .. 'pausetexttweenx' .. i, CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, CustomSelectFiles[curSelectTarget][i].xof, UIseltweent/3, 'quartOut')
                    end
                end
                if CustomSelectTarget[curSelectTarget].select ~= i then
                    SelectTargetMode(i,true,curSelectTarget,curSelectTargetxt)
                end
                --SelectTargetMode(i)
            end
            pauseselectcmop = false
        end
	else

	end
    
end

function SelectTargetMode(i,custom,tag,txt)
    if custom == true then
        --debugPrint('omg' .. i)
        local Tempdatas = CustomSelectTarget[tag].select-i
        if AlphaMode == true then
            doTweenAlpha(tag .. 'pausetexttweenAngle' .. i, CustomSelectFiles[tag][i].tag .. txt .. i, Alphavalue, UIseltweent/3, 'quartOut')
        end
        doTweenY(tag .. 'pausetexttweeny' .. i, CustomSelectFiles[tag][i].tag .. txt .. i, CustomSelectFiles[tag][i].yof-TextSpace.xy*Tempdatas, UIseltweent/3, 'quartOut')
        doTweenX(tag .. 'pausetexttweenx' .. i, CustomSelectFiles[tag][i].tag .. txt .. i, CustomSelectFiles[tag][i].xof-TextSpace.xs*Tempdatas, UIseltweent/3, 'quartOut')
    else
        --debugPrint('omg' .. i)
        local Tempdatas = SelectTarget-i
        if AlphaMode == true then
            doTweenAlpha('pausetexttweenAngle' .. i, SelectFiles[i].tag .. 'm_Text' .. i, Alphavalue, UIseltweent/3, 'quartOut')
        end
        doTweenY('pausetexttweeny' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].yof-TextSpace.xy*Tempdatas, UIseltweent/3, 'quartOut')
        doTweenX('pausetexttweenx' .. i, SelectFiles[i].tag .. 'm_Text' .. i, SelectFiles[i].xof-TextSpace.xs*Tempdatas, UIseltweent/3, 'quartOut')
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'waitpause' then
        PauseMode = true;
    end
end



function onPause()
    if not Paused then
        runTimer('waitpause', 0.05, 1)
        PauseMode = false;
        doTweenAlpha('BlackTween', UIname .. 'Black', 0.5, tweentime, 'linear')
        doTweenAlpha('bgTweenalpha', UIname .. 'bg', 0.5, tweentime, 'linear')
        doTweenX('bgtweenx', UIname .. 'bg', 0, tweentime*3, 'circOut')


        if selectmenubg == true then
        doTweenX('uistweenx0', UIname .. 'uis0', UIselposxshow, tweentime*6, 'circOut')
        end

        for i = 1 , #SelectFiles do
            setProperty(SelectFiles[i].tag .. 'm_Text' .. i .. '.visible', true)
        end

        for a = 0, getProperty('notes.length') - 1 do
            setPropertyFromGroup('notes', i, 'canBeHit', false)
        end
        
        Paused = true
        playSound('tea-time', 1, 'pausemenusound')

    --[[if resume == true then
        playSound('dialPause', 1, 'pausemus')
        playSound('scrollMenu',2)
    end
    if restart == true then
        restartSong(false);
        playSound('scrollMenu',2)
    end
    if quit == true then
        exitSong(false);
        playSound('scrollMenu',2)
    end
    if random == true then
        quotenum = math.random(thing)
        playSound('scrollMenu',2)
        Paused = true
    end
    if setings == true then
        if canseting == true then
            setingmenu = true
            Paused = true
    else
        playSound('scratch',2)
        Paused = true
    end]]
    end
    pos = getPropertyFromClass('Conductor', 'songPosition')
	return Function_Stop
end

function ListCreate(aname, ftag, nametag, value1)
    if value1 == true then
        CustomSelectTarget[curSelectTarget].select = 1;
        curSelectTarget = ftag;
        curSelectTargetxt = nametag;
        --debugPrint(#CustomSelectFiles[ftag])
        for i = 1 , #CustomSelectFiles[ftag] do
            --debugPrint(SelectFiles[i].name)
            local Tempdatas = CustomSelectTarget[ftag].select-i
            --if 1 == i then
            if CustomSelectTarget[curSelectTarget].select == i then
                if jumpinText == true then
                    makeLuaText(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, CustomSelectFiles[aname][ftag][i].name--[[ .. '(' .. CustomSelectFiles[ftag][i].tag .. ')']], 0, CustomSelectFiles[aname][ftag][i].xof+JumpinX, CustomSelectFiles[aname][ftag][i].yof)
                else
                    makeLuaText(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i,CustomSelectFiles[aname][ftag][i].name--[[ .. '(' .. CustomSelectFiles[ftag][i].tag .. ')']], 0, CustomSelectFiles[aname][ftag][i].xof, CustomSelectFiles[aname][ftag][i].yof)
                end
            else
                makeLuaText(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i,CustomSelectFiles[aname][ftag][i].name--[[ .. '(' .. CustomSelectFiles[ftag][i].tag .. ')']], 0, CustomSelectFiles[aname][ftag][i].xof-TextSpace.xs*Tempdatas, CustomSelectFiles[aname][ftag][i].yof-TextSpace.xy*Tempdatas)
            end
            --makeLuaText(CustomSelectFiles[ftag][i].tag .. 'm_Text' .. i,CustomSelectFiles[ftag][i].name, 0, CustomSelectFiles[ftag][i].xof+SelectFiles[i].xs,CustomSelectFiles[ftag][i].yof+SelectFiles[i].ys)
            setTextFont(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, TextFont)
            setTextColor(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, 'ffffff')
            setTextSize(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, 70)
            setTextAlignment(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, 'left')
            setTextBorder(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, 3, '000000')
            addLuaText(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i)
            setObjectCamera(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, 'camOther')
            addLuaSprite(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, false)
    
            setProperty(CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i .. '.visible', true)
    
            --[[local Tempdatas = SelectTarget-i
            if 1 == i then
                doTweenY('pausetexttweeny' .. i, CustomSelectFiles[ftag][i].tag .. 'm_Text' .. i,CustomSelectFiles[ftag][i].yof, UIseltweent/3, UIseltweenn)
            else
                doTweenY('pausetexttweeny' .. i, CustomSelectFiles[ftag][i].tag .. 'm_Text' .. i,CustomSelectFiles[ftag][i].yof-SelectFiles[i].txy*Tempdatas, 0.02, UIseltweenn)
            end]]
            if CustomSelectTarget[ftag].select == i then
                if AlphaMode == true then
                    doTweenAlpha('pausetexttweenAngle' .. i, CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, 1, 0.02, 'quartOut')
                end
            else
                if AlphaMode == true then
                    doTweenAlpha('pausetexttweenAngle' .. i, CustomSelectFiles[aname][curSelectTarget][i].tag .. curSelectTargetxt .. i, Alphavalue, 0.02, 'quartOut')
                end
            end
        end
    else
        CustomSelectTarget[curSelectTarget].select = 1;
    curSelectTarget = ftag;
    curSelectTargetxt = nametag;
    --debugPrint(#CustomSelectFiles[ftag])
    for i = 1 , #CustomSelectFiles[ftag] do
        --debugPrint(SelectFiles[i].name)
        local Tempdatas = CustomSelectTarget[ftag].select-i
        --if 1 == i then
        if CustomSelectTarget[curSelectTarget].select == i then
            if jumpinText == true then
                makeLuaText(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, CustomSelectFiles[ftag][i].name--[[ .. '(' .. CustomSelectFiles[ftag][i].tag .. ')']], 0, CustomSelectFiles[ftag][i].xof+JumpinX, CustomSelectFiles[ftag][i].yof)
            else
                makeLuaText(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i,CustomSelectFiles[ftag][i].name--[[ .. '(' .. CustomSelectFiles[ftag][i].tag .. ')']], 0, CustomSelectFiles[ftag][i].xof, CustomSelectFiles[ftag][i].yof)
            end
        else
            makeLuaText(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i,CustomSelectFiles[ftag][i].name--[[ .. '(' .. CustomSelectFiles[ftag][i].tag .. ')']], 0, CustomSelectFiles[ftag][i].xof-TextSpace.xs*Tempdatas, CustomSelectFiles[ftag][i].yof-TextSpace.xy*Tempdatas)
        end
        --makeLuaText(CustomSelectFiles[ftag][i].tag .. 'm_Text' .. i,CustomSelectFiles[ftag][i].name, 0, CustomSelectFiles[ftag][i].xof+SelectFiles[i].xs,CustomSelectFiles[ftag][i].yof+SelectFiles[i].ys)
	    setTextFont(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, TextFont)
	    setTextColor(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, 'ffffff')
	    setTextSize(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, 70)
	    setTextAlignment(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, 'left')
	    setTextBorder(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, 3, '000000')
	    addLuaText(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i)
	    setObjectCamera(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, 'camOther')
	    addLuaSprite(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, false)

        setProperty(CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i .. '.visible', true)

        --[[local Tempdatas = SelectTarget-i
        if 1 == i then
            doTweenY('pausetexttweeny' .. i, CustomSelectFiles[ftag][i].tag .. 'm_Text' .. i,CustomSelectFiles[ftag][i].yof, UIseltweent/3, UIseltweenn)
        else
            doTweenY('pausetexttweeny' .. i, CustomSelectFiles[ftag][i].tag .. 'm_Text' .. i,CustomSelectFiles[ftag][i].yof-SelectFiles[i].txy*Tempdatas, 0.02, UIseltweenn)
        end]]
        if CustomSelectTarget[ftag].select == i then
            if AlphaMode == true then
                doTweenAlpha('pausetexttweenAngle' .. i, CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, 1, 0.02, 'quartOut')
            end
        else
            if AlphaMode == true then
                doTweenAlpha('pausetexttweenAngle' .. i, CustomSelectFiles[curSelectTarget][i].tag .. curSelectTargetxt .. i, Alphavalue, 0.02, 'quartOut')
            end
        end
    end
    end
end