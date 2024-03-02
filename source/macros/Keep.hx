package macros;
#if macro
import haxe.macro.Compiler;

using StringTools;

class Keep
{
    // JUST WRITE THE CLASS PACKAGE AS STRING (e.g  "flixel.effects.particles.FlxParticle") IT'S AS SIMPLE AS THAT
    public static var classesToKeep:Array<String> = [];
    
    public static function keepClasses(){
        var packagesArray = [];
        for(clas in classesToKeep){
            var dotsSplit = clas.split('.');
            var pack = '';
            for(i in 0...dotsSplit.length-1)
                pack += dotsSplit[i] + '.';
            if(pack.endsWith('.'))
                pack = pack.substr(0, pack.length-1);
            packagesArray.push(pack);
            trace(pack);
        }
        for(pack in packagesArray)
            Compiler.include(pack);
        Compiler.keep(null, classesToKeep, true);
    }
}
#end
