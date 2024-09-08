package grig.audio.hxal;

import haxe.ds.Option;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import grig.audio.hxal.HVar;

using StringTools;

class ClassDescriptor
{
    public var className:String;
    public var vars = new Array<HVar>();
    private static inline var metaPrefix = ':hxal.';

    private function setupPredefineds():Void {
        // vars.push(new HVar('sin', TFunction, BuiltIn));
    }

    // tries to resolve variable from beginning of array to last, so for masking to work
    // right, ensure that higher scopes come /later/
    static private function findVarInScope(varScopes:Array<Array<HVar>>, name:String):Option<HVar> {
        for (vars in varScopes) {
            for (hvar in vars) {
                if (hvar.name == name) return Some(hvar);
            }
        }
        return None;
    }

    private static function checkNoParams(typePath:TypePath, position:Position):Void {
        if (typePath.params != null && typePath.params.length != 0) {
            Macro.error('Type: ${typePath.name} does not allow parameters', position);
        }
    }

    private static function getTypeFromTypePath(typePath:TypePath, position:Position):VarType {
        var name = typePath.name;
        return switch name {
            case 'Float':
                checkNoParams(typePath, position);
                TFloat;
            case 'AtomicFloat':
                checkNoParams(typePath, position);
                TAtomicFloat;
            default:
                Macro.error('Not implemented type: ${name}', position);
                TInvalid;
        }
    }

    public static function getType(complexType:ComplexType, position:Position):VarType {
        return switch complexType {
            case TPath(typePath):
                getTypeFromTypePath(typePath, position);
            default:
                Macro.error('Not implemented complex type', position);
                TInvalid;
        }
    }

    public function new(classType:ClassType) {
        className = classType.name;

        setupPredefineds();

        var fields:Array<Field> = Context.getBuildFields();
        for (field in fields) {
            if (findVarInScope([vars], field.name).match(Some(_))) {
                Macro.error('Variable already defined: ${field.name}', field.pos);
            }

            switch (field.kind) {
                case FVar(complexType, expr):
                    if (complexType == null) {
                        Macro.error("Unspecified type in declaration not supported", field.pos);
                    }
                    var name = field.name;
                    var type = getType(complexType, field.pos);
                    // nodeVar.expr = expr;
                    // verifySupportedVarAccess(nodeVar, field.access);
                    for (meta in field.meta) {
                        if (!meta.name.startsWith(metaPrefix)) continue;
                        var hMeta = meta.name.substring(metaPrefix.length);
                        switch hMeta {
                            // We haven't implemented anything yet
                            default:
                                Macro.warning('hxal macro "${hMeta}" not defined', field.pos);
                        }
                    }
                    vars.push({name: name, type: type, definedLocation: Defined(field.pos)});
                case FFun(fun):
                    trace('fun');
                case FProp(_, _):
                    Macro.error("Properties not supported", field.pos);
            }
        }
    }

    public function getUsedAtomicTypes():Array<VarType> {
        var usedAtomicTypes = new Array<VarType>();
        for (hvar in vars) {
            if (HVarTools.isAtomic(hvar.type) && !usedAtomicTypes.contains(hvar.type)) {
                usedAtomicTypes.push(hvar.type);
            }
        }
        return usedAtomicTypes;
    }
}