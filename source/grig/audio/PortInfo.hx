package grig.audio;

typedef PortInfo =
{
    // var isDefault:Bool;
	var portID:Int;
    var portName:String;
    var isDefaultInput:Bool;
    var isDefaultOutput:Bool;
    var maxInputChannels:Int;
    var maxOutputChannels:Int;
    var defaultSampleRate:Float;
    var sampleRates:Array<Float>;
    @:optional var defaultLowInputLatency:Float;
    @:optional var defaultLowOutputLatency:Float;
    @:optional var defaultHighInputLatency:Float;
    @:optional var defaultHighOutputLatency:Float;
}