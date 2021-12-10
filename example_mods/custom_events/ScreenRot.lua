function onEvent(name, value1, value2)
	if name == "ScreenRot" then
		if value2 == nil then
			value2 = 0.005
		end
		
		doTweenAngle('turn', 'camGame', value1, value2, 'circOut')
		doTweenAngle('turn2', 'camHUD', value1, value2, 'circOut')	
	end
end