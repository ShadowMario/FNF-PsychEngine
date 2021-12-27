function onCreate()
	-- background shit
	makeLuaSprite('stage', 'sky-stage', -250, -100);
	addLuaSprite('stage', false);
	scaleObject('stage', 1.0, 1.0);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeAnimatedLuaSprite('stage-animated', 'sky-stage-animated', -250, -100);
		addAnimationByPrefix('stage-animated', 'first','Stage', 24, true);
		objectPlayAnimation('stage-animated', 'first');
		addLuaSprite('stage-animated', false);
		scaleObject('stage-animated', 1.0, 1.0);
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end