package dev_toolbox.stage_editor;

import stage.BeatTween;
import stage.OnBeatTweenSprite;
import stage.StageAnim;
import flixel.FlxSprite;

class FlxStageSprite extends FlxSprite {
    public var name:String = null;
    public var animType:String = "loop";
    public var type:String = "Bitmap";
    public var anim:StageAnim = null;
    public var spritePath:String = "";
    public var shaderName:String;
    public var onBeatOffset:BeatTween;
}