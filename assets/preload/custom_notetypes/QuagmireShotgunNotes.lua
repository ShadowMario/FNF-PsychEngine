function onCreate()

    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'QuagmireShotgunNotes' then --Check if the note on the chart is a Bullet Note
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'QuagmireShotgunNotes'); --Change texture
            setPropertyFromGroup('unspawnNotes', i, 'noteSplashHue', 0);
            setPropertyFromGroup('unspawnNotes', i, 'noteSplashSat', -20);
            setPropertyFromGroup('unspawnNotes', i, 'noteSplashBrt', 1);

            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
            end
        end
    end
end

local singAnims = {"singLEFT", "singDOWN", "singUP", "singRIGHT"}
local singAnims2 = {"quagmire left0", "quagmire down0", "quagmire up0", "quagmire right0"}
function opponentNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'QuagmireShotgunNotes' then
        --characterPlayAnim('bf', singAnims[direction + 1], true);
        --characterPlayAnim('dad', 'idle', false);
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'QuagmireShotgunNotes' then
        health = getProperty('health')
        setProperty('health', health+ 0.036);
    end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if noteType == 'QuagmireShotgunNotes' then
        setProperty('health', -0.11036);
        --addMisses(+1);
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    -- A loop from a timer you called has been completed, value "tag" is it's tag
    -- loops = how many loops it will have done when it ends completely
    -- loopsLeft = how many are remaining
    if loopsLeft >= 1 then
        setProperty('health', getProperty('health')-111.111);
    end
end