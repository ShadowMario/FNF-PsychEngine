function onCreate()
	makeLuaSprite('stage1', 'mfm-stage-gospel', -1500, -1500);
	addLuaSprite('stage1', false);
	scaleObject('stage1', 2, 2);

	makeLuaSprite('stage2', 'mfm-stage-crescendo', -1500, -1500);
	addLuaSprite('stage2', false);
	scaleObject('stage2', 2, 2);

	setProperty('stage1.visible', true);
	setProperty('stage2.visible', false);
end

function onEvent(name,value1,value2)
	if name == 'Play Animation' then 
		
		if value1 == 'stage1' then
			setProperty('stage1.visible', true);
			setProperty('stage2.visible', false);
		end
		if value1 == 'stage2' then
			setProperty('stage1.visible', false);
			setProperty('stage2.visible', true);
		end
		if value1 == 'stage3' then
			setProperty('stage1.visible', false);
			setProperty('stage2.visible', false);
		end
	end
end