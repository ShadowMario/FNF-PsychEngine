function onCreate()
    precacheImage('mfm-stage-gospel');
    precacheImage('mfm-stage-crescendo');
    precacheImage('ruv-fatassmod');
    precacheImage('ruv-fatassmod-crescendo');
    precacheImage('sarvente-succubus');
    precacheImage('sarvente-succubus-fatassmod-crescendo');
end

local xx = 270;
local yy = 500;
local xx2 = 750;
local yy2 = 500;
local ofs = 75;
local followchars = true;
local del = 0;
local del2 = 0;

function onEvent(name,value1,value2)
        if name == 'Blammed Lights' then 
            
            if value1 == '1' then
                cameraShake('game', '0.02', '0.1');
                cameraShake('hud', '0.02', '0.1');
            end
            if value1 == '2' then
                cameraShake('game', '0.02', '0.1');
                cameraShake('hud', '0.02', '0.1');
            end
            if value1 == '3' then
                cameraShake('game', '0.02', '0.1');
                cameraShake('hud', '0.02', '0.1');
            end
            if value1 == '4' then
                cameraShake('game', '0.02', '0.1');
                cameraShake('hud', '0.02', '0.1');
            end
            if value1 == '5' then
                cameraShake('game', '0.02', '0.1');
                cameraShake('hud', '0.02', '0.1');
            end
        end
    end
function onUpdate()
	if del > 0 then
		del = del - 1
	end
	if del2 > 0 then
		del2 = del2 - 1
	end
    if followchars == true then
        if mustHitSection == false then
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
        else

            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            end
	    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
    else
        triggerEvent('Camera Follow Pos','','')
    end
end

