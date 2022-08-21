package mod_support_stuff;

import openfl.utils.Assets;
import cpp.vm.Thread;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class SwitchMod extends FlxTypedSpriteGroup<FlxSprite> {
    public var modName:String = "";
    public var modDataName:String = "";
    public function new(x:Float, y:Float, modDataName:String, modName:String, modImage:FlxGraphicAsset) {
        this.modName = modName;
        this.modDataName = modDataName;
        super(x, y);
        this.scrollFactor.set(0, 0);
        var icon = new FlxSprite(0, 0);
        icon.antialiasing = true;
        add(icon);

        var modTitle = new Alphabet(0, 0, modName, false, false, FlxColor.WHITE);
        modTitle.x = 160;
        add(modTitle);

        var bmap = Assets.getBitmapData(modImage);
        if (bmap != null && icon.colorTransform != null) {
            icon.loadGraphic(bmap);
            icon.setGraphicSize(150, 150);
            icon.updateHitbox();
            icon.scale.set(Math.min(icon.scale.x, icon.scale.y), Math.min(icon.scale.x, icon.scale.y));
        }
    }

    public override function destroy() {
        super.destroy();
    }
}