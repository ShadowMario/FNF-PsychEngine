package;

import charter.YoshiCrafterCharter;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.Transition;
import flixel.FlxSubState;
import dev_toolbox.ToolboxMessage;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import lime.graphics.Image;
import lime.utils.Assets;
import lime.app.Application;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.addons.transition.TransitionData;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;

typedef FlxSpriteTypedGroup = FlxTypedGroup<FlxSprite>;
typedef FlxSpriteArray = Array<FlxSprite>;


@:allow(mod_support_stuff.SwitchModSubstate)
class MusicBeatState extends FlxUIState
{
	public static var __firstStateLoaded:Bool = false;
	public static var medalOverlay:Array<MedalsOverlay> = [];
	private var reloadModsState:Bool = false;

	private static var doCachingShitNextTime:Bool = false;
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curDecStep:Float = 0;
	private var curBeat:Int = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var defaultIcon:Image = null;

	public var lastElapsed:Float = 0;

	public override function onFocus() {
		if (reloadModsState) {
			super.onFocus();
			if (Settings.engineSettings.data.alwaysCheckForMods) if (ModSupport.reloadModsConfig(false, false)) FlxG.resetState();	
		}
	}

	public override function destroy() {
		super.destroy();
	}

	var oldPersistStuff:Map<FlxGraphic, Bool> = [];
	public function new(?transIn:TransitionData, ?transOut:TransitionData) {
		ModSupport.updateTitleBar();
		ModSupport.refreshDiscordRpc();
		ModSupport.updateCursor();
		ModSupport.reloadModsConfig(false, true, false, CoolUtil.isDevMode());
		Settings.engineSettings.flush();

		LimeAssets.loggedRequests = [];

		if (doCachingShitNextTime) {
			if (__firstStateLoaded) {
				LimeAssets.logRequests = true;
				@:privateAccess
				for(e in FlxG.bitmap._cache) {
					oldPersistStuff[e] = e.persist;
					e.persist = true;
				}
			} else
				__firstStateLoaded = true;
		} else {
			doCachingShitNextTime = true;
		}
		
		super(transIn, transOut);
	}

	override function createPost() {
		super.createPost();
		if (LimeAssets.logRequests) {
			
			LimeAssets.logRequests = false;

			for(k=>e in oldPersistStuff) {
				k.persist = e;
			}
			
			FlxG.bitmap.clearCache();

			try {
				Assets.cache.clearExceptArray(LimeAssets.loggedRequests);
			} catch(e) {
				trace(e);
			}
			

			oldPersistStuff = [];

			LimeAssets.loggedRequests = [];
		}
	}

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public function doResizeShit() {return true;}
	
	override function create()
	{
		if (!Std.isOfType(FlxG.scaleMode, WideScreenScale)) {
			FlxG.scaleMode = new WideScreenScale(); // still here cause resize and shit
		}
		var scl:WideScreenScale = cast FlxG.scaleMode;
        scl.isWidescreen = Settings.engineSettings.data.secretWidescreenSweep;

		var width = 1280;
		var height = 720;
		var conf = ModSupport.modConfig[Settings.engineSettings.data.selectedMod];
		if (conf != null) {
			if (conf.gameWidth != null && conf.gameWidth > 0) width = conf.gameWidth;
			if (conf.gameHeight != null && conf.gameHeight > 0) height = conf.gameHeight;
		}
        scl.width = width;
		scl.height = height;

		super.create();
		if (Settings.engineSettings != null) {
			FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
			FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
		}

	}
	
	override function draw() {
		super.draw();
		if (!Std.isOfType(subState, MusicBeatSubstate)) {
			for(k=>m in MusicBeatState.medalOverlay) {
				m.y = 110 * k;
				m.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				m.draw();
			}
		}
	}

	override function update(elapsed:Float)
	{
		lastElapsed = elapsed;
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();
		
		if (oldStep < curStep && curStep > 0)
			stepHit();
		
		super.update(elapsed);
		
		if (MusicBeatState.medalOverlay != null) {
			for(k=>m in MusicBeatState.medalOverlay) {
				m.y = 110 * k;
				m.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				m.update(elapsed);
			}
		}
	}

	private function updateBeat():Void
	{
		curDecBeat = curDecStep / 4;
		curBeat = Std.int(curDecBeat);
	}

	private function updateCurStep():Void
	{
		curStep = Std.int(curDecStep = getStepAtPos(Conductor.songPosition));
	}

	function getStepAtPos(t:Float) {
		var lastChange = getLastChange(t);
		var bpm = Conductor.bpm;
		if (Std.isOfType(FlxG.state, PlayState) && PlayState.SONG != null) {
			bpm = PlayState.SONG.bpm;
		} else if (Std.isOfType(FlxG.state, YoshiCrafterCharter) && YoshiCrafterCharter._song != null) {
			bpm = YoshiCrafterCharter._song.bpm;
		}

		return lastChange.stepTime + ((t - lastChange.songTime) / (lastChange.bpm == 0 ? (60 / bpm * 250) : ((60 / lastChange.bpm) * 250)));
	}

	private function getLastChange(t:Float) {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		if (Conductor.bpmChangeMap != null) {
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (t >= Conductor.bpmChangeMap[i].songTime)
					lastChange = Conductor.bpmChangeMap[i];
			}
		}
		return lastChange;
	}

	private function getLastChangeForStep(step:Float) {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		
		if (Conductor.bpmChangeMap != null) {
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (step >= Conductor.bpmChangeMap[i].stepTime)
					lastChange = Conductor.bpmChangeMap[i];
			}
		}
		return lastChange;
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

	public function onDropFile(path:String) {
		
	}

    public function showMessage(title:String, text:String) {
        var m = ToolboxMessage.showMessage(title, text);
        m.cameras = cameras;
        openSubState(m);
    }

	public override function openSubState(state:FlxSubState) {
		if (subState != null) {
			if (Std.isOfType(subState, Transition))  {
				closeSubState();
			}
		}
		persistentUpdate = false;
		super.openSubState(state);
	}
}
