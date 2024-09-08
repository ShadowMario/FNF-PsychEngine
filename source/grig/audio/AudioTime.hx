package grig.audio;

/**
 * Represents time in seconds
 */
abstract AudioTime(Float)
{
    public function new(value:Float)
    {
        this = value;
    }

    public inline function inMS():Float
    {
        return this * 1000.0;
    }

    static public inline function ofMS(inMS:Float)
    {
        return new AudioTime(inMS / 1000.0);
    }
}