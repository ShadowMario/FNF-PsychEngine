-- 1.71secs per section

local swaySlow = false 
local swayIntense = false 
local swayIntense2 = false 
local cameraBeat = false 

function start (song)
    print('Modchart Start')
end

function setDefaultX(id)
	_G['defaultStrum'..id..'X'] = getActorX(id)
end
function setDefaultY(id)
	_G['defaultStrum'..id..'Y'] = getActorY(id)
end

function update (elapsed)
local currentBeat = (songPos / 1000)*(bpm/60)
    if swaySlow then 
        for i = 0, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swayIntense then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayIntense2 then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 80 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] - 32 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 80 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] - 32 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
end

function beatHit (beat)
    if cameraBeat then 
        setCamZoom(1)
    end
end

function stepHit (step)
-- long note moving things P1
    if step == 64 then 
        for i = 0, 1 do 
            tweenFadeIn(i, 0, 1.71)
        end
        tweenFadeIn(3, 0, 1.71)
        for i = 0, 3 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.70, i)
        end
    end
    if step == 80 then 
        tweenFadeIn(2, 0, 1.71)
        tweenFadeOut(1, 1, 1.71)
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 1.70, i)
        end
    end
    if step == 96 then 
        tweenFadeIn(1, 0, 1.71)
        tweenFadeOut(3, 1, 1.71)
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.70, i)
        end
    end
    if step == 112 then 
        tweenFadeIn(3, 0, 0.85)
        tweenFadeOut(2, 1, 0.85)
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.85, 'setDefaultX')
        end
    end
    if step == 120 then 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.85)
        end
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.85, 'setDefaultY')
        end
    end
-- long notes moving things P1 end
-- long notes moving things P2
    if step == 128 then 
        for i = 6, 7 do 
            tweenFadeIn(i, 0, 1.71)
        end
        for i = 4, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 80, getActorAngle(i), 1.70, i)
        end
    end
    if step == 144 then 
        tweenFadeIn(4, 0, 1.71)
        tweenFadeOut(6, 1, 1.71)
        for i = 4, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 1.71, i)
        end
    end
    if step == 160 then 
        tweenFadeIn(5, 0, 1.71)
        tweenFadeOut(4, 1, 1.71)
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.70, i)
        end
    end
    if step == 176 then 
        tweenFadeIn(6, 0, 0.85)
        tweenFadeIn(4, 0, 0.85)
        tweenFadeOut(5, 1, 0.85)
        tweenFadeOut(7, 1, 0.85)
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.85, i)
        end
    end
    if step == 184 then 
        tweenFadeOut(4, 1, 0.85)
        tweenFadeOut(6, 1, 0.85)
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.85, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.85, 'setDefaultY')
        end
    end
-- long notes moving things P2 end
-- long notes moving things P1 part 2
    if step == 191 then 
        for i = 1, 3 do 
            tweenFadeIn(i, 0, 0.001)
        end
    end
    if step == 192 then 
        tweenFadeIn(0, 0, 1.71)
        tweenFadeOut(2, 1, 1.71)
        for i = 0, 3 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.70, i)
        end
    end
    if step == 208 then 
        tweenFadeIn(2, 0, 1.71)
        tweenFadeOut(1, 1, 1.71)
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 1.70, i)
        end
    end
    if step == 224 then 
        tweenFadeIn(1, 0, 1.71)
        tweenFadeOut(3, 1, 1.71)
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 1.70, i)
        end
    end
    if step == 240 then 
        tweenFadeIn(3, 0, 0.85)
        tweenFadeOut(2, 1, 0.85)
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.85, 'setDefaultX')
        end
    end
    if step == 248 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.85, 'setDefaultY')
            tweenFadeOut(i, 1, 0.85)
        end
    end
-- blinking for long note moving things P1 part 2
    -- left arrow 
    if step == 210 or step == 214 or step == 218 or step == 238 then 
        tweenFadeOut(0, 1, 0.001)
    end
    if step == 211 or step == 215 or step == 219 or step == 239 then 
        tweenFadeIn(0, 0, 0.30)
    end
    -- down arrow 
    if step == 206 or step == 242 or step == 246 then 
        tweenFadeOut(1, 1, 0.001)
    end
    if step == 207 or step == 243 or step == 247 then 
        tweenFadeIn(1, 0, 0.30)
    end
    -- up arrow 
    if step == 226 or step == 230 or step == 234 then 
        tweenFadeOut(2, 1, 0.001)
    end
    if step == 227 or step == 231 or step == 235 then 
        tweenFadeIn(2, 0, 0.30)
    end
    -- right arrow 
    if step == 194 or step == 198 or step == 202 or step == 222 then 
        tweenFadeOut(3, 1, 0.001)
    end
    if step == 195 or step == 199 or step == 203 or step == 223 then 
        tweenFadeIn(3, 0, 0.30)
    end
-- blinking for long note moving things P1 part 2 end
-- long notes moving things P1 part 2 end
    if step == 256 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 1.70, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenFadeIn(i, 0, 0.85)
        end
    end
    if step == 272 then 
        swaySlow = true 
    end
    if step == 312 then 
        swaySlow = false 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 0.85, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenFadeOut(i, 1, 0.85)
        end
    end
    if step == 320 then 
        swaySlow = true
    end
    if step == 358 then 
        swaySlow = false
        for i = 0, 3 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640, getActorAngle(i), 2.50, 'setDefaultX')
        end
        for i = 4, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640, getActorAngle(i), 2.50, 'setDefaultX')
        end
    end
    if step == 384 then 
        swaySlow = true
    end
    if step == 486 then 
        swaySlow = false 
        for i = 0, 3 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640, getActorAngle(i), 1.25, 'setDefaultX')
        end
        for i = 4, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640, getActorAngle(i), 1.25, 'setDefaultX')
        end
    end
-- MOAR MOVING ARROWS
    if step == 512 then 
        setCamZoom(1.5)
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 0.85, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.85, i)
        end
    end
    if step == 522 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.20, i)
        end
    end
    if step == 524 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 64, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 64, getActorAngle(i), 0.20, i)
        end
    end
    if step == 526 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.85, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.85, 'setDefaultY')
        end
    end
    if step == 544 then 
        setCamZoom(1.5)
        swayIntense = true 
    end
    if step == 560 or step == 563 or step == 566 or step == 598 or step == 599 then 
        setCamZoom(1)
    end
    if step == 572 then 
        swayIntense = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.40, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.40, 'setDefaultY')
        end
    end
--arrow moving again yeyy
    if step == 576 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 64, getActorAngle(i), 0.85, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 64, getActorAngle(i), 0.85, i)
        end
    end
    if step == 586 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.20, 'setDefaultX')
        end
    end
    if step == 588 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 590 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.85, 'setDefaultY')
        end
    end
    if step == 600 or step == 603 or step == 606 then
        setCamZoom(1.5)
    end
    if step == 608 then 
        setCamZoom(2)
        swayIntense = true 
    end
    if step == 636 then 
        swayIntense = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.42, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.42, 'setDefaultY')
        end
    end
    if step == 640 then 
        setCamZoom(1.5)
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 0.85, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.85, i)
        end
    end
    if step == 650 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.20, i)
        end
    end
    if step == 652 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 64, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 64, getActorAngle(i), 0.20, i)
        end
    end
    if step == 654 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.85, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.85, 'setDefaultY')
        end
    end
    if step == 672 or step == 696 or step == 699 then 
        setCamZoom(1)
        swayIntense2 = true 
    end
    if step == 680 then 
        setCamZoom(1.5)
    end
    if step == 688 or step == 691 or step == 694 then 
        setCamZoom(1)
    end
    if step == 700 then 
        swayIntense2 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.42, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.42, 'setDefaultY')
        end
    end
    if step == 701 or step == 702 then 
        setCamZoom(1)
    end
-- hehe more funny moving arrows funny
    if step == 704 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 64, getActorAngle(i), 0.85, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 64, getActorAngle(i), 0.85, i)
        end
    end
    if step == 714 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.20, 'setDefaultX')
        end
    end
    if step == 716 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 718 then 
         for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.60, 'setDefaultY')
        end
    end
    if step == 730 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 732 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 64, getActorAngle(i), 0.20, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 64, getActorAngle(i), 0.20, i)
        end
    end
    if step == 734 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 2.5, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 2.5, 'setDefaultY')
        end
    end
    if step == 768 then 
        setCamZoom(1.5)
    end
    if step == 752 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 0.85)
        end
    end
    if step == 762 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320,getActorAngle(i), 0.001, 'setDefaultX')
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320,getActorAngle(i), 0.001, 'setDefaultX')
        end
    end
    if step == 764 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] - 320,getActorAngle(0) + 360, 0.3, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] - 260,getActorAngle(1) + 360, 0.3, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] + 260,getActorAngle(2) + 360, 0.3, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] + 320,getActorAngle(3) + 360, 0.3, 'setDefaultX')
    end
    if step == 768 then 
        for i = 4, 7 do 
            tweenFadeOut(i, 1, 6.8)
        end
    end
-- blinking notes (again)
    -- left arrow 
    if step == 768 or step == 776 or step == 784 or step == 792 or step == 800 or step == 808 or step == 816 or step == 824 then 
        tweenFadeOut(0, 1, 0.001)
    end
    if step == 769 or step == 777 or step == 785 or step == 793 or step == 801 or step == 809 or step == 817 or step == 825 then 
        tweenFadeIn(0, 0, 0.15)
    end
    -- down arrow 
    if step == 772 or step == 780 or step == 788 or step == 796 or step == 804 or step == 812 or step == 820 or step == 828 then 
        tweenFadeOut(1, 1, 0.001)
    end
    if step == 773 or step == 781 or step == 789 or step == 797 or step == 805 or step == 813 or step == 821 or step == 829 then 
        tweenFadeIn(1, 0, 0.15)
    end
    -- up arrow 
    if step == 768 or step == 774 or step == 778 or step == 786 or step == 794 or step == 802 or step == 810 or step == 818 or step == 826 then 
        tweenFadeOut(2, 1, 0.001)
    end
    if step == 769 or step == 775 or step == 779 or step == 787 or step == 795 or step == 803 or step == 811 or step == 819 or step == 827 then 
        tweenFadeIn(2, 0, 0.15)
    end
    -- right arrow 
    if step == 770 or step == 782 or step == 790 or step == 798 or step == 806 or step == 814 or step == 822 or step == 830 then 
        tweenFadeOut(3, 1, 0.001)
    end
    if step == 771 or step == 783 or step == 791 or step == 799 or step == 807 or step == 815 or step == 823 then 
        tweenFadeIn(3, 0, 0.15)
    end
    if step == 832 then 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.42)
        end
    end
-- DONE BLINKING NOTES AGAIN LOL
    if step == 880 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] + 320,getActorAngle(0), 0.001, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] + 260,getActorAngle(1), 0.001, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] - 260,getActorAngle(2), 0.001, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] - 320,getActorAngle(3), 0.001, 'setDefaultX')
    end
    if step == 882 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320,getActorAngle(i), 0.001, 'setDefaultX')
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320,getActorAngle(i), 0.001, 'setDefaultX')
        end
    end
    if step == 883 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640,getActorAngle(i), 0.001, 'setDefaultX')
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640,getActorAngle(i), 0.001, 'setDefaultX')
        end  
    end
    if step == 884 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640,getActorAngle(i), 0.001, 'setDefaultX')
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640,getActorAngle(i), 0.001, 'setDefaultX')
        end  
    end 
    if step == 886 then 
        tweenFadeIn(0, 0, 0.001)
        tweenFadeIn(7, 0, 0.001)
    end
    if step == 887 then 
        tweenFadeIn(1, 0, 0.001)
        tweenFadeIn(6, 0, 0.001)
    end
    if step == 888 then 
        tweenFadeIn(2, 0, 0.001)
        tweenFadeIn(5, 0, 0.001)
    end
    if step == 889 then 
        tweenFadeIn(3, 0, 0.001)
        tweenFadeIn(4, 0, 0.001)
    end
    if step == 892 then 
        for i = 0, 7 do
            tweenFadeOut(i, 1, 0.42)
        end
    end
    if step == 896 then 
        setCamZoom(1.5)
    end
-- funny more moving arrows for the chorus COOLL!!!!!! 
    if step == 896 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80,getActorAngle(i), 0.85, i)
        end
    end
    if step == 920 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.30, 'setDefaultX')
        end
    end
    if step == 926 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 0.85, i)
        end
    end
    if step == 936 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80,getActorAngle(i), 0.85, i)
        end
    end 
    if step == 952 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.20, 'setDefaultY')
        end
    end
    if step == 955 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80,getActorAngle(i), 0.20, i)
        end
    end  
    if step == 958 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.20, 'setDefaultX')
        end
    end
    if step == 964 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 0.60, i)
        end
    end
    if step == 970 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 978 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 160, getActorAngle(i), 0.60, i)
        end
    end
    if step == 984 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.60, 'setDefaultY')
        end
    end
    if step == 990 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 0.85, i)
        end
    end
    if step == 1018 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 1021 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.20, 'setDefaultX')
        end
    end
    if step == 1032 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 0.60, i)
        end
    end
    if step == 1048 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.60, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.60, 'setDefaultY')
        end
    end
    if step == 1054 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 1060 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 80, getActorAngle(i), 0.20, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.20, 'setDefaultY')
        end
    end
    if step == 1080 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 1083 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.20, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.20, 'setDefaultY')
        end
    end
    if step == 1086 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 0.20, i)
        end
    end
    if step == 1088 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.85, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.85, 'setDefaultY')
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.42, i)
        end
    end
    if step == 1092 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.42, 'setDefaultY')
        end
    end
    if step == 1112 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 0.60, i)
        end
    end
    if step == 1118 then
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.82, 'setDefaultY')
        end
    end
    if step == 1136 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 1.71, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 1.71, 'setDefaultY')
        end
    end
-- END OF MORE MOVING ARROWS 
    if step == 1152 then 
        swayIntense = true 
        setCamZoom(1.5)
    end
    if step == 1216 or step == 1344 then 
        setCamZoom(1.5)
    end
    if step == 1276 then 
        swayIntense = false  
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.42, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.42, 'setDefaultY')
        end
    end
    if step == 1280 then 
        swayIntense2 = true 
        setCamZoom(1.5)
    end
    if step == 1344 then 
        swayIntense2 = false 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.42, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.42, 'setDefaultY')
            tweenFadeIn(i, 0, 1.60)
        end
    end
    if step == 1358 then 
        setCamZoom(1.5)
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 1358 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 1.60)
        end
    end
    if step == 1374 then 
        setCamZoom(1.5)
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 1375 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 3.4)
        end
    end
    if step == 1408 then 
        setCamZoom(1)
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.001)
        end
    end
    if step == 1504 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 3.4, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenFadeIn(i, 0, 3.4)
        end
    end
    if step == 1536 then 
        swaySlow = true 
    end
    if step == 1584 then 
        swaySlow = false 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 1.71, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenFadeOut(i, 1, 1.71)
        end
    end
    if step == 1600 then 
        swaySlow = true 
    end
    if step == 1664 or step == 1792 then 
        cameraBeat = true 
        setCamZoom(1.5)
    end
    if step == 1904 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 0.001)
        end
        cameraBeat = false 
    end
    if step == 1912 then 
        swaySlow = false 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 0.001, 'setDefaultX')
            tweenFadeOut(i, 1, 0.85)
        end
    end
    if step == 1920 or step == 1928 or step == 1931 or step == 1934 or step == 1937 or step == 1940 or step == 1947 or step == 1950 then 
        setCamZoom(1)
    end
    if step == 1944 or step == 1960 or step == 2024 or step == 2136 or step == 2160 or step == 2176 then 
        setCamZoom(1.2)
    end
    if step == 1984 or step == 2052 or step == 2060 or step == 2072 or step == 2080 or step == 2112 or step == 2116 or step == 2139 or step == 2142 or step == 2146 or step == 2148 then 
        setCamZoom(1)
    end
    if step == 2164 or step == 2168 or step == 2172 or step == 2173 then 
        setCamZoom(1)
    end
-- part 2 camera 
    if step == 2184 or step == 2192 or step == 2196 or step == 2197 or step == 2198 or step == 2199 or step == 2224 or step == 2226 or step == 2230 then 
        setCamZoom(1)
    end
    if step == 2200 or step == 2204 or step == 2216 or step == 2242 or step == 2248 or step == 2254 or step == 2260 or step == 2264 or step == 2267 then 
        setCamZoom(1.2)
    end
    if step == 2232 or step == 2234 or step == 2238 or step == 2246 or step == 2252 or step == 2262 or step == 2274 or step == 2276 then 
        setCamZoom(1)
    end
    if step == 2270 or step == 2280 or step == 2291 or step == 2296 or step == 2299 or step == 2302 or step == 2304 or step == 2320 then 
        setCamZoom(1.2)
    end
    if step == 2288 or step == 2289 or step == 2290 or step == 2294 or step == 2295 or step == 2308 or step == 2312 or step == 2328 or step == 2234 then 
        setCamZoom(1)
    end
    if step == 2239 or step == 2341 or step == 2344 or step == 2360 or step == 2363 or step == 2366 or step == 2372 or step == 2380 or step == 2395 or step == 2398 or step == 2401 or step == 2404 or step == 2408 then 
        setCamZoom(1.2)
    end
    if step == 2352 or step == 2355 or step == 2358 or step == 2376 or step == 2389 or step == 2392 or step == 2416 or step == 2432 then 
        setCamZoom(1)
    end
    if step == 2416 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 1.71, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 1.71, 'setDefaultY')
        end
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 1.71)
        end
    end
    if step == 2662 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 1.71)
        end
    end
end

function keyPressed (key)
    if curStep >= 1920 and curStep < 2176 then
        if key == 'left' then 
            for i = 4, 7 do 
                tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 20, getActorAngle(i), 0.05, i)
            end
        end
        if key == 'down' then 
            for i = 4, 7 do 
                tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 20, getActorAngle(i), 0.05, i)
            end
        end
        if key == 'up' then 
            for i = 4, 7 do 
                tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 20, getActorAngle(i), 0.05, i)
            end
        end
        if key == 'right' then 
            for i = 4, 7 do 
                tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 20, getActorAngle(i), 0.05, i)
            end
        end
    end
    if curStep >= 2176 and curStep < 2416 then
        if key == 'left' then 
            for i = 4, 7 do 
                tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.05, i)
            end
        end
        if key == 'down' then 
            for i = 4, 7 do 
                tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.05, i)
            end
        end
        if key == 'up' then 
            for i = 4, 7 do 
                tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.05, i)
            end
        end
        if key == 'right' then 
            for i = 4, 7 do 
                tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.05, i)
            end
        end
    end
end