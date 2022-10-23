package flxanimate.animate;

import flixel.system.FlxSound;

class ButtonEvent
{
	/**
	 * The callback function to call when this even fires.
	 */
	public var callback:Void->Void;

	#if FLX_SOUND_SYSTEM
	/**
	 * The sound to play when this event fires.
	 */
	public var sound:FlxSound;
	#end

	/**
	 * @param   Callback   The callback function to call when this even fires.
	 * @param   sound      The sound to play when this event fires.
	 */
	public function new(?Callback:Void->Void, ?sound:FlxSound)
	{
		callback = Callback;

		#if FLX_SOUND_SYSTEM
		this.sound = sound;
		#end
	}

	/**
	 * Cleans up memory.
	 */
	public inline function destroy():Void
	{
		callback = null;

		#if FLX_SOUND_SYSTEM
		sound.destroy();
		#end
	}

	/**
	 * Fires this event (calls the callback and plays the sound)
	 */
	public inline function fire():Void
	{
		if (callback != null)
			callback();

		#if FLX_SOUND_SYSTEM
		if (sound != null)
			sound.play(true);
		#end
	}
}