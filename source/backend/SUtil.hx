package backend;

#if android
import android.content.Context;
import android.widget.Toast;
import android.os.Environment;
import android.Permissions;
#end
import haxe.io.Path;
import haxe.CallStack;
import lime.app.Application;
import lime.system.System as LimeSystem;
import lime.utils.Assets as LimeAssets;
import lime.utils.Log as LimeLogger;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
 * ...
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class SUtil
{
	/**
	 * This returns the external storage path that the game will use by the type.
	 */
	public static function getPath():String
	{
		#if android
		return  Context.getExternalFilesDir(null) + '/';
		#elseif ios
		return LimeSystem.applicationStorageDirectory;
		#end
	}

	/**
	 * A simple function that checks for game files/folders.
	 */
	public static function checkFiles():Void
	{
		#if android
		if (!Permissions.getGrantedPermissions().contains(Permissions.WRITE_EXTERNAL_STORAGE)
			&& !Permissions.getGrantedPermissions().contains(Permissions.READ_EXTERNAL_STORAGE) && !Permissions.getGrantedPermissions().contains(Permissions.MANAGE_EXTERNAL_STORAGE))
		{
				Permissions.requestPermissions(Permissions.WRITE_EXTERNAL_STORAGE);
				Permissions.requestPermissions(Permissions.READ_EXTERNAL_STORAGE);
				Permissions.requestPermissions(Permissions.MANAGE_EXTERNAL_STORAGE);
				Lib.application.window.alert('This game need external storage access to function properly' + "\nTo give it access you must accept the storage permission\nIf you accepted you're good to go!\nIf not you'll face issues inGame..."
					+ '\nPress Ok to see what happens',
					'Permissions?');
		}

		if (!FileSystem.exists(SUtil.getPath() + "assets") && !FileSystem.exists(SUtil.getPath() + "mods") || !FileSystem.exists(SUtil.getPath() + "assets") || !FileSystem.exists(SUtil.getPath() + "mods"))
			{
				try {
				if (Permissions.getGrantedPermissions().contains(Permissions.WRITE_EXTERNAL_STORAGE)
					&& Permissions.getGrantedPermissions().contains(Permissions.READ_EXTERNAL_STORAGE) && !Permissions.getGrantedPermissions().contains(Permissions.MANAGE_EXTERNAL_STORAGE))
				{
					if (!FileSystem.exists(SUtil.getPath()))
						FileSystem.createDirectory(SUtil.getPath();)
					if (FileSystem.exists(Environment.getDownloadCacheDirectory() + "assets"))
						copyDirectoryFromExternalStorage(Environment.getDownloadCacheDirectory() + "assets", SUtil.getPath());
	
					if (FileSystem.exists(Environment.getDownloadCacheDirectory() + "mods"))
						copyDirectoryFromExternalStorage(Environment.getDownloadCacheDirectory() + "mods", SUtil.getPath());
	
				}
			} 
			catch(e:Dynamic) {
			Lib.application.window.alert("Whoops, your game have failed in copying the needed files!\n Please make sure you have the needed folders:\nmods and assets in your downloads folder.\n if the problem presists, try moving the files manualy into " + SUtil.getPath + " directory!",
			'Missing files!');
			Toast.makeText('Error!\nCouldn\'t copy the files because:\n' + e, Toast.LENGTH_LONG);
			//LimeSystem.exit(1);
			}
		}
		#end
		#if mobile
		if (!FileSystem.exists(SUtil.getPath() +  'assets') && !FileSystem.exists(SUtil.getPath() +  'mods'))
		{
			Lib.application.window.alert("Whoops, seems like you didn't extract the files from the .APK!\nPlease copy the files from the .APK to\n" + SUtil.getPath(),
				'Error!');
			LimeSystem.exit(1);
		}
		else if ((FileSystem.exists(SUtil.getPath() +  'assets') && !FileSystem.isDirectory(SUtil.getPath() + 'assets'))
			&& (FileSystem.exists(SUtil.getPath() +  'mods') && !FileSystem.isDirectory(SUtil.getPath() + 'mods')))
		{
			Lib.application.window.alert("Why did you create two files called assets and mods instead of copying the folders from the .APK?, expect a crash.",
				'Error!');
			LimeSystem.exit(1);
		}
		else
		{
			if (!FileSystem.exists(SUtil.getPath() +  'assets'))
			{
				Lib.application.window.alert("Whoops, seems like you didn't extract the assets/assets folder from the .APK!\nPlease copy the assets/assets folder from the .APK to\n" + SUtil.getPath(),
					'Error!');
				LimeSystem.exit(1);
			}
			else if (FileSystem.exists(SUtil.getPath() +  'assets') && !FileSystem.isDirectory(SUtil.getPath() + 'assets'))
			{
				Lib.application.window.alert("Why did you create a file called assets instead of copying the assets directory from the .APK?, expect a crash.",
					'Error!');
				LimeSystem.exit(1);
			}

			if (!FileSystem.exists(SUtil.getPath() +  'mods'))
			{
				Lib.application.window.alert("Whoops, seems like you didn't extract the assets/mods folder from the .APK!\nPlease copy the assets/mods folder from the .APK to\n" + SUtil.getPath(),
					'Error!');
				LimeSystem.exit(1);
			}
			else if (FileSystem.exists(SUtil.getPath() +  'mods') && !FileSystem.isDirectory(SUtil.getPath() + 'mods'))
			{
				Lib.application.window.alert("Why did you create a file called mods instead of copying the mods directory from the .APK?, expect a crash.",
					'Error!');
				LimeSystem.exit(1);
			}
		}
		#end
	}

	/**
	 * Uncaught error handler, original made by: Sqirra-RNG and YoshiCrafter29
	 */
	public static function uncaughtErrorHandler():Void
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		Lib.application.onExit.add(function(exitCode:Int)
		{
			if (Lib.current.loaderInfo.uncaughtErrorEvents.hasEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR))
				Lib.current.loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		});
	}

	private static function onError(e:UncaughtErrorEvent):Void
	{
		var stack:Array<String> = [];
		stack.push(e.error);

		for (stackItem in CallStack.exceptionStack(true))
		{
			switch (stackItem)
			{
				case CFunction:
					stack.push('C Function');
				case Module(m):
					stack.push('Module ($m)');
				case FilePos(s, file, line, column):
					stack.push('$file (line $line)');
				case Method(classname, method):
					stack.push('$classname (method $method)');
				case LocalFunction(name):
					stack.push('Local Function ($name)');
			}
		}

		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		final msg:String = stack.join('\n');

		#if sys
		try
		{
			if (!FileSystem.exists(SUtil.getPath() +  'logs'))
				FileSystem.createDirectory(SUtil.getPath() + 'logs');

			File.saveContent(SUtil.getPath()
				+ 'logs/'
				+ Lib.application.meta.get('file')
				+ '-'
				+ Date.now().toString().replace(' ', '-').replace(':', "'")
				+ '.txt',
				msg + '\n');
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			Toast.makeText("Error!\nClouldn't save the crash dump because:\n" + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nClouldn't save the crash dump because:\n" + e);
			#end
		}
		#end

		LimeLogger.println(msg);
		Lib.application.window.alert(msg, 'Error!');
		#if desktop DiscordClient.shutdown(); #end
		#if sys Sys.exit(1); #else LimeSystem.exit(1); #end
	}

	/**
	 * This is mostly a fork of https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
	#if sys
	public static function mkDirs(directory:String):Void
	{
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				if (!FileSystem.exists(total))
					FileSystem.createDirectory(total);
			}
		}
	}

	public static function copyContentFromInternalStorage(copyPath:String, savePath:String):Void
	{
		try
		{
			if (!FileSystem.exists(savePath) && LimeAssets.exists(copyPath))
			{
				if (!FileSystem.exists(Path.directory(savePath)))
					SUtil.mkDirs(Path.directory(savePath));

				File.saveBytes(savePath, LimeAssets.getBytes(copyPath));
			}
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			Toast.makeText('Error!\nClouldn\'t copy the $copyPath because:\n' + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println('Error!\nClouldn\'t copy the $copyPath because:\n' + e);
			#end
		}
	}

	public static function copyContentFromExternalStorage(copyPath:String, savePath:String):Void
		{
			try
			{
				if (!FileSystem.exists(savePath) && FileSystem.exists(copyPath))
				{
					if (!FileSystem.exists(Path.directory(savePath)))
						SUtil.mkDirs(Path.directory(savePath));
	
					File.saveBytes(savePath, File.getBytes(copyPath));
				}
			}
			catch (e:Dynamic)
			{
				#if (android && debug)
				Toast.makeText('Error!\nClouldn\'t copy the $copyPath because:\n' + e, Toast.LENGTH_LONG);
				#else
				LimeLogger.println('Error!\nClouldn\'t copy the $copyPath because:\n' + e);
				#end
			}
		}
		//i readed that File.copy() copies directories so idk
		public static function copyDirectoryFromExternalStorage(copyPath:String, savePath:String):Void
			{
				try
				{
					if (!FileSystem.exists(savePath) && FileSystem.exists(copyPath))
					{
						if (!FileSystem.exists(Path.directory(savePath)))
							FileSystem.createDirectory(Path.directory(savePath));
			
						File.copy(copyPath, savePath);
					}
				}
				catch (e:Dynamic)
				{
					#if (android && debug)
					Toast.makeText('Error!\nCouldn\'t copy the $copyPath because:\n' + e, Toast.LENGTH_LONG);
					#else
					LimeLogger.println('Error!\nCouldn\'t copy the $copyPath because:\n' + e);
					#end
				}
			}
	#end
}
