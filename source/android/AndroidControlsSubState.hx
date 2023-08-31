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

class AndroidControlsSubState extends FlxSubState {
	final controlsItems:Array<String> = ['Pad-Right', 'Pad-Left', 'Pad-Custom', 'Pad-Duo', 'Hitbox', 'Keyboard'];
	var virtualPad:FlxVirtualPad;
	var hitbox:FlxHitbox;
	var upPosition:FlxText;
	var downPosition:FlxText;
	var leftPosition:FlxText;
	var rightPosition:FlxText;
	var inputText:FlxText;
	var noAndroidControlsText:FlxText;
	var tipText:FlxText;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var currentlySelected:Int = AndroidControls.getMode();
	var buttonBinded:Bool = false;
	var bindButton:FlxButton;
	var resetButton:FlxButton;
	var background:FlxSprite;
	var velocityBG:FlxBackdrop;

	override function create() {
		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromHSB(FlxG.random.int(0, 359), FlxG.random.float(0, 0.8), FlxG.random.float(0.3, 1)));
		background.alpha = 0.00001;
		background.scrollFactor.set();
		add(background);

		resetButton = new FlxButton(FlxG.width - 200, 50, 'Reset', function() {
			if (resetButton.visible) {
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
		resetButton.label.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, CENTER);
		resetButton.color = FlxColor.RED;
		resetButton.visible = false;
		add(resetButton);

		virtualPad = new FlxVirtualPad(NONE, NONE);
		virtualPad.visible = false;
		add(virtualPad);

		hitbox = new FlxHitbox();
		hitbox.visible = false;
		add(hitbox);

		noAndroidControlsText = new FlxText(0, 50, 0, 'You dont have any Android Controls!', 32);
		noAndroidControlsText.setFormat('VCR OSD Mono', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noAndroidControlsText.borderSize = 2.4;
		noAndroidControlsText.screenCenter();
		noAndroidControlsText.visible = false;
		add(noAndroidControlsText);

		inputText = new FlxText(0, 100, 0, '', 32);
		inputText.setFormat('VCR OSD Mono', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		inputText.borderSize = 2.4;
		inputText.screenCenter(X);
		add(inputText);

		leftArrow = new FlxSprite(inputText.x - 60, inputText.y - 25);
		leftArrow.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/android/menu/arrows.png'),
			Assets.getText('assets/android/menu/arrows.xml'));
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(inputText.x + inputText.width + 10, inputText.y - 25);
		rightArrow.frames = FlxAtlasFrames.fromSparrow(Assets.getBitmapData('assets/android/menu/arrows.png'),
			Assets.getText('assets/android/menu/arrows.xml'));
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.play('idle');
		add(rightArrow);

		tipText = new FlxText(10, FlxG.height - 24, 0, 'Press BACK on your phone to get back to the options menu', 16);
		tipText.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 1.25;
		tipText.scrollFactor.set();
		add(tipText);

		rightPosition = new FlxText(10, FlxG.height - 44, 0, '', 16);
		rightPosition.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rightPosition.borderSize = 2.4;
		add(rightPosition);

		leftPosition = new FlxText(10, FlxG.height - 64, 0, '', 16);
		leftPosition.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		leftPosition.borderSize = 2.4;
		add(leftPosition);

		downPosition = new FlxText(10, FlxG.height - 84, 0, '', 16);
		downPosition.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		downPosition.borderSize = 2.4;
		add(downPosition);

		upPosition = new FlxText(10, FlxG.height - 104, 0, '', 16);
		upPosition.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		upPosition.borderSize = 2.4;
		add(upPosition);

		changeSelection();

		super.create();

		FlxTween.tween(background, {alpha: 0.6}, 1, {ease: FlxEase.circInOut});
	}

	override function update(elapsed:Float) {
		if (FlxG.android.justPressed.BACK || FlxG.android.justReleased.BACK) {
			AndroidControls.setMode(currentlySelected);

			if (controlsItems[Math.floor(currentlySelected)] == 'Pad-Custom')
				AndroidControls.setCustomMode(virtualPad);

			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}

		super.update(elapsed);

		inputText.screenCenter(X);
		leftArrow.x = inputText.x - 60;
		rightArrow.x = inputText.x + inputText.width + 10;

		for (touch in FlxG.touches.list) {
			if (touch.overlaps(leftArrow) && touch.justPressed)
				changeSelection(-1);
			else if (touch.overlaps(rightArrow) && touch.justPressed)
				changeSelection(1);

			if (controlsItems[Math.floor(currentlySelected)] == 'Pad-Custom') {
				if (buttonBinded) {
					if (touch.justReleased) {
						bindButton = null;
						buttonBinded = false;
					} else
						moveButton(touch, bindButton);
				} else {
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

		if (virtualPad != null) {
			if (virtualPad.buttonUp != null)
				upPosition.text = 'Button Up X:' + virtualPad.buttonUp.x + ' Y:' + virtualPad.buttonUp.y;

			if (virtualPad.buttonDown != null)
				downPosition.text = 'Button Down X:' + virtualPad.buttonDown.x + ' Y:' + virtualPad.buttonDown.y;

			if (virtualPad.buttonLeft != null)
				leftPosition.text = 'Button Left X:' + virtualPad.buttonLeft.x + ' Y:' + virtualPad.buttonLeft.y;

			if (virtualPad.buttonRight != null)
				rightPosition.text = 'Button Right x:' + virtualPad.buttonRight.x + ' Y:' + virtualPad.buttonRight.y;
		}
	}

	function changeSelection(change:Int = 0):Void {
		currentlySelected += change;

		if (currentlySelected < 0)
			currentlySelected = controlsItems.length - 1;
		if (currentlySelected >= controlsItems.length)
			currentlySelected = 0;

		inputText.text = controlsItems[currentlySelected];

		var daChoice:String = controlsItems[Math.floor(currentlySelected)];

		switch (daChoice) {
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

		noAndroidControlsText.visible = daChoice == 'Keyboard';
		resetButton.visible = daChoice == 'Pad-Custom';
		upPosition.visible = daChoice == 'Pad-Custom';
		downPosition.visible = daChoice == 'Pad-Custom';
		leftPosition.visible = daChoice == 'Pad-Custom';
		rightPosition.visible = daChoice == 'Pad-Custom';
	}

	function moveButton(touch:FlxTouch, button:FlxButton):Void {
		bindButton = button;
		bindButton.x = touch.x - Std.int(bindButton.width / 2);
		bindButton.y = touch.y - Std.int(bindButton.height / 2);
		buttonBinded = true;
	}
}