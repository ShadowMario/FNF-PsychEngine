package grig.audio;

typedef AudioInterfaceOptions =
{
    @:optional var inputPort:Int;
    @:optional var outputPort:Int;
	@:optional var inputNumChannels:Int;
	@:optional var outputNumChannels:Int;
    @:optional var sampleRate:Float;
    @:optional var bufferSize:Int;
    @:optional var inputLatency:Float;
    @:optional var outputLatency:Float;
    @:optional var interleaved:Bool;
}