package backend;

#if VIDEOS_ALLOWED 
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

/*A class made to handle Video functions from diffrent hxCodec versions*/
class VideoManager extends VideoHandler {
    public function new() {
        super();
    }
    #if VIDEOS_ALLOWED

    /**
	 * Native video support for Flixel & OpenFL
	 * @param Path Example: `your/video/here.mp4`
	 * @param Loop Loop the video.
	 */
    public function startVideo(path:String, loop:Bool = false) {
        #if (hxCodec >= "3.0.0")
        this.play(path, loop);
        #else
        this.playVideo(path, loop, false);
        #end
    }

    /**
	 * Adds a function that is called when the Video ends.
	 * @param func Example: `function() { //code to run}`
	 */
    public function setFinishCallBack(func:Dynamic){
        #if (hxCodec >= "3.0.0")
        this.onEndReached.add(function() {
            this.dispose();
            if(func != null)
            func();
        }, true);
        #else
        if(func != null)
        this.finishCallback = func;
        #end
    }

    /**
	 * Adds a function which is called when the Codec is opend(video starts).
	 * @param func Example: `function() { //code to run}`
	 */
    public function setStartCallBack(func:Dynamic){
        #if (hxCodec >= "3.0.0")
        if(func != null)
        this.onOpening.add(func, true);
        #else
        if(func != null)
        this.openingCallback = func;
        #end
    }
    override public function pause(){
        super.pause();
        if(FlxG.signals.focusLost.has(pause))
            FlxG.signals.focusLost.remove(pause);
        if(FlxG.signals.focusGained.has(resume))
            FlxG.signals.focusGained.remove(resume);
    }

    override public function resume(){
        super.resume();
        FlxG.signals.focusLost.add(pause);
        FlxG.signals.focusGained.add(resume);
    }
    #end
}