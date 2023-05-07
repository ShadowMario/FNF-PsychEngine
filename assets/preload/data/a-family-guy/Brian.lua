
--by latter or latter K (no one will get it)
function onRecalculateRating()

end

-----------------------------------------------

--this is only useful for things like setProperty and doTweens and things that you can do to LuaSprites in general 

local Character_tag = 'Brian'--if you want to make more than one character then make sure that the names are different from each other

-----------------------------------------------

local Character_Image_Name = 'characters/Brian'

-----------------------------------------------

local x = 950 --this is the characterX
local y = 450 --this is the characterY

--here you can fix the offsets for the animations. i recommended that you make a .json for the character and fix the offsets from there, then just copy and paste the already fixed offsets and you will be done.
offsetI = {'1', '1'}-- idle

offsetL = {'1', '1'}-- left

offsetD = {'1', '1'}-- down

offsetU = {'1', '1'}-- up

offsetR = {'1', '1'}-- right

offsetS = {'4', '1'}-- special
-----------------------------------------------

--you can find the animation name in the .xml for the Character
local idle = 'Brian idle'

local left = 'Brian left'

local down = 'Brian down'

local up = 'Brian up'

local right = 'Brian right'

local special = 'Brian talk'
-----------------------------------------------

--here is the frame for the animations, 24 is the default 

local FrameI = 24--for Idle

local FrameL = 24--for Left

local FrameD = 24--for Down

local FrameU = 24--for Up

local FrameR = 24--for Right 

local FrameS = 24--for Special anim
-----------------------------------------------

--here is the idle option, do you want the idle to loop or not, if the idle doesn't loop, that means the idle animation will play with beats, just like the normal characters

local loopI = false--or true

--heres the option if you want the character to hide or not

local Hide = false--or true


function onStepHit()
--here you can abuse this to unhide the character
if Hide == true then
if curStep == 100 then-- you can choose the step that you want, if you don't know what steps are, there basically like the grey and white Square in the chart editor

		setProperty(Character_tag.. '.alpha', 1)
end
end
end

function onEvent(name, value1, value2)
if name == 'Play Animation' then
if value2 == 'SP' then
loopI = true
objectPlayAnimation(Character_tag, 'SPECIAL', false)
runTimer('play', 1)
end
end
end

-----------------------------------------------
--here you will have the option to ether put the character behind (false) or above (true) the characters AND above all the stage elements.

local above = true--or true


local flip = false-- do you want to flipX the character or not

--here you can choose the size of the character

local xS = 1.1--this is for the X
local yS = 1.1--this is for the Y

-----------------------------------------------
local note = 'BrianNotes'--this is for the character to play there animations
-----------------------------------------------
-----------------------------------------------


function onCreate()
makeAnimatedLuaSprite(Character_tag, Character_Image_Name, x, y);

local fuck_this = true
	addAnimationByPrefix(Character_tag, 'IDLE', idle, FrameI, loopI);
	addAnimationByPrefix(Character_tag, 'LEFT', left, FrameL, false);
	addAnimationByPrefix(Character_tag, 'DOWN', down, FrameD, false);
	addAnimationByPrefix(Character_tag, 'UP', up, FrameU, false);
	addAnimationByPrefix(Character_tag, 'RIGHT', right, FrameR, false);
	addAnimationByPrefix(Character_tag, 'SPECIAL', special, FrameS, false);
setProperty(Character_tag.. '.flipX', flip)
objectPlayAnimation (Character_tag, 'IDLE', false)
	if Hide == true then
		setProperty(Character_tag.. '.alpha', 0)
end


	scaleObject(Character_tag, xS, yS);
	addLuaSprite(Character_tag, above);


	end

function onCreatePost()
			for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == note then
setPropertyFromGroup('unspawnNotes', i, 'texture', 'BrianNotes');
end

if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'StewieNotes' then
setPropertyFromGroup('unspawnNotes', i, 'texture', 'StewieNotes'); 
end
end
end

function onUpdate()

if getProperty(Character_tag..'.animation.curAnim.name') == 'IDLE' then
		objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);
elseif getProperty(Character_tag..'.animation.curAnim.name') == 'LEFT' then
		objectPlayAnimation(Character_tag, 'LEFT');
	setProperty(Character_tag.. '.offset.x', offsetL[1]);
	setProperty(Character_tag.. '.offset.y', offsetL[2]);
elseif getProperty(Character_tag..'.animation.curAnim.name') == 'UP' then
		objectPlayAnimation(Character_tag, 'UP');
	setProperty(Character_tag.. '.offset.x', offsetU[1]);
	setProperty(Character_tag.. '.offset.y', offsetU[2]);
elseif getProperty(Character_tag..'.animation.curAnim.name') == 'DOWN' then
		objectPlayAnimation(Character_tag, 'DOWN');
	setProperty(Character_tag.. '.offset.x', offsetD[1]);
	setProperty(Character_tag.. '.offset.y', offsetD[2]);
elseif getProperty(Character_tag..'.animation.curAnim.name') == 'RIGHT' then
		objectPlayAnimation(Character_tag, 'RIGHT');
	setProperty(Character_tag.. '.offset.x', offsetR[1]);
	setProperty(Character_tag.. '.offset.y', offsetR[2]);
end
end

local singing = {"LEFT", "DOWN", "UP", "RIGHT"}
local singgf = {"singLEFT", "singDOWN", "singUP", "singRIGHT"}
function onUpdatePost(elapsed)
	for a = 0, getProperty('notes.length') - 1 do
      local noteData = getPropertyFromGroup('notes', a, 'noteData');
      local strumTime = getPropertyFromGroup('notes', a, 'strumTime');
      if getPropertyFromGroup('notes', a, 'noteType') == note then
         setPropertyFromGroup('notes', a, 'alpha', 0.5);
         setPropertyFromGroup("notes", a, "mustPress", true)
if getPropertyFromGroup("notes", a, "isSustainNote") then
setPropertyFromGroup('notes', a, 'offset.y', -20);
end
         if strumTime - getSongPosition() < -20 then
            removeFromGroup("notes" , a , false)
    objectPlayAnimation(Character_tag, singing[noteData + 1], true);
runTimer('idle back', 0.5)
fuck_this = false
setProperty('health', getProperty('health') + 0.01)
         end
      end
if curStep < 1219 then
      if getPropertyFromGroup('notes', a, 'noteType') == 'StewieNotes' then
         setPropertyFromGroup('notes', a, 'alpha', 0.5);
         setPropertyFromGroup("notes", a, "mustPress", true)
if getPropertyFromGroup("notes", a, "isSustainNote") then
setPropertyFromGroup('notes', a, 'offset.y', -20);
end
         if strumTime - getSongPosition() < -20 then
            removeFromGroup("notes" , a , false)
if gfName == 'stewie' then
        characterPlayAnim("gf", singgf[(noteData % 4) + 1], true)
end

if boyfriendName == 'stewie' then
        characterPlayAnim("boyfriend", singgf[(noteData % 4) + 1], true)

end

setProperty('health', getProperty('health') + 0.01)
	end
end
end
end
end




function opponentNoteHit(id, direction, noteType, isSustainNote)
if noteType == note then
runTimer('idle back', 0.5)
fuck_this = false

objectPlayAnimation(Character_tag, singing[direction + 1], true);



if direction == 0 then
	setProperty(Character_tag.. '.offset.x', offsetL[1]);

	setProperty(Character_tag.. '.offset.y', offsetL[2]);



elseif direction == 1 then
	setProperty(Character_tag.. '.offset.x', offsetD[1]);
	setProperty(Character_tag.. '.offset.y', offsetD[2]);



elseif direction == 2 then
	setProperty(Character_tag.. '.offset.x', offsetU[1]);
	setProperty(Character_tag.. '.offset.y', offsetU[2]);



elseif direction == 3 then
	setProperty(Character_tag.. '.offset.x', offsetR[1]);
	setProperty(Character_tag.. '.offset.y', offsetR[2]);



		end
end

end

function goodNoteHit(id, direction, noteType, isSustainNote)
if noteType == note then

runTimer('idle back', 0.5)

fuck_this = false

objectPlayAnimation(Character_tag, singing[direction + 1], true);




if direction == 0 then
	setProperty(Character_tag.. '.offset.x', offsetL[1]);

	setProperty(Character_tag.. '.offset.y', offsetL[2]);



elseif direction == 1 then
	setProperty(Character_tag.. '.offset.x', offsetD[1]);
	setProperty(Character_tag.. '.offset.y', offsetD[2]);



elseif direction == 2 then
	setProperty(Character_tag.. '.offset.x', offsetU[1]);
	setProperty(Character_tag.. '.offset.y', offsetU[2]);



elseif direction == 3 then
	setProperty(Character_tag.. '.offset.x', offsetR[1]);
	setProperty(Character_tag.. '.offset.y', offsetR[2]);



		end
end

end

-- this is for the character to do there animation on Countdown with the actual characters
function onCountdownTick(counter)
if loopI == false then
	if counter %2 == 0 and fuck_this == true then
			objectPlayAnimation(Character_tag, 'IDLE');
			setProperty(Character_tag.. '.offset.x', offsetI[1]);
			setProperty(Character_tag.. '.offset.y', offsetI[2]);
		end
end
end

-- this is for the character to do there animation on beat
function onBeatHit()

if loopI == false then
	if curBeat % 2 == 0 and fuck_this == true then
		objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);

	end
fuck_this = true
end
end

function onTimerCompleted(tag)
if tag == 'play' then
loopI = false
		objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);
end
if tag == 'idle back' then

		objectPlayAnimation(Character_tag, 'IDLE');
		setProperty(Character_tag.. '.offset.x', offsetI[1]);
		setProperty(Character_tag.. '.offset.y', offsetI[2]);
end
end