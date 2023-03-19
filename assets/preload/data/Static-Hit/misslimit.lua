local misslimit = 15 -- You can set this to any number you want!

function onUpdatePost(elasped)
    setTextString('scoreTxt', 'Score: '.. score .. ' | Misses: '.. misses .. '/'.. misslimit .. ' | Rating: '.. ratingName)
end

function onUpdate(elapsed)
    if misses > misslimit then
        setProperty('health', 0)
    end
end