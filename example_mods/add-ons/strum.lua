function onCreate()
	--checks if middlescroll is activated
	if middlescroll then
		--makes the strum bar
		makeLuaSprite('Strum','Strum',258,-110);
		addLuaSprite('Strum',true);
		setScrollFactor('Strum',0,0);
		setObjectCamera('Strum','hud');
		setObjectOrder('Strum',1)
	end
end