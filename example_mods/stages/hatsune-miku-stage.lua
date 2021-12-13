function onCreate()
	-- background shit
	makeLuaSprite('stage', 'hatsune-miku-stage', 0, 0);
	addLuaSprite('stage', false);
	scaleObject('stage', 1.5, 1.5);
	
	makeAnimatedLuaSprite('crowd', 'hatsune-miku-crowd', 250, 1000);
	addAnimationByPrefix('crowd', 'first','Crowd', 24, true);
	objectPlayAnimation('crowd', 'first');
	addLuaSprite('crowd', true);
	scaleObject('crowd', 1.5, 1.5);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		--Low Quality mode not yet implemented
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end