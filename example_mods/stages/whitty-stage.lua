function onCreate()
	-- background shit
	makeLuaSprite('whitty-stageback', 'whitty-stageback', -600, -300);
	
	makeLuaSprite('whitty-stagefront', 'whitty-stagefront', -650, 600);
	scaleObject('whitty-stagefront', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		--Low Quality mode not yet implemented
	end

	addLuaSprite('whitty-stageback', false);
	addLuaSprite('whitty-stagefront', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end