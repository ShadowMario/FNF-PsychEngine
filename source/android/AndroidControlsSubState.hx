package android;

import android.flixel.FlxButton;
import android.flixel.FlxHitbox;
import android.flixel.FlxVirtualPad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSave;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.input.touch.FlxTouch;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class AndroidControlsSubState extends FlxSubState
{
	var virtualPad:FlxVirtualPad;
	var hitbox:FlxHitbox;
	var upPozition:FlxText;
	var downPozition:FlxText;
	var leftPozition:FlxText;
	var rightPozition:FlxText;
	var inputvari:FlxText;
	var funitext:FlxText;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var controlitems:Array<String> = ['Pad-Right', 'Pad-Left', 'Pad-Custom', 'Pad-Duo', 'Hitbox', 'Keyboard'];
	var curSelected:Int = 0;
	var buttonIsTouched:Bool = false;
	var bindButton:FlxButton;
	var resetButton:FlxButton;

	override function create()
	{
		curSelected = AndroidControls.getMode();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromHSB(FlxG.random.int(0, 359), FlxG.random.float(0, 0.8), FlxG.random.float(0.3, 1)));
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		resetButton = new FlxButton(FlxG.width - 200, 50, "Reset", function()
		{
			if (resetButton.visible)
			{
				virtualPad.buttonUp.x = FlxG.width - 258;
				virtualPad.buttonUp.y = FlxG.height - 408;
				virtualPad.buttonDown.x = FlxG.width - 258;
				virtualPad.buttonDown.y = FlxG.height - 201;
				virtualPad.buttonRight.x = FlxG.width - 132;
				virtualPad.buttonRight.y = FlxG.height - 309;
				virtualPad.buttonLeft.x = FlxG.width - 384;
				virtualPad.buttonLeft.y = FlxG.height - 309;
			}
		});
		resetButton.setGraphicSize(Std.int(resetButton.width) * 3);
		resetButton.label.setFormat(null, 16, 0x333333, "center");
		resetButton.label.color = FlxColor.fromRGB(0, 238, 40);
		resetButton.color = FlxColor.fromRGB(158, 158, 158);
		resetButton.visible = false;
		add(resetButton);

		virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
		virtualPad.visible = false;
		add(virtualPad);

		hitbox = new FlxHitbox();
		hitbox.visible = false;
		add(hitbox);

		inputvari = new FlxText(0, 50, 0, 'No Android Controls!', 32);
		inputvari.setFormat(null, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		inputvari.borderSize = 2.4;
		inputvari.screenCenter();
		inputvari.visible = false;
		add(inputvari);

		inputvari = new FlxText(0, 100, 0, '', 32);
		inputvari.setFormat(null, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		inputvari.borderSize = 2.4;
		inputvari.screenCenter(X);
		add(inputvari);

		leftArrow = new FlxSprite(inputvari.x - 60, inputvari.y - 50);
		leftArrow.frames = FlxAtlasFrames.fromSparrow('assets/android/menu/arrows.png', 'assets/android/menu/arrows.xml');
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', 'arrow push left');
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, inputvari.y - 50);
		rightArrow.frames = FlxAtlasFrames.fromSparrow('assets/android/menu/arrows.png', 'assets/android/menu/arrows.xml');
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', 'arrow push right', 24, false);
		rightArrow.animation.play('idle');
		add(rightArrow);

		upPozition = new FlxText(10, FlxG.height - 104, 0, 'Button Up X:' + virtualPad.buttonUp.x + ' Y:' + virtualPad.buttonUp.y, 16);
		upPozition.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		upPozition.borderSize = 2.4;
		add(upPozition);

		downPozition = new FlxText(10, FlxG.height - 84, 0, 'Button Down X:' + virtualPad.buttonDown.x + ' Y:' + virtualPad.buttonDown.y, 16);
		downPozition.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		downPozition.borderSize = 2.4;
		add(downPozition);

		leftPozition = new FlxText(10, FlxG.height - 64, 0, 'Button Left X:' + virtualPad.buttonLeft.x + ' Y:' + virtualPad.buttonLeft.y, 16);
		leftPozition.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		leftPozition.borderSize = 2.4;
		add(leftPozition);

		rightPozition = new FlxText(10, FlxG.height - 44, 0, 'Button RIght x:' + virtualPad.buttonRight.x + ' Y:' + virtualPad.buttonRight.y, 16);
		rightPozition.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rightPozition.borderSize = 2.4;
		add(rightPozition);

		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press BACK on your phone to get back in options menu', 16);
		tipText.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2.4;
		tipText.scrollFactor.set();
		add(tipText);

		changeSelection();

		super.create();

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.android.justReleased.BACK)
		{
			AndroidControls.setMode(curSelected);

			if (controlitems[Math.floor(curSelected)] == 'Pad-Custom')
				AndroidControls.setCustom(virtualPad);

			flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}

		super.update(elapsed);

		leftArrow.x = inputvari.x - 60;
		rightArrow.x = inputvari.x + inputvari.width + 10;
		inputvari.screenCenter(X);

		for (touch in FlxG.touches.list)
		{
			if (touch.overlaps(leftArrow) && touch.justPressed)
				changeSelection(-1);
			else if (touch.overlaps(rightArrow) && touch.justPressed)
				changeSelection(1);

			var daChoice:String = controlitems[Math.floor(curSelected)];

			if (daChoice == 'Pad-Custom')
			{
				if (buttonIsTouched)
				{
					if (bindButton.justReleased && touch.justReleased)
					{
						buttonIsTouched = false;
						bindButton = null;
					}
					else
					{
						moveButton(touch, bindButton);
						positionsTexts();
					}
				}
				else
				{
					if (virtualPad.buttonUp.justPressed)
						moveButton(touch, virtualPad.buttonUp);

					if (virtualPad.buttonDown.justPressed)
						moveButton(touch, virtualPad.buttonDown);

					if (virtualPad.buttonRight.justPressed)
						moveButton(touch, virtualPad.buttonRight);

					if (virtualPad.buttonLeft.justPressed)
						moveButton(touch, virtualPad.buttonLeft);
				}
			}
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = controlitems.length - 1;
		if (curSelected >= controlitems.length)
			curSelected = 0;

		inputvari.text = controlitems[curSelected];

		var daChoice:String = controlitems[Math.floor(curSelected)];

		switch (daChoice)
		{
			case 'Pad-Right':
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Left':
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Custom':
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				virtualPad = AndroidControls.getCustom(virtualPad);
				add(virtualPad);
			case 'Pad-Duo':
				remove(virtualPad);
				virtualPad = new FlxVirtualPad(BOTH_FULL, NONE);
				add(virtualPad);
			case 'Hitbox':
				virtualPad.visible = false;
			case 'Keyboard':
				remove(virtualPad);
				virtualPad.visible = false;
		}

		if (daChoice == 'Hitbox')
			hitbox.visible = true;
		else
			hitbox.visible = false;

		if (daChoice == 'Keyboard')
			funitext.visible = true;
		else
			funitext.visible = false;

		if (daChoice == 'Pad-Custom')
		{
			resetButton.visible = true;
			upPozition.visible = true;
			downPozition.visible = true;
			leftPozition.visible = true;
			rightPozition.visible = true;
		}
		else
		{
			resetButton.visible = false;
			upPozition.visible = false;
			downPozition.visible = false;
			leftPozition.visible = false;
			rightPozition.visible = false;
		}
	}

	function moveButton(touch:FlxTouch, button:FlxButton):Void
	{
		button.x = touch.x - button.getGraphicMidpoint().x;
		button.y = touch.y - button.getGraphicMidpoint().y;

		bindButton = button;
		buttonIsTouched = true;
	}

	function positionsTexts():Void
	{
		upPozition.text = 'Button Up X:' + virtualPad.buttonUp.x + ' Y:' + virtualPad.buttonUp.y;
		downPozition.text = 'Button Down X:' + virtualPad.buttonDown.x + ' Y:' + virtualPad.buttonDown.y;
		leftPozition.text = 'Button Left X:' + virtualPad.buttonLeft.x + ' Y:' + virtualPad.buttonLeft.y;
		rightPozition.text = 'Button Right x:' + virtualPad.buttonRight.x + ' Y:' + virtualPad.buttonRight.y;
	}
}
