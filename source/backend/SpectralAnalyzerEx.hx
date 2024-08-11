package backend;
#if funkin.vis 
import funkin.vis._internal.html5.AnalyzerNode;
import funkin.vis.audioclip.frontends.LimeAudioClip;
import funkin.vis.dsp.SpectralAnalyzer;
import funkin.vis.dsp.RecentPeakFinder;
import grig.audio.FFT;
import grig.audio.FFTVisualization;
import lime.media.AudioSource;

using grig.audio.lime.UInt8ArrayTools;
#end

class SpectralAnalyzerEx #if funkin.vis extends SpectralAnalyzer #end
{
	#if funkin.vis
	var _levels:Array<Bar> = [];
	public function recycledLevels():Array<Bar>
	{
		#if web
		var amplitudes:Array<Float> = htmlAnalyzer.getFloatFrequencyData();

		for (i in 0...bars.length) {
			var bar = bars[i];
			var binLo = bar.binLo;
			var binHi = bar.binHi;

			var value:Float = minDb;
			for (j in (binLo + 1)...(binHi)) {
				value = Math.max(value, amplitudes[Std.int(j)]);
			}

			// this isn't for clamping, it's to get a value
			// between 0 and 1!
			value = normalizedB(value);
			bar.recentValues.push(value);
			var recentPeak = bar.recentValues.peak;

			if(_levels[i] != null)
			{
				_levels[i].value = value;
				_levels[i].peak = recentPeak;
			}
			else _levels.push({value: value, peak: recentPeak});
		}

		return _levels;
		#else
		var numOctets = Std.int(audioSource.buffer.bitsPerSample / 8);
		var wantedLength = fftN * numOctets * audioSource.buffer.channels;
		var startFrame = audioClip.currentFrame;
		startFrame -= startFrame % numOctets;
		var segment = audioSource.buffer.data.subarray(startFrame, min(startFrame + wantedLength, audioSource.buffer.data.length));
		var signal = recycledInterleaved(segment, audioSource.buffer.bitsPerSample);

		if (audioSource.buffer.channels > 1)
		{
			var mixed = [];
			mixed.resize(Std.int(signal.length / audioSource.buffer.channels));
			for (i in 0...mixed.length)
			{
				mixed[i] = 0.0;
				for (c in 0...audioSource.buffer.channels)
					mixed[i] += 0.7 * signal[i*audioSource.buffer.channels+c];

				mixed[i] *= blackmanWindow[i];
			}
			signal = mixed;
		}

		var range = 16;
		var freqs = fft.calcFreq(signal);
		var bars = vis.makeLogGraph(freqs, barCount, Math.floor(maxDb - minDb), range);

		if (bars.length > barHistories.length)
			barHistories.resize(bars.length);

		_levels.resize(bars.length);
		for (i in 0...bars.length)
		{
			if (barHistories[i] == null)
			{
				barHistories[i] = new RecentPeakFinder();
				trace('created barHistories[$i]');
			}
			var recentValues = barHistories[i];
			var value = bars[i] / range;

			// slew limiting
			var lastValue = recentValues.lastValue;
			if (maxDelta > 0.0)
			{
				var delta = clamp(value - lastValue, -1 * maxDelta, maxDelta);
				value = lastValue + delta;
			}
			recentValues.push(value);

			var recentPeak = recentValues.peak;

			if(_levels[i] != null)
			{
				_levels[i].value = value;
				_levels[i].peak = recentPeak;
			}
			else _levels[i] = {value: value, peak: recentPeak};
		}
		return _levels;
		#end
	}

	var _buffer:Array<Float> = [];
	function recycledInterleaved(data:lime.utils.UInt8Array, bitsPerSample:Int):Array<Float>
	{
		switch(bitsPerSample)
		{
			case 8:
				_buffer.resize(data.length);
				for (i in 0...data.length)
					_buffer[i] = data[i] / 128.0;

			case 16:
				_buffer.resize(Std.int(data.length / 2));
				for (i in 0..._buffer.length)
					_buffer[i] = data.getInt16(i * 2) / 32767.0;

			case 24:
				_buffer.resize(Std.int(data.length / 3));
				for (i in 0..._buffer.length)
					_buffer[i] = data.getInt24(i * 3) / 8388607.0;

			case 32:
				_buffer.resize(Std.int(data.length / 4));
				for (i in 0..._buffer.length)
					_buffer[i] = data.getInt32(i * 4) / 2147483647.0;

			default: trace('Unknown integer audio format');
		}
		return _buffer;
	}

	@:generic
	static inline function min<T:Float>(x:T, y:T):T
	{
		return x > y ? y : x;
	}
	
	@:generic
	static inline function clamp<T:Float>(val:T, min:T, max:T):T
	{
		return val <= min ? min : val >= max ? max : val;
	}
	#else
	//Just to avoid errors until they review my PR
	public var fftN:Int = 0;
	public function new(?v1:Dynamic, ?v2:Dynamic, ?v3:Dynamic, ?v4:Dynamic) {}
	public function recycledLevels():Array<Dynamic>
	{
		return [{value: 0, peak: 0}];
	}
	#end
}