import openfl.utils.Assets;
import flixel.util.FlxColor;

class Rating {
	
	public var name:String = "Sick";
	public var image(default, set):String = "Friday Night Funkin':ratings/sick";
	public var accuracy:Float = 1;
	public var health:Float = 0.1;
	public var maxDiff:Float = 35;
	public var score:Int = 350;
	public var color:FlxColor = 0xFF24DEFF;
	public var miss:Bool = false;
	public var scale:Float = 1;
	public var antialiasing:Bool = true;
	public var fcRating:String = "FC";
	public var showSplashes:Bool = false;
	public var bitmap:String = null;

	public function new() {}

	private function set_image(path:String):String {
		if (Assets.exists(path)) {
			bitmap = image = path;
			return path;
		}
		var splittedPath = path.split(":");
		if (splittedPath.length < 2) {
			bitmap = Paths.image(path);
			return path;
		}
		var mod = splittedPath[0];
		var path = splittedPath[1];
		if(mod.toLowerCase() == "yoshiengine") mod = "YoshiCrafterEngine";
		var mPath = Paths.modsPath;
		var bData = Paths.image(path, 'mods/$mod');
		if (bData != null) {
			// if (bitmap != null) bitmap.dispose();
			image = path;
			bitmap = bData;
		}
		return path;
	}
}