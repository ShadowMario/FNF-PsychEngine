local shakeAmount = 0

local defaultNotePos = {}

function onSongStart()
	for i = 0,7 do 
        x = getPropertyFromGroup('strumLineNotes', i, 'x')
        y = getPropertyFromGroup('strumLineNotes', i, 'y')
        table.insert(defaultNotePos, {x,y})
		--remember first in array is 1: x = 1, y = 2
    end
end

for i=4,7 do
	setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + math.random(-shakeAmount, shakeAmount))
	setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + math.random(-shakeAmount, shakeAmount))
end

function onEvent(name, value1, value2)
	if name == "Shakey Strums" then
		shakeAmount = tonumber(value1)
	end	
end