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
	var bpm:Int;
}

class Conductor
{

	/**
	 * Current song BPM
	 */
	public static var bpm:Int = 100;
	/**
		* Beat length in milliseconds
	*/
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	/**
		* Step length in milliseconds
	*/
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	

	/**
	 * Song position in milliseconds
	 */
	public static var songPosition:Float;
	public static var songPositionOld:Float;

	public static var lastKeyShitTimeStamp:Null<Float> = null;

	/**
	 * Last song position in milliseconds
	 */
	public static var lastSongPos:Float;
	

	/**
	 * Song offset
	 */
	public static var offset:Float = 0;

	

	/**
	 * Safe frames
	 */
	public static var safeFrames:Int = 11;
	

	/**
	 * "is calculated in create() is safeFrames in milliseconds"
	 */
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	

	/**
	 * BPM change map
	 */
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new()
	{
	}


	/**
	 * Maps the BPM changes
	 */
	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		if (song == null) return;
		if (song.notes == null) return;
		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i] == null) continue;
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

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}


	/**
	 * Changes the song's BPM
	 */
	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
