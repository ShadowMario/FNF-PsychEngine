function onCreate()
precacheSound('shotgun')
makeAnimatedLuaSprite('qug2', 'characters/QuagmireShotgunFV', getProperty('boyfriend.x') + 90, getProperty('boyfriend.y') - 30);
		addAnimationByPrefix('qug2', 'haha', 'QuagmireShotgunFV shot', 19, false);

setProperty('qug2.visible', false)
		scaleObject('qug2', 1.2, 1.2);
		addLuaSprite('qug2',true)
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'shotgun' then --Check if the note on the chart is a Bullet Note
		setPropertyFromGroup('unspawnNotes', i, 'texture', 'QuagmireShotgunNotes'); --Change texture

		setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true); -- make it so original character doesn't sing these notes

		setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties

			end
		end
	end

function onUpdatePost()
setProperty('qug2.offset.x', 1320)
setProperty('qug2.offset.y', -209)
end

function goodNoteHit(id, direction, noteType, isSustainNote)
if noteType == 'shotgun' then
setProperty('health', getProperty('health') + 0.5)
setProperty('boyfriend.visible', false)
setProperty('qug2.visible', true)
objectPlayAnimation('qug2', 'haha', false)
runTimer('getbacktowork', 1)
playSound('shotgun')
cameraShake('camGame', 0.05, 0.2)
cameraShake('camHUD', 0.05, 0.2)
end
end


function onTimerCompleted(t)
if t == 'getbacktowork' then
setProperty('boyfriend.visible', true)
setProperty('qug2.visible', false)
end
end