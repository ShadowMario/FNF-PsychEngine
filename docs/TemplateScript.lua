-- Lua stuff

function onCreate()
	-- Triggered when the lua file is started, some variables weren't created yet
end

function onCreatePost()
	-- End of "create"
end

function onDestroy()
	-- Triggered when the lua file is ended
end


-- Gameplay/Song interactions
function onSectionHit()
	-- Triggered after it goes to the next section
end

function onBeatHit()
	-- Triggered 4 times per section
end

function onStepHit()
	-- Triggered 16 times per section
end

function onUpdate(elapsed)
	-- Start of "update", some variables weren't updated yet
	-- Also gets called while in the game over screen
end

function onUpdatePost(elapsed)
	-- End of "update"
	-- Also gets called while in the game over screen
end

function onStartCountdown()
	-- Countdown started, duh
	-- return Function_Stop if you want to stop the countdown from happening (Can be used to trigger dialogues and stuff! You can trigger the countdown with startCountdown())
	return Function_Continue;
end

function onCountdownStarted()
	-- Called AFTER countdown started, if you want to stop it from starting, refer to the previous function (onStartCountdown)
end

function onCountdownTick(counter)
	-- counter = 0 -> "Three"
	-- counter = 1 -> "Two"
	-- counter = 2 -> "One"
	-- counter = 3 -> "Go!"
	-- counter = 4 -> Nothing happens lol, tho it is triggered at the same time as onSongStart i think
end

function onSpawnNote(id, data, type, isSustainNote, strumTime)
	--You can use id to get other properties from notes, for example:
	--getPropertyFromGroup('notes', id, 'texture')
end

function onSongStart()
	-- Inst and Vocals start playing, songPosition = 0
end

function onEndSong()
	-- Song ended/starting transition (Will be delayed if you're unlocking an achievement)
	-- return Function_Stop to stop the song from ending for playing a cutscene or something.
	return Function_Continue;
end


-- Substate interactions
function onPause()
	-- Called when you press Pause while not on a cutscene/etc
	-- return Function_Stop if you want to stop the player from pausing the game
	return Function_Continue;
end

function onResume()
	-- Called after the game has been resumed from a pause (WARNING: Not necessarily from the pause screen, but most likely is!!!)
end

function onGameOver()
	-- You died! Called every single frame your health is lower (or equal to) zero
	-- return Function_Stop if you want to stop the player from going into the game over screen
	return Function_Continue;
end

function onGameOverStart()
	-- Called when you have entered the game over screen and "onGameOver" wasn't stopped
end

function onGameOverConfirm(retry)
	-- Called when you Press Enter/Esc on Game Over
	-- If you've pressed Esc, value "retry" will be false
end


-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(line)
	-- triggered when the next dialogue line starts, dialogue line starts at 0 (first line), although it won't be triggered on line 0
end

function onSkipDialogue(line)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts at 0 (first line)
end


-- Key Press/Release
function onKeyPressPre(key)
	-- Called before the note key press calculations
	-- "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
end

function onKeyReleasePre(key)
	-- Called before the note key release calculations
	-- "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
end

function onKeyPress(key)
	-- Called after the note key press calculations
	-- "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
end

function onKeyRelease(key)
	-- Called after the note key release calculations
	-- "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
end

function onGhostTap(key)
	-- Player pressed a button, but there was no note to hit and "Ghost Tapping" is enabled (ghost tap)
	-- "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
end


-- Note miss/hit
---- PRE
function goodNoteHitPre(id, noteData, noteType, isSustainNote)
	-- Function called when you hit a note (***before*** note hit calculations)
	-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
	-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
	-- noteType: The note type string
	-- isSustainNote: If it's a hold note, can be either true or false
end
function opponentNoteHitPre(id, noteData, noteType, isSustainNote)
	-- Function called when the opponent hits a note (***before*** note hit calculations)
	-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
	-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
	-- noteType: The note type string
	-- isSustainNote: If it's a hold note, can be either true or false
end

---- POST
function goodNoteHit(id, noteData, noteType, isSustainNote)
	-- Function called when you hit a note (***after*** note hit calculations)
	-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
	-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
	-- noteType: The note type string
	-- isSustainNote: If it's a hold note, can be either true or false
end
function opponentNoteHit(id, noteData, noteType, isSustainNote)
	-- Function called when the opponent hits a note (***after*** note hit calculations)
	-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
	-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
	-- noteType: The note type string
	-- isSustainNote: If it's a hold note, can be either true or false
end

function noteMissPress(direction)
	-- Called after the note press miss calculations
	-- Player pressed a button, but there was no note to hit (ghost miss)
end

function noteMiss(id, direction, noteType, isSustainNote)
	-- Called after the note miss calculations
	-- Player missed a note by letting it go offscreen
end


-- Other function hooks
function preUpdateScore(miss)
	-- Called before the score text updates
	-- "miss" will be true if you missed
	-- return Function_Stop if you want to stop the score text from updating
	return Function_Continue
end

function onUpdateScore(miss)
	-- Called after the score text updates
	-- "miss" will be true if you missed
end

function onRecalculateRating()
	-- return Function_Stop if you want to do your own rating calculation,
	-- use setRatingPercent() to set the number on the calculation and setRatingString() to set the funny rating name
	-- NOTE: THIS IS CALLED BEFORE THE CALCULATION!!!
	return Function_Continue;
end

function onMoveCamera(focus)
	--Called when the camera focuses to a character

	if focus == 'boyfriend' then
		-- Called when the camera focuses on boyfriend
	elseif focus == 'dad' then
		-- Called when the camera focuses on dad
	elseif focus == 'gf' then
		-- Called when the camera focuses on girlfriend
	end
end


-- Event notes hooks
function onEvent(name, value1, value2, strumTime)
	-- Event note triggered

	-- print('Event triggered: ', name, value1, value2, strumTime);
end

function onEventPushed(name, value1, value2, strumTime)
	-- Called for every event note, recommended to precache assets
end

function eventEarlyTrigger(name, value1, value2, strumTime)
	--[[
	Here's a port of the Kill Henchmen early trigger but on Lua instead of Haxe:

	if name == 'Kill Henchmen' then
		return 280;
	end

	This makes the "Kill Henchmen" event be triggered 280 miliseconds earlier so that the kill sound is perfectly timed with the song
	]]--

	-- write your shit under this line, the new return value will override the ones hardcoded on the engine
end


-- Custom Substates
function onCustomSubstateCreate(name)
	-- "name" is defined on "openCustomSubstate(name)"
end

function onCustomSubstateCreatePost(name)
	-- "name" is defined on "openCustomSubstate(name)"
end

function onCustomSubstateUpdate(name, elapsed)
	-- "name" is defined on "openCustomSubstate(name)"
end

function onCustomSubstateUpdatePost(name, elapsed)
	-- "name" is defined on "openCustomSubstate(name)"
end

function onCustomSubstateDestroy(name)
	-- "name" is defined on "openCustomSubstate(name)"
	-- Called when you use "closeCustomSubstate()"
end


-- Tween/Timer/Sound hooks
function onTweenCompleted(tag, vars)
	-- A tween you called has been completed, value "tag" is it's tag
	-- vars = the tag of the sprite that was tweened
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- A loop from a timer you called has been completed, value "tag" is it's tag
	-- loops = how many loops it will have done when it ends completely
	-- loopsLeft = how many are remaining
end

function onSoundFinished(tag)
	-- Only called if you use playSound() with a tag
end
