package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class LoadingScreen extends FlxTypedGroup<FlxSprite>
{
	public var progress:Int = 0;
	public var max:Int = 10;

	var loadingImage:FlxSprite;
	var loadTxtBg:FlxSprite;
	var loadTxtProgress:FlxSprite;
	var loadTxt:FlxText;

	public function new()
	{
		super();

		loadingImage = new FlxSprite(0, 0);

		if (PlayState.SONG != null)
		{
			if (PlayState.SONG.song.toLowerCase() == "ugh"
				|| PlayState.SONG.song.toLowerCase() == "guns"
				|| PlayState.SONG.song.toLowerCase() == "stress")
			{
				if (!FlxG.save.data.secretChars[5])
				{
					if (!FlxG.save.data.secretChars[6])
					{
						if (!FlxG.save.data.secretChars[7])
						{
							loadingImage.loadGraphic(Paths.image('nm/3', 'preload'));
						}
						else
						{
							loadingImage.loadGraphic(Paths.image('nm/2', 'preload'));
						}
					}
					else
					{
						loadingImage.loadGraphic(Paths.image('nm/1', 'preload'));
					}
				}
				else
				{
					loadingImage.loadGraphic(Paths.image('nm/0', 'preload'));
				}
			}
			else
			{
				loadingImage.loadGraphic(Paths.image('Loading_screen', 'preload'));
			}
		}
		else
		{
			loadingImage.loadGraphic(Paths.image('Loading_screen', 'preload'));
		}

		loadingImage.updateHitbox();
		loadingImage.screenCenter();
		add(loadingImage);

		loadTxtBg = new FlxSprite();
		add(loadTxtBg);

		loadTxtProgress = new FlxSprite();
		add(loadTxtProgress);

		loadTxt = new FlxText(0, 0, 0, "Ucitavanje...", 30);
		loadTxt.setFormat(HelperFunctions.returnMenuFont("VCR OSD Mono"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadTxt.x = 5;
		loadTxt.y = FlxG.height - loadTxt.height - 5;
		add(loadTxt);

		loadTxtBg.makeGraphic(1, 1, 0xFF000000);
		loadTxtBg.updateHitbox();
		loadTxtBg.origin.set();
		loadTxtBg.scale.set(1280, loadTxt.height + 5);
		loadTxtBg.alpha = 0.8;
		loadTxtBg.y = loadTxt.y;

		loadTxtProgress.makeGraphic(1, 1, 0x800080);
		loadTxtProgress.updateHitbox();
		loadTxtProgress.origin.set();
		loadTxtProgress.scale.set(0, loadTxt.height + 5);
		loadTxtProgress.alpha = 0.3;
		loadTxtProgress.y = loadTxt.y;

		loadTxt.y += 2;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerpTarget:Float = 1280.0 * (progress / max);
		loadTxtProgress.scale.x = FlxMath.lerp(loadTxtProgress.scale.x, lerpTarget, elapsed * 5);
	}

	public function setLoadingText(text:String)
	{
		loadTxt.text = text;
	}
}
