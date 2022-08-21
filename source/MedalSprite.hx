import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class MedalSprite extends FlxSpriteGroup {
    public var title:AlphabetOptimized;
    public var img:FlxSprite;
    public var locked:Bool = false;

    public function new(mod:String, medal:MedalsJSON.Medal, ?showAsUnlocked:Bool = false) {
        super();
        title = new AlphabetOptimized(110, 35, medal.name, false, 0.5);
        title.textColor = 0xFFFFFFFF;
        add(title);

        img = new FlxSprite(0, 0);
        if (medal.img != null) {
            if (Assets.exists(Paths.file('images/${medal.img.src}.xml', TEXT, 'mods/${mod}'))) {
                img.frames = Paths.getSparrowAtlas(medal.img.src, 'mods/${mod}');
                img.animation.addByPrefix('anim', medal.img.anim, medal.img.fps, true);
                img.animation.play('anim');
            } else {
                img.loadGraphic(Paths.image(medal.img.src, 'mods/${mod}'));
            }
        }
        img.setGraphicSize(100, 100);
        img.updateHitbox();
        var min = Math.min(img.scale.x, img.scale.y);
        img.scale.set(min, min);
        img.antialiasing = true;
        add(img);

        if (Medals.getState(mod, medal.name) == LOCKED && !showAsUnlocked) {
            title.text = "???";
            img.setColorTransform(0, 0, 0, 1);

            var lock = new FlxSprite(50, 50);
            lock.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets', 'preload');
            lock.animation.addByPrefix('lock', 'lock', 0, false);
            lock.animation.play('lock');
            lock.antialiasing = true;
            lock.scale.set(0.75, 0.75);
            lock.updateHitbox();
            lock.x -= lock.width / 2;
            lock.y -= lock.height / 2;
            add(lock);

            locked = true;
        }
    }
}