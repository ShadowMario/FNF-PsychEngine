package psychlua;

class TextFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua = funk.lua;
		Lua_helper.add_callback(lua, "makeLuaText", function(tag:String, ?text:String = '', ?width:Int = 0, ?x:Float = 0, ?y:Float = 0) {
			tag = tag.replace('.', '');

			LuaUtils.destroyObject(tag);
			var leText:FlxText = new FlxText(x, y, width, text, 16);
			leText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(PlayState.instance != null) leText.cameras = [PlayState.instance.camHUD];
			leText.scrollFactor.set();
			leText.borderSize = 2;
			MusicBeatState.getVariables().set(tag, leText);
		});

		Lua_helper.add_callback(lua, "setTextString", function(tag:String, text:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.text = text;
				return true;
			}
			FunkinLua.luaTrace("setTextString: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextSize", function(tag:String, size:Int) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.size = size;
				return true;
			}
			FunkinLua.luaTrace("setTextSize: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextWidth", function(tag:String, width:Float) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.fieldWidth = width;
				return true;
			}
			FunkinLua.luaTrace("setTextWidth: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextHeight", function(tag:String, height:Float) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.fieldHeight = height;
				return true;
			}
			FunkinLua.luaTrace("setTextHeight: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextAutoSize", function(tag:String, value:Bool) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.autoSize = value;
				return true;
			}
			FunkinLua.luaTrace("setTextAutoSize: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextBorder", function(tag:String, size:Float, color:String, ?style:String = 'outline') {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				CoolUtil.setTextBorderFromString(obj, (size > 0 ? style : 'none'));
				if(size > 0)
					obj.borderSize = size;
				
				obj.borderColor = CoolUtil.colorFromString(color);
				return true;
			}
			FunkinLua.luaTrace("setTextBorder: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextColor", function(tag:String, color:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.color = CoolUtil.colorFromString(color);
				return true;
			}
			FunkinLua.luaTrace("setTextColor: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextFont", function(tag:String, newFont:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.font = Paths.font(newFont);
				return true;
			}
			FunkinLua.luaTrace("setTextFont: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextItalic", function(tag:String, italic:Bool) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.italic = italic;
				return true;
			}
			FunkinLua.luaTrace("setTextItalic: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextAlignment", function(tag:String, alignment:String = 'left') {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.alignment = LEFT;
				switch(alignment.trim().toLowerCase())
				{
					case 'right':
						obj.alignment = RIGHT;
					case 'center':
						obj.alignment = CENTER;
					case 'justify':
						obj.alignment = JUSTIFY;
				}
				return true;
			}
			FunkinLua.luaTrace("setTextAlignment: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});

		Lua_helper.add_callback(lua, "getTextString", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null && obj.text != null)
			{
				return obj.text;
			}
			FunkinLua.luaTrace("getTextString: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "getTextSize", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				return obj.size;
			}
			FunkinLua.luaTrace("getTextSize: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return -1;
		});
		Lua_helper.add_callback(lua, "getTextFont", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				return obj.font;
			}
			FunkinLua.luaTrace("getTextFont: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "getTextWidth", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				return obj.fieldWidth;
			}
			FunkinLua.luaTrace("getTextWidth: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return 0;
		});

		Lua_helper.add_callback(lua, "addLuaText", function(tag:String) {
			var text:FlxText = MusicBeatState.getVariables().get(tag);
			if(text != null) LuaUtils.getTargetInstance().add(text);
		});
		Lua_helper.add_callback(lua, "removeLuaText", function(tag:String, destroy:Bool = true) {
			var variables = MusicBeatState.getVariables();
			var text:FlxText = variables.get(tag);
			if(text == null) return;

			var instance:Dynamic = CustomSubstate.instance != null ? CustomSubstate.instance : LuaUtils.getTargetInstance();
			instance.remove(text, true);
			if(destroy)
			{
				text.destroy();
				variables.remove(tag);
			}
		});
	}
}
