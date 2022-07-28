package android;

import android.flixel.FlxButton;
import android.flixel.FlxHitbox;
import android.flixel.FlxVirtualPad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSave;
import flixel.util.FlxColor;
import flixel.input.touch.FlxTouch;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;

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
	var curSelected:Int = 0;
	var buttonBinded:Bool = false;
	var bindButton:FlxButton;
	var resetButton:FlxButton;
	final controlsItems:Array<String> = ['Pad-Right', 'Pad-Left', 'Pad-Custom', 'Pad-Duo', 'Hitbox', 'Keyboard'];

	override function create()
	{
		curSelected = AndroidControls.getMode();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
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
		resetButton.label.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER);
		resetButton.color = FlxColor.RED;
		resetButton.visible = false;
		add(resetButton);

		virtualPad = new FlxVirtualPad(NONE, NONE);
		virtualPad.visible = false;
		add(virtualPad);

		hitbox = new FlxHitbox();
		hitbox.visible = false;
		add(hitbox);

		funitext = new FlxText(0, 50, 0, 'No Android Controls!', 32);
		funitext.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funitext.borderSize = 2.4;
		funitext.screenCenter();
		funitext.visible = false;
		add(funitext);

		inputvari = new FlxText(0, 100, 0, '', 32);
		inputvari.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		inputvari.borderSize = 2.4;
		inputvari.screenCenter(X);
		add(inputvari);

		leftArrow = new FlxSprite(inputvari.x - 60, inputvari.y - 25);
		leftArrow.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/android/menu/arrows.png'),
			Assets.getText('assets/android/menu/arrows.xml'));
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, inputvari.y - 25);
		rightArrow.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/android/menu/arrows.png'),
			Assets.getText('assets/android/menu/arrows.xml'));
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.play('idle');
		add(rightArrow);

		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press BACK on your phone to get back to the options menu', 16);
		tipText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2.4;
		tipText.scrollFactor.set();
		add(tipText);

		rightPozition = new FlxText(10, FlxG.height - 44, 0, '', 16);
		rightPozition.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rightPozition.borderSize = 2.4;
		add(rightPozition);

		leftPozition = new FlxText(10, FlxG.height - 64, 0, '', 16);
		leftPozition.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		leftPozition.borderSize = 2.4;
		add(leftPozition);

		downPozition = new FlxText(10, FlxG.height - 84, 0, '', 16);
		downPozition.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		downPozition.borderSize = 2.4;
		add(downPozition);

		upPozition = new FlxText(10, FlxG.height - 104, 0, '', 16);
		upPozition.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		upPozition.borderSize = 2.4;
		add(upPozition);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.android.justPressed.BACK || FlxG.android.justReleased.BACK)
		{
			AndroidControls.setMode(curSelected);

			if (controlsItems[Math.floor(curSelected)] == 'Pad-Custom')
				AndroidControls.setCustomMode(virtualPad);

			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}

		super.update(elapsed);

		inputvari.screenCenter(X);
		leftArrow.x = inputvari.x - 60;
		rightArrow.x = inputvari.x + inputvari.width + 10;

		for (touch in FlxG.touches.list)
		{
			if (touch.overlaps(leftArrow) && touch.justPressed)
				changeSelection(-1);
			else if (touch.overlaps(rightArrow) && touch.justPressed)
				changeSelection(1);

			if (controlsItems[Math.floor(curSelected)] == 'Pad-Custom')
			{
				if (buttonBinded)
				{
					if (touch.justReleased)
					{
						bindButton = null;
						buttonBinded = false;
					}
					else
						moveButton(touch, bindButton);
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

		if (virtualPad != null)
		{
			if (virtualPad.buttonUp != null)
				upPozition.text = 'Button Up X:' + virtualPad.buttonUp.x + ' Y:' + virtualPad.buttonUp.y;

			if (virtualPad.buttonDown != null)
				downPozition.text = 'Button Down X:' + virtualPad.buttonDown.x + ' Y:' + virtualPad.buttonDown.y;

			if (virtualPad.buttonLeft != null)
				leftPozition.text = 'Button Left X:' + virtualPad.buttonLeft.x + ' Y:' + virtualPad.buttonLeft.y;

			if (virtualPad.buttonRight != null)
				rightPozition.text = 'Button Right x:' + virtualPad.buttonRight.x + ' Y:' + virtualPad.buttonRight.y;
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = controlsItems.length - 1;
		if (curSelected >= controlsItems.length)
			curSelected = 0;

		inputvari.text = controlsItems[curSelected];

		var daChoice:String = controlsItems[Math.floor(curSelected)];

		switch (daChoice)
		{
			case 'Pad-Right':
				hitbox.visible = false;
				virtualPad.destroy();
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Left':
				hitbox.visible = false;
				virtualPad.destroy();
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case 'Pad-Custom':
				hitbox.visible = false;
				virtualPad.destroy();
				virtualPad = AndroidControls.getCustomMode(new FlxVirtualPad(RIGHT_FULL, NONE));
				add(virtualPad);
			case 'Pad-Duo':
				hitbox.visible = false;
				virtualPad.destroy();
				virtualPad = new FlxVirtualPad(BOTH_FULL, NONE);
				add(virtualPad);
			case 'Hitbox':
				hitbox.visible = true;
				virtualPad.visible = false;
			case 'Keyboard':
				hitbox.visible = false;
				virtualPad.visible = false;
		}

		funitext.visible = daChoice == 'Keyboard';
		resetButton.visible = daChoice == 'Pad-Custom';
		upPozition.visible = daChoice == 'Pad-Custom';
		downPozition.visible = daChoice == 'Pad-Custom';
		leftPozition.visible = daChoice == 'Pad-Custom';
		rightPozition.visible = daChoice == 'Pad-Custom';
	}

	function moveButton(touch:FlxTouch, button:FlxButton):Void
	{
		bindButton = button;

		bindButton.x = touch.x - Std.int(bindButton.width / 2);
		bindButton.y = touch.y - Std.int(bindButton.height / 2);

		buttonBinded = true;
	}
}
