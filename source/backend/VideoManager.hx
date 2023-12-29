package backend;

#if VIDEOS_ALLOWED 
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end
import haxe.extern.EitherType;
import flixel.util.FlxSignal;
import haxe.io.Path;

#if VIDEOS_ALLOWED
class VideoManager extends VideoHandler {
    public var playbackRate(get, set):EitherType<Single, Float>;
    public var paused(default, set):Bool = false;
    public var onVideoEnd:FlxSignal;
    public var onVideoStart:FlxSignal;

    public function new(#if (hxCodec >= "3.0.0") ?autoDispose:Bool = true #end) {

        super();
        onVideoEnd = new FlxSignal();
        onVideoStart = new FlxSignal();    
        
        #if (hxCodec >= "3.0.0")
        if(autoDispose)
            onEndReached.add(function(){
                dispose();
            }, true);

        onOpening.add(onVideoStart.dispatch);
        onEndReached.add(onVideoEnd.dispatch);
        #else
        openingCallback = onVideoStart.dispatch;
        finishCallback = onVideoEnd.dispatch;
        #end    
    }

    public function startVideo(path:String, loop:Bool = false) {
        #if (hxCodec >= "3.0.0")
        play(path, loop);
        #else
        playVideo(path, loop, false);
        #end
    }

    @:noCompletion
    private function set_paused(shouldPause:Bool){
        if(shouldPause){
            pause();
            if(FlxG.autoPause) {
                if(FlxG.signals.focusGained.has(pause))
                    FlxG.signals.focusGained.remove(pause);
    
                if(FlxG.signals.focusLost.has(resume))
                    FlxG.signals.focusLost.remove(resume);
            }
        } else {
            resume();
            if(FlxG.autoPause) {
                FlxG.signals.focusGained.add(pause);
                FlxG.signals.focusLost.add(resume);
            }
        }
        return shouldPause;
    }

    @:noCompletion
    private function set_playbackRate(multi:EitherType<Single, Float>){
        rate = multi;
        return multi;
    }

    @:noCompletion
    private function get_playbackRate():Float {
        return rate;
    }
    #end
}
