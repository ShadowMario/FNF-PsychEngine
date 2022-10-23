package flxanimate.data;

typedef AnimateAtlas =
{
	var ATLAS:AnimateSprites;
	var meta:Meta;
}

typedef AnimateSprites =
{
	var SPRITES:Array<AnimateSprite>;
}

typedef AnimateSprite =
{
	var SPRITE:AnimateSpriteData;
}

typedef AnimateSpriteData =
{
	var name:String;
	var x:Float;
	var y:Float;
	var w:Int;
	var h:Int;
	var rotated:Bool;
}
@:forward
abstract Meta({var app:String; var version:String; var image:String; var format:String; var size:Size;})
{
	public var resolution(get, never):String;

	inline function get_resolution()
	{
		return AnimationData.setFieldBool(this, ["resolution", "scale"]);
	}
}

typedef Size =
{
	var w:Int;
	var h:Int;
}
