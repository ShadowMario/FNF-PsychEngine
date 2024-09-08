package grig.audio.js.webaudio; #if (js && !nodejs)

import js.html.audio.AudioContext;

class AudioContextFactory
{
    static public function createAudioContext():AudioContext
    {
        var context:AudioContext = js.Syntax.code('window.AudioContext || window.webkitAudioContext || null');
        if (context == null) {
            throw 'AudioContext apparently not supported in this browser';
        }
        return js.Syntax.code('new {0}()', context);
    }
}

#end