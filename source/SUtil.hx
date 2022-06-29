package;

#if android
import android.Tools;
import android.Permissions;
import android.PermissionsList;
import android.os.Build;
#end
import flash.system.System;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.Exception;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 */

using StringTools;

class SUtil
{
	/**
	 * A simple check function
	 */
	public static function check()
	{
		#if android
		if (!Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE) || !Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE))
		{
			if (Build.SDK_INT > 23 || Build.SDK_INT == 23)
			{
				Permissions.requestPermissions([PermissionsList.READ_EXTERNAL_STORAGE, PermissionsList.WRITE_EXTERNAL_STORAGE]);

				/**
				 * Basicaly for now i can't force the app to stop while it requst a android permission, so this make the app to stop while it request the specific permission!
				 */
				SUtil.applicationAlert('Permissions? ', 'IF you accepted the permissions all are good!' + "\nIf you didn't expect a crash" + 'Press Ok to see what happens');
			}
			else
			{
				SUtil.applicationAlert('Permissions?', 'Please grant the storage permissions in app settings' + '\nPress Ok io close the app');
				Sys.exit(1);
			}
		}

		if (Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE) || Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE))
		{
			if (!FileSystem.exists(SUtil.getPath()))
				FileSystem.createDirectory(SUtil.getPath());

			if (!FileSystem.exists(SUtil.getPath() + 'assets/') && !FileSystem.exists(SUtil.getPath() + 'mods/'))
			{
				SUtil.applicationAlert('Error!', "Whoops, seems you didn't extract the files from the .APK!\nPlease watch the tutorial by pressing OK.");
				CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
				System.exit(1);
			}
			else
			{
				if (!FileSystem.exists(SUtil.getPath() + 'assets/'))
				{
					SUtil.applicationAlert('Error!', "Whoops, seems you didn't extract the assets/assets folder from the .APK!\nPlease watch the tutorial by pressing OK.");
					CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
					System.exit(1);
				}

				if (!FileSystem.exists(SUtil.getPath() + 'mods/'))
				{
					SUtil.applicationAlert('Error!', "Whoops, seems you didn't extract the assets/mods folder from the .APK!\nPlease watch the tutorial by pressing OK.");
					CoolUtil.browserLoad('https://youtu.be/zjvkTmdWvfU');
					System.exit(1);
				}
			}
		}
		#end
	}

	/**
	 * this will returm the external storage path that will be used for the game
	 */
	public static function getPath():String
	{
		#if android
		return Tools.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file') + '/';
		#else
		return '';
		#end
	}

	/**
	 * uncaught error handler original made by: sqirra-rng
	 */
	public static function uncaughtErrorHandler()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	static function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = SUtil.getPath() + "crash/" + "Crash_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;

		try
		{
			if (!FileSystem.exists(SUtil.getPath() + "crash/"))
				FileSystem.createDirectory(SUtil.getPath() + "crash/");

			File.saveContent(path, errMsg + "\n");
		}
		catch(x:Exception)
			SUtil.applicationAlert('Error!', "Chouldn't save the crash file becuase: " + x);

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		System.exit(1);
	}

	static function applicationAlert(title:String, description:String)
	{
		Application.current.window.alert(description, title);
	}

	#if android
	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot something to add in your code')
	{
		try
		{
			if (!FileSystem.exists(SUtil.getPath() + 'saves/'))
				FileSystem.createDirectory(SUtil.getPath() + 'saves/');

			File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
			SUtil.applicationAlert('Done!', 'File Saved Successfully!');
		}
		catch(e:Exception)
		{
			openfl.system.System.setClipboard(fileData);
			SUtil.applicationAlert('Done!', 'Data Saved to Clipboard Successfully!');
		}
	}

	public static function copyContent(copyPath:String, savePath:String)
	{
		try
		{
			if (!FileSystem.exists(savePath))
				File.saveBytes(savePath, OpenFlAssets.getBytes(copyPath));
		}
		catch(x:Exception)
			SUtil.applicationAlert('Error!', "Chouldn't copy the file becuase: " + x);
	}
	#end
}

