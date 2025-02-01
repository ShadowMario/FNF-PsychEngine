package psychlua;

import Type.ValueType;
import haxe.Constraints;

import substates.GameOverSubstate;

//
// Functions that use a high amount of Reflections, which are somewhat CPU intensive
// These functions are held together by duct tape
//

class ReflectionFunctions
{
	static final instanceStr:Dynamic = "##PSYCHLUA_STRINGTOOBJ";
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		Lua_helper.add_callback(lua, "getProperty", function(variable:String, ?allowMaps:Bool = false) {
			var split:Array<String> = variable.split('.');
			if(split.length > 1)
				return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length-1], allowMaps);
			return LuaUtils.getVarInArray(LuaUtils.getTargetInstance(), variable, allowMaps);
		});
		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic, ?allowMaps:Bool = false, ?allowInstances:Bool = false) {
			var split:Array<String> = variable.split('.');
			if(split.length > 1) {
				LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length-1], allowInstances ? parseInstances(value) : value, allowMaps);
				return value;
			}
			LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, allowInstances ? parseInstances(value) : value, allowMaps);
			return value;
		});
		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String, ?allowMaps:Bool = false) {
			var myClass:Dynamic = Type.resolveClass(classVar);
			if(myClass == null)
			{
				FunkinLua.luaTrace('getPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED);
				return null;
			}

			var split:Array<String> = variable.split('.');
			if(split.length > 1) {
				var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
				for (i in 1...split.length-1)
					obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

				return LuaUtils.getVarInArray(obj, split[split.length-1], allowMaps);
			}
			return LuaUtils.getVarInArray(myClass, variable, allowMaps);
		});
		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false, ?allowInstances:Bool = false) {
			var myClass:Dynamic = Type.resolveClass(classVar);
			if(myClass == null)
			{
				FunkinLua.luaTrace('setPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED);
				return null;
			}

			var split:Array<String> = variable.split('.');
			if(split.length > 1) {
				var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
				for (i in 1...split.length-1)
					obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

				LuaUtils.setVarInArray(obj, split[split.length-1], allowInstances ? parseInstances(value) : value, allowMaps);
				return value;
			}
			LuaUtils.setVarInArray(myClass, variable, allowInstances ? parseInstances(value) : value, allowMaps);
			return value;
		});
		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(group:String, index:Int, variable:Dynamic, ?allowMaps:Bool = false) {
			var split:Array<String> = group.split('.');
			var realObject:Dynamic = null;
			if(split.length > 1)
				realObject = LuaUtils.getPropertyLoop(split, false, allowMaps);
			else
				realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if(groupOrArray != null)
			{
				switch(Type.typeof(groupOrArray))
				{
					case TClass(Array): //Is Array
						var leArray:Dynamic = realObject[index];
						if(leArray != null) {
							var result:Dynamic = null;
							if(Type.typeof(variable) == ValueType.TInt)
								result = leArray[variable];
							else
								result = LuaUtils.getGroupStuff(leArray, variable, allowMaps);
							return result;
						}
						FunkinLua.luaTrace('getPropertyFromGroup: Object #$index from group: $group doesn\'t exist!', false, false, FlxColor.RED);

					default: //Is Group
						var result:Dynamic = LuaUtils.getGroupStuff(realObject.members[index], variable, allowMaps);
						return result;
				}
			}
			FunkinLua.luaTrace('getPropertyFromGroup: Group/Array $group doesn\'t exist!', false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(group:String, index:Int, variable:Dynamic, value:Dynamic, ?allowMaps:Bool = false, ?allowInstances:Bool = false) {
			var split:Array<String> = group.split('.');
			var realObject:Dynamic = null;
			if(split.length > 1)
				realObject = LuaUtils.getPropertyLoop(split, false, allowMaps);
			else
				realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			if(realObject != null)
			{
				switch(Type.typeof(realObject))
				{
					case TClass(Array): //Is Array
						var leArray:Dynamic = realObject[index];
						if(leArray != null)
						{
							if(Type.typeof(variable) == ValueType.TInt)
							{
								leArray[variable] = allowInstances ? parseInstances(value) : value;
								return value;
							}
							LuaUtils.setGroupStuff(leArray, variable, allowInstances ? parseInstances(value) : value, allowMaps);
						}

					default: //Is Group
						LuaUtils.setGroupStuff(realObject.members[index], variable, allowInstances ? parseInstances(value) : value, allowMaps);
				}
			}
			else FunkinLua.luaTrace('setPropertyFromGroup: Group/Array $group doesn\'t exist!', false, false, FlxColor.RED);
			return value;
		});
		Lua_helper.add_callback(lua, "addToGroup", function(group:String, tag:String, ?index:Int = -1) {
			var obj:FlxSprite = LuaUtils.getObjectDirectly(tag);
			if(obj == null || obj.destroy == null)
			{
				FunkinLua.luaTrace('addToGroup: Object $tag is not valid!', false, false, FlxColor.RED);
				return;
			}

			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if(groupOrArray == null)
			{
				FunkinLua.luaTrace('addToGroup: Group/Array $group is not valid!', false, false, FlxColor.RED);
				return;
			}

			if(index < 0)
			{
				switch(Type.typeof(groupOrArray))
				{
					case TClass(Array): //Is Array
						groupOrArray.push(obj);

					default: //Is Group
						groupOrArray.add(obj);
				}
			}
			else groupOrArray.insert(index, obj);
		});
		Lua_helper.add_callback(lua, "removeFromGroup", function(group:String, ?index:Int = -1, ?tag:String = null, ?destroy:Bool = true) {
			var obj:FlxSprite = null;
			if(tag != null)
			{
				obj = LuaUtils.getObjectDirectly(tag);
				if(obj == null || obj.destroy == null)
				{
					FunkinLua.luaTrace('removeFromGroup: Object $tag is not valid!', false, false, FlxColor.RED);
					return;
				}
			}

			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if(groupOrArray == null)
			{
				FunkinLua.luaTrace('removeFromGroup: Group/Array $group is not valid!', false, false, FlxColor.RED);
				return;
			}

			switch(Type.typeof(groupOrArray))
			{
				case TClass(Array): //Is Array
					if(obj != null)
					{
						groupOrArray.remove(obj);
						if(destroy) obj.destroy();
					}
					else groupOrArray.remove(groupOrArray[index]);

				default: //Is Group
					if(obj == null) obj = groupOrArray.members[index];
					groupOrArray.remove(obj, true);
					if(destroy) obj.destroy();
			}
		});
		
		Lua_helper.add_callback(lua, "callMethod", function(funcToRun:String, ?args:Array<Dynamic>) {
			var parent:Dynamic = PlayState.instance;
			var split:Array<String> = funcToRun.split('.');
			var varParent:Dynamic = MusicBeatState.getVariables().get(split[0].trim());
			if (varParent != null) {
				split.shift();
				funcToRun = split.join('.').trim();
				parent = varParent;
			}
			
			if(funcToRun.length > 0) {
				return callMethodFromObject(parent, funcToRun, parseInstances(args));
			}
			return Reflect.callMethod(null, parent, parseInstances(args));
		});
		Lua_helper.add_callback(lua, "callMethodFromClass", function(className:String, funcToRun:String, ?args:Array<Dynamic>) {
			return callMethodFromObject(Type.resolveClass(className), funcToRun, parseInstances(args));
		});

		Lua_helper.add_callback(lua, "createInstance", function(variableToSave:String, className:String, ?args:Array<Dynamic>) {
			if (!Std.isOfType(args, Array)) args = [];
			variableToSave = variableToSave.trim().replace('.', '');
			if(MusicBeatState.getVariables().get(variableToSave) == null)
			{
				if(args == null) args = [];
				var myType:Dynamic = Type.resolveClass(className);
		
				if(myType == null)
				{
					FunkinLua.luaTrace('createInstance: Class $className not found', false, false, FlxColor.RED);
					return false;
				}

				var obj:Dynamic = Type.createInstance(myType, parseInstances(args));
				if(obj != null)
					MusicBeatState.getVariables().set(variableToSave, obj);
				else
					FunkinLua.luaTrace('createInstance: Failed to create $variableToSave, arguments are possibly wrong.', false, false, FlxColor.RED);

				return (obj != null);
			}
			else FunkinLua.luaTrace('createInstance: Variable $variableToSave is already being used and cannot be replaced!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "addInstance", function(objectName:String, ?inFront:Bool = false) {
			var savedObj:Dynamic = MusicBeatState.getVariables().get(objectName);
			if(savedObj != null)
			{
				var obj:Dynamic = savedObj;
				if (inFront)
					LuaUtils.getTargetInstance().add(obj);
				else
				{
					if(!PlayState.instance.isDead)
						PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), obj);
					else
						GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
				}
			}
			else FunkinLua.luaTrace('addInstance: Can\'t add what doesn\'t exist~ ($objectName)', false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "instanceArg", function(instanceName:String, ?className:String = null) {
			var retStr:String ='$instanceStr::$instanceName';
			if(className != null) retStr += '::$className';
			return retStr;
		});
	}

	static function parseInstanceArray(arg:Array<Dynamic>) {
		var newArray:Array<Dynamic> = [];
		for (val in arg)
			newArray.push(parseInstances(val));
		return newArray;
	}
	public static function parseInstances(arg:Dynamic):Dynamic {
		if (arg == null) return null;
		
		if (Std.isOfType(arg, Array)) {
			return parseInstanceArray(arg);
		} else {
			return parseSingleInstance(arg);
		}
	}
	public static function parseSingleInstance(arg:Dynamic)
	{
		var argStr:String = cast arg;
		if(argStr != null && argStr.length > instanceStr.length)
		{
			var index:Int = argStr.indexOf('::');
			if(index > -1)
			{
				argStr = argStr.substring(index+2);
				//trace('Op1: $argStr');
				var lastIndex:Int = argStr.lastIndexOf('::');

				var split:Array<String> = (lastIndex > -1) ? argStr.substring(0, lastIndex).split('.') : argStr.split('.');
				arg = (lastIndex > -1) ? Type.resolveClass(argStr.substring(lastIndex+2)) : PlayState.instance;
				for (j in 0...split.length)
				{
					//trace('Op2: ${Type.getClass(args[i])}, ${split[j]}');
					arg = LuaUtils.getVarInArray(arg, split[j].trim());
					//trace('Op3: ${args[i] != null ? Type.getClass(args[i]) : null}');
				}
			}
		}
		return arg;
	}

	static function callMethodFromObject(classObj:Dynamic, funcStr:String, args:Array<Dynamic>)
	{
		var split:Array<String> = funcStr.split('.');
		var funcToRun:Function = null;
		var obj:Dynamic = classObj;
		//trace('start: ' + obj);
		if(obj == null)
		{
			return null;
		}

		for (i in 0...split.length)
		{
			obj = LuaUtils.getVarInArray(obj, split[i].trim());
			//trace(obj, split[i]);
		}

		funcToRun = cast obj;
		//trace('end: $obj');
		return funcToRun != null ? Reflect.callMethod(obj, funcToRun, args) : null;
	}
}
