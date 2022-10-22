package lime._internal.backend.flash;

import flash.media.SoundChannel;
import lime.math.Vector4;
import lime.media.AudioSource;

@:access(lime.media.AudioBuffer)
class FlashAudioSource
{
	private var channel:SoundChannel;
	private var completed:Bool;
	private var length:Null<Int>;
	private var loops:Int;
	private var parent:AudioSource;
	private var pauseTime:Int;
	private var playing:Bool;
	private var position:Vector4;

	public function new(parent:AudioSource)
	{
		this.parent = parent;

		position = new Vector4();
	}

	public function dispose():Void {}

	public function init():Void {}

	public function play():Void
	{
		if (channel != null) channel.stop();
		channel = parent.buffer.__srcSound.play(pauseTime / 1000 + parent.offset, loops + 1);
	}

	public function pause():Void
	{
		if (channel != null)
		{
			pauseTime = Std.int(channel.position * 1000);
			channel.stop();
		}
	}

	public function stop():Void
	{
		pauseTime = 0;

		if (channel != null)
		{
			channel.stop();
		}
	}

	// Get & Set Methods
	public function getCurrentTime():Int
	{
		if (channel != null)
		{
			return Std.int(channel.position) - parent.offset;
		}
		else
		{
			return 0;
		}
	}

	public function setCurrentTime(value:Int):Int
	{
		pauseTime = value;

		if (channel != null && value != getCurrentTime())
		{
			pauseTime = value;
			channel.stop();
			play();
		}

		return value;
	}

	public function getGain():Float
	{
		return channel.soundTransform.volume;
	}

	public function setGain(value:Float):Float
	{
		var soundTransform = channel.soundTransform;
		soundTransform.volume = value;
		channel.soundTransform = soundTransform;
		return value;
	}

	public function getLength():Int
	{
		if (length != null)
		{
			return length;
		}

		return Std.int(parent.buffer.__srcSound.length) - parent.offset;
	}

	public function setLength(value:Int):Int
	{
		return length = value;
	}

	public function getLoops():Int
	{
		return loops;
	}

	public function setLoops(value:Int):Int
	{
		return loops = value;
	}

	public function getPitch():Float
	{
		lime.utils.Log.verbose("Pitch is not supported in Flash.");
		return 1;
	}

	public function setPitch(value:Float):Float
	{
		return getPitch();
	}

	public function getPosition():Vector4
	{
		position.x = channel.soundTransform.pan;

		return position;
	}

	public function setPosition(value:Vector4):Vector4
	{
		position.x = value.x;
		position.y = value.y;
		position.z = value.z;
		position.w = value.w;

		var soundTransform = channel.soundTransform;
		soundTransform.pan = position.x;
		channel.soundTransform = soundTransform;

		return position;
	}
}
