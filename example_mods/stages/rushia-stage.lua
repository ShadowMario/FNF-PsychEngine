function onCreate()
	-- background shit

	makeLuaSprite('background', 'rushia-stage-background', -750, -1000);
	addLuaSprite('background', false);
	scaleObject('background', 1.2, 1.2);
	setLuaSpriteScrollFactor('background', 0.5, 0.5);

	makeLuaSprite('stage', 'rushia-stage-floor', -550, -720);
	scaleObject('stage', 1.1, 1.1);
	addLuaSprite('stage', false);

	makeLuaSprite('plants', 'rushia-stage-plants', -770, -720);
	scaleObject('plants', 1.1, 1.1);
	addLuaSprite('plants', false);
	setLuaSpriteScrollFactor('plants', 0.9, 0.9);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end