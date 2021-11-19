-- 1.41secs per section
-- 0.70secs per section/2
-- 0.35secs per section/4

local swaySlowP1 = false 
local swaySlowP2 = false 
local swayScreenP1 = false
local swayScreenLargerP1 = false
local swaySlow = false 
local swayFastP2 = false 
local swayFast = false 
local swayIntense = false 
local swayIntense2 = false 
local swayIntense3 = false 
local swayIntense4 = false 
local cameraBeat = false 


function setDefault(id)
	_G['defaultStrum'..id..'X'] = getActorX(id)
end

function update (elapsed)
local currentBeat = (songPos / 1000)*(bpm/60)
    if swaySlowP1 then 
        for i = 0, 3 do 
            setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swaySlowP2 then 
        for i = 4, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swaySlow then 
        for i = 0, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swayFastP2 then 
        for i = 4, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] + 128 * math.sin((currentBeat + i*0)) + 16, i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swayFast then 
        for i = 0, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swayIntense then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] - 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] - 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] - 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayIntense2 then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayIntense3 then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 80 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 80 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayIntense4 then 
        for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] - 320 * math.sin((currentBeat + i*0)) + 320, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*8) * math.pi),i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 320 * math.sin((currentBeat + i*0)) - 320, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 32 * math.cos((currentBeat + i*8) * math.pi),i)
		end
    end
    if swayScreenP1 then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] - 320 * math.sin((currentBeat + i*0)) + 320, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 48 * math.cos((currentBeat + i*8) * math.pi),i)
        end 
    end
    if swayScreenLargerP1 then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] - 480 * math.sin((currentBeat + i*0)) + 320, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 64 * math.cos((currentBeat + i*8) * math.pi),i)
        end 
    end
end

function beatHit (beat)
    if cameraBeat then 
        setCamZoom(1)
    end
end

function stepHit (step)
    if step == 128 then 
        for i = 0, 1 do 
            tweenFadeIn(i, 0, 0.35)
        end
        tweenFadeIn(3, 0, 0.35)
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320,getActorAngle(0) + 360, 0.35, 'setDefault')
        end
        tweenFadeIn(2, 0, 5.64)
    end
    if step == 132 then 
        swaySlowP2 = true 
        swayScreenP1 = true 
    end
    if step == 208 then 
        swayScreenP1 = false
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.001, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.001, 'setDefault')
        end
    end
    if step == 248 then 
        swaySlowP2 = false
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320,getActorAngle(0) + 360, 0.70, 'setDefault')
        end
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.70)
        end
    end
    if step == 256 then 
        swaySlow = true 
    end
    if step == 384 then 
        swaySlow = false 
        for i = 0, 1 do 
            tweenFadeIn(i, 0, 0.35)
        end
        tweenFadeIn(3, 0, 0.35)
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320,getActorAngle(i) + 360, 0.35, 'setDefault')
        end
        tweenFadeIn(2, 0, 5.64)
    end
    if step == 388 then 
        swaySlowP2 = true 
        swayScreenP1 = true 
    end
    if step == 448 then 
        swaySlowP2 = false 
        swayScreenP1 = false  
        swayFastP2 = true 
        swayScreenLargerP1 = true 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 5.64)
        end
    end
    if step == 444 then 
        cameraBeat = true 
    end
    if step == 496 then 
        swayFastP2 = false  
        swayScreenLargerP1 = false 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320,getActorAngle(i) + 360, 0.35, 'setDefault')
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.35, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.35, 'setDefault')
        end
    end
    if step == 504 then 
        cameraBeat = false 
    end
    if step == 512 then 
        swayFast = true 
    end
    --flicker notes 
    if step == 571 then 
        tweenFadeIn(3, 0, 0.001)
    end
    if step == 572 then 
        tweenFadeIn(2, 0, 0.001)
        tweenFadeOut(3, 1, 0.001)
    end
    if step == 573 then 
        tweenFadeIn(1, 0, 0.001)
        tweenFadeOut(2, 1, 0.001)
    end
    if step == 574 then 
        tweenFadeIn(0, 0, 0.001)
        tweenFadeOut(1, 1, 0.001)
    end
    if step == 575 then 
        tweenFadeIn(1, 0, 0.001)
        tweenFadeOut(0, 1, 0.001)
    end
    if step == 576 then 
        tweenFadeOut(1, 1, 0.001)
    end
    --end flicker notes
    -- flicker part 2
    if step == 699 then 
        tweenFadeIn(3, 0, 0.001)
    end
    if step == 700 then 
        tweenFadeIn(2, 0, 0.001)
        tweenFadeOut(3, 1, 0.001)
    end
    if step == 701 then 
        tweenFadeIn(1, 0, 0.001)
        tweenFadeOut(2, 1, 0.001)
    end
    if step == 702 then 
        tweenFadeIn(0, 0, 0.001)
        tweenFadeOut(1, 1, 0.001)
    end
    if step == 703 then 
        tweenFadeIn(1, 0, 0.001)
        tweenFadeOut(0, 1, 0.001)
    end
    if step == 704 then 
        tweenFadeOut(1, 1, 0.001)
    end
    -- end flicker part 2 
    if step == 760 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640,getActorAngle(i) + 360, 0.70, 'setDefault')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640,getActorAngle(0) + 360, 0.70, 'setDefault')
        end
        swayFast = false 
    end
    if step == 768 then 
        swayIntense = true 
    end
    if step == 888 then 
        swayIntense = false
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640,getActorAngle(i) + 360, 0.70, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.70, 'setDefault')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640,getActorAngle(0) + 360, 0.70, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.70, 'setDefault')
        end
    end
    if step == 896 then 
        swayIntense2 = true 
    end
    if step == 1024 then 
        swayIntense2 = false
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320,getActorAngle(0), 0.35, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.35, 'setDefault')
            tweenFadeIn(i, 0, 0.35)
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320,getActorAngle(i), 0.35, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.35, 'setDefault')
        end
    end
    if step == 1028 then 
        tweenPosXAngle(4, _G['defaultStrum4X'] - 320,getActorAngle(4) + 360, 0.01, 'setDefault')
        tweenPosXAngle(5, _G['defaultStrum5X'] - 260,getActorAngle(5) + 360, 0.01, 'setDefault')
        tweenPosXAngle(6, _G['defaultStrum6X'] + 260,getActorAngle(6) + 360, 0.01, 'setDefault')
        tweenPosXAngle(7, _G['defaultStrum7X'] + 320,getActorAngle(7) + 360, 0.01, 'setDefault')
        swaySlowP1 = true 
    end
-- blinking notes for cam
    -- left arrow
    if step == 1065 or step == 1113 or step == 1177 or step == 1193 or step == 1231 or step == 1265 then 
        tweenFadeOut(4, 1, 0.35)
    end
    if step == 1074 or step == 1122 or step == 1186 or step == 1202 or step == 1240 or step == 1274 then 
        tweenFadeIn(4, 0, 0.35)
    end
    -- down arrow
    if step == 1049 or step == 1071 or step == 1103 or step == 1125 or step == 1145 or step == 1199 or step == 1272 then 
        tweenFadeOut(5, 1, 0.35)
    end
    if step == 1058 or step == 1080 or step == 1112 or step == 1134 or step == 1154 or step == 1208 then 
        tweenFadeIn(5, 0, 0.35)
    end
    -- up arrow
    if step == 1081 or step == 1141 or step == 1209 or step == 1253 then 
        tweenFadeOut(6, 1, 0.35)
    end
    if step == 1090 or step == 1150 or step == 1218 or step == 1262 then 
        tweenFadeIn(6, 0, 0.35)
    end
    -- right arrow
    if step == 1039 or step == 1097 or step == 1137 or step == 1167 or step == 1225 or step == 1241 or step == 1269 then 
        tweenFadeOut(7, 1, 0.35)
    end
    if step == 1048 or step == 1106 or step == 1146 or step == 1176 or step == 1234 or step == 1250 or step == 1278 then 
        tweenFadeIn(7, 0, 0.35)
    end
    if step == 1280 then 
        for i = 4, 7 do
            tweenFadeOut(i, 1, 5.64)
        end
        for i = 0, 3 do
            tweenFadeIn(i, 0, 5.64)
        end
        tweenPosXAngle(4, _G['defaultStrum4X'] + 320,getActorAngle(4), 5.64, 'setDefault')
        tweenPosXAngle(5, _G['defaultStrum5X'] + 260,getActorAngle(5), 5.64, 'setDefault')
        tweenPosXAngle(6, _G['defaultStrum6X'] - 260,getActorAngle(6), 5.64, 'setDefault')
        tweenPosXAngle(7, _G['defaultStrum7X'] - 320,getActorAngle(7), 5.64, 'setDefault')
    end
    if step == 1344 then 
        swaySlowP1 = false
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320,getActorAngle(i), 0.001, 'setDefault')
        end
    end
    if step == 1400 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320,getActorAngle(i) + 360, 0.70, 'setDefault')
        end
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.70)
        end
    end
    if step == 1536 then 
        for i = 0, 1 do 
            tweenFadeIn(i, 0, 0.35)
        end
        tweenFadeIn(3, 0, 0.35)
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320,getActorAngle(i) + 360, 0.35, 'setDefault')
        end
        tweenFadeIn(2, 0, 5.64)
    end
    if step == 1540 then 
        swaySlowP2 = true 
        swayScreenP1 = true 
    end
    if step == 1596 then 
        cameraBeat = true  
    end
    if step == 1600 then 
        swaySlowP2 = false 
        swayScreenP1 = false 
        swayFastP2 = true 
        swayScreenLargerP1 = true
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 4.23)
        end
    end
    if step == 1656 then 
        cameraBeat = false 
        swayFastP2 = false 
        swayScreenLargerP1 = false
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320,getActorAngle(i) + 360, 0.35, 'setDefault')
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.35, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.35, 'setDefault')
            tweenFadeIn(i, 0.3, 0.70)
        end
    end
--blinking arrows
    if step == 1664 or step == 1667 or step == 1670 or step == 1676 or step == 1679 or step == 1682 then 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 1665 or step == 1668 or step == 1677 or step == 1680 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0.3, 0.10)
        end
    end
    if step == 1671 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0.3, 0.35)
        end
    end
-- blinking arrows end
    if step == 1700 then 
        setCamZoom(1.5)
        swayIntense3 = true 
    end
    if step == 1788 then 
        swayIntense3 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.35, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.35, 'setDefault')
        end
    end
    if step == 1795 or step == 1798 or step == 1801 or step == 1804 or step == 1807 or step == 1810 then 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 1792 or step == 1796 or step == 1799 or step == 1802 or step == 1805 or step == 1808 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0.3, 0.10)
        end
    end
    if step == 1824 then 
        setCamZoom(1.5)
        swayIntense3 = true 
    end
    if step == 1912 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.70, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.70, 'setDefault')
        end
        swayIntense3 = false
    end
    if step == 1920 or step == 2056 then 
        swayIntense4 = true 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 2050 then 
        swayIntense4 = false 
        for i = 0, 3 do 
            tweenFadeIn(i, 0, 0.001)
        end
    end
    if step == 2176 then 
        swayIntense4 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 1.41, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 1.41, 'setDefault')
        end
    end
    if step == 2192 then 
        swayIntense2 = true 
    end

    if step == 2304 then 
        swayIntense2 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 1.41, 'setDefault')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 1.41, 'setDeault')
        end
    end
    if step == 2424 then 
        for i = 0, 2 do 
            tweenFadeIn(i, 0, 0.70)
        end
        for i = 4, 7 do 
            tweenFadeIn(i, 0, 0.70)
        end
    end
    if step == 2432 then 
        tweenFadeIn(3, 0, 2.82)
    end
end