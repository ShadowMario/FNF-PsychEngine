local visible = true  -- on or off

local ratingGrab = {'sick', 'good', 'bad', 'shit'} -- What it'll grab
local numPrefix  = 'num'                -- Easier to change numbers 
local numSuffix  = ''

local missType   = 'miss'
local comboType  = 'combo'

local defaultPosRating = {0, 0}  
local defaultPosNum    = {0, 0}     

local showComboThng = true

local msText        = true  -- Shows your milliseconds above (or below) the notes | Kinda fucks memory a bit

local ratingScale = {0.35, 0.35}        -- You can guess what these are for | DEFAULT: rating = 0.35, 0.35 | num = 0.3, 0.3
local numScale    = {0.3, 0.3}             -- IF you mess with the numScale, be sure to adjust it's spacing down below as they might overlap
local combScale   = {0.32, 0.32}
local missScale   = {0.33, 0.33}

-- Modes --

local directNums = false   -- Combo numbers appear under ratings 

local simpleMode = false     -- Only 1 set of numbers and ratings are shown at a time

local stationaryMode = false -- Prevent the Rating hop | Simple mode recommended

local hideRating = false  -- Hides rating, not numbers (who coulda guessed)
local hideNums = false    -- Hides numbers, not ratings (who coulda guessed)


local colorRatings = true  -- Color the ratings based on rating, Sick is blue, good is green, etc
local colorSyncing = true  -- Rating takes color of direction | Overwrites colorRatings
local colorFade = true     -- Fades color back to ratingColors[4]'s value
local fcColorRating = false -- Colors Ratings based on FC level, like andromeda!!! (Turn off others, they overide this)

local colorNumbers = true  -- Same as above, but for numbers
local colorSyncNums = true
local colorFadeNums = true
local fcColorNums = false -- (Turn off others, they overide this)

local combColorFade = true

-- Colors --

-- Best with base ratings --
 
    -- Chad Hex color please --
local ratingColors = {'68fafc', '48f048', 'fffecb', 'ffffff'} 

local colorSync = {'c24b99', '68fafc', '12fa05', 'f9393f'} 


local notePositions = {}
local eh = 0        -- Make the sprites load in the way it does

local pixel = false

local numCount = 1 
local misNumCount = 1 
local comboYeah = false -- for missing with combo showin
local eorl = '-'
--------------------------------------------------------------------------|The Code Shit|---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------|By Unholywanderer04|------------------------------------------------------------------------------------------

function onDestroy()
    setPropertyFromClass('ClientPrefs', 'hideHud', false) -- (Fail Safe) So the stupid thing actually (hopefully) unhides once you complete a song >:(
end

function onCreatePost()
    if getPropertyFromClass('PlayState', 'isPixelStage') then
        pixel = true
    end

    if pixel then 
        ratingGrab = {'pixelUI/sick-pixel', 'pixelUI/good-pixel', 'pixelUI/bad-pixel', 'pixelUI/shit-pixel'}

        numPrefix = 'pixelUI/num'
        numSuffix = '-pixel'
    
        missType = 'pixelUI/miss-pixel'
        comboType = 'pixelUI/combo-pixel'

        colorSync = {'e276ff', '3dcaff', '71e300', 'ff884e'}

        ratingColors[1] = '3dcaff'
        ratingColors[2] = '71e300'

        ratingScale = {2.35, 2.35}
        numScale = {2.7, 2.7}
        combScale = {2.22, 2.22}
    end

    if msText then
        makeLuaText('msTxt', '', 300, 0, 0)
        setObjectCamera('msTxt', 'hud');
        setTextSize('msTxt', 30);
        addLuaText('msTxt');
        setTextAlignment('msTxt', 'center');
    end

    if visible == true then -- I don't get this? Why?

    end
end

local begin = false
function onUpdate()
    if not begin then -- initial note thing, constantly gets note pos until you hit a note
        for i = 0, 3 do
            lolX = getPropertyFromGroup('playerStrums', i, 'x')
            lolY = getPropertyFromGroup('playerStrums', i, 'y')
            notePositions[i] = {x = lolX, y = lolY}
        end

        if showComboThng then
            setProperty('msTxt.y', (getPropertyFromGroup('playerStrums', 0, 'y') + (downscroll and 100 or -30)))
        end
    end
        
    if downscroll then
        if not directNums then
            defaultPosNum[1] = (getPropertyFromGroup('playerStrums', 1, 'x' ) + 45)
            defaultPosNum[2] = (getPropertyFromGroup('playerStrums', 0, 'y') - 120)
        end
    else
        if not directNums then
            defaultPosNum[1] = (getPropertyFromGroup('playerStrums', 1, 'x') + 45)
            defaultPosNum[2] = (getPropertyFromGroup('playerStrums', 0, 'y') + 180) 
        end
    end

    if msText then
        setProperty('msTxt.x', (getPropertyFromGroup('playerStrums', 1, 'x') - 40))
        --setProperty('msTxt.y', (getPropertyFromGroup('playerStrums', 0, 'y') + (downscroll and 100 or -30)))
    end
    
    if visible then
        setPropertyFromClass('ClientPrefs', 'hideHud', true)
    else
        setPropertyFromClass('ClientPrefs', 'hideHud', false) 
    end
    
    if (getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SEVEN') or getPropertyFromClass('flixel.FlxG', 'keys.justPressed.EIGHT')) then
        setPropertyFromClass('ClientPrefs', 'hideHud', false)
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote) 
    if visible then
        if not isSustainNote then
            if simpleMode then
                eh = 0 -- Keeps 'eh' at 0 so it can't spawn more than one at a time
            end

            begin = true
            updateNotePos(direction)

            -- Took from Whitty mod >:)
            strumTime = getPropertyFromGroup('notes', id, 'strumTime')
            hmm = getRating(strumTime - getSongPosition() + getPropertyFromClass('ClientPrefs','ratingOffset'))
            
            -- small thing, checks rating color
            useColor = ''
            ratiNum = 0

            if  hmm == 'sick' then ratiNum = 1 elseif 
                hmm == 'good' then ratiNum = 2 elseif
                hmm == 'bad'  then ratiNum = 3 elseif
                hmm == 'shit' then ratiNum = 4
            else
                ratiNum = nil
            end
            
            if msText then setProperty('msTxt.color', getColorFromHex(ratingColors[ratiNum])) 
                setProperty('msTxt.y', (getPropertyFromGroup('playerStrums', 0, 'y') + (downscroll and 107 or -30)))
                if getPropertyFromGroup('notes', id, 'strumTime') < getSongPosition() then
                    eorl = ''
                else
                    eorl = '-'
                end    
            end

            if ratiNum ~= nil then
                useColor = ratingColors[ratiNum]
            else
                useColor = ratingColors[4]
            end
            
            if hideRating == true then -- so the color gets set based on rating, THEN it removes the rating
                hmm = ''
                ratiNum = nil
            end

            if fcColorRating or fcColorNums then
                levelNum = 0
                if getProperty('ratingFC') == 'SFC' then levelNum = 1 elseif 
                   getProperty('ratingFC') == 'GFC' then levelNum = 2 elseif
                   getProperty('ratingFC') == 'FC'  then levelNum = 3 else levelNum = 4 end
            end

            thisOne = nil
            numUse = nil

            if colorRatings and not colorSyncing then
                thisOne = useColor
            elseif colorSyncing then
                if hmm ~= 'shit' then thisOne = colorSync[direction+1] else thisOne = ratingColors[4] end
            elseif fcColorRating then
                thisOne = ratingColors[levelNum]
            else
                thisOne = ratingColors[4]
            end
            combUse = thisOne

            if combColor == false then
                combUse = ratingColors[4]
            end

            if colorNumbers and not colorSyncNums then numUse = useColor
            elseif colorSyncNums then numUse = colorSync[direction+1]
            elseif fcColorNums then numUse = ratingColors[levelNum]
            else numUse = ratingColors[4] end


            -------------------------------Ratings---------------------------------------            
            if ratiNum ~= nil then
                if not simpleMode then spawnR8 = hmm .. 'ly' .. eh else spawnR8 = 'rating' end
                makeLuaSprite(spawnR8, ratingGrab[ratiNum], notePositions[direction].noteX - 10, notePositions[direction].noteY - (stationaryMode and 15 or 0))
            end

            setProperty(spawnR8 .. '.color', getColorFromHex(thisOne))
            setObjectCamera(spawnR8, 'hud')
            setObjectOrder(spawnR8, getObjectOrder('strumLineNotes')-1)
            scaleObject(spawnR8, ratingScale[1], ratingScale[2])
            if pixel then
                setProperty(spawnR8 .. '.antialiasing', false)
            end

            addLuaSprite(spawnR8, true)
            if not stationaryMode then
                setProperty(spawnR8 .. '.acceleration.y', 550)
                setProperty(spawnR8 ..'.velocity.y', -180)
            end
            doTweenAlpha('nachotweenRatn' .. eh .. hmm, spawnR8, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
            if colorFade then
                doTweenColor('coolRatn' .. eh, spawnR8, ratingColors[4], 0.2 + (stepCrochet * 0.002), 'quartIn')
            end
            if getProperty(spawnR8 ..'.alpha') == 0 then
                removeLuaSprite(spawnR8, false)
            end  
            
            if showComboThng and getProperty('combo') >= 10 then
                comboYeah = true
                if directNums then yeep = eh 
                    makeLuaSprite('combThing' .. yeep, comboType, notePositions[direction].noteX, notePositions[direction].noteY + (downscroll and 50 or 65))
                else yeep = 1 
                    makeLuaSprite('combThing' .. yeep, comboType, defaultPosNum[1] + 12, defaultPosNum[2] + (downscroll and -40 or 30))
                end
                
                setObjectCamera('combThing' .. yeep, 'hud')
                if pixel then
                   setProperty('combThing' .. yeep .. '.antialiasing', false)
                end

                setObjectOrder('combThing' .. yeep, getObjectOrder('strumLineNotes')-1)
                scaleObject('combThing' .. yeep, combScale[1], combScale[2])

                setProperty('combThing' .. yeep .. '.color', getColorFromHex(thisOne))
                addLuaSprite('combThing' .. yeep, true)
                if not stationaryMode then
                    if directNums then
                        setProperty('combThing' .. yeep .. '.acceleration.y', 550)
                        setProperty('combThing' .. yeep .. '.velocity.y', -180)
                    end
                end
                if not directNums then
                    runTimer('fuckOffNowCombo', (stepCrochet * 0.008))
                else
                    doTweenAlpha('nachotweenCombGo' .. yeep, 'combThing' .. yeep, 0, 0.2 + (stepCrochet * 0.008), 'quartIn')
                end
                if combColorFade then
                    doTweenColor('coolCom' .. yeep, 'combThing' .. yeep, ratingColors[4], 0.2 + (stepCrochet * 0.006), 'quartIn')
                end
                if getProperty('combThing'.. yeep .. '.alpha') == 0 then
                   removeLuaSprite('combThing'.. yeep, true)
                end   
            end

            eh = eh + 1 -- makes the sprites spawn the way they do

            if eh > 100 then
                eh = 0 -- So it begins to overwrite inital sprites (stops lag)
            end

            -------------------------------Counter---------------------------------------
            bruh = getProperty('combo')
            lol = {}
            uno = table.insert(lol, (math.floor(bruh % 10)))
            dos = table.insert(lol, (math.floor((bruh / 10) % 10)))
            thr = table.insert(lol, (math.floor((bruh / 100) % 10)))
            if bruh >= 1000 then
                fuo = table.insert(lol, (math.floor(bruh / 1000) % 10))
            end
            --------------------------------Numbers----------------------------------------
                               
            if not hideNums then
                numCount = 1 -- 1 | Lua starts at fuckn 1 soooo
                useNumber = defaultPosNum[1] + 25
                if bruh >= 10 then numCount = 2 useNumber = defaultPosNum[1] + 12.5 end -- 01
                if bruh >= 100 then numCount = 3 useNumber = defaultPosNum[1] end -- 001
                if bruh >= 1000 then numCount = 4 useNumber = defaultPosNum[1] - 12.5 end -- 0001

                sequence = nil
                for i = 1, numCount do
                    multBy = (((i - 1) - numCount) * 25)

                    spawn = eh .. i
                    sequence = numPrefix .. lol[i] .. numSuffix  

                    if directNums then
                        makeLuaSprite('num' .. spawn, sequence, useNumber + (notePositions[direction].numX - multBy), notePositions[direction].numY - 10)
                    else
                        spawn = i -- fixes multiple spawning numbers
                        makeLuaSprite('num' .. spawn, sequence, (useNumber - multBy), defaultPosNum[2])
                    end
                    setObjectCamera('num' .. spawn, 'hud')

                    setProperty('num'.. spawn .. '.color', getColorFromHex(numUse))
                    setObjectOrder('num' .. spawn, getObjectOrder('strumLineNotes')-1)
                    if pixel then
                        setProperty('num' .. spawn .. '.antialiasing', false)
                    end

                    scaleObject('num' .. spawn, numScale[1], numScale[2])
                    addLuaSprite('num' .. spawn, true)
                    if not stationaryMode then
                        if directNums then
                            setProperty('num'.. spawn ..'.velocity.y', -160)
                            setProperty('num' .. spawn .. '.acceleration.y', 400)
                        end
                    end
                    if not directNums then
                        runTimer('fuckOffNow', (stepCrochet * 0.008))
                    else
                        doTweenAlpha('nachotweenNumGo' .. eh .. i, 'num' .. spawn, 0, 0.2 + (stepCrochet * 0.008), 'quartIn')
                    end
                    if colorFadeNums then
                        doTweenColor('itsjustafad' .. eh .. i, 'num' .. spawn, ratingColors[4], 0.2 + (stepCrochet * 0.006), 'quartIn')
                    end
                end
            end
        end
    end
end

local missMAX = false
function noteMiss(id, direction, noteType, isSustainNote) --Sets back to 0
    eh = eh + 1
    
    if eh > 100 then
        eh = 0
    end

    begin = true
    updateNotePos(direction)
    
    makeLuaSprite('looser' .. eh, missType, notePositions[direction].noteX - 10, notePositions[direction].noteY)
    setObjectCamera('looser' .. eh, 'hud')
    if pixel then
        setProperty('looser' .. eh .. '.antialiasing', false)
    end
    scaleObject('looser' .. eh, missScale[1], missScale[2])
    
    setObjectOrder('looser' .. eh, getObjectOrder('strumLineNotes')-1)
    addLuaSprite('looser' .. eh, true)
    if not stationaryMode then
        setProperty('looser' .. eh .. '.acceleration.y', 550)
        setProperty('looser' .. eh .. '.velocity.y', -180)
    end
    doTweenAlpha('nachotweenBru' .. eh, 'looser' .. eh, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
    if getProperty('looser'.. eh .. '.alpha') == 0 then
        removeLuaSprite('looser'.. eh, true)
    end

    if not hideNums and not directNums then
        for i = 1, numCount do
            removeLuaSprite('num'..i)
        end
    end

    if showComboThng and not directNums and comboYeah then
        comboYeah = false
        removeLuaSprite('combThing1', false)

        if pixel then guh = 'pixelUI/comboBroke-pixel' else guh = 'comboBroke' end

        makeLuaSprite('combMiss', guh, defaultPosNum[1] + 12, defaultPosNum[2] + (downscroll and -35 or 25))
        setObjectCamera('combMiss', 'hud')

        if pixel then setProperty('combMiss.antialiasing', false) end

        setObjectOrder('combMiss', getObjectOrder('strumLineNotes')-1)
        scaleObject('combMiss', combScale[1], combScale[2])
        setProperty('combMiss.color', getColorFromHex('bc0000'))

        addLuaSprite('combMiss', true)

        setProperty('combMiss.angularVelocity', math.random(-50, 50))
        setProperty('combMiss.acceleration.y', 650)
        setProperty('combMiss.velocity.y', -120) 

        doTweenAlpha('comFUckedup', 'combMiss', 0, 0.7, 'quartInOut')
    end

    blap = getProperty('songMisses')

    if not missMAX then
        missCount = {} 
        unoMis = table.insert(missCount, math.floor((blap % 10)))
        if blap >= 10 then
            dosMis = table.insert(missCount, math.floor((blap / 10) % 10))
            if blap >= 100 then
                thrMis = table.insert(missCount, math.floor((blap / 100) % 10))
                if blap >= 1000 then
                    missMAX = true -- doesn't go above 1000, no need to, you don't suck THAT much
                end
            end
        end
        miSysmbol = table.insert(missCount, 'minus') -- always at the end for consistency 
    else
        missCount = {9, 9, 9, 'minus'} 
    end

    if not hideNums then
        misNumCount = 2
        useNumber = defaultPosNum[1] + 50 -- 01
        if blap >= 10 then misNumCount = 3 useNumber = defaultPosNum[1] + 25 end -- 001
        if blap >= 100 then misNumCount = 4 useNumber = defaultPosNum[1] + 12.5 end -- 0001
        --if blap >= 1000 then misNumCount = 4 useNumber = defaultPosNum[1] - 10 end -- 0001

        if pixel then mPrefi = 'pixelUI/' else mPrefi = '' end
        
        sequence = nil
        for i = 1, misNumCount do
            multBy = ((i - misNumCount) * 25)

            if type(missCount[i]) ~= 'number' then
                sequence = mPrefi .. missCount[i] .. numSuffix
            else
                sequence = numPrefix .. missCount[i] .. numSuffix
            end

            spawn = eh .. i
            if directNums then
                makeLuaSprite('fuke' .. spawn, sequence, (notePositions[direction].numX - multBy), notePositions[direction].numY)
            else
                spawn = i
                makeLuaSprite('fuke' .. spawn, sequence, (useNumber - multBy), defaultPosNum[2] - (downscroll and 35 or -35))
            end
            
            setObjectCamera('fuke' .. spawn, 'hud')
            setProperty('fuke'.. spawn .. '.color', getColorFromHex('bc0000'))
            setObjectOrder('fuke' .. spawn, getObjectOrder('strumLineNotes')-1)
            if pixel then
                setProperty('fuke' .. spawn .. '.antialiasing', false)
            end
            scaleObject('fuke' .. spawn, numScale[1], numScale[2])
            addLuaSprite('fuke' .. spawn, true)
            if not stationaryMode then
                if directNums then
                    setProperty('fuke'.. spawn ..'.velocity.y', -160)
                    setProperty('fuke' .. spawn .. '.acceleration.y', 400)
                end
            end
            doTweenAlpha('nachotweenMissNum' .. eh .. i, 'fuke' .. spawn, 0, 0.2 + (stepCrochet * 0.008), 'quartIn') 
        end
    end
end

function onTimerCompleted(t, l, ll)
    if t == 'fuckOffNow' then
        for i = 0, numCount do
            doTweenAlpha('nachotweenNumGo' .. i, 'num' .. i, 0, 0.2, 'quartIn')
        end
    end

    if t == 'fuckOffNowCombo' then
        doTweenAlpha('nachotweenCombgo1', 'combThing1', 0, 0.2, 'quartIn')
    end
end

function getRating(diff)
	diff = math.abs(diff)

    if msText then
        setProperty('msTxt.alpha', 1)
        setTextString('msTxt', eorl..round(diff, 2)..' ms')
        doTweenAlpha('fadeOuttaHere', 'msTxt', 0, 0.2 + (stepCrochet * 0.006), 'quartInOut')
        doTweenY('awayWithYou', 'msTxt', (getProperty('msTxt.y') + (downscroll and 35 or -20)), 0.2 + (stepCrochet * 0.006), 'quartInOut')
    end

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

function updateNotePos(direction) -- so a for loop isn't just mashed into functions
    if direction == nil then direction = 3 end
    for i = 0, direction do
        lolX = getPropertyFromGroup('playerStrums', i, 'x')
        if directNums then 
            lulX = getPropertyFromGroup('playerStrums', i, 'x') - 12 else
            lulX = getPropertyFromGroup('playerStrums', 1, 'x') + 45 end
        if downscroll then
            if directNums then
                lolY = getPropertyFromGroup('playerStrums', i, 'y') - 60                    
                lulY = getPropertyFromGroup('playerStrums', i, 'y') - 10
            else
                lolY = getPropertyFromGroup('playerStrums', i, 'y') - 35                    
            end
        else
            lolY = getPropertyFromGroup('playerStrums', i, 'y') + 130 
            if directNums then
                lulY = getPropertyFromGroup('playerStrums', i, 'y') + 180 
            end
        end

        notePositions[i] = {noteX = lolX, noteY = lolY, numX = lulX, numY = lulY}
    end
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end