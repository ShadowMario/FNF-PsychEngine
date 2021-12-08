function onCreate()
	-- background shit
	makeLuaSprite('camellia-stageback', 'camellia-stageback', 0, 0);
	setLuaSpriteScrollFactor('camellia-stageback', 1.0, 1.0);
	
	makeLuaSprite('camellia-stagefront', 'camellia-stagefront', 0, 0);
	setLuaSpriteScrollFactor('camellia-stagefront', 1.0, 1.0);

	addLuaSprite('camellia-stagefront', 'false');
	addLuaSprite('camellia-stageback', 'false');
	
	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end