function onCreate()
	-- background shit
	makeLuaSprite('background', 'garcello-stage-background', -500, -300);
	addLuaSprite('background', false);
	scaleObject('background', 1.0, 1.0);
	
	makeLuaSprite('smoke', 'garcello-stage-smoke', -500, -300);
	addLuaSprite('smoke', false);
	scaleObject('smoke', 1.0, 1.0);

	makeLuaSprite('stage', 'garcello-stage', -500, -300);
	addLuaSprite('stage', false);
	scaleObject('stage', 1.0, 1.0);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end