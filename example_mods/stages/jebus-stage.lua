function onCreate()
	-- background shit
	makeLuaSprite('stage', 'jebus-stage', -500, -300);
	addLuaSprite('stage', false);
	setLuaSpritesScrollFactor('stage', 0.5, 0.5);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end