package backend;

import sys.FileSystem;
import sys.io.File;
import tjson.TJSON as Json;

typedef ModsList = {
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
};

class Mods
{
	static public var currentModDirectory:String = '';
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];

	private static var globalMods:Array<String> = [];

	inline public static function getGlobalMods()
		return globalMods;

	inline public static function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		for(mod in parseList().enabled)
		{
			var pack:Dynamic = getPack(mod);
			if(pack != null && pack.runsGlobally) globalMods.push(mod);
		}
		return globalMods;
	}

	inline public static function getModDirectories():Array<String>
	{
		var list:Array<String> = [];
		var modsFolder:String = Paths.mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder))
			{
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder.toLowerCase()) && !list.contains(folder))
					list.push(folder);
			}
		}
		return list;
	}

	inline public static function getFoldersList(path:String, fileToFind:String, mods:Bool = true)
	{
		var foldersToCheck:Array<String> = [];
		if(FileSystem.exists(path + fileToFind)) foldersToCheck.push(path + fileToFind);

		#if MODS_ALLOWED
		if(mods)
		{
			// Global mods first
			for(mod in Mods.getGlobalMods())
			{
				var folder:String = Paths.mods(mod + '/' + fileToFind);
				if(FileSystem.exists(folder)) foldersToCheck.insert(0, folder);
			}

			// Then "PsychEngine/mods/" main folder
			var folder:String = Paths.mods(fileToFind);
			if(FileSystem.exists(folder)) foldersToCheck.insert(0, Paths.mods(fileToFind));

			// And lastly, the loaded mod's folder
			if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			{
				var folder:String = Paths.mods(Mods.currentModDirectory + '/' + fileToFind);
				if(FileSystem.exists(folder)) foldersToCheck.insert(0, folder);
			}
		}
		#end
		return foldersToCheck;
	}

	public static function getPack(?folder:String = null):Dynamic
	{
		if(folder == null) folder = Mods.currentModDirectory;

		var path = Paths.mods(folder + '/pack.json');
		if(FileSystem.exists(path)) {
			try {
				var rawJson:String = File.getContent(path);
				if(rawJson != null && rawJson.length > 0) return Json.parse(rawJson);
			} catch(e:Dynamic) {
				trace(e);
			}
		}
		return null;
	}

	public static var updatedOnState:Bool = false;
	inline public static function parseList():ModsList {
		if(!updatedOnState) updateModList();
		var list:ModsList = {enabled: [], disabled: [], all: []};

		try {
			for (mod in CoolUtil.coolTextFile('modsList.txt'))
			{
				//trace('Mod: $mod');
				var dat = mod.split("|");
				list.all.push(dat[0]);
				if (dat[1] == "1")
					list.enabled.push(dat[0]);
				else
					list.disabled.push(dat[0]);
			}
		} catch(e) {
			trace(e);
		}
		return list;
	}
	
	private static function updateModList()
	{
		// Find all that are already ordered
		var list:Array<Array<Dynamic>> = [];
		var added:Array<String> = [];
		try {
			for (mod in CoolUtil.coolTextFile('modsList.txt'))
			{
				var dat:Array<String> = mod.split("|");
				var folder:String = dat[0];
				if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) && !added.contains(folder))
				{
					added.push(folder);
					list.push([folder, (dat[1] == "1")]);
				}
			}
		} catch(e) {
			trace(e);
		}
		
		// Scan for folders that aren't on modsList.txt yet
		for (folder in getModDirectories())
		{
			if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) &&
			!ignoreModFolders.contains(folder.toLowerCase()) && !added.contains(folder))
			{
				added.push(folder);
				list.push([folder, true]); //i like it false by default. -bb //Well, i like it True! -Shadow Mario (2022)
				//Shadow Mario (2023): What the fuck was bb thinking
			}
		}

		// Now save file
		var fileStr:String = '';
		for (values in list)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0');
		}
		//trace(fileStr);

		File.saveContent('modsList.txt', fileStr);
		updatedOnState = true;
		//trace('Saved modsList.txt');
	}

	public static function loadTopMod()
	{
		Mods.currentModDirectory = '';
		
		#if MODS_ALLOWED
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			Mods.currentModDirectory = list[0];
		#end
	}
}