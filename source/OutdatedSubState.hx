package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var files:Array<String>;
	var ver:String;
	var changelog:String;
	public function new(files:Array<String>, ver:String, changelog:String) {
		this.files = files;
		this.ver = ver;
		this.changelog = changelog;
		super();
	}
	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('menuBGYoshiCrafter', 'preload'));
		bg.scale.set(1.2, 1.2);
		bg.screenCenter();
		add(bg);

		#if windows
		var anims = ['enter to update', 'space to check github', 'backspace to skip'];
		#else
		var anims = ['enter to update', 'backspace to skip'];
		#end
		// var xOffset:Float = 10;

		for (i in 0...anims.length) {
			var b = new FlxSprite(10, 0);
			b.frames = Paths.getSparrowAtlas("outdatedAssets", "preload");
			b.animation.addByPrefix("anim", anims[i]);
			b.animation.play("anim");
			b.setGraphicSize(Std.int(b.width * 0.75));
			b.y = 710 - b.height;
			b.x = ((FlxG.width) * ((i + 0.5) / anims.length)) - (b.width / 2);
			b.antialiasing = true;
			add(b);
		}


		var localVer = Main.engineVer;
		var latestVer = ver;

		var txt:FlxText = new FlxText(0, 10, FlxG.width,
			"HEY ! Your YoshiCrafter Engine is outdated !\n"
			+ 'v$localVer < v$latestVer\n'
			,32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txt.screenCenter(X);
		add(txt);

		var changelog = new FlxText(100, txt.y + txt.height + 20, 1080, changelog, 16);
		changelog.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(changelog);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			#if windows
				FlxG.switchState(new UpdateState(files));
			#else
				FlxG.openURL('https://www.github.com/YoshiCrafter29/YoshiCrafterEngine/releases/latest');
			#end
		}
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.openURL('https://www.github.com/YoshiCrafter29/YoshiCrafterEngine/releases/latest');
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
