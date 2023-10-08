package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
			if (!ClientPrefs.colorQuants)
			{
				colorSwap.hue = ClientPrefs.arrowHSV[note][0] / 360;
				colorSwap.saturation = ClientPrefs.arrowHSV[note][1] / 100;
				colorSwap.brightness = ClientPrefs.arrowHSV[note][2] / 100;
			}

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if(texture == null && ClientPrefs.splashType == 'Psych Engine') {
			texture = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		if(ClientPrefs.splashType == 'VS Impostor') {
			texture = 'impostorNoteSplashes';
		}
		if(ClientPrefs.splashType == 'Base Game') {
			texture = 'baseNoteSplashes';
		}
		if(ClientPrefs.splashType == 'Doki Doki+') {
			texture = 'NOTE_splashes_doki';
		}
		if(ClientPrefs.splashType == 'TGT V4') {
			texture = 'tgtNoteSplashes';
		}
		if(ClientPrefs.splashType == 'Indie Cross') {
			texture = 'icNoteSplashes';
		}
		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		if (!ClientPrefs.colorQuants)
		{
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		}
		if (ClientPrefs.splashType != 'Base Game') {
		offset.set(10, 10);
		} else {
		offset.set(-10, 0);
		}

		var animNum:Int = 0;
		if (ClientPrefs.splashType != 'Doki Doki+' && ClientPrefs.splashType != 'Base Game')
		{
		animNum = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		}
		if (ClientPrefs.splashType == 'Doki Doki+')
		{
		animNum = 1;
		animation.play('note' + note, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		}
		if (ClientPrefs.splashType == 'Base Game')
		{
		animNum = FlxG.random.int(0, 1);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		}
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		if (ClientPrefs.splashType == 'Psych Engine')
		{
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Indie Cross')
		{
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'TGT V4')
		{
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'VS Impostor')
		{
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Doki Doki+')
		{
		for (i in 1...3) {
		animation.addByPrefix('note1', 'note splash blue', 24, false);
		animation.addByPrefix('note2', 'note splash green', 24, false);
		animation.addByPrefix('note0', 'note splash purple', 24, false);
		animation.addByPrefix('note3', 'note splash red', 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Base Game')
		{
		for (i in 1...3) {
		animation.addByPrefix('note1-0', 'note impact 1 blue', 24, false);
		animation.addByPrefix('note2-0', 'note impact 1 green', 24, false);
		animation.addByPrefix('note0-0', 'note impact 1 purple', 24, false);
		animation.addByPrefix('note3-0', 'note impact 1 red', 24, false);
		animation.addByPrefix('note1-1', 'note impact 2 blue', 24, false);
		animation.addByPrefix('note2-1', 'note impact 2 green', 24, false);
		animation.addByPrefix('note0-1', 'note impact 2 purple', 24, false);
		animation.addByPrefix('note3-1', 'note impact 2 red', 24, false);
		}
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}