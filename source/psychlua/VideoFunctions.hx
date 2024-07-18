package psychlua;

import objects.VideoSprite;

import substates.GameOverSubstate;

class VideoFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua = funk.lua;
		Lua_helper.add_callback(lua, "makeVideoSprite", function(tag:String, video:String, ?x:Float = 0, ?y:Float = 0, ?loop:Dynamic = false) {
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leVideo:VideoSprite = new VideoSprite(Paths.video(video), true, false, loop);
			leVideo.setPosition(x, y);
			MusicBeatState.getVariables().set(tag, leVideo);
		});
		Lua_helper.add_callback(lua, "setVideoSize", function(tag:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			var obj:VideoSprite = MusicBeatState.getVariables().get(tag);
			if(obj != null) {
				obj.setGraphicSize(x, y);
				if(updateHitbox) obj.updateHitbox();
				return;
			}

			var split:Array<String> = tag.split('.');
			var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1)
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);

			if(poop != null) {
				poop.setGraphicSize(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			FunkinLua.luaTrace('setVideoSize: Couldnt find video: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "scaleVideo", function(tag:String, x:Float, y:Float, updateHitbox:Bool = true) {
			var obj:VideoSprite = MusicBeatState.getVariables().get(tag);
			if(obj != null) {
				obj.scale.set(x, y);
				if(updateHitbox) obj.updateHitbox();
				return;
			}

			var split:Array<String> = tag.split('.');
			var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1)
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);

			if(poop != null) {
				poop.scale.set(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			FunkinLua.luaTrace('scaleVideo: Couldnt find video: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addLuaVideo", function(tag:String, front:Bool = false) {
			var myVideo:VideoSprite = MusicBeatState.getVariables().get(tag);
			if(myVideo == null) return false;

			var instance = LuaUtils.getTargetInstance();
			if(front)
				instance.add(myVideo);
			else
			{
				if(PlayState.instance == null || !PlayState.instance.isDead)
					instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), myVideo);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), myVideo);
			}
			return true;
		});
		Lua_helper.add_callback(lua, "removeLuaVideo", function(tag:String, destroy:Bool = true, ?group:String = null) {
			var obj:VideoSprite = LuaUtils.getObjectDirectly(tag);
			if(obj == null || obj.destroy == null)
				return;

			var groupObj:Dynamic = null;
			if(group == null) groupObj = LuaUtils.getTargetInstance();
			else groupObj = LuaUtils.getObjectDirectly(group);

			groupObj.remove(obj, true);
			if(destroy)
			{
				MusicBeatState.getVariables().remove(tag);
				obj.destroy();
			}
		});

		Lua_helper.add_callback(lua, "playVideo", function(tag:String) {
			var obj:VideoSprite = MusicBeatState.getVariables().get(tag);
			if(obj != null) {
				obj.play();
				return;
			}

			var split:Array<String> = tag.split('.');
			var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1)
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);

			if(poop != null) {
				poop.play();
				return;
			}
			FunkinLua.luaTrace('playVideo: Couldnt find video: ' + tag, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "resumeVideo", function(tag:String) {
			var obj:VideoSprite = MusicBeatState.getVariables().get(tag);
			if(obj != null) {
				obj.resume();
				return;
			}

			var split:Array<String> = tag.split('.');
			var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1)
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);

			if(poop != null) {
				poop.resume();
				return;
			}
			FunkinLua.luaTrace('resumeVideo: Couldnt find video: ' + tag, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "pauseVideo", function(tag:String) {
			var obj:VideoSprite = MusicBeatState.getVariables().get(tag);
			if(obj != null) {
				obj.pause();
				return;
			}

			var split:Array<String> = tag.split('.');
			var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1)
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);

			if(poop != null) {
				poop.pause();
				return;
			}
			FunkinLua.luaTrace('pauseVideo: Couldnt find video: ' + tag, false, false, FlxColor.RED);
		});

		Lua_helper.add_callback(lua, "luaVideoExists", function(tag:String) {
			var obj:VideoSprite = MusicBeatState.getVariables().get(tag);
			return (obj != null && Std.isOfType(obj, VideoSprite));
		});
	}
}