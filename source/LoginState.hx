package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxInputText;
import flixel.ui.FlxButton;
import haxe.Json;


using StringTools;

class LoginState extends MusicBeatState
{
    var usernameBox:FlxInputText;
    var passwordBox:FlxInputText;
    var loginButton:FlxButton;
    var camFollow:FlxObject;
    var zoomShit:Bool;
    var errorText:FlxText;
    var errorTimer:FlxTimer = new FlxTimer();

    private function submitCredentials(username:String, password:String)
        {
            var login:Dynamic = ServerConnectionsManager.login(username, password);
            if(login.success)
            {
                errorText.setFormat("VCR OSD Mono", 20, 0xFF03FC07, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF008C02);
                errorTimer.cancel();
                errorText.text = 'Logged in as ' + username;
                errorText.alpha = 1;
                FlxG.mouse.visible = false;
                new FlxTimer().start(1, function (timer:FlxTimer) {
                    FlxG.switchState(new MainMenuState());
                });
            }else
            {
                errorTimer.cancel();
                trace('error xd');
                errorText.text = login.error == null ? "Unknown error" : login.error;
                errorText.alpha = 1;
                errorTimer = new FlxTimer().start(7, function (timer:FlxTimer) {
                    var tempY = errorText.y;
                    FlxTween.tween(errorText, {y: errorText.y * 10, alpha: 0}, 0.4, {ease: FlxEase.quadIn, onComplete: function (tween:FlxTween) {
                        errorText.y = tempY;
                    }});
                });
            }
        }

    override function create()
    {
        FlxG.mouse.visible = true;
        var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
        bg.scrollFactor.set();
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);

        camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

        var logo:FlxSprite = new FlxSprite(FlxG.width * 0.475, FlxG.height * -0.15);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = true;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.scrollFactor.set();
		logo.setGraphicSize(Std.int(logo.width * 0.8));
		logo.updateHitbox();
		add(logo);

        usernameBox = new FlxInputText(-300, -70, 550, "Username", 50, FlxColor.BLACK, FlxColor.WHITE);
        passwordBox = new FlxInputText(-300, usernameBox.y + 100, 550, "", 50, FlxColor.BLACK, FlxColor.WHITE);
        passwordBox.passwordMode = true;
        add(usernameBox);
        add(passwordBox);

        loginButton = new FlxButton(FlxG.width / 2 - 200, (passwordBox.y + 150) * 3, "Login", () -> submitCredentials(usernameBox.text, passwordBox.text));
        loginButton.setGraphicSize(70);
        loginButton.updateHitbox();
        //loginButton.loadGraphic(Paths.image("buttons/loginButton", "shared"));
        loginButton.label.setFormat("VCR OSD Mono", 70, FlxColor.BLACK);
        //loginButton.label.y += 100;
        add(loginButton);

        var registerButton:FlxButton = new FlxButton(FlxG.width / 2 + 300, (passwordBox.y + 150) * 3, "Register", () -> LoadingState.loadAndSwitchState(new RegisterState()));
        registerButton.setGraphicSize(30);
        registerButton.updateHitbox();
        //registerButton.loadGraphic(Paths.image("buttons/loginButton", "shared"));
        registerButton.label.setFormat("VCR OSD Mono", 30, FlxColor.BLACK);
        //registerButton.label.y += 100;
        add(registerButton);

        errorText = new FlxText(loginButton.x, loginButton.y - 40, 0, "error bruh", 17);
        errorText.setFormat("VCR OSD Mono", 20, 0xFFC0303, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF8A0000);
        errorText.scrollFactor.set();
        errorText.alpha = 0;
        add(errorText);

        FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

        super.create();
		Conductor.changeBPM(102);
    }
    override function update(elapsed:Float)
    {
        #if debug
        if(FlxG.keys.justPressed.SIX)
        {
            zoomShit = !zoomShit;
            if(zoomShit)
                {
                    FlxTween.tween(FlxG.camera, { zoom: 0.17 }, 0.5,{ ease: FlxEase.quadInOut });
                }else{
                    FlxTween.tween(FlxG.camera, { zoom: 1 }, 0.5,{ ease: FlxEase.quadInOut });
                }
        }
        #end
        if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.switchState(new MainMenuState());
			}

        if(FlxG.keys.justPressed.ENTER)
        {
            submitCredentials(usernameBox.text, passwordBox.text);
        }

        super.update(elapsed);
    }
}