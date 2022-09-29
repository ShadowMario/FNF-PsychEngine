--- credit if you use this or else
--- original icon bop golden apple script by bbpanzu
--- Laztrix#5670 did all here


local turnvalue = 20
function onCreatePost()

  setProperty('timeBarBG.visible',false)
  setProperty('timeBar.visible',false)
  setProperty('scoreTxt.visible',false)
  setTextFont('botplayTxt', 'COMIC.TTF')
  setTextFont('timeTxt', 'COMIC.TTF')


  makeLuaText('ghudscoreTxt', 'Score: 0 | Misses: 0 | Accuracy: 0%', 1280, 0, (downscroll and 114 or 686));
  setTextBorder("ghudscoreTxt", 2, '000000')
  setTextAlignment('ghudscoreTxt', 'CENTER')
  setTextFont('ghudscoreTxt', 'COMIC.TTF')
  setTextSize('ghudscoreTxt', 20)
  addLuaText('ghudscoreTxt')

  makeLuaText('ghudsong', (songName .. ' - ' .. getProperty('storyDifficultyText')), 1280, 2, (downscroll and 0 or 695));
  setTextBorder("ghudsong", 1.8, '000000')
  setTextAlignment('ghudsong', 'LEFT')
  setTextFont('ghudsong', 'COMIC.TTF')
  setTextSize('ghudsong', 17)
  addLuaText('ghudsong')



 for i = 0,3 do
   setPropertyFromGroup('strumLineNotes',i,'x',40 + (112 * (i % 4)))
   end
   for i = 4,7 do
    setPropertyFromGroup('strumLineNotes',i,'x',670 + (112 * (i % 4)))
    end
  
  setProperty('grpNoteSplashes.visible',false)
  setProperty('camZoomingDecay',2.5)
end
function onSongStart()
  setProperty('camZooming',true)
end
function onCountdownTick(counter)
      if counter == 0 then
          characterPlayAnim('dad','idle',true)
          characterPlayAnim('dad','danceLeft',true)
          characterPlayAnim('boyfriend','idle',true)
      end
      if counter == 1 then
          characterPlayAnim('dad','idle',true)
          characterPlayAnim('dad','danceLeft',true)
          characterPlayAnim('boyfriend','idle',true)
      end
      if counter == 2 then
          characterPlayAnim('dad','idle',true)
          characterPlayAnim('dad','danceLeft',true)
          characterPlayAnim('boyfriend','idle',true)
          cameraSetTarget("boyfriend")
      end
      if counter == 3 then
          characterPlayAnim('dad','danceLeft',true)
          cameraSetTarget("boyfriend")
          characterPlayAnim('dad','idle',true)
          if boyfriendName == 'bf' then
          characterPlayAnim('boyfriend','hey',true)
          else
          characterPlayAnim('boyfriend','idle',true)
          end
          characterPlayAnim('gf','cheer',true)
      end
end
------- ICON BOP SYSTEM (LAZTRIX,ft. bbpanzu) --------------
function onBeatHit()
  setProperty('iconP2.scale.x',1)
  turnvalue = 20
  if curBeat % 2 == 0 then
  turnvalue = -20
  end
    if curBeat % 1 == 0 then
      setProperty('bficon.scale.y',0.6)
      doTweenY('bfic','bficon.scale',1,crochet/1000,'circOut')
      setProperty('dadicon.scale.y',1.4)
      doTweenY('dadic','dadicon.scale',1,crochet/1000,'circOut')
  setProperty('iconP2.angle',turnvalue)
  setProperty('iconP1.angle',-turnvalue)
  doTweenAngle('iconTween1','iconP1',0,crochet/1000,'circOut')
  doTweenAngle('iconTween2','iconP2',0,crochet/1000,'circOut')
  end
  if curBeat % 2 == 0 then
    setProperty('bficon.scale.y',1.4)
    doTweenY('bfic','bficon.scale',1,crochet/1000,'circOut')
    setProperty('dadicon.scale.y',0.6)
    doTweenY('dadic','dadicon.scale',1,crochet/1000,'circOut')
  end
end

  if curBeat % 4 == 0 then
  setProperty('timeTxt.scale.x',1.15)
  setProperty('timeTxt.scale.y',1.15)
  doTweenX('da','timeTxt.scale',1,0.5,'circOut')
  doTweenY('da2','timeTxt.scale',1,0.5,'circOut')
  end
end
-----------------------------------------------------------
function onUpdate()
  setTextString('ghudscoreTxt','Score: '..score..' | Misses: '..misses..' | Accuracy: '..round((getProperty('ratingPercent') * 100), 2) ..'%')
end


function goodNoteHit(id, direction, noteType, isSustainNote)
  if not isSustainNote then
  setProperty('ghudscoreTxt.scale.x',1.1)
  doTweenX('scora','ghudscoreTxt.scale',1,crochet/1000,'bounceOut')
  end
end

function milliToHuman(milliseconds) -- https://forums.mudlet.org/viewtopic.php?t=3258
	local totalseconds = math.floor(milliseconds / 1000)
	local seconds = totalseconds % 60
	local minutes = math.floor(totalseconds / 60)
	minutes = minutes % 60
	return string.format("%02d:%02d", minutes, seconds)  
end

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end