package grig.audio;

class Ints
{
    public static inline function min(a:Int, b:Int):Int {
        return a > b ? b : a;
    }

    public static inline function max(a:Int, b:Int):Int {
        return a < b ? b : a;
    }
}