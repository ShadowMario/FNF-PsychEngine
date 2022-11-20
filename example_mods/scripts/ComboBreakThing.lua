local ComboBreakBG = true

function onCreatePost()
	for i = 0, 3 do
		makeLuaSprite('thingToDisplay' .. i, '', getPropertyFromGroup('playerStrums', i, 'x'), 0)
		makeGraphic('thingToDisplay' .. i, getPropertyFromGroup('playerStrums', i, 'width'), screenHeight, 'ffffff')
		setProperty('thingToDisplay' .. i .. '.alpha', 0)
		setObjectCamera('thingToDisplay' .. i, 'hud')
		addLuaSprite('thingToDisplay' .. i, false)
	end
end

function ComboBreak(dir, rating)
	setProperty('thingToDisplay' .. dir .. '.alpha', 1)
	
	if rating == 'miss' then
		setProperty('thingToDisplay' .. dir .. '.color', 0xDD0A93)
	elseif rating == 'shit' then
		setProperty('thingToDisplay' .. dir .. '.color', 0x175DB3)
	end
	
	doTweenAlpha('thingToDisplayAlpha' .. dir, 'thingToDisplay' .. dir, 0, 1)
end

function noteMiss(id, direction, noteType, isSustainNote)
	if ComboBreakBG then
		ComboBreak(direction, 'miss')
	end
end

function noteMissPress(direction)
	if ComboBreakBG then
		ComboBreak(direction, 'shit')
	end
end
