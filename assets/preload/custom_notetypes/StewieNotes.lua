function onCreate()

    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'StewieNotes' then --Check if the note on the chart is a Bullet Note
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'StewieNotes'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true); -- make it so original character doesn't sing these notes
            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
            end
        end
    end
end

SGF = true
onetime = true
function goodNoteHit(id, direction, noteType, isSustainNote)
if noteType == 'StewieNotes' then
if songName == 'A-Family-Guy' then
if SGF == true then
if direction == 0 then
triggerEvent('Play Animation', 'singLEFT', 'gf')
elseif direction == 1 then
triggerEvent('Play Animation', 'singDOWN', 'gf')
elseif direction == 2 then
triggerEvent('Play Animation', 'singUP', 'gf')
elseif direction == 3 then
triggerEvent('Play Animation', 'singRIGHT', 'gf')
end
else
if direction == 0 then
triggerEvent('Play Animation', 'singLEFT', 'boyfriend')
elseif direction == 1 then
triggerEvent('Play Animation', 'singDOWN', 'boyfriend')
elseif direction == 2 then
triggerEvent('Play Animation', 'singUP', 'boyfriend')
elseif direction == 3 then
triggerEvent('Play Animation', 'singRIGHT', 'boyfriend')
end
end
elseif songName == 'Rooten-Family' then
if direction == 0 then
triggerEvent('Play Animation', 'singLEFT', 'boyfriend')
elseif direction == 1 then
triggerEvent('Play Animation', 'singDOWN', 'boyfriend')
elseif direction == 2 then
triggerEvent('Play Animation', 'singUP', 'boyfriend')
elseif direction == 3 then
triggerEvent('Play Animation', 'singRIGHT', 'boyfriend')
end

end
end
end

function onUpdatePost()
if songName == 'A-Family-Guy' then
if boyfriendName == 'stewie' and onetime == true then
SGF = false
onetime = false
end
end
end