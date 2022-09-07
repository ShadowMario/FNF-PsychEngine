package;

import flixel.math.FlxMath;
import flixel.FlxG;
import Section.SwagSection;
import sys.FileSystem;
import Note.EventNote;
import flixel.util.FlxStringUtil;
import Song.SwagSong;

using StringTools;

class ChartParser
{
	/**
	 * base game chart parsing;
	 * used with the current chart format that we have (from 0.2.8);
	 * @return an array full of notes from your chart data
	 */
	public static function parseSongChart(songData:SwagSong):Array<Note>
	{
		var noteData:Array<SwagSection>;
		var unspawnNotes:Array<Note> = [];

		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(PlayState.instance.songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				/**
				 * "oh but you could just make the noteTypeMap static!"
				 * I could, but this breaks notetype pushing as a whole
				 * meaning that the game *will crash* if this is done twice
				**/
				if(!PlayState.instance.noteTypeMap.exists(swagNote.noteType)) {
					PlayState.instance.noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}

		return unspawnNotes;
	}

	/**
	 * I don't know why would you want to keep this but just in case ehhh;
	 * this is for Ludum Dare Prototype Charts;
	 * -gabi
	 */
	public static function parseLudumChart(songName:String, section:Int):Array<Dynamic>
	{
		var IMG_WIDTH:Int = 8;
		var regex:EReg = new EReg("[ \t]*((\r\n)|\r|\n)[ \t]*", "g");

		var csvData = FlxStringUtil.imageToCSV(Paths.file('data/' + songName + '/' + songName + '_section' + section + '.png'));

		var lines:Array<String> = regex.split(csvData);
		var rows:Array<String> = lines.filter(function(line) return line != "");
		csvData.replace("\n", ',');

		var heightInTiles = rows.length;
		var widthInTiles = 0;

		var row:Int = 0;

		// LMAOOOO STOLE ALL THIS FROM FLXBASETILEMAP LOLOL

		var dopeArray:Array<Int> = [];
		while (row < heightInTiles)
		{
			var rowString = rows[row];
			if (rowString.endsWith(","))
				rowString = rowString.substr(0, rowString.length - 1);
			var columns = rowString.split(",");

			if (columns.length == 0)
			{
				heightInTiles--;
				continue;
			}
			if (widthInTiles == 0)
			{
				widthInTiles = columns.length;
			}

			var column = 0;
			var pushedInColumn:Bool = false;
			while (column < widthInTiles)
			{
				// the current tile to be added:
				var columnString = columns[column];
				var curTile = Std.parseInt(columnString);

				if (curTile == null)
					throw 'String in row $row, column $column is not a valid integer: "$columnString"';

				if (curTile == 1)
				{
					if (column < 4)
						dopeArray.push(column + 1);
					else
					{
						var tempCol = (column + 1) * -1;
						tempCol += 4;
						dopeArray.push(tempCol);
					}

					pushedInColumn = true;
				}

				column++;
			}

			if (!pushedInColumn)
				dopeArray.push(0);

			row++;
		}
		return dopeArray;
	}
}
