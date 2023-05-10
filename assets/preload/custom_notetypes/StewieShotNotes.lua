function onCreatePost()

precacheSound('funny_pew_pew')
makeAnimatedLuaSprite('dadsh', 'characters/CorruptStewiePh2', getProperty('dad.x'), getProperty('dad.y'))

addAnimationByPrefix('dadsh', 'shoot8', 'CorruptStewiePh2 shoot', 20, false)

setProperty('dadsh.alpha', 0)
setProperty('dadsh.scale.x', 1.1)
setProperty('dadsh.scale.y', 1.1)
addLuaSprite('dadsh', true)

makeLuaSprite('redfl', nil, 0, 0)
    makeGraphic('redfl', screenWidth, screenHeight, 'FF0028')
setProperty('redfl.alpha', 0)
setObjectCamera('redfl', 'other')
addLuaSprite('redfl', true)

    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'StewieShotNotes' then 
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'StewieShotNotes'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true); -- make it so original character doesn't sing these notes
            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
            end
        end
    end
end


function onUpdate()
setProperty('dadsh.offset.x', 180)
setProperty('dadsh.offset.y', 474)
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'StewieShotNotes' then
playSound('funny_pew_pew', 1)
setProperty('dadsh.alpha', 1)
setProperty('dadsh.x', getProperty('dad.x'))
setProperty('dadsh.y', getProperty('dad.y'))
objectPlayAnimation('dadsh', 'shoot8', true)
setProperty('dad.alpha', 0)
runTimer('backdadyoyoyoyoyoyoyoyo', 0.5)
    end
end



function noteMiss(id, direction, noteType, isSustainNote)
    if noteType == 'StewieShotNotes' then
setProperty('health',getProperty('health') - 0.4)
playSound('funny_pew_pew', 1)
setProperty('dadsh.alpha', 1)
setProperty('dadsh.x', getProperty('dad.x'))
setProperty('dadsh.y', getProperty('dad.y'))
objectPlayAnimation('dadsh', 'shoot8', true)
setProperty('dad.alpha', 0)
setProperty('redfl.alpha', 1)
doTweenAlpha('flaaaa', 'redfl', 0, 2, 'linear')
runTimer('backdadyoyoyoyoyoyoyoyo', 0.5)
    end
end


function onTimerCompleted(t)
if t == 'backdadyoyoyoyoyoyoyoyo' then
setProperty('dad.alpha', 1)
setProperty('dadsh.alpha', 0)
end
end