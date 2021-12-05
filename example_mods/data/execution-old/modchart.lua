-- this gets called starts when the level loads.
function start(song)

end

-- this gets called every frame
function update(elapsed) 
    local currentBeat = (songPos / 1000)*(bpm/20)

    if curStep == 89 then
        for i =0,3 do
            --tweenAngle(i, _G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0.25) * math.pi), 0.4)
            --setActorAngle(getActorAngle(i) + 5, i)
            --setActorAccelerationX(25,i)
            --tweenAngle(i, 360, 0.4)
        end
    end

    if curStep == 123 then
        for i =4,7 do
            --setActorX(_G['defaultStrum'..i..'X'] + 6 * math.cos((currentBeat + i*0.25) * math.pi), i)
            --tweenAngle(i, _G['defaultStrum'..i..'Y'] + 100 * math.sin((currentBeat + i*0.25) * math.pi), 0.4)
            --setActorAngle(getActorAngle(i) + 5, i)
            --setActorAccelerationX(25,i)
            --tweenAngle(i, 360, 0.4)
        end
    end

    if curStep == 0 then
        tweenCameraZoomIn(1, 3)
    end

    if curStep == 94 then
        tweenCameraZoomOut(0.8, 0.4)
    end

    if curStep >= 123 and curStep < 155 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 187 and curStep < 219 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 251 and curStep < 283 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 315 and curStep < 347 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 540 and curStep < 604 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 667 and curStep < 731 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 795 and curStep < 859 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 923 and curStep < 987 then
        tweenCameraZoomIn(0.9, 0.4)
    end

    if curStep >= 1051 and curStep < 1083 then
        tweenCameraZoomIn(0.9, 0.4)
    end
end

-- this gets called every beat
function beatHit(beat) 

end

-- this gets called every step
function stepHit(step)

end
