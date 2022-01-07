package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.system.scaleModes.*;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	public var scaleRatio = ClientPrefs.getResolution()[1] / 720;
	public static var musInstance:MusicBeatState;
	var modeRatio:RatioScaleMode;
	var modeStage:StageSizeScaleMode;
	
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();
musInstance = this;
		// Custom made Trans out
		
		modeRatio = new RatioScaleMode();
		modeStage = new StageSizeScaleMode();
		
//	thx Cary for the res code < 333
		
		
		if(!skip) {
			openSubState(new CustomFadeTransition(1, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}
	
	#if (VIDEOS_ALLOWED && windows)
	override public function onFocus():Void
	{
		FlxVideo.onFocus();
		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		FlxVideo.onFocusLost();
		super.onFocusLost();
	}
	#end

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();
			
			
			
		if (FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ENTER){//to disable this fucker
			FlxG.fullscreen = !FlxG.fullscreen;
		}
			
			

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.7, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					musInstance.onStateSwitch();
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					musInstance.onStateSwitch();
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public function onStateSwitch(){
		
		options.GraphicsSettingsSubState.onChangeRes();
		FlxG.scaleMode = modeStage;

		if (FlxG.fullscreen)FlxG.scaleMode = modeRatio;
	}
	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
