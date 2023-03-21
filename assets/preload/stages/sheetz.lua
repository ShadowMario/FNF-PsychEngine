function onCreate()
	-- background shit
	makeLuaSprite('sheetz', 'sheetz', -1000, -500);
	scaleObject('sheetz', 1.5, 1.5);
	setScrollFactor('sheetz', 1.0, 1.0);

	addLuaSprite('sheetz', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end