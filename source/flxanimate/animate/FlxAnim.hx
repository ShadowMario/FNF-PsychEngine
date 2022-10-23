package flxanimate.animate;

import flixel.util.FlxStringUtil;
import openfl.geom.ColorTransform;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flxanimate.data.AnimationData;
#if FLX_SOUND_SYSTEM
import flixel.system.FlxSound;
#end

typedef SymbolStuff = {var symbol:FlxSymbol; var ?indices:Array<Int>; var X:Float; var Y:Float; var frameRate:Float; var looped:Bool;};
typedef ClickStuff = {
	?OnClick:Void->Void,
	?OnRelease:Void->Void
}
typedef ButtonSettings = {
	?Callbacks:ClickStuff,
	#if FLX_SOUND_SYSTEM
	?Sound:FlxSound
	#end
}
class FlxAnim implements IFlxDestroyable
{
	public var coolParse(default, null):AnimAtlas;
	public var length(get, never):Int;

	public var curSymbol:FlxSymbol;
	public var finished(default, null):Bool = false;
	public var reversed:Bool = false;
	/**
		Checks if the movieclip should move or not. for having a similar experience to swfs
	**/
	public var swfRender:Bool;
	
	var buttonMap:Map<String, ButtonSettings> = new Map();
	/**
	 * When ever the animation is playing.
	 */
	public var isPlaying(default, null):Bool = false;
	public var onComplete:()->Void;

	var frameTick:Float;
	public var framerate(default, set):Float;

	var _framerate:Float;

	/**
	 * Internal, used for each skip between frames.
	 */
	var frameDelay:Float;

	public var curFrame(get, set):Int;

	var animsMap:Map<String, SymbolStuff> = new Map();
	
	/**
	 * Internal, the parsed loop type
	 */
	var loopType(default, null):LoopType = loop;

	public var symbolType:SymbolType = "G";

	var _parent:FlxAnimate;

	public function new(parent:FlxAnimate, ?coolParsed:AnimAtlas)
	{
		_parent = parent;
		swfRender = false;
		symbolDictionary = [];
		if (coolParsed != null) _loadAtlas(coolParsed);
	}
	@:allow(flxanimate.FlxAnimate)
	function _loadAtlas(animationFile:AnimAtlas)
	{
		symbolDictionary = [];
		coolParse = animationFile;
		setSymbols(animationFile);
		if (animationFile.AN.STI != null)
		{
			var STI = animationFile.AN.STI.SI;
			
			symbolType = STI.ST;
			loopType = ([graphic, "graphic"].indexOf(symbolType) != -1) ? STI.LP : loop;
			curFrame = STI.FF;
			@:privateAccess
			_parent._matrix.concat(FlxSymbol.prepareMatrix(STI.M3D, STI.bitmap.POS));
			if (STI.C != null)
			{
				@:privateAccess
				_parent.colorTransform = FlxAnimate.colorEffect(STI.C);
			}
			@:privateAccess
			_parent.origin.set(STI.TRP.x, STI.TRP.y);
		}
		framerate = _framerate = animationFile.MD.FRT;
	}
	public var symbolDictionary:Map<String, FlxSymbol>;
	
	public function play(?Name:String, Force:Bool = false, Reverse:Bool = false, Frame:Int = 0)
	{
		pause();
		var nth = #if html5 js.Lib.undefined #else null #end;
		var curThing = animsMap.get(Name);
		if ([nth, ""].indexOf(Name) == -1 && curThing == null)
		{
			var symbol = symbolDictionary.get(Name);
			if (symbol != null) curThing = {symbol: symbol, looped: true, frameRate: _framerate, X: 0, Y: 0};

			if (curThing == null)
			{
				FlxG.log.error('there\'s no animation called "$Name"!');
				isPlaying = true;
				return;
			}
		}
		@:privateAccess
		if ([nth, ""].indexOf(Name) == -1)
		{
			_parent._matrix.identity();
			if (Name == coolParse.AN.SN && coolParse.AN.STI != null)
				_parent._matrix.concat(FlxSymbol.prepareMatrix(coolParse.AN.STI.SI.M3D, coolParse.AN.STI.SI.bitmap.POS));
			_parent._matrix.concat(new FlxMatrix(1,0,0,1,curThing.X,curThing.Y));
			curFrame = 0;
			@:privateAccess
			loopType = curThing.looped ? loop : playonce;
			framerate = curThing.frameRate;
		}
		if (Force || finished || [nth, ""].indexOf(Name) == -1 || curThing != null && curThing.symbol != curSymbol)
		{
			curFrame = (Reverse) ? Frame - length : Frame;
		}
		if ([nth, ""].indexOf(Name) == -1) curSymbol = curThing.symbol;
		reversed = Reverse;
		finished = false;
		isPlaying = true;
		
	}

	public function pause()
	{
		isPlaying = false;
	}
	public function stop()
	{
		pause();
		curFrame = 0;
	}

	var pressed:Bool = false;

	function setSymbols(Anim:AnimAtlas)
	{
		if (coolParse.SD != null)
		{
			for (symbol in coolParse.SD.S)
			{
				symbolDictionary.set(symbol.SN, new FlxSymbol(symbol.SN, symbol.TL));
			}
		}
		curSymbol = new FlxSymbol(Anim.AN.SN, Anim.AN.TL);
		symbolDictionary.set(Anim.AN.SN, curSymbol);
	}
	
	public function update(elapsed:Float)
	{
		curFrame = curSymbol.frameControl(curFrame, loopType);
		if (!isPlaying || finished) return;
		curSymbol.update(framerate,reversed, loopType);
		if (FlxG.keys.pressed.F)
			trace(loopType, curFrame > length - 1);
		finished = [playonce, "playonce"].indexOf(loopType) != -1 && (reversed && curFrame == 0 || curFrame > length - 1);

		if (finished)
		{
			if (onComplete != null)
				onComplete();
			pause();
		}
	}
	function get_curFrame()
	{
		return curSymbol.curFrame;
	}
	function set_curFrame(Value:Int)
	{
		return curSymbol.curFrame = Value;
	}
	/**
	 * Creates an animation using an already made symbol from a texture atlas
	 * @param Name The name of the animation
	 * @param SymbolName the name of the symbol you're looking. if you have two symbols beginning by the same name, use `\` at the end to differ one symbol from another
	 * @param X the *x* axis of the animation.
	 * @param Y  the *y* axis of the animation.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addBySymbol(Name:String, SymbolName:String, FrameRate:Float = 0, Looped:Bool = true, X:Float = 0, Y:Float = 0)
	{
		FrameRate = (FrameRate == 0) ? _framerate : FrameRate;
		var symbol = null;
		for (name in symbolDictionary.keys())
		{
			if (startsWith(name, SymbolName))
			{
				symbol = symbolDictionary.get(name);
				break;
			}
		}
		if (symbol != null)
			animsMap.set(Name, {symbol: new FlxSymbol(Name, symbol.timeline), X: X, Y: Y, frameRate: FrameRate, looped: Looped});
		else
			FlxG.log.error('No symbol was found with the name $SymbolName!');
	}
	function startsWith(reference:String, string:String):Bool
	{
		if (StringTools.endsWith(string, String.fromCharCode(92))) // String.fromCharCode(92) == \ :)
			return reference == string.substring(0, string.length - 1)
		else
			return StringTools.startsWith(reference, string);
	}
	/**
	 * Creates an animation using the indices, looking as a reference the main animation of the texture atlas.
	 * @param Name The name of the animation you're creating
	 * @param Indices The indices you're gonna be using for the animation, like `[0,1,2]`.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addByAnimIndices(Name:String, Indices:Array<Int>, FrameRate:Float = 0) 
	{
		addBySymbolIndices(Name, coolParse.AN.SN, Indices, FrameRate, (coolParse.AN.STI != null) ? ["loop", "LP"].indexOf(coolParse.AN.STI.SI.LP) != -1 : false, 0,0);
	}
	public function addBySymbolIndices(Name:String, SymbolName:String, Indices:Array<Int>, FrameRate:Float = 0, Looped:Bool = true, X:Float = 0, Y:Float = 0) 
	{
		FrameRate = (FrameRate == 0) ? _framerate : FrameRate;
		var thing = symbolDictionary.get(SymbolName);
		if (thing == null)
		{
			FlxG.log.error('$SymbolName does not exist as a symbol! maybe you misspelled it?');
			return;
		}
		var layers:Array<Layers> = [];
		
		var frames:Array<Frame> = [];
		for (index in 0...Indices.length)
		{
			var i = Indices[index];
			
			var element:Element = cast {
				SI: {
					SN: SymbolName,
					TRP: {x: 0, y: 0},
					IN: "",
					ST: "G",
					LP: (Looped) ? "LP" : "PO",
					M3D: [1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0],
					FF: i,
				}
			}
			frames.push({I: index, DU: 1, E: [element]});
		}
		layers.push({LN: "Layer 1", FR: frames});

		animsMap.set(Name, {symbol: new FlxSymbol(Name, {L: layers}), indices: Indices, X: X, Y: Y, frameRate: FrameRate, looped: false});
	}

	function set_framerate(value:Float):Float
	{
		frameDelay = 1 / value;
		return framerate = value;
	}
	/**
	 * This adds a new animation by adding a custom timeline, obviously taking as a reference the timeline syntax!
	 * **WARNING**: I, *CheemsAndFriends*, do **NOT** recommend this unless you're using an extern json file to do this!
	 * if you wanna make a custom symbol to play around and is separated from the texture atlas, go ahead! but if you wanna just make a new symbol, 
	 * just do it in Flash directly
	 * @param Name The name of the new Symbol.
	 * @param Timeline The timeline which will have the symbol.
	 * @param FrameRate The framerate it'll go, by default is 30.
	 */
	public function addByCustomTimeline(Name:String, Timeline:Timeline, FrameRate:Float = 0, Looped:Bool = true)
	{
		FrameRate = (FrameRate == 0) ? _framerate : FrameRate;
		animsMap.set(Name, {symbol: new FlxSymbol(Name, Timeline), X: 0, Y: 0, frameRate: FrameRate, looped: Looped});
	}

	public function get_length()
	{
		return curSymbol.length;
	}

	public function getFrameLabel(name:String):Null<FlxLabel>
	{
		var thingy = curSymbol.labels.get(name);

		if (thingy == null)
		{
			FlxG.log.error('The frame label "$name" does not exist! maybe you misspelled it?');
		}
		return thingy;
	}
	public function toString()
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("symbolDictionary", symbolDictionary),
			LabelValuePair.weak("framerate", framerate)
		]);
	}
	/**
	 * Redirects the frame into a frame with a frame label of that type.
	 * @param name the name of the label.
	 */
	public function goToFrameLabel(name:String)
	{
		var label = getFrameLabel(name);

		if (label != null)
			curFrame = label.frame;
	}
	/**
	 * Checks the next frame label name you're looking for.
	 * **WARNING: DO NOT** confuse with `anim.curSymbol.getNextToFrameLabel`!!
	 * @param name the name of the frame label.
	 * @return A `String`. WARNING: it can be `null`
	 */
	public function getNextToFrameLabel(name:String):Null<String>
	{
		return curSymbol.getNextToFrameLabel(name).name;
	}
	/**
	 * Links a callback into a label.
	 * @param label the name of the label.
	 * @param callback the callback you're going to add 
	 */
	public function addCallbackTo(label:String, callback:()->Void)
	{
		curSymbol.addCallbackTo(label, callback);
	}

	public function removeCallbackFrom(label:String, callback:()->Void)
	{
		curSymbol.removeCallbackFrom(label, callback);
	}

	public function removeAllCallbacksFrom(label:String)
	{
		curSymbol.removeAllCallbacksFrom(label);
	}

	
	public function getByName(name:String)
	{
		return animsMap.get(name);
	}

	public function destroy()
	{
		coolParse = null;
		curFrame = 0;
		framerate = 0;
		frameTick = 0;
		animsMap = null;
		loopType = null;
		symbolType = null;
		symbolDictionary = null;
	}
}