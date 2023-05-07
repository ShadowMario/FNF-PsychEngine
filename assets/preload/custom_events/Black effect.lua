function onEvent(n,v1,v2)
	if n == 'Black effect' then
	   makeLuaSprite('flash', '', 0, 0);
        makeGraphic('flash',1280,720,'ffffff')
	      addLuaSprite('flash', true);

	setBlendMode('flash', 'SUBTRACT')
	setObjectCamera ('flash', 'other')
	      setProperty('flash.scale.x',1)
	      setProperty('flash.scale.y',1)
	      setProperty('flash.alpha',0)
		setProperty('flash.alpha',1)
		doTweenAlpha('flTw','flash',0,v1,'linear')
	end
end