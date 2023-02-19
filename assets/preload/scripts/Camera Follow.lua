xx = nil --540
yy = nil --550
xx2 = nil --820
yy2 = nil --550
xx3 = nil --670
yy3 = nil --450
ofsX = 30
ofsY = 30
camFollowEventTriggered = false
locked = false
followchars = false
sectionUpdate = false
disableFollowOnEvent = false
charOfs = {
    bf = {0, 0},
    dad = {0, 0},
    gf = {0, 0}
}
stageOfs = {
    bf = {0, 0},
    dad = {0, 0},
    gf = {0, 0}
}

local path = '' --put the path of the folder where you keep all your scripts. If you just put them in mods then leave it blank
local function setVars(script, vars, val)
    if script ~= nil then
        for i = 1, table.getn(vars) do
            setGlobalFromScript(path..script, vars[i], val[i])
        end
    elseif script == nil then
        for i = 1, table.getn(vars) do
            setProperty(vars[i], val[i])
        end
    end
end

--[[
    here's an example on how to use setVars:
    
        setVars('camFollow', {'xx', 'xx2'}, {100, 400})
    ______________________________________________________________________________________________________________________________________________________________________
        basically, the first argument, where "camFollow" is, that's where you would put the script you want to mess with and stuff
        the second one, has "{}" because it's something called a "table", basically, the strings in there are the global variables you want to change
        and lastly, the third one that's has {} is like the second argument, except for this one, you are putting in the new values for the global variables.
        this command works on any variable that's a global variable, so if it has "local" before it, then it won't work!
        REMEMBER! For this to work properly you have to put the variables and the values in the same order, so like if I want xx to be 50, you have to have them both
        in the same slot of the tables they are in otherwise the value will get assigned to something else
        also, make sure that the global variables and the value tables have the same amount of things in them, otherwise it'll probably crash lol
]]

function getCameraPos(char)
    bfJsonArray = getProperty('boyfriend.cameraPosition')
    dadJsonArray = getProperty('dad.cameraPosition')
    if getProperty('gf.curCharacter') ~= 'gf.curCharacter' then
        gfJsonArray = getProperty('gf.cameraPosition')
    end

    for i = 1, 2 do
        stageOfs.bf[i] = getProperty('boyfriendCameraOffset')[i]
        stageOfs.dad[i] = getProperty('opponentCameraOffset')[i]
        if getProperty('gf.curCharacter') ~= 'gf.curCharacter' then
            stageOfs.gf[i] = getProperty('girlfriendCameraOffset')[i]
        end
    end
    
    if char == 'bf' or char == 'BF' or char == '0' then
        for i = 1, 2 do
            charOfs.bf[i] = bfJsonArray[i]
        end
    end

    if char == 'dad' or char == 'Dad' or char == '1' then
        for i = 1, 2 do
            charOfs.dad[i] = dadJsonArray[i]
        end
    end

    if char == 'gf' or char == 'GF' or char == '2' then
        for i = 1, 2 do    
            if getProperty('gf.curCharacter') ~= 'gf.curCharacter' then
                charOfs.gf[i] = gfJsonArray[i]
            end
        end
    end

    if char == 'all' or char == '' or char == nil then
        for i = 1, 2 do
            charOfs.bf[i] = bfJsonArray[i]
            charOfs.dad[i] = dadJsonArray[i]
            if getProperty('gf.curCharacter') ~= 'gf.curCharacter' then
                charOfs.gf[i] = gfJsonArray[i]
            end
        end
        
        
    end
    
    if not lowQuality then
        callOnLuas('onCameraPosGet')
    end
    
    
    if char == 'all' or char == '' or char == nil then
        setCameraPos('all')
    elseif char == 'bf' or char == 'BF' or char == '0' then
        setCameraPos('BF')
    elseif char == 'dad' or char == 'Dad' or char == '1' then
        setCameraPos('Dad')
    elseif char == 'gf' or char == 'GF' or char == '2' then
        if getProperty('gf.curCharacter') ~= 'gf.curCharacter' then
            setCameraPos('GF')
        end
    end
    
end

function setCameraPos(char)
    if char == 'all' or char == '' or char == nil then
        
        if split(getProperty('dad.curCharacter')) ~= 'gf' then
            xx = getMidpointX('dad') + 150 + charOfs.dad[1] - stageOfs.dad[1]
            yy = getMidpointY('dad') - 100 + charOfs.dad[2] + stageOfs.dad[2]
            
        else
            xx = getMidpointX('gf') + charOfs.gf[1] - stageOfs.gf[1]
            yy = getMidpointY('gf') + charOfs.gf[2] + stageOfs.gf[2]
        end

        xx2 = getMidpointX('boyfriend') - 100 - charOfs.bf[1] + stageOfs.bf[1]
        yy2 = getMidpointY('boyfriend') - 100 + charOfs.bf[2] + stageOfs.bf[2]

        xx3 = getMidpointX('gf') + charOfs.gf[1] + stageOfs.gf[1]
        yy3 = getMidpointY('gf') + charOfs.gf[2] + stageOfs.gf[2]
    end

    if char == 'bf' or char == 'BF' or char == '0' then
        xx2 = getMidpointX('boyfriend') - 100 - charOfs.bf[1] + stageOfs.bf[1]
        yy2 = getMidpointY('boyfriend') - 100 + charOfs.bf[2] + stageOfs.bf[2] 
    end

    if char == 'dad' or char == 'Dad' or char == '1' then
        xx = getMidpointX('dad') + 150 + charOfs.dad[1] - stageOfs.dad[1]
        yy = getMidpointY('dad') - 100 + charOfs.dad[2] + stageOfs.dad[2]
    end

    if char == 'gf' or char == 'GF' or char == '2' then
        if getProperty('gf.curCharacter') ~= 'gf.curCharacter' then
            xx3 = getMidpointX('gf')
            yy3 = getMidpointY('gf')
            xx3 = xx3 + charOfs.gf[1] - stageOfs.gf[1]
            yy3 = yy3 + charOfs.gf[2] + stageOfs.gf[2]
        end
    end

    
    
    if locked == false then
        if camFollowEventTriggered == false then
            followchars = true
        end
    end
    
    if not lowQuality then
        callOnLuas('onCameraPosSet')
    end
    
end

function onScriptAdd()
    getCameraPos('all')
end

function onStartCountdown()
    if getProperty('skipCountdown') == false then
        getCameraPos('all')
    end

    return Function_Continue
end

function onSongStart()
    if getProperty('skipCountdown') == true then
        getCameraPos('all')
    end
end

function onStepHit()
    if sectionUpdate then
        if curStep % 16 == 0 then
            if mustHitSection == false then
                getCameraPos('dad')
            elseif mustHitSection == true then
                getCameraPos('boyfriend')
            end
        end
    end
end

function onEvent(n, v1, v2)
    if n == 'Change Character' then
        if v1 == 'GF' or v1 == '2' then
            getCameraPos('GF')
        elseif v1 == 'BF' or v1 == '0' or v1 == 'bf' then
            getCameraPos('BF')
        elseif v1 == 'Dad' or v1 == '1' or v1 == 'dad' then
            getCameraPos('Dad')
        end
    end
    
    if n == 'Set Property' then
        if v1 == 'gf.x' or v1 == 'gf.y' then
            getCameraPos('GF')
        elseif v1 == 'boyfriend.x' or v1 == 'boyfriend.y' then
            getCameraPos('BF')
        elseif v1 == 'dad.x' or v1 == 'dad.y' then
            getCameraPos('Dad')
        end
    end
    
    if n == 'Camera Follow Pos' then
        if v1 ~= '' and v2 ~= '' then
            followchars = false
        else        
            followchars = true
        end
    end

    if n == '' then
        if v1 == 'xx' then
            xx = v2
        elseif v1 == 'yy' then
            yy = v2
        elseif v1 == 'xx+' then
            xx = xx + v2
        elseif v1 == 'yy+' then
            yy = yy + v2
        elseif v1 == 'xx2' then
            xx2 = v2
        elseif v1 == 'yy2' then
            yy2 = v2
        elseif v1 == 'xx2+' then
            xx2 = xx2 + v2
        elseif v1 == 'yy2+' then
            yy2 = yy2 + v2
        elseif v1 == 'xx3' then
            xx3 = v2
        elseif v1 == 'yy3' then
            yy3 = v2
        elseif v1 == 'xx3+' then
            xx3 = xx3 + v2
        elseif v1 == 'yy3+' then
            yy3 = yy3 + v2
        end
    end
end

function toggleLock(staionary)
    if staionary then
        locked = true
        followchars = false
        setProperty('isCameraOnForcedPos', false)
    elseif not staionary then
        locked = false
        followchars = true
        setProperty('isCameraOnForcedPos', true)
    end
end

whiteListedCharacters = '-_, '

function split(string)
    for word in string.gmatch(string, '([^'..whiteListedCharacters..']+)') do --Difficult yet neccessary motherfucker.
        return word
    end
end

--Modified version of Washo789's follow script.
--at least, I think it belongs to Washo789 (￣▽￣)"
function onUpdate(elasped)
    
    local curBFAnim = getProperty('boyfriend.animation.curAnim.name')
	local curGFAnim = getProperty('gf.animation.curAnim.name')
	local curDadAnim = getProperty('dad.animation.curAnim.name')
    
    if followchars == true then
        if camFollowEventTriggered == false then
            setProperty('isCameraOnForcedPos', true)
        end
        
        if mustHitSection == false and not gfSection then
            if curDadAnim == 'singLEFT'  or curDadAnim == 'singLEFT-alt'then
                setProperty('camFollow.x', xx - ofsX)
                setProperty('camFollow.y', yy)
                
            elseif curDadAnim == 'singDOWN' or curDadAnim == 'singDOWN-alt' then
                setProperty('camFollow.x', xx)
                setProperty('camFollow.y', yy + ofsY)
            
            elseif curDadAnim == 'singUP' or curDadAnim == 'singUP-alt' then
                setProperty('camFollow.x', xx)
                setProperty('camFollow.y', yy - ofsY)
            
            elseif curDadAnim == 'singRIGHT' or curDadAnim == 'singRIGHT-alt' then
                setProperty('camFollow.x', xx + ofsX)
                setProperty('camFollow.y', yy)
            
            else
                setProperty('camFollow.x', xx)
                setProperty('camFollow.y', yy)
            end
        
        elseif mustHitSection == true and not gfSection then

            if curBFAnim == 'singLEFT' or curBFAnim == 'singLEFT-alt' then
                setProperty('camFollow.x', xx2 - ofsX)
                setProperty('camFollow.y', yy2)
            
            elseif curBFAnim == 'singDOWN' or curBFAnim == 'singDOWN-alt' then
                setProperty('camFollow.x', xx2)
                setProperty('camFollow.y', yy2 + ofsY)
            
            elseif curBFAnim == 'singUP' or curBFAnim == 'singUP-alt' then
                setProperty('camFollow.x', xx2)
                setProperty('camFollow.y', yy2 - ofsY)
            
            elseif curBFAnim == 'singRIGHT' or curBFAnim == 'singRIGHT-alt' then
                setProperty('camFollow.x', xx2 + ofsX)
                setProperty('camFollow.y', yy2)
            else
                setProperty('camFollow.x', xx2)
                setProperty('camFollow.y', yy2)
            end
        end

        if gfSection == true then
    
            if curGFAnim == 'singLEFT' or curGFAnim == 'singLEFT-alt' then
                setProperty('camFollow.x', xx3 - ofsX)
                setProperty('camFollow.y', yy3)
            
            elseif curGFAnim == 'singDOWN' or curGFAnim == 'singDOWN-alt' then
                setProperty('camFollow.x', xx3)
                setProperty('camFollow.y', yy3 + ofsY)
            
            elseif curGFAnim == 'singUP' or curGFAnim == 'singUP-alt' then
                setProperty('camFollow.x', xx3)
                setProperty('camFollow.y', yy3 - ofsY)
            
            elseif curGFAnim == 'singRIGHT' or curGFAnim == 'singRIGHT-alt' then
                setProperty('camFollow.x', xx3 + ofsX)
                setProperty('camFollow.y', yy3)
            else
                setProperty('camFollow.x', xx3)
                setProperty('camFollow.y', yy3)
            end
        end
    end

    if getProperty('dad.curCharacter') == 'Character_That_Floats_and_Stuff' then
        if mustHitSection == false then
            toggleLock(true) --cameraSetTarget Shit works and it's not gonna follow movements
        elseif mustHitSection == true then
            toggleLock(false)
        end
    end

    if getProperty('boyfriend.curCharacter') == 'Character_That_Floats_and_Stuff_but_bf' then
        if mustHitSection == true then
            toggleLock(true)
        elseif mustHitSection == false then
            toggleLock(false)
        end
    end
end