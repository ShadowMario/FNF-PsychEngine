package;

import SongEvent;
import sys.io.File;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var events:Array<SongEvent>;
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	var keyNumber:Null<Int>;
	var noteTypes:Array<String>;

	@:optional var sectionLength:Null<Int>;
	@:optional var scripts:Array<String>;
	@:optional var gfVersion:String;
	@:optional var noGF:Bool;
	@:optional var noBF:Bool;
	@:optional var noDad:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var keyNumber:Int = 4;
	public var noteTypes:Array<String> = ["Friday Night Funkin':Default Note"];

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}
	
	public static function loadModFromJson(jsonInput:String, mod:String, ?folder:String):SwagSong
	{
		var rawJson = "";
		var path = "";
		if (folder == null)
			path = Paths.json('$jsonInput/$jsonInput', 'mods/$mod');
		else
			path = Paths.json('$folder/$jsonInput', 'mods/$mod');

		if (Assets.exists(path)) {
			rawJson = Assets.getText(path);
		} else {
			throw "Chart doesn't exist.";
			return null;
		}
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
