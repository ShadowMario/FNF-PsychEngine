-- OPTIONS --
-- If you need help with the keys, you can go to https://api.haxeflixel.com/flixel/input/keyboard/FlxKeyList.html --
camKey = 'TAB' -- The key to toggle Freecam
camZoomKeys = {'Q', 'E'} -- The first key is zoom in and the second key is zoom out
camFastKey = 'SHIFT' -- The key to move the camera faster
camFreezeKey = 'F' -- The key to freeze the camera while in Freecam
camSpeed = 2.5 -- Speed to move the camera faster
camSpeedT = true -- Toggle to move the camera faster when pressing the specific key
camSpeedM = 4 -- Multiplicative speed for moving the camera faster
-------------

function onCreatePost()
	cam = false
	camFreeze = false
	camx = getProperty('camFollowPos.x')
	camy = getProperty('camFollowPos.y')
	camzoom = getPropertyFromClass('flixel.FlxG', 'camera.zoom')
	prevcamspeed = camSpeed;
	
	makeLuaText('menutitle', '-- FREECAM MODE --', 0, 4, 4)
	setTextSize('menutitle', 20)
	setTextAlignment('menutitle', 'left');
	setObjectCamera('menutitle', 'camOther')
	addLuaText('menutitle');
	
	makeLuaText('controls', 'Press arrow keys to move camera\nPress '..camZoomKeys[1]..' and '..camZoomKeys[2]..' to zoom in and out\nHold '..camFastKey..' to move faster\nPress '..camFreezeKey..' to freeze camera', 0, 4, 24)
	if camSpeedT == false then
		setTextString('controls', 'Press arrow keys to move camera\nPress '..camZoomKeys[1]..' and '..camZoomKeys[2]..' to zoom in and out\nPress '..camFreezeKey..' to unfreeze camera')
	end
	setTextSize('controls', 18)
	setTextAlignment('controls', 'left');
	setObjectCamera('controls', 'camOther')
	addLuaText('controls');
end

function onUpdatePost(elapsed)
	setProperty('menutitle.visible', cam)
	setProperty('controls.visible', cam)
	
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..camKey) then
		if cam == false then
			cam = true;
		elseif cam == true then
			cam = false;
		end
	end
	
	if camSpeedT == true then
		if getPropertyFromClass('flixel.FlxG', 'keys.pressed.'..camFastKey) then
			camSpeed = prevcamspeed*camSpeedM
		else
			camSpeed = prevcamspeed
		end
	end
	
	if cam == true then
		if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..camFreezeKey) then
			if camFreeze == false then
				camFreeze = true
			else
				camFreeze = false
			end
		end
	end
	
	if cam == true then
		if camFreeze == false then
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.LEFT') then
				camx = camx-camSpeed
			end
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.RIGHT') then
				camx = camx+camSpeed
			end
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.UP') then
				camy = camy-camSpeed
			end
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.DOWN') then
				camy = camy+camSpeed
			end
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.'..camZoomKeys[1]) then
				camzoom = camzoom+((camSpeed/150)*getProperty('camGame.zoom'))
			end
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.'..camZoomKeys[2]) then
				if getProperty('camGame.zoom') >= 0.001 then
					camzoom = camzoom-((camSpeed/150)*getProperty('camGame.zoom'))
				end
			end
		end
	end
	if cam == true or camFreeze == true then
		setProperty('camFollowPos.x', camx)
		setProperty('camFollowPos.y', camy)
		setProperty('camGame.zoom', camzoom)
	end
	
	-- text handler
	if camSpeedT == true then
		if camFreeze == false then
			setTextString('controls', 'Press arrow keys to move camera\nPress '..camZoomKeys[1]..' and '..camZoomKeys[2]..' to zoom in and out\nHold '..camFastKey..' to move faster\nPress '..camFreezeKey..' to freeze camera')
		else
			setTextString('controls', 'Press arrow keys to move camera\nPress '..camZoomKeys[1]..' and '..camZoomKeys[2]..' to zoom in and out\nHold '..camFastKey..' to move faster\nPress '..camFreezeKey..' to unfreeze camera')
		end
	else
		if camFreeze == false then
			setTextString('controls', 'Press arrow keys to move camera\nPress '..camZoomKeys[1]..' and '..camZoomKeys[2]..' to zoom in and out\nPress '..camFreezeKey..' to freeze camera')
		else
			setTextString('controls', 'Press arrow keys to move camera\nPress '..camZoomKeys[1]..' and '..camZoomKeys[2]..' to zoom in and out\nPress '..camFreezeKey..' to unfreeze camera')
		end
	end
end
