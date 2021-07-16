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
	var bgFade:FlxSprite = null;
	var box:FlxSprite;
	var textToType:String = '';

	var arrayCharacters:Array<FlxSprite> = [];
	var arrayStartX:Array<Float> = [];

	var currentText:Int = 1;
	var offsetPos:Float = 600;

	// This is where you add your characters, ez pz
	function addCharacter(char:FlxSprite, name:String) {
		switch(name) {
			case 'bf':
				char.frames = Paths.getSparrowAtlas('dialogue/BF_Dialogue');
				char.animation.addByPrefix('talkIdle', 'BFTalk', 24, true); //Dialogue ended
				char.animation.addByPrefix('talk', 'bftalkloop', 24, true); //During dialogue

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


	var doFadeOut:Bool = false;
	public function new(?dialogueList:Array<String>, ?song:String = null)
	{
		super();

		if(song != null) {
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
			doFadeOut = true;
		}
		
		bgFade = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		bgFade.scrollFactor.set();
		bgFade.visible = true;
		bgFade.alpha = 0;
		add(bgFade);

		this.dialogueList = dialogueList;
		var splitName:Array<String> = dialogueList[0].split(":");
		spawnCharacters(splitName);

		box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.antialiasing = ClientPrefs.globalAntialiasing;
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

		startNextDialog();
	}

	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	function spawnCharacters(splitName:Array<String>) {
		for (i in 0...arrayCharacters.length) {
			var char:FlxSprite = arrayCharacters[0];
			remove(char);
			arrayCharacters.remove(char);
			arrayStartX.remove(arrayStartX[0]);
		}
		arrayCharacters = [];
		arrayStartX = [];

		for (i in 0...splitName.length) {
			var x:Float = 50;
			var char:FlxSprite = new FlxSprite(50, 180);
			char.x -= offsetPos;
			addCharacter(char, splitName[i]);
			char.setGraphicSize(Std.int(char.width * 0.7));
			char.updateHitbox();
			if(i > 0) {
				x = FlxG.width - char.width - 100;
				char.x = x + offsetPos;
			}
			char.antialiasing = ClientPrefs.globalAntialiasing;
			char.scrollFactor.set();
			char.alpha = 0;
			add(char);
			arrayCharacters.push(char);
			arrayStartX.push(x);
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
					switch(box.animation.curAnim.name) {
						case 'normalOpen' | 'normal':
							box.animation.play('normalOpen', true);
						case 'angryOpen' | 'angry':
							box.animation.play('angryOpen', true);
					}
					box.animation.curAnim.curFrame = box.animation.curAnim.frames.length - 1;
					box.animation.curAnim.reverse();
					remove(daText);
					daText = null;
					updateBoxOffsets();
					if(doFadeOut) FlxG.sound.music.fadeOut(1, 0);
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
				switch(box.animation.curAnim.name) {
					case 'normalOpen':
						box.animation.play('normal', true);
					case 'angryOpen':
						box.animation.play('angry', true);
				}
				updateBoxOffsets();
			}

			if(lastCharacter != -1 && arrayCharacters.length > 0) {
				for (i in 0...arrayCharacters.length) {
					var char = arrayCharacters[i];
					if(char != null) {
						if(i != lastCharacter) {
							if(i == 1) {
								if(char.x < arrayStartX[i] + offsetPos) {
									char.x += scrollSpeed * elapsed;
									if(char.x > arrayStartX[i] + offsetPos) char.x = arrayStartX[i] + offsetPos;
								}
							} else if(char.x > arrayStartX[i] - offsetPos) {
								char.x -= scrollSpeed * elapsed;
								if(char.x < arrayStartX[i] - offsetPos) char.x = arrayStartX[i] - offsetPos;
							}
							char.alpha -= 3 * elapsed;
							if(char.alpha < 0) char.alpha = 0;
						} else {
							if(i == 1) {
								if(char.x > arrayStartX[i]) {
									char.x -= scrollSpeed * elapsed;
									if(char.x < arrayStartX[i]) char.x = arrayStartX[i];
								}
							} else if(char.x < arrayStartX[i]) {
								char.x += scrollSpeed * elapsed;
								if(char.x > arrayStartX[i]) char.x = arrayStartX[i];
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
	var lastBoxType:Int = -1;
	function startNextDialog():Void
	{
		var splitName:Array<String> = dialogueList[currentText].split(":");
		if(splitName.length <= 2) {
			spawnCharacters(splitName);
			lastCharacter = -1;
			lastBoxType = -1;
			for (i in 0...arrayCharacters.length) {
				arrayCharacters[i].visible = true;
			}
			currentText++;
			splitName = dialogueList[currentText].split(":");
		}
		var character:Int = Std.parseInt(splitName[1]);
		var speed:Float = Std.parseFloat(splitName[3]);
		var boxType:Int = Std.parseInt(splitName[4]);
		textToType = splitName[5];
		//FlxG.log.add(textToType);
		box.visible = true;
		if(character != lastCharacter) {
			if(boxType > 0) {
				box.animation.play('angryOpen', true);
			} else {
				box.animation.play('normalOpen', true);
			}
			updateBoxOffsets();
			box.flipX = (character < 1);
		} else if(boxType != lastBoxType) {
			if(boxType > 0) {
				box.animation.play('angry', true);
			} else {
				box.animation.play('normal', true);
			}
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
	}

	function updateBoxOffsets() {
		box.centerOffsets();
		box.updateHitbox();
		if(box.animation.curAnim.name.startsWith('angry')) {
			box.offset.set(50, 70);
		} else {
			box.offset.set(10, 0);
		}
		
		if(!box.flipX) box.offset.y += 10;
	}
}
