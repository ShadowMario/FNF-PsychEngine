package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;

	private var player:Int;

	public static var colorFromData:Array<Array<Int>> = [
		[0,1,2,3],
		[0,2,3,5,1,6],
		[0,1,2,3,4,5,6,7,8],
		[0,1,4,2,3],
		[0,2,3,4,5,1,6],
		[0,1,2,3,5,6,7,8],
		[4],
		[0,3],
		[0,4,3]
	];

	public static var maniaSwitchPositions:Array<Dynamic> = [
        [0, 1, 2, 3, "alpha0", "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, 4, 1, 2, "alpha0", 3, "alpha0", "alpha0", 5],
        [0, 1, 2, 3, 4, 5, 6, 7, 8],
        [0, 1, 3, 4, 2, "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, 5, 1, 2, 3, 4, "alpha0", "alpha0", 6],
        [0, 1, 2, 3, "alpha0", 4, 5, 6, 7],
        ["alpha0", "alpha0", "alpha0", "alpha0", 0, "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, "alpha0", "alpha0", 1, "alpha0", "alpha0", "alpha0", "alpha0", "alpha0"],
        [0, "alpha0", "alpha0", 2, 1, "alpha0", "alpha0", "alpha0", "alpha0"]
    ];

	public var defaultWidth:Float;
	public var defaultY:Float;
	public var defaultX:Float;

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + skin));
			width = width / 9;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + skin), true, Math.floor(width), Math.floor(height));
			animation.add('green', [11]);
			animation.add('red', [12]);
			animation.add('blue', [10]);
			animation.add('purplel', [9]);

			animation.add('white', [13]);
			animation.add('yellow', [14]);
			animation.add('violet', [15]);
			animation.add('black', [16]);
			animation.add('darkred', [16]);
			animation.add('orange', [16]);
			animation.add('dark', [17]);

			var numstatic:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8]; //this is most tedious shit ive ever done why the fuck is this so hard
			var startpress:Array<Int> = [9, 10, 11, 12, 13, 14, 15, 16, 17];
			var endpress:Array<Int> = [18, 19, 20, 21, 22, 23, 24, 25, 26];
			var startconf:Array<Int> = [27, 28, 29, 30, 31, 32, 33, 34, 35];
			var endconf:Array<Int> = [36, 37, 38, 39, 40, 41, 42, 43, 44];                    
			switch (Note.mania)
			{
				case 1:
					numstatic = [0, 2, 3, 5, 1, 8];
					startpress = [9, 11, 12, 14, 10, 17];
					endpress = [18, 20, 21, 23, 19, 26];
					startconf = [27, 29, 30, 32, 28, 35];
					endconf = [36, 38, 39, 41, 37, 44];
				case 3: 
					numstatic = [0, 1, 4, 2, 3];
					startpress = [9, 10, 13, 11, 12];
					endpress = [18, 19, 22, 20, 21];
					startconf = [27, 28, 31, 29, 30];
					endconf = [36, 37, 40, 38, 39];
				case 4: 
					numstatic = [0, 2, 3, 4, 5, 1, 8];
					startpress = [9, 11, 12, 13, 14, 10, 17];
					endpress = [18, 20, 21, 22, 23, 19, 26];
					startconf = [27, 29, 30, 31, 32, 28, 35];
					endconf = [36, 38, 39, 40, 41, 37, 44];
				case 5: 
					numstatic = [0, 1, 2, 3, 5, 6, 7, 8];
					startpress = [9, 10, 11, 12, 14, 15, 16, 17];
					endpress = [18, 19, 20, 21, 23, 24, 25, 26];
					startconf = [27, 28, 29, 30, 32, 33, 34, 35];
					endconf = [36, 37, 38, 39, 41, 42, 43, 44];
				case 6: 
					numstatic = [4];
					startpress = [13];
					endpress = [22];
					startconf = [31];
					endconf = [40];
				case 7: 
					numstatic = [0, 3];
					startpress = [9, 12];
					endpress = [18, 21];
					startconf = [27, 30];
					endconf = [36, 39];
				case 8: 
					numstatic = [0, 4, 3];
					startpress = [9, 13, 12];
					endpress = [18, 22, 21];
					startconf = [27, 31, 30];
					endconf = [36, 40, 39];
			}
			defaultWidth = width;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelnoteScale));
			updateHitbox();
			antialiasing = false;
			animation.add('static', [numstatic[leData]]);
			animation.add('pressed', [startpress[leData], endpress[leData]], 12, false);
			animation.add('confirm', [startconf[leData], endconf[leData]], 24, false);

		}
		else
		{
			frames = Paths.getSparrowAtlas(skin);

			var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			var pPre:Array<String> = ['purple', 'blue', 'green', 'red'];
			switch (Note.mania)
			{
				case 1:
					nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
					pPre = ['purple', 'green', 'red', 'yellow', 'blue', 'dark'];

				case 2:
					nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					pPre = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
				case 3: 
					nSuf = ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'];
					pPre = ['purple', 'blue', 'white', 'green', 'red'];
				case 4: 
					nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
					pPre = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
				case 5: 
					nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					pPre = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'];
				case 6: 
					nSuf = ['SPACE'];
					pPre = ['white'];
				case 7: 
					nSuf = ['LEFT', 'RIGHT'];
					pPre = ['purple', 'red'];
				case 8: 
					nSuf = ['LEFT', 'SPACE', 'RIGHT'];
					pPre = ['purple', 'white', 'red'];
			}

			antialiasing = ClientPrefs.globalAntialiasing;
			defaultWidth = width;
			setGraphicSize(Std.int(width * Note.noteScale));

			animation.addByPrefix('static', 'arrow' + nSuf[leData]);
			animation.addByPrefix('pressed', pPre[leData] + ' press', 24, false);
			animation.addByPrefix('confirm', pPre[leData] + ' confirm', 24, false);
		}

		updateHitbox();
		scrollFactor.set();
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		x -= Note.posRest[Note.mania];
		ID = noteData;
		defaultX = this.x;
		defaultY = this.y;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		
		/*if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
			updateConfirmOffset();
		}*/

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		var colornum:Int = colorFromData[Note.mania][noteData % Note.keyAmmo[Note.mania]];
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[colornum][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[colornum][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[colornum][2] / 100;

			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				updateConfirmOffset();
			}
		}
	}

	function updateConfirmOffset() { //TO DO: Find a calc to make the offset work fine on other angles
		centerOffsets();
		var yoffset:Float = 13;
		var xoffset:Float = 13;

		var scaleToCheck = Note.noteScale;
		switch (player)
		{
			case 0: 
				scaleToCheck = Note.p2NoteScale;
			case 1: 
				scaleToCheck = Note.p1NoteScale;
		}
		xoffset = (xoffset * 0.7) / (scaleToCheck); //calculates offset based on notescale 
		yoffset = (yoffset * 0.7) / (scaleToCheck);
		offset.x -= xoffset;
		offset.y -= yoffset;
	}
	public function moveKeyPositions(spr:FlxSprite, newMania:Int, playe:Int):Void 
	{
		spr.x = ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X;
		
		spr.alpha = 1;
		
		if (maniaSwitchPositions[newMania][spr.ID] == "alpha0")
		{
			spr.alpha = 0;
		}            
		else
		{
			spr.x += Note.noteWidths[newMania] * maniaSwitchPositions[newMania][spr.ID];
		}
			
		spr.x += 50;
		spr.x += ((FlxG.width / 2) * playe);
		spr.x -= Note.posRest[newMania];

		defaultX = spr.x;
	}
}
