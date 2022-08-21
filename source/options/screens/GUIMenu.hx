package options.screens;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.FlxG;
import options.OptionScreen;
import flixel.group.FlxSpriteGroup;

class GUIMenu extends OptionScreen {

    var camHUD:FlxCamera;
    var scoreTxt:FlxText;
    var strums:FlxSpriteGroup = new FlxSpriteGroup();
    var msScoreLabel:FlxText;

    public function new() {
        super("Options > Customization > Customize HUD");
    }

    public override function create() {
        options = [
            {
                name: "Show timer",
                desc: "If enabled, will show a timer with the song name, time elapsed and song length.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showTimer);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showTimer = !Settings.engineSettings.data.showTimer);}
            },
            {
                name: "Show press delay",
                desc: "If enabled, will show the delay above the strums everytime a note is hit.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showPressDelay);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showPressDelay = !Settings.engineSettings.data.showPressDelay);}
            },
            {
                name: "Bump press delay",
                desc: "If enabled, will show the delay above the strums everytime a note is hit.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.animateMsLabel);},
                onEnter: function(e) {if (e.check(Settings.engineSettings.data.animateMsLabel)) msScoreLabel.offset.y = msScoreLabel.height / 3;},
                onSelect: function(e) {
                    if (e.check(Settings.engineSettings.data.animateMsLabel = !Settings.engineSettings.data.animateMsLabel)) {
                        msScoreLabel.offset.y = msScoreLabel.height / 3;
                    } else {
                        msScoreLabel.offset.y = 0;
                    }}
            },
            {
                name: "Show accuracy",
                desc: "If enabled, show your accuracy in percent on the Score Bar.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showAccuracy);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showAccuracy = !Settings.engineSettings.data.showAccuracy);}
            },
            {
                name: "Show accuracy mode",
                desc: "If enabled, will show the accuracy mode you're using (Simple or Complex).",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.showAccuracyMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showAccuracyMode = !Settings.engineSettings.data.showAccuracyMode);}
            },
            {
                name: "Show number of misses",
                desc: "If enabled, will show the number of misses.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showMisses);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showMisses = !Settings.engineSettings.data.showMisses);}
            },
            {
                name: "Show ratings amount",
                desc: "If enabled, will show the number of hits for each rating at the right of the screen.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.showRatingTotal);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showRatingTotal = !Settings.engineSettings.data.showRatingTotal);}
            },
            {
                name: "Show average hit delay",
                desc: "If enabled, will add your average delay in milliseconds next to the score.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showAverageDelay);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showAverageDelay = !Settings.engineSettings.data.showAverageDelay);}
            },
            {
                name: "Show rating",
                desc: "If enabled, will show your rating next to the score (ex : FC).",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showRating);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showRating = !Settings.engineSettings.data.showRating);}
            },
            {
                name: "Animate the Score Bar",
                desc: "If enabled, the Score bar will do a pop animation every time you hit a note.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.animateInfoBar);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.animateInfoBar = !Settings.engineSettings.data.animateInfoBar);}
            },
            {
                name: "Show watermark",
                desc: "If enabled, will show a watermark with the engine's name, the mod's name and the song name.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.watermark);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.watermark = !Settings.engineSettings.data.watermark);}
            },
            {
                name: "Minimal mode",
                desc: "When checked, will minimize the Score Text width.",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.minimizedMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.minimizedMode = !Settings.engineSettings.data.minimizedMode);}
            },
            {
                name: "Score Text Size",
                desc: "Sets the score text size. 16 is base game size, 20 is Psych size. Defaults to 18.",
                value: '${Settings.engineSettings.data.scoreTextSize}',
                additional: true,
                onUpdate: function(v) {
                    if (controls.LEFT_P) Settings.engineSettings.data.scoreTextSize -= 1;
                    if (controls.RIGHT_P) Settings.engineSettings.data.scoreTextSize += 1;
                    v.value = '< ${Settings.engineSettings.data.scoreTextSize} >';
                },
                onLeft: function(v) {
                    v.value = '${Settings.engineSettings.data.scoreTextSize}';
                }
            },
            {
                name: "Classic healthbar",
                desc: "When checked, will use the classic healthbar colors (Red & Green).",
                value: "",
                additional: true,
                onCreate: function(e) {e.check(Settings.engineSettings.data.classicHealthbar);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.classicHealthbar = !Settings.engineSettings.data.classicHealthbar);}
            },
            {
                name: "Show song name on timer",
                desc: "When checked, will show the song name on the timer.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.timerSongName);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.timerSongName = !Settings.engineSettings.data.timerSongName);}
            }
        ];

        super.create();

        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.add(camHUD, false);
        camHUD.bgColor = 0;
        camHUD.zoom = 1;

        var h = FlxG.height;

        scoreTxt = new FlxText(0, (h * (Settings.engineSettings.data.downscroll ? 0.075 : 0.9)) + 30, FlxG.width, "Score: 123456 | Misses: 0 | Accuracy: 100% (Simple) | Average: 5ms | S (MFC)", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), Std.int(Settings.engineSettings.data.scoreTextSize), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scale.x = 1;
		scoreTxt.scale.y = 1;
		scoreTxt.antialiasing = true;
		scoreTxt.cameras = [camHUD];
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();

        for(i in 0...4) {
            var babyArrow = new FlxSprite(Note._swagWidth * i, 0);
            
            babyArrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets', 'shared') : Paths.getSparrowAtlas(Settings.engineSettings.data.customArrowSkin.toLowerCase(), 'skins');
					
					
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
        strums.screenCenter(X);
        strums.y = 50;

        msScoreLabel = new FlxText(
			strums.x,
			strums.y - 25,
			strums.width,
			"25ms", 20);
		msScoreLabel.setFormat(Paths.font("vcr.ttf"), Std.int(30), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msScoreLabel.antialiasing = true;
		msScoreLabel.visible = false;
		msScoreLabel.scale.x = 1;
		msScoreLabel.scale.y = 1;
		msScoreLabel.scrollFactor.set();
        msScoreLabel.color = 0xFF24DEFF;
		msScoreLabel.alpha = 0;

		add(msScoreLabel);

        add(scoreTxt);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        var l = 0.125 * elapsed * 60;
        var h = FlxG.height;

        var showStrums = [1, 2];
        var showScoreLabel = [1, 3];
        var showScore:Array<Int> = [for(i in 3...13) i];
        showScore.insert(0, 0);

        scoreTxt.y = (h * (Settings.engineSettings.data.downscroll ? 0.075 : 0.9)) + 30;
        scoreTxt.x = ((FlxG.width / camHUD.initialZoom) - scoreTxt.width) / 2; 
        scoreTxt.alpha = FlxMath.lerp(scoreTxt.alpha, showScore.contains(curSelected) ? 1 : 0, l);
        scoreTxt.size = Settings.engineSettings.data.scoreTextSize;
        var t = "";
        var accText = ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode];
        if (Settings.engineSettings.data.minimizedMode) {
            accText = accText.charAt(0);
            var e = ["Score: 12345"];
            if (Settings.engineSettings.data.showMisses) e.push("0 Misses");
            if (Settings.engineSettings.data.showAccuracy) e.push("100%" + (Settings.engineSettings.data.showAccuracyMode ? ' ($accText)' : ""));
            if (Settings.engineSettings.data.showAverageDelay) e.push("~ 25ms");
            if (Settings.engineSettings.data.showRating) e.push("S (MFC)");
            t = e.join(Settings.engineSettings.data.scoreJoinString);
        } else {
            var e = ["Score: 12345"];
            if (Settings.engineSettings.data.showMisses) e.push("Misses:0");
            if (Settings.engineSettings.data.showAccuracy) e.push("Accuracy:100%" + (Settings.engineSettings.data.showAccuracyMode ? ' ($accText)' : ""));
            if (Settings.engineSettings.data.showAverageDelay) e.push("Average:25ms");
            if (Settings.engineSettings.data.showRating) e.push("S (MFC)");
            t = e.join(Settings.engineSettings.data.scoreJoinString);
        }
        scoreTxt.text = t;

        if (msScoreLabel.visible != (msScoreLabel.visible = Settings.engineSettings.data.showPressDelay)) {
            if (Settings.engineSettings.data.animateMsLabel) {
                msScoreLabel.offset.y = msScoreLabel.height / 3;
            }
        }
        msScoreLabel.offset.y = FlxMath.lerp(msScoreLabel.offset.y, 0, CoolUtil.wrapFloat(0.25 * 60 * elapsed, 0, 1));


        strums.alpha = FlxMath.lerp(strums.alpha, showStrums.contains(curSelected) ? 1 : 0, l * 2);
        msScoreLabel.alpha = FlxMath.lerp(msScoreLabel.alpha, showScoreLabel.contains(curSelected) ? 1 : 0, l * 2);
        // 13
    }

    public override function onExit() {
        doFlickerAnim(-2, function() {
            FlxG.switchState(new NotesMenu());
        });
    }
}