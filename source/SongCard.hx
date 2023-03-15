package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;

class SongCard extends FlxSprite
{
    var size:Float = 0;

    // based on vs impostor
    public function new(_x:Float, _y:Float, _song:String){
        super(_x, _y);

        var data:String = Assets.getText(Paths.txt(_song.toLowerCase().replace(' ', '-') + '/info'));
        data += '\n';
        var dataArray:Array<String> = [];

        dataArray = data.split('\n');

        dataArray.resize(2);
        trace(dataArray.length);

        var songName = new FlxText(0, 0, 0, "", 24);
        songName.setFormat(Paths.font("fontybot.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        var artist = new FlxText(0, 30, 0, "", 24);
        artist.setFormat(Paths.font("fontybot.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        songName.text = dataArray[0];
        artist.text = dataArray[1];

        for (e in [songName, artist])
            e.updateHitbox();

        size = artist.width;

        var bg = new FlxSprite(24/-2, 24/-2).makeGraphic(Math.floor(size + 24), Std.int(text.height + text2.height + 15), FlxColor.WHITE);
        bg.height = text.height + text2.height;
        bg.alpha = 0.47;

        text.text += "\n";

        add(bg);
        add(songName);
        add(artist);

        x -= size;
        alpha = 0.00000001;
    }

    public function start(){
        alpha = 1;

        FlxTween.tween(this, {x: x + size + (24/2)}, 1, {ease: FlxEase.quintInOut, onComplete: function(twn:FlxTween){
            FlxTween.tween(this, {x: x - size - 50}, 1, {ease: FlxEase.quintInOut, startDelay: 2, onComplete: function(twn:FlxTween){ 
                this.destroy();
            }});
        }});
    }
}