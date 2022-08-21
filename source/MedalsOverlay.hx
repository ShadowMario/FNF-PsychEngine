import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class MedalsOverlay extends FlxSpriteGroup {

    public var archivementSprite:MedalSprite;
    public var bg:FlxSprite;
    public var t:Float = 0;

    public function new(mod:String, medal:MedalsJSON.Medal) {
        super();
        bg = new FlxSprite(0, 0).makeGraphic(1, 1, 0xAA000000, true);
        bg.scrollFactor.set();
        add(bg);

        // prevents asset override
        var oldMod = Settings.engineSettings.data.selectedMod;

        var medalUnlockedText:AlphabetOptimized = new AlphabetOptimized(10, 10, "Medal Unlocked", false, 18 / 60);
        medalUnlockedText.x = ((FlxG.width * 0.3) - medalUnlockedText.width) / 2;
        medalUnlockedText.scrollFactor.set();
        add(medalUnlockedText);

        archivementSprite = new MedalSprite(mod, medal, true);
        archivementSprite.setPosition(10, 0);
        archivementSprite.scrollFactor.set();
        add(archivementSprite);
        
        bg.scale.set(130 + Math.max(archivementSprite.title.width, medalUnlockedText.width), 100);
        bg.updateHitbox();
        scrollFactor.set();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        t += elapsed;
        if (t < 0.5) {
            setPosition(FlxMath.lerp(-(bg.scale.x), 10, FlxEase.cubeOut(t * 2)), 10);
        } else if (t > 6) {
            // destroy
            FlxG.state.remove(this);
            destroy();
            MusicBeatState.medalOverlay.remove(this);
        } else if (t > 5) {
            setPosition(FlxMath.lerp(10, -(bg.scale.x), FlxEase.cubeIn(t - 5)), 10);
        } else {
            setPosition(10, 10);
        }
    }
}