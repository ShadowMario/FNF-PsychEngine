typedef StoryMenuCharacter = {
	var file:String;
	var animation:String;
	var confirmAnim:String;
	var scale:Float;
	var flipX:Bool;
	var offset:Array<Float>;
}
typedef FNFWeek = {
	var name:String;
	var songs:Array<String>;
	@:optional var mod:String; // Set automatically, no need to worry
	var buttonSprite:String;
	var color:String;
	var dad:StoryMenuCharacter;
	var bf:StoryMenuCharacter;
	var gf:StoryMenuCharacter;
	var difficulties:Array<WeekDifficulty>;
	var selectSFX:String;
	@:optional var locked:Bool;
	var bg:String;
	var bgAnim:String;
}
typedef WeekDifficulty = {
	var name:String;
	var sprite:String;
}
typedef WeeksJson = {
	var weeks:Array<FNFWeek>;
}