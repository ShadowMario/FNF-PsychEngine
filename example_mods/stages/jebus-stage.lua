function onCreate()
	-- background shit
	makeLuaSprite('jebus-stage', 'jebus-stage', -500, -300);
	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		--Low Quality mode not yet implemented
	end

	addLuaSprite('jebus-stage', false);
	setLuaSpritesScrollFactor('jebus-stage', 0.5, 0.5);
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end