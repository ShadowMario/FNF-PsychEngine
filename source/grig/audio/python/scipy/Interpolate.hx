package grig.audio.python.scipy; #if python

import grig.audio.python.numpy.Ndarray;

@:pythonImport('scipy', 'interpolate')
@:native('interpolate')
@:callable
extern class Interpolate
{
    public static function interp1d(x:Ndarray, y:Ndarray, kind:String):(x:Ndarray)->Ndarray;
}

#end
