package charter;

import haxe.io.Path;
import sys.FileSystem;
import flixel.addons.ui.FlxUIButton;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class NoteTypeSelector extends ChooseCharacterScreen {
    public override function changeSecondMenu(mod:String) {
        for(m in charsScroll.members) {
            if (m == null) continue;
            m.destroy();
            charsScroll.remove(m);
            remove(m);
        }
        FileSystem.createDirectory('${Paths.modsPath}/$mod/notes/');
        for(i=>t in [for(e in FileSystem.readDirectory('${Paths.modsPath}/$mod/notes/')) if (!FileSystem.isDirectory('${Paths.modsPath}/$mod/notes/$e')) if (Main.supportedFileTypes.contains(Path.extension(e.toLowerCase()))) e]) {
            var button = new FlxUIButton(Std.int(FlxG.width / 2), 50 + ((i) * 30), Path.withoutExtension(t), function() {
                close();
                if (callback != null) callback(mod, Path.withoutExtension(t));
            });
            button.label.alignment = LEFT;
            button.label.offset.x = 0;
            button.resize(300, 30);
            charsScroll.add(button);
        }
        trace(mod);
        charsScroll.y = 0;
        charsScrollY = 0;
    }
}