--Script by Canndiez


local bfArrowMove = true -- enables the effect on bf's arrows
local dadArrowMove = true -- enables the effect on the opponent's arrows


local movementAmount = -30  -- how far the arrows move on the Y value
--TweenOutwards
local tweenType = 'elasticOut' 
local tweenTime = 1
--Tween Inwards
local inTweenType = 'cubeOut'
local inTweenTime = 0.1


local sideAmount = -20  -- how far the arrows move on the X value
--TweenOutwards
local sideTweenType = 'elasticOut' 
local sideTweenTime = 1
--Tween Inwards
local sideInTweenType = 'cubeOut'
local sideInTweenTime = 0.1


local rotationAmount = 30 -- how much the arrows can rotate
--Tween Outwards
local rotationTweenType = 'cubeInOut'
local rotationTweenTime = 0.25
--Tween Inwards
local inTweenTypeRot = 'cubeOut'
local inTweenTimeRot = 0.1


--All the actual code is below here
function goodNoteHit(id, direction, noteType, isSustainNote)

    if bfArrowMove == true then
		if direction == 0 then
		cancelTween('BFGO1')
		cancelTween('BFGO1ANG')
		
        noteTweenY('BFGO11', 4, defaultPlayerStrumY0-movementAmount, inTweenTime, inTweenType)
		noteTweenAngle('BFGO11ANG', 4, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('BFGO1X')			
        noteTweenX('BFGO11X', 4, defaultPlayerStrumX0+sideAmount, sideInTweenTime, sideInTweenType)
	
		
		elseif direction == 1 then
		cancelTween('BFGO2')
		cancelTween('BFGO2ANG')
		
        noteTweenY('BFGO22', 5, defaultPlayerStrumY1-movementAmount, inTweenTime, inTweenType)
		noteTweenAngle('BFGO22ANG', 5, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('BFGO2X')		
        noteTweenX('BFGO22X', 5, defaultPlayerStrumX1+(sideAmount*0.5), sideInTweenTime, sideInTweenType)
		
		elseif direction == 2 then
		cancelTween('BFGO3')
		cancelTween('BFGO3ANG')
		
        noteTweenY('BFGO33', 6, defaultPlayerStrumY2-movementAmount, inTweenTime, inTweenType)
		noteTweenAngle('BFGO33ANG', 6, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('BFGO3X')
        noteTweenX('BFGO33X', 6, defaultPlayerStrumX2-(sideAmount*0.5), sideInTweenTime, sideInTweenType)
		
		elseif direction == 3 then
		cancelTween('BFGO4')
		cancelTween('BFGO4ANG')
		
        noteTweenY('BFGO44', 7, defaultPlayerStrumY3-movementAmount, inTweenTime, inTweenType)
		noteTweenAngle('BFGO44ANG', 7, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('BFGO4X')
        noteTweenX('BFGO44X', 7, defaultPlayerStrumX3-sideAmount, sideInTweenTime, sideInTweenType)
		
		end
	end

end

function opponentNoteHit(id, direction, noteType, isSustainNote)

    if dadArrowMove == true then
		if direction == 0 then
		cancelTween('DADGO1')
		cancelTween('DADGO1ANG')
		
        noteTweenY('DADGO11', 0, defaultOpponentStrumY0-movementAmount, inTweenTime, inTweenType)
		noteTweenAngle('DADGO11ANG', 0, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('DADGO1X')
        noteTweenX('DADGO11X', 0, defaultOpponentStrumX0+sideAmount, sideInTweenTime, sideInTweenType)
		
		elseif direction == 1 then
		cancelTween('DADGO2')
		cancelTween('DADGO2ANG')
		
        noteTweenY('DADGO22', 1, defaultOpponentStrumY1-movementAmount,inTweenTime, inTweenType)
		noteTweenAngle('DADGO22ANG', 1, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('DADGO2X')		
        noteTweenX('DADGO22X', 1, defaultOpponentStrumX1+(sideAmount*0.5),sideInTweenTime, sideInTweenType)
		
		elseif direction == 2 then
		cancelTween('DADGO3')
		cancelTween('DADGO3ANG')
		
        noteTweenY('DADGO33', 2, defaultOpponentStrumY2-movementAmount, inTweenTime, inTweenType)
		noteTweenAngle('DADGO33ANG', 2, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('DADGO3X')
        noteTweenX('DADGO33X', 2, defaultOpponentStrumX2-(sideAmount*0.5), sideInTweenTime, sideInTweenType)
		
		elseif direction == 3 then
		cancelTween('DADGO4')
		cancelTween('DADGO4ANG')
		
        noteTweenY('DADGO44', 3, defaultOpponentStrumY3-movementAmount,inTweenTime, inTweenType)
		noteTweenAngle('DADGO44ANG', 3, math.random(-rotationAmount,rotationAmount), inTweenTimeRot, inTweenTypeRot)
		
		cancelTween('DADGO4X')
        noteTweenX('DADGO44X', 3, defaultOpponentStrumX3-sideAmount,sideInTweenTime, sideInTweenType)
		
		end
	end

end



function onTweenCompleted(tag)
	-- A tween you called has been completed, value "tag" is it's tag
	
	if tag == 'BFGO11' then
	noteTweenY('BFGO1', 4, defaultPlayerStrumY0, tweenTime, tweenType)
	end
	
	if tag == 'BFGO22' then
	noteTweenY('BFGO2', 5, defaultPlayerStrumY1, tweenTime, tweenType)
	end
	
	if tag == 'BFGO33' then
	noteTweenY('BFGO3', 6, defaultPlayerStrumY2, tweenTime, tweenType)
	end
	
	if tag == 'BFGO44' then
	noteTweenY('BFGO4', 7, defaultPlayerStrumY3, tweenTime, tweenType)
	end
	
	if tag == 'BFGO11X' then
	noteTweenX('BFGO1X', 4, defaultPlayerStrumX0, sideTweenTime, sideTweenType)
	end
	
	if tag == 'BFGO22X' then
	noteTweenX('BFGO2X', 5, defaultPlayerStrumX1, sideTweenTime, sideTweenType)
	end
	
	if tag == 'BFGO33X' then
	noteTweenX('BFGO3X', 6, defaultPlayerStrumX2, sideTweenTime, sideTweenType)
	end
	
	if tag == 'BFGO44X' then
	noteTweenX('BFGO4X', 7, defaultPlayerStrumX3, sideTweenTime, sideTweenType)
	end
	
	
	if tag == 'BFGO11ANG' then
	noteTweenAngle('BFGO1ANG', 4, 0, rotationTweenTime, rotationTweenType)
	end
	
	if tag == 'BFGO22ANG' then
	noteTweenAngle('BFGO2ANG', 5, 0, rotationTweenTime, rotationTweenType)
	end
	
	if tag == 'BFGO33ANG' then
	noteTweenAngle('BFGO3ANG', 6, 0, rotationTweenTime, rotationTweenType)
	end
	
	if tag == 'BFGO44ANG' then
	noteTweenAngle('BFGO4ANG', 7, 0, rotationTweenTime, rotationTweenType)
	end
	
	
	
	
	
	
	
	
	if tag == 'DADGO11' then
	noteTweenY('DADGO1', 0, defaultOpponentStrumY0, tweenTime, tweenType)
	end
	
	if tag == 'DADGO22' then
	noteTweenY('DADGO2', 1, defaultOpponentStrumY1, tweenTime, tweenType)
	end
	
	if tag == 'DADGO33' then
	noteTweenY('DADGO3', 2, defaultOpponentStrumY2, tweenTime, tweenType)
	end
	
	if tag == 'DADGO44' then
	noteTweenY('DADGO4', 3, defaultOpponentStrumY3, tweenTime, tweenType)
	end
	
	if tag == 'DADGO11X' then
	noteTweenX('DADGO1X', 0, defaultOpponentStrumX0, sideTweenTime, sideTweenType)
	end
	
	if tag == 'DADGO22X' then
	noteTweenX('DADGO2X', 1, defaultOpponentStrumX1, sideTweenTime, sideTweenType)
	end
	
	if tag == 'DADGO33X' then
	noteTweenX('DADGO3X', 2, defaultOpponentStrumX2, sideTweenTime, sideTweenType)
	end
	
	if tag == 'DADGO44X' then
	noteTweenX('DADGO4X', 3, defaultOpponentStrumX3, sideTweenTime, sideTweenType)
	end
	
	if tag == 'DADGO11ANG' then
	noteTweenAngle('DADGO1ANG', 0, 0, rotationTweenTime, rotationTweenType)
	end
	
	if tag == 'DADGO22ANG' then
	noteTweenAngle('DADGO2ANG', 1, 0, rotationTweenTime, rotationTweenType)
	end
	
	if tag == 'DADGO33ANG' then
	noteTweenAngle('DADGO3ANG', 2, 0, rotationTweenTime, rotationTweenType)
	end
	
	if tag == 'DADGO44ANG' then
	noteTweenAngle('DADGO4ANG', 3, 0, rotationTweenTime, rotationTweenType)
	end
	
end
