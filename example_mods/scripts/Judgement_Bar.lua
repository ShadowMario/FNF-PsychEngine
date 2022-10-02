local ntbcolor = {"3E5FE0","1EBC73","F9C22B","E83B3B","808080"}

function onCreate()
    createQuickBox('judgebg', (screenWidth - 80), ((screenHeight / 2) - (350 / 2)), 19 , 350, "000000", 1)
    createQuickBox('judgefg', getProperty('judgebg.x') + 4, getProperty('judgebg.y') + 4, (19 - 8), (350 - 8), "404040", 1)
    addLuaSprite('judgebg', true)
    addLuaSprite('judgefg', true)
    for i = 1, 5 do
        createQuickBox('judgementbar' .. i, getProperty('judgefg.x'), getProperty('judgefg.y'), (19 - 8), (350 - 8), ntbcolor[i], 1)
        setProperty('judgementbar' .. i .. '.origin.x', getProperty('judgementbar'..i..'.width') * 0.5)
        setProperty('judgementbar' .. i .. '.origin.y', 0)

        createTextQuick("judgetext" .. i, "0", 0, 0, 0, "center", 32, 2.5, ntbcolor[i], '000000')
        setProperty("judgetext"..i..".visible", false)
    end
end

function onCreatePost()
    setObjectOrder('judgebg', getObjectOrder('healthBar'))
    setObjectOrder('judgefg', getObjectOrder('judgebg') + 1)
    for i = 1, 5 do
        addLuaSprite('judgementbar' .. i, true)
        addLuaText("judgetext" .. i)
        setObjectOrder('judgementbar' .. i, getObjectOrder('judgefg') + i)
        setObjectOrder('judgetext' .. i, getObjectOrder('judgementbar1') + i)
    end
end

function onUpdatePost()
    local sicks = getProperty("sicks")
    local goods = getProperty("goods")
    local bads = getProperty("bads")
    local shits = getProperty("shits")
    local songMisses = getProperty("songMisses")

    local alltogether = (sicks + goods + bads + shits + songMisses)

    if alltogether ~= 0 then
        sickspercent = toPercentage(sicks, alltogether)
        goodspercent = toPercentage(goods, alltogether)
        badspercent = toPercentage(bads, alltogether)
        shitspercent = toPercentage(shits, alltogether)
        songMissespercent = toPercentage(songMisses, alltogether)
    else
        sickspercent = 0
        goodspercent = 0
        badspercent = 0
        shitspercent = 0
        songMissespercent = 0
    end

    judgeamount = {sicks, goods, bads, shits, songMisses}

    judgepercentages = {sickspercent, goodspercent, badspercent, shitspercent, songMissespercent}

    for i = 1, 5 do
        if judgeamount[i] > 0 then
            setProperty("judgetext"..i..".visible", true)

            setTextString("judgetext" .. i, tostring(judgeamount[i]))

            setTextSize("judgetext" .. i, 32 * (0.5 + ((judgepercentages[i] / 100) / 2)))
            setProperty("judgetext" .. i .. '.borderSize', 2.75 * (0.5 + ((judgepercentages[i] / 100) / 2)))

            setProperty("judgetext"..i..".x", (getProperty("judgementbar" .. i .. ".x") + ((getProperty("judgementbar" .. i .. ".width") / 2) - (getProperty("judgetext" .. i .. ".width") / 2)) - 1.5))
            setProperty("judgetext"..i..".y", (getProperty("judgementbar" .. i .. ".y") + (((getProperty("judgementbar" .. i .. ".height") * (judgepercentages[i] / 100)) / 2) - (getProperty("judgetext" .. i .. ".height") / 2))))
        end
    end

    -- make the bar size depending on something
    for i = 1, 5 do
        setProperty('judgementbar'.. i..'.scale.y', (judgepercentages[i] / 100))
    end
    setProperty('judgementbar1.y', getProperty('judgefg.y'))
    for i = 1, 4 do
        setProperty('judgementbar' .. (i + 1) .. '.y', (getProperty('judgementbar' .. i .. '.y') + (getProperty('judgementbar' .. i .. '.height') * (judgepercentages[i] / 100))))
    end
end

function createTextQuick(tag, text, x, y, width, alignment, size, bsize, color, bcolor)
    makeLuaText(tag, text, width, x, y)
    setTextSize(tag, size)
    setTextAlignment(tag, alignment);
    updateHitbox(tag)
    setTextColor(tag, color)
    setProperty(tag .. '.borderSize', bsize)
    setProperty(tag .. '.borderColor', getColorFromHex(bcolor));
    setObjectCamera(tag, 'hud')
end

function createQuickBox(tag, x, y, width, height, color, alpha)
    makeLuaSprite(tag, '', x, y)
    makeGraphic(tag, width, height, color)
    setProperty(tag .. '.alpha', alpha)
    setObjectCamera(tag, 'hud')
end

function toPercentage(value, total)
    if total > 0 then
        return ((value / total) * 100)
    end
end