package grig.audio.js.webaudio; #if (js && !nodejs)

import haxe.io.Input;
import tink.core.Error;
import tink.core.Future;
import tink.core.Outcome;

class Reader
{
    private var input:Input;

    public function new(_input:Input)
    {
        input = _input;
    }

    public function load():Surprise<AudioBuffer, tink.core.Error>
    {
        return Future.async(function(_callback) {
            try {
                var bytes = input.readAll();
                AudioInterface.audioContext.decodeAudioData(bytes.getData(), function(buffer:js.html.audio.AudioBuffer) {
                    _callback(Success(new AudioBuffer(buffer)));
                }, function(error:js.html.DOMException) {
                    _callback(Failure(new Error(InternalError, 'Failed to load audio data. ${error.message}')));
                });
            }
            catch (error:Error) {
                _callback(Failure(new Error(InternalError, 'Failed to load audio data. ${error.message}')));
            }
        });
    }
}

#end