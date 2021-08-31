package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSubState;

using StringTools;

// TO DO: Clean code? Maybe? idk
class DialogueBoxPsych extends FlxSpriteGroup
{
	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	var bgFade:FlxSprite = null;
	var box:FlxSprite;
	var textToType:String = '';

	var arrayCharacters:Array<FlxSprite> = [];
	var arrayStartPos:Array<Float> = []; //For 'center', it works as the starting Y, for everything else it works as starting X
	var arrayPosition:Array<Int> = [];

	var currentText:Int = 1;
	var offsetPos:Float = -600;

	var textBoxTypes:Array<String> = ['normal', 'angry'];
	var charPositionList:Array<String> = ['left', 'center', 'right'];

	// This is where you add your characters, ez pz
	function addCharacter(char:FlxSprite, name:String) {
		switch(name) {
			case 'bf':
				char.frames = Paths.getSparrowAtlas('dialogue/BF_Dialogue');
				char.animation.addByPrefix('talkIdle', 'BFTalk', 24, true); //Dialogue ended
				char.animation.addByPrefix('talk', 'bftalkloop', 24, true); //During dialogue
				char.flipX = !char.flipX;

			case 'psychic':
				char.frames = Paths.getSparrowAtlas('dialogue/Psy_Dialogue'); //oppa gangnam style xddddd kill me
				char.animation.addByPrefix('talkIdle', 'PSYtalk', 24, true);
				char.animation.addByPrefix('talk', 'PSY loop', 24, true);
				char.animation.addByPrefix('angryIdle', 'PSY angry', 24, true);
				char.animation.addByPrefix('angry', 'PSY ANGRY loop', 24, true);
				char.animation.addByPrefix('unamusedIdle', 'PSY unamused', 24, true);
				char.animation.addByPrefix('unamused', 'PSY UNAMUSED loop', 24, true);
				char.y -= 140;
		}
		char.animation.play('talkIdle', true);
	}



	public function new(?dialogueList:Array<String>, song:String)
	{
		super();

		if(song != null && song != '') {
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		
		bgFade = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		bgFade.scrollFactor.set();
		bgFade.visible = true;
		bgFade.alpha = 0;
		add(bgFade);

		this.dialogueList = dialogueList;
		spawnCharacters(dialogueList[0].split(" "));

		box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.antialiasing = ClientPrefs.globalAntialiasing;
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.animation.addByPrefix('center-normal', 'speech bubble middle', 24);
		box.animation.addByPrefix('center-normalOpen', 'Speech Bubble Middle Open', 24, false);
		box.animation.addByPrefix('center-angry', 'AHH Speech Bubble middle', 24);
		box.animation.addByPrefix('center-angryOpen', 'speech bubble Middle loud open', 24, false);
		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

		startNextDialog();
	}

	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	function spawnCharacters(splitSpace:Array<String>) {
		for (i in 0...splitSpace.length) {
			var splitName:Array<String> = splitSpace[i].split(":");
			var y:Float = 180;
			var x:Float = 50;
			var char:FlxSprite = new FlxSprite(x, y);
			char.x += offsetPos;
			addCharacter(char, splitName[0]);

			char.setGraphicSize(Std.int(char.width * 0.7));
			char.updateHitbox();
			char.antialiasing = ClientPrefs.globalAntialiasing;
			char.scrollFactor.set();
			char.alpha = 0;
			add(char);

			var saveY:Bool = false;
			var pos:Int = 0;
			switch(splitName[1]) {
				case 'center':
					pos = 1;
					char.x = FlxG.width / 2;
					char.x -= char.width / 2;
					y = char.y;
					char.y = FlxG.height + 50;
					saveY = true;
				case 'right':
					pos = 2;
					char.flipX = !char.flipX;
					x = FlxG.width - char.width - 100;
					char.x = x - offsetPos;
			}
			arrayCharacters.push(char);
			arrayStartPos.push(saveY ? y : x);
			arrayPosition.push(pos);
		}
	}

	var textX = 90;
	var textY = 430;
	var scrollSpeed = 4500;
	var daText:Alphabet = null;
	override function update(elapsed:Float)
	{
		if(!dialogueEnded) {
			bgFade.alpha += 0.5 * elapsed;
			if(bgFade.alpha > 0.5) bgFade.alpha = 0.5;

			if(FlxG.keys.justPressed.ANY) {
				if(!daText.finishedText) {
					if(daText != null) {
						daText.killTheTimer();
						remove(daText);
					}
					daText = new Alphabet(0, 0, textToType, false, true, 0.0, 0.7);
					daText.x = textX;
					daText.y = textY;
					add(daText);
				} else if(currentText >= dialogueList.length) {
					dialogueEnded = true;
					for (i in 0...textBoxTypes.length) {
						var checkArray:Array<String> = ['', 'center-'];
						var animName:String = box.animation.curAnim.name;
						for (j in 0...checkArray.length) {
							if(animName == checkArray[j] + textBoxTypes[i] || animName == checkArray[j] + textBoxTypes[i] + 'Open') {
								box.animation.play(checkArray[j] + textBoxTypes[i] + 'Open', true);
							}
						}
					}

					box.animation.curAnim.curFrame = box.animation.curAnim.frames.length - 1;
					box.animation.curAnim.reverse();
					remove(daText);
					daText = null;
					updateBoxOffsets();
					FlxG.sound.music.fadeOut(1, 0);
				} else {
					startNextDialog();
				}
				FlxG.sound.play(Paths.sound('dialogueClose'));
			} else if(daText.finishedText) {
				var char:FlxSprite = arrayCharacters[lastCharacter];
				if(char != null && !char.animation.curAnim.name.endsWith('Idle') && char.animation.curAnim.curFrame >= char.animation.curAnim.frames.length - 1) {
					char.animation.play(char.animation.curAnim.name + 'Idle');
				}
			}

			if(box.animation.curAnim.finished) {
				for (i in 0...textBoxTypes.length) {
					var checkArray:Array<String> = ['', 'center-'];
					var animName:String = box.animation.curAnim.name;
					for (j in 0...checkArray.length) {
						if(animName == checkArray[j] + textBoxTypes[i] || animName == checkArray[j] + textBoxTypes[i] + 'Open') {
							box.animation.play(checkArray[j] + textBoxTypes[i], true);
						}
					}
				}
				updateBoxOffsets();
			}

			if(lastCharacter != -1 && arrayCharacters.length > 0) {
				for (i in 0...arrayCharacters.length) {
					var char = arrayCharacters[i];
					if(char != null) {
						if(i != lastCharacter) {
							switch(charPositionList[arrayPosition[i]]) {
								case 'left':
									char.x -= scrollSpeed * elapsed;
									if(char.x < arrayStartPos[i] + offsetPos) char.x = arrayStartPos[i] + offsetPos;
								case 'center':
									char.y += scrollSpeed * elapsed;
									if(char.y > FlxG.height + 50) char.y = FlxG.height + 50;
								case 'right':
									char.x += scrollSpeed * elapsed;
									if(char.x > arrayStartPos[i] - offsetPos) char.x = arrayStartPos[i] - offsetPos;
							}
							char.alpha -= 3 * elapsed;
							if(char.alpha < 0) char.alpha = 0;
						} else {
							switch(charPositionList[arrayPosition[i]]) {
								case 'left':
									char.x += scrollSpeed * elapsed;
									if(char.x > arrayStartPos[i]) char.x = arrayStartPos[i];
								case 'center':
									char.y -= scrollSpeed * elapsed;
									if(char.y < arrayStartPos[i]) char.y = arrayStartPos[i];
								case 'right':
									char.x -= scrollSpeed * elapsed;
									if(char.x < arrayStartPos[i]) char.x = arrayStartPos[i];
							}
							char.alpha += 3 * elapsed;
							if(char.alpha > 1) char.alpha = 1;
						}
					}
				}
			}
		} else { //Dialogue ending
			if(box != null && box.animation.curAnim.curFrame <= 0) {
				remove(box);
				box = null;
			}

			if(bgFade != null) {
				bgFade.alpha -= 0.5 * elapsed;
				if(bgFade.alpha <= 0) {
					remove(bgFade);
					bgFade = null;
				}
			}

			for (i in 0...arrayCharacters.length) {
				var leChar:FlxSprite = arrayCharacters[i];
				if(leChar != null) {
					leChar.x += scrollSpeed * (i == 1 ? 1 : -1) * elapsed;
					leChar.alpha -= elapsed * 10;
				}
			}

			if(box == null && bgFade == null) {
				for (i in 0...arrayCharacters.length) {
					var leChar:FlxSprite = arrayCharacters[0];
					if(leChar != null) {
						arrayCharacters.remove(leChar);
						remove(leChar);
					}
				}
				finishThing();
				kill();
			}
		}
		super.update(elapsed);
	}

	var lastCharacter:Int = -1;
	var lastBoxType:String = '';
	function startNextDialog():Void
	{
		var splitName:Array<String> = dialogueList[currentText].split(":");
		var character:Int = Std.parseInt(splitName[1]);
		var speed:Float = Std.parseFloat(splitName[3]);

		var animName:String = splitName[4];
		var boxType:String = textBoxTypes[0];
		for (i in 0...textBoxTypes.length) {
			if(textBoxTypes[i] == animName) {
				boxType = animName;
			}
		}

		textToType = splitName[5];
		//FlxG.log.add(textToType);
		box.visible = true;

		var centerPrefix:String = '';
		if(charPositionList[arrayPosition[character]] == 'center') centerPrefix = 'center-';

		if(character != lastCharacter) {
			box.animation.play(centerPrefix + boxType + 'Open', true);
			updateBoxOffsets();
			box.flipX = (charPositionList[arrayPosition[character]] == 'left');
		} else if(boxType != lastBoxType) {
			box.animation.play(centerPrefix + boxType, true);
			updateBoxOffsets();
		}
		lastCharacter = character;
		lastBoxType = boxType;

		if(daText != null) {
			daText.killTheTimer();
			remove(daText);
		}
		daText = new Alphabet(textX, textY, textToType, false, true, speed, 0.7);
		add(daText);

		var char:FlxSprite = arrayCharacters[character];
		if(char != null) {
			char.animation.play(splitName[2], true);
			var rate:Float = 24 - (((speed - 0.05) / 5) * 480);
			if(rate < 12) rate = 12;
			else if(rate > 48) rate = 48;
			char.animation.curAnim.frameRate = rate;
		}
		currentText++;

		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function updateBoxOffsets() {
		box.centerOffsets();
		box.updateHitbox();
		if(box.animation.curAnim.name.startsWith('angry')) {
			box.offset.set(50, 65);
		} else if(box.animation.curAnim.name.startsWith('center-angry')) {
			box.offset.set(50, 30);
		} else {
			box.offset.set(10, 0);
		}
		
		if(!box.flipX) box.offset.y += 10;
	}
}
