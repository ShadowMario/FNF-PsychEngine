
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import lime.utils.Assets;
import openfl.display.BitmapData;
import sys.FileSystem;
import flixel.addons.ui.*;

class ModCard extends FlxSpriteGroup {
    var m:ModConfig;

    var mod_name:AlphabetOptimized;
    var mod_desc:FlxUIText;
    var mod_icon:FlxUISprite;

    public var mod:String;
    public override function new(modFolder:String, mod:ModConfig) {
        super();
        this.mod = modFolder;

        var bg = new FlxSprite(0, 0).loadGraphic(Paths.image('modcardbg', 'preload'));

        mod_name = new AlphabetOptimized(10, 10, "Mod Name", false, 0.5);
        mod_name.doOptimisationStuff = false;

        mod_desc = new FlxUIText(170, mod_name.y + 50, 460, "Mod Description");
        mod_icon = new FlxUISprite(10, mod_name.y + 50);
        mod_icon.makeGraphic(150, 150, 0xFF000000, true);
        mod_icon.antialiasing = true;
        mod_icon.antialiasing = true;
        add(bg);
        add(mod_name);
        add(mod_desc);
        add(mod_icon);

        updateMod(modFolder);

    }

    public function updateMod(mod:String) {
        this.mod = mod;
        m = ModSupport.modConfig[mod];
        var mod = m;
        
        mod_name.text = mod.name != null ? mod.name : this.mod;
        mod_desc.text = mod.description != null ? mod.description : "(No description)";
		var asset = Paths.getPath('modIcon.png', IMAGE, 'mods/${this.mod}');
        mod_icon.loadGraphic(Assets.exists(asset) ? asset : Paths.image("modEmptyIcon", "preload"));
        mod_icon.setGraphicSize(150, 150);
        mod_icon.updateHitbox();
        mod_icon.scale.set(Math.min(mod_icon.scale.x, mod_icon.scale.y), Math.min(mod_icon.scale.x, mod_icon.scale.y));
    }

}