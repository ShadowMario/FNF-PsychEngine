package lime._internal.backend.native;

import haxe.Int64;
import haxe.Timer;
import lime.math.Vector4;
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
import lime.media.vorbis.VorbisFile;
import lime.media.AudioManager;
import lime.media.AudioSource;
import lime.utils.UInt8Array;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(lime.media.AudioBuffer)
class NativeAudioSource
{
	private static var STREAM_BUFFER_SIZE = 48000;
	#if (native_audio_buffers && !macro)
	private static var STREAM_NUM_BUFFERS = Std.parseInt(haxe.macro.Compiler.getDefine("native_audio_buffers"));
	#else
	private static var STREAM_NUM_BUFFERS = 3;
	#end
	private static var STREAM_TIMER_FREQUENCY = 100;

	private var buffers:Array<ALBuffer>;
	private var completed:Bool;
	private var dataLength:Int;
	private var format:Int;
	private var handle:ALSource;
	private var length:Null<Int>;
	private var loops:Int;
	private var parent:AudioSource;
	private var playing:Bool;
	private var position:Vector4;
	private var samples:Int;
	private var stream:Bool;
	private var streamTimer:Timer;
	private var timer:Timer;

	public function new(parent:AudioSource)
	{
		this.parent = parent;

		position = new Vector4();
	}

	public function dispose():Void
	{
		if (handle != null)
		{
			stop();
			AL.sourcei(handle, AL.BUFFER, null);
			AL.deleteSource(handle);
			if (buffers != null)
			{
				for (buffer in buffers)
				{
					AL.deleteBuffer(buffer);
				}
				buffers = null;
			}
			handle = null;
		}
	}

	public function init():Void
	{
		dataLength = 0;
		format = 0;

		if (parent.buffer.channels == 1)
		{
			if (parent.buffer.bitsPerSample == 8)
			{
				format = AL.FORMAT_MONO8;
			}
			else if (parent.buffer.bitsPerSample == 16)
			{
				format = AL.FORMAT_MONO16;
			}
		}
		else if (parent.buffer.channels == 2)
		{
			if (parent.buffer.bitsPerSample == 8)
			{
				format = AL.FORMAT_STEREO8;
			}
			else if (parent.buffer.bitsPerSample == 16)
			{
				format = AL.FORMAT_STEREO16;
			}
		}

		if (parent.buffer.__srcVorbisFile != null)
		{
			stream = true;

			var vorbisFile = parent.buffer.__srcVorbisFile;
			dataLength = Std.int(Int64.toInt(vorbisFile.pcmTotal()) * parent.buffer.channels * (parent.buffer.bitsPerSample / 8));

			buffers = new Array();

			for (i in 0...STREAM_NUM_BUFFERS)
			{
				buffers.push(AL.createBuffer());
			}

			handle = AL.createSource();
		}
		else
		{
			if (parent.buffer.__srcBuffer == null)
			{
				parent.buffer.__srcBuffer = AL.createBuffer();

				if (parent.buffer.__srcBuffer != null)
				{
					AL.bufferData(parent.buffer.__srcBuffer, format, parent.buffer.data, parent.buffer.data.length, parent.buffer.sampleRate);
				}
			}

			dataLength = parent.buffer.data.length;

			handle = AL.createSource();

			if (handle != null)
			{
				AL.sourcei(handle, AL.BUFFER, parent.buffer.__srcBuffer);
			}
		}

		samples = Std.int((dataLength * 8) / (parent.buffer.channels * parent.buffer.bitsPerSample));
	}

	public function play():Void
	{
		/*var pitch:Float = AL.getSourcef (handle, AL.PITCH);
			trace(pitch);
			AL.sourcef (handle, AL.PITCH, pitch*0.9);
			pitch = AL.getSourcef (handle, AL.PITCH);
			trace(pitch); */
		/*var pos = getPosition();
			trace(AL.DISTANCE_MODEL);
			AL.distanceModel(AL.INVERSE_DISTANCE);
			trace(AL.DISTANCE_MODEL);
			AL.sourcef(handle, AL.ROLLOFF_FACTOR, 5);
			setPosition(new Vector4(10, 10, -100));
			pos = getPosition();
			trace(pos); */
		/*var filter = AL.createFilter();
			trace(AL.getErrorString());

			AL.filteri(filter, AL.FILTER_TYPE, AL.FILTER_LOWPASS);
			trace(AL.getErrorString());

			AL.filterf(filter, AL.LOWPASS_GAIN, 0.5);
			trace(AL.getErrorString());

			AL.filterf(filter, AL.LOWPASS_GAINHF, 0.5);
			trace(AL.getErrorString());

			AL.sourcei(handle, AL.DIRECT_FILTER, filter);
			trace(AL.getErrorString()); */

		if (playing || handle == null)
		{
			return;
		}

		playing = true;

		if (stream)
		{
			setCurrentTime(getCurrentTime());

			streamTimer = new Timer(STREAM_TIMER_FREQUENCY);
			streamTimer.run = streamTimer_onRun;
		}
		else
		{
			var time = completed ? 0 : getCurrentTime();

			AL.sourcePlay(handle);

			setCurrentTime(time);
		}
	}

	public function pause():Void
	{
		playing = false;

		if (handle == null) return;
		AL.sourcePause(handle);

		if (streamTimer != null)
		{
			streamTimer.stop();
		}

		if (timer != null)
		{
			timer.stop();
		}
	}

	private function readVorbisFileBuffer(vorbisFile:VorbisFile, length:Int):UInt8Array
	{
		#if lime_vorbis
		var buffer = new UInt8Array(length);
		var read = 0, total = 0, readMax;

		while (total < length)
		{
			readMax = 4096;

			if (readMax > length - total)
			{
				readMax = length - total;
			}

			read = vorbisFile.read(buffer.buffer, total, readMax);

			if (read > 0)
			{
				total += read;
			}
			else
			{
				break;
			}
		}

		return buffer;
		#else
		return null;
		#end
	}

	private function refillBuffers(buffers:Array<ALBuffer> = null):Void
	{
		#if lime_vorbis
		var vorbisFile = null;
		var position = 0;

		if (buffers == null)
		{
			var buffersProcessed:Int = AL.getSourcei(handle, AL.BUFFERS_PROCESSED);

			if (buffersProcessed > 0)
			{
				vorbisFile = parent.buffer.__srcVorbisFile;
				position = Int64.toInt(vorbisFile.pcmTell());

				if (position < dataLength)
				{
					buffers = AL.sourceUnqueueBuffers(handle, buffersProcessed);
				}
			}
		}

		if (buffers != null)
		{
			if (vorbisFile == null)
			{
				vorbisFile = parent.buffer.__srcVorbisFile;
				position = Int64.toInt(vorbisFile.pcmTell());
			}

			var numBuffers = 0;
			var data;

			for (buffer in buffers)
			{
				if (dataLength - position >= STREAM_BUFFER_SIZE)
				{
					data = readVorbisFileBuffer(vorbisFile, STREAM_BUFFER_SIZE);
					AL.bufferData(buffer, format, data, data.length, parent.buffer.sampleRate);
					position += STREAM_BUFFER_SIZE;
					numBuffers++;
				}
				else if (position < dataLength)
				{
					data = readVorbisFileBuffer(vorbisFile, dataLength - position);
					AL.bufferData(buffer, format, data, data.length, parent.buffer.sampleRate);
					numBuffers++;
					break;
				}
			}

			AL.sourceQueueBuffers(handle, numBuffers, buffers);

			// OpenAL can unexpectedly stop playback if the buffers run out
			// of data, which typically happens if an operation (such as
			// resizing a window) freezes the main thread.
			// If AL is supposed to be playing but isn't, restart it here.
			if (playing && handle != null && AL.getSourcei(handle, AL.SOURCE_STATE) == AL.STOPPED){
				AL.sourcePlay(handle);
			}
		}
		#end
	}

	public function stop():Void
	{
		if (playing && handle != null && AL.getSourcei(handle, AL.SOURCE_STATE) == AL.PLAYING)
		{
			AL.sourceStop(handle);
		}

		playing = false;

		if (streamTimer != null)
		{
			streamTimer.stop();
		}

		if (timer != null)
		{
			timer.stop();
		}
		
		setCurrentTime(0);
	}

	// Event Handlers
	private function streamTimer_onRun():Void
	{
		refillBuffers();
	}

	private function timer_onRun():Void
	{
		if (loops > 0)
		{
			playing = false;
			loops--;
			setCurrentTime(0);
			play();
			return;
		}
		else
		{
			stop();
		}

		completed = true;
		parent.onComplete.dispatch();
	}

	// Get & Set Methods
	public function getCurrentTime():Int
	{
		if (completed)
		{
			return getLength();
		}
		else if (handle != null)
		{
			if (stream)
			{
				var time = (Std.int(parent.buffer.__srcVorbisFile.timeTell() * 1000) + Std.int(AL.getSourcef(handle, AL.SEC_OFFSET) * 1000)) - parent.offset;
				if (time < 0) return 0;
				return time;
			}
			else
			{
				var offset = AL.getSourcei(handle, AL.BYTE_OFFSET);
				var ratio = (offset / dataLength);
				var totalSeconds = samples / parent.buffer.sampleRate;

				var time = Std.int(totalSeconds * ratio * 1000) - parent.offset;

				// var time = Std.int (AL.getSourcef (handle, AL.SEC_OFFSET) * 1000) - parent.offset;
				if (time < 0) return 0;
				return time;
			}
		}

		return 0;
	}

	public function setCurrentTime(value:Int):Int
	{
		// `setCurrentTime()` has side effects and is never safe to skip.
		/* if (value == getCurrentTime())
		{
			return value;
		} */

		if (handle != null)
		{
			if (stream)
			{
				AL.sourceStop(handle);

				parent.buffer.__srcVorbisFile.timeSeek((value + parent.offset) / 1000);
				AL.sourceUnqueueBuffers(handle, STREAM_NUM_BUFFERS);
				refillBuffers(buffers);

				if (playing) AL.sourcePlay(handle);
			}
			else if (parent.buffer != null)
			{
				AL.sourceRewind(handle);
				if (playing) AL.sourcePlay(handle);
				// AL.sourcef (handle, AL.SEC_OFFSET, (value + parent.offset) / 1000);

				var secondOffset = (value + parent.offset) / 1000;
				var totalSeconds = samples / parent.buffer.sampleRate;

				if (secondOffset < 0) secondOffset = 0;
				if (secondOffset > totalSeconds) secondOffset = totalSeconds;

				var ratio = (secondOffset / totalSeconds);
				var totalOffset = Std.int(dataLength * ratio);

				AL.sourcei(handle, AL.BYTE_OFFSET, totalOffset);
			}
		}

		if (playing)
		{
			if (timer != null)
			{
				timer.stop();
			}

			var timeRemaining = Std.int((getLength() - value) / getPitch());

			if (timeRemaining > 0)
			{
				completed = false;
				timer = new Timer(timeRemaining);
				timer.run = timer_onRun;
			}
			else
			{
				playing = false;
				completed = true;
			}
		}

		return value;
	}

	public function getGain():Float
	{
		if (handle != null)
		{
			return AL.getSourcef(handle, AL.GAIN);
		}
		else
		{
			return 1;
		}
	}

	public function setGain(value:Float):Float
	{
		if (handle != null)
		{
			AL.sourcef(handle, AL.GAIN, value);
		}

		return value;
	}

	public function getLength():Int
	{
		if (length != null)
		{
			return length;
		}

		return Std.int(samples / parent.buffer.sampleRate * 1000) - parent.offset;
	}

	public function setLength(value:Int):Int
	{
		if (playing && length != value)
		{
			if (timer != null)
			{
				timer.stop();
			}

			var timeRemaining = Std.int((value - getCurrentTime()) / getPitch());

			if (timeRemaining > 0)
			{
				timer = new Timer(timeRemaining);
				timer.run = timer_onRun;
			}
		}

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
		if (handle != null)
		{
			return AL.getSourcef(handle, AL.PITCH);
		}
		else
		{
			return 1;
		}
	}

	public function setPitch(value:Float):Float
	{
		if (playing && value != getPitch())
		{
			if (timer != null)
			{
				timer.stop();
			}

			var timeRemaining = Std.int((getLength() - getCurrentTime()) / value);

			if (timeRemaining > 0)
			{
				timer = new Timer(timeRemaining);
				timer.run = timer_onRun;
			}
		}

		if (handle != null)
		{
			AL.sourcef(handle, AL.PITCH, value);
		}

		return value;
	}

	public function getPosition():Vector4
	{
		if (handle != null)
		{
			#if !emscripten
			var value = AL.getSource3f(handle, AL.POSITION);
			position.x = value[0];
			position.y = value[1];
			position.z = value[2];
			#end
		}

		return position;
	}

	public function setPosition(value:Vector4):Vector4
	{
		position.x = value.x;
		position.y = value.y;
		position.z = value.z;
		position.w = value.w;

		if (handle != null)
		{
			AL.distanceModel(AL.NONE);
			AL.source3f(handle, AL.POSITION, position.x, position.y, position.z);
		}

		return position;
	}
}