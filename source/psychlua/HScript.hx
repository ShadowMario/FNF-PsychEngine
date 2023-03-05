package psychlua;

#if hscript
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
#end

import objects.Character;

class HScript
{
	#if hscript
	public static var parser:Parser = new Parser();
	public var interp:Interp;

	public var variables(get, never):Map<String, Dynamic>;

	public function get_variables()
	{
		return interp.variables;
	}
	
	public static function initHaxeModule()
	{
		#if hscript
		if(FunkinLua.hscript == null)
		{
			//trace('initializing haxe interp for: $scriptName');
			FunkinLua.hscript = new HScript(); //TO DO: Fix issue with 2 scripts not being able to use the same variable names
		}
		#end
	}

	public function new()
	{
		interp = new Interp();
		interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Conductor', Conductor);
		interp.variables.set('ClientPrefs', ClientPrefs);
		interp.variables.set('Character', Character);
		interp.variables.set('Alphabet', Alphabet);
		interp.variables.set('CustomSubstate', psychlua.CustomSubstate);
		#if (!flash && sys)
		interp.variables.set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		interp.variables.set('ShaderFilter', openfl.filters.ShaderFilter);
		interp.variables.set('StringTools', StringTools);

		interp.variables.set('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		interp.variables.set('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		interp.variables.set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
	}

	public function execute(codeToRun:String):Dynamic
	{
		@:privateAccess
		HScript.parser.line = 1;
		HScript.parser.allowTypes = true;
		return interp.execute(HScript.parser.parseString(codeToRun));
	}
	#end
}