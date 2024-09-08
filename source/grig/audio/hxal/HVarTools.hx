package grig.audio.hxal;

import grig.audio.hxal.HVar;

class HVarTools
{
    public static function isAtomic(varType:VarType):Bool {
        return switch varType {
            case TFloat: false;
            case TAtomicFloat: true;
            case TInvalid: false; // more like not-even-false
        }
    }

    public static function getAtomicTypes():Array<VarType> {
        return Type.allEnums(VarType).filter((prop) -> { isAtomic(prop); });
    }

    public static function getHxalNameForType(varType:VarType):String {
        return switch varType {
            case TFloat: 'Float';
            case TAtomicFloat: 'AtomicFloat';
            case TInvalid: 'Invalid';
        }
    }
}