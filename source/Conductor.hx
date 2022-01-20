package;

import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

typedef SignatureChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var numerator:Int;
	var denominator:Int;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;
	public static var numerator:Int = 4;
	public static var denominator:Int = 4;

	//public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (ClientPrefs.safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var signatureChangeMap:Array<SignatureChangeEvent> = [];

	public function new()
	{
	}

	public static function judgeNote(note:Note, diff:Float=0) //STOLEN FROM KADE ENGINE (bbpanzu) - I had to rewrite it later anyway after i added the custom hit windows lmao (Shadow Mario)
	{
		//tryna do MS based judgment due to popular demand
		var timingWindows:Array<Int> = [ClientPrefs.sickWindow, ClientPrefs.goodWindow, ClientPrefs.badWindow];
		var windowNames:Array<String> = ['sick', 'good', 'bad'];

		// var diff = Math.abs(note.strumTime - Conductor.songPosition) / (PlayState.songMultiplier >= 1 ? PlayState.songMultiplier : 1);
		for(i in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
		{
			if (diff <= timingWindows[Math.round(Math.min(i, timingWindows.length - 1))])
			{
				return windowNames[i];
			}
		}
		return 'shit';
	}
	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];
		signatureChangeMap = [];

		var curBPM:Float = song.bpm;
		var curNumerator:Int = song.numerator;
		var curDenominator:Int = song.denominator;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}
			if(song.notes[i].changeSignature && (song.notes[i].numerator != curNumerator || song.notes[i].denominator != curDenominator))
			{
				curNumerator = song.notes[i].numerator;
				curDenominator = song.notes[i].denominator;
				var event:SignatureChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					numerator: curNumerator,
					denominator: curDenominator
				};
				signatureChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((((60 / curBPM) * 4000) / curDenominator) / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
		trace("new signature map BUDDY " + signatureChangeMap);
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 4000) / denominator;
		stepCrochet = crochet / 4;
	}

	public static function changeSignature(newNumerator:Int, newDenominator:Int)
	{
		numerator = newNumerator;
		denominator = newDenominator;
		
		crochet = ((60 / bpm) * 4000) / denominator;
		stepCrochet = crochet / 4;
	}
}
