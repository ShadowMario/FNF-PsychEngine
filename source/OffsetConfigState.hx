import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.addons.ui.*;
import flixel.tweens.FlxEase;
import flixel.*;
import flixel.math.FlxMath;

class OffsetConfigState extends MusicBeatState {

    var chars:Array<Character> = [];
    var offsetLabel:FlxUIText;
    public function new() {
        super();
    }

    public function generateStage() {
        var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('default_stage/stageback', 'mods/Friday Night Funkin\''));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);
    
        var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('default_stage/stagefront', 'mods/Friday Night Funkin\''));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);
    
        var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('default_stage/stagecurtains', 'mods/Friday Night Funkin\''));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        add(stageCurtains);
    }
    public override function create() {
        super.create();
        
        generateStage();

        var gf = new Character(100, 100, "Friday Night Funkin':gf");
        chars.push(gf);
        add(gf);

        var bf = new Character(770, 100, "Friday Night Funkin':bf", true);
        chars.push(bf);
        add(bf);

        FlxG.sound.playMusic(Paths.modInst('tutorial', "Friday Night Funkin'", "hard"));
        Conductor.changeBPM(100);
        Conductor.songPosition = -5000;
        Conductor.songPositionOld = -5000;

        FlxG.camera.scroll.set(gf.getMidpoint().x - (FlxG.width / 2), gf.getMidpoint().y - (FlxG.height / 2));

        var hud = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.add(hud, false);
        hud.bgColor = 0;

        var title = new Alphabet(0, 0, "Offset Settings", true);
        title.y = 15;
        for(m in title.members) {
            m.scale.x *= 0.75;
            m.scale.y *= 0.75;
            m.updateHitbox();
            m.x *= 0.75;
            m.y *= 0.75;
        }
        title.screenCenter(X);
        title.cameras = [hud];

        var thing = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(title.height) + 30, 0x88000000, true);
        thing.cameras = [hud];
        add(thing);
        add(title);

        var bar1 = new FlxBar(100, (FlxG.height * 0.95) - 17, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.2) - 100 + 1, 17, Settings.engineSettings.data, "noteOffset", -100, 0, true);
        bar1.cameras = [hud];
        bar1.createGradientBar([0xFF7163F1, 0xFFD15CF8], [0x88222222], 1, 90, true, 0xFF000000);
        add(bar1);

        var bar2 = new FlxBar(Std.int(FlxG.width * 0.2), (FlxG.height * 0.95) - 17, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.8) - 100, 17, Settings.engineSettings.data, "noteOffset", 0, 400, true);
        bar2.cameras = [hud];
        bar2.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);
        add(bar2);

        var bar1label = new FlxUIText(bar1.x, bar1.y + bar1.height + 10, 0, "-100ms");
        bar1label.setFormat(null, 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
        bar1label.x -= bar1label.width / 2;
        bar1label.cameras = [hud];
        add(bar1label);

        var bar2label = new FlxUIText(bar2.x + bar2.width, bar2.y + bar2.height + 10, 0, "400ms");
        bar2label.setFormat(null, 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
        bar2label.x -= bar2label.width / 2;
        bar2label.cameras = [hud];
        add(bar2label);


        offsetLabel = new FlxUIText(100, bar2.y + bar2.height + 10, FlxG.width - 200, "0ms");
        offsetLabel.setFormat(null, 24, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
        offsetLabel.cameras = [hud];
        add(offsetLabel);

        bar1label.y -= bar1label.height;
        bar1.y -= bar1label.height;
        bar2label.y -= bar1label.height;
        bar2.y -= bar1label.height;
        offsetLabel.y -= bar1label.height;
    }

    public override function beatHit() {
        super.beatHit();
        for(c in chars) {
            c.dance();
        }
    }
    public override function update(elapsed:Float) {
        if (controls.RIGHT_P) {
            Settings.engineSettings.data.noteOffset += 2;
        }
        if (controls.LEFT_P) {
            Settings.engineSettings.data.noteOffset -= 2;
        }
        if (controls.RIGHT && FlxControls.pressed.SHIFT) {
            Settings.engineSettings.data.noteOffset += 25 * elapsed;
        }
        if (controls.LEFT && FlxControls.pressed.SHIFT) {
            Settings.engineSettings.data.noteOffset -= 25 * elapsed;
        }
        if (controls.RESET) Settings.engineSettings.data.noteOffset = 0;
        
        if (controls.BACK) {
            Settings.engineSettings.data.noteOffset -= Settings.engineSettings.data.noteOffset % 1;
            FlxG.sound.music.fadeOut(500);
            FlxG.switchState(new OptionsMenu(0, 0));
        }

        Settings.engineSettings.data.noteOffset = FlxMath.bound(Settings.engineSettings.data.noteOffset, -100, 400);
        offsetLabel.text = '${Std.string(Math.floor(Settings.engineSettings.data.noteOffset))}ms';
		Conductor.songPosition += Settings.engineSettings.data.noteOffset;
        if (FlxG.sound.music.time == Conductor.songPositionOld) {
            Conductor.songPosition += FlxG.elapsed * 1000;
        } else {
            Conductor.songPosition = Conductor.songPositionOld = FlxG.sound.music.time;
        }
		Conductor.songPosition -= Settings.engineSettings.data.noteOffset;

        super.update(elapsed);

        FlxG.camera.zoom = FlxMath.lerp(1.025 * 0.8, 0.8, FlxEase.quartOut((Conductor.songPosition % (Conductor.crochet * 2)) / (2 * Conductor.crochet)));
    }
}