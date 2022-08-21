import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

typedef Button = {
    var label:String;
    var callback:Void->Void;
}
class MenuMessage extends MusicBeatSubstate {
    var wasUnpressed = false;
    var buttons:Array<Button> = [{
        label: "OK",
        callback: null
    }];
    var alphabets:Array<AlphabetOptimized> = [];
    var curSelected:Int = 0;
    var wasAccepted:Bool = false;
    public override function new(message:String, ?buttons:Array<Button>, defaultSelected:Int = 0) {
        super();
        add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000, true));
        add(new FlxSprite(FlxG.width / 8, FlxG.height / 8).makeGraphic(960, 540, 0x88000000, true));
        
        var message = new AlphabetOptimized(FlxG.width / 8 + 10, FlxG.height / 8 + 10, message, false, 1 / 3);
        message.maxWidth = 940;
        add(message);

        if (buttons != null && buttons.length > 0) {
            this.buttons = buttons;
        }
        curSelected = defaultSelected;
        for(k=>b in this.buttons) {
            var ler = ((k + 0.5) / this.buttons.length);
            var alphabet = new AlphabetOptimized(FlxMath.lerp(FlxG.width / 8, (FlxG.width / 8) + (FlxG.width * 0.75), ler), (FlxG.height / 8) + (FlxG.height * 0.75) - 10 - 45, b.label, true, 0.5);
            alphabet.x -= alphabet.width / 2;
            add(alphabet);
            alphabets.push(alphabet);
        }
        changeSelection(0);
        wasAccepted = controls.ACCEPT;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.RIGHT_P || controls.DOWN_P) changeSelection(1);
        if (controls.LEFT_P || controls.UP_P) changeSelection(-1);
        if (!(wasAccepted = wasAccepted && controls.ACCEPT) && controls.ACCEPT) {
            CoolUtil.playMenuSFX(1);
            if (buttons[curSelected].callback != null) buttons[curSelected].callback();
            close();
        }
    }

    public function changeSelection(am:Int = 0) {
        if (am != 0 && buttons.length > 1) CoolUtil.playMenuSFX(0);
        curSelected = CoolUtil.wrapInt(curSelected + am, 0, alphabets.length);
        for(k=>a in alphabets) {
            a.alpha = k == curSelected ? 1 : 0.5;
        }
    }
}