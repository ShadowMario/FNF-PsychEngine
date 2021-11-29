-- GHOST TIME 

-- 1.09secs per section 
-- 0.54secs per 1/2 section 
-- 0.27secs per 1/4 section

local glitch = false 
local glitchier = false 
local shifted = false 
local glitched = false 

local fading = false 
local faded = false 
local fadingFast = false 
local fadedFast = false 
local fadingFaster = false 
local fadedFaster = false 

local partySideways = false 
local partiedSideways = false 
local partyIDiagonal = false 
local partyODiagonal = false 
local partiedIDiagonal = false 
local partiedODiagonal = false 
local partyRoundLeft = false 
local partyRoundRight = false 
local partyWave = false 

local partySideways2 = false 
local partiedSideways2 = false 
local partyIDiagonal2 = false 
local partyODiagonal2 = false 
local partiedIDiagonal2 = false 
local partiedODiagonal2 = false 

local waitForBeatMove = false
local waitForBeatFade = false
local waitForStepMove = false 
local waitForStepFade = false 

function setDefaultX(id)
	_G['defaultStrum'..id..'X'] = getActorX(id)
    setActorAngle(0,id)
end

function setDefaultY(id)
	_G['defaultStrum'..id..'Y'] = getActorY(id)
    setActorAngle(0,id)
end

function partyDone()
    partied = false 
end

function update (elapsed)
local currentBeat = (songPos / 1000)*(bpm/60)
    if glitch then 
        if curBeat % 4 == 0 then 
            shifted = not shifted
            if shifted then 
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] + 40 * math.sin((currentBeat + i*0)), i)
                end
            else
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] - 40 * math.sin((currentBeat + i*0)), i)
                end
            end
        end
    end
    if glitchier then 
        if curBeat % 2 == 0 then 
            shifted = not shifted
            if shifted then 
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] + 40 * math.sin((currentBeat + i*0)), i)
                end
                glitched = not glitched
                if glitched then 
                    for i = 0, 7 do 
                        setActorY(_G['defaultStrum'..i..'Y'] + 10 * math.sin((currentBeat + i*0)), i)
                    end
                else 
                    for i = 0, 7 do 
                        setActorY(_G['defaultStrum'..i..'Y'] - 10 * math.sin((currentBeat + i*0)), i)
                    end
                end
            else
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] - 40 * math.sin((currentBeat + i*0)), i)
                end
            end
        end
    end
    if fading then 
        if curBeat % 16 == 0 and not waitForBeatFade then 
            waitForBeatFade = true
            faded = not faded 
            if faded then 
                for i = 0, 7 do 
                    tweenFadeIn(i, 0.1, 4.35)
                end
            else 
                for i = 0, 7 do 
                    tweenFadeOut(i, 1, 4.35)
                end
            end
        end
    end
    if fadingFast then 
        if curBeat % 1 == 0 and not waitForBeatFade then 
            waitForBeatFade = true
            fadedFast = not fadedFast 
            if fadedFast then 
                for i = 0, 7 do 
                    tweenFadeIn(i, 0.1, 0.25)
                end
            else 
                for i = 0, 7 do 
                    tweenFadeOut(i, 1, 0.25)
                end
            end
        end
    end
    if fadingFaster then 
        if curStep % 2 == 0 and not waitForStepFade then 
            waitForStepFade = true
            fadedFaster = not fadedFaster 
            if fadedFaster then 
                for i = 0, 7 do 
                    tweenFadeIn(i, 0.1, 0.05)
                end
            else 
                for i = 0, 7 do 
                    tweenFadeOut(i, 1, 0.05)
                end
            end
        end
    end
    if partySideways then 
        if curBeat % 1 == 0 and not waitForBeatMove then 
            waitForBeatMove = true
            partiedSideways = not partiedSideways
            if partiedSideways then 
                for i = 0, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                end
            else 
                for i = 0, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                end
            end
        end
    end
    if partyIDiagonal then 
        if curBeat % 1 == 0 and not waitForBeatMove then 
            waitForBeatMove = true
            partiedIDiagonal = not partiedIDiagonal
            if partiedIDiagonal then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
            end
        end
    end
    if partyODiagonal then 
        if curBeat % 1 == 0 and not waitForBeatMove then 
            waitForBeatMove = true
            partiedODiagonal = not partiedODiagonal
            if partiedODiagonal then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
            end
        end
    end
    if partySideways2 then 
        if curStep % 2 == 0 and not waitForStepMove then 
            waitForStepMove = true
            partiedSideways2 = not partiedSideways2
            if partiedSideways2 then 
                for i = 0, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.1, i)
                end
            else 
                for i = 0, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.1, i)
                end
            end
        end
    end
    if partyIDiagonal2 then 
        if curStep % 2 == 0 and not waitForStepMove then 
            waitForStepMove = true
            partiedIDiagonal2 = not partiedIDiagonal2
            if partiedIDiagonal2 then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
            end
        end
    end
    if partyODiagonal2 then 
        if curStep % 2 == 0 and not waitForStepMove then 
            waitForStepMove = true
            partiedODiagonal2 = not partiedODiagonal2
            if partiedODiagonal2 then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
            end
        end
    end
    if partyRoundLeft then 
        for i = 0, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 80 * math.sin((currentBeat + i*0) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*4) * math.pi),i)
        end 
    end
    if partyRoundRight then 
        for i = 0, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] + 80 * math.sin((currentBeat + i*0) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*4) * math.pi),i)
        end 
    end
    if partyWave then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*128) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*128) * math.pi),i)
        end 
    end
end


function beatHit (beat)
    waitForBeatMove = false
    waitForBeatFade = false 
end

function stepHit (step)
    waitForStepFade = false 
    waitForStepMove = false 
-- glitching beginning section
    if step == 1 then 
        fading = true 
    end
    if step == 128 then 
        glitch = true 
    end
    if step == 384 then 
        glitch = false 
        fading = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.27, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.27, 'setDefaultY')
            tweenFadeOut(i, 1, 0.01)
        end
    end
-- moving arrows for build up 
    if step == 640 or step == 648 or step == 656 or step == 664 or step == 672 or step == 680 or step == 688 or step == 696 or step == 704 or step == 712 or step == 720 or step == 728 or step == 736 or step == 744 or step == 752 or step == 760 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 20, getActorAngle(i), 0.27, 'setDefaultX')
        end
    end
    if step == 640 then 
        for i = 0, 3 do 
            tweenFadeIn(i, 0, 7.63)
        end
    end
    if step == 864 or step == 868 or step == 872 or step == 876 or step == 880 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 53.33, getActorAngle(i), 0.25, 'setDefaultX')
        end
    end
    if step == 884 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 53.34, getActorAngle(i), 0.25, 'setDefaultX')
        end
    end
    if step == 888 then 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.54)
        end
    end
-- the drop PARTY ARROWS
    if step == 908 then 
        partySideways = true 
    end
    if step == 956 then 
        partySideways = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
        end
    end
    if step == 972 then 
        fadingFast = true 
    end
    if step == 1024 then 
        fadingFast = false 
        for i = 0, 7 do 
            tweenFadeOut(i, 0.5, 0.01)
        end
    end
    if step == 1036 then 
        partyIDiagonal = true 
    end
    if step == 1084 then 
        partyIDiagonal = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
            tweenFadeOut(i, 1, 0.01)
        end
    end
    if step == 1096 or step == 1128 then 
        partyODiagonal = true 
    end
    if step == 1120 then 
        partyODiagonal = false 
    end
    if step == 1144 then 
        partyODiagonal = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.50, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.50, i)
        end
    end
-- PART TWO OF PARTY! 

    if step == 1292 then 
        partyRoundLeft = true 
    end
    if step == 1344 then 
        partyRoundLeft = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.50, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.50, i)
        end
    end
    if step == 1356 then 
        fadingFast = true 
    end
    if step == 1408 then 
        fadingFast = false 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.01)
        end
    end
    if step == 1420 then 
        partyRoundRight = true 
    end
    if step == 1472 then 
        partyRoundRight = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.50, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.50, i)
        end
    end
    if step == 1484 then 
        fadingFast = true 
    end
    if step == 1528 then 
        fadingFast = false 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.50)
        end
    end
-- Part 3 of PARTY! 
    if step == 1548 then 
        fadingFast = true 
        partyIDiagonal = true 
    end
    if step == 1600 then 
        partyIDiagonal = false 
        fadingFast = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.50, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.50, i)
            tweenFadeOut(i, 1, 0.01)
        end
    end
    if step == 1612 then
        fadingFast = true 
        partyODiagonal = true 
    end
    if step == 1664 then 
        partyODiagonal = false 
        fadingFast = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.50, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.50, i)
            tweenFadeOut(i, 1, 0.01)
        end
    end
    if step == 1676 then 
        partyRoundLeft = true 
        fadingFast = true 
    end
    if step == 1728 then 
        partyRoundLeft = false 
        fadingFast = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.50, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.50, i)
            tweenFadeOut(i, 1, 0.01)
        end
    end
    if step == 1740 then 
        partyRoundRight = true 
        fadingFast = true 
    end
    if step == 1784 then 
        partyRoundRight = false 
        fadingFast = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.001, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.001, i)
        end
        for i = 0, 3 do 
            tweenFadeIn(i, 0, 0.001)
        end
        for i = 4, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
-- END OF FIRST PARTY 
-- slow part
    if step == 1791 then 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 8.7)
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 0.001, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 0.001, 'setDefaultX')
        end
    end
    if step == 1792 then 
        tweenPosXAngle(4, _G['defaultStrum4X'] - 320,getActorAngle(4), 8.7, 'setDefaultX')
        tweenPosXAngle(5, _G['defaultStrum5X'] - 260,getActorAngle(5), 8.7, 'setDefaultX')
        tweenPosXAngle(6, _G['defaultStrum6X'] + 260,getActorAngle(6), 8.7, 'setDefaultX')
        tweenPosXAngle(7, _G['defaultStrum7X'] + 320,getActorAngle(7), 8.7, 'setDefaultX')
    end
    if step == 1920 then 
        tweenPosXAngle(4, _G['defaultStrum4X'] + 320,getActorAngle(4), 8.7, 'setDefaultX')
        tweenPosXAngle(5, _G['defaultStrum5X'] + 260,getActorAngle(5), 8.7, 'setDefaultX')
        tweenPosXAngle(6, _G['defaultStrum6X'] - 260,getActorAngle(6), 8.7, 'setDefaultX')
        tweenPosXAngle(7, _G['defaultStrum7X'] - 320,getActorAngle(7), 8.7, 'setDefaultX')

        tweenPosXAngle(0, _G['defaultStrum0X'] - 320,getActorAngle(0), 8.7, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] - 260,getActorAngle(1), 8.7, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] + 260,getActorAngle(2), 8.7, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] + 320,getActorAngle(3), 8.7, 'setDefaultX')
    end
-- blinking arrows for the slow part (this is many many many steps)
    --left arrow
    --if step == 2060 or step == 2072 or step == 2078 or step == 2092 or step == 2100 or step == 2110 or step == 2136 or step == 2142 or step == 2156 or step == 2164 or step == 2174 or step == 2188 or step == 2200 or step == 2206 or step == 2220 or step == 2228 or step == 2238 or step == 2252 or step == 2264 or step == 2270 then 
    --    tweenFadeOut(0, 1, 0.001)
    --end
    --if step == 2061 or step == 2073 or step == 2079 or step == 2093 or step == 2101 or step == 2111 or step == 2137 or step == 2143 or step == 2157 or step == 2165 or step == 2175 or step == 2189 or step == 2201 or step == 2207 or step == 2221 or step == 2229 or step == 2239 or step == 2253 or step == 2265 or step == 2271 then 
    --    tweenFadeIn(0, 0, 0.1)
    --end
    -- down arrow
    --if step == 2050 or step == 2056 or step == 2062 or step == 2068 or step == 2074 or step == 2082 or step == 2088 or step == 2094 or step == 2104 or step == 2108 or step == 2114 or step == 2120 or step == 2124 or step == 2132 or step == 2138 or step == 2146 or step == 2152 or step == 2158 or step == 2168 or step == 2172 or step == 2178 or step == 2184 or step == 2190 or step == 2196 or step == 2202 or step == 2210 or step == 2216 or step == 2222 or step == 2232 or step == 2236 or step == 2242 or step == 2248 or step == 2254 or step == 2260 or step == 2266 then 
    --    tweenFadeOut(1, 1, 0.001)
    --end
    --if step == 2051 or step == 2057 or step == 2063 or step == 2069 or step == 2075 or step == 2083 or step == 2089 or step == 2095 or step == 2105 or step == 2109 or step == 2115 or step == 2121 or step == 2125 or step == 2133 or step == 2139 or step == 2147 or step == 2153 or step == 2159 or step == 2169 or step == 2173 or step == 2179 or step == 2185 or step == 2191 or step == 2197 or step == 2203 or step == 2211 or step == 2217 or step == 2223 or step == 2233 or step == 2237 or step == 2243 or step == 2249 or step == 2255 or step == 2261 or step == 2267 then 
    --    tweenFadeIn(1, 0, 0.1)
    --end
    -- up arrow
    --if step == 2048 or step == 2054 or step == 2064 or step == 2070 or step == 2080 or step == 2086 or step == 2096 or step == 2102 or step == 2112 or step == 2118 or step == 2126 or step == 2128 or step == 2134 or step == 2144 or step == 2150 or step == 2160 or step == 2166 or step == 2176 or step == 2182 or step == 2192 or step == 2198 or step == 2208 or step == 2214 or step == 2224 or step == 2230 or step == 2240 or step == 2246 or step == 2256 or step == 2262 then 
    --    tweenFadeOut(2, 1, 0.001)
    --end
    --if step == 2049 or step == 2055 or step == 2065 or step == 2071 or step == 2081 or step == 2087 or step == 2097 or step == 2103 or step == 2113 or step == 2119 or step == 2127 or step == 2129 or step == 2135 or step == 2145 or step == 2151 or step == 2161 or step == 2167 or step == 2177 or step == 2183 or step == 2193 or step == 2199 or step == 2209 or step == 2215 or step == 2225 or step == 2231 or step == 2241 or step == 2247 or step == 2257 or step == 2263 then 
    --    tweenFadeIn(2, 0, 0.1)
    --end
    -- right arrow 
    --if step == 2052 or step == 2058 or step == 2066 or step == 2076 or step == 2084 or step == 2090 or step == 2098 or step == 2106 or step == 2116 or step == 2122 or step == 2130 or step == 2140 or step == 2148 or step == 2154 or step == 2162 or step == 2170 or step == 2180 or step == 2186 or step == 2194 or step == 2204 or step == 2212 or step == 2218 or step == 2226 or step == 2234 or step == 2244 or step == 2250 or step == 2258 or step == 2268 then 
    --    tweenFadeOut(3, 1, 0.001)
    --end
    --if step == 2053 or step == 2059 or step == 2067 or step == 2077 or step == 2085 or step == 2091 or step == 2099 or step == 2107 or step == 2117 or step == 2123 or step == 2131 or step == 2141 or step == 2149 or step == 2155 or step == 2163 or step == 2171 or step == 2181 or step == 2187 or step == 2195 or step == 2205 or step == 2213 or step == 2219 or step == 2227 or step == 2235 or step == 2245 or step == 2251 or step == 2259 or step == 2269 then 
    --    tweenFadeIn(3, 0, 0.1)
    --end
    --if step == 2272 then 
    --    for i = 0, 3 do 
    --        tweenFadeOut(i, 1, 2.15)
    --    end
    --end
-- end of the blinking arrows
    if step == 2304 then 
        glitchier = true 
        fading = true 
    end
    if step == 2552 then
        glitchier = false 
        fading = false 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
        end
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
        tweenPosXAngle(0, _G['defaultStrum0X'] + 320,getActorAngle(0), 0.20, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] + 260,getActorAngle(1), 0.20, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] - 260,getActorAngle(2), 0.20, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] - 320,getActorAngle(3), 0.20, 'setDefaultX')
    end
    if step == 2556 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 0.20, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 0.20, 'setDefaultX')
        end
    end
-- CHORUS WITH ALL THE LNS
    if step == 2816 then 
        partySideways = true 
        fadingFaster = true 
    end
    if step == 3068 then 
        partySideways = false
        fadingFaster = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 3072 or step == 3200 then 
        partyWave = true 
    end
    if step == 3164 or step == 3292 then 
        partyWave = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
        end
    end
-- the part with the triple long notes
    if step == 3329 or step == 3335 or step == 3341 or step == 3347 or step == 3353 or step == 3357 or step == 3361 or step == 3367 or step == 3373 or step == 3379 or step == 3385 or step == 3393 or step == 3399 or step == 3405 or step == 3411 or step == 3417 or step == 3421 or step == 3425 or step == 3431 or step == 3437 or step == 3443 or step == 3457 or step == 3463 or step == 3469 or step == 3475 or step == 3481 or step == 3485 or step == 3489 or step == 3495 or step == 3501 or step == 3507 or step == 3521 or step == 3527 or step == 3533 or step == 3539 or step == 3545 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0.1, 0.20)
        end
    end
    if step == 3334 or step == 3340 or step == 3346 or step == 3352 or step == 3356 or step == 3360 or step == 3366 or step == 3372 or step == 3378 or step == 3384 or step == 3392 or step == 3398 or step == 3404 or step == 3410 or step == 3416 or step == 3420 or step == 3424 or step == 3430 or step == 3436 or step == 3442 or step == 3448 or step == 3462 or step == 3468 or step == 3474 or step == 3480 or step == 3484 or step == 3488 or step == 3494 or step == 3500 or step == 3506 or step == 3512 or step == 3526 or step == 3532 or step == 3538 or step == 3544 or step == 3548 or step == 3550 then 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
-- chorus again! 
    if step == 3596 then 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
        partySideways2 = true 
    end
    if step == 3644 then 
        partySideways2 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
        end
    end
    if step == 3660 then 
        fadingFaster = true 
    end
    if step == 3712 then 
        fadingFaster = false 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 3724 then 
        partyIDiagonal2 = true 
    end
    if step == 3772 then 
        partyIDiagonal2 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
        end
    end
    if step == 3784 or step == 3816 then 
        partyODiagonal2 = true 
    end
    if step == 3808 then 
        partyODiagonal2 = false 
    end
    if step == 3832 then 
        partyODiagonal2 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.50, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.50, i)
        end
    end
    if step == 3852 then 
        partyIDiagonal2 = true 
        fadingFaster = true 
    end
    if step == 3904 then 
        partyIDiagonal2 = false 
        fadingFaster = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 3916 then 
        partyODiagonal2 = true 
        fadingFaster = true 
    end
    if step == 3968 then 
        partyODiagonal2 = false 
        fadingFaster = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 4096 or step == 4224 then 
        partySideways2 = true 
        fadingFaster = true 
    end
    if step == 4212 then 
        partySideways2 = false
        fadingFaster = false 
    end
    if step == 4348 then 
        partySideways2 = false
        fadingFaster = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.20, i)
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 4608 then 
        for i = 0, 7 do
            tweenFadeIn(i, 0, 17.44)
        end
    end
end