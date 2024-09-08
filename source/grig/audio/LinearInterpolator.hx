package grig.audio;

@:generic
class LinearInterpolator<T:Float>
{
    public function new() {}
    
    /**
     * Returns a new input with ratio * input.length amount of samples
     * @param input input channel to be resampled
     * @param ratio ratio of output channel to input channel length
     * @return AudioChannel
     */
    public function resampleChannel(input:AudioChannel<T>, ratio:Float):AudioChannel<T>
    {
        var newNumSamples = Math.ceil(input.length * ratio);
        var newAudioChannel = new AudioChannel<T>(newNumSamples);
        resampleIntoChannel(input, newAudioChannel, ratio);
        return newAudioChannel;
    }

    public function resampleBuffer(input:AudioBuffer<T>, ratio:Float, repitch:Bool = false):AudioBuffer<T>
    {
        var newNumSamples = Math.ceil(input.numSamples * ratio);
        var sampleRate = repitch ? input.sampleRate : input.sampleRate * ratio;
        var newBuffer = new AudioBuffer<T>(input.numChannels, newNumSamples, sampleRate);

        for (c in 0...input.numChannels) {
            resampleIntoChannel(input[c], newBuffer[c], ratio);
        }

        return newBuffer;
    }

    public function resampleIntoChannel(input:AudioChannel<T>, output:AudioChannel<T>, ratio:Float):Void
    {
        if (ratio == 0.0) return;
        var newNumSamples = Math.ceil(input.length * ratio);

        newNumSamples = Ints.min(newNumSamples, output.length);
        for (i in 0...newNumSamples) {
            var idx = i / ratio;
            var leftIdx = Math.floor(idx);
            var rightIdx = Math.ceil(idx);
            if (leftIdx == rightIdx || rightIdx >= input.length) {
                output[i] = input[leftIdx];
                continue;
            }
            var leftVal = input[leftIdx];
            var rightVal = input[rightIdx];
            output[i] = cast (leftVal + (rightVal - leftVal) * (idx - leftIdx) / (rightIdx - leftIdx));
        }
    }
}