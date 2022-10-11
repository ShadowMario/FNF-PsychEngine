import haxe.io.Path;
import openfl.utils.Assets as OpenFlAssets;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

// These universal code work on both Embedded assets and normal files
// They try to use the normal files, but if missing, fall back on the
// embedded assets.
class UniPath {
	static public function getText(path): Null<String> {
		#if sys
		if (FileSystem.exists(path)) {
			return File.getContent(path);
		}
		#end
		return OpenFlAssets.getText(path);
	}

	static public function fileExists(path): Bool {
		#if sys
		if (FileSystem.exists(path) && !FileSystem.isDirectory(path)) {
			return true;
		}
		#end
		return OpenFlAssets.exists(path);
	}

	static public function folderExists(path): Bool {
		#if sys
		if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
			return true;
		}
		#end
		// check if there is an asset file with a path that start with path + "/"
		var pathWithTrailingSlash = Path.addTrailingSlash(path);
		for (asset in OpenFlAssets.list(null)) {
			if (asset.startsWith(pathWithTrailingSlash)) {
				return true;
			}
		}
		return false;
	}

	static private function readDirectory(path, listFile: Bool, listFolder: Bool): Array<String> {
		#if sys
		if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
			var list = [];
			for (entry in FileSystem.readDirectory(path)) {
				var entryPath = Path.join([path, entry]);
				var isDirectory = FileSystem.isDirectory(entryPath);
				if ((listFile && !isDirectory) || (listFolder && isDirectory)) {
					list.push(entry);
				}
			};
			// Do not try to check for additional files in the embedded assets.
			// It should probably not have what we want to get a list for
			// on native.
			return list;
		}
		#end
		var list = [];
		var pathWithTrailingSlash = Path.addTrailingSlash(path);
		for (asset in OpenFlAssets.list(null)) {
			if (asset.startsWith(pathWithTrailingSlash)) {
				var assetTrimmed = asset.substr(pathWithTrailingSlash.length);
				var entry = assetTrimmed.split("/")[0];
				// if the sum of these two element are equal, then the concatenuation
				// of them have the same length as "asset" (and form it).
				var isDirectory = asset.length != pathWithTrailingSlash.length + entry.length;
				if ((listFile && !isDirectory) || (listFolder && isDirectory)) {
					list.push(entry);
				}
			}
		}
		return list;
	}

	static public function getSubFiles(path): Array<String> {
		return readDirectory(path, true, false);
	}

	static public function getSubDirectories(path): Array<String> {
		return readDirectory(path, false, true);
	}
}