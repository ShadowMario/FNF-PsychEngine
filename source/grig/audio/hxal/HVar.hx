package grig.audio.hxal;

import haxe.macro.Expr;

enum VarType
{
    TFloat;
    TAtomicFloat;
    TInvalid;
}

enum DefinedLocation
{
    BuiltIn;
    Defined(position:Position);
}

typedef HVar = {
    var name:String;
    var type:VarType;
    var definedLocation:DefinedLocation;
}