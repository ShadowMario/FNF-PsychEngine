package;

import sys.io.File;
import sys.FileSystem;

/*  File Tracer made by Sirox  */

class FT {
	
	public static function trace(thing:Dynamic, var_name:String) {
		var dateNow:String = Date.now().toString();
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");
		var fp:String = SUtil.getPath() + "logs/" + "log_" + dateNow + ".txt";
		
		if (!FileSystem.exists(SUtil.getPath() + "logs/")) {
			FileSystem.createDirectory(SUtil.getPath() + "logs/");
		}
		
		var thingToSave:String = forceToString(thing);

		File.saveContent(fp, var_name + " = " + thingToSave + "\n");
		Application.current.window.alert(var_name + " = " + thingToSave, "Trace");
		Sys.exit(1);
	}
	
	public static function forceToString(shit:Dynamic):String {
		var result:String = '';
		if (!Std.isOfType(shit, String)) {
			result = Std.string(shit);
		} else {
			result = shit;
		}
		return result;
	}
}
