package grig.audio.hxal.environment;

import grig.audio.hxal.HVar;
import haxe.DynamicAccess;
import haxe.macro.Context;
import sys.io.File;

class CppEnvironment implements grig.audio.hxal.Environment
{
    #if macro

    public function new() {
    }

    public function buildOutput(descriptor:ClassDescriptor, outPath:String):Void {
        var ereg = new EReg('\\.\\w+$', '');
        if (!ereg.match(outPath)) outPath += '.cpp';
        grig.audio.hxal.Macro.info('Outputting to path: ${outPath}', Context.currentPos());
        var helper = new EnvironmentHelper();
        var vars = new DynamicAccess<Dynamic>();
        vars['descriptor'] = descriptor;
        vars['CppEnvironment'] = CppEnvironment;
        File.saveContent(outPath, helper.print('cpp/main.cc.mtt', vars));
    }

    public static function cppTypeFromVarType(varType:VarType):String {
        return switch varType {
            case TFloat: 'float';
            case TAtomicFloat: 'std::atomic<float>';
            case TInvalid: 'NaN';
        }
    }

    #end
}