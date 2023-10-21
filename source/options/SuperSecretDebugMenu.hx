package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
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

class SuperSecretDebugMenu extends BaseOptionsMenu
{
	public function new()
	{
		FlxG.mouse.visible = true;
        FlxG.camera.zoom = 10;
        FlxG.camera.alpha = 0;
        FlxTween.tween(FlxG.camera, {zoom: 1, alpha: 1}, 2, {ease: FlxEase.quartOut});
		title = 'Secret Debug Menu';
		rpcTitle = 'Super Secret Debug Menu!!'; //for Discord Rich Presence

		var option:Option = new Option('Rainbow Notes',
			"If checked, notes will be rainbow..ized. Yeah i don't \nquite have any actual description of what this does so yeah",
			'rainbowNotes',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('No Ascend RNG',
			"If checked, makes the RNG Guns ascend part play every time.",
			'noGunsRNG',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Playback Rate Controls',
			"If checked, allows you to control the playback rate in PlayState \nwithout the need for the Pause Menu.",
			'pbRControls',
			'bool',
			false);
		addOption(option);

		/*
		var option:Option = new Option('Note Motion Blur',
			"If checked, notes will go BLURRRR",
			'noteMotionBlur',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Motion Blur Mult: ',
			"Multiplier for motion blur. If you still feel like the notes stutter, this can help.\nHigher values mean blurrier notes.",
			'noteMBMult',
			'float',
			1);
		addOption(option);
		*/ //while this did work the hsv behaved incorrectly
		option.scrollSpeed = 2.2;
		option.minValue = 0.1;
		option.maxValue = 10;
		option.changeValue = 0.1;
		option.decimals = 2;
		option.displayFormat = '%vx';

		var option:Option = new Option('Crash the Engine',
			"Select this to crash the engine.",
			'crashEngine',
			'bool',
			false);

		option.onChange = crashDaEngine;
		addOption(option);

		super();
	}
	function crashDaEngine():Void {
                    var i:Int = -1;
                    var messages = [
                        "Are you sure?",
                        "Are you really sure?",
                        "fr??",
                        "this is a one way go, are you really really sure?",
                        "i cant believe you. are you REALLY sure about that?",
                        "select no if you're sure about it.",
                        "are you really really sure?",
                        "there may be something left unsaved. Are you really really really sure?",
                        "i think they want me to stfu",
                        "yeah they do.",
                        "really really really sure????",
                        "really sure? last warning",
                        "i lied MUAHAHHAHAHAHAHAA",
                        "are you really really really sure?",
                        "last warning (fr this time)",
                        "are you sure?",
                        "Fredbear's Family Diner William Afton and Henry opened in 1967 the family friendly Fredbear's Family Diner, featuring a brown furry suit of a bear as a mascot. Henry would usually wear the suit, as they didn't have enough money to hire someone to do the job for a long time and they were studying at the time. William studied engineering and Henry business adminstration and communication. William met an unnamed woman, with whom he married and three years later had a boy challed Michael. They met in the court; William was being charged for murdering a child that allegedly was crying outside the Diner for being scared of Fredbear, the bear, and she was working selling hot-dogs in from of the building.",
                        "im not funny",
                        "mfw",
                        "how did you even find this option",
                        "what have you done to get here",
                        "anyways",
                        "are you sure?"
                    ];
    var nextMessage:Void->Void = null;
    
    nextMessage = function() {
        i++;
        if (i >= messages.length) {
                           var e:MusicBeatState = null;
                            @:privateAccess
                            e.update(0);
        } else {
            openSubState(new Prompt(messages[i], 0, function() {nextMessage();}, null, false, "Yes", "No"));
        }
    }
    
    nextMessage();
	}
}
