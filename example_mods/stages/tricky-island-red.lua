--Last Edited 10/12/21 by SaturnSpades
--Tricky mod credits will be put here temporarily until in-game credits can be modified within Lua
--Tricky Mod Developers: Banbuds, Rosebud, KadeDev, CVal, YingYang48, JADS, Moro
--Special Thanks: Tom Fulp, Krinkels, GWebDev, Tsuraran
function onCreate()
	--Create Background sprites
	makeLuaSprite('tricky-redbg2', '', -1200, -650);
	luaSpriteMakeGraphic('tricky-redbg2', 4000, 2000, '290c0c')
	setLuaSpriteScrollFactor('tricky-redbg2', 0.9);
	
	makeLuaSprite('tricky-island-red', 'tricky-island-red', -3400, -800);
	scaleLuaSprite('tricky-island-red', 2, 2);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		--Low Quality mode not yet implemented
	end

	addLuaSprite('tricky-redbg2', false);
	addLuaSprite('tricky-island-red', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end