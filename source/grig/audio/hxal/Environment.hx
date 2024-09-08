package grig.audio.hxal;

/**
    Represents a pure hxal (sidestepping haxe's code generation) environment
**/
interface Environment
{
    public function buildOutput(descriptor:ClassDescriptor, outPath:String):Void;
}