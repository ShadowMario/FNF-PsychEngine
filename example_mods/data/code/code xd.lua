local letters = 0
local randomInt = 0
local x = 500
local letterArray = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', ' ', '(', ')', '    ', "'", ",", ''}
local letterArrayCap = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
local numberArray = {0,1,2,3,4,5,6,7,8,9}
local symbolsArray = {"-", ".", "/"}
letterNumber = 0
local currentText = ''
local lastState = nil
local keyIsHeld = false
local amountOfLetters = 0
local lines = 1

function onCreate()
    precacheSound('type')
    makeLuaSprite('a', '', -100, -50)
    makeGraphic('a', 1920, 1080, '000000')
    setScrollFactor('a', 0, 0)
    addLuaSprite('a', true)
    setProperty('camHUD.visible', 0)
    runTimer('updateNumber', 0.001, 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
    makeLuaText('yess', '[] are ()\n\nUse The Numberpad For Numbers\n\nShift + Enter to save script\n\nEverything else is the same as usual\n\nPress BACKSPACE To Delete After Reading', nil,10, 10)
    addLuaText('yess', true)
    makeLuaText('aaa', 'a', nil,500, 200)
    addLuaText('aaa', true)
    setProperty('skipCountdown', 1)
    setTextSize('yess', 50)
    setTextFont('yess', 'calibri.ttf')
    setTextBorder('yess', 0)
    --screenCenter('yess', 'Y')
    --screenCenter('yess', 'X')
    setObjectCamera('yess', 'other')
    startingX = getProperty('yess.x')
end
local Stage = {Save = {}}
function onUpdate()
    setProperty('sound.volume', 0)

    setTextAlignment('text', 'left')
    setProperty('yess.antialiasing', true)
    onUpdateKeys()
    setTextString('aaa', letterNumber)
    currentText = getTextString('yess')
    if getTextString('yess') == 'function' then
        setTextColor('yess', '8a00c2')
    elseif getTextString('yess') == 'function onCreate()' then
        setTextColor('yess', 'FFEA17')
    elseif getTextString('yess') == 'function onCreate() end' then
        setTextColor('yess', '8a00c2')
    elseif getTextString('yess') == '--' then
        setTextColor('yess', '228c22')
    elseif lines == 0 then
        setTextColor('yess', 'ffffff')
        lines = 1
    elseif lines > 1 then
        setTextColor('yess', 'ffffff')
        lines = 1
    elseif not getTextString('yess') == '--' then
        setTextColor('yess', 'ffffff')
    end

    --letterNumber = letterNumber+1
    --if letterNumber > 26 then
    --    letterNumber = 0
    --end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ANY') and not getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE') then
        playSound('type')
    end
    if keyIsHeld then
        playSound('type')
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        --screenCenter('yess', 'X')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justReleased.ANY') and not getPropertyFromClass('flixel.FlxG', 'keys.justReleased.BACKSPACE') and not getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ENTER') then
        keyIsHeld = false
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ENTER') and getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
        
        Stage.Save:Lua()
    end
    freezeTime()
end

function Stage.Save:Lua()

    local src = [==[

--      Script Made By JasonTheOne111

]==] .. getTextString('yess') 

    local path = 'mods/scripts/itWorked.lua'
    debugPrint('Updated Lua Script in: ' .. path)
    local luaFile = io.open(path, 'wb')
    luaFile:write(src)
    luaFile:close()
end
function pr(ahh, key)
    getPropertyFromClass('flixel.FlxG', 'keys.' .. ahh .. '.'  .. key)
end

function freezeTime()
    setPropertyFromClass('Conductor', 'songPosition', 0)
    setPropertyFromClass('flixel.FlxG', 'sound.music.time', 0)
	setPropertyFromClass('flixel.FlxG', 'sound.vocals.volume', 0)
	setPropertyFromClass('flixel.FlxG', 'sound.music.volume', 0);
	setProperty('instrumental.volume', 0)
	setProperty('vocals.volume', 0)
end

function onTimerCompleted(tag)
    if tag == 'isKeyHeld' then
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.ANY') and not getPropertyFromClass('flixel.FlxG', 'keys.pressed.BACKSPACE') and not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            keyIsHeld = true
        end
    end
    if tag == 'addLetter' then
        setProperty('yess.x', getProperty('yess.x')-5)
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
    end
    if tag == 'updateNumber' then
        --letterNumber = letterNumber+1
    end
end


function onUpdateKeys()
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.A') then
        letterNumber = 1
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.B') then
        letterNumber = 2
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.C') then
        letterNumber = 3
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.D') then
        letterNumber = 4
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.E') then
        letterNumber = 5
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.F') then
        letterNumber = 6
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.G') then
        letterNumber = 7
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.H') then
        letterNumber = 8
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.I') then
        letterNumber = 9
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.J') then
        letterNumber = 10
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.K') then
        letterNumber = 11
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.L') then
        letterNumber = 12
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.M') then
        letterNumber = 13
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.N') then
        letterNumber = 14
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.O') then
        letterNumber = 15
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.P') then
        letterNumber = 16
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.Q') then
        letterNumber = 17
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.R') then
        letterNumber = 18
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.S') then
        letterNumber = 19
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.T') then
        letterNumber = 20
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.U') then
        letterNumber = 21
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.V') then
        letterNumber = 22
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.W') then
        letterNumber = 23
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.X') then
        letterNumber = 24
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.Y') then
        letterNumber = 25
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.Z') then
        letterNumber = 26
        lastState = getTextString('yess')
        if not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        end
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
            setTextString('yess', getTextString('yess') .. letterArrayCap[letterNumber])
        end
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE') then
        letterNumber = 27
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.LBRACKET') then
        letterNumber = 28
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.RBRACKET') then
        letterNumber = 29
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.TAB') then
        letterNumber = 30
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        --screenCenter('yess', 'X')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.QUOTE') then
        letterNumber = 31
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.COMMA') then
        letterNumber = 32
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ENTER') and not getPropertyFromClass('flixel.FlxG', 'keys.pressed.SHIFT') then
        letterNumber = 33
        lines = lines+1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. letterArray[letterNumber] .. '\n')
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
        runTimer('isKeyHeld', 0.6)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADZERO') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[1])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADONE') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[2])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.DOWN') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[3])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end

    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADTHREE') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[4])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.LEFT') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[5])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADFIVE') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[6])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.RIGHT') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[7])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end

    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADSEVEN') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[8])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.UP') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[9])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADNINE') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. numberArray[10])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.MINUS') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. symbolsArray[1])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.PERIOD') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. symbolsArray[2])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SLASH') then
        letterNumber = -1
        lastState = getTextString('yess')
        setTextString('yess', getTextString('yess') .. symbolsArray[3])
        --screenCenter('yess', 'X')
        --screenCenter('yess', 'Y')
    end
    --getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADONE')
    if getPropertyFromClass('flixel.FlxG', "keys.pressed.BACKSPACE") then
        letterNumber = -1
        setTextColor('yess', 'ffffff')
        setTextString('yess', '')
        setProperty('yess.x', startingX)
    end
    if getPropertyFromClass('flixel.FlxG', "keys.justPressed.ESCAPE") then
        endSong()
    end
end

function onPause()
    return Function_Stop;
end

