function onUpdatePost()
    if getPropertyFromClass('ClientPrefs', 'timeBarType') == 'Disabled' then
        close(true)
    else
        setProperty('botplayTxt.visible', false)
        setProperty('timeBarBG.visible', false)
  
        setTextBorder('scoreTxt', 1, '000000')
        setTextSize('scoreTxt', 20)
        setObjectCamera('scoreTxt', 'other')
        setTextAlignment('scoreTxt', 'center')
        setProperty('scoreTxt.x', '')
        setProperty('scoreTxt.y', 685)
  
        setProperty('timeBar.x', 445)
        setProperty('timeBar.scale.x', 3.275)
        setProperty('timeBar.y', 710)
        setObjectCamera('timeBar', 'other')
  
        setTextSize('timeTxt', 20)
        setProperty('timeTxt.x', 870)
        setTextBorder('timeTxt', 1, '000000')
        setTextAlignment('timeTxt', 'right')
        setProperty('timeTxt.y', 685)
        setObjectCamera('timeTxt', 'other')
  
        makeLuaText('songName', '', 0, 10, 685)
        setTextSize('songName', 20)
        setTextBorder('songName', 1, '000000')
        setObjectCamera('songName', 'other')
        addLuaText('songName')
        setTextString('songName', songName.. ' - ' ..string.upper(difficultyName))
        
        if getPropertyFromClass('ClientPrefs', 'timeBarType') == 'Song Name' then
            setProperty('timeTxt.visible', false)
            setProperty('scoreTxt.x', -10)
            setTextAlignment('scoreTxt', 'right')
        end
  
        if botPlay == true then
            setTextString('scoreTxt', 'BOTPLAY')
        else
            setTextString('scoreTxt', 'Score: ' ..score.. ' | Misses: ' ..misses.. ' | Accuracy: ' ..getRatingVar().. '%')
        end

        setPropertyFromClass('ClientPrefs', 'scoreZoom', false)
    end
end
  
function onCreatePost()
    setProperty('timeBar.color', getColorFromHex('FF0000'))
end

function getRatingVar()
	return string.sub(tostring(rating*100), 1, 5)
end