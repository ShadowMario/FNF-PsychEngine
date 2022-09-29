local ratingSarv = 'Unrated'

-- These are disabled by default, but you can enable them by setting the value to 'true'

local enableAcc = true

local enableTime = false

function onCreate()
    createQuickBox('boxInfo', 339, 674, 601, 30, 'ffffff', 0.3, true, 16)
    createTextQuick('DC', 'DEATHS: ' .. getPropertyFromClass('PlayState', 'deathCounter'),
        getProperty('boxInfo.x') + 21, getProperty('boxInfo.y') + 4, 0, 'left', 16, 0, 0, '0x00FFFFFF')
    createTextQuick('MC', 'MISSED: ' .. misses, getProperty('boxInfo.x') + 121, getProperty('boxInfo.y') + 4, 0, 'left',
        16, 0, 0, '0x00FFFFFF')
    createTextQuick('RC', 'RATING: ' .. ratingSarv, getProperty('boxInfo.x') + 252, getProperty('boxInfo.y') + 4, 0,
        'left', 16, 0, 0, '0x00FFFFFF')
    createTextQuick('SC', 'SCORE:' .. score, getProperty('boxInfo.x') + 477, getProperty('boxInfo.y') + 4, 0, 'left',
        16, 0, 0, '0x00FFFFFF')
    if hideHud then
        setProperty('boxInfo.visible', 0)
        setProperty('DC.visible', 0)
        setProperty('MC.visible', 0)
        setProperty('RC.visible', 0)
        setProperty('SC.visible', 0)
    end
    if enableAcc then
        createQuickBox('AccInfo', 86, 674, 171, 30, 'ffffff', 0.3, true, 16)
        createTextQuick('AC', 'ACCURACY: ' .. round((getProperty('ratingPercent') * 100), 2) .. '%',
            getProperty('AccInfo.x') + 4, getProperty('boxInfo.y') + 4, 0, 'left', 16, 0, 0, '0x00FFFFFF')
        if hideHud then
            setProperty('AccInfo.visible', 0)
            setProperty('AC.visible', 0)
        end
    end

    if enableTime then
        createQuickBox('TimeInfo', ((screenWidth / 2) - (170 / 2)), 16, 170, 30, 'ffffff', 0.3, true, 674)
        createTextQuick('TM', milliToHuman(
            math.floor(songLength - (getPropertyFromClass('Conductor', 'songPosition') - noteOffset))),
            getProperty('TimeInfo.x'), getProperty('TimeInfo.y') + 4, 0, 'center', 16, 0, 0, '0x00FFFFFF')
        if hideHud then
            setProperty('TimeInfo.visible', 0)
            setProperty('TM.visible', 0)
        end
    end
end

function onCreatePost()
    setProperty('timeBar.y', -1000)
    setProperty('timeTxt.y', -1000)
    setProperty('scoreTxt.alpha', 0)

    setObjectOrder('boxInfo', getObjectOrder('iconP1') - 1)

    setObjectOrder('DC', (getObjectOrder('boxInfo') + 1))
    setObjectOrder('MC', (getObjectOrder('boxInfo') + 1))
    setObjectOrder('RC', (getObjectOrder('boxInfo') + 1))
    setObjectOrder('SC', (getObjectOrder('boxInfo') + 1))

    if enableAcc then
        setObjectOrder('AccInfo', getObjectOrder('iconP1') - 1)
        setObjectOrder('AC', (getObjectOrder('AccInfo') + 1))
    end

    if enableTime then
        setObjectOrder('TimeInfo', getObjectOrder('iconP1') - 1)
        setObjectOrder('TM', (getObjectOrder('TimeInfo') + 1))
    end

    if downscroll then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'y', (getPropertyFromGroup('strumLineNotes', i, 'y') - 20))
        end
        setProperty('healthBar.y', (getProperty('healthBar.y') + 21))
        setProperty('iconP1.y', (getProperty('iconP1.y') + 31))
        setProperty('iconP2.y', (getProperty('iconP2.y') + 31))
    else
        setProperty('healthBar.y', (getProperty('healthBar.y') - 21))
        setProperty('iconP1.y', (getProperty('iconP1.y') - 21))
        setProperty('iconP2.y', (getProperty('iconP2.y') - 21))
    end
end

function createTextQuick(tag, text, x, y, width, alignment, size, bsize, bq, bcolor)
    makeLuaText(tag, text, width, x, y)
    setTextSize(tag, size)

    setTextAlignment(tag, alignment);
    updateHitbox(tag)
    setProperty(tag .. '.borderSize', bsize)
    setProperty(tag .. '.borderQuality', bq)
    setProperty(tag .. '.borderColor', getColorFromHex(bcolor));
    -- setProperty('songInfo.borderColor', getColorFromHex('000000'));
    addLuaText(tag)
    setObjectCamera(tag, 'hud')
end

function createQuickBox(tag, x, y, width, height, color, alpha, downscrollcheck, dsy)
    makeLuaSprite(tag, '', x, y)
    makeGraphic(tag, width, height, color)
    setProperty(tag .. '.alpha', alpha)
    if downscrollcheck == true then
        if downscroll then
            setProperty(tag .. '.y', dsy)
        end
    end
    addLuaSprite(tag, true)
    -- setObjectCamera('breakerbg', 'other')
    setObjectCamera(tag, 'hud')
end

function onUpdate()
    if enableTime then
        setProperty('TM.x',
            (getProperty('TimeInfo.x') + ((getProperty('TimeInfo.width') / 2) - (getProperty('TM.width') / 2))))
    end
    if misses == 0 and getProperty('songHits') > 0 then
        ratingSarv = 'PERFECT COMBO'
        colorBox('A8A800')
    elseif misses > 0 then
        if getProperty('songHits') == 0 then
            ratingSarv = 'D'
        else
            if rating >= 0.9 then
                ratingSarv = 'S'
                colorBox('0C889F')
            elseif rating >= 0.72 then
                ratingSarv = 'A'
                colorBox('AF0000')
            elseif rating >= 0.54 then
                ratingSarv = 'B'
                colorBox('000000')
            elseif rating >= 0.36 then
                ratingSarv = 'C'
                colorBox('000000')
            elseif rating >= 0.18 then
                ratingSarv = 'D'
                colorBox('000000')
            end
        end
    else
        colorBox('000000')
    end
    setTextString('DC', 'DEATHS: ' .. getPropertyFromClass('PlayState', 'deathCounter'))
    setTextString('MC', 'MISSED: ' .. misses)
    setTextString('RC', 'RATING: ' .. ratingSarv)
    setTextString('SC', 'SCORE:' .. score)
    if enableAcc then
        setTextString('AC', 'ACCURACY: ' .. round((getProperty('ratingPercent') * 100), 2) .. '%')
    end
    if enableTime then
        setTextString('TM', milliToHuman(
            math.floor(songLength - (getPropertyFromClass('Conductor', 'songPosition') - noteOffset))))
    end
end

function colorBox(color)
    setProperty('boxInfo.color', getColorFromHex(color))
    if enableAcc then
        setProperty('AccInfo.color', getColorFromHex(color))
    end
    if enableTime then
        setProperty('TimeInfo.color', getColorFromHex(color))
    end
end

-- functions that are taken from the place called internet (credits are included so dw) --

function milliToHuman(milliseconds) -- https://forums.mudlet.org/viewtopic.php?t=3258 (modified a bit so that it doesn't have an extra zero on the minutes like from 05:00 to 5:00 [i don't know how to explain it better so uhh there's that])
    local totalseconds = math.floor(milliseconds / 1000)
    local seconds = totalseconds % 60
    local minutes = math.floor(totalseconds / 60)
    minutes = minutes % 60
    return string.format("%2d:%02d", minutes, seconds)
end

function round(x, n) -- https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then
        x = math.floor(x + 0.5)
    else
        x = math.ceil(x - 0.5)
    end
    return x / n
end
