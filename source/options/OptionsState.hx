package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{

    var kId = 0;
    var keys:Array<FlxKey> = [D, E, B, U, G, SEVEN]; // lol
var konamiIndex:Int = 0; // Track the progress in the Konami code sequence
	var konamiCode = [];
	var isEnteringKonamiCode:Bool = false;
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Optimization', 'Visuals and UI', 'Gameplay', 'Misc'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;
	public var enteringDebugMenu:Bool = false;
	private var mainCamera:FlxCamera;
	private var subCamera:FlxCamera;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
			#if android
			removeVirtualPad();
			#end
				openSubState(new options.NotesSubState());
			case 'Controls':
			#if android
			removeVirtualPad();
			#end
				openSubState(new options.ControlsSubState());
			case 'Graphics':
			#if android
			removeVirtualPad();
			#end
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
			#if android
			removeVirtualPad();
			#end
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
			#if android
			removeVirtualPad();
			#end
				openSubState(new options.GameplaySettingsSubState());
			case 'Optimization':
			#if android
			removeVirtualPad();
			#end
				openSubState(new options.OptimizationSubState());
			case 'Adjust Delay and Combo':
			#if android
			removeVirtualPad();
			#end
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
			case 'Misc':
			#if android
			removeVirtualPad();
			#end
				openSubState(new options.MiscSettingsSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var customizeAndroidControlsTipText:FlxText;
	var androidControlsStyleTipText:FlxText;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		mainCamera = new FlxCamera();
		subCamera = new FlxCamera();
		subCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(mainCamera);
		FlxG.cameras.add(subCamera, false);

		FlxG.cameras.setDefaultDrawTarget(mainCamera, true);
		CustomFadeTransition.nextCamera = subCamera;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		FlxG.camera.follow(camFollowPos, null, 1);

		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var yScroll:Float = Math.max(0.25 - (0.05 * (options.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		bg.scrollFactor.set(0, yScroll / 4);

		bg.screenCenter();
		bg.y -= 5;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.scrollFactor.set(0, yScroll*1.5);
			grpOptions.add(optionText);
		}
		//I TOOK THIS FROM THE MAIN MENU STATE, NOT FROM DENPA ENGINE
		selectorLeft = new Alphabet(0, 0, '>', true);
		selectorLeft.scrollFactor.set(0, yScroll*1.5);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		selectorRight.scrollFactor.set(0, yScroll*1.5);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		#if android
		addVirtualPad(LEFT_FULL, A_B_X_Y);
		virtualPad.y = -44;
		#end

		#if android
		androidControlsStyleTipText = new FlxText(10, FlxG.height - 44, 0, 'Press Y to customize your opacity for hitbox, virtual pads and hitbox style!', 16);
		customizeAndroidControlsTipText = new FlxText(10, FlxG.height - 24, 0, 'Press X to customize your android controls!', 16);
			androidControlsStyleTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			customizeAndroidControlsTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		androidControlsStyleTipText.borderSize = 1.25;
		androidControlsStyleTipText.scrollFactor.set();
		customizeAndroidControlsTipText.borderSize = 1.25;
		customizeAndroidControlsTipText.scrollFactor.set();
		add(androidControlsStyleTipText);
		add(customizeAndroidControlsTipText);
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var lerpVal:Float = CoolUtil.clamp(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK && !isEnteringKonamiCode) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(PauseSubState.inPause)
			{
				PauseSubState.inPause = false;
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}
		if (controls.ACCEPT && !isEnteringKonamiCode) {
			if (isEnteringKonamiCode) return;
			openSelectedSubstate(options[curSelected]);
		}
		#if android
		if (virtualPad.buttonX.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidControlsSubState());
		}
		if (virtualPad.buttonY.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidControlsSettingsSubState());
		}
		#end

        if (FlxG.keys.justPressed.ANY #if android || virtualPad.buttonUp.justPressed || virtualPad.buttonDown.justPressed || virtualPad.buttonLeft.justPressed || virtualPad.buttonRight.justPressed || virtualPad.buttonB.justPressed || virtualPad.buttonA.justPressed #end) {
            var k = keys[kId];
		#if android konamiCode = [virtualPad.buttonUp, virtualPad.buttonUp, virtualPad.buttonDown, virtualPad.buttonDown, virtualPad.buttonLeft, virtualPad.buttonRight, virtualPad.buttonLeft, virtualPad.buttonRight, virtualPad.buttonB, virtualPad.buttonA]; #end
            if (FlxG.keys.anyJustPressed([k]) #if android || !enteringDebugMenu && checkKonamiCode() #end) {
                #if desktop kId++; #end
                if (kId >= keys.length #if android || konamiIndex >= konamiCode.length #end) {
			enteringDebugMenu = true;
			kId = 0;
                    FlxTween.tween(FlxG.camera, {alpha: 0}, 1.5, {startDelay: 1, ease: FlxEase.cubeOut});
                    if (FlxG.sound.music != null)
                        FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, 2.5, {ease: FlxEase.cubeOut});
                    FlxTween.tween(FlxG.camera, {zoom: 0.1, angle: -15}, 2.5, {ease: FlxEase.cubeIn, onComplete: function(t) {
			FlxG.camera.angle = 0;
                        openSubState(new options.SuperSecretDebugMenu());
                    }});
                }
            }
        }

		#if android
		if (virtualPad.buttonC.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidControlsSubState());
		}
		#end
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			var thing:Float = 0;
			if (item.targetY == 0) {
				item.alpha = 1;
				if(grpOptions.members.length > 4) {
					thing = grpOptions.members.length * 8;
				}
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
				camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y - thing);
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
function checkKonamiCode():Bool {
    if (konamiCode[konamiIndex].justPressed) {
        konamiIndex++;
	if (konamiIndex > 6) isEnteringKonamiCode = true;
        if (konamiIndex >= konamiCode.length) {
            return true;
	    konamiIndex = 0;
        }
    } else { //you messed up the code
        konamiIndex = 0;
	isEnteringKonamiCode = false;
    }
    return false;
}
}