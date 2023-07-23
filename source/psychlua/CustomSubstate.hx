package psychlua;

import flixel.FlxObject;

class CustomSubstate extends MusicBeatSubstate
{
	public static var name:String = 'unnamed';
	public static var instance:CustomSubstate;

	public static function implement(funk:FunkinLua)
	{
		#if LUA_ALLOWED
		var lua = funk.lua;
		var game = PlayState.instance;
		Lua_helper.add_callback(lua, "openCustomSubstate", function(name:String, ?pauseGame:Bool = false) {
			if(pauseGame)
			{
				FlxG.camera.followLerp = 0;
				game.persistentUpdate = false;
				game.persistentDraw = true;
				game.paused = true;
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					game.vocals.pause();
				}
			}
			game.openSubState(new CustomSubstate(name));
		});

		Lua_helper.add_callback(lua, "closeCustomSubstate", function() {
			if(instance != null)
			{
				game.closeSubState();
				instance = null;
				return true;
			}
			return false;
		});
		
		Lua_helper.add_callback(lua, "insertToCustomSubstate", function(tag:String, ?pos:Int = -1) {
			if(instance != null)
			{
				var tagObject:FlxObject = cast (game.variables.get(tag), FlxObject);
				if(tagObject == null) tagObject = cast (game.modchartSprites.get(tag), FlxObject);

				if(tagObject != null)
				{
					if(pos < 0) instance.add(tagObject);
					else instance.insert(pos, tagObject);
					return true;
				}
			}
			return false;
		});
		#end
	}

	override function create()
	{
		instance = this;

		PlayState.instance.callOnLuas('onCustomSubstateCreate', [name]);
		super.create();
		PlayState.instance.callOnLuas('onCustomSubstateCreatePost', [name]);
	}
	
	public function new(name:String)
	{
		CustomSubstate.name = name;
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	override function update(elapsed:Float)
	{
		PlayState.instance.callOnLuas('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		PlayState.instance.callOnLuas('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy()
	{
		PlayState.instance.callOnLuas('onCustomSubstateDestroy', [name]);
		super.destroy();
	}
}
