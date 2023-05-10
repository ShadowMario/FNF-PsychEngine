function onCreate()

precacheSound('punchFF')
originaldadx = getProperty('dad.x')
    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'FFHitNote' then 
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'FFHitNote'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true); -- make it so original character doesn't sing these notes
            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
            end
        end
    end
end
colddown = false
function onCreatePost()
makeAnimatedLuaSprite('FF_punch', 'characters/ErnieCorrupt', getProperty('dad.x'), getProperty('dad.y'))
addAnimationByPrefix('FF_punch', 'punch', 'Hit', 17, false)
setProperty('FF_punch.alpha', 0)
addLuaSprite('FF_punch', false)

makeAnimatedLuaSprite('PFF_punch', 'characters/PeterErnie', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
addAnimationByPrefix('PFF_punch', 'punch', 'Hit', 24, false)
setProperty('PFF_punch.alpha', 0)
addLuaSprite('PFF_punch', false)

makeAnimatedLuaSprite('PcFF_punch', 'characters/PeterErnieCorrupt', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
addAnimationByPrefix('PcFF_punch', 'punch', 'Hit', 24, false)
setProperty('PcFF_punch.color', getColorFromHex('7B7B7B'))
setProperty('PcFF_punch.alpha', 0)
addLuaSprite('PcFF_punch', false)


end

function onUpdate()

setProperty('FF_punch.x', getProperty('dad.x'))
setProperty('FF_punch.y', getProperty('dad.y'))
setProperty('PcFF_punch.color', getProperty('boyfriend.color'))
setProperty('FF_punch.color', getProperty('dad.color'))

setProperty('PcFF_punch.x', getProperty('boyfriend.x'))
setProperty('PcFF_punch.y', getProperty('boyfriend.y'))

setProperty('PFF_punch.offset.x', 157)
setProperty('PFF_punch.offset.y', 4)

setProperty('PcFF_punch.offset.x', 128)
setProperty('PcFF_punch.offset.y', 8)

setProperty('FF_punch.offset.x', -93)
setProperty('FF_punch.offset.y', 38)
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'FFHitNote' then

triggerEvent('Add Camera Zoom', 0.05,0.03)
cameraShake('camHUD', 0.03, 0.05)
cameraShake('camGame', 0.03, 0.05)
setProperty('camGame.angle', math.random(-15, 15))
doTweenAngle('dhdube guy iebehduedeidheyeherbjkeehskfsb bobby ebegys hi ge gif yet true see iegwow gift efwwh', 'camGame', 0, 0.3, 'circOut')
playSound('punchFF', 0.5)
if not colddown then
colddown = true
runTimer('cool', 1.1)
objectPlayAnimation('FF_punch', 'punch', true)
setProperty('dad.alpha', 0)
setProperty('FF_punch.alpha', 1)
setProperty('boyfriend.alpha', 0)
if boyfriendName == 'peterCorruptFF' then
setProperty('PcFF_punch.alpha', 1)
objectPlayAnimation('PcFF_punch', 'punch', true)
doTweenX('9', 'dad', getProperty('dad.x') + 145, 0.5, 'circOut')
else
setProperty('PFF_punch.alpha', 1)
objectPlayAnimation('PFF_punch', 'punch', true)
doTweenX('9', 'dad', getProperty('dad.x') + 120, 0.5, 'circOut')
end

    end
end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if noteType == 'FFHitNote' then
setProperty('health',getProperty('health') - 0.4)
triggerEvent('Add Camera Zoom', 0.05,0.03)
cameraShake('camHUD', 0.03, 0.05)
cameraShake('camGame', 0.03, 0.05)
cameraFlash('camOther', '000000', 3, true)
setProperty('camGame.angle', math.random(-30, 30))
doTweenAngle('dhdube guy iebehduedeidheyeherbjkeehskfsb bobby ebegys hi ge gif yet true see iegwow gift efwwh', 'camGame', 0, 0.3, 'circOut')
playSound('punchFF', 0.5)
if not colddown then
colddown = true
objectPlayAnimation('FF_punch', 'punch', true)
setProperty('dad.alpha', 0)
setProperty('FF_punch.alpha', 1)

runTimer('cool', 1.1)
if boyfriendName == 'peterCorruptFF' then
doTweenX('9', 'dad', getProperty('dad.x') + 175, 0.5, 'circOut')
else
doTweenX('9', 'dad', getProperty('dad.x') + 165, 0.5, 'circOut')
end
    end
end
end

function onTweenCompleted(t)
if t == '9' then
doTweenX('91', 'dad', originaldadx, 0.5, 'circOut')
setProperty('dad.alpha', 1)
setProperty('FF_punch.alpha', 0)
setProperty('boyfriend.alpha', 1)
setProperty('PFF_punch.alpha', 0)
setProperty('PcFF_punch.alpha', 0)
end
end

function onTimerCompleted(t)
if t == 'cool' then
colddown = false
end
end