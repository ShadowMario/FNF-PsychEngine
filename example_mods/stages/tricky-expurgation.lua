--Last Edited 10/12/21 by SaturnSpades
--Tricky mod credits will be put here temporarily until in-game credits can be modified within Lua
--Tricky Mod Developers: Banbuds, Rosebud, KadeDev, CVal, YingYang48, JADS, Moro
--Special Thanks: Tom Fulp, Krinkels, GWebDev, Tsuraran
function onCreate()
	--Create Background sprites
	makeLuaSprite('tricky-redbg', 'tricky-redbg', -1200, -650);
	setLuaSpriteScrollFactor('tricky-redbg', 0.9);

	makeLuaSprite('tricky-expurgation-energywall', 'tricky-expurgation-energywall', 1200, -200);

	makeLuaSprite('tricky-expurgation-spawnhole-back', 'tricky-expurgation-spawnhole-back', 80, 820);

	makeLuaSprite('tricky-expurgation-spawnhole-cover', 'tricky-expurgation-spawnhole-cover', 30, 845);
	
	makeLuaSprite('tricky-expurgation-back', 'tricky-expurgation-back', -650, -200);

	makeLuaSprite('tricky-expurgation-backcover', 'tricky-expurgation-backcover', -93, 870);
	--setLuaSpriteScrollFactor('exback', 0.9, 0.9);
	--scaleLuaSprite('expurgationback', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		--Low Quality mode not yet implemented
	end

	addLuaSprite('tricky-redbg', false);
	addLuaSprite('tricky-expurgation-energywall', false);
	addLuaSprite('tricky-expurgation-back', false);
	addLuaSprite('tricky-expurgation-backcover', true);
	addLuaSprite('tricky-expurgation-spawnhole-back', false);
	addLuaSprite('tricky-expurgation-spawnhole-cover', true);
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end