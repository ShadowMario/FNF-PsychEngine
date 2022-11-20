function onCreatePost()

makeLuaText('misses', '99: 99', 400, 10,590)
setTextFont('misses','youtube-sans-medium.ttf')
setTextSize('misses', 25)
setObjectCamera('misses', 'hud')
setTextAlignment('misses','left')
addLuaText('misses')
setProperty('misses.antialiasing', false)

makeLuaText('score-text', '99: 99', 400, 10,645)
setTextFont('score-text','youtube-sans-medium.ttf')
setTextSize('score-text', 40)
setObjectCamera('score-text', 'hud')
setTextAlignment('score-text','left')
addLuaText('score-text')
setProperty('score-text.antialiasing', false)

makeLuaText('accuracy', '99: 99%', 400, 10,621)
setTextFont('accuracy','youtube-sans-medium.ttf')
setTextSize('accuracy', 25)
setObjectCamera('accuracy', 'hud')
setTextAlignment('accuracy','left')
addLuaText('accuracy')
setProperty('accuracy.antialiasing', false)

end

function onUpdatePost()
accuracylua = math.floor((rating*100)*1000)/1000;
setProperty("scoreTxt.y", -990)
setTextString("score-text", 'Score: '..score)--getProperty('scoreTxt.text'))
setTextString("misses", 'Misses: '..misses)
setTextString("accuracy", "Accuracy: "..accuracylua.."%")
end