function onCreate()
	-- If low quality is turned on.
	if lowQuality then
		makeLuaSprite('stage', 'sky-manifest-stage', -250, -100);
		addLuaSprite('stage', false);
		scaleObject('stage', 1.0, 1.0);
	end

	-- If low quality is turned off, then load animated sprites.
	if not lowQuality then
		makeAnimatedLuaSprite('stage-animated', 'sky-manifest-stage-animated', -250, -100);
		addAnimationByPrefix('stage-animated', 'first', 'Stage', 24, true);
		objectPlayAnimation('stage-animated', 'first');
		addLuaSprite('stage-animated', false);
		setLuaSpriteScrollFactor('stage-animated', 0.8, 0.8);
		scaleObject('stage-animated', 1.0, 1.0);
		
		makeAnimatedLuaSprite('stagefloor-animated', 'sky-manifest-stagefloor-animated', -500, -400);
		addAnimationByPrefix('stagefloor-animated', 'first', 'Stagefloor', 24, true);
		objectPlayAnimation('stagefloor-animated', 'first');
		addLuaSprite('stagefloor-animated', false);
		scaleObject('stagefloor-animated', 1.0, 1.0);
	end
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end