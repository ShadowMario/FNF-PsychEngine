-- Creator: HaxLua
-- Link: https://github.com/ShadowMario/FNF-PsychEngine/discussions/3670

notehitlol = 0
sadfasd = 0 -- unused
font = "vcr.ttf" -- the font that the text will use.
cmoffset = -4
cmy = 20
tnhx = -10

function onCreate()
    makeLuaText("tnh", 'Total Notes Hit: 0', 250, tnhx, 259); -- Total Notes Hit: 0
    setTextFont('tnh', font)
    setObjectCamera("tnh", 'other');
    setTextAlignment("tnh", 'left');
    setTextSize('tnh', 20);
    addLuaText("tnh");
    doTweenX('tnhTween', 'tnh', '5.7', '0.1', 'linear')

    makeLuaText("cm", 'Combos: 0', 200, -getProperty('tnh.x') + cmoffset, getProperty('tnh.y') + cmy);
    makeLuaText("sick", 'Sicks!: 0', 200, getProperty('cm.x'), getProperty('cm.y') + 30);
    makeLuaText("good", 'Goods: 0', 200, getProperty('cm.x'), getProperty('sick.y') + 30);
    makeLuaText("bad", 'Bads: 0', 200, getProperty('cm.x'), getProperty('good.y') + 30);
    makeLuaText("shit", 'Shits: 0', 200, getProperty('cm.x'), getProperty('bad.y') + 30);
    makeLuaText("miss", 'Misses: 0', 200, getProperty('cm.x'), getProperty('shit.y') + 30);

    setObjectCamera("cm", 'other');
    setTextSize('cm', 20);
    addLuaText("cm");
    setTextFont('cm', font)
    setTextAlignment('cm', 'left')

    setObjectCamera("sick", 'other');
    setTextSize('sick', 20);
    addLuaText("sick");
    setTextFont('sick', font)
    setTextAlignment('sick', 'left')

    setObjectCamera("good", 'other');
    setTextSize('good', 20);
    addLuaText("good");
    setTextFont('good', font)
    setTextAlignment('good', 'left')

    setObjectCamera("bad", 'other');
    setTextSize('bad', 20);
    addLuaText("bad");
    setTextFont('bad', font)
    setTextAlignment('bad', 'left')

    setObjectCamera("shit", 'other');
    setTextSize('shit', 20);
    addLuaText("shit");
    setTextFont('shit', font)
    setTextAlignment('shit', 'left')

    setObjectCamera("miss", 'other');
    setTextSize('miss', 20);
    setTextColor('miss', 'ff0000');
    addLuaText("miss");
    setTextFont('miss', font)
    setTextAlignment('miss', 'left')
end  

function goodNoteHit(id, direction, noteType, isSustainNote)
	-- Function called when you hit a note (after note hit calculations)
	-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
	-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
	-- noteType: The note type string/tag
	-- isSustainNote: If it's a hold note, can be either true or false
    if not isSustainNote then
        notehitlol = notehitlol + 1;
        setTextString('tnh', 'Total Notes Hit: ' .. tostring(notehitlol))
    end -- NOTE I DID NOT MAKE THIS FRANTASTIC24 MADE THIS!
end  

function onUpdate(elapsed)
    -- notehitloltosting = tostring(notehitlol)
    setTextString('cm', 'Combos: ' .. getProperty('combo'))
    setTextString('sick', 'Sick!: ' .. getProperty('sicks'))
    setTextString('good', 'Goods: ' .. getProperty('goods'))
    setTextString('bad', 'Bads: ' .. getProperty('bads'))
    setTextString('shit', 'Shits: ' .. getProperty('shits'))
    setTextString('miss', 'Misses: ' .. getProperty('songMisses'))
	-- start of "update", some variables weren't updated yet
    -- setTextString('tnh', 'Total Notes Hit: ' + 1)    
end  