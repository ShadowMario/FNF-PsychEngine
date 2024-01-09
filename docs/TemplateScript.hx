// HScript stuff

function onCreate()
{
	// triggered when the hscript file is started, some variables weren't created yet
}

function onCreatePost()
{
	// end of "create"
}

function onDestroy()
{
	// triggered when the haxe file is ended (Song fade out finished)
}


// Gameplay/Song interactions
function onSectionHit()
{
	// triggered after it goes to the next section
}

function onBeatHit()
{
	// triggered 4 times per section
}

function onStepHit()
{
	// triggered 16 times per section
}

function onUpdate(elapsed:Float)
{
	// start of "update", some variables weren't updated yet
}

function onUpdatePost(elapsed:Float)
{
	// end of "update"
}

function onStartCountdown()
{
	// countdown started, duh
	// return Function_Stop if you want to stop the countdown from happening (Can be used to trigger dialogues and stuff! You can trigger the countdown with startCountdown())
	return Function_Continue;
}

function onCountdownStarted()
{
	// called AFTER countdown started, if you want to stop it from starting, refer to the previous function (onStartCountdown)
}

function onCountdownTick(tick:Countdown, counter:Int)
{
	switch(tick)
	{
		case Countdown.THREE:
			//counter equals to 0
		case Countdown.TWO:
			//counter equals to 1
		case Countdown.ONE:
			//counter equals to 2
		case Countdown.GO:
			//counter equals to 3
		case Countdown.START:
			//counter equals to 4, this has no visual indication or anything, it's pretty much at nearly the exact time the song starts playing
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
	// song ended/starting transition (Will be delayed if you're unlocking an achievement)
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

function onGameOverConfirm(retry:Bool)
{
	// Called when you Press Enter/Esc on Game Over
	// If you've pressed Esc, value "retry" will be false
}


// Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(line:Int)
{
	// triggered when the next dialogue line starts, dialogue line starts with 1
}

function onSkipDialogue(line:Int)
{
	// triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
}


// Key Press/Release
function onKeyPress(key:Int)
{
	// key can be: 0 - left, 1 - down, 2 - up, 3 - right
}

function onKeyRelease(key:Int)
{
	// key can be: 0 - left, 1 - down, 2 - up, 3 - right
}

function onGhostTap(key:Int)
{
	// key can be: 0 - left, 1 - down, 2 - up, 3 - right
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
function onRecalculateRating()
{
	// return Function_Stop if you want to do your own rating calculation,
	// use setRatingPercent() to set the number on the calculation and setRatingString() to set the funny rating name
	// NOTE: THIS IS CALLED BEFORE THE CALCULATION!!!
	return Function_Continue;
}

function onMoveCamera(focus:String)
{
	if (focus == 'boyfriend')
	{
		// called when the camera focus on boyfriend
	}
	else if (focus == 'dad')
	{
		// called when the camera focus on dad
	}
}


// Event notes hooks
function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
	// event note triggered
	// triggerEvent() does not call this function!!

	// print('Event triggered: ', name, value1, value2, strumTime);
}

function onEventPushed(name:String, value1:String, value2:String, strumTime:Float)
{
	// Called for every event note, recommended to precache assets
}

function eventEarlyTrigger(name:String)
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
	// name is defined on "openCustomSubstate(name)"
}

function onCustomSubstateCreatePost(name:String)
{
	// name is defined on "openCustomSubstate(name)"
}

function onCustomSubstateUpdate(name:String, elapsed:Float)
{
	// name is defined on "openCustomSubstate(name)"
}

function onCustomSubstateUpdatePost(name:String, elapsed:Float)
{
	// name is defined on "openCustomSubstate(name)"
}

function onCustomSubstateDestroy(name:String)
{
	// name is defined on "openCustomSubstate(name)"
	// called when you use "closeCustomSubstate()"
}
