package grig.audio;

// Float types

#if cpp
typedef Float32 = cpp.Float32;
typedef Float64 = cpp.Float64;
#elseif (java || cs || hl)
typedef Float32 = Single;
typedef Float64 = Float;
#else
typedef Float32 = Float;
typedef Float64 = Float;
#end

// Int types

#if cpp
typedef Int8 = cpp.Int8;
typedef UInt8 = cpp.UInt8;
typedef Int16 = cpp.Int16;
typedef UInt16 = cpp.UInt16;
typedef UInt32 = cpp.UInt32;
typedef UInt64 = cpp.UInt64;
#elseif cs
import cs.StdTypes
typedef Int8 = cs.Int8;
typedef UInt8 = cs.UInt8;
typedef Int16 = cs.Int16;
typedef UInt16 = cs.UInt16;
typedef UInt32 = cs.UInt32;
typedef UInt64 = cs.UInt64;
#elseif java
import java.StdTypes
typedef Int8 = java.Int8;
typedef Int16 = java.Int16;
typedef UInt8 = Int;
typedef UInt16 = Int;
typedef UInt32 = haxe.Int64;
typedef UInt64 = haxe.Int64;
#end

typedef Int32 = haxe.Int32;
typedef Int64 = haxe.Int64;
