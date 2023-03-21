function onCreate()
	-- background shit
	makeLuaSprite('jackground', 'jackground', -1000, -500);
	scaleObject('jackground', 1.5, 1.5);
	setScrollFactor('jackground', 1.0, 1.0);

	addLuaSprite('jackground', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end