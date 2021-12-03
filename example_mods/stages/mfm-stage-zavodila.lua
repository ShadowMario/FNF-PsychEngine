function onCreate()
	-- background shit
	makeLuaSprite('mfm-stage-zavodila', 'mfm-stage-zavodila', -500, -500);
	addLuaSprite('mfm-stage-zavodila',false);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end