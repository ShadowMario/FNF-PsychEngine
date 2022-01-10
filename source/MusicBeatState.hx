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
	public static var musInstance:MusicBeatState;
	#if desktop
	public var scaleRatio = ClientPrefs.getResolution()[1] / 720;
	var modeRatio:RatioScaleMode;
	var modeStage:StageSizeScaleMode;
	#end
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
		// fixAspectRatio();
		
		
		if(!skip) {
			openSubState(new CustomFadeTransition(1, true));
		}
		FlxTransitionableState.skipNextTransOut = false;

		// FlxG.signals.gameResized.add(onGameResized);
		// this makes the game crash immediately for some reason, i'll try to figure it out later but this would allow
		// resizing the window and having the aspect ratio update with it
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
			
			
		/*
		if (FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ENTER){//to disable this fucker
			FlxG.fullscreen = !FlxG.fullscreen;
		}
		*/ // this fucker should remain enabled bruh being able to toggle fullscreen at any point is a good feature
		   // regardless this is a janky and bad way to do this, like, please don't ever do this
		   // the visual effect this causes is going to make every person ever think this is a glitch

		if (FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ENTER && FlxG.fullscreen && ClientPrefs.screenScaleMode == "ADAPTIVE") {
			FlxG.fullscreen = false;
		} // only disabling this when adaptive is enabled is better as a warning about jankiness is given for adaptive anyways
			

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
					musInstance.fixAspectRatio();
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					musInstance.fixAspectRatio();
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

	
	public function fixAspectRatio() {
		// options.GraphicsSettingsSubState.onChangeRes();

		if (ClientPrefs.screenScaleMode == "LETTERBOX") {
			FlxG.scaleMode = new RatioScaleMode (false);
		} else if (ClientPrefs.screenScaleMode == "PAN") {
			FlxG.scaleMode = new RatioScaleMode (true);
		} else if (ClientPrefs.screenScaleMode == "STRETCH") {
			FlxG.scaleMode = new FillScaleMode ();
		} else if (ClientPrefs.screenScaleMode == "ADAPTIVE") {
			FlxG.scaleMode = modeStage;
		}

		//FlxG.scaleMode = modeStage; // https://coinflipstudios.com/devblog/?p=418#:~:text=StageSizeScaleMode%C2%A0%C2%A0
		//if (FlxG.fullscreen) FlxG.scaleMode = modeRatio;
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
