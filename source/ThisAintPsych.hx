import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

// meant to appear when you press 7 on the main menu
class ThisAintPsych extends MusicBeatSubstate {
    public override function new() {
        super();
        var bg1 = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xAA000000, true);
        bg1.scrollFactor.set(0, 0);
        add(bg1);

        var bg = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width / 2 + 20), FlxG.height - 20, 0x88000000, true);
        bg.scrollFactor.set(0, 0);
        bg.screenCenter();
        add(bg);

        var warningTextAlphabet = new Alphabet(0, 0, "Hi there", false, false, FlxColor.WHITE);
        warningTextAlphabet.screenCenter(X);
        warningTextAlphabet.y = 100;
        warningTextAlphabet.scrollFactor.set(0, 0);
        add(warningTextAlphabet);

        var text:FlxText = new FlxText(0, warningTextAlphabet.y + warningTextAlphabet.height + 10 + 75, (FlxG.width / 2 - 20),
        'You tried to press 7 on the Main Menu. Normally, on Psych Engine, it would take you to the secret mod editor menu, however, this engine works differently.
The engine uses a Developer Mode setting that allows users to access to the Toolbox to easily make mods.
Since you tried to access a mod maker menu, would you like to enable Developer Mode ?
It can be triggered on/off again in Options -> Developer Menu -> Developer Mode');
		text.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.screenCenter(X);
        text.scrollFactor.set(0, 0);
        add(text);

        var yesButton:FlxClickableSprite = new FlxClickableSprite(0, FlxG.height - 30);
        yesButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
        yesButton.animation.addByPrefix("yes", "yes button");
        yesButton.animation.play("yes");
        yesButton.y -= yesButton.height;
        yesButton.x = (FlxG.width / 2) - 10 - yesButton.width;
        yesButton.key = FlxKey.ENTER;
        yesButton.scrollFactor.set(0, 0);
        add(yesButton);

        var noButton:FlxClickableSprite = new FlxClickableSprite(0, FlxG.height - 30);
        noButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
        noButton.animation.addByPrefix("no", "no button");
        noButton.animation.play("no");
        noButton.y -= yesButton.height;
        noButton.x = (FlxG.width / 2) + 10;
        noButton.key = FlxKey.ESCAPE;
        noButton.scrollFactor.set(0, 0);
        add(noButton);

        var yesInfo = new FlxText(yesButton.x, yesButton.y + yesButton.height, yesButton.width, "(ENTER)");
        yesInfo.setFormat(yesInfo.font, yesInfo.size, yesInfo.color, CENTER);
        yesInfo.scrollFactor.set(0, 0);
        add(yesInfo);

        var noInfo = new FlxText(noButton.x, noButton.y + noButton.height, noButton.width, "(ESCAPE)");
        noInfo.setFormat(noInfo.font, noInfo.size, noInfo.color, CENTER);
        noInfo.scrollFactor.set(0, 0);
        add(noInfo);

        FlxG.sound.play(Paths.sound("scrollMenu", "preload"));
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.ACCEPT) {
            close();
            Settings.engineSettings.data.developerMode = true;
            FlxG.resetState();
            FlxG.sound.play(Paths.sound("confirmMenu", "preload"));
            return;
        }
        if (controls.BACK) {
            FlxG.sound.play(Paths.sound("cancelMenu", "preload"));
            close();
        }
    }
}