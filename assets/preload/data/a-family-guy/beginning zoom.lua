

timer = 1.5
---when the timer for the cam return to normal state.

tim = 5
--this is the timer for how fast do you want the cam to get back to normal
function onCreate()
addCharacterToList('family', 'dad')
addCharacterToList('familydark', 'dad')
addCharacterToList('loisduo', 'gf')
addCharacterToList('megandchris', 'dad')
addCharacterToList('peterchrismeg', 'dad')
addCharacterToList('peterduo', 'dad')
addCharacterToList('stewie', 'boyfriend')
addLuaScript('custom_events/WBG')
addLuaScript('custom_events/Black effect')
end

function onCreatePost()

gforiginalX = getProperty('gf.x')
gforiginalY = getProperty('gf.y')
	   makeLuaSprite('did', '', 0, 0);
        makeGraphic('did',1280,720,'000000')
              setObjectCamera('did', 'other')
	      addLuaSprite('did', false);
doTweenColor('0', 'dad', '000000', 0.01, 'linear')
doTweenColor('00', 'boyfriend', '000000', 0.01, 'linear')
	makeLuaSprite('1Bar', nil, 0, -190)
	makeGraphic('1Bar', 1280, 180, '000000')
	setObjectCamera('1Bar', 'other')
	addLuaSprite('1Bar', false)

	makeLuaSprite('2Bar', nil, 0, 750)
	makeGraphic('2Bar', 1280, 180, '000000')
	setObjectCamera('2Bar', 'other')
	addLuaSprite('2Bar', false)
setProperty('camHUD.alpha', 0)
setProperty('bg1_Anm.alpha', 0.5)
setProperty('bg2_Anm.alpha', 0.5)
setProperty('bg3_Anm.alpha', 0.5)


end

function onSongStart()
	runTimer('get back', timer)
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'get back' then
		doTweenAlpha('dd','did', 0.8, tim,'linear')
		doTweenAlpha('dd2','camHUD', 0.2, tim,'linear')
doTweenZoom('cam', 'camGame',0.7, tim, 'quadInOut')
setProperty('cameraSpeed', 0.5)
elseif tag == 'gopeter' then
triggerEvent('Change Character', 'dad', 'peterduo')
end
end

cutscene = false
camspeed = 0.3
betn = false
function onUpdate()
setProperty('cameraSpeed', camspeed)
if cutscene == 1 then
setProperty('camFollow.x', 1400)
setProperty('camFollow.y', 650)
elseif cutscene == 2 then
setProperty('camFollow.x', 650)
setProperty('camFollow.y', 390)
elseif cutscene == 3 then
setProperty('camFollow.x', -100)
setProperty('camFollow.y', 500)
elseif cutscene == 4 then
setProperty('camFollow.x', 350)
setProperty('camFollow.y', 390)
end
end

follow = false

function onUpdatePost()

if follow == true then
cameraSetTarget('boyfriend')
end
end
cool_effect_NOW = false
function onStepHit()
if curStep == 32 then

doTweenY('i', '1Bar', 0, 4.5, 'linear')
doTweenY('i2', '2Bar', 520, 4.5, 'linear')

elseif curStep == 59 then
		doTweenAlpha('dd','did', 1, 0.5,'linear')
		doTweenAlpha('dd2','camHUD', 0, 0.5,'linear')
		doTweenAlpha('dd5','bg1_Anm', 0, 0.5,'linear')
		doTweenAlpha('dd6','bg2_Anm', 0, 0.5,'linear')
		doTweenAlpha('dd7','bg3_Anm', 0, 0.5,'linear')
doTweenZoom('cam', 'camGame', 1.5, 0.5, 'quadInOut')

elseif curStep == 64 then
removeLuaSprite('1Bar')
camspeed = 1
removeLuaSprite('2Bar')
doTweenZoom('cam', 'camGame', 0.93, 0.1, 'quadInOut')
setProperty('defaultCamZoom', 0.73)
		doTweenAlpha('dd3','did', 0, 0.1,'linear')
		doTweenAlpha('dd4','camHUD', 1, 0.1,'linear')
		doTweenAlpha('dd5','bg1_Anm', 1, 0.1,'linear')
		doTweenAlpha('dd6','bg2_Anm', 1, 0.1,'linear')
		doTweenAlpha('dd7','bg3_Anm', 1, 0.1,'linear')
setProperty('cameraSpeed', 1)
doTweenColor('0', 'dad', 'ffffff', 0.01, 'linear')
doTweenColor('00', 'boyfriend', 'ffffff', 0.01, 'linear')
cameraFlash('camOther', 'ffffff', 1, true)
elseif curStep == 192 then
cameraFlash('camOther', 'ffffff', 1, true)
elseif curStep == 304 then
doTweenZoom('cam', 'camGame',1.5, 2, 'linear')
doTweenZoom('camH', 'camHUD',1.1, 2, 'linear')
		doTweenAlpha('dd5','bg1_Anm', 0, 2,'linear')
		doTweenAlpha('dd6','bg2_Anm', 0, 2,'linear')
		doTweenAlpha('dd7','bg3_Anm', 0, 2,'linear')
elseif curStep == 384 or curStep == 448 or curStep == 512 then
camspeed = 100000000000000000000000000
elseif curStep == 321 or curStep == 385 or curStep == 449 or curStep == 513 then
camspeed = 1

elseif curStep == 320 then
camspeed = 100000000000000000000000000
doTweenZoom('cam', 'camGame',0.93, 0.1, 'linear')
setProperty('defaultCamZoom', 0.93)
doTweenZoom('camH', 'camHUD',1, 0.1, 'linear')
cameraFlash('camOther', 'ffffff', 1, true)

		doTweenAlpha('dd5','bg1_Anm', 1, 0.1,'linear')
		doTweenAlpha('dd6','bg2_Anm', 1, 0.1,'linear')
		doTweenAlpha('dd7','bg3_Anm', 1, 0.1,'linear')
elseif curStep == 336 then
doTweenZoom('cam', 'camGame',0.83, 0.1, 'linear')
setProperty('defaultCamZoom', 0.83)
elseif curStep == 352 then
doTweenZoom('cam', 'camGame',0.73, 0.1, 'linear')
setProperty('defaultCamZoom', 0.73)
elseif curStep == 368 then
doTweenZoom('cam', 'camGame',0.83, 0.1, 'linear')
setProperty('defaultCamZoom', 0.83)

doTweenZoom('cam', 'camGame',0.73, 0.1, 'linear')
setProperty('defaultCamZoom', 0.73)

elseif curStep == 559 then
camspeed = 1
elseif curStep == 560 then
doTweenZoom('cam', 'camGame',1.7, 0.5, 'linear')
setProperty('defaultCamZoom', 1.7)

cutscene = 1
elseif curStep == 560 then
triggerEvent('Play Animation', 'talk', 'gf')
elseif curStep == 567 then
triggerEvent('Play Animation', '', 'SP')
elseif curStep == 575 then
cutscene = false

elseif curStep == 576 then
doTweenZoom('cam', 'camGame',0.73, 0.1, 'linear')
setProperty('defaultCamZoom', 0.73)
cameraFlash('camOther', 'ffffff', 1, true)
triggerEvent('Change Character', 'dad', 'family')
setProperty('bg2_Anm.visible', true)
setProperty('bg1_Anm.visible', false)
setProperty('effectd_Anm.alpha', 0.15)
doTweenAlpha('forever', 'effectd_Anm', 0.9, 20, 'linear')
elseif curStep == 704 or curStep == 832 then
cameraFlash('camOther', 'ffffff', 1, true)

elseif curStep == 860 then
doTweenZoom('cam', 'camGame',1.7, 0.5, 'linear')

elseif curStep == 960 then
cameraFlash('camOther', 'ffffff', 1, true)
cutscene = 2
doTweenZoom('cam', 'camGame',0.53, 0.5, 'linear')
setProperty('defaultCamZoom', 0.53)

elseif curStep == 1080 then
doTweenZoom('cam', 'camGame',1.7, 1, 'linear')
cameraShake('camGame', 0.5, 1)
cutscene = false
elseif curStep == 1088 then
cameraFlash('camOther', 'ffffff', 1, true)
cutscene = 2
triggerEvent('WBG', 'on i')
setProperty('Brian.visible', false)
setProperty('gf.visible', false)
setProperty('effectd_Anm.alpha', 0.15)
triggerEvent('Change Character', 'dad', 'familydark')
doTweenZoom('cam', 'camGame',0.53, 0.5, 'linear')
setProperty('defaultCamZoom', 0.53)
elseif curStep == 1143 then
cutscene = false
follow = true
doTweenZoom('cam', 'camGame',1.2, 0.5, 'linear')
setProperty('defaultCamZoom', 1.2)

elseif curStep == 1144 then
doTweenX('Ahhhh', 'boyfriend', getProperty('dad.x') - 700, 0.7, 'linear')
elseif curStep == 1150 then
cutscene = 4
follow = false
elseif curStep == 1152 then
cameraFlash('camOther', 'ffffff', 2, true)
doTweenZoom('cam', 'camGame',0.53, 0.5, 'linear')
setProperty('defaultCamZoom', 0.53)
setProperty('boyfriend.visible', false)
elseif curStep == 1200 then
doTweenZoom('cam', 'camGame',0.6, 1, 'linear')
setProperty('defaultCamZoom', 0.6)

elseif curStep == 1213 then
setProperty('dad.visible', false)
doTweenZoom('cam', 'camGame',0.73, 0.1, 'linear')
setProperty('defaultCamZoom', 0.73)
cameraFlash('camOther', 'ffffff', 2, true)
elseif curStep == 1214 then
triggerEvent('WBG', 'off i')
setProperty('Brian.visible', true)
setProperty('boyfriend.visible', true)
setProperty('gf.visible', true)
setProperty('bg3_Anm.visible', true)
setProperty('bg2_Anm.visible', false)
elseif curStep == 1215 then

triggerEvent('Change Character', 'boyfriend', 'stewie')
doTweenZoom('cam', 'camGame',1, 0.1, 'linear')
setProperty('defaultCamZoom', 1)
triggerEvent('Change Character', 'boyfriend', 'stewie')
setProperty('boyfriend.flipX', false)
setProperty('boyfriend.x', gforiginalX)
setProperty('boyfriend.y', gforiginalY)


runTimer('gopeter', 0.05)
triggerEvent('Change Character', 'gf', 'loisduo')
setProperty('gf.x', getProperty('dad.x') + 400)
setProperty('gf.y', getProperty('dad.y') + 50)
elseif curStep == 1230 then
cutscene = false

elseif curStep == 1344 then
cameraFlash('camOther', 'ffffff', 1, true)

elseif curStep == 1472 then
betn = true

elseif curStep == 1728 then
cameraFlash('camOther', 'ffffff', 1, true)
cutscene = 2
doTweenZoom('cam', 'camGame',0.53, 0.5, 'linear')
setProperty('defaultCamZoom', 0.53)
betn = false

elseif curStep == 1856 then
doTweenZoom('cam', 'camGame',1, 15, 'linear')
setProperty('defaultCamZoom', 1)

triggerEvent('Black effect', '1.5')
cutscene = 3
camspeed = 0.1

setProperty('camHUD.visible', false)
setProperty('boyfriend.visible', false)
setProperty('gf.visible', false)
removeLuaSprite('Brian', true)
removeLuaSprite('bg3_Anm', true)
removeLuaSprite('effectd_Anm', true)

elseif curStep == 1860 or curStep == 1864 or curStep == 1872 or curStep == 1876 or curStep == 1880 or curStep == 1888 or curStep == 1892 or curStep == 1896 or curStep == 1904 or curStep == 1908 or curStep == 1912 or curStep == 1920 or curStep == 1924 or curStep == 1928 or curStep == 1936 or curStep == 1944 or curStep == 1952 or curStep == 1956 or curStep == 1960 or curStep == 1968 or curStep == 1972 or curStep == 1976 or curStep == 1980 then
triggerEvent('Black effect', '1.5')
elseif curStep >= 1984 and curStep < 1997 then
triggerEvent('Black effect', '0.3')

elseif curStep == 1997 then
setProperty('camGame.visible', false)
setProperty('camOther.visible', false)
end
end

function onBeatHit()
if betn then
if curBeat %2 == 0 then
triggerEvent('Add Camera Zoom', '0.05', '0.05')
setProperty('camGame.angle', 20)
doTweenAngle('ojde8wi', 'camGame', 0, 0.2, 'smootherStepIn')
else
triggerEvent('Add Camera Zoom', '0.05', '0.05')
setProperty('camGame.angle', -20)
doTweenAngle('ojde8wi', 'camGame', 0, 0.2, 'smootherStepIn')
end
end
end

function onEvent(name,value1,value2)
if name == 'WBG' then 
if value1 == 'on i' then
    doTweenColor('Brian', 'Brian', '000000', 0.001, 'linear');

end
if value1 == 'off i' then

    doTweenColor('Brian', 'Brian', 'ffffff', 0.001, 'linear');
end
end
end


