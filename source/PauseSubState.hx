package;

import Script.DummyScript;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import lime.utils.Assets;
import dev_toolbox.ToolboxHome;
import dev_toolbox.stage_editor.StageEditor;
import ControlsSettingsSubState;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import Script.HScript;

class PauseSubState extends MusicBeatSubstate
{
	public var grpMenuShit:FlxTypedGroup<Alphabet>;
	public var items(get, set):FlxTypedGroup<Alphabet>;
	function get_items() {return grpMenuShit;}
	function set_items(i) {return grpMenuShit = i;}

	public var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Change Keybinds', 'Options', 'Exit to menu'];
	public var curSelected:Int = 0;

	public var pauseMusic:FlxSound;
	public var script:Script;
	
	public var pauseMenuScript:Script = null;
	public var levelInfo:FlxText;
	public var levelDifficulty:FlxText;
	public var blueballAmount:FlxText;

	public var cam:FlxCamera;

	public var alpha:Float = 0;

	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.isStoryMode || PlayState.alternativeDifficulties == null || PlayState.alternativeDifficulties.length < 2) menuItems.remove("Change Difficulty");
		
		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		cam.bgColor = 0;
		FlxG.cameras.add(cam);
		var valid = true;
		script = Script.create('${Paths.modsPath}/${PlayState.songMod}/ui/PauseSubState');
		if (script == null) {
			valid = false;
			script = new DummyScript();
		}
		ModSupport.setScriptDefaultVars(script, PlayState.songMod, {});
		script.setVariable("preCreate", function() {});
		script.setVariable("create", function() {});
		script.setVariable("postCreate", function() {});
		script.setVariable("createPost", function() {});
		script.setVariable("preUpdate", function(elapsed) {});
		script.setVariable("update", function(elapsed) {});
		script.setVariable("postUpdate", function(elapsed) {});
		script.setVariable("onSelect", function(name) {}); // return false to cancel default
		script.setVariable("state", this); // return false to cancel default
		if (valid) {
			script.setScriptObject(this);
			script.loadFile('${Paths.modsPath}/${PlayState.songMod}/ui/PauseSubState');
		}
		script.executeFunc("preCreate");
		

		var p = Paths.music('breakfast', 'mods/${PlayState.songMod}');
		if (!Assets.exists(p)) p = Paths.music('breakfast');
		pauseMusic = new FlxSound().loadEmbedded(p, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);


		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		blueballAmount = new FlxText(20, 15 + 64, 0, "", 32);
		blueballAmount.text += 'Blueballed: ${PlayState.blueballAmount}';
		blueballAmount.scrollFactor.set();
		blueballAmount.setFormat(Paths.font('vcr.ttf'), 32);
		blueballAmount.updateHitbox();
		add(blueballAmount);

		levelDifficulty.alpha = levelInfo.alpha = blueballAmount.alpha = 0;

		levelInfo.x = Std.int(1280) - (levelInfo.width + 20);
		levelDifficulty.x = Std.int(1280) - (levelDifficulty.width + 20);
		blueballAmount.x = Std.int(1280) - (blueballAmount.width + 20);

		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballAmount, {alpha: 1, y: blueballAmount.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		if (CoolUtil.isDevMode())
			menuItems.insert(2, "Developer Options");
		
		script.executeFunc("create");
		
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [cam];
		script.executeFunc("postCreate");
		script.executeFunc("createPost");
	}

	override function update(elapsed:Float)
	{
		
		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballAmount.x = FlxG.width - (blueballAmount.width + 20);

		alpha = FlxMath.lerp(alpha, 0.6, 0.125 * elapsed * 60);

		cam.bgColor = FlxColor.fromRGBFloat(0, 0, 0, alpha);
		script.executeFunc("preUpdate", [elapsed]);
		cam.setSize(FlxG.width, FlxG.height);
		cam.scroll.x = -(FlxG.width - 1280) / 2;
		cam.scroll.y = -(FlxG.height - 720) / 2;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		script.executeFunc("update", [elapsed]);
		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			if (script.executeFunc("onSelect", [daSelected]) != false) {
				switch (daSelected)
				{
					case "Resume":
						close();
					case "Restart Song":
						FlxG.resetState();
					case "Change Keybinds":
						var s = new ControlsSettingsSubState(PlayState.SONG.keyNumber, cam);
						openSubState(s);
					case "Change Difficulty":

						var controlsList:Array<{label:String, callback:RightPane->Void}> = [];
						for(e in PlayState.alternativeDifficulties) {
							controlsList.push({
								label: e,
								callback: function(state) {
									state.close();
									CoolUtil.loadSong(PlayState.songMod, PlayState.SONG.song, e, PlayState.alternativeDifficulties);
									FlxG.resetState();
								}
							});
						}
						var pane = new RightPane("Difficulties", controlsList);
						pane.cameras = cameras;
						openSubState(pane);

					case "Developer Options":
						var controlsList:Array<{label:String, callback:RightPane->Void}> = [];
						var devMenuItems:Array<String> = ['Skip Song', 'Logs', 'Edit Opponent', 'Edit Player', 'Edit Stage'];
						controlsList.push({
							label: 'Skip Song',
							callback: function(t) {
								close();
								PlayState.current.endSong();
							}
						});
						controlsList.push({
							label: 'Logs (F6)',
							callback: function(t) {
								Main.logsOverlay.visible = !Main.logsOverlay.visible;
							}
						});
						controlsList.push({
							label: 'Edit Player',
							callback: function(t) {
								var split = PlayState.SONG.player1.split(":");
								dev_toolbox.character_editor.CharacterEditor.fromFreeplay = true;
								dev_toolbox.ToolboxHome.selectedMod = split[0];
								FlxG.switchState(new dev_toolbox.character_editor.CharacterEditor(split[1]));
							}
						});
						controlsList.push({
							label: 'Edit Opponent',
							callback: function(t) {
								var split = PlayState.SONG.player2.split(":");
								dev_toolbox.character_editor.CharacterEditor.fromFreeplay = true;
								dev_toolbox.ToolboxHome.selectedMod = split[0];
								FlxG.switchState(new dev_toolbox.character_editor.CharacterEditor(split[1]));
							}
						});
						if (PlayState.current.devStage != null) {
							controlsList.push({
								label: 'Edit Stage',
								callback: function(t) {
									var devStageSplit = PlayState.current.devStage.split(":");
									ToolboxHome.selectedMod = devStageSplit[0];
									StageEditor.fromFreeplay = true;
									FlxG.switchState(new StageEditor(devStageSplit[1]));
								}
							});
						}
						controlsList.push({
							label: 'Open charts folder',
							callback: function(t) {
								CoolUtil.openFolder('${Paths.modsPath}/${PlayState.songMod}/data/${PlayState.SONG.song}/');
							}
						});
						controlsList.push({
							label: 'Reload chart',
							callback: function(t) {
								CoolUtil.loadSong(PlayState.songMod, PlayState.SONG.song, PlayState.storyDifficulty, PlayState.alternativeDifficulties);
								FlxG.resetState();
							}
						});
						controlsList.push({
							label: 'Open Toolbox',
							callback: function(t) {
								FlxG.switchState(new ToolboxHome(PlayState.songMod));
							}
						});
						if (PlayState.fromCharter) 
							controlsList.push({
								label: 'Exit Charter Mode',
								callback: function(t) {
									CoolUtil.playMenuSFX(1);
									PlayState.fromCharter = false;
									PlayState.current.scoreWarning.text = "/!\\ Score will not be saved";
								}
							});

						var pane = new RightPane("Developer Options", controlsList);
						pane.cameras = cameras;
						openSubState(pane);
					case "Options":
						OptionsMenu.fromFreeplay = true;
						FlxG.switchState(new OptionsMenu(0, 0));
					case "Exit to menu":
						if (PlayState.fromCharter) {
							var m = new MenuMessage("Are you sure you want to exit back to the main menu? Any unsaved progress will be lost.", [
								{
									label: "No",
									callback: function() {}
								},
								{
									label: "Yes",
									callback: function() {
										FlxG.switchState(new MainMenuState());
										PlayState._SONG = null;
									}
								}
							]);
							m.cameras = cameras;
							openSubState(m);
						} else {
							FlxG.switchState(new MainMenuState());
							PlayState._SONG = null;
						}
				}
			}
			
		}
		script.executeFunc("updatePost", [elapsed]);
		script.executeFunc("postUpdate", [elapsed]);
	}

	override function destroy()
	{
		pauseMusic.destroy();
		FlxG.cameras.remove(cam);
		cam.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		var oldSelected = curSelected;
		curSelected += change;
		if (change != 0) CoolUtil.playMenuSFX(0);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		if (script.executeFunc("onChangeSelected", [curSelected]) != false) {		
			var bullShit:Int = 0;

			for (item in grpMenuShit.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;

				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}	
		} else {
			curSelected = oldSelected;
		}
	}
}
