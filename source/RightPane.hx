import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;

class RightPane extends MusicBeatSubstate {
    var cons:Array<{label:String, callback:RightPane->Void}> = [];
    var titleSprite:AlphabetOptimized;
    var options:Array<AlphabetOptimized> = [];
    var curSelected:Int = 0;
    var stillPressed:Bool = true;
    var title:String = "";
    var blackBG:FlxSprite = new FlxSprite();
    var offset:Float = 1;
    var bg:FlxSprite;
    var offsets:Array<Float> = [];

    public function new(title:String, cons:Array<{label:String, callback:RightPane->Void}>) {
        super();
        this.title = title;
        this.cons = cons;
    }

    public override function create() {
        super.create();

        bg = new FlxSprite();
        bg.scrollFactor.set();
        bg.makeGraphic(1, 1, 0xFF000000);
        bg.alpha = 0.5;
        add(bg);

        blackBG.makeGraphic(1, 1, 0xFF000000);
        blackBG.alpha = 0.75;
        blackBG.scrollFactor.set();
        add(blackBG);
        
        CoolUtil.playMenuSFX(0);

        titleSprite = new AlphabetOptimized(0, 5, title, true, .85);
        titleSprite.scrollFactor.set();
        add(titleSprite);

        for(k=>e in cons) {
            var alphabet = new AlphabetOptimized(0, 100 + (60 * k), e.label, false, .7);
            alphabet.scrollFactor.set();
            add(alphabet);
            options.push(alphabet);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        offset = FlxMath.lerp(offset, 0, 0.25 * elapsed * 60);
        var shrex:Float = titleSprite.width;
        for(e in options)
            shrex = Math.max(e.width, shrex);
        blackBG.scale.set(shrex + 40, FlxG.height);
        blackBG.updateHitbox();
        blackBG.setPosition(FlxG.width - shrex - 40 + (offset * blackBG.width), 0);

        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.setPosition(0, 0);
        bg.alpha = (1 - offset) * 0.33;
        for(k=>e in options) {
            var o = offsets[k];
            offsets[k] = FlxMath.lerp(o, k == curSelected ? 20 : 0, 0.125 * elapsed * 60);
            e.x = blackBG.x + 10 + (offsets[k]);
        }

        titleSprite.x = blackBG.x + ((blackBG.width - titleSprite.width) / 2);

        stillPressed = stillPressed && controls.ACCEPT;
        changeSelection(-FlxG.mouse.wheel + (controls.DOWN_P ? 1 : 0) + (controls.UP_P ? -1 : 0));
        for(k=>e in options)
            e.alpha = k == curSelected ? 1 : (1 / 3);
        if (controls.ACCEPT && !stillPressed) {
            cons[curSelected].callback(this);
        }
        if (controls.BACK) {
            CoolUtil.playMenuSFX(2);
            close();
        }
    }

    public function changeSelection(num:Int = 0) {
        if (num == 0) return;
        curSelected += num;
        while(curSelected < 0) curSelected += options.length;
        curSelected %= options.length;
        CoolUtil.playMenuSFX(0);
    }
}