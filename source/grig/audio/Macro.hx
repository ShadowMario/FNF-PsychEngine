package grig.audio;

import haxe.macro.Context;

class Macro
{
    #if macro

    static public function buildPlatformSpecificBuffer() {
        #if (js && !nodejs && !heaps)
        trace(Context.getLocalType());
        #end 
        return null;
    }

    #end
}