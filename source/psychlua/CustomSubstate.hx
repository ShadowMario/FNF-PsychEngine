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
		Lua_helper.add_callback(lua, "openCustomSubstate", openCustomSubstate);
		Lua_helper.add_callback(lua, "closeCustomSubstate", closeCustomSubstate);
		Lua_helper.add_callback(lua, "insertToCustomSubstate", insertToCustomSubstate);
		#end
	}
	
	public static function openCustomSubstate(name:String, ?pauseGame:Bool = false)
	{
		if(pauseGame)
		{
			FlxG.camera.followLerp = 0;
			PlayState.instance.persistentUpdate = false;
			PlayState.instance.persistentDraw = true;
			PlayState.instance.paused = true;
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				PlayState.instance.vocals.pause();
			}
		}
		PlayState.instance.openSubState(new CustomSubstate(name));
		PlayState.instance.setOnHScript('customSubstate', instance);
		PlayState.instance.setOnHScript('customSubstateName', name);
	}

	public static function closeCustomSubstate()
	{
		if(instance != null)
		{
			PlayState.instance.closeSubState();
			instance = null;
			return true;
		}
		return false;
	}

	public static function insertToCustomSubstate(tag:String, ?pos:Int = -1)
	{
		if(instance != null)
		{
			var tagObject:FlxObject = cast (PlayState.instance.variables.get(tag), FlxObject);
			#if LUA_ALLOWED if(tagObject == null) tagObject = cast (PlayState.instance.modchartSprites.get(tag), FlxObject); #end

			if(tagObject != null)
			{
				if(pos < 0) instance.add(tagObject);
				else instance.insert(pos, tagObject);
				return true;
			}
		}
		return false;
	}

	override function create()
	{
		instance = this;

		PlayState.instance.callOnScripts('onCustomSubstateCreate', [name]);
		super.create();
		PlayState.instance.callOnScripts('onCustomSubstateCreatePost', [name]);
	}
	
	public function new(name:String)
	{
		CustomSubstate.name = name;
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	override function update(elapsed:Float)
	{
		PlayState.instance.callOnScripts('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		PlayState.instance.callOnScripts('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy()
	{
		PlayState.instance.callOnScripts('onCustomSubstateDestroy', [name]);
		name = 'unnamed';

		PlayState.instance.setOnHScript('customSubstate', null);
		PlayState.instance.setOnHScript('customSubstateName', name);
		super.destroy();
	}
}
