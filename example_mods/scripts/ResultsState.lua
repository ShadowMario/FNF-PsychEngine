function onEndSong()
	openCustomSubstate('Results', true)
	return Function_Stop
end

function onCreate()
	topCombo = 0
end

function onUpdate()
	if topCombo < getProperty('combo') then
		topCombo = getProperty('combo')
	end
end

function onCustomSubstateCreate(tag)
	if not isStoryMode then
	songAndDiff = songName..' - '..string.upper(difficultyName)
	sickWin = getPropertyFromClass('ClientPrefs','sickWindow')
	goodWin = getPropertyFromClass('ClientPrefs','goodWindow')
	badWin = getPropertyFromClass('ClientPrefs','badWindow')
	shitWin = 166
	if tag == 'Results' then
		setPropertyFromClass('flixel.FlxG','mouse.visible', true)
		playMusic('breakfast', 0.8, true)

		makeLuaSprite('bg','',0,0)
		makeGraphic('bg', screenWidth, screenHeight,'000000')
		setObjectCamera('bg', 'other')
		setProperty('bg.alpha', 0)
		addLuaSprite('bg', true)

		makeLuaText('cleared','Song Cleared!',0,20,-55)
		setTextSize('cleared', 34)
		setTextBorder('cleared', 4,'000000')
		setTextFont('cleared','pixel.otf')
		setObjectCamera('cleared','other')
		addLuaText('cleared')

		makeLuaText('playedOn','Played on '..songAndDiff,0,20,-70)
		setTextSize('playedOn', 34)
		setTextFont('playedOn','pixel.otf')
		setTextBorder('playedOn', 4,'000000')
		setObjectCamera('playedOn','other')
		addLuaText('playedOn')

		makeLuaText('judge','Judgements:',0,20,-75)
		setTextFont('judge','pixel.otf')
		setTextBorder('judge', 4,'000000')
		setTextSize('judge', 28)
		setObjectCamera('judge','other')
		addLuaText('judge')

		makeLuaText('sick','Sicks - '..getProperty('sicks'),0,20, -75)
		setTextFont('sick','pixel.otf')
		setTextBorder('sick', 4,'000000')
		setObjectCamera('sick','other')
		setTextSize('sick', 28)
		addLuaText('sick')

		makeLuaText('good','Goods - '..getProperty('goods'),0,20, -75)
		setTextFont('good','pixel.otf')
		setTextBorder('good', 4,'000000')
		setObjectCamera('good','other')
		setTextSize('good', 28)
		addLuaText('good')

		makeLuaText('bad','Bads - '..getProperty('bads'),0,20, -75)
		setTextFont('bad','pixel.otf')
		setTextBorder('bad', 4,'000000')
		setObjectCamera('bad','other')
		setTextSize('bad', 28)
		addLuaText('bad')

		makeLuaText('breaks','Combo Breaks: '..misses,0, 20, -75)
		setTextSize('breaks', 28)
		setObjectCamera('breaks','other')
		setTextBorder('breaks', 4,'000000')
		setTextFont('breaks','pixel.otf')
		addLuaText('breaks')

		makeLuaText('combo','Highest Combo: '..topCombo,0, 20, -75)
		setTextSize('combo', 28)
		setObjectCamera('combo','other')
		setTextBorder('combo', 4,'000000')
		setTextFont('combo','pixel.otf')
		addLuaText('combo')

		makeLuaText('score','Score: '..score,0, 20, -75)
		setTextSize('score', 28)
		setObjectCamera('score','other')
		setTextBorder('score', 4,'000000')
		setTextFont('score','pixel.otf')
		addLuaText('score')

		makeLuaText('accuracy','Accuracy: '..round(rating * 100,2)..'%'..' (Accurate)',0, 20, -75)
		setTextSize('accuracy', 28)
		setObjectCamera('accuracy','other')
		setTextBorder('accuracy', 4,'000000')
		setTextFont('accuracy','pixel.otf')
		addLuaText('accuracy')

--[[ this doesn't wanna work for some reason so fuck it
		makeLuaText('rating','('..ratingFC..') '..wife3,0, 20, -75)
		setTextSize('rating', 28)
		setObjectCamera('rating','other')
		setTextBorder('rating', 4,'000000')
		setTextFont('rating','pixel.otf')
		addLuaText('rating')
--]]

		makeLuaText('continue','Click or Press ENTER to continue.', 0, 660, 800)
		setTextSize('continue', 24)
		setObjectCamera('continue','other')
		setTextBorder('continue', 4,'000000')
		setTextFont('continue','pixel.otf')
		addLuaText('continue')

		makeLuaText('timeWin','Mean: ? (SICK:'..sickWin..'ms,GOOD:'..goodWin..'ms,BAD:'..badWin..'ms,SHIT:'..shitWin..'ms)', 0, 20, 810)
		setTextSize('timeWin', 14)
		setObjectCamera('timeWin','other')
		setTextBorder('timeWin', 4,'000000')
		setTextFont('timeWin','pixel.otf')
		addLuaText('timeWin')

		doTweenAlpha('tween','bg', 0.65, 0.5,'linear')
		doTweenY('down','cleared', 20, 1,'expoOut')
		doTweenY('down2','playedOn', 90, 1,'expoOut')
		doTweenY('down4','judge', 180, 1,'expoOut')
		doTweenY('down5','sick', 220, 1,'expoOut')
		doTweenY('down6','good', 260, 1,'expoOut')
		doTweenY('down7','bad', 300, 1,'expoOut')
		doTweenY('down8','breaks', 370, 1,'expoOut')
		doTweenY('down9','combo', 410, 1,'expoOut')
		doTweenY('down10','score', 450, 1,'expoOut')
		doTweenY('down11','accuracy', 490, 1,'expoOut')
		doTweenY('down12','rating', 560, 1,'expoOut')
		doTweenY('up','continue', 670, 1,'expoOut')
		doTweenY('up2','timeWin', 680, 1,'expoOut')
	end
end
end

function onCustomSubstateUpdate(tag)
	if mousePressed('left') then
		exitSong()
		setPropertyFromClass('flixel.FlxG','mouse.visible', false)
	end
	if keyboardJustPressed('ENTER') then
		exitSong()
		setPropertyFromClass('flixel.FlxG','mouse.visible', false)
	end
end

function round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return  x / n
end

function onRecalculateRating()
    if rating >= 0.999935 then
       wife3 = 'AAAAA'
   elseif rating >= 0.99980 then
       wife3 = 'AAAA:'
   elseif rating >= 0.99970 then
       wife3 = 'AAAA.'
   elseif rating >= 0.99955 then
       wife3 = 'AAAA'
   elseif rating >= 0.9990 then
       wife3 = 'AAA:'
   elseif rating >= 0.9980 then
       wife3 = 'AAA.'
   elseif rating >= 0.9970 then
       wife3 = 'AAA'
   elseif rating >= 0.99 then
       wife3 = 'AA:'
   elseif rating >= 0.9650 then
       wife3 = 'AA.'
   elseif rating >= 0.93 then
       wife3 = 'AA'
   elseif rating >= 0.90 then
       wife3 = 'A:'
   elseif rating >= 0.85 then
       wife3 = 'A.'
   elseif rating >= 0.80 then
       wife3 = 'A'
   elseif rating >= 0.70 then
       wife3 = 'B'
   elseif rating >= 0.60 then
       wife3 = 'C'
   elseif rating <= 0.60 then
       wife3 = 'D'
   end
end