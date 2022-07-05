package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import haxe.Json;
import ReplayState.ReplayFile;
import sys.io.File;

using CoolUtil;
using StringTools;

class ReplaySelectState extends MusicBeatState
{
    public static var menuItems:Array<String> = [];

    var dateText:FlxText;
    var diffText:FlxText;
    var songText:FlxText;
    
    var songName:String;

    var curSelected:Int;
    var grpMenuShit:FlxTypedGroup<Alphabet>;

    var difficulties:Array<Null<Int>> = [];
    var dates:Array<String> = [];

    var textSine:Float;

    public function new(songName:String)
    {
        super();
        this.songName = songName;
        menuItems = [];
    }

    override function create()
    {
        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

        final song:String = songName.toLowerCase().coolReplace('-', ' ');

        var path:Array<String> = CoolUtil.coolPathArray(Paths.getPreloadPath('replays/'));

        if (path != null && path.length > 0)
        {
            for (i in 0...path.length)
            {
                var file:String = path[i];
                
                if (!file.contains(song) || !file.endsWith('.json'))
                    continue;

                var replayFile:ReplayFile = Json.parse(File.getContent(Paths.getPreloadPath('replays/$file')));

                menuItems.push(file);
                difficulties.push(replayFile.currentDifficulty);
                dates.push(replayFile.date);
            }
        }

        grpMenuShit = new FlxTypedGroup<Alphabet>();
        add(grpMenuShit);

        if (menuItems.length > 0)
            for (i in 0...menuItems.length)
            {
                var replay:Alphabet = new Alphabet(0, (70 * i) + 10, 'Replay ${i + 1} ($song)', true, false);
                replay.isMenuItem = true;
                replay.targetY = i;
                replay.menuType = "Centered";
                replay.screenCenter(X);
                grpMenuShit.add(replay);
            }
        
        else
        {
            var texts:Array<String> = ['There is no replay', 'for $song!'];

            for (i in 0...texts.length)
            {
                var replay:Alphabet = new Alphabet(0, (70 * i) + 10, texts[i], true, false);
                replay.menuType = "Centered";
                replay.screenCenter(X);
                grpMenuShit.add(replay);
            }
        }

        changeSelection();
        
        FlxTween.tween(menuBG, {alpha: 1});

        dateText = new FlxText(10, 32, 0, "Replay save date: ", 30);
		dateText.scrollFactor.set();
        dateText.borderSize = 2;
		dateText.borderQuality = 2;
        dateText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(dateText);

        diffText = new FlxText(10, 64, 0, "Used difficulty:", 30);
        diffText.scrollFactor.set();
        diffText.borderSize = 2;
		diffText.borderQuality = 2;
        diffText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(diffText);

        songText = new FlxText(10, 96, 0, 'Song Name: ${songName.toUpperCase()}', 30);
        songText.scrollFactor.set();
        songText.borderSize = 2;
		songText.borderQuality = 2;
        songText.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(songText);

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var song:String = Highscore.formatSong(songName, difficulties[curSelected]);

        if (controls.UI_UP_P && menuItems.length > 0)
            changeSelection(-1);
        
        else if (controls.UI_DOWN_P && menuItems.length > 0)
            changeSelection(1);

        else if (controls.ACCEPT && menuItems.length > 0)
        {
            PlayState.SONG = Song.loadFromJson(song, songName);
            PlayState.storyDifficulty = difficulties[curSelected];
            LoadingState.loadAndSwitchState(new ReplayState(Std.parseInt(menuItems[curSelected].split(" ")[1])), true);
        }

        else if (controls.BACK)
            FlxG.switchState(new FreeplayState());

        if (menuItems.length <= 0)
        {
            textSine += 90 * elapsed;

            grpMenuShit.forEach(function(alphabet:Alphabet)
            {
                alphabet.alpha = 1 - Math.sin((Math.PI * textSine) / 180);
            });
        }

        var date:String = dates[curSelected];

        if (date != null)
            dateText.text = 'Replay save date: $date';
        else
            dateText.text = 'Replay save date: Unknown';

        if (difficulties[curSelected] == null)
            diffText.text = 'Used difficulty: Unknown';
        else
            diffText.text = 'Used difficulty: ${CoolUtil.defaultDifficulties[difficulties[curSelected]]}';
    }

    function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}