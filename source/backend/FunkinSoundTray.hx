package backend;

#if BASE_GAME_FILES
import haxe.io.Bytes;
import openfl.utils.AssetType;
import flixel.tweens.FlxTween;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.system.ui.FlxSoundTray;

/**
 *  V-Slice SoundTray
 *  Wouldn't say this is the best way of implementing this, but it works. // oops spelling error!!!
 *  Also Supports The Mods Folders
 *  only shows when you have base game assets enabled.
 */
class FunkinSoundTray extends FlxSoundTray
{
	var graphicScale:Float = 0.30;
	var lerpYPos:Float = 0;
	var alphaTarget:Float = 0;

	var volumeMaxSound:String;

	public function new()
	{
		// calls super, then removes all children to add our own
		// graphics
		super();
		removeChildren();

		var bg:Bitmap = new Bitmap(getImage("images/soundtray/volumebox"));
		bg.scaleX = graphicScale;
		bg.scaleY = graphicScale;
		addChild(bg);

		y = -height;
		visible = false;

		// makes an alpha'd version of all the bars (bar_10.png)
		var backingBar:Bitmap = new Bitmap(getImage('images/soundtray/bars_10'));
		backingBar.x = 9;
		backingBar.y = 5;
		backingBar.scaleX = graphicScale;
		backingBar.scaleY = graphicScale;
		addChild(backingBar);
		backingBar.alpha = 0.4;

		// clear the bars array entirely, it was initialized
		// in the super class
		_bars = [];

		// 1...11 due to how block named the assets,
		// we are trying to get assets bars_1-10
		for (i in 1...11)
		{
			var bar:Bitmap = new Bitmap(getImage('images/soundtray/bars_$i'), false);
			bar.x = 9;
			bar.y = 5;
			bar.scaleX = graphicScale;
			bar.scaleY = graphicScale;
			addChild(bar);
			_bars.push(bar);
		}

		y = -height;
		screenCenter();

		volumeUpSound = 'Volup';
		volumeDownSound = 'Voldown';
		volumeMaxSound = 'VolMAX';
	}

	function getImage(path:String):Dynamic
	{
		final imagePath = Paths.getPath('$path.png', IMAGE);
		#if MODS_ALLOWED
		return BitmapData.fromFile(imagePath);
		#end
		return Assets.getBitmapData(imagePath);
	}

	// see the probl;em
	function getSound(path):openfl.media.Sound
	{
		final currentPsychEngineVersion:Int = Std.parseInt(states.MainMenuState.psychEngineVersion);

		final key:String = 'soundtray/$path';
		if (currentPsychEngineVersion < 1.0) // hopefully thats how it works :3  
			return Paths.returnSound('sounds', key);
		return Paths.returnSound('sounds/$key');

		// make sure the engine version doesn't have any letters in it.
	}

	override public function update(MS:Float):Void
	{
		y = CoolUtil.coolLerp(y, lerpYPos, 0.1);
		alpha = CoolUtil.coolLerp(alpha, alphaTarget, 0.25);

		// Animate sound tray thing
		if (_timer > 0)
		{
			_timer -= (MS / 1000);
			alphaTarget = 1;
		}
		else if (y >= -height)
		{
			lerpYPos = -height - 10;
			alphaTarget = 0;
		}

		if (y <= -height)
		{
			visible = false;
			active = false;

			#if FLX_SAVE
			// Save sound preferences
			if (FlxG.save.isBound)
			{
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
			#end
		}
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	up Whether the volume is increasing.
	 */
	override public function show(up:Bool = false):Void
	{
		_timer = 1;
		lerpYPos = 10;
		visible = true;
		active = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		if (!silent)
		{
			var sound = null;
			#if MODS_ALLOWED
			sound = getSound((up ? volumeUpSound : volumeDownSound)); // Paths.returnSound('sounds', 'sounds/soundtray/${up ? volumeUpSound : volumeDownSound}');
			#else
			sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
			#end

			if (globalVolume == 10)
				sound = getSound(volumeMaxSound); // Paths.returnSound('sounds/soundtray/$volumeMaxSound');

			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].visible = true;
			}
			else
			{
				_bars[i].visible = false;
			}
		}
	}
}
#end