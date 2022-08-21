package stage;

typedef StageSprite = {
	var name:String;
	var type:String;
	@:optional var animation:StageAnim;
	@:optional var src:String;
	@:optional var pos:Array<Float>;
	@:optional var antialiasing:Null<Bool>;
	var scrollFactor:Array<Float>;
	@:optional var scale:Null<Float>;
	@:optional var beatTween:BeatTween;
	@:optional var shader:String;
	@:optional var alpha:Null<Float>;
}