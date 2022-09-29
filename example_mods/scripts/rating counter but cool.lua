local visible = true

local pixel = false 

local ratings = {'sick', 'good', 'bad', 'shit', 'miss'}
local ratPrefix = ''
local ratSuffix = ''                

local numPrefix = 'croppedNums/num'     -- please don't use the regular numbers, their cropping makes it look bad           
local numSuffix = ''

local defaultPosRating = {450, 280}
local defaultPosNum = {450, 400} 

local ratingScale = {0.35, 0.35}   
local numScale = {0.2, 0.2}        

local sicks = 0
local goods = 0
local bads = 0
local shits = 0

local sickCount = {}
local goodCount = {}
local badCount = {}
local shitCount = {}
local missCount = {}

local initalY = {0, 0, 0, 0, 0}
local colorNShit = {'68fafc', '48f048', 'fffecb', 'ffffff', 'ffffff'}

local zoomAmount = 0.08

local below = false -- check
function onCreate() -- b of the best panzus
    curver = 0

    bit = string.gsub(version,"%.","")
    curver = tonumber(bit)
end

function onCreatePost()
    if getPropertyFromClass('PlayState', 'isPixelStage') == true then
        pixel = true
    end

    if pixel == true then 
        ratPrefix = 'pixelUI/'
        ratSuffix = '-pixel'
        zoomAmount = 0.5

        ratingScale[1] = 2.35
        ratingScale[2] = 2.35

        numPrefix = 'pixelUI/num'
        numSuffix = '-pixel'
        numScale[1] = 2
        numScale[2] = 2

        colorNShit[1] = '3dcaff'
        colorNShit[2] = '71e300'
    end

    for i = 1, 5 do
        makeLuaSprite('head'..ratings[i], ratPrefix .. ratings[i] .. ratSuffix, 50, 120 + (i * 75)) 
    
        setProperty('head'..ratings[i]..'.color', getColorFromHex(colorNShit[i]))
        setObjectCamera('head'..ratings[i], 'hud')
        setProperty('head'..ratings[i]..'.alpha', 0.6)
        setObjectOrder('head'..ratings[i], getObjectOrder('strumLineNotes')-1)
        scaleObject('head'..ratings[i], ratingScale[1], ratingScale[2])
        if pixel == true then
            setProperty('head'..ratings[i]..'.antialiasing', false)
        end
        addLuaSprite('head'..ratings[i], true)
        initalY[i] = getProperty('head'..ratings[i]..'.y')
    end

    
    for i = 1, 5 do
        i1 = ratings[i]
        useX = getProperty('head'..ratings[i]..'.x')
        useY = getProperty('head'..ratings[i]..'.y')

        for i = 1, 3 do
            makeLuaSprite('baseCount'.. i1 .. i, numPrefix..'0'..numSuffix, useX + 75 + ((i - 1) * 18), useY + 50) 
            setObjectCamera('baseCount'.. i1 .. i, 'hud')
            setObjectOrder('baseCount'.. i1 .. i, getObjectOrder('strumLineNotes')-1)
            scaleObject('baseCount'.. i1 .. i, numScale[1], numScale[2])
            setProperty('baseCount'.. i1 .. i..'.alpha', 0.6)
            if i1 == ratings[5] then
                setProperty('baseCount'.. i1 .. i ..'.color', getColorFromHex('bc0000'))
            end
            if pixel == true then
                setProperty('baseCount'.. i1 .. i..'.antialiasing', false)
            end
            addLuaSprite('baseCount'.. i1 .. i, true)
        end
    end
end

function onStartCountdown()
    if curver <= 52 then 
        below = true
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote)    
    if not isSustainNote then
        if not below then
            hmm = getPropertyFromGroup('notes', id, 'rating')
            --debugPrint('6.0 and above havin ass')
        elseif below then
            strumTime = getPropertyFromGroup('notes', id, 'strumTime')
            hmm = getRating(strumTime - getSongPosition() + getPropertyFromClass('ClientPrefs','ratingOffset'))
            --debugPrint('below 6.0 havin ass')
        end

        if getProperty('head'..hmm..'.alpha') ~= 1 then setProperty('head'..hmm..'.alpha', 1) end
        if getProperty('baseCount'..hmm..'3.visible') == true then removeTempNums(hmm) end


        if hmm == 'sick' then
            setProperty('headsick.scale.x', ratingScale[1] + zoomAmount)
            setProperty('headsick.scale.y', ratingScale[2] + zoomAmount)
            cancelTween('backToRgSX')
            cancelTween('backToRgSY')

            runTimer('sicked', 0.005)
            sicks = sicks + 1

            sickCount = {}
            uno = table.insert(sickCount, (math.floor(sicks % 10)))
            dos = table.insert(sickCount, (math.floor((sicks / 10) % 10)))
            thr = table.insert(sickCount, (math.floor((sicks / 100) % 10)))
            if sicks >= 1000 then
                fuo = table.insert(sickCount, (math.floor(sicks / 1000) % 10))
            end

            numCount = 3
            if sicks >= 1000 then numCount = 4 end -- 0001

            sequence = nil
            for i = 1, numCount do
                multBy = ((i - 1) * 18)

                sequence = numPrefix .. sickCount[i] .. numSuffix  

                makeLuaSprite('numSick' .. i, sequence, (getProperty('headsick.x') + 111) - multBy, initalY[1] + 50)
                setObjectCamera('numSick' .. i, 'hud')
                setProperty('numSick' .. i..'.color', getColorFromHex(colorNShit[1]))
                setObjectOrder('numSick' .. i, getObjectOrder('strumLineNotes')-1)
                if pixel then
                    setProperty('numSick' .. i .. '.antialiasing', false)
                end
                scaleObject('numSick' .. i, numScale[1], numScale[2])
                addLuaSprite('numSick' .. i, true)
            end
        elseif hmm == 'good' then
            setProperty('headgood.scale.x', ratingScale[1] + zoomAmount)
            setProperty('headgood.scale.y', ratingScale[2] + zoomAmount)
            cancelTween('backToRgGX')
            cancelTween('backToRgGY')

            runTimer('gooded', 0.05)
            goods = goods + 1

            goodCount = {}
            uno = table.insert(goodCount, (math.floor(goods % 10)))
            dos = table.insert(goodCount, (math.floor((goods / 10) % 10)))
            thr = table.insert(goodCount, (math.floor((goods / 100) % 10)))
            if goods >= 1000 then
                fuo = table.insert(goodCount, (math.floor(goods / 1000) % 10))
            end

            numCount = 3
            if goods >= 1000 then numCount = 4 end -- 0001

            sequence = nil
            for i = 1, numCount do
                multBy = ((i - 1) * 18)

                sequence = numPrefix .. goodCount[i] .. numSuffix  

                makeLuaSprite('numGood' .. i, sequence, (getProperty('headgood.x') + 111) - multBy, initalY[2] + 50)
                setObjectCamera('numGood' .. i, 'hud')
                setProperty('numGood' .. i..'.color', getColorFromHex(colorNShit[2]))
                setObjectOrder('numGood' .. i, getObjectOrder('strumLineNotes')-1)
                if pixel then
                    setProperty('numGood' .. i .. '.antialiasing', false)
                end
                scaleObject('numGood' .. i, numScale[1], numScale[2])
                addLuaSprite('numGood' .. i, true)
            end
        elseif hmm == 'bad' then
            setProperty('headbad.scale.x', ratingScale[1] + zoomAmount)
            setProperty('headbad.scale.y', ratingScale[2] + zoomAmount)
            cancelTween('backToRgBX')
            cancelTween('backToRgBY')
            
            runTimer('baded', 0.05)
            bads = bads + 1

            badCount = {}
            uno = table.insert(badCount, (math.floor(bads % 10)))
            dos = table.insert(badCount, (math.floor((bads / 10) % 10)))
            thr = table.insert(badCount, (math.floor((bads / 100) % 10)))
            if bads >= 1000 then
                fuo = table.insert(badCount, (math.floor(bads / 1000) % 10))
            end

            numCount = 3
            if bads >= 1000 then numCount = 4 end -- 0001

            sequence = nil
            for i = 1, numCount do
                multBy = ((i - 1) * 18)

                sequence = numPrefix .. badCount[i] .. numSuffix  

                makeLuaSprite('numBad' .. i, sequence, (getProperty('headbad.x') + 111) - multBy, initalY[3] + 50)
                setObjectCamera('numBad' .. i, 'hud')
                setProperty('numBad' .. i..'.color', getColorFromHex(colorNShit[3]))
                setObjectOrder('numBad' .. i, getObjectOrder('strumLineNotes')-1)
                if pixel then
                    setProperty('numBad' .. i .. '.antialiasing', false)
                end
                scaleObject('numBad' .. i, numScale[1], numScale[2])
                addLuaSprite('numBad' .. i, true)
            end
        elseif hmm == 'shit' then
            setProperty('headshit.scale.x', ratingScale[1] + zoomAmount)
            setProperty('headshit.scale.y', ratingScale[2] + zoomAmount)
            cancelTween('backToRgShX')
            cancelTween('backToRgShY')
            
            runTimer('shited', 0.05)
            shits = shits + 1

            shitCount = {}
            uno = table.insert(shitCount, (math.floor(shits % 10)))
            dos = table.insert(shitCount, (math.floor((shits / 10) % 10)))
            thr = table.insert(shitCount, (math.floor((shits / 100) % 10)))
            if shits >= 1000 then
                fuo = table.insert(shitCount, (math.floor(shits / 1000) % 10))
            end

            numCount = 3
            if shits >= 1000 then numCount = 4 end -- 0001

            sequence = nil
            for i = 1, numCount do
                multBy = ((i - 1) * 18)

                sequence = numPrefix .. shitCount[i] .. numSuffix  

                makeLuaSprite('numShit' .. i, sequence, (getProperty('headsick.x') + 111) - multBy, initalY[4] + 50)
                setObjectCamera('numShit' .. i, 'hud')
                setProperty('numShit' .. i..'.color', getColorFromHex(colorNShit[4]))
                setObjectOrder('numShit' .. i, getObjectOrder('strumLineNotes')-1)
                if pixel then
                    setProperty('numShit' .. i .. '.antialiasing', false)
                end
                scaleObject('numShit' .. i, numScale[1], numScale[2])
                addLuaSprite('numShit' .. i, true)
            end
        end
    end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if getProperty('headmiss.alpha') ~= 1 then setProperty('headmiss.alpha', 1) end
    if getProperty('baseCountmiss3.visible') == true then removeTempNums('miss') end

    setProperty('headmiss.scale.x', ratingScale[1] + zoomAmount)
    setProperty('headmiss.scale.y', ratingScale[2] + zoomAmount)
    cancelTween('backToRgMX')
    cancelTween('backToRgMY')
    
    runTimer('missed', 0.05)
    miss = getProperty('songMisses')

    missCount = {}
    uno = table.insert(missCount, (math.floor(miss % 10)))
    dos = table.insert(missCount, (math.floor((miss / 10) % 10)))
    thr = table.insert(missCount, (math.floor((miss / 100) % 10)))
    if miss >= 1000 then
        fuo = table.insert(missCount, (math.floor(miss / 1000) % 10))
    end

    numCount = 3
    if miss >= 1000 then numCount = 4 end -- 0001

    sequence = nil
    for i = 1, numCount do
        multBy = ((i - 1) * 18)

        sequence = numPrefix .. missCount[i] .. numSuffix  

        makeLuaSprite('numMiss' .. i, sequence, (getProperty('headsick.x') + 111) - multBy, initalY[5] + 50)
        setObjectCamera('numMiss' .. i, 'hud')
        setProperty('numMiss'..i..'.color', getColorFromHex('bc0000'))
        setObjectOrder('numMiss' .. i, getObjectOrder('strumLineNotes')-1)
        if pixel then
            setProperty('numMiss' .. i .. '.antialiasing', false)
        end
        scaleObject('numMiss' .. i, numScale[1], numScale[2])
        addLuaSprite('numMiss' .. i, true)
    end
end

function onTimerCompleted(t, l, ll)
    if t == 'sicked' then
        doTweenX('backToRgSX', 'headsick.scale', ratingScale[1], 0.2, 'linear')
        doTweenY('backToRgSY', 'headsick.scale', ratingScale[2], 0.2, 'linear')
    end
    if t == 'gooded' then
        doTweenX('backToRgGX', 'headgood.scale', ratingScale[1], 0.2, 'linear')
        doTweenY('backToRgGY', 'headgood.scale', ratingScale[2], 0.2, 'linear')
    end
    if t == 'baded' then
        doTweenX('backToRgBX', 'headbad.scale', ratingScale[1], 0.2, 'linear')
        doTweenY('backToRgBY', 'headbad.scale', ratingScale[2], 0.2, 'linear')    
    end
    if t == 'shited' then
        doTweenX('backToRgShX', 'headshit.scale', ratingScale[1], 0.2, 'linear')
        doTweenY('backToRgShY', 'headshit.scale', ratingScale[2], 0.2, 'linear')   
    end
    if t == 'missed' then
        doTweenX('backToRgMX', 'headmiss.scale', ratingScale[1], 0.2, 'linear')
        doTweenY('backToRgMY', 'headmiss.scale', ratingScale[2], 0.2, 'linear')
    end
end

function getRating(diff) -- grrr grrr you know the man, the myth, the legend, bbpanzu
	diff = math.abs(diff)
	if diff <= getPropertyFromClass('ClientPrefs', 'badWindow') then
		if diff <= getPropertyFromClass('ClientPrefs', 'goodWindow') then
			if diff <= getPropertyFromClass('ClientPrefs', 'sickWindow') then
				return 'sick'
			end
			return 'good'
		end
		return 'bad'
	end
	return 'shit'
end

function removeTempNums(rating)
    for i = 1, 3 do
        setProperty('baseCount'..rating..i..'.visible', false)
        --debugPrint(rating..i..' is gone')
    end
end