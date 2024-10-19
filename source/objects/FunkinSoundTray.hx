package objects;

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
 *  Wouldnt say this is the best way of implemeting this, but it works.
 *  Also Supports The Mods Folders
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

		var bg:Bitmap = new Bitmap(getPath("images/soundtray/volumebox", IMAGE));
		bg.scaleX = graphicScale;
		bg.scaleY = graphicScale;
		addChild(bg);

		y = -height;
		visible = false;

		// makes an alpha'd version of all the bars (bar_10.png)
		var backingBar:Bitmap = new Bitmap(getPath('images/soundtray/bars_10', IMAGE));
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
			var bar:Bitmap = new Bitmap(getPath('images/soundtray/bars_$i', IMAGE), false);
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

	function getPath(path:String, ?TYPE:AssetType = IMAGE):Dynamic
	{
		var ext = '';
		switch (TYPE)
		{
			case IMAGE:
				ext = 'png';
				var file = Paths.getPath('$path.$ext', IMAGE);
				#if MODS_ALLOWED
				return BitmapData.fromFile(file);
				#end
				return Assets.getBitmapData(file);
			case SOUND:
				ext = Paths.SOUND_EXT;
				var uhh = Paths.getPath('$path.$ext', TYPE);
				#if MODS_ALLOWED
				return uhh;
				#end
			default:
				ext = '';
		};

		return null;
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
			sound = Paths.returnSound('sounds/soundtray/${up ? volumeUpSound : volumeDownSound}');
			#else 
			sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
			#end

			if (globalVolume == 10)
				sound = Paths.returnSound('sounds/soundtray/$volumeMaxSound');

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