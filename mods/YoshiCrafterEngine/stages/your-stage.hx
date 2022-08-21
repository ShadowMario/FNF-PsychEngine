var stage:Stage = null;
EngineSettings.middleScroll = true;
EngineSettings.maxRatingsAllowed = 0;

function create() {
	stage = loadStage('your-stage');

}

function postCreate() {

	PlayState.boyfriend.playAnim('walk');

    PlayState.autoCamZooming = false;
    PlayState.camZooming = false;

}

function regenerateNotes() {
  var notesToKeep:Array<Note> = [];
  for(e in PlayState.unspawnNotes) {
    if (!e.isSustainNote) {
      notesToKeep.push(e);
      e.strumTime = e.strumTime - (Conductor.crochet * 68) + (Conductor.crochet * 20);
    }
  }
  notesToKeep.sort(PlayState.sortByShit);
  PlayState.unspawnNotes = notesToKeep;
  for (section in PlayState.song.notes)
		{
			if (section == null) continue;

			for (songNotes in section.sectionNotes)
			{
				if (songNotes[0] < PlayState.startTime && PlayState.startTime > 0) continue;
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] % (PlayState.song.keyNumber * 2) >= PlayState.song.keyNumber)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (PlayState.unspawnNotes.length > 0)
					oldNote = PlayState.unspawnNotes[Std.int(PlayState.unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote, section.altAnim);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				var prevSusNote = swagNote;
				// if (!EngineSettings.downscroll) unspawnNotes.push(swagNote);

				// naaaaah i'm not adding this in
				// for (susNote in 0...Math.floor(susLength > 0 ? susLength + 1 : susLength))
				if (swagNote.strumTime > Conductor.crochet * 24) PlayState.unspawnNotes.push(swagNote);
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = PlayState.unspawnNotes[Std.int(PlayState.unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * (susNote)), daNoteData, oldNote, true, gottaHitNote, section.altAnim);
					sustainNote.scrollFactor.set();
					sustainNote.noteOffset.y -= Note.swagWidth / 2;
					sustainNote.alpha *= (EngineSettings.transparentSubstains) ? 0.6 : 1;
					sustainNote.prevSusNote = prevSusNote;
					PlayState.unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += PlayState.guiSize.x / 2; // general offset
					}

					prevSusNote = sustainNote;
				}

				// if (EngineSettings.downscroll) ;

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += PlayState.guiSize.x / 2; // general offset
				}
				else {}

				
			}
		}
}


function postUpdate(elapsed) {
  // loop start = 20th beat
  // loop end = 68th beat

  if (Conductor.songPosition > Conductor.crochet * 68) {
    Conductor.songPosition = Conductor.songPosition - (Conductor.crochet * 68) + (Conductor.crochet * 20);
    FlxG.sound.music.time = PlayState.vocals.time = Conductor.songPosition;
    PlayState.boyfriend.lastHit = PlayState.boyfriend.lastHit - (Conductor.crochet * 68) + (Conductor.crochet * 20);
    regenerateNotes();
  }
}
function update(elapsed) {
	stage.update(elapsed);


	
    PlayState.timerBG.visible = false;
    PlayState.timerBar.visible = false;
    PlayState.timerText.visible = false;
    PlayState.timerNow.visible = false;
    PlayState.timerFinal.visible = false;
    PlayState.iconP1.visible = false;
    PlayState.iconP2.visible = false;
    PlayState.scoreWarning.visible = false;
    PlayState.healthBar.visible = false;
    PlayState.healthBarBG.visible = false;
    PlayState.scoreTxt.visible = false;

	PlayState.camFollow.setPosition(640, 320);
	PlayState.defaultCamZoom = 1;
	

    if (PlayState.section != null && PlayState.section.mustHitSection) {
        PlayState.camFollow.setPosition(640, 320);
    }
      else {
        PlayState.camFollow.setPosition(640, 320);
	}

	  PlayState.boyfriend.x = 640;
	  PlayState.boyfriend.y = 320;

	}

function stepHit(curStep:Int) {

}

function beatHit(curBeat) {
	stage.onBeat();

	if (curBeat = 116){
	PlayState.boyfriend.playAnim('walk');
	}
}