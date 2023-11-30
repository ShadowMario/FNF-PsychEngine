package;

import flixel.addons.transition.FlxTransitionableState;
import backend.Highscore;
import states.FlashingState;

// THIS IS FOR INITIALIZING STUFF BECAUSE FLIXEL HATES INITIALIZING STUFF IN MAIN
// GO TO MAIN FOR GLOBAL PROJECT/OPENFL STUFF
class Init extends flixel.FlxState {
	override function create():Void {
		FlxTransitionableState.skipNextTransOut = true;
		Paths.clearStoredMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		FlxG.updateFramerate = FlxG.drawFramerate = ClientPrefs.data.framerate;

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		Highscore.load();

		if (FlxG.save.data.weekCompleted != null) states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		super.create();

		if (FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;

		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else FlxG.switchState(Type.createInstance(Main.game.initialState, []));
	}
}