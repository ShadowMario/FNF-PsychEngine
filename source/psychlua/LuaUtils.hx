package psychlua;

import objects.Bar;
import flixel.util.FlxStringUtil;
import flixel.math.FlxPoint;
//import backend.WeekData;
//import objects.Character;

import openfl.display.BlendMode;
import animateatlas.AtlasFrameMaker;
//import Type.ValueType;

import substates.GameOverSubstate;

typedef LuaTweenOptions = {
	type:FlxTweenType,
	startDelay:Float,
	?onUpdate:String,
	?onStart:String,
	?onComplete:String,
	loopDelay:Float,
	ease:EaseFunction
}

class LuaUtils
{
	public static function getLuaTween(options:Dynamic):LuaTweenOptions
	{
		return {
			type: getTweenTypeByString(options.type),
			startDelay: options.startDelay,
			onUpdate: options.onUpdate,
			onStart: options.onStart,
			onComplete: options.onComplete,
			loopDelay: options.loopDelay,
			ease: getTweenEaseByString(options.ease)
		};
	}

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Any
	{
		final splitProps:Array<String> = variable.split('[');
		if(splitProps.length > 1)
		{
			var target:Dynamic = null;
			if(PlayState.instance.variables.exists(splitProps[0]))
			{
				final retVal:Dynamic = PlayState.instance.variables.get(splitProps[0]);
				if(retVal != null)
					target = retVal;
			}
			else target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				final j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				if(i >= splitProps.length-1) //Last array
					target[j] = value;
				else //Anything else
					target = target[j];
			}
			return target;
		}

		if(allowMaps && isMap(instance))
		{
			//trace(instance);
			instance.set(variable, value);
			return value;
		}

		if(PlayState.instance.variables.exists(variable))
		{
			PlayState.instance.variables.set(variable, value);
			return value;
		}
		Reflect.setProperty(instance, variable, value);
		return value;
	}
	public static function getVarInArray(instance:Dynamic, variable:String, allowMaps:Bool = false):Any
	{
		final splitProps:Array<String> = variable.split('[');
		if(splitProps.length > 1)
		{
			var target:Dynamic = null;
			if(PlayState.instance.variables.exists(splitProps[0]))
			{
				final retVal:Dynamic = PlayState.instance.variables.get(splitProps[0]);
				if(retVal != null)
					target = retVal;
			}
			else
				target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				final j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				target = target[j];
			}
			return target;
		}
		
		if(allowMaps && isMap(instance))
		{
			//trace(instance);
			return instance.get(variable);
		}

		if(PlayState.instance.variables.exists(variable))
		{
			final retVal:Dynamic = PlayState.instance.variables.get(variable);
			if(retVal != null)
				return retVal;
		}
		return Reflect.getProperty(instance, variable);
	}
	
	public static function isMap(variable:Dynamic)
	{
		/*switch(Type.typeof(variable)){
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				return true;
			default:
				return false;
		}*/

		//trace(variable);
		return (variable.exists != null && variable.keyValueIterator != null);
	}

	public static function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic, ?allowMaps:Bool = false) {
		final split:Array<String> = variable.split('.');
		if(split.length > 1) {
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length-1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;
			variable = split[split.length-1];
		}
		if(allowMaps && isMap(leArray)) leArray.set(variable, value);
		else Reflect.setProperty(leArray, variable, value);
		return value;
	}
	public static function getGroupStuff(leArray:Dynamic, variable:String, ?allowMaps:Bool = false) {
		final split:Array<String> = variable.split('.');
		if(split.length > 1) {
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length-1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;
			variable = split[split.length-1];
		}

		if(allowMaps && isMap(leArray)) return leArray.get(variable);
		return Reflect.getProperty(leArray, variable);
	}

	public static function getPropertyLoop(split:Array<String>, ?checkForTextsToo:Bool = true, ?getProperty:Bool=true, ?allowMaps:Bool = false):Dynamic
	{
		var obj:Dynamic = getObjectDirectly(split[0], checkForTextsToo);
		final end = (getProperty ? split.length-1 : split.length);

		for (i in 1...end) obj = getVarInArray(obj, split[i], allowMaps);
		return obj;
	}

	public static function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true, ?allowMaps:Bool = false):Dynamic
	{
		switch(objectName)
		{
			case 'this' | 'instance' | 'game':
				return PlayState.instance;
			
			default:
				var obj:Dynamic = PlayState.instance.getLuaObject(objectName, checkForTextsToo);
				if(obj == null) obj = getVarInArray(getTargetInstance(), objectName, allowMaps);
				return obj;
		}
	}

	inline public static function getTextObject(name:String):FlxText
	{
		return #if LUA_ALLOWED PlayState.instance.modchartTexts.exists(name) ? PlayState.instance.modchartTexts.get(name) : #end Reflect.getProperty(PlayState.instance, name);
	}
	
	public static function isOfTypes(value:Any, types:Array<Dynamic>)
	{
		for (type in types)
		{
			if(Std.isOfType(value, type)) return true;
		}
		return false;
	}
	
	public static inline function getTargetInstance()
	{
		return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
	}

	static final _lePoint:FlxPoint = FlxPoint.get();

	inline public static function getMousePoint(camera:String, axis:String):Float
	{
		FlxG.mouse.getScreenPosition(LuaUtils.cameraFromString(camera), _lePoint);
		return (axis == 'y' ? _lePoint.y : _lePoint.x);
	}

	inline public static function getPoint(leVar:String, type:String, axis:String, ?camera:String):Float
	{
		final split:Array<String> = leVar.split('.');
		var obj:FlxSprite = null;
		if (split.length > 1)
			obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
		else
			obj = LuaUtils.getObjectDirectly(split[0]);

		if (obj != null)
		{
			switch(type)
			{
				case 'graphic':
					obj.getGraphicMidpoint(_lePoint);
				case 'screen':
					obj.getScreenPosition(_lePoint, LuaUtils.cameraFromString(camera));
				default:
					obj.getMidpoint(_lePoint);
			};
			return (axis == 'y' ? _lePoint.y : _lePoint.x);
		}
		return 0;
	}

	public static function setBarColors(bar:Bar, color1:String, color2:String) {
		final left_color:Null<FlxColor> = (color1 != null && color1 != '' ? CoolUtil.colorFromString(color1) : null);
		final right_color:Null<FlxColor> = (color2 != null && color2 != '' ? CoolUtil.colorFromString(color2) : null);
		bar.setColors(left_color, right_color);
	}

	public static inline function getLowestCharacterGroup():FlxSpriteGroup
	{
		var group:FlxSpriteGroup = PlayState.instance.gfGroup;
		var pos:Int = PlayState.instance.members.indexOf(group);

		var newPos:Int = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
		if(newPos < pos)
		{
			group = PlayState.instance.boyfriendGroup;
			pos = newPos;
		}
		
		newPos = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
		if(newPos < pos)
		{
			group = PlayState.instance.dadGroup;
			pos = newPos;
		}
		return group;
	}
	
	public static function addAnimByIndices(obj:String, name:String, prefix:String, indices:Any = null, framerate:Int = 24, loop:Bool = false)
	{
		final obj:Dynamic = LuaUtils.getObjectDirectly(obj, false);
		if(obj != null && obj.animation != null)
		{
			if(indices == null)
				indices = [0];
			else if(Std.isOfType(indices, String))
			{
				indices = FlxStringUtil.toIntArray(cast indices);
			}

			obj.animation.addByIndices(name, prefix, indices, '', framerate, loop);
			if(obj.animation.curAnim == null)
			{
				if(obj.playAnim != null) obj.playAnim(name, true);
				else obj.animation.play(name, true);
			}
			return true;
		}
		return false;
	}
	
	public static function loadFrames(spr:FlxSprite, image:String, spriteType:String)
	{
		switch(spriteType.toLowerCase().trim())
		{
			case "texture" | "textureatlas" | "tex":
				spr.frames = AtlasFrameMaker.construct(image);

			case "texture_noaa" | "textureatlas_noaa" | "tex_noaa":
				spr.frames = AtlasFrameMaker.construct(image, null, true);

			case "packer" | "packeratlas" | "pac":
				spr.frames = Paths.getPackerAtlas(image);

			default:
				spr.frames = Paths.getSparrowAtlas(image);
		}
	}

	public static function resetTextTag(tag:String) {
		#if LUA_ALLOWED
		if(!PlayState.instance.modchartTexts.exists(tag)) {
			return;
		}

		final target:FlxText = PlayState.instance.modchartTexts.get(tag);
		target.kill();
		PlayState.instance.remove(target, true);
		target.destroy();
		PlayState.instance.modchartTexts.remove(tag);
		#end
	}

	public static function resetSpriteTag(tag:String) {
		#if LUA_ALLOWED
		if(!PlayState.instance.modchartSprites.exists(tag)) {
			return;
		}

		final target:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
		target.kill();
		PlayState.instance.remove(target, true);
		target.destroy();
		PlayState.instance.modchartSprites.remove(tag);
		#end
	}

	public static function cancelTween(tag:String) {
		#if LUA_ALLOWED
		if(PlayState.instance.modchartTweens.exists(tag)) {
			PlayState.instance.modchartTweens.get(tag).cancel();
			PlayState.instance.modchartTweens.get(tag).destroy();
			PlayState.instance.modchartTweens.remove(tag);
		}
		#end
	}

	public static function tweenPrepare(tag:String, vars:String) {
		cancelTween(tag);
		final variables:Array<String> = vars.split('.');
		return  if (variables.length > 1)
					LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(variables), variables[variables.length-1]);
				else 
					LuaUtils.getObjectDirectly(variables[0]);
	}

	public static function cancelTimer(tag:String) {
		#if LUA_ALLOWED
		if(PlayState.instance.modchartTimers.exists(tag)) {
			var theTimer:FlxTimer = PlayState.instance.modchartTimers.get(tag);
			theTimer.cancel();
			theTimer.destroy();
			PlayState.instance.modchartTimers.remove(tag);
		}
		#end
	}

	//buncho string stuffs
	inline public static function getTweenTypeByString(?type:String = ''):FlxTweenType {
		return switch(type.toLowerCase().trim()) {
			case 'backward':       FlxTweenType.BACKWARD;
			case 'looping'|'loop': FlxTweenType.LOOPING;
			case 'persist':        FlxTweenType.PERSIST;
			case 'pingpong':       FlxTweenType.PINGPONG;
			default:               FlxTweenType.ONESHOT;
		}
	}

	inline public static function getTweenEaseByString(?ease:String = ''):EaseFunction {
		return switch(ease.toLowerCase().trim()) {
			case 'backin':            FlxEase.backIn;
			case 'backinout':         FlxEase.backInOut;
			case 'backout':           FlxEase.backOut;
			case 'bouncein':          FlxEase.bounceIn;
			case 'bounceinout':       FlxEase.bounceInOut;
			case 'bounceout':         FlxEase.bounceOut;
			case 'circin':            FlxEase.circIn;
			case 'circinout':         FlxEase.circInOut;
			case 'circout':           FlxEase.circOut;
			case 'cubein':            FlxEase.cubeIn;
			case 'cubeinout':         FlxEase.cubeInOut;
			case 'cubeout':           FlxEase.cubeOut;
			case 'elasticin':         FlxEase.elasticIn;
			case 'elasticinout':      FlxEase.elasticInOut;
			case 'elasticout':        FlxEase.elasticOut;
			case 'expoin':            FlxEase.expoIn;
			case 'expoinout':         FlxEase.expoInOut;
			case 'expoout':           FlxEase.expoOut;
			case 'quadin':            FlxEase.quadIn;
			case 'quadinout':         FlxEase.quadInOut;
			case 'quadout':           FlxEase.quadOut;
			case 'quartin':           FlxEase.quartIn;
			case 'quartinout':        FlxEase.quartInOut;
			case 'quartout':          FlxEase.quartOut;
			case 'quintin':           FlxEase.quintIn;
			case 'quintinout':        FlxEase.quintInOut;
			case 'quintout':          FlxEase.quintOut;
			case 'sinein':            FlxEase.sineIn;
			case 'sineinout':         FlxEase.sineInOut;
			case 'sineout':           FlxEase.sineOut;
			case 'smoothstepin':      FlxEase.smoothStepIn;
			case 'smoothstepinout':   FlxEase.smoothStepInOut;
			case 'smoothstepout':     FlxEase.smoothStepInOut;
			case 'smootherstepin':    FlxEase.smootherStepIn;
			case 'smootherstepinout': FlxEase.smootherStepInOut;
			case 'smootherstepout':   FlxEase.smootherStepOut;
			default:                  FlxEase.linear;
		}
	}

	inline public static function blendModeFromString(blend:String):BlendMode {
		return cast (blend.toLowerCase().trim() : BlendMode);
	}
	
	inline public static function typeToString(type:Int):String {
		#if LUA_ALLOWED
		return switch(type) {
			case Lua.LUA_TBOOLEAN:	 "boolean";
			case Lua.LUA_TNUMBER:	 "number";
			case Lua.LUA_TSTRING:	 "string";
			case Lua.LUA_TTABLE:	 "table";
			case Lua.LUA_TFUNCTION:	 "function";
			default:				 (type <= Lua.LUA_TNIL ? "nil" : "unknown");
		}
		#else
		return "unknown";
		#end
	}

	inline public static function cameraFromString(cam:String):FlxCamera {
		return switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':     PlayState.instance.camHUD;
			case 'camother' | 'other': PlayState.instance.camOther;
			default:                   PlayState.instance.camGame;
		}
	}
}