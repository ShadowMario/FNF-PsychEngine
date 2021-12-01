function onCreate()
	-- background shit
	makeAnimatedLuaSprite('Stage', 'starecrown-stage-inversion', -500, -300);
	addAnimationByPrefix('Stage', 'first','Stage', 48, true);
	objectPlayAnimation('Stage', 'first');
	addLuaSprite('Stage', false);
	scaleObject('Stage', 1.2, 1.2);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end