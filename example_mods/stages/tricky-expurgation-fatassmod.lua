
function onCreate()
	--Create Background sprites
	makeLuaSprite('background', 'tricky-greenbg', -1200, -650);
	setLuaSpriteScrollFactor('background', 0.9);

	makeLuaSprite('energywall', 'tricky-expurgation-energywall-fatassmod', 1200, -200);

	makeLuaSprite('spawnhole-back', 'tricky-expurgation-spawnhole-back', 80, 820);

	makeLuaSprite('spawnhole-cover', 'tricky-expurgation-spawnhole-cover-fatassmod', 30, 845);
	
	makeLuaSprite('stageback', 'tricky-expurgation-back-fatassmod', -650, -200);

	makeLuaSprite('stageback-cover', 'tricky-expurgation-backcover-fatassmod', -93, 870);
	--setLuaSpriteScrollFactor('exback', 0.9, 0.9);
	--scaleLuaSprite('expurgationback', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		--Low Quality mode not yet implemented
	end

	addLuaSprite('background', false);
	addLuaSprite('energywall', false);
	addLuaSprite('stageback', false);
	addLuaSprite('stageback-cover', true);
	addLuaSprite('spawnhole-back', false);
	addLuaSprite('spawnhole-cover', true);
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end