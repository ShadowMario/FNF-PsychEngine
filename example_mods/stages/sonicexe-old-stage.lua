function onCreate()

   makeLuaSprite('background', 'sonicexe-old-stage-background', -400, -100);
   addLuaSprite('background', false);
   setLuaSpriteScrollFactor('background', 0.8, 0.8);

   makeLuaSprite('grass', 'sonicexe-old-stage-grass', -400, -125);
   addLuaSprite('grass', false);
   setLuaSpriteScrollFactor('grass', 0.9, 0.9);
   --scaleLuaSprite('grass', 1.1, 1.1);
   
   makeLuaSprite('floor', 'sonicexe-old-stage-floor', -400, -100);
   addLuaSprite('floor', false);
   --scaleLuaSprite('floor', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end