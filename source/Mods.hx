import flixel.util.FlxColor;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.Json;

// Represent information about a mod
class ModInfo {
    // The directory in which the mod is store. May be absolute or relative
    public var folder:String;
    // The name of the last directory that contain the mod
    public var dirName:String;
    // The name of the mod itself, as displayer in the UI
	public var name:String;
	public var description:String;
	public var color:FlxColor;
	public var restart:Bool; //trust me. this is very important
    
    public function new(folder: String) {
        this.folder = folder;
        this.dirName = Path.withoutDirectory(Path.removeTrailingSlashes(folder));
        this.loadPackInfo();
    }

    public function loadPackInfo() {
        this.name = this.dirName;
		this.description = "No description provided.";
		this.color = ModsMenuState.defaultColor;
		this.restart = false;
        
        //Try loading json
		var path = this.folder + '/pack.json';
		if(FileSystem.exists(path)) {
			var rawJson:String = File.getContent(path);
			if(rawJson != null && rawJson.length > 0) {
				var parsedJson:Dynamic = Json.parse(rawJson);
                var colors:Null<Array<Dynamic>> = cast(parsedJson.colors, Null<Array<Dynamic>>);
                var description:Null<String> = cast(parsedJson.description, Null<String>);
                var name:Null<String> = cast(parsedJson.name, Null<String>);
                var restart:Null<Bool> = cast(parsedJson.restart, Null<Bool>);
				
				// default value is "Name", and some people forget (or just don’t have to) change it
				if (name != null && name.length > 0 && name != "Name")
				{
					this.name = name;
				}
				// same, except default is "Description"
				if (description != null && description.length > 0 && description != "Description")
				{
					this.description = description;
				}
				if (colors != null && colors.length > 2)
				{
                    var colorsTyped:Array<Int> = [for (c in colors) cast(c, Int)];
					this.color = FlxColor.fromRGB(colorsTyped[0], colorsTyped[1], colorsTyped[2]);
				}
                if (restart != null) {
				    this.restart = restart;
                }
			}
		}
    }
}