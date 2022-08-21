import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.effects.FlxFlicker;

class FlashWarningState extends MusicBeatState {
    var checkboxSelected:Bool = false;
    var enableSelected:Bool = false;

    var canSelect:Bool = true;

    var checkbox:FunkinCheckbox;
    var checkboxLabel:AlphabetOptimized;

    var enableLabel:AlphabetOptimized;
    var disableLabel:AlphabetOptimized;

    var callback:Void->Void;
    
    public function new(callback:Void->Void) {
        super();
        this.callback = callback;
    }

    public override function create() {
        super.create();
        var title = new AlphabetOptimized(0, 0, "Flashing Lights", false);
        title.screenCenter(X);
        title.y = 200;
        add(title);

        var notice = new FlxText(0, title.y + 70, FlxG.width, "One of the mods you've installed contains flashing lights.\nIf you're sensible to these, select \"Disable\" to disable them, or \"Enable\" to enable them if you're comfortable with it. You'll be able to change that setting in the options menu.\n\nYou can also check \"Do not warn me again\" to prevent this message from appearing after installing a new mod with flashing lights.");
        notice.setFormat(Paths.font("vcr.ttf"), Std.int(24), 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        notice.antialiasing = true;
        add(notice);

        checkbox = new FunkinCheckbox(50, notice.y + notice.height + 35, false);
        checkbox.scale.set(0.5, 0.5);
        checkbox.updateHitbox();
        add(checkbox);

        checkboxLabel = new AlphabetOptimized(checkbox.x + checkbox.width + 20, checkbox.y + (checkbox.height / 2) - 20, "Do not warn me again", false, 0.5);
        add(checkboxLabel);

        enableLabel = new AlphabetOptimized(FlxG.width * 0.25, FlxG.height * 0.75, "Enable", false);
        enableLabel.x -= enableLabel.width / 2;
        disableLabel = new AlphabetOptimized(FlxG.width * 0.75, FlxG.height * 0.75, "Disable", false);
        disableLabel.x -= enableLabel.width / 2;
        add(enableLabel);
        add(disableLabel);

        FlxG.camera.zoom = 0.1;
        FlxTween.tween(FlxG.camera, {zoom: 1}, 0.75, {ease: FlxEase.elasticOut});
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        //
        // CONTROLS
        //
        if (canSelect) {
            if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP) {
                CoolUtil.playMenuSFX(0);
                checkboxSelected = !checkboxSelected;
            }
            if (checkboxSelected) {
                if (FlxG.keys.justPressed.ENTER) {
                    checkbox.check(!checkbox.checked);
                }
            } else {
                if ((FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)) {
                    CoolUtil.playMenuSFX(0);
                    enableSelected = !enableSelected;
                }
                if (FlxG.keys.justPressed.ENTER) {
                    canSelect = !canSelect;
                    Settings.engineSettings.data.flashingLights = enableSelected;
                    Settings.engineSettings.data.flashingLightsDoNotShow = checkbox.checked;
                    CoolUtil.playMenuSFX(1);
                    FlxFlicker.flicker(enableSelected ? enableLabel : disableLabel, 1.5, 0.15, true, true, function(f) {
                        callback();
                    });
                }
            }
        }

        checkboxLabel.textColor = checkboxSelected ? 0xFF44FFFF : -1;
        enableLabel.textColor = (enableSelected && !checkboxSelected) ? 0xFF44FFFF : -1;
        disableLabel.textColor = (!enableSelected && !checkboxSelected) ? 0xFF44FFFF : -1;
    }
}