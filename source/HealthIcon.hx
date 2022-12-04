package;

import openfl.utils.Assets as OpenFlAssets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class HealthIcon extends FlxSprite
{
	public static var prefix(default, null):String = 'icons/';
	public static var credits(default, null):String = 'credits/';
	public static var defaultIcon(default, null):String = 'icon-unknown';

	public var iconOffsets:Array<Float> = [0, 0];
	public var sprTracker:FlxSprite;
	public var isOldIcon(get, null):Bool;
	public var isPlayer:Bool;
	public var isCredit:Bool;

	private var char:String = '';
	private var availableStates:Int = 1;
	private var state:Int = 0;

	public static function returnGraphic(char:String, ?folder:String, defaultIfMissing:Bool = false, creditIcon:Bool = false):FlxGraphic {
		var path:String;
		if (creditIcon) {
			path = credits + ((folder != null || folder == '') ? folder + '/' : '') + char;
			if ((folder != null || folder == '') && !Paths.fileExists('images/' + path + '.png', IMAGE)) path = credits + char;
			if (Paths.fileExists('images/' + path + '.png', IMAGE)) return Paths.image(path);
			if (defaultIfMissing) return Paths.image(prefix + defaultIcon);
			return null;
		}
		path = prefix + char;
		if (!Paths.fileExists('images/' + path + '.png', IMAGE)) path = prefix + 'icon-' + char; //Older versions of psych engine's support
		if (!Paths.fileExists('images/' + path + '.png', IMAGE)) { //Prevents crash from missing icon
			if (!defaultIfMissing) return null;
			path = prefix + defaultIcon;
		}
		return Paths.image(path);
	}

	public function new(?char:String, ?folder:String, isPlayer:Bool = false, isCredit:Bool = false) {
		this.isPlayer = isPlayer;
		this.isCredit = isCredit;

		super();
		scrollFactor.set();
		changeIcon(char == null ? (isCredit ? defaultIcon : 'bf') : char, folder);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if (isOldIcon) changeIcon(char.substr(0, -4));
		else changeIcon(char + '-old');
	}

	public function changeIcon(char:String, ?folder:String, defaultIfMissing:Bool = true):Bool {
		if (this.char == char) return false;
		var graph:FlxGraphic = null;

		if (isCredit) graph = returnGraphic(char, folder, false, true);
		if (graph == null) graph = returnGraphic(char, defaultIfMissing);
		else {
			this.char = char;

			iconOffsets[1] = iconOffsets[0] = 0;
			loadGraphic(graph);
			updateHitbox();
			state = 0;

			antialiasing = !char.endsWith('-pixel');
			return true;
		}

		if (graph == null) return false;
		var ratio:Float = graph.width / graph.height;
		availableStates = Math.round(ratio);
		this.char = char;

		iconOffsets[1] = iconOffsets[0] = 0;
		if (availableStates <= 1) {
			loadGraphic(graph);
			updateHitbox();
			state = 0;
			return true;
		}
		loadGraphic(graph, true, Math.floor(graph.width / availableStates), graph.height);
		updateHitbox();

		animation.add(char, [for (i in 0...availableStates) i], 0, false, isPlayer);
		animation.play(char);

		antialiasing = !char.endsWith('-pixel');
		return true;
	}

	public function setState(state:Int) {
		if (state >= availableStates) state = 0;
		if (this.state == state || animation.curAnim == null) return;
		animation.curAnim.curFrame = this.state = state;
	}

	override function updateHitbox() {
		super.updateHitbox();
		offset.set(iconOffsets[0], iconOffsets[1]);
	}

	public function getCharacter():String
		return char;

	inline function get_isOldIcon():Bool
		return char.substr(-4, 4) == '-old';
}
