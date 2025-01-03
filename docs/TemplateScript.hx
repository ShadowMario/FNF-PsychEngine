// HScript stuff

function onCreate()
{
	// Triggered when the hscript file is started, some variables weren't created yet
}

function onCreatePost()
{
	// End of "create"
}

function onDestroy()
{
	// Triggered when the hscript file is ended
}


// Gameplay/Song interactions
function onSectionHit()
{
	// Triggered after it goes to the next section
}

function onBeatHit()
{
	// Triggered 4 times per section
}

function onStepHit()
{
	// Triggered 16 times per section
}

function onUpdate(elapsed:Float)
{
	// Start of "update", some variables weren't updated yet
	// Also gets called while in the game over screen
}

function onUpdatePost(elapsed:Float)
{
	// End of "update"
	// Also gets called while in the game over screen
}

function onStartCountdown()
{
	// Countdown started, duh
	// return Function_Stop if you want to stop the countdown from happening (Can be used to trigger dialogues and stuff! You can trigger the countdown with startCountdown())
	return Function_Continue;
}

function onCountdownStarted()
{
	// Called AFTER countdown started, if you want to stop it from starting, refer to the previous function (onStartCountdown)
}

function onCountdownTick(tick:Countdown, counter:Int)
{
	switch(tick)
	{
		case Countdown.THREE:
			//Counter equals to 0
		case Countdown.TWO:
			//Counter equals to 1
		case Countdown.ONE:
			//Counter equals to 2
		case Countdown.GO:
			//Counter equals to 3
		case Countdown.START:
			//Counter equals to 4, this has no visual indication or anything, it's pretty much at nearly the exact time the song starts playing
	}
}

function onSpawnNote(note:Note)
{
	// Read the function name and you will understand what it does
}

function onSongStart()
{
	// Inst and Vocals start playing, songPosition = 0
}

function onEndSong()
{
	// Song ended/starting transition (Will be delayed if you're unlocking an achievement)
	// return Function_Stop to stop the song from ending for playing a cutscene or something.
	return Function_Continue;
}


// Substate interactions
function onPause()
{
	// Called when you press Pause while not on a cutscene/etc
	// return Function_Stop if you want to stop the player from pausing the game
	return Function_Continue;
}

function onResume()
{
	// Called after the game has been resumed from a pause (WARNING: Not necessarily from the pause screen, but most likely is!!!)
}

function onGameOver()
{
	// You died! Called every single frame your health is lower (or equal to) zero
	// return Function_Stop if you want to stop the player from going into the game over screen
	return Function_Continue;
}

function onGameOverStart()
{
	// Called when you have entered the game over screen and "onGameOver" wasn't stopped
}

function onGameOverConfirm(retry:Bool)
{
	// Called when you Press Enter/Esc on Game Over
	// If you've pressed Esc, value "retry" will be false
}


// Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(line:Int)
{
	// Triggered when the next dialogue line starts, dialogue line starts at 0 (first line), although it won't be triggered on line 0
}

function onSkipDialogue(line:Int)
{
	// Triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts at 0 (first line)
}


// Key Press/Release
function onKeyPressPre(key:Int)
{
	// Called before the note key press calculations
	// "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
}

function onKeyReleasePre(key:Int)
{
	// Called before the note key release calculations
	// "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
}

function onKeyPress(key:Int)
{
	// Called after the note key press calculations
	// "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
}

function onKeyRelease(key:Int)
{
	// Called after the note key release calculations
	// "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
}

function onGhostTap(key:Int)
{
	// Player pressed a button, but there was no note to hit and "Ghost Tapping" is enabled (ghost tap)
	// "key" can be: 0 - left, 1 - down, 2 - up, 3 - right
}


// Note miss/hit
function goodNoteHitPre(note:Note)
{
	// Function called when you hit a note (***before*** note hit calculations)
}
function opponentNoteHitPre(note:Note)
{
	// Works the same as goodNoteHitPre, but for Opponent's notes being hit
}

function goodNoteHit(note:Note)
{
	// Function called when you hit a note (***after*** note hit calculations)
}
function opponentNoteHit(note:Note)
{
	// Works the same as goodNoteHit, but for Opponent's notes being hit
}

function noteMissPress(direction:Int)
{
	// Called after the note press miss calculations
	// Player pressed a button, but there was no note to hit (ghost miss)
}

function noteMiss(note:Note)
{
	// Called after the note miss calculations
	// Player missed a note by letting it go offscreen
}


// Other function hooks
function preUpdateScore(miss:Bool)
{
	// Called before the score text updates
	// "miss" will be true if you missed
	// return Function_Stop if you want to stop the score text from updating
	return Function_Continue;
}

function onUpdateScore(miss:Bool)
{
	// Called after the score text updates
	// "miss" will be true if you missed
}

function onRecalculateRating()
{
	// return Function_Stop if you want to do your own rating calculation,
	// use setRatingPercent() to set the number on the calculation and setRatingString() to set the funny rating name
	// NOTE: THIS IS CALLED BEFORE THE CALCULATION!!!
	return Function_Continue;
}

function onMoveCamera(focus:String)
{
	// Called when the camera focuses to a character

	if (focus == 'boyfriend')
	{
		// Called when the camera focuses on boyfriend
	}
	else if (focus == 'dad')
	{
		// Called when the camera focuses on dad
	}
	else if (focus == 'gf')
	{
		// Called when the camera focuses on girlfriend
	}
}


// Event notes hooks
function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
	// Event note triggered

	// print('Event triggered: ', name, value1, value2, strumTime);
}

function onEventPushed(name:String, value1:String, value2:String, strumTime:Float)
{
	// Called for every event note, recommended to precache assets
}

function eventEarlyTrigger(name:String, value1:String, value2:String, strumTime:Float)
{
	/*
	Here's a port of the Kill Henchmen early trigger:

	if (name == 'Kill Henchmen')
		return 280;

	This makes the "Kill Henchmen" event be triggered 280 miliseconds earlier so that the kill sound is perfectly timed with the song
	*/

	// write your shit under this line, the new return value will override the ones hardcoded on the engine
}


// Custom Substates
function onCustomSubstateCreate(name:String)
{
	// "name" is defined on "openCustomSubstate(name)"
}

function onCustomSubstateCreatePost(name:String)
{
	// "name" is defined on "openCustomSubstate(name)"
}

function onCustomSubstateUpdate(name:String, elapsed:Float)
{
	// "name" is defined on "openCustomSubstate(name)"
}

function onCustomSubstateUpdatePost(name:String, elapsed:Float)
{
	// "name" is defined on "openCustomSubstate(name)"
}

function onCustomSubstateDestroy(name:String)
{
	// "name" is defined on "openCustomSubstate(name)"
	// Called when you use "closeCustomSubstate()"
}
