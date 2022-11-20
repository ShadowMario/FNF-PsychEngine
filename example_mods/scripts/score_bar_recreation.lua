scoreName = "Score"
missesName = "Misses"
ratingNames = "Rating"
function onUpdate()
    if not getProperty('ratingName') == '?' then
        setProperty('scoreTxt.text', scoreName .. ': ' .. getProperty('songScore') .. ' | ' .. missesName .. ': ' .. getProperty('songMisses') .. ' | ' .. ratingNames .. ': ' .. getProperty('ratingName') .. ' (' .. round(getProperty('ratingPercent') * 100, 2) .. '%) - ' .. getProperty('ratingFC'))
    end
    if getProperty('ratingName') == '?' then
        setProperty('scoreTxt.text', scoreName .. ': ' .. getProperty('songScore') .. ' | ' .. missesName .. ': ' .. getProperty('songMisses') .. ' | ' .. ratingNames .. ': ' .. getProperty('ratingName'))
    end
end
function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end