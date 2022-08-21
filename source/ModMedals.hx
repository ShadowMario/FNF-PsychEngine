package;

class ModMedals {
    var __mod:String;

    public function new(mod:String) {
        __mod = mod;
    }

    public function unlock(name:String) {Medals.unlock(__mod, name);}
    public function lock(name:String) {Medals.lock(__mod, name);}
    public function getState(name:String) {Medals.getState(__mod, name);}
}