

local swayScreenP1 = false 

function setDefaultX(id)
	_G['defaultStrum'..id..'X'] = getActorX(id)
end

function setDefaultY(id)
	_G['defaultStrum'..id..'Y'] = getActorY(id)
end

function update (elapsed)
local currentBeat = (songPos / 1000)*(bpm/60)
    if swayScreenP1 then 
        for i = 0, 3 do 
            setActorX(_G['defaultStrum'..i..'X'] + 320 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'] - 48 * math.cos((currentBeat + i*8) * math.pi),i)
        end 
    end
end

function stepHit (step)
    if step == 1 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 0.001)
        end
    end
    if step == 16 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 0.42, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 0.42, 'setDefaultX')
        end
    end
    if step == 128 then 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.42)
        end
    end
    if step == 156 then 
        tweenPosXAngle(4, _G['defaultStrum4X'] - 320,getActorAngle(4) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(5, _G['defaultStrum5X'] - 260,getActorAngle(5) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(6, _G['defaultStrum6X'] + 260,getActorAngle(6) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(7, _G['defaultStrum7X'] + 320,getActorAngle(7) + 360, 0.42, 'setDefaultX')
        for i = 4, 7 do 
            tweenFadeOut(i, 1, 0.42)
        end
    end
    if step == 220 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] - 320,getActorAngle(0) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] - 260,getActorAngle(1) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] + 260,getActorAngle(2) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] + 320,getActorAngle(3) + 360, 0.42, 'setDefaultX')

        tweenPosXAngle(4, _G['defaultStrum4X'] + 320,getActorAngle(4) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(5, _G['defaultStrum5X'] + 260,getActorAngle(5) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(6, _G['defaultStrum6X'] - 260,getActorAngle(6) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(7, _G['defaultStrum7X'] - 320,getActorAngle(7) + 360, 0.42, 'setDefaultX')
    end
    if step == 256 or step == 288 or step == 320 or step == 352 or step == 384 or step == 416 or step == 448 or step == 480 or step == 512 then 
        setCamZoom(1)
    end
    if step == 284 or step == 412 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
    end
    if step == 316 or step == 380 or step == 444 or step == 508 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.42, 'setDefaultY')
        end
    end
    if step == 348 or step == 476 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 380 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] + 320,getActorAngle(0) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] + 260,getActorAngle(1) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] - 260,getActorAngle(2) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] - 320,getActorAngle(3) + 360, 0.42, 'setDefaultX')
        for i = 0, 3 do 
            tweenFadeIn(i, 0.3, 0.42)
        end
    end
    if step == 384 then 
        swayScreenP1 = true 
    end
    if step == 512 then 
        swayScreenP1 = false 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(4), 0.42, 'setDefaultX')
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.42, 'setDefaultY')
            tweenFadeOut(i, 1, 0.42)
        end
    end
    if step == 516 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 1.40)
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 12.82, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 12.82, 'setDefaultX')
        end
    end
    if step == 528 or step == 560 or step == 592 or step == 624 then 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 1.71)
        end
    end
    if step == 544 or step == 576 or step == 608 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 1.71)
        end
    end
-- this moving arrow shit 
    if step == 640 then 
        
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 1.3, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.3, i)
        end
    end
    if step == 652 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 654 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 656 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 658 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.85, i)
        end
    end
    if step == 666 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 668 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- on beat moving things
    if step == 672 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 673 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 674 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 675 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 677 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 678 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 679 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 680 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 682 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 683 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 684 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 685 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 687 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end

    if step == 688 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 689 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 690 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 691 then 
        
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 693 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 694 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 695 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 696 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 698 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 699 then 
        
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 700 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 701 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 703 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- moving arrow shit part 2
    if step == 704 then 
        
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 1.3, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.3, i)
        end
    end
    if step == 716 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 718 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 720 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 722 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.85, i)
        end
    end
    if step == 732 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 733 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 734 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 735 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
        end
    end
-- on beat moving things PART 2
    if step == 736 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 737 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 738 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 739 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 741 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 742 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 743 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 744 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 746 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 747 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 748 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 749 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 751 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end

    if step == 752 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 753 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 754 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 755 then 
        
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 757 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 758 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 759 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 760 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 762 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 763 then 
        
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 764 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 765 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 767 then
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- moving arrow shit part 3, there's a lot going on is there? 
    if step == 768 then 
        
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.3, i)
        end
    end
    if step == 780 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 782 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 784 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 786 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.85, i)
        end
    end
    if step == 794 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 796 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- on beat moving things PART 3
    if step == 800 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 801 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 802 then
        setCamZoom(1) 
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 803 then
        setCamZoom(1) 
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 805 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 806 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 807 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 808 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 810 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 811 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 812 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 813 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 815 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end

    if step == 816 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 817 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 818 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 819 then
        
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 821 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 822 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 823 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 824 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 826 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 827 then 
        
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 828 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 829 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 831 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 832 or step == 896 then 
        
    end
--end 
    if step == 894 then 
        for i = 4, 7 do 
            tweenFadeIn(i, 0, 3.5)
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 3.5, 'setDefaultX')
        end
    end
    if step == 952 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 0.85, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenFadeOut(i, 1, 0.85)
        end
    end
    if step == 1008 then 
        tweenFadeIn(0, 0, 0.05)
        tweenFadeIn(1, 0, 0.05)
        tweenFadeIn(3, 0, 0.05)
        tweenFadeIn(4, 0, 0.05)
        tweenFadeIn(6, 0, 0.05)
        tweenFadeIn(7, 0, 0.05)
    end
    if step == 1011 then 
        tweenFadeIn(2, 0, 0.05)
        tweenFadeIn(5, 0, 0.05)
        tweenFadeOut(1, 1, 0.05)
        tweenFadeOut(6, 1, 0.05)
    end
    if step == 1014 then 
        tweenFadeIn(1, 0, 0.05)
        tweenFadeIn(6, 0, 0.05)
        tweenFadeOut(3, 1, 0.05)
        tweenFadeOut(4, 1, 0.05)
    end
    if step == 1017 then 
        tweenFadeIn(3, 0, 0.001)
        tweenFadeIn(4, 0, 0.001)
    end
    if step == 1018 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 90, getActorAngle(i), 0.001, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 90, getActorAngle(i), 0.001, 'setDefaultX')
        end
    end
    if step == 1020 then 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 0.5)
        end
    end
-- diagonal arrows in chorus 
    if step == 1024 or step == 1056 or step == 1088 or step == 1120 or step == 1152 or step == 1184 or step == 1224 or step == 1248 then 
        
    end
    if step == 1280 or step == 1312 or step == 1344 or step == 1376 then 
        setCamZoom(2)
    end
    if step == 1052 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 50,getActorAngle(3), 0.42, i)
    end
    if step == 1084 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 1116 then
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 50,getActorAngle(3), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
    end
    if step == 1144 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 460, getActorAngle(i), 0.85, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 460, getActorAngle(i), 0.85, 'setDefaultX')
        end
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 50,getActorAngle(0), 0.85, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20,getActorAngle(1), 0.85, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 20,getActorAngle(2), 0.85, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 50,getActorAngle(3), 0.85, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.85, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.85, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.85, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.85, i)
    end
    if step == 1180 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
    end
    if step == 1216 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 50,getActorAngle(0), 0.85, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 20,getActorAngle(2), 0.85, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 20,getActorAngle(4), 0.85, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 50,getActorAngle(6), 0.85, i)

        tweenPosYAngle(1, _G['defaultStrum1Y'] + 50,getActorAngle(1), 0.85, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 20,getActorAngle(3), 0.85, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.85, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.85, i)
    end
    if step == 1224 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.001, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.001, i)
        end
    end
--end
-- on beat moving things for chorus part 4 
    if step == 1248 then 
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 20, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 20, getActorAngle(4), 0.10, i)
    end
    if step == 1249 then 
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 20, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20, getActorAngle(5), 0.10, i)
    end
    if step == 1250 then 
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 20, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20, getActorAngle(6), 0.10, i)
    end
    if step == 1251 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 20, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 20, getActorAngle(7), 0.10, i)
    end

    if step == 1252 then 
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 20, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 20, getActorAngle(4), 0.10, i)
    end
    if step == 1253 then 
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 20, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20, getActorAngle(5), 0.10, i)
    end
    if step == 1254 then 
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20, getActorAngle(6), 0.10, i)
    end
    if step == 1255 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 20, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 20, getActorAngle(7), 0.10, i)
    end

    if step == 1256 then 
        tweenPosXAngle(3, _G['defaultStrum3X'] + 20, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 20, getActorAngle(4), 0.10, i)
    end
    if step == 1257 then 
        tweenPosXAngle(2, _G['defaultStrum2X'] + 20, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 20, getActorAngle(5), 0.10, i)
    end
    if step == 1258 then 
        tweenPosXAngle(1, _G['defaultStrum1X'] + 20, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] - 20, getActorAngle(6), 0.10, i)
    end
    if step == 1259 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] + 20, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] - 20, getActorAngle(7), 0.10, i)
    end

    if step == 1260 then 
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 20, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 20, getActorAngle(4), 0.10, i)

        tweenPosXAngle(3, _G['defaultStrum3X'] - 20, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 20, getActorAngle(4), 0.10, i)
    end
    if step == 1261 then 
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 20, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20, getActorAngle(5), 0.10, i)

        tweenPosXAngle(2, _G['defaultStrum2X'] - 20, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 20, getActorAngle(5), 0.10, i)
    end
    if step == 1262 then 
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20, getActorAngle(6), 0.10, i)

        tweenPosXAngle(1, _G['defaultStrum1X'] + 20, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 20, getActorAngle(6), 0.10, i)
    end
    if step == 1263 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 20, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 20, getActorAngle(7), 0.10, i)

        tweenPosXAngle(0, _G['defaultStrum0X'] + 20, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 20, getActorAngle(7), 0.10, i)
    end

    if step == 1264 then 
        tweenPosYAngle(3, _G['defaultStrum3Y'], getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'], getActorAngle(4), 0.10, i)

        tweenPosXAngle(3, _G['defaultStrum3X'], getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'], getActorAngle(4), 0.10, i)
    end
    if step == 1265 then 
        tweenPosYAngle(2, _G['defaultStrum2Y'], getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'], getActorAngle(5), 0.10, i)

        tweenPosXAngle(2, _G['defaultStrum2X'], getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'], getActorAngle(5), 0.10, i)
    end
    if step == 1266 then 
        tweenPosYAngle(1, _G['defaultStrum1Y'], getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'], getActorAngle(6), 0.10, i)

        tweenPosXAngle(1, _G['defaultStrum1X'], getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'], getActorAngle(6), 0.10, i)
    end
    if step == 1267 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'], getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'], getActorAngle(7), 0.10, i)

        tweenPosXAngle(0, _G['defaultStrum0X'], getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'], getActorAngle(7), 0.10, i)
    end

    if step == 1268 then 
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 20, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 20, getActorAngle(4), 0.10, i)
    end
    if step == 1269 then 
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 20, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20, getActorAngle(5), 0.10, i)
    end
    if step == 1270 then 
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20, getActorAngle(6), 0.10, i)
    end
    if step == 1271 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 20, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 20, getActorAngle(7), 0.10, i)
    end

    if step == 1272 then 
        tweenPosXAngle(3, _G['defaultStrum3X'] + 20, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 20, getActorAngle(4), 0.10, i)
    end
    if step == 1273 then 
        tweenPosXAngle(2, _G['defaultStrum2X'] + 20, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 20, getActorAngle(5), 0.10, i)
    end
    if step == 1274 then 
        tweenPosXAngle(1, _G['defaultStrum1X'] + 20, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] - 20, getActorAngle(6), 0.10, i)
    end
    if step == 1275 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] + 20, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] - 20, getActorAngle(7), 0.10, i)
    end

    if step == 1276 then 
        tweenPosYAngle(3, _G['defaultStrum3Y'], getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'], getActorAngle(4), 0.10, i)

        tweenPosXAngle(3, _G['defaultStrum3X'], getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'], getActorAngle(4), 0.10, i)
    end
    if step == 1277 then 
        tweenPosYAngle(2, _G['defaultStrum2Y'], getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'], getActorAngle(5), 0.10, i)

        tweenPosXAngle(2, _G['defaultStrum2X'], getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'], getActorAngle(5), 0.10, i)
    end
    if step == 1278 then 
        tweenPosYAngle(1, _G['defaultStrum1Y'], getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'], getActorAngle(6), 0.10, i)

        tweenPosXAngle(1, _G['defaultStrum1X'], getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'], getActorAngle(6), 0.10, i)
    end
    if step == 1279 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'], getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'], getActorAngle(7), 0.10, i)

        tweenPosXAngle(0, _G['defaultStrum0X'], getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'], getActorAngle(7), 0.10, i)
    end
-- end 
-- diagonal arrows again 
    if step == 1280 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 50,getActorAngle(3), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 1312 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 50,getActorAngle(3), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
    end
    if step == 1328 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.42, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.42, i)
        end
    end
    if step == 1332 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 50,getActorAngle(3), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
    end
    if step == 1336 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 550, getActorAngle(i), 0.42, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 550, getActorAngle(i), 0.42, 'setDefaultX')
        end
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 50,getActorAngle(3), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 1340 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.42, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.42, i)
        end
    end
    if step == 1392 then 
        for i = 0, 3 do 
            tweenFadeIn(i, 0, 0.001)
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 1.2, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 1.2, 'setDefaultX')
        end
    end
-- end
-- beginning part again 
    if step == 1408 or step == 1440 or step == 1472 or step == 1504 or step == 1536 then 
        
    end
    if step == 1404 then 
        for i = 0, 3 do 
            tweenFadeOut(i, 1, 0.42)
        end
        tweenPosXAngle(0, _G['defaultStrum0X'] - 320,getActorAngle(0) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] - 260,getActorAngle(1) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] + 260,getActorAngle(2) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] + 320,getActorAngle(3) + 360, 0.42, 'setDefaultX')
    end
    if step == 1436 or step == 1500 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 50,getActorAngle(3), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 1468 then 
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 50,getActorAngle(0), 0.42, i)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 20,getActorAngle(1), 0.42, i)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 20,getActorAngle(2), 0.42, i)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 50,getActorAngle(3), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
    end
    if step == 1532 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.42, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.42, i)
        end
    end
    if step == 1535 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] + 320,getActorAngle(0) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] + 260,getActorAngle(1) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] - 260,getActorAngle(2) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] - 320,getActorAngle(3) + 360, 0.42, 'setDefaultX')
    end
    if step == 1540 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 12.82, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 12.82, 'setDefaultX')
        end
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 1.40)
        end
    end
    if step == 1552 or step == 1584 or step == 1616 or step == 1648 then 
        for i = 0, 7 do 
            tweenFadeOut(i, 1, 1.71)
        end
    end
    if step == 1568 or step == 1600 or step == 1632 then 
        for i = 0, 7 do 
            tweenFadeIn(i, 0, 1.71)
        end
    end
-- after the beginning part again askjda
    if step == 1664 then  
        
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 1.3, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.3, i)
        end
    end
    if step == 1676 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1678 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 1680 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1682 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.85, i)
        end
    end
    if step == 1690 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1692 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- part 4 of moving beat things arrow 
    if step == 1696 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1697 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1698 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 1699 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 1701 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1702 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1703 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1704 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1706 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 1707 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 1708 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1709 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1711 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end

    if step == 1712 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 1713 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 1714 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1715 then 
        
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1717 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1718 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1719 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1720 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1722 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1723 then 
        
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1724 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 1725 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 1727 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- moving arrows again part 5 i think 
    if step == 1728 then 
        
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 80, getActorAngle(i), 1.3, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.3, i)
        end
    end
    if step == 1740 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1742 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 1744 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1746 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.85, i)
        end
    end
    if step == 1754 then 
        for i = 0, 3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1756 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1757 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 1758 then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
        end
    end
-- moving arrows on beat uh.. part 6? no part 5
    if step == 1760 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 1761 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 1762 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 1763 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 1765 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1766 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1767 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1768 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1770 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1771 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1772 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1773 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1775 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end

    if step == 1776 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1777 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1778 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1779 then 
        
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1781 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1782 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1783 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1784 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1786 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 1787 then 
        
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 1788 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 1789 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 1791 then
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- ANOTHER ARROW MOVING SHIT! part 6
    if step == 1792 then 
        
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 80, getActorAngle(i), 1.3, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 80, getActorAngle(i), 1.3, i)
        end
    end
    if step == 1804 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1806 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 1808 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1810 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.85, i)
        end
    end
    if step == 1818 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.10, i)
        end
    end
    if step == 1820 then 
        for i = 0, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
-- on beat arrows.. again... part 6
    if step == 1824 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 1825 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1826 then
        setCamZoom(1) 
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 1827 then
        setCamZoom(1) 
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1829 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1830 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1831 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1832 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1834 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1835 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 1836 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 1837 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1839 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end

    if step == 1840 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] + 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1841 then 
        setCamZoom(1)
        tweenPosYAngle(2, _G['defaultStrum2Y'] - 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.10, i)
    end
    if step == 1842 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] + 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.10, i)
    end
    if step == 1843 then
        
        tweenPosYAngle(0, _G['defaultStrum0Y'] - 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1845 then 
        setCamZoom(1)
        tweenPosXAngle(3, _G['defaultStrum3X'] + 40, getActorAngle(3), 0.10, i)
        tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.10, i)
    end
    if step == 1846 then 
        setCamZoom(1)
        tweenPosXAngle(2, _G['defaultStrum2X'] + 40, getActorAngle(2), 0.10, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1847 then 
        setCamZoom(1)
        tweenPosXAngle(1, _G['defaultStrum1X'] - 40, getActorAngle(1), 0.10, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1848 then 
        
        tweenPosXAngle(0, _G['defaultStrum0X'] - 40, getActorAngle(0), 0.10, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.10, i)
    end

    if step == 1850 then 
        setCamZoom(1)
        tweenPosYAngle(3, _G['defaultStrum3Y'] - 40, getActorAngle(3), 0.10, i)
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 40, getActorAngle(4), 0.10, i)
    end
    if step == 1851 then 
        
        tweenPosYAngle(2, _G['defaultStrum2Y'] + 40, getActorAngle(2), 0.10, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 40, getActorAngle(5), 0.10, i)
    end
    if step == 1852 then 
        setCamZoom(1)
        tweenPosYAngle(1, _G['defaultStrum1Y'] - 40, getActorAngle(1), 0.10, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 40, getActorAngle(6), 0.10, i)
    end
    if step == 1853 then 
        setCamZoom(1)
        tweenPosYAngle(0, _G['defaultStrum0Y'] + 40, getActorAngle(0), 0.10, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 40, getActorAngle(7), 0.10, i)
    end

    if step == 1855 then 
        setCamZoom(1)
        for i = 0, 7 do
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.10, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.10, i)
        end
    end
    if step == 1856 or step == 1920 then 
        
    end
    if step == 1918 then 
        for i = 4, 7 do 
            tweenFadeIn(i, 0, 3.5)
        end
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 3.5, 'setDefaultX')
        end
    end
    if step == 1976 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 0.85, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenFadeOut(i, 1, 0.85)
        end
    end
    if step == 2032 then 
        tweenFadeIn(0, 0, 0.05)
        tweenFadeIn(2, 0, 0.05)
        tweenFadeIn(3, 0, 0.05)
        tweenFadeIn(4, 0, 0.05)
        tweenFadeIn(5, 0, 0.05)
        tweenFadeIn(7, 0, 0.05)
    end
    if step == 2034 then 
        tweenFadeIn(1, 0, 0.05)
        tweenFadeIn(6, 0, 0.05)
        tweenFadeOut(2, 1, 0.05)
        tweenFadeOut(5, 1, 0.05)
    end
    if step == 2038 then 
        tweenFadeIn(1, 0, 0.05)
        tweenFadeIn(6, 0, 0.05)
        tweenFadeOut(3, 1, 0.05)
        tweenFadeOut(4, 1, 0.05)
    end
    if step == 2040 then 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320, getActorAngle(i), 0.001, 'setDefaultX')
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320, getActorAngle(i), 0.001, 'setDefaultX')
        end
    end
    if step == 2044 then 
        for i = 0, 3 do 
            tweenFadeIn(i, 0.3, 0.42)
        end
        for i = 4, 7 do 
            tweenFadeIn(i, 1, 0.42)
        end
    end
    if step == 2048 then 
        
        swayScreenP1 = true 
    end
-- LAST CHORUS FINALLY
    if step == 2080 or step == 2112 or step == 2144 or step == 2192 or step == 2248 or step == 2272 or step == 2304 or step == 2336 or step == 2368 or step == 2400 then 
        
    end
    if step == 2176 then 
        setCamZoom(1)
    end
    if step == 2076 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)

        tweenPosXAngle(4, _G['defaultStrum4X'] - 50,getActorAngle(4), 0.42, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 15,getActorAngle(5), 0.42, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 15,getActorAngle(6), 0.42, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 2108 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 2140 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i), 0.42, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'],getActorAngle(i), 0.42, i)
        end
    end
    if step == 2160 then 
        swayScreenP1 = false 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i), 0.42, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'],getActorAngle(i), 0.42, i)
        end
    end
    if step == 2176 then 
        swayScreenP1 = true 
        for i = 0, 3 do 
            tweenFadeIn(i, 0, 0.001)
        end
    end
    if step == 2192 then 
        for i = 0, 3 do 
            tweenFadeOut(i, 0.5, 0.001)
        end
    end
    if step == 2204 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 320 ,getActorAngle(i), 0.42, i)
        end
    end
    if step == 2236 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'],getActorAngle(i), 0.42, i)
        end
    end
    if step == 2268 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 320 ,getActorAngle(i), 0.42, i)
        end
        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 2304 then 
        for i = 4, 7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'],getActorAngle(i), 0.42, i)
        end
    end
    if step == 2332 then 
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i), 0.42, i)
        end
    end
    if step == 2364 then 
        tweenPosXAngle(4, _G['defaultStrum4X'] - 50,getActorAngle(4), 0.42, i)
        tweenPosXAngle(5, _G['defaultStrum5X'] - 15,getActorAngle(5), 0.42, i)
        tweenPosXAngle(6, _G['defaultStrum6X'] + 15,getActorAngle(6), 0.42, i)
        tweenPosXAngle(7, _G['defaultStrum7X'] + 50,getActorAngle(7), 0.42, i)

        tweenPosYAngle(4, _G['defaultStrum4Y'] - 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] - 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] + 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] + 50,getActorAngle(7), 0.42, i)
    end
    if step == 2396 then 
        tweenPosYAngle(4, _G['defaultStrum4Y'] + 50,getActorAngle(4), 0.42, i)
        tweenPosYAngle(5, _G['defaultStrum5Y'] + 20,getActorAngle(5), 0.42, i)
        tweenPosYAngle(6, _G['defaultStrum6Y'] - 20,getActorAngle(6), 0.42, i)
        tweenPosYAngle(7, _G['defaultStrum7Y'] - 50,getActorAngle(7), 0.42, i)
    end
-- ALMOST THERE
    if step == 2432 or step == 2464 or step == 2496 or step == 2528 or step == 2560 then 
        
    end
    if step == 2416 then 
        swayScreenP1 = false 
        for i = 0, 3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(4), 1.2, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'],getActorAngle(4), 1.2, i)
            tweenFadeOut(i, 1, 1.2)
        end
        for i = 4, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i), 1.2, i)
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'],getActorAngle(i), 1.2, i)
        end
    end
    if step == 2428 then 
        tweenPosXAngle(0, _G['defaultStrum0X'] - 320,getActorAngle(0) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] - 260,getActorAngle(1) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] + 260,getActorAngle(2) + 360, 0.42, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] + 320,getActorAngle(3) + 360, 0.42, 'setDefaultX')
    end
--ending!!!!
    if step == 2688 then 
        setActorAccelerationY(100, 4)
        setActorAccelerationY(100, 5)
        setActorAccelerationY(100, 6)
        setActorAccelerationY(100, 7)

        setActorAccelerationX(-100, 4)
        setActorAccelerationX(-50, 5)
        setActorAccelerationX(50, 6)
        setActorAccelerationX(100, 7)

        tweenPosXAngle(0, _G['defaultStrum0X'] + 320,getActorAngle(0) + 360, 13.68, 'setDefaultX')
        tweenPosXAngle(1, _G['defaultStrum1X'] + 260,getActorAngle(1) + 360, 13.68, 'setDefaultX')
        tweenPosXAngle(2, _G['defaultStrum2X'] - 260,getActorAngle(2) + 360, 13.68, 'setDefaultX')
        tweenPosXAngle(3, _G['defaultStrum3X'] - 320,getActorAngle(3) + 360, 13.68, 'setDefaultX')
    end
    if step == 2842 then 
        setActorAccelerationY(100, 0)
        setActorAccelerationY(100, 1)
        setActorAccelerationY(100, 2)
        setActorAccelerationY(100, 3)

        setActorAccelerationX(-100, 0)
        setActorAccelerationX(-50, 1)
        setActorAccelerationX(50, 2)
        setActorAccelerationX(100, 3)
    end
end

--function keyPressed (key)
--    if curStep >= 672 and curStep < 704 then
--        if key == 'left' then 
--            for i = 0, 7 do 
--                tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 20, getActorAngle(i), 0.05, i)
--            end
--       end
--        if key == 'down' then 
--            for i = 0, 7 do 
--                tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 20, getActorAngle(i), 0.05, i)
--            end
--        end
--        if key == 'up' then 
--            for i = 0, 7 do 
--                tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 20, getActorAngle(i), 0.05, i)
--            end
--        end
--        if key == 'right' then 
--            for i = 0, 7 do 
--                tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 20, getActorAngle(i), 0.05, i)
--            end
--        end
--    end
--end