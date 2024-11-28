package backend;

import flixel.FlxG;
#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.flixel.FlxVideo; //Just so it's compiled into the build for something like hscript
#end

//Psych 1.0's VideoSprite class would end up crashing Psych so I made a new class that doesn't have this issue
class FunkinVideo extends FlxVideoSprite {
	public var onFinish:(skipped:Bool) -> Void;
	
	public var skippable:Bool = false;
	public var loaded:Bool = false;
	
	public function new(videoName:String, canSkip:Bool = true, loop:Bool = false) {
		this.skippable = canSkip;
		
		super();
		
		antialiasing = ClientPrefs.globalAntialiasing;
		scrollFactor.set();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		bitmap.onFormatSetup.add(function() {
			if (this != null && bitmap != null && bitmap.bitmapData != null) {
				final scale:Float = Math.min(FlxG.width / bitmap.bitmapData.width, FlxG.height / bitmap.bitmapData.height);

				setGraphicSize(Std.int(bitmap.bitmapData.width * scale), Std.int(bitmap.bitmapData.height * scale));
				updateHitbox();
				screenCenter();
				
				#if FLX_SOUND_SYSTEM
				autoVolumeHandle = false;
				bitmap.volume = getVolumeFromFlxG(); //The video is just too quiet...
				#end
			}
		});
		
		bitmap.onEndReached.add(function() {
			if(onFinish != null) onFinish(false);
			destroy();
		});
	}
	
	public function loadVideo(filePath:String, ?loop:Dynamic = false):Bool {
		if(!loaded) {
			this.load(filePath, loop ? ['input-repeat=65545'] : null);
			loaded = true;
			return true;
		}
		trace("WARNING: Video already has it's data loaded!");
		return false;
	}
	
	public function playVideo():Bool {
		if(!loaded) {
			trace("WARNING: Cannot play video because it has not been loaded!");
			return false;
		}
		this.play();
		return true;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		bitmap.volume = getVolumeFromFlxG();
		if(skippable && FlxG.keys.justPressed.SPACE) {
			if(onFinish != null) onFinish(true);
			this.destroy();
		}
	}
	
	override function destroy() {
		onFinish = null;
		super.destroy();
	}
	
	private function getVolumeFromFlxG():Int {
		return Std.int(3 * ((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume) * 100);
	}
}