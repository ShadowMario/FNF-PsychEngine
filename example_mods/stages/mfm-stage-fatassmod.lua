function onCreate()
	-- background shit
	makeLuaSprite('stage', 'mfm-stage-gospel', -1500, -1500);
	addLuaSprite('stage',false);
	scaleObject('stage', 2, 2);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end