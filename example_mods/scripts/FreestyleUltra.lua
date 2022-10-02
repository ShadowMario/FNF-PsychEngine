--[[
Welcome to ThermiteFe8's fucking ass script!! It almost works I think

If you wanna use it, modify it, or do literally anything else with it go ahead - just let me know 'cause I wanna see what
you make/record using this beautiful mess!!! feel free to credit me too but I can't really do anything about it if you don't

Only works if ghost tapping is on. 

CONTROLS!!!!!!!!
Space - make BF do an animation and say "yeah"
Tab - Switch between beatboxing mode and chromatic mode
Shift - if you're in chromatic mode, holding it makes you play the upper half of the scale. If you're in beatboxing mode,
it switches you to the next set of sounds. Right now there's just two sets
Alt - switches between major/minor scale. Doesn't do shit if you're in beat mode
CONTROL - switches the scale, raising it by a semitone
BACKSPACE - switches the scale, lowering it by a semitone.
CAPSLOCK - toggles beatSnap mode for chromatics. Can only snap to later beats since I haven't discovered time travel, sadly.

If you ghost tap while chromatic mode's on, you'll do some actual singing!! make sure to match up the key/scale with whatever
is playing or else it'll probably sound bad. Wouldn't want that, would you? huh?? punk ass bitch

If you ghost tap while beat mode's on, you'll make beatbox and background noises. I don't actually know if they're labeled
properly because I was born yesterday, sadly. 

I've tried commenting the code to make it easier to modify and use, so there's that too

also bf starts on C because fuck you
]]--
local yeahKey = "SPACE";
local toggleModeKey = "TAB";
local shiftSetKey = "SHIFT";
local majorMinorKey = "ALT";
local raiseScaleKey = "CONTROL";
local lowerScaleKey = "BACKSPACE";
local toggleBeatKey = "CAPSLOCK";

local chromaticState = false; -- if its false, we're on beat mode. Otherwise we're on singing mode
local scale = 1; --controls what scale we're on. It starts on C and goes up a semitone for each unit increase
local altScale = false; -- if it's true, it just switches BF to the upper half of the scale on chromatic mode
local minorScale = false; --if it's true, we're using a major instead of a minor scale
local chromaticMax = 31; --maximum reach of the chromatic. Just how many filesdureslaaaaasd
local loopTimeMin = 150; --Milliseconds(?) to start the loop at for a hold note? I don't even know if it works
local toggleBeatSnap = false;
--I don't even know how many of the below variables are used but I'm afraid of touching anything because it could just
--explode again and that doesn't sound good
local allPossibleSounds = {FreestyleNote0 = 'left', FreestyleNote1 = 'down', FreestyleNote2 = 'up', FreestyleNote3 = 'right'};
local currentFilesChromatic = {FreestyleNote0 = 0, FreestyleNote1 = 1, FreestyleNote2 = 2, FreestyleNote3 = 3}; --futile attempt to make thing work
local noteLabels = {noteZero = 'C', noteOne = 'D', noteTwo = 'E', noteThree = 'F'};
--If you wanna add more beatbox sounds, just follow what I've done with these two tables/arrays
local beatboxGroupNames = {defaultBox = {noteZero = "boom", noteOne = "boom", noteTwo = "beat", noteThree = "twist"}, freshVoice = {noteZero = "man", noteOne = "go", noteTwo = "aw", noteThree = "yeah"}};
local beatboxGroupHelper = {"defaultBox", "freshVoice"};

local allNotes = {'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'}; --list of notes
local beatboxMax = 4; -- number of beatbox sounds
local beatboxSet = 0; -- how many sets of beatbox stuff minus one
local beatboxSetMax = 1; --yeah


--local noteOneTag = "";
--Create the text boxes
--please lua I beg of you
function onCreatePost() --creates the text lables
	local yTextOffset = -50;--maybe I should just center it on the note?? idk
	if(downscroll == true) then
		yTextOffset = -50
	end
	
	makeLuaText('noteZero', "go", 200, defaultPlayerStrumX0 - 45, defaultPlayerStrumY0 + yTextOffset); --default names or smthn idk
	makeLuaText('noteOne', "boom", 200, defaultPlayerStrumX1- 45, defaultPlayerStrumY1 + yTextOffset);
	makeLuaText('noteTwo', "beat", 200, defaultPlayerStrumX2- 45, defaultPlayerStrumY2 + yTextOffset);
	makeLuaText('noteThree', "man", 200, defaultPlayerStrumX3- 45, defaultPlayerStrumY3 + yTextOffset);
	
	for p,s in pairs(noteLabels) do 
	  setTextSize(p, 30);
	  setTextAlignment(p, 'center');
	  addLuaText(p);
	 end

	
	
end
function scaleWriter(daNumber)
	local otherHelper = daNumber%12;
	if otherHelper == 0 then
		otherHelper = 12;
	end
	return otherHelper;
end
function onUpdatePost(elapsed) --text update stuff - handles the scoreTXT thing and the note lables
	--remakes the regular score text because holy fuck
	local ratingHelper = math.floor(rating * 10000)/100;
	local textHelper = "Score: ".. score ..' | Misses: ' .. misses ..' | Rating: '.. ratingName .." ("..ratingHelper.."%) | ";
	
	if chromaticState == true then
		textHelper = textHelper .. "Chromatic | " .. allNotes[scaleWriter(scale)];
		--debugPrint(textHelper);
		setTextString('noteZero', allNotes[scaleWriter(scaleHandler(0))]);
		setTextString('noteOne', allNotes[scaleWriter(scaleHandler(1))]);
		setTextString('noteTwo', allNotes[scaleWriter(scaleHandler(2))]);
		setTextString('noteThree', allNotes[scaleWriter(scaleHandler(3))]);
		if minorScale == true then
			textHelper = textHelper .. " Minor";
		else
			textHelper = textHelper .. " Major";
		end
		if toggleBeatSnap == true then
		textHelper = textHelper .. " | Beat Snap Mode On"
		else
		textHelper = textHelper .. " | Beat Snap Mode Off"
		end
	else
		setTextString('noteZero', beatboxGroupNames[beatboxGroupHelper[beatboxSet + 1]].noteZero);
		setTextString('noteOne', beatboxGroupNames[beatboxGroupHelper[beatboxSet + 1]].noteOne);
		setTextString('noteTwo', beatboxGroupNames[beatboxGroupHelper[beatboxSet + 1]].noteTwo);
		setTextString('noteThree', beatboxGroupNames[beatboxGroupHelper[beatboxSet + 1]].noteThree);
		
		--debugPrint(textHelper);
		textHelper = textHelper .. "Beat | " .. beatboxGroupHelper[beatboxSet + 1];
		--debugPrint(textHelper);
	end
	setProperty('scoreTxt.text', textHelper);
end

--SECTION THAT HANDLES THE AUDIO AND SHIT
function onUpdate(elapsed)
	-- start of "update", some variables weren't updated yet
	if keyboardJustPressed(yeahKey) then
		playSound("\\balls\\Yeah");
		characterPlayAnim("boyfriend", "hey", true);
	end
	
	if keyboardJustPressed(toggleModeKey) then --switch chromatic state
		chromaticState = not chromaticState;
	end
	if keyboardJustPressed(toggleBeatKey) then
		toggleBeatSnap = not toggleBeatSnap;
	end
	
	if keyboardJustPressed(shiftSetKey) then --i already described these why am I writing stuff
		altScale = true;
		beatboxSet = beatboxSet + 1;
		if beatboxSet > beatboxSetMax then
			beatboxSet = 0;
		end
		
		
	end
	
	if keyboardJustPressed(majorMinorKey) then
		minorScale = not minorScale;
	end
	
	if keyboardJustPressed(raiseScaleKey) and chromaticState == true then
		scale = scale + 1;
		if scale > chromaticMax then --loops scale back around if you go too far
			scale = 1;
		end
		
		
	end
	
	if keyboardJustPressed(lowerScaleKey) and chromaticState == true then
		scale = scale - 1;
		if scale < 1 then -- loops scale back around if you go too far
			scale = chromaticMax;
		end
	end
	
	if keyboardReleased(shiftSetKey) then -- haha I'm stuff get it
		altScale = false;
	end
	

	 -- fades out the note if the key's been released
	if keyReleased('left') then
		--stopSound("FreestyleNote0");
		soundFadeOut("FreestyleNote" .. 0, 0.025);
	elseif keyReleased'down' then
		--stopSound("FreestyleNote1");
		soundFadeOut("FreestyleNote" .. 1, 0.025);
	elseif keyReleased'up' then
		--stopSound("FreestyleNote2");
		soundFadeOut("FreestyleNote" .. 2, 0.025);
	elseif keyReleased'right' then
		--stopSound("FreestyleNote3");
		soundFadeOut("FreestyleNote" .. 3, 0.025);
	end
	
end

--handles the looping of chromatic audio
function onSoundFinished(tag)
	if keyPressed(allPossibleSounds[tag]) then
		
		playSound("\\chromatic\\" .. scaleHandler(currentFilesChromatic[tag]), 1, tag);
		setSoundTime(tag, loopTimeMin);
		
		--debugPrint(tag);
	end

	
end

function onPause() --pauses audio in the menu because that might've been a problem for a while
	 for k,v in ipairs(allPossibleSounds) do 
	 pauseSound(v); 
	 --debugPrint(v); 
	 end
end

function onGhostTap(direction) --starts the sound effects on ghost tap
	if chromaticState == true then
		helper = "FreestyleNote" .. direction; --tag for the note so I can reference it later
		playSound("\\chromatic\\" .. scaleHandler(direction), 1, helper);
		if toggleBeatSnap == true then
			pauseSound(helper);
		end
		--debugPrint("\\chromatic\\" .. scaleHandler(direction));

	else --if it isn't chromatic just play the beatbox noises.
		playSound("\\beatbox\\" .. beatboxHandler(direction));
	end
	
	
	--play the note animations kronk
	if direction == 0 then
		characterPlayAnim("boyfriend", "singLEFT", true);
	elseif direction == 1 then
		characterPlayAnim("boyfriend", "singDOWN", true);
	elseif direction == 2 then
		characterPlayAnim("boyfriend", "singUP", true);
	else 
		characterPlayAnim("boyfriend", "singRIGHT", true);
	end
	
end

function onStepHit()
	if toggleBeatSnap == true and curStep%2 == 0 then
	resumeSound("FreestyleNote0");
	resumeSound("FreestyleNote1");
	resumeSound("FreestyleNote2");
	resumeSound("FreestyleNote3");
	end
end

--helps select the beatbox sounds so I don't have to
function beatboxHandler(direction)
	beatboxHelper = direction + 1;
	beatboxHelper = beatboxHelper + 4*beatboxSet;
	return beatboxHelper;

end

--deals with selecting the notes that're in the scale. I forgot how this works. I don't remember writing it. 
function scaleHandler(direction)
	local directionHelper = 1;
	if direction == 0 then
	
	elseif direction == 1 then
	directionHelper = directionHelper + 2;
		if altScale == true and minorScale == true then
			directionHelper = directionHelper - 1;
		end
	elseif direction == 2 then
	directionHelper = directionHelper + 3;
		if minorScale == false then
		directionHelper = directionHelper + 1;
		end
	else
	directionHelper = directionHelper + 5;
	end
	directionHelper = directionHelper + scale - 1;
	if altScale == true then
		directionHelper = directionHelper + 7;
	end
	
	while (directionHelper > chromaticMax) do
		directionHelper = directionHelper - chromaticMax;
	end
	
	return directionHelper;
	
	
end
--extra unused code I might wanna reference later
--[[function onGhostTap(direction)
	--playSound("BeatBoxOne");
	if direction == 0 then
		playSound("BeatBoxOne");
		characterPlayAnim("boyfriend", "singLEFT", true);
	elseif direction == 1 then
		playSound("BeatBoxOne");
		characterPlayAnim("boyfriend", "singDOWN", true);
	elseif direction == 2 then
		playSound("BeatBoxTwo");
		characterPlayAnim("boyfriend", "singUP", true);
	else 
		playSound("Go");
		characterPlayAnim("boyfriend", "singRIGHT", true);
	end
end]]--
		--setProperty("modchartSounds(" .. helper ..").volume)", 0);
		--setProperty("FreestyleNote" .. direction .. ".loopTime", loopTimeMin);
	--setPropertyFromGroup("modchartSoudns", index:Int, variable:Dynamic, value:Dynamic)