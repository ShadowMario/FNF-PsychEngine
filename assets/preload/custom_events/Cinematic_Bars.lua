-- Event Working
startValue = 0

function onCreate()
	-- Bar Sprites
	makeLuaSprite('topBar', 'empty', 0, -120)
	makeGraphic('topBar', 1280, 120, '000000')
	setObjectCamera('topBar', 'hud')
	addLuaSprite('topBar', false)

	makeLuaSprite('bottomBar', 'empty', 0, 720)
	makeGraphic('bottomBar', 1280, 120, '000000')
	setObjectCamera('bottomBar', 'hud')
	addLuaSprite('bottomBar', false)
end

function onUpdate()
	-- START
	if startValue == 1 then
		doTweenY('TopBarStart', 'topBar', 0, 0.5, 'sineOut')
		doTweenY('BottomBarStart', 'bottomBar', 600, 0.5, 'sineOut')
	end

	if downscroll and startValue == 1 then
		doTweenY('TopBarStart', 'topBar', 0, 0.5, 'sineOut')
		doTweenY('BottomBarStart', 'bottomBar', 600, 0.5, 'sineOut')
	end

	-- END
	if startValue == 2 then
		doTweenY('TopBarEnd', 'topBar', -120, 0.5, 'sineOut')
		doTweenY('BottomBarEnd', 'bottomBar', 720, 0.5, 'sineOut')
	end

	if downscroll and startValue == 2 then
		doTweenY('TopBarEnd', 'topBar', -120, 0.5, 'sineOut')
		doTweenY('BottomBarEnd', 'bottomBar', 720, 0.5, 'sineOut')
	end
end

function onEvent(name, value1)
	-- Event Working
	if name == 'Cinematic_Bars' then
		startValue = tonumber(value1)
	end
end
