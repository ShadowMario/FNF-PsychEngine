package lime.utils;

import openfl.Lib;
#if android
import android.widget.Toast;
#end
import haxe.PosInfos;
import lime.app.Application;
import lime.system.System;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Log
{
	public static var level:LogLevel;
	public static var throwErrors:Bool = true;

	public static function debug(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.DEBUG)
		{
			#if js
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").debug("[" + info.className + "] " + Std.string(message));
			#else
			println("[" + info.className + "] " + Std.string(message));
			#end
		}
	}

	public static function error(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.ERROR)
		{
			var message:String = "[" + info.className + "] ERROR: " + Std.string(message);

			if (throwErrors)
			{
				#if sys
				try
				{
					if (!FileSystem.exists(SUtil.getStorageDirectory() + 'logs'))
						FileSystem.createDirectory(SUtil.getStorageDirectory() + 'logs');

					File.saveContent(SUtil.getStorageDirectory()
						+ 'logs/'
						+ Lib.application.meta.get('file')
						+ '-'
						+ Date.now().toString().replace(' ', '-').replace(':', "'")
						+ '.txt',
						message
						+ '\n');
				}
				catch (e:Dynamic)
				{
					#if android
					Toast.makeText("Error!\nClouldn't save the crash log because:\n" + e, Toast.LENGTH_LONG);
					#else
					println("Error!\nClouldn't save the crash log because:\n" + e);
					#end
				}
				#end

				println(message);
				Application.current.window.alert(message, 'Error!');
				System.exit(1);
			}
			else
			{
				#if js
				untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").error(message);
				#else
				println(message);
				#end
			}
		}
	}

	public static function info(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.INFO)
		{
			#if js
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").info("[" + info.className + "] " + Std.string(message));
			#else
			println("[" + info.className + "] " + Std.string(message));
			#end
		}
	}

	public static function verbose(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.VERBOSE)
		{
			println("[" + info.className + "] " + Std.string(message));
		}
	}

	public static function warn(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.WARN)
		{
			#if js
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").warn("[" + info.className + "] WARNING: " + Std.string(message));
			#else
			println("[" + info.className + "] WARNING: " + Std.string(message));
			#end
		}
	}

	public static inline function print(message:Dynamic):Void
	{
		#if sys
		Sys.print(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log(Std.string(message));
		#else
		trace(Std.string(message));
		#end
	}

	public static inline function println(message:Dynamic):Void
	{
		#if sys
		Sys.println(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log(Std.string(message));
		#else
		trace(Std.string(message));
		#end
	}

	private static function __init__():Void
	{
		#if no_traces
		level = NONE;
		#elseif verbose
		level = VERBOSE;
		#else
		#if sys
		var args = Sys.args();
		if (args.indexOf("-v") > -1 || args.indexOf("-verbose") > -1)
		{
			level = VERBOSE;
		}
		else
		#end
		{
			#if debug
			level = DEBUG;
			#else
			level = INFO;
			#end
		}
		#end

		#if js
		if (untyped #if haxe4 js.Syntax.code #else __js__ #end ("typeof console") == "undefined")
		{
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console = {}");
		}
		if (untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log == null)
		{
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log = function() {};
		}
		#end
	}
}
