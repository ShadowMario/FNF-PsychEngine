package macros;

#if macro
import haxe.macro.Compiler;

/**
 * Uses for adding classes even if they not used in game (for hscript goodies)
 */
class AdditionalClasses {
	public static function add() {
		var includePackages:Array<String> = [
			#if desktop "discord_rpc", #end
			"flixel",

			#if (VIDEOS_ALLOWED && hxCodec >= "2.6.1") "hxcodec", #end
			#if (VIDEOS_ALLOWED && hxCodec < "2.6.0") "vlc", #end
			"lime",
			#if LUA_ALLOWED "llua", #end
			"openfl",
			#if SScript "tea", #end
			#if SScript "haxescript", #end

			"haxe",
			#if flash "flash", #end
			#if cpp "cpp", #end
			#if hl "hl", #end
			#if neko "neko", #end
			#if sys "sys", #end
		];

		var excludePackages:Array<String> = [
			"flixel.addons.editors.spine",
			"flixel.addons.nape",
			"flixel.system.macros",

			"haxe.macro",
			#if (js || hxcpp) "haxe.atomic.AtomicObject", #end

			"lime._internal.backend.air",
			"lime._internal.backend.html5",
			"lime._internal.backend.kha",
			"lime.tools",
		];
		Compiler.define('dce', 'no');
		for (pkg in includePackages) Compiler.include(pkg, true, excludePackages);
	}
}
#end
