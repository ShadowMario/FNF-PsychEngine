package grig.audio.js.webaudio; #if (js && !nodejs)

@:forward(sampleRate)
abstract AudioBuffer(js.html.audio.AudioBuffer) from js.html.audio.AudioBuffer
{
    public var numChannels(get, never):Int;
    public var numSamples(get, never):Int;

    private inline function get_numChannels():Int {
        return this.numberOfChannels;
    }

    private inline function get_numSamples():Int {
        return this.length;
    }

    public inline function new(numChannels:Int, numSamples:Int, sampleRate:Float)
    {
        this = new js.html.audio.AudioBuffer({
            sampleRate: sampleRate,
            numberOfChannels: numChannels,
            length: numSamples
        });
    }

    @:arrayAccess
    public inline function get(i:Int):AudioChannel {
        return return this.getChannelData(i);
    }

    inline public function clear():Void
    {
        for (i in 0...this.numberOfChannels) {
            this.getChannelData(i).fill(0.0);
        }
    }
}

#end