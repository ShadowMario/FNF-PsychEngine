function onCreate()
    makeLuaText('ratingText', '?', 100, 0, 550)
    setTextSize('ratingText', 150)
    addLuaText('ratingText')
end

function onUpdate(elapsed)
    if misses == 0 then
        setTextString('ratingText', 'S')
        setTextColor('ratingText', 'FFD000')
    elseif misses == 1 then
        setTextString('ratingText', 'A')
        setTextColor('ratingText', '37FF00')
    elseif misses == 5 then
        setTextString('ratingText', 'B')
        setTextColor('ratingText', '0022FF')
    elseif misses == 10 then
        setTextString('ratingText', 'C')
        setTextColor('ratingText', 'BD6200')
    elseif misses == 15 then
        setTextString('ratingText', 'D')
        setTextColor('ratingText', 'BD2F00')
    elseif misses == 20 then
        setTextString('ratingText', 'F')
        setTextColor('ratingText', '7A0000')
    end
end