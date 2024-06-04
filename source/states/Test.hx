package states;

import flixel.addons.ui.*;
import backend.ui.*;
import backend.ui.PsychUIEventHandler.PsychUIEvent;

class Test extends MusicBeatState implements PsychUIEvent
{
	var UI_box:PsychUIBox;
	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		bg.color = FlxColor.GRAY;
		add(bg);

		UI_box = new PsychUIBox(FlxG.width - 275, 25, 250, 120, ['Ghost', 'Settings']);
		UI_box.scrollFactor.set();
		add(UI_box);

		var radiogrp:PsychUIRadioGroup = new PsychUIRadioGroup(100, 100, ['Test', 'Other', 'Another', 'And other', 'Yup, other', 'Over limit', 'Right?'], 25, 5);
		radiogrp.scrollFactor.set();
		add(radiogrp);

		addGhostTab();
		addSettingsTab();

		super.create();
	}

	function addGhostTab()
	{
		var tab_group = UI_box.getTab('Ghost').menu;

		//var hideGhostButton:FlxButton = null;
		var makeGhostButton:PsychUIButton = new PsychUIButton(25, 15, "Make Ghost", function() {
			trace('Pressed "Make Ghost" button');
		});

		/*hideGhostButton = new FlxButton(20 + makeGhostButton.width, makeGhostButton.y, "Hide Ghost", function() {
			ghost.visible = false;
			hideGhostButton.active = false;
			hideGhostButton.alpha = 0.6;
		});
		hideGhostButton.active = false;
		hideGhostButton.alpha = 0.6;*/

		var highlightGhost:PsychUICheckBox = new PsychUICheckBox(20 + makeGhostButton.x + makeGhostButton.width, makeGhostButton.y, "Highlight Ghost", 100);
		highlightGhost.onClick = function()
		{
			trace('Pressed Highlight Ghost checkbox');
		};

		var ghostAlphaSlider:PsychUISlider = new PsychUISlider(10, makeGhostButton.y + 25, function(v:Float) {
			trace('value set to: $v');
		}, 0.6, 0, 1, 210);
		//ghostAlphaSlider.label = 'Opacity:';
		ghostAlphaSlider.decimals = 2;

		/*var ghostAlphaSlider:FlxUISlider = new FlxUISlider(this, 'ghostAlpha', 10, makeGhostButton.y + 25, 0, 1, 210, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		ghostAlphaSlider.nameLabel.text = 'Opacity:';
		ghostAlphaSlider.decimals = 2;
		ghostAlphaSlider.callback = function(relativePos:Float) {
			ghost.alpha = ghostAlpha;
			if(animateGhost != null) animateGhost.alpha = ghostAlpha;
		};
		ghostAlphaSlider.value = ghostAlpha;*/
		
		/*var inputText:PsychUIInputText = new PsychUIInputText(110, 40, 100, 'Test', 8);
		tab_group.add(inputText);*/

		//var ghostAlphaStepper:PsychUINumericStepper = new PsychUINumericStepper(20, 40, 0.05, 0, -10, 10, 2);

		tab_group.add(makeGhostButton);
		//tab_group.add(hideGhostButton);
		tab_group.add(highlightGhost);
		//tab_group.add(ghostAlphaStepper);
		tab_group.add(ghostAlphaSlider);
	}

	function addSettingsTab()
	{
		var tab_group = UI_box.getTab('Settings').menu;
		
		var reloadCharacter:PsychUIButton = new PsychUIButton(140, 20, "Reload Char", function()
		{
			trace('Pressed Reload Char');
		});
		tab_group.add(reloadCharacter);
		
		var templateCharacter:PsychUIButton = new PsychUIButton(140, 50, "Load Template", function()
		{
			trace('Pressed Template button');
		});
		templateCharacter.normalStyle.bgColor = FlxColor.RED;
		templateCharacter.normalStyle.textColor = FlxColor.WHITE;
		tab_group.add(templateCharacter);

		var check:PsychUICheckBox = new PsychUICheckBox(10, 60, "Playable Character", 100);
		check.checked = true;
		check.onClick = function()
		{
			trace('Pressed checkbox! ' + check.checked);
		};
		tab_group.add(check);

		var charDropDown:PsychUIDropDownMenu = new PsychUIDropDownMenu(10, 30, ['test', 'test2', '2test2', 'gaytest', 'gaytestgay', 'testgaygay', 'testgay'], function(index:Int, selected:String)
		{
			trace('selected $index: $selected');
		});
		tab_group.add(charDropDown);
	}

	public function UIEvent(id:String, sender:Dynamic)
	{
		trace(id, sender);
	}
}