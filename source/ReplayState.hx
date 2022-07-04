package;

import haxe.Json;
import openfl.events.KeyboardEvent;

import sys.io.File;

using DateTools;
using StringTools;

typedef ReplayFile = {
    public var hits:Array<Float>;
    public var misses:Array<Array<Float>>;
    public var sustainHits:Array<Int>;
    public var judgements:Array<Float>;
    public var date:String;
    public var currentDifficulty:Int;
}

class ReplayState extends PlayState
{
    public var curDiff:Int;
    public var _song:String;

    public static var hits:Array<Null<Float>> = [];
    public static var miss:Array<Array<Null<Float>>> = [];
    public static var judgements:Array<Null<Float>> = [];
    public static var sustainHits:Array<Int> = [];

    public function new(curDiff:Int)
    {
        super();

        this.curDiff = curDiff;
    }

    override function create():Void
    {
        super.create();

        _song = PlayState.SONG.song.toLowerCase().replace('-', ' ');
        var file:ReplayFile = Json.parse(File.getContent(Paths.getPreloadPath('replays/$_song $curDiff.json')));

        hits = file.hits;
        miss = file.misses;
        judgements = file.judgements;
        sustainHits = file.sustainHits;

        inReplay = true;
        cpuControlled = false;

        PlayState.chartingMode = false;
        PlayState.isStoryMode = false;
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        notes.forEachAlive(function(note:Note)
        {
            if (note.mustPress && note.canBeHit && hits.contains(note.strumTime)
                && !note.isSustainNote)
            {
                if (note.strumTime <= Conductor.songPosition)
                    goodNoteHit(note);
            }

            else if (note.isSustainNote && note.mustPress
                && sustainHits[getSustain(Std.int(note.strumTime))] == Std.int(note.strumTime) && note.canBeHit)
            {
                goodNoteHit(note);
            }
        });

        botplaySine += 180 * elapsed;
        botplayTxt.text = "REPLAY";
        botplayTxt.visible = true;
        botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);

        if (miss.length > 0 && getMiss(Conductor.songPosition) > -1)
            if (miss[getMiss(Conductor.songPosition)][0] == Std.int(Conductor.songPosition))
            {
                StrumPress(Std.int(miss[getMiss(Conductor.songPosition)][1]));
                noteMissPress(Std.int(miss[getMiss(Conductor.songPosition)][1]));
            }

        keyShit();
    }


    override function onKeyPress(e:KeyboardEvent):Void
    {
        return;
    }

    override function onKeyRelease(e:KeyboardEvent):Void
    {
        return;
    }

    override function doDeathCheck(?force:Bool = false):Bool
    {
        return false;
    }

    override function keyShit():Void
    {
		var char:Character = PlayState.instance.boyfriend;
        
        if (char.holdTimer > Conductor.stepCrochet * char.singDuration * 0.001)
		{
			if (char.animation.curAnim.name.startsWith('sing') && !char.animation.curAnim.name.endsWith('miss'))
			{
				char.dance();
			}
		}
    }

    override function popUpScore(?note:Note, ?rating:Float):Void
    {
        rating = judgements[getNoteID(note.strumTime)];
        super.popUpScore(note, rating);
    }

    override function StrumPlayAnim(isDad:Bool, noteData:Int, time:Float):Void
    {
        var spr:StrumNote = null;

		if (isDad) 
			spr = strumLineNotes.members[noteData];
		else 
			spr = playerStrums.members[noteData];
		
		spr.playAnim('confirm', true);
		spr.resetAnim = 0.15;
    }

    override function StrumPress(id:Int, ?time:Float):Void
    {
		var spr:StrumNote = playerStrums.members[id];
		spr.playAnim('pressed');
		spr.resetAnim = 0.2;
    }

    override function endSong():Void
    {
        MusicBeatState.switchState(new FreeplayState());
    }

    function getNoteID(time:Float):Int
    {
        for (i in 0...hits.length)
            if (hits[i] == time)
                return i;

        return -1;
    }

    function getSustain(time:Int):Int
    {
        for (i in 0...sustainHits.length)
            if (sustainHits[i] == time)
                return i;

        return -1;
    }

    function getMiss(time:Float):Int
    {
        for (i in 0...miss.length)
            if (miss[i][0] == Std.int(time))
                return i;

        return -1;
    }

    public static function stringify(?returnString:Bool = true):Dynamic
    {
        var replayFile:ReplayFile = {
            hits: hits,
            sustainHits: sustainHits,
            misses: miss,
            judgements: judgements,
            date: DateTools.format(Date.now(), "%Y/%m/%d %H:%M:%S"),
            currentDifficulty: PlayState.storyDifficulty
        };

        return if (returnString) Json.stringify(replayFile, "\t") else replayFile;
    }
}

class ReplayPauseSubstate extends PauseSubState
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        menuItemsOG = ['Resume', 'Restart Replay', 'Exit to menu'];
        menuItems = menuItemsOG;
        regenMenu();
    }
}