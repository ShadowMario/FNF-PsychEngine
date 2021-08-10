package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxSprite;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
import openfl.display.BitmapData;
#end

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	#if MODS_ALLOWED
		#if (haxe >= "4.0.0")
		public static var customImagesLoaded:Map<String, BitmapData> = new Map();
		#else
		public static var customImagesLoaded:Map<String, BitmapData> = new Map<String, openfl.display.BitmapData>();
		#end
	#end
	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, currentLevel + '_high');
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		if(FileSystem.exists(modsImages(key))) {
			if(!customImagesLoaded.exists(key)) {
				customImagesLoaded.set(key, BitmapData.fromFile(modsImages(key)));
			}
			return customImagesLoaded.get(key);
		}
		#end
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		if(OpenFlAssets.exists(Paths.getPath(key, type))) {
			return true;
		}

		#if MODS_ALLOWED
		if(FileSystem.exists(mods(key))) {
			return true;
		}
		#end
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:BitmapData = null;
		if(FileSystem.exists(modsImages(key))) {
			if(!customImagesLoaded.exists(key)) {
				customImagesLoaded.set(key, BitmapData.fromFile(modsImages(key)));
			}
			imageLoaded = customImagesLoaded.get(key);
		}
		
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key))) {
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:BitmapData = null;
		if(FileSystem.exists(modsImages(key))) {
			if(!customImagesLoaded.exists(key)) {
				customImagesLoaded.set(key, BitmapData.fromFile(modsImages(key)));
			}
			imageLoaded = customImagesLoaded.get(key);
		}
		
		var txtExists:Bool = false;
		if(FileSystem.exists(modsTxt(key))) {
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}
	
	#if MODS_ALLOWED
	inline static public function mods(key:String) {
		return 'mods/' + key;
	}
	inline static public function modsImages(key:String) {
		return mods('images/' + key + '.png');
	}
	
	inline static public function modsXml(key:String) {
		return mods('images/' + key + '.xml');
	}
	inline static public function modsTxt(key:String) {
		return mods('images/' + key + '.xml');
	}
	#end
}
