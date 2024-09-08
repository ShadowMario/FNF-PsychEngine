package grig.audio.hxal.environment;

import haxe.DynamicAccess;
import ftk.format.template.Interp;
import ftk.format.template.Parser;
import haxe.macro.Context;
import sys.io.File;

class EnvironmentHelper
{
    private var templateDataCache = new Map<String, String>();
    private var absolutePath:String;
    private var interp = new Interp();
    private var parser = new Parser();

    public function new() {
        absolutePath = Context.resolvePath('grig/audio/hxal/environment');
        parser.SIGN = '$';
    }

    private function getContent(relativePath:String):String {
        if (!templateDataCache.exists(relativePath)) {
            templateDataCache[relativePath] = File.getContent(absolutePath + '/' + relativePath);
        }
        return templateDataCache[relativePath];
    }

    public function print(relativePath:String, vars:DynamicAccess<Dynamic>):String {
        for (type in [HVarTools]) {
            var path = Type.getClassName(type).split('.');
            vars[path[path.length-1]] = type;
        }
        return interp.execute(parser.parse(getContent(relativePath)), {
            environment: vars,
            include: include
        });
    }

    public function include(relativePath:String, vars:{}):String {
        return interp.execute(parser.parse(getContent(relativePath)), vars);
    }
}
