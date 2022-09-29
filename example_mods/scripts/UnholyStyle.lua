-- Settings (Player) --

local visible = true  -- on or off

local pixel = false 

local directNums = false   -- Combo numbers appear under ratings 

local ratingGrab = {'sick', 'good', 'bad', 'shit'} -- What it'll grab
local numPrefix = 'num'                -- Easier to change numbers 
local numSuffix = ''

local missType = 'miss'

local defaultPosRating = {0, 0}  
local defaultPosNum = {0, 0}     


local ratingScale = {0.35, 0.35}        -- You can guess what these are for | DEFAULT: rating = 0.69, 0.69 | num = 0.5, 0.5
local numScale = {0.3, 0.3}             -- IF you mess with the numScale, be sure to adjust it's spacing down below as they might overlap

-- Modes (Player) --

local simpleMode = false -- Only 1 set of numbers and ratings are shown at a time | Helps prevent lag

local stationaryMode = false -- Prevent the Rating hop | Simple mode recommended

local hideRating = false  -- Hides rating, not numbers (who coulda guessed)
local hideNums = false    -- Hides numbers, not ratings (who coulda guessed)


local colorRatings = true  -- Color the ratings based on which you get, Sick is blue, good is green, etc
local colorSyncing = true -- Let the colors shine tonight | Rating takes color of direction pressed | Not for custom colors | Overwrites colorRatings
local colorFade = true    -- Fades color back to baseColor's value
local fcColorRating = false -- Colors Ratings based of FC level, like andromeda!!! (Turn off others, they overide this)

local colorNumbers = true -- Same as above, but for numbers
local colorSyncNums = true
local colorFadeNums = true
local fcColorNums = false -- Colors numbers based of FC level, like andromeda!!! (Turn off others, they overide this)


-- Colors --

-- Best with base ratings --
 
    -- Chad Hex color please --
local sickColor = '68fafc'
local goodColor = '48f048'
local badColor = 'fffecb'
local baseColor = 'ffffff' 

local colorSync0 = 'c24b99' -- left 
local colorSync1 = '68fafc' -- down 
local colorSync2 = '12fa05' -- up   
local colorSync3 = 'f9393f' -- right


-- Dont touch these unless you know what you're doing | I don't sadly :(
local eh = 0        -- Make the sprites load in the way it does
local notePositions = {}
--
local doThing = false

--------------------------------------------------------------------------|The Code Shit|---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------|By Unholywanderer04|------------------------------------------------------------------------------------------

function onCreate() -- bbPantsZoo
    curver = 0

    bit = string.gsub(version,"%.","")
    curver = tonumber(bit)
end

function onDestroy()
    if doThing == false then
        setPropertyFromClass('ClientPrefs', 'hideHud', false) -- (Fail Safe) So the stupid thing actually (hopefully) unhides once you complete a song >:(
    end
end

function onCreatePost()
    if curver >= 60 then 
        doThing = true
    end

    if getPropertyFromClass('PlayState', 'isPixelStage') == true then
        pixel = true
    end

    if pixel == true then 
        ratingGrab[1] = 'pixelUI/sick-pixel' 
        ratingGrab[2] = 'pixelUI/good-pixel'
        ratingGrab[3] = 'pixelUI/bad-pixel' 
        ratingGrab[4] = 'pixelUI/shit-pixel'

        numPrefix = 'pixelUI/num'
        numSuffix = '-pixel'
    
        missType = 'pixelUI/miss-pixel'

        colorSync0 = 'e276ff'
        colorSync1 = '3dcaff'
        colorSync2 = '71e300'
        colorSync3 = 'ff884e'

        sickColor = '3dcaff'
        goodColor = '71e300'

        ratingScale[1], ratingScale[2] = 2.35, 2.35
        numScale[1], numScale[2] = 2.7, 2.7
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
    
    if visible then
        if doThing == true then
            if getProperty('showRating') ~= false then
                setProperty('showRating', false)
                setProperty('showComboNum', false)
            end
        else    
            setPropertyFromClass('ClientPrefs', 'hideHud', true)
        end
    else
        if doThing == false then
            if getProperty('showRating') ~= true then
                setProperty('showRating', true)
                setProperty('showComboNum', true)
            end
        else    
            setPropertyFromClass('ClientPrefs', 'hideHud', false) 
        end
    end
    
    if (getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SEVEN') or getPropertyFromClass('flixel.FlxG', 'keys.justPressed.EIGHT')) and doThing == false then
        setPropertyFromClass('ClientPrefs', 'hideHud', false)
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote) 
    if visible == true then
        comboOffset = getPropertyFromClass('ClientPrefs', 'comboOffset') -- rating offsets ( [1] Rating X | [2] Rating Y | [3] Number X | [4] Number Y ) 
        if not isSustainNote then
            if simpleMode == true then
                eh = 0 -- Keeps 'eh' at 0 so it can't spawn more than one at a time
            end

            begin = true
            updateNotePos('player', direction)

            -- Took from Whitty mod >:)
            strumTime = getPropertyFromGroup('notes', id, 'strumTime')
            hmm = getRating(strumTime - getSongPosition() + getPropertyFromClass('ClientPrefs','ratingOffset'), noteType, 'bf')

            -- small thing, checks rating color
            ratingColo = ''
            ratiNum = 0

            if hmm == 'sick' then
                ratingColo = sickColor
                ratiNum = 1
            elseif hmm == 'good' then
                ratingColo = goodColor
                ratiNum = 2
            elseif hmm == 'bad' then
                ratingColo = badColor
                ratiNum = 3
            elseif hmm == 'shit' then
                ratingColo = baseColor
                ratiNum = 4
            else
                ratingColo = baseColor
                ratiNum = nil
            end
            
            if hideRating == true then -- so the color gets set based on rating, THEN it removes the rating
                hmm = ''
                ratiNum = nil
            end

            grabby = {colorSync0, colorSync1, colorSync2, colorSync3}
            thisOne = nil
            numUse = nil

            if colorRatings == true and colorSyncing == false then
                thisOne = ratingColo
            elseif colorSyncing == true then
                if hmm ~= 'shit' then thisOne = grabby[direction+1] else thisOne = baseColor end
            elseif fcColorRating == true then
                if getProperty('ratingFC') == 'SFC' then
                    thisOne = sickColor
                elseif getProperty('ratingFC') == 'GFC' then
                    thisOne = goodColor
                elseif getProperty('ratingFC') == 'FC' then
                    thisOne = badColor
                else
                    thisOne = baseColor
                end
            else
                thisOne = baseColor
            end
            
            
            if colorNumbers == true and colorSyncNums == false then
                numUse = ratingColo
            elseif colorSyncNums == true then
                numUse = grabby[direction+1]
            elseif fcColorNums == true then
                if getProperty('ratingFC') == 'SFC' then
                    numUse = sickColor
                elseif getProperty('ratingFC') == 'GFC' then
                    numUse = goodColor
                elseif getProperty('ratingFC') == 'FC' then
                    numUse = badColor
                else
                    numUse = baseColor
                end
            else
                numUse = baseColor
            end

            -------------------------------Ratings---------------------------------------            
            if ratiNum ~= nil then
                makeLuaSprite(hmm ..'ly' .. eh, ratingGrab[ratiNum], notePositions[direction].noteX - 10, notePositions[direction].noteY)
            end
            setProperty(hmm ..'ly'.. eh .. '.color', getColorFromHex(thisOne))
            setObjectCamera(hmm ..'ly' .. eh, 'hud')
            setObjectOrder(hmm ..'ly' .. eh, getObjectOrder('strumLineNotes')-1)
            scaleObject(hmm ..'ly' .. eh, ratingScale[1], ratingScale[2])
            if pixel == true then
                setProperty(hmm ..'ly' .. eh .. '.antialiasing', false)
            end
            addLuaSprite(hmm ..'ly' .. eh, true)
            if stationaryMode == false then
                setProperty(hmm ..'ly' .. eh .. '.acceleration.y', 550)
                setProperty(hmm ..'ly'.. eh ..'.velocity.x', math.random(0,10))
                setProperty(hmm ..'ly'.. eh ..'.velocity.y', -180)
            end
            doTweenAlpha('nachotweenRatn' .. eh .. hmm, hmm ..'ly' .. eh, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
            if colorFade == true then
                doTweenColor('coolRatn' .. eh, hmm ..'ly' .. eh, baseColor, 0.2 + (stepCrochet * 0.002), 'quartIn')
            end
            if getProperty(hmm ..'ly'.. eh ..'.alpha') == 0 then -- don't think this works :(, not with the default mode
                removeLuaSprite(hmm ..'ly'.. eh, false)
            end  
            

            eh = eh + 1 -- makes the sprites spawn the way they do

            if eh > 100 then
                eh = 0 -- So it begins to overwrite inital sprites (stops lag)
            end

            -------------------------------Counter---------------------------------------
            bruh = getProperty('combo')
            lol = {} -- like the source heheheheheahah
            uno = table.insert(lol, (math.floor(bruh % 10)))
            dos = table.insert(lol, (math.floor((bruh / 10) % 10)))
            thr = table.insert(lol, (math.floor((bruh / 100) % 10)))
            if bruh >= 1000 then
                fuo = table.insert(lol, (math.floor(bruh / 1000) % 10))
            end
            --------------------------------Numbers----------------------------------------
                               
            if hideNums == false then
                numCount = 1 -- 1 | Lua starts at fuckn 1 soooo
                if bruh >= 10 then numCount = 2 end -- 01
                if bruh >= 100 or foreverComboCount == false then numCount = 3 end -- 001
                if bruh >= 1000 then numCount = 4 end -- 0001

                sequence = nil
                for i = 1, numCount do
                    multBy = (((i - 1) - numCount) * 25)

                    spawn = eh .. i
                    sequence = numPrefix .. lol[i] .. numSuffix  

                    if directNums then
                        makeLuaSprite('num' .. spawn, sequence, (notePositions[direction].numX - multBy), notePositions[direction].numY)
                    else
                        spawn = i -- fixes multiple spawning numbers
                        makeLuaSprite('num' .. spawn, sequence, defaultPosNum[1] - multBy, defaultPosNum[2])
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
                            setProperty('num'.. spawn ..'.velocity.x', math.random(-5, 5))
                            setProperty('num'.. spawn ..'.velocity.y', math.random(-140, -160))
                            setProperty('num' .. spawn .. '.acceleration.y', math.random(200, 400))
                        end
                    end
                    doTweenAlpha('nachotweenNumGo' .. eh .. i, 'num' .. spawn, 0, 0.2 + (stepCrochet * 0.008), 'quartIn')
                    if colorFadeNums == true then
                        doTweenColor('itsjustafad' .. eh .. i, 'num' .. spawn, baseColor, 0.2 + (stepCrochet * 0.005), 'quartIn')
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
    updateNotePos('player', direction)
    
    makeLuaSprite('looser' .. eh, missType, notePositions[direction].noteX - 10, notePositions[direction].noteY)
    setObjectCamera('looser' .. eh, 'hud')
    if pixel == true then
        setProperty('looser' .. eh .. '.antialiasing', false)
        scaleObject('looser' .. eh, ratingScale[1] + 0.1, ratingScale[2] + 0.1)
    else
        scaleObject('looser' .. eh, ratingScale[1] + 0.1, ratingScale[2] + 0.1)
    end
    setObjectOrder('looser' .. eh, getObjectOrder('strumLineNotes')-1)
    addLuaSprite('looser' .. eh, true)
    if stationaryMode == false then
        setProperty('looser' .. eh .. '.acceleration.y', 550)
        setProperty('looser' .. eh .. '.velocity.x', math.random(0,10))
        setProperty('looser' .. eh .. '.velocity.y', -200)
    end
    doTweenAlpha('nachotweenBru' .. eh, 'looser' .. eh, 0, 0.2 + (stepCrochet * 0.004), 'quartIn')
    if getProperty('looser'.. eh .. '.alpha') == 0 then
        removeLuaSprite('looser'.. eh, true)
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
                    fuoMis = table.insert(missCount, math.floor((blap / 1000) % 10))
                    if blap >= 9999 then
                        missMAX = true -- doesn't go above 1000, no need to, you don't suck THAT much
                    end
                end
            end
        end
        miSysmbol = table.insert(missCount, 'minus') -- always at the end for consistency 
    else
        missCount = {9, 9, 9, 9, 'minus'} 
    end

    if hideNums == false then
        numCount = 2
        if blap >= 10 then
            numCount = 3 
        end
        if blap >= 100 then
            numCount = 4 
        end
        if blap >= 1000 then
            numCount = 5 
        end

        if pixel then mPrefi = 'pixelUI/' else mPrefi = '' end
        
        sequence = nil
        for i = 1, numCount do
            multBy = (((i - 1) - numCount) * 25)

            if type(missCount[i]) ~= 'number' then
                sequence = mPrefi .. missCount[i] .. numSuffix
            else
                sequence = numPrefix .. missCount[i] .. numSuffix
            end

            if directNums then
                makeLuaSprite('fuke' .. eh .. i, sequence, (notePositions[direction].numX - multBy), notePositions[direction].numY)
            else
                makeLuaSprite('fuke' .. eh .. i, sequence, defaultPosNum[1] - multBy, defaultPosNum[2])
            end
            
            setObjectCamera('fuke' .. eh .. i, 'hud')
            setProperty('fuke'.. eh .. i .. '.color', getColorFromHex('bc0000'))
            setObjectOrder('fuke' .. eh .. i, getObjectOrder('strumLineNotes')-1)
            if pixel then
                setProperty('fuke' .. eh .. i .. '.antialiasing', false)
            end
            scaleObject('fuke' .. eh .. i, numScale[1], numScale[2])
            addLuaSprite('fuke' .. eh .. i, true)
            if not stationaryMode then
                if directNums then
                    setProperty('fuke'.. eh .. i ..'.velocity.x', math.random(-5, 5))
                    setProperty('fuke'.. eh .. i ..'.velocity.y', math.random(-140, -160))
                    setProperty('fuke' .. eh .. i .. '.acceleration.y', math.random(200, 400))
                end
            end
            doTweenAlpha('nachotweenMissNum' .. eh .. i, 'fuke' .. eh .. i, 0, 0.2 + (stepCrochet * 0.008), 'quartIn') 
        end
    end
end

function getRating(diff, noteType, char)
    if char == 'bf' then
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
end

function updateNotePos(noteGroup, direction) -- so a for loop isn't just mashed into functions
    if direction == nil then direction = 3 end
    for i = 0, direction do
        lolX = getPropertyFromGroup(noteGroup .. 'Strums', i, 'x')
        if directNums then 
            lulX = getPropertyFromGroup(noteGroup .. 'Strums', i, 'x') - 12 else
            lulX = getPropertyFromGroup(noteGroup .. 'Strums', 1, 'x') + 45 end
        if downscroll then
            if directNums then
                lolY = getPropertyFromGroup(noteGroup .. 'Strums', i, 'y') - 60                    
                lulY = getPropertyFromGroup(noteGroup .. 'Strums', i, 'y') - 10
            else
                lolY = getPropertyFromGroup(noteGroup .. 'Strums', i, 'y') - 35                    
            end
        else
            lolY = getPropertyFromGroup(noteGroup .. 'Strums', i, 'y') + 130 
            if directNums then
                lulY = getPropertyFromGroup(noteGroup .. 'Strums', i, 'y') + 180 
            end
        end

        if noteGroup == 'player' then
            notePositions[i] = {noteX = lolX, noteY = lolY, numX = lulX, numY = lulY} end
    end
end

local angleshit = 15;
local anglevar = 13;
function onBeatHit()
	if curBeat % 2 == 0 then
		angleshit = anglevar;
	else
		angleshit = -anglevar;
	end
	setGraphicSize('iconP1', angleshit*-10)
	setGraphicSize('iconP2', angleshit*10)
	setProperty('iconP1.angle',angleshit*-1.2)
	setProperty('iconP2.angle',angleshit*1.2)
	doTweenAngle('turn', 'iconP1', 0, stepCrochet*0.004, 'cubeOut')
	doTweenX('tuin', 'iconP1', -angleshit*8, crochet*0.001, 'linear')
	doTweenAngle('tt', 'iconP2', 0, stepCrochet*0.004, 'cubeOut')
	doTweenX('ttrn', 'iconP2', -angleshit*8, crochet*0.001, 'linear')
end

function onUpdatePost()

	setProperty("iconP1.scale.y", (getProperty("iconP1.scale.y") - 1) / -0.6 + 1)
	setProperty("iconP2.scale.y", (getProperty("iconP2.scale.y") - 1) / -0.6 + 1)
	setProperty("iconP1.y", 500 + (getProperty("iconP1.scale.y") * 75))
	setProperty("iconP2.y", 500 + (getProperty("iconP2.scale.y") * 75))
   
	if getPropertyFromClass('ClientPrefs', 'downScroll') == true then
	   setProperty("iconP1.y", -65 + (getProperty("iconP1.scale.y") * 75))
	   setProperty("iconP2.y", -65 + (getProperty("iconP2.scale.y") * 75))
	end
end