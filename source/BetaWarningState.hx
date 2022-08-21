import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIText;
import flixel.addons.transition.FlxTransitionableState;

class BetaWarningState extends FlxState {
    var accepted = false;
    public function new() {
        super();
    }
    public override function create() {
        super.create();
        var warningAlphabet = new AlphabetOptimized(0, 200, "WARNING!", true);
        warningAlphabet.screenCenter(X);
        add(warningAlphabet);

        var text = new FlxText(0, warningAlphabet.y + warningAlphabet.height + 20, FlxG.width - 200, "This version of YoshiCrafter Engine is currently in beta. That means that features may be incomplete or subject to change. If you're making a mod in this version, i won't be responsible for errors and bugs for the in-dev features.\nThere is a known bug with the game crashing between states, and we're already working on a fix.\n\nPress [ENTER] to continue.");
        text.screenCenter(X);
        text.setFormat(Paths.font("vcr.ttf"), Std.int(24), 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        text.antialiasing = true;
        add(text);
        CoolUtil.playMenuSFX(5);
        FlxG.camera.zoom = 0.1;
        FlxTween.tween(FlxG.camera, {zoom: 1}, 0.75, {ease: FlxEase.elasticOut});
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (!accepted && (accepted = FlxG.keys.justPressed.ENTER)) {
            CoolUtil.playMenuSFX(1);
            FlxG.camera.flash(0x88FFFFFF, 1, function() {
                new FlxTimer().start(0.5, function(t) {
                    FlxG.camera.fade(0xFF000000, 1.5, false, function() {
                        FlxG.switchState(new TitleState());
                    });
                });
            });
        }
    }
}