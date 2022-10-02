local angleshit = 15;
local anglevar = 13;
function onBeatHit()
	if curBeat % 2 == 0 then
		angleshit = anglevar;
	else
		angleshit = -anglevar;
	end
	setGraphicSize('iconP1', angleshit*-10)
	setGraphicSize('iconP2', angleshit*10)
	setProperty('iconP1.angle',angleshit*-1.2)
	setProperty('iconP2.angle',angleshit*1.2)
	doTweenAngle('turn', 'iconP1', 0, stepCrochet*0.004, 'cubeOut')
	doTweenX('tuin', 'iconP1', -angleshit*8, crochet*0.001, 'linear')
	doTweenAngle('tt', 'iconP2', 0, stepCrochet*0.004, 'cubeOut')
	doTweenX('ttrn', 'iconP2', -angleshit*8, crochet*0.001, 'linear')
end

function onUpdatePost()

	setProperty("iconP1.scale.y", (getProperty("iconP1.scale.y") - 1) / -0.6 + 1)
	setProperty("iconP2.scale.y", (getProperty("iconP2.scale.y") - 1) / -0.6 + 1)
	setProperty("iconP1.y", 500 + (getProperty("iconP1.scale.y") * 75))
	setProperty("iconP2.y", 500 + (getProperty("iconP2.scale.y") * 75))
   
	if getPropertyFromClass('ClientPrefs', 'downScroll') == true then
	   setProperty("iconP1.y", -65 + (getProperty("iconP1.scale.y") * 75))
	   setProperty("iconP2.y", -65 + (getProperty("iconP2.scale.y") * 75))
	end
end