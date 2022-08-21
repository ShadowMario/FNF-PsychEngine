import flixel.math.FlxRect;
import options.screens.KeybindsMenu;
import flixel.math.FlxMath;
import NoteShader.ColoredNoteShader;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxBasic;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import Note.NoteDirection;
import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class ControlsSettingsSubState extends MusicBeatSubstate {

    public static final customKeybindsNameOverride:Map<String, String> = [
        "numpadone" => "Numpad 1",
        "numpadtwo" => "Numpad 2",
        "numpadthree" => "Numpad 3",
        "numpadfour" => "Numpad 4",
        "numpadfive" => "Numpad 5",
        "numpadsix" => "Numpad 6",
        "numpadseven" => "Numpad 7",
        "numpadeight" => "Numpad 8",
        "numpadnine" => "Numpad 9",
        "numpadzero" => "Numpad 0",
        "one" => "1",
        "two" => "2",
        "three" => "3",
        "four" => "4",
        "five" => "5",
        "six" => "6",
        "seven" => "7",
        "eight" => "8",
        "nine" => "9",
        "zero" => "0",
        "numpadplus" => "Numpad +",
        "numpadminus" => "Numpad -",
        "numpadmultiply" => "Numpad *"
    ];
    public static final customKeybindsNameOverrideSimple:Map<String, String> = [
        "numpadone" => "#1",
        "numpadtwo" => "#2",
        "numpadthree" => "#3",
        "numpadfour" => "#4",
        "numpadfive" => "#5",
        "numpadsix" => "#6",
        "numpadseven" => "#7",
        "numpadeight" => "#8",
        "numpadnine" => "#9",
        "numpadzero" => "#0",
        "one" => "1",
        "two" => "2",
        "three" => "3",
        "four" => "4",
        "five" => "5",
        "six" => "6",
        "seven" => "7",
        "eight" => "8",
        "nine" => "9",
        "zero" => "0",
        "numpadplus" => "#+",
        "numpadminus" => "#-",
        "numpadmultiply" => "#*"
    ];
    var bg = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFF000000, true);

    public var strums:Array<FlxSprite> = [];
    public var labels:Array<AlphabetOptimized> = [];

    public var arrowNumber = 4;
    public var size:Float = 0;
    public var curSelected:Int = 0;
    public var currentKeys:Array<FlxKey> = [];
    public var changeThingGrp:FlxSpriteGroup = new FlxSpriteGroup();
    public var strumsGrp:FlxSpriteGroup = new FlxSpriteGroup();
    public var callback:Void->Void = null;
    public var sizeRect:FlxRect = new FlxRect();

    public function new(arrowNumber:Int, camera:FlxCamera, ?callback:Void->Void) {
        var engineSettings = Settings.engineSettings.data;
        sizeRect.width = FlxG.width;
        sizeRect.height = FlxG.height;
        if (PlayState.current != null) {
            engineSettings = PlayState.current.engineSettings;
            sizeRect.width = PlayState.current.guiSize.x;
            sizeRect.height = PlayState.current.guiSize.y;
        }
        
        super();
        this.cameras = [camera];
        this.arrowNumber = arrowNumber;
        this.callback = callback;
        bg.alpha = 0.5;
        add(bg);

        var title = new AlphabetOptimized(0, 20, "Change Keybinds", true, 0.75);
        title.screenCenter(X);
        add(title);

        var statusThing = new AlphabetOptimized(10, sizeRect.height - 70, "[Enter] Change Selected Keybind | [Esc] Save & Exit", false, 0.5);
        statusThing.screenCenter(X);
        add(statusThing);

        size = Note._swagWidth;

        for(i in 0...arrowNumber) {
            var babyArrow = new FlxSprite(size * (i), 110);
            
            babyArrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored', 'shared') : Paths.getSparrowAtlas(engineSettings.customArrowSkin.toLowerCase(), 'skins');
					
            babyArrow.animation.addByPrefix('up', 'arrowUP');
            babyArrow.animation.addByPrefix('down', 'arrowDOWN');
            babyArrow.animation.addByPrefix('left', 'arrowLEFT0');
            babyArrow.animation.addByPrefix('right', 'arrowRIGHT0');
            var color = [
                new FlxColor(Settings.engineSettings.data.arrowColor0),
                new FlxColor(Settings.engineSettings.data.arrowColor1),
                new FlxColor(Settings.engineSettings.data.arrowColor2),
                new FlxColor(Settings.engineSettings.data.arrowColor3)
            ][i % 4];
            babyArrow.shader = new ColoredNoteShader(color.red, color.green, color.blue, false);
            cast(babyArrow.shader, ColoredNoteShader).enabled.value = [false];

            var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[arrowNumber];
            if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];
            switch (noteNumberScheme[i % noteNumberScheme.length])
            {
                case Left:
                    babyArrow.animation.addByPrefix('static', 'arrowLEFT0');
                    babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                case Down:
                    babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                    babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                case Up:
                    babyArrow.animation.addByPrefix('static', 'arrowUP');
                    babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                case Right:
                    babyArrow.animation.addByPrefix('static', 'arrowRIGHT0');
                    babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
            }

            babyArrow.animation.play("static");
            babyArrow.antialiasing = true;
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
            babyArrow.camera = camera;

            
            babyArrow.centerOffsets();
            babyArrow.centerOrigin();
            babyArrow.offset.y = 30;

            strums.push(babyArrow);
            strumsGrp.add(babyArrow);

            var key:FlxKey = cast(Reflect.field(Settings.engineSettings.data, 'control_' + arrowNumber + '_$i'), FlxKey);
            currentKeys.push(key);

            var t = new AlphabetOptimized(babyArrow.x + (babyArrow.width / 2), babyArrow.y + size + 20, getKeyName(key, true), false, 0.5);
            t.textColor = 0xFFFFFFFF;
            t.x -= t.width / 2;
            labels.push(t);
            strumsGrp.add(t);
        }

        var bg = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFF000000, true);
        bg.alpha = 0.5;
        changeThingGrp.add(bg);

        var instructions = new AlphabetOptimized(30, 30, "Press any key to change the keybind\n     or press [Esc] to cancel.", false, 0.75);
        instructions.screenCenter();
        instructions.y -= 60;

        changeThingGrp.add(instructions);
        add(strumsGrp);
        add(changeThingGrp);
        if (strumsGrp.width < sizeRect.width - size)
            strumsGrp.screenCenter(X);
        else
            strumsGrp.x = size / 2;
    }

    var isChanging:Bool = false;
    var isAccept:Bool = true;

    public function updateLabels() {
        for(i=>k in currentKeys) {
            var label = labels[i];
            var strum = strums[i];

            label.text = getKeyName(k, true);
            label.x = strum.x + ((strum.width - label.width) / 2);
        }
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);
        changeThingGrp.visible = isChanging;
        if (!controls.ACCEPT) isAccept = false;
        if (isChanging) {
            if (controls.BACK) {
                isChanging = false;
            } else {
                var k = 0;
                if ((k = FlxControls.firstJustPressed()) != -1) {
                    var key:FlxKey = cast(k, FlxKey);
                    currentKeys[curSelected] = key;
                    isChanging = false;
                    updateLabels();
                }
            }
        } else {
            if (strumsGrp.width >= sizeRect.width - size) {
                strumsGrp.x = FlxMath.lerp(strumsGrp.x, FlxMath.bound(-curSelected * size + (sizeRect.width / 2) - (size * 0.5), -(strumsGrp.width - sizeRect.width) - 100, 100), 0.125 * 60 * elapsed); 
            } else {
                strumsGrp.screenCenter(X); // since widescreen doesnt break shit anymore
            }
            if (controls.BACK) {
                for(i=>k in currentKeys) {
                    Reflect.setField(Settings.engineSettings.data, 'control_' + arrowNumber + '_$i', k);
                    if (PlayState.current != null && PlayState.current.engineSettings != null) {
                        Reflect.setField(PlayState.current.engineSettings, 'control_' + arrowNumber + '_$i', k);
                    }
                }
                CoolUtil.playMenuSFX(1);
                close();
                if (callback != null) callback();
            }
            if (controls.LEFT_P) curSelected--;
            if (controls.RIGHT_P) curSelected++;
            if (curSelected < 0) curSelected = arrowNumber + (curSelected % arrowNumber);
            curSelected %= arrowNumber;
            for(k=>s in strums) {
                s.alpha = FlxMath.lerp(s.alpha, (k == curSelected ? 1 : 0.3), 0.25 * 60 * elapsed);
                s.offset.y = FlxMath.lerp(s.offset.y, (k == curSelected ? 10 : 30), 0.25 * 60 * elapsed);
            }
            if (controls.ACCEPT && !isAccept) {
                isChanging = true;
            }
        }
        if (controls.ACCEPT) isAccept = true;
    }

    public static function getKeyName(key:FlxKey, simple:Bool = false) {
        if (customKeybindsNameOverrideSimple[Std.string(key).toLowerCase()] != null && simple) {
            return customKeybindsNameOverrideSimple[Std.string(key).toLowerCase()];
        } else if (customKeybindsNameOverride[Std.string(key).toLowerCase()] != null) {
            return customKeybindsNameOverride[Std.string(key).toLowerCase()];
        } else {
            return Std.string(key);
        }
    }
}