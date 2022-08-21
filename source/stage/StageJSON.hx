package stage;

typedef StageJSON = {
	var defaultCamZoom:Null<Float>;	
	var bfOffset:Array<Float>;	
	var gfOffset:Array<Float>;	
	var dadOffset:Array<Float>;
	var sprites:Array<StageSprite>;
	var followLerp:Null<Float>;
}