function onCreatePost()
precacheSound('funny_pew_pew')
makeLuaSprite('laser', 'L laser', getProperty('gf.x') - 330, getProperty('gf.y') + 20)
scaleObject('laser', 2.2, 2.2)
setProperty('laser.visible', false)
addLuaSprite('laser', false)

makeLuaSprite('ATTACK', 'ATTACK', -290 ,-210)
scaleObject('ATTACK', 0.7, 0.7)
setProperty('ATTACK.visible', false)
setObjectCamera('ATTACK', 'hud')
addLuaSprite('ATTACK', false)
end


function opponentNoteHit(id, direction, noteType, isSustainNote)
if dadName == 'peter' then
if getProperty('health') >= 0.03 then

setProperty('health', getProperty('health') - 0.01)

end
elseif dadName == 'family' then
setProperty('health', getProperty('health') - 0.025)
elseif gfName == 'loisduo' then
if getProperty('health') >= 0.03 then
setProperty('health', getProperty('health') - 0.015)
end
elseif dadName == 'peterchrismeg' then
setProperty('health', getProperty('health') - 0.02)
elseif dadName == 'megandchris' then
setProperty('health', getProperty('health') - 0.01)
end
end


local shot = false
local cold = 5
local first = true
local red = 0
local just = true
function onUpdatePost()

if keyJustPressed('space') and shot or botPlay and shot then
shot = false
runTimer('youcannow', 1, 5)
setProperty('health', getProperty('health') + 0.3)
playSound('funny_pew_pew', 1)

cold = 5
triggerEvent('Play Animation', 'gunshot', 'gf')
triggerEvent('Play Animation', 'gunshot', 'boyfriend')
doTweenX('oi', 'laser', -900, 0.3, 'linear')
doTweenY('oi2', 'laser', 100, 0.3, 'linear')
setProperty('laser.visible', true)
setProperty('ATTACK.visible', true)
setProperty('ATTACK.alpha', 0.5)

if first == true then
first = false
red = 0
doTweenX('k', 'ATTACK.scale', 0.2, 1, 'linear')
doTweenY('k2', 'ATTACK.scale', 0.2, 1, 'linear')
doTweenX('k3', 'ATTACK', getProperty('healthBarBG.x') -1070, 1, 'linear')
doTweenY('k4', 'ATTACK', getProperty('healthBarBG.y') - 650, 1, 'linear')
setProperty('ATTACK.alpha', 0.5)
setProperty('ATTACK.color', getColorFromHex('FFFFFF'))
end
end

if curStep == 577 and shot == false then
setProperty('ATTACK.visible', true)
runTimer('flashthe', 0.1, 1000000000)

shot = true
first = true
red = 1
elseif curStep == 1089 and just == true then
doTweenAlpha('co', 'ATTACK', 0, 1, 'linear')
just = false
shot = false
cold = 99

elseif curStep == 1281 and just == false then
just = true
setProperty('ATTACK.visible', true)
setProperty('ATTACK.alpha',1)
setProperty('ATTACK.x', -290)
setProperty('ATTACK.y', -210)
setProperty('ATTACK.scale.x', 0.7)
setProperty('ATTACK.scale.y', 0.7)
runTimer('flashthe', 0.1, 1000000000)
shot = true
first = true

doTweenAlpha('forever', 'effectd_Anm', 0.9, 20, 'linear')
red = 1
elseif curStep == 1857 then
removeLuaSprite('ATTACK', true)
cold = 99
shot = false
end
if cold == 0 then
shot = true
setProperty('ATTACK.alpha', 1)
end
end

function onTimerCompleted(tag)


if tag == 'youcannow' then
cold = cold - 1

end
if tag == 'flashthe' then
if red == 1 then
setProperty('ATTACK.color', getColorFromHex('FF2F00'))
red = 2
elseif red == 2 then
setProperty('ATTACK.color', getColorFromHex('FFFFFF'))
red = 1
end
end
end

function onTweenCompleted(tag)
if tag == 'oi' then

if boyfriendName == 'triobf' then
setProperty('laser.y', getProperty('gf.y') + 20)
setProperty('laser.x', getProperty('gf.x') - 330)
setProperty('laser.visible', false)
end

if boyfriendName == 'stewie' then
setProperty('laser.y', getProperty('boyfriend.y') + 20)
setProperty('laser.x', getProperty('boyfriend.x') - 330)
setProperty('laser.visible', false)
end

elseif tag == 'co' then
removeLuaText('col', true)
cold = 99
end
end