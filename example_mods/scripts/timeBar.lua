function formatTime(millisecond)
    local seconds = math.floor(millisecond / 1000)

    return string.format("%01d:%02d:%02d", (seconds / 360) % 60, (seconds / 60) % 60, seconds % 60)  
end

function onUpdatePost(elapsed)
    setTextString('timeTxt', formatTime(getSongPosition() - noteOffset) .. ' / ' .. formatTime(songLength))
end