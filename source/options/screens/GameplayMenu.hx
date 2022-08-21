package options.screens;

import flixel.util.FlxColor;
import flixel.math.FlxMath;
import options.OptionScreen;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import Note.NoteDirection;
import NoteShader.ColoredNoteShader;

class GameplayMenu extends OptionScreen {
    var strums:FlxSpriteGroup = new FlxSpriteGroup();
    var arrow:FlxSprite;
    
    public function new() {
        super("Options > Gameplay");
    }

    public override function create() {
        options = [
            {
                name: "Downscroll",
                desc: "If enabled, Notes will scroll from up to down, instead of from down to up.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.downscroll);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll);}
            },
            {
                name: "Middlescroll",
                desc: "If enabled, Strums will be centered, and opponent strums will be hidden.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.middleScroll);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.middleScroll = !Settings.engineSettings.data.middleScroll);}
            },
            {
                name: "Scroll Speed",
                desc: "If enabled, override the chart's scroll speed. Press Enter to Enable/Disable.",
                value: "",
                onCreate: function(e) {
                    e.check(Settings.engineSettings.data.customScrollSpeed);
                    if (Settings.engineSettings.data.customScrollSpeed) {
                        e.value = Std.string(Settings.engineSettings.data.scrollSpeed);
                    }
                },
                onSelect: function(e) {
                    e.check(Settings.engineSettings.data.customScrollSpeed = !Settings.engineSettings.data.customScrollSpeed);
                    if (Settings.engineSettings.data.customScrollSpeed) {
                        e.value = '< ${Settings.engineSettings.data.scrollSpeed} >';
                    }
                },
                onLeft: function(e) {
                    e.check(Settings.engineSettings.data.customScrollSpeed);
                    if (Settings.engineSettings.data.customScrollSpeed) {
                        e.value = Std.string(Settings.engineSettings.data.scrollSpeed);
                    }
                },
                onUpdate: function(e) {
                    e.check(Settings.engineSettings.data.customScrollSpeed);
                    if (!Settings.engineSettings.data.customScrollSpeed) return;
                    var elapsed = FlxG.elapsed;
                    var oldScroll = FlxMath.roundDecimal(Settings.engineSettings.data.scrollSpeed, 1);

                    if (controls.LEFT_P)  Settings.engineSettings.data.scrollSpeed -= 0.1;
                    if (controls.RIGHT_P) Settings.engineSettings.data.scrollSpeed += 0.1;
                   
                    Settings.engineSettings.data.scrollSpeed = FlxMath.roundDecimal(Settings.engineSettings.data.scrollSpeed, 1);
                    noteTime = noteTime * oldScroll / Settings.engineSettings.data.scrollSpeed;
                    e.value = '< ${Settings.engineSettings.data.scrollSpeed} >';
                }
            },
            {
                name: "Ghost Tapping",
                desc: "If enabled, you won't get misses from pressing keys while there are no notes able to be hit.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.ghostTapping);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.ghostTapping = !Settings.engineSettings.data.ghostTapping);}
            },
            {
                name: "Configure Note Offset",
                desc: "Sync your Notes to the Song Beat, Useful for preventing audio lag from wireless earphones.",
                value: '${Std.int(Settings.engineSettings.data.noteOffset)}ms',
                onSelect: function(e) {doFlickerAnim(curSelected, function() {FlxG.switchState(new OffsetConfigState());});}
            },
            {
                name: "Botplay",
                desc: "If enabled, the game will be played by a bot. Useful for showcasing charts.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.botplay);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.botplay = !Settings.engineSettings.data.botplay);}
            },
            {
                name: "Accuracy mode",
                desc: "Sets the accuracy mode. Simple means based on the rating, Complex means based on the press delay.",
                value: "",
                additional: true,
                onCreate: function(e) {e.value = ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode];},
                onUpdate: function(e) {
                    if (controls.ACCEPT || controls.RIGHT_P) Settings.engineSettings.data.accuracyMode++;
                    if (controls.LEFT_P) Settings.engineSettings.data.accuracyMode--;
                    while(Settings.engineSettings.data.accuracyMode < 0) Settings.engineSettings.data.accuracyMode += ScoreText.accuracyTypesText.length;
                    Settings.engineSettings.data.accuracyMode %= ScoreText.accuracyTypesText.length;
                    e.value = '< ${ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode]} >';
                },
                onLeft: function(e) {
                    e.value = ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode];
                }
            },
            {
                name: "Flashing Lights",
                desc: "If unchecked, will disable every flashing lights on supported mods. Disable this if you're sensible to flashing.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.flashingLights);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.flashingLights = !Settings.engineSettings.data.flashingLights);}
            }
        ];
        super.create();
        for(i in 0...4) {
            var babyArrow = new FlxSprite(Note._swagWidth * i, 0);
            
            babyArrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored', 'shared') : Paths.getSparrowAtlas(Settings.engineSettings.data.customArrowSkin.toLowerCase(), 'skins');
					
					
            babyArrow.animation.addByPrefix('green', 'arrowUP');
            babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
            babyArrow.animation.addByPrefix('purple', 'arrowLEFT0');
            babyArrow.animation.addByPrefix('red', 'arrowRIGHT0');
            //babyArrow.colored = Settings.engineSettings.data.customArrowColors;

            babyArrow.antialiasing = true;
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
            
            switch (i)
            {
                case 0:
                    babyArrow.animation.addByPrefix('static', 'arrowLEFT0');
                case 1:
                    babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                case 2:
                    babyArrow.animation.addByPrefix('static', 'arrowUP');
                case 3:
                    babyArrow.animation.addByPrefix('static', 'arrowRIGHT0');
            }
            babyArrow.animation.play('static');
            strums.add(babyArrow);
        }
        add(strums);

        arrow = new FlxSprite(0, 0);
            
        arrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored', 'shared') : Paths.getSparrowAtlas(Settings.engineSettings.data.customArrowSkin.toLowerCase(), 'skins');
        arrow.animation.addByPrefix('green', 'green0');
        arrow.antialiasing = true;
        arrow.setGraphicSize(Std.int(arrow.width * 0.7));
        arrow.animation.play('green');
        var shader:ColoredNoteShader;
        var color:FlxColor = Settings.engineSettings.data.arrowColor2;
        arrow.shader = shader = new ColoredNoteShader(color.red, color.green, color.blue, false);

        add(arrow);
        if (Settings.engineSettings.data.downscroll) {
            strums.y = FlxG.height - Note._swagWidth - 50;
        } else {
            strums.y = 50;
        }
        if (Settings.engineSettings.data.middleScroll) {
            strums.x = FlxG.width / 2;
            strums.x -= strums.width / 2;
        } else {
            strums.x = FlxG.width / 4 * 3;
            strums.x -= strums.width / 2;
        }
    }

    var noteTime:Float = 0;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        var pointX:Float = 0;
        var pointY:Float = 0;

        if (curSelected < 3) {
            if (Settings.engineSettings.data.downscroll) {
                pointY = FlxG.height - Note._swagWidth - 50;
            } else {
                pointY = 50;
            }
            if (Settings.engineSettings.data.middleScroll) {
                pointX = FlxG.width / 2;
                pointX -= strums.width / 2;
            } else {
                pointX = FlxG.width / 4 * 3;
                pointX -= strums.width / 2;
            }
        } else {
            pointX = strums.x;
            pointY = -FlxG.height / 4;
        }
        var l = FlxMath.bound(0.125 * 60 * elapsed, 0, 1);
        strums.x = FlxMath.lerp(strums.x, pointX, l);
        strums.y = FlxMath.lerp(strums.y, pointY, l);
        arrow.alpha = strums.alpha = FlxMath.lerp(strums.alpha, curSelected < 3 ? 1 : 0, l);

        if (arrow.visible = (curSelected == 2 && Settings.engineSettings.data.customScrollSpeed)) {
            noteTime += elapsed;
            var notePos = FlxG.height - (((noteTime * 1000) * (0.45 * FlxMath.roundDecimal(Settings.engineSettings.data.scrollSpeed, 2))) % FlxG.height);
            if (Settings.engineSettings.data.downscroll) notePos = -notePos;
            arrow.x = strums.members[2].x;
            arrow.y = strums.members[2].y + notePos;
            arrow.visible = true;
        }
    }
}