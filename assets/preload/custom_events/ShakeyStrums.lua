local shakeAmount = 0

local defaultNotePos = {}

-- ALTER be like..
function onCreatePost()
	for i = 0,getProperty('opponentStrums.length') do 
        x = getPropertyFromGroup('opponentStrums', i, 'x')
        y = getPropertyFromGroup('opponentStrums', i, 'y')
        table.insert(defaultNotePos, {x,y})
		--remember first in array is 1: x = 1, y = 2
    end
end

function onUpdatePost()

	for i=0,getProperty('opponentStrums.length') do
		setPropertyFromGroup('opponentStrums', i, 'x', defaultNotePos[i + 1][1] + math.random(-shakeAmount, shakeAmount))
		setPropertyFromGroup('opponentStrums', i, 'y', defaultNotePos[i + 1][2] + math.random(-shakeAmount, shakeAmount))
	end	
end

function onEvent(name, value1, value2)
	if name == "Shakey Strums" then
		shakeAmount = tonumber(value1)
	end	
end
