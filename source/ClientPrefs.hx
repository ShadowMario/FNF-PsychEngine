package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var hideTime:Bool = false;

	//Every key has two binds, these binds are defined on defaultKeys! If you want your control to be changeable, you have to add it on ControlsSubState (inside OptionsState.hx)'s list
	public static var keyBinds:Map<Control, Dynamic> = new Map<Control, Dynamic>();
	public static var defaultKeys:Map<Control, Dynamic>;

	public static function startControls() {
		//Key Bind, Name for ControlsSubState
		keyBinds.set(Control.NOTE_LEFT, [A, LEFT]);
		keyBinds.set(Control.NOTE_DOWN, [S, DOWN]);
		keyBinds.set(Control.NOTE_CENTER_5k, [SPACE, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_UP, [W, UP]);
		keyBinds.set(Control.NOTE_RIGHT, [D, RIGHT]);

		// 6k 7k
		keyBinds.set(Control.NOTE_1_6k, [S, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_2_6k, [D, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_3_6k, [F, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_CENTER_7k, [SPACE, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_4_6k, [H, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_5_6k, [J, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_6_6k, [K, FlxKey.NONE]);

		// 8k 9k
		keyBinds.set(Control.NOTE_1_8k, [A, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_2_8k, [S, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_3_8k, [D, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_4_8k, [F, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_CENTER_9k, [SPACE, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_5_8k, [H, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_6_8k, [J, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_7_8k, [K, FlxKey.NONE]);
		keyBinds.set(Control.NOTE_8_8k, [L, FlxKey.NONE]);

		keyBinds.set(Control.UI_LEFT, [A, LEFT]);
		keyBinds.set(Control.UI_DOWN, [S, DOWN]);
		keyBinds.set(Control.UI_UP, [W, UP]);
		keyBinds.set(Control.UI_RIGHT, [D, RIGHT]);

		keyBinds.set(Control.ACCEPT, [SPACE, ENTER]);
		keyBinds.set(Control.BACK, [BACKSPACE, ESCAPE]);
		keyBinds.set(Control.PAUSE, [ENTER, ESCAPE]);
		keyBinds.set(Control.RESET, [R, FlxKey.NONE]);


		// Don't delete this
		defaultKeys = keyBinds.copy();
	}

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		//FlxG.save.data.cursing = cursing;
		//FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.hideTime = hideTime;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.imagesPersist != null) {
			imagesPersist = FlxG.save.data.imagesPersist;
			FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.hideTime != null) {
			hideTime = FlxG.save.data.hideTime;
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<Control, Dynamic> = save.data.customControls;
			if(loadedControls != null) { // Old format check
				for (control => keys in loadedControls) {
					keyBinds.set(control, keys);
				}
				reloadControls();
			}
		}
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);
	}
}