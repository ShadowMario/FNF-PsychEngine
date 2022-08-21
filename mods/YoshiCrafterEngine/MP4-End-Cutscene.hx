// TO USE, ADD A "yoursong-end-cutscene.mp4" FILE IN YOUR VIDEOS FOLDER. IT WILL BE HANDLED AUTOMATICALLY

function create() {
    var mFolder = Paths_.modsPath;
    
    var path = Paths.video(PlayState.song.song + "-end-cutscene", 'mods/' + PlayState_.songMod);
    trace(path);
    if (!Assets.exists(path)) {
        trace("Video not found.");
        end();
        return;
    }

    var wasWidescreen = PlayState.isWidescreen;
    var videoSprite:FlxSprite = null;
    
    PlayState.isWidescreen = false;
    PlayState.camHUD.bgColor = 0xFF000000;
    videoSprite = MP4Video.playMP4(Assets.getPath(path),
        function() {
            PlayState.remove(videoSprite);
            PlayState.isWidescreen = wasWidescreen;
            PlayState.camHUD.bgColor = 0x00000000;
            end();
        },
        // If midsong.
        false, FlxG.width, FlxG.height);

    videoSprite.cameras = [PlayState.camHUD];
    videoSprite.scrollFactor.set();
    PlayState.add(videoSprite);
}