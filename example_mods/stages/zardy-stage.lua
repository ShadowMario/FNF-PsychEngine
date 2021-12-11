function onCreate()
	-- background shit
	makeLuaSprite('maze', 'zardy-stage', -500, -500);
	addLuaSprite('maze', false);
	scaleObject('maze', 1.0, 1.0);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeAnimatedLuaSprite('maze-animated', 'zardy-stage-animated', -500, -500);
		addAnimationByPrefix('maze-animated', 'first','Stage', 24, true);
		objectPlayAnimation('maze-animated', 'first');
		addLuaSprite('maze-animated', false);
		scaleObject('maze-animated', 1.0, 1.0);
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end