package charter;

import flixel.FlxSprite;

class CharterStrum extends FlxSprite {
    public var lastHit:Float = -1000;
    public function new(x:Float, y:Float, data:Int) {
        super(x, y);
        frames = Paths.getSparrowAtlas("NOTE_assets_charter", "shared");
        
        var scheme = Note.noteNumberSchemes[YoshiCrafterCharter._song.keyNumber];
        if (scheme == null) scheme = Note.noteNumberSchemes[4];
        switch(scheme[data % YoshiCrafterCharter._song.keyNumber]) {
            case Left:
                animation.addByPrefix('static', 'arrowLEFT0');
                animation.addByPrefix('pressed', 'left press', 24, false);
                animation.addByPrefix('confirm', 'left confirm', 24, false);
            case Down:
                animation.addByPrefix('static', 'arrowDOWN');
                animation.addByPrefix('pressed', 'down press', 24, false);
                animation.addByPrefix('confirm', 'down confirm', 24, false);
            case Up:
                animation.addByPrefix('static', 'arrowUP');
                animation.addByPrefix('pressed', 'up press', 24, false);
                animation.addByPrefix('confirm', 'up confirm', 24, false);
            case Right:
                animation.addByPrefix('static', 'arrowRIGHT0');
                animation.addByPrefix('pressed', 'right press', 24, false);
                animation.addByPrefix('confirm', 'right confirm', 24, false);
        }
        animation.play('static');
        setGraphicSize(YoshiCrafterCharter.GRID_SIZE, YoshiCrafterCharter.GRID_SIZE);
        updateHitbox();
        antialiasing = true;
    }

    public override function update(elapsed:Float) {
        super.update(lastHit);
        if (lastHit > 0) {
            if (animation.curAnim.name != 'confirm') {
                animation.play('confirm');
                centerOffsets();
                centerOrigin();
            }
        } else {
            if (animation.curAnim.name != 'static') {
                animation.play('static');
                centerOffsets();
                centerOrigin();
            }
        }
        lastHit -= elapsed;
    }
}