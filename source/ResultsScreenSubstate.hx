package;

import flixel.FlxCamera;
import Song;
import Highscore;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import PlayState;

class ResultsScreenSubstate extends MusicBeatSubstate {
	var uiCamera:FlxCamera = new FlxCamera();
	public var playState = new PlayState();

	public function new() {
		super();
	playState.endedTheSong = true; //the next time endSong is triggered, end the song

        if (ClientPrefs.skipResultsScreen) {
            PlayState.instance.endSong();
            return;
        }
		var leDate = Date.now();
		if (leDate.getHours() >= 6 && leDate.getHours() <= 18) {
		FlxG.sound.playMusic(Paths.music('PeggleCreditsOST'), 0);
		} else {
		FlxG.sound.playMusic(Paths.music('PeggleNightsProgressOST'), 0);
		}		
		FlxG.sound.music.fadeIn(2, 0, 0.5);

		uiCamera.bgColor.alpha = 0;
		FlxG.cameras.add(uiCamera, false);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.y -= 100;
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6, y: bg.y + 100}, 0.4, {ease: FlxEase.quartInOut});

		var topString = PlayState.SONG.song + " - " + CoolUtil.difficultyString() + " complete! (" + Std.string(playState.playbackRate) + "x)";

		var topText:FlxText = new FlxText((FlxG.width / 2) - 248, 19, 0, topString, 32);
		topText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		topText.scrollFactor.set();
		add(topText);

		var ratings:FlxText = new FlxText(0, FlxG.height, 0, '');
		ratings.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		ratings.screenCenter(Y);
		ratings.scrollFactor.set();
		add(ratings);

		if (!ClientPrefs.noMarvJudge)
		{
		ratings.text = 'Marvelous!!!: ' + playState.marvs + '\nSicks!!: ' + playState.sicks + '\nGoods!: ' + playState.goods + '\nBads: ' + playState.bads + '\nShits: ' + playState.shits + '\nMisses: ' + playState.songMisses;
		if (ClientPrefs.hudType == 'Doki Doki+') ratings.text = 'Very Doki: ' + playState.marvs + '\nDoki: ' + playState.sicks + '\nGood: ' + playState.goods + '\nOK: ' + playState.bads + '\nNO: ' + playState.shits + '\nMiss: ' + playState.songMisses;
		if (ClientPrefs.hudType == 'VS Impostor') ratings.text = 'SO SUSSY: ' + playState.marvs + '\nSussy: ' + playState.sicks + '\nSus: ' + playState.goods + '\nSad: ' + playState.bads + '\nAss: ' + playState.shits + '\nMiss: ' + playState.songMisses;
		}
		if (ClientPrefs.noMarvJudge)
		{
		ratings.text = 'Sicks!!: ' + playState.sicks + '\nGoods!: ' + playState.goods + '\nBads: ' + playState.bads + '\nShits: ' + playState.shits + '\nMisses: ' + playState.songMisses;
		if (ClientPrefs.hudType == 'Doki Doki+') ratings.text = 'Doki: ' + playState.sicks + '\nGood: ' + playState.goods + '\nOK: ' + playState.bads + '\nNO: ' + playState.shits + '\nMiss: ' + playState.songMisses;
		if (ClientPrefs.hudType == 'VS Impostor') ratings.text = 'Sussy: ' + playState.sicks + '\nSus: ' + playState.goods + '\nSad: ' + playState.bads + '\nAss: ' + playState.shits + '\nMiss: ' + playState.songMisses;
		}

		@:privateAccess
		var bottomText:FlxText = new FlxText(FlxG.width, FlxG.height, 0,
			"Press ENTER to close this menu.");
		bottomText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		bottomText.setPosition(FlxG.width - bottomText.width - 2, FlxG.height - 32);
		bottomText.scrollFactor.set();
		add(bottomText);

		cameras = [uiCamera];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER) {
		playState.endedTheSong = true;
			PlayState.instance.endSong();
            return;
	}
        }
}
