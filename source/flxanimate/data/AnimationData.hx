package flxanimate.data;


@:noCompletion
class AnimationData
{
	public static var filters = new flxanimate.Filters();
	public static var version:String;
	public static var resolution:String;
	@:noCompletion
	public static function setFieldBool(abstracto:Dynamic, things:Array<String>, ?set:Dynamic):Dynamic
	{
		//TODO: The comment below this comment.
		// GeoKureli told me that Reflect is shit, but I have literally no option but to use this.
		// If I have another thing to use that works the same, should replace this lol
		if (abstracto == null)
			return Reflect.field({}, "");
		for (thing in things)
		{
			if (set != null)
			{
				Reflect.setField(abstracto, thing, set);
				return set;
			}
			if (Reflect.hasField(abstracto, thing))
			{
				return Reflect.field(abstracto, thing);
			}
		}

		return Reflect.field(abstracto, "");
	}
}

abstract AnimAtlas({}) from {}
{
	/**
	 * The main thing, the animation that makes the different drawings animate together and shit
	 */
	public var AN(get, never):Animation;
	/**
	 * This collects the symbols and gets it into weird stuff so it can be used on the anim, **WARNING:** Can be `Null` or `undefined`
	 */
	public var SD(get, never):SymbolDictionary;
	/**
	 * Minor stuff, this checks the framerate the anim is and nothing much tbh
	 */
	public var MD(get, never):MetaData;

	function get_AN():Animation
	{
		return AnimationData.setFieldBool(this, ["AN", "ANIMATION"]);
	}

	function get_MD():MetaData
	{
		return AnimationData.setFieldBool(this, ["MD", "metadata"]);
	}
	function get_SD()
	{
		return AnimationData.setFieldBool(this, ["SD", "SYMBOL_DICTIONARY"]);
	}
}
/**
 * The list of symbols that the anim uses
 */
abstract SymbolDictionary({}) from {}
{
	/**
	 * The list of Symbols used in an animation
	 */
	public var S(get, never):Array<SymbolData>;

	function get_S():Array<SymbolData>
	{
		return AnimationData.setFieldBool(this, ["S", "Symbols"]);
	}
}
/**
 * The main animation Thing
 */
abstract Animation({}) from {}
{
	/**
	 * The name of the symbol
	 */
	public var SN(get, never):String;
	/**
	 * The name of the document which was exported
	 */
	public var N(get, never):String;
	/**
	 * The timeline of the animation which was exported
	 */
	public var TL(get, never):Timeline;
	/**
	 * Optional: Some docs have an STI, which idk what is it tbh
	 */
	public var STI(get, never):StageInstance;

	function get_SN():String 
	{
		return AnimationData.setFieldBool(this, ["SN", "SYMBOL_name"]);
	}
	function get_N():String
	{
		return AnimationData.setFieldBool(this, ["N", "name"]);
	}
	function get_TL():Timeline
	{
		return AnimationData.setFieldBool(this, ["TL", "TIMELINE"]);
	}
	function get_STI()
	{
		return AnimationData.setFieldBool(this, ["STI", "StageInstance"]);
	}
}

abstract StageInstance({}) 
{
	public var SI(get, never):SymbolInstance;

	function get_SI():SymbolInstance
	{
		return AnimationData.setFieldBool(this, ["SI", "SYMBOL_Instance"]);
	}
}
/**
 * the SymbolData that the symbol has for checking stuff
 */
abstract SymbolData({}) from {}
{
	/**
	 * The name of the symbol
	 */
	public var SN(get, never):String;
	/**
	 * The timeline of the Symbol, aka the frames of the symbols, with all the layers and stuff
	 */
	public var TL(get, never):Timeline;

	function get_SN():String 
	{
		return AnimationData.setFieldBool(this, ["SN", "SYMBOL_name"]);
	}
	function get_TL():Timeline
	{
		return AnimationData.setFieldBool(this, ["TL", "TIMELINE"]);
	}
}
/**
 * The timeline that the animation is based
 */
abstract Timeline({}) from {}
{
	/**
	 * The layers that are in the timeline
	 */
	public var L(get, set):Array<Layers>;

	function get_L():Array<Layers>
	{
		return AnimationData.setFieldBool(this, ["L", "LAYERS"]);
	}
	function set_L(value:Array<Layers>)
	{
		return AnimationData.setFieldBool(this, ["L", "LAYERS"], value);
	}
}
/**
 * the Layer abstract, nothing much to say here
 */
abstract Layers({}) from {}
{
	/**
	 * The name of the layer.
	 */
	public var LN(get, never):String;
	/**
	 * The frames that the layer has.
	 */
	public var FR(get, set):Array<Frame>;

	function get_LN():String
	{
		
		return AnimationData.setFieldBool(this, ["LN", "Layer_name"]);
	}
	function get_FR():Array<Frame>
	{
		return AnimationData.setFieldBool(this, ["FR", "Frames"]);
	}
	function set_FR(value:Array<Frame>):Array<Frame>
	{
		return AnimationData.setFieldBool(this, ["FR", "Frames"], value);
	}
}
/**
 * Only has the framerate for some reason
 */
abstract MetaData({}) from {}
{
	
	/**
	 * Framerate of the anim, nothing much here.
	 */
	public var FRT(get, never):Float;
	
	function get_FRT()
	{
		return AnimationData.setFieldBool(this, ["FRT", "framerate"]);
	}
}
/**
 * the frame abstract that has the essential
 */
abstract Frame({}) from {}
{
	/**
	 * The "name of the frame", basically labels that you can use as thingies for more cool stuff to program lol
	 */
	public var N(get, never):String;
	/**
	 * The frame index, aka the current number frame.
	 */
	public var I(get, never):Int;
	/**
	 * The duration of the frame.
	 */
	public var DU(get, never):Int;
	/**
	 * The elements that the frame has. Drawings/symbols to be specific
	 */
	public var E(get, never):Array<Element>;

	/**
	 * The Color Effect of the symbol, it says color but it affects alpha too lol.
	 */
	public var C(get, set):ColorEffects;

	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):Filters;

	function get_N():String
	{
		return AnimationData.setFieldBool(this, ["N", "name"]);
	}
	function get_I():Int
	{
		return AnimationData.setFieldBool(this, ["I", "index"]);
	}
	function get_DU():Int
	{
		return AnimationData.setFieldBool(this, ["DU", "duration"]);
	}
	function get_E():Array<Element>
	{
		return AnimationData.setFieldBool(this, ["E", "elements"]);
	}
	function get_C()
	{
		return AnimationData.setFieldBool(this, ["C", "color"]);
	}
	function set_C(value:ColorEffects)
	{
		return AnimationData.setFieldBool(this, ["C", "color"], value);
	}

	function get_F()
	{
		return AnimationData.setFieldBool(this, ["F", "filters"]);
	}
}
/**
 * The Element thing inside the frame
 */
@:forward
abstract Element(StageInstance)
{
	/*
	 * the Sprite of the animation, aka the non Symbol.
	 */
	public var ASI(get, never):AtlasSymbolInstance;

	function get_ASI():AtlasSymbolInstance
	{
		return AnimationData.setFieldBool(this, ["ASI", "ATLAS_SPRITE_instance"]);
	}
}
/**
 * The Symbol Abstract
 */
abstract SymbolInstance({}) from {}
{
	/**
	 * the name of the symbol.
	 */
	public var SN(get, never):String;

	/**
	 * the name instance of the Symbol.
	 */
	public var IN(get, never):String;
	/**
	 * the type of symbol,
	 * Which can be a:
	 * - Graphic
	 * - MovieClip
	 * - Button
	 */
	public var ST(get, never):SymbolType;

	/**
	 * bitmap Settings, Used in 2018 and 2019
	 */
	public var bitmap(get, never):Bitmap;

	/**
	 * this sets on which frame it's the symbol, Graphic only
	 */
	public var FF(get, never):Int;
	/**
	 * the Loop Type of the symbol, which can be:
	 * - Loop
	 * - Play Once
	 * - Single Frame
	 */
	public var LP(get, never):LoopType;
	/**
	 * the Transformation Point of the symbol, basically the pivot that determines how it scales or not in Flash
	 */
	public var TRP(get, never):TransformationPoint;
	/**
	 * The Matrix of the Symbol, Be aware from Neo! He can be anywhere!!! :fearful:
	 */
	public var M3D(get, never):OneOfTwo<Array<Float>, Matrix3D>;
	/**
	 * The Color Effect of the symbol, it says color but it affects alpha too lol.
	 */
	public var C(get, set):ColorEffects;

	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):Filters;

	function get_SN()
	{
		return AnimationData.setFieldBool(this, ["SN", "SYMBOL_name"]);
	}

	function get_IN()
	{
		return AnimationData.setFieldBool(this, ["IN", "Instance_Name"]);
	}

	function get_ST()
	{
		return AnimationData.setFieldBool(this, ["ST", "symbolType"]);
	}

	function get_bitmap()
	{
		return AnimationData.setFieldBool(this, ["BM", "bitmap"]);
	}
	function get_FF()
	{
		return AnimationData.setFieldBool(this, ["FF", "firstFrame"]);
	}

	function get_LP()
	{
		return AnimationData.setFieldBool(this, ["LP", "loop"]);
	}

	function get_TRP()
	{
		return AnimationData.setFieldBool(this, ["TRP", "transformationPoint"]);
	}

	function get_M3D()
	{
		return AnimationData.setFieldBool(this, ["M3D", "Matrix3D"]);
	}

	function get_C()
	{
		return AnimationData.setFieldBool(this, ["C", "color"]);
	}
	function set_C(value:ColorEffects)
	{
		return AnimationData.setFieldBool(this, ["C", "color"], value);
	}

	function get_F()
	{
		return AnimationData.setFieldBool(this, ["F", "filters"]);
	}
}
abstract ColorEffects({}) from {}
{
	/**
	 * What type of Effect is it.
	 */
	public var M(get, never):ColorMode;
	/**
	 * tint Color, basically, How's the color gonna be lol.
	 */
	public var TC(get, never):String;
	/**
	 * tint multiplier, or the alpha of **THE COLOR!** Don't forget that.
	 */
	public var TM(get, never):Float;

	public var AM(get, never):Float;
	public var AO(get, never):Int;

	// Red Multiplier and Offset
	public var RM(get, never):Float;
	public var RO(get, never):Int;
	// Green Multiplier and Offset
	public var GM(get, never):Float;
	public var GO(get, never):Int;
	// Blue Multiplier and Offset
	public var BM(get, never):Float;
	public var BO(get, never):Int;

	public var BRT(get, never):Float;

	function get_M()
	{
		return AnimationData.setFieldBool(this, ["M", "mode"]);
	}
	function get_TC()
	{
		return AnimationData.setFieldBool(this, ["TC", "tintColor"]);
	}
	function get_TM()
	{
		return AnimationData.setFieldBool(this, ["TM", "tintMultiplier"]);
	}
	function get_AM()
	{
		return AnimationData.setFieldBool(this, ["AM", "alphaMultiplier"]);
	}
	function get_AO()
	{
		return AnimationData.setFieldBool(this, ["AO", "AlphaOffset"]);
	}
	function get_RM()
	{
		return AnimationData.setFieldBool(this, ["RM", "RedMultiplier"]);
	}
	function get_RO()
	{
		return AnimationData.setFieldBool(this, ["RO", "redOffset"]);
	}
	function get_GM()
	{
		return AnimationData.setFieldBool(this, ["GM", "greenMultiplier"]);
	}
	function get_GO()
	{
		return AnimationData.setFieldBool(this, ["GO", "greenOffset"]);
	}
	function get_BM()
	{
		return AnimationData.setFieldBool(this, ["BM", "blueMultiplier"]);
	}
	function get_BO()
	{
		return AnimationData.setFieldBool(this, ["BO", "blueOffset"]);
	}
	function get_BRT()
	{
		return AnimationData.setFieldBool(this, ["BRT", "Brightness"]);
	}
}
abstract Filters({})
{
	/**
	 * Adjusting the color filter... This is the filter which has small support, the rest doesn't have a shit
	 */
	public var ACF(get, never):AdjustColorFilter;

	function get_ACF()
	{
		return AnimationData.setFieldBool(this, ["ACF", "AdjustColorFilter"]);
	}
}
// The filters aren't looked much lol
abstract AdjustColorFilter({})
{
	public var BRT(get, never):Float;
	public var CT(get, never):Float;
	public var SAT(get, never):Float;
	public var H(get, never):Float;

	function get_BRT()
	{
		return AnimationData.setFieldBool(this, ["BRT", "brightness"]);
	}
	function get_CT()
	{
		return AnimationData.setFieldBool(this, ["CT", "contrast"]);
	}
	function get_SAT()
	{
		return AnimationData.setFieldBool(this, ["SAT", "saturation"]);
	}
	function get_H()
	{
		return AnimationData.setFieldBool(this, ["H", "hue"]);
	}
}

enum abstract ColorMode(String) from String to String
{
	var Tint = "T";
	var Advanced = "AD";
	var Alpha = "CA";
	var Brightness = "CBRT";
}
abstract Bitmap({}) from {}
{
	/**
	 * The name of the drawing, basically determines which one of the sprites on spritemap should be used.
	 */
	public var N(get, never):String;

	/**
	 * Only used in earliest versions of texture atlas release. checks the position, nothing else lol
	 */
	public var POS(get, never):TransformationPoint;
	function get_N()
	{
		return AnimationData.setFieldBool(this, ["N", "name"]);
	}
	function get_POS()
	{
		return AnimationData.setFieldBool(this, ["POS", "Position"]);
	}
}
/**
 * The Sprite/Drawing abstract
 */
@:forward
abstract AtlasSymbolInstance(Bitmap) from {}
{
	/**
	 * The matrix of the Sprite, Neo should be here at any second!!!
	 */
	public var M3D(get, never):OneOfTwo<Array<Float>, Matrix3D>;

	function get_M3D()
	{
		return AnimationData.setFieldBool(this, ["M3D", "Matrix3D"]);
	}
}

typedef Matrix3D = 
{
	var m00:Float; 
	var m01:Float; 
	var m02:Float; 
	var m03:Float; 
	var m10:Float;
	var m11:Float;
	var m12:Float;
	var m13:Float;
	var m20:Float;
	var m21:Float;
	var m22:Float;
	var m23:Float;
	var m30:Float;
	var m31:Float;
	var m32:Float;
	var m33:Float;
}
/**
 * Position Stuff
 */
typedef TransformationPoint = 
{
	var x:Float;
	var y:Float;
}

typedef BlurFilterS = {
	var BLX:Float;
	var BLY:Float;
	var Q:Int;
}
enum abstract LoopType(String) from String to String
{
	var loop = "LP";
	var playonce = "PO";
	var singleframe = "SF";
}

enum abstract SymbolType(String) from String to String
{
	var graphic = "G";
	var movieclip = "MC";
	var button = "B";
}
@:forward
abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}