function start (song)
	print("Song: " .. song .. " @ " .. bpm .. " downscroll: " .. downscroll)

end


function update (elapsed)
    local currentBeat = (songPos / 1000)*(bpm/84)
    if curStep >= 789 and curStep < 923 then
        for i=0,8 do
            setActorY(_G['defaultStrum'..i..'Y'] + 5 * math.sin((currentBeat + i*0.25) * math.pi), i)
        end
    end

    if curStep >= 924 and curStep < 1048 then
        for i=0,8 do
            setActorY(_G['defaultStrum'..i..'Y'] - 5 * math.sin((currentBeat + i*0.25) * math.pi), i)
        end
    end

    if curStep >= 1049 and curStep < 1176 then
        for i=0,8 do
            setActorX(_G['defaultStrum'..i..'X'] + 2 * math.sin((currentBeat + i*0.25) * math.pi), i)
        end
    end

    if curStep >= 1177 and curStep < 1959 then
        for i=0,8 do
            setActorX(_G['defaultStrum'..i..'X'] - 6 * math.sin((currentBeat + i*0.25) * math.pi), i)
        end
    end

    if curStep >= 760 and curStep < 786 then
        tweenCameraZoom(1.2, 0.5)
    end

    if curStep >= 1392 and curStep < 1428 then
        tweenCameraZoom(1.2, 0.5)
    end


end



function beatHit (beat)
   -- do nothing

end 

function stepHit (step)


end

function keyPressed (key)
   -- do nothing
end

print("Mod Chart script loaded :)")
