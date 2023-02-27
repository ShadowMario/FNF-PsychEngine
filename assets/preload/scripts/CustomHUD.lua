
function onCreatePost() --everything written by Rhy

    makeLuaText('score', "Score: ", 0, 15, 375) --score
    setTextSize('score', 24)
    setTextFont('score', 'PhantomMuff.ttf')
    setTextColor('score', 'FF000000')
    addLuaText('score', "Score: ", 0, 150, 150)
    setObjectCamera('score', 'other')

    makeLuaText('Vs Stupid v1 ( DEMO BUILD )', "Vs Stupid v1 ( DEMO BUILD )", 0, 15, 600) --watermark mod text
    setTextSize('Vs Stupid v1 ( DEMO BUILD )', 24)
    setTextFont('Vs Stupid v1 ( DEMO BUILD )', 'PhantomMuff.ttf')
    setTextColor('Vs Stupid v1 ( DEMO BUILD )', 'FF000000')
    addLuaText('Vs Stupid v1 ( DEMO BUILD )', "Vs Stupid v1 ( DEMO BUILD )", 0, 150, 150)
    setObjectCamera('Vs Stupid v1 ( DEMO BUILD )', 'other')


    makeLuaText('misses', "Misses: ", 0, 15, 400) --misses
    setTextSize('misses', 24)
    setTextFont('misses', 'PhantomMuff.ttf')
    setTextColor('misses', 'FF000000')
    addLuaText('misses', "Misses: ", 0, 150, 140)
    setObjectCamera('misses', 'other')

    makeLuaText('ratingName', "Rating: ", 0, 15, 425) --rating
    setTextSize('ratingName', 24)
    setTextFont('ratingName', 'PhantomMuff.ttf')
    setTextColor('ratingName', 'FF000000')
    addLuaText('ratingName', "Rating: ", 0, 150, 150)
    setObjectCamera('ratingName', 'other')

    makeLuaText('difficultyName', "Difficulty: ", 0, 15, 455) --ratingFC
    setTextSize('difficultyName', 24)
    setTextFont('difficultyName', 'PhantomMuff.ttf')
    setTextColor('difficultyName', 'FF000000')
    addLuaText('difficultyName', "Difficulty: ", 0, 150, 150)
    setObjectCamera('difficultyName', 'other')

end

function onUpdatePost()

    setTextString('score', 'Score: '.. getPropertyFromClass(score))

    setTextString('misses', 'Misses: '.. getPropertyFromClass(misses))

    setTextString('ratingName', 'Rating: '.. getPropertyFromClass(ratingName))

    setTextString('difficultyName', "Difficulty: ".. getPropertyFromClass(difficultyName))

end
