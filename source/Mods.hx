import flixel.util.FlxColor;
import haxe.io.Path;
import haxe.Json;
import lime.system.System.applicationStorageDirectory;
#if sys
import sys.io.File;
#end

// Represent information about a mod
class ModInfo {
    // The directory in which the mod is store. May be absolute or relative
    public var folder:String;
    // The name of the last directory that contain the mod
	//TODO:marius: remove when there is no use for it anymore
    public var dirName:String;
    // The name of the mod itself, as displayer in the UI
	public var name:String;
	public var description:String;
	public var color:FlxColor;
	public var restart:Bool; //trust me. this is very important
	public var global:Bool;
	public var isGameAssets: Bool = false;

	// if folder is "assets", load the assets data instead of a standard mod with pack.json
    public function new(folder: String) {
		this.folder = folder;
		if (folder == "assets") {
			this.isGameAssets = true;
			this.dirName = '';
			this.name = "Psych Engine";
			this.description = "The assets of Psych Engine. This mod (and description) shouldn’t appear in any visible mod list.";
			this.color = 0xFF665AFF;
			this.restart = false;
			this.global = true;
		} else {
			#if MODS_ALLOWED
        	this.dirName = Path.withoutDirectory(Path.removeTrailingSlashes(folder));
        	this.loadPackInfo();
			#else
			throw "The game tried to load a mod at " + folder + " but mod loading is statically disabled!!!";
			#end
		}
    }

	#if MODS_ALLOWED
    public function loadPackInfo() {
        this.name = this.dirName;
		this.description = "No description provided.";
		this.color = ModsMenuState.defaultColor;
		this.restart = false;
		this.global = false;
        
        //Try loading json
		var path = Path.join([this.folder, 'pack.json']);
		if(Paths.universalFileExists(path)) {
			var rawJson:String = Paths.universalGetText(path);
			if(rawJson != null && rawJson.length > 0) {
				var parsedJson:Dynamic = Json.parse(rawJson);
                var colors:Null<Array<Dynamic>> = cast(parsedJson.colors, Null<Array<Dynamic>>);
                var description:Null<String> = cast(parsedJson.description, Null<String>);
                var name:Null<String> = cast(parsedJson.name, Null<String>);
                var restart:Null<Bool> = cast(parsedJson.restart, Null<Bool>);
				var global:Null<Bool> = cast(parsedJson.runsGlobally, Null<Bool>);
				
				// default value is "Name", and some people forget (or just don’t have to) change it
				if (name != null && name.length > 0 && name != "Name") {
					this.name = name;
				}
				// same, except default is "Description"
				if (description != null && description.length > 0 && description != "Description") {
					this.description = description;
				}
				if (colors != null && colors.length > 2) {
                    var colorsTyped:Array<Int> = [for (c in colors) cast(c, Int)];
					this.color = FlxColor.fromRGB(colorsTyped[0], colorsTyped[1], colorsTyped[2]);
				}
                if (restart != null) {
				    this.restart = restart;
                }
				if (global != null) {
					this.global = global;
				}
			}
		}
    }
	#end
	
	// put as a dedicate function if we want to later add the option to enable a mod without side effect.
	// Will probably need a double-check that everything that should use this or globalActiveMods
	public function useAsGlobal(): Bool {
		return this.global;
	}
}

#if MODS_ALLOWED
class ModsListEntry {
	public var dirName: String;
	// True to not load the mods at all (including its weeks)
	public var disabled: Bool;

	public function new(dirName: String, disabled: Bool) {
		this.dirName = dirName;
		this.disabled = disabled;
	}
}
#end

// A directory containing mods, and the related modsList.txt info, if it exist
// There are up to two modsList the game will interact with: The one in the game folder, and the one in the user folder
// The one in the game folder will be used if there is already a modsList.txt here, otherwise, it will use the one the user folder
class ModsList {
	#if MODS_ALLOWED
	public var folder: String;
	public var modsListPath: String;
	public var values: Array<ModsListEntry>;
	#end
	// Keep these arrays even if mods are disabled. Game assets are also handled as mods for simplicity purpose.

	#if MODS_ALLOWED
	// Active mods excluding the game assets
	public static var activeModsNoAssets: Array<ModInfo>;
	#end

	// Mods that should be considered as active, with stuff being displayed in lists.
	public static var activeMods: Array<ModInfo>;
	// Global mods, which can perform changes everywhere, instead of just adding new stuff in lists.
	public static var globalActiveMods: Array<ModInfo>;
	// The currenctly active mod, if any. Equivalent to currentModDirectory with ModInfo.
	// May contain the game assets pseudo-mod when using content from it
	public static var currentMod: Null<ModInfo>;

	#if MODS_ALLOWED
	public function new(folder: String, modsListPath: String, ?skipLoad: Bool) {
		this.folder = folder;
		this.modsListPath = modsListPath;
		if (!skipLoad) {
			this.load();
		} else {
			this.values = [];
		}
	}

	public function load() {
		this.values = [];
		var modsDirectoryList = Paths.getSubdirectories(this.folder);

		// Load mods in modsList.txt which have an existing folder (ignore them otherwise)
		if (Paths.universalFileExists(this.modsListPath)) {
			var lines:Array<String> = CoolUtil.coolTextFile(this.modsListPath);
			for (line in lines) {
				var modSplit:Array<String> = line.split('|');
				if (modSplit.length >= 2) {
					//TODO:marius: is this ignoreModsFolders usefull? A mod won’t be in the list unless it is manually added.
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && modSplit[0] != "" && modsDirectoryList.contains(modSplit[0])) {	
						var disabled:Bool = false;
						if(modSplit[1] == '0')
							disabled = true;
						this.values.push(new ModsListEntry(modSplit[0], disabled));
					}
				}
			}
		}

		// load mods not in modsList.txt
		for (modDirName in modsDirectoryList) {
			if (!Paths.ignoreModFolders.contains(modDirName)) {
				if (!Lambda.exists(this.values, function(info) return info.dirName == modDirName)) {
					this.values.push(new ModsListEntry(modDirName, false));
				}
			}
		}
	}

	#if sys
	public function save() {
		var fileStr:String = '';
		for (modEntry in this.values)
		{
			if (fileStr.length > 0) fileStr += '\n';
			fileStr += modEntry.dirName + '|' + (modEntry.disabled ? '0' : '1');
		}
		File.saveContent(this.modsListPath, fileStr);
	}
	#end

	public function getLoadedMods(): Array<ModInfo> {
		var result: Array<ModInfo> = [];
		for (modEntry in this.values) {
			if (!modEntry.disabled) {
				result.push(new ModInfo(Path.join([this.folder, modEntry.dirName])));
			}
		}
		return result;
	}

	static public function loadDefaultModsList(?skipLoad: Bool): ModsList {
		//TODO:marius: temporary, until everything is switched to use this function.
		//TODO:marius: make sure it also checks if mods are installed, even if there is no modsList.txt
		//if (Paths.universalFileExists("modsList.txt")) {
		return new ModsList("mods", "modsList.txt", skipLoad);
		/*} else {
			//TODO:marius: make sure this end up being an appropriate directory. End up being ~/.local/share/ShadowMario/PsychEngine on Linux.
			return new ModsList(Path.join([applicationStorageDirectory, "mods/"]), Path.join([applicationStorageDirectory, "modsList.txt"]), skipLoad);
		}*/
	}
	#end

	// Return a list with the current loaded mod if it exist, and then all the global mods (include Psych Engine’s data)
	static public function getCurrentThenGlobalMods() {
		if (ModsList.currentMod == null) {
			return ModsList.globalActiveMods;
		} else {
			return [ModsList.currentMod].concat(ModsList.globalActiveMods);
		}
	}

	static public function loadActiveMods() {
		#if MODS_ALLOWED
		ModsList.activeModsNoAssets = ModsList.loadDefaultModsList().getLoadedMods();
		ModsList.activeMods = ModsList.activeModsNoAssets.copy();
		#else
		ModsList.activeMods = [];
		#end
		ModsList.activeMods.push(new ModInfo("assets"));
		ModsList.globalActiveMods = ModsList.activeMods.filter(function (modinfo) return modinfo.useAsGlobal());
	}
}