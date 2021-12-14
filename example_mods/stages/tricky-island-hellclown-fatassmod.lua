--Last Edited 10/12/21 by SaturnSpades
--Tricky mod credits will be put here temporarily until in-game credits can be modified within Lua
--Tricky Mod Developers: Banbuds, Rosebud, KadeDev, CVal, YingYang48, JADS, Moro
--Special Thanks: Tom Fulp, Krinkels, GWebDev, Tsuraran
function onCreate()
	--Create Background sprites
	makeLuaSprite('tricky-greenbg', 'tricky-greenbg', -1200, -650);
	luaSpriteMakeGraphic('tricky-greenbg', 4000, 2000, '274e13')
	setLuaSpriteScrollFactor('tricky-greenbg', 0.9);
	
	makeLuaSprite('tricky-island-hellclown-fatassmod', 'tricky-island-hellclown-fatassmod', -3400, -800);
	scaleLuaSprite('tricky-island-hellclown-fatassmod', 2, 2);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		--Low Quality mode not yet implemented
	end

	addLuaSprite('tricky-island-hellclown-fatassmod', false);
	addLuaSprite('tricky-island-hellclown-fatassmod', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end