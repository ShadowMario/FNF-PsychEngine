package android.flixel;

import openfl.display.BitmapData;
import openfl.display.Shape;
import android.flixel.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class FlxNewHitbox extends FlxSpriteGroup {
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);
	public var buttonSpace:FlxButton = new FlxButton(0, 0);

	/**
	 * Create the zone.
	 */
	public function new():Void {
		super();

		var buttonLeftColor:Array<FlxColor>;
	    var buttonDownColor:Array<FlxColor>;
		var buttonUpColor:Array<FlxColor>;
		var buttonRightColor:Array<FlxColor>;
		if (ClientPrefs.dynamicColors) { //bri'ish type option
			buttonLeftColor = ClientPrefs.arrowHSV[0];
			buttonDownColor = ClientPrefs.arrowHSV[1];
			buttonUpColor = ClientPrefs.arrowHSV[2];
			buttonRightColor = ClientPrefs.arrowHSV[3];
		} else {
			buttonLeftColor = ClientPrefs.arrowHSV[0];
			buttonDownColor = ClientPrefs.arrowHSV[1];
			buttonUpColor = ClientPrefs.arrowHSV[2];
			buttonRightColor = ClientPrefs.arrowHSV[3];
	    }

		if (!ClientPrefs.hitboxSpace) {
            add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), buttonLeftColor[0]));
		    add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), buttonDownColor[0]));
		    add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), buttonUpColor[0]));
		    add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), buttonRightColor[0]));
        }

        else {
        if (ClientPrefs.hitboxSpaceLocation == 'Bottom') {
		    add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonLeftColor[0]));
		    add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonDownColor[0]));
		    add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonUpColor[0]));
		    add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonRightColor[0]));
            add(buttonSpace = createHint(0, (FlxG.height / 5) * 4, FlxG.width, Std.int(FlxG.height / 5), 0xFFFF00)); 
		}

		else if (ClientPrefs.hitboxSpaceLocation == 'Top') {
		    add(buttonLeft = createHint(0, (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonLeftColor[0]));
		    add(buttonDown = createHint(FlxG.width / 4, (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonDownColor[0]));
		    add(buttonUp = createHint(FlxG.width / 2, (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonUpColor[0]));
		    add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), buttonRightColor[0]));
            add(buttonSpace = createHint(0, 0, FlxG.width, Std.int(FlxG.height / 5), 0xFFFF00));		        
		}
		    
		else {
		    add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), buttonLeftColor[0]));
		    add(buttonDown = createHint(FlxG.width / 5 * 1, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), buttonDownColor[0]));
		    add(buttonUp = createHint(FlxG.width / 5 * 3, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), buttonUpColor[0]));
		    add(buttonRight = createHint(FlxG.width / 5 * 4 , 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), buttonRightColor[0]));
            add(buttonSpace = createHint(FlxG.width / 5 * 2, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), 0xFFFF00));
		}
	}	
	scrollFactor.set();
}

	/**
	 * Clean up memory.
	 */
	override function destroy():Void {
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
		buttonSpace = null;
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF):BitmapData {
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		shape.graphics.lineStyle(10, Color, 1);
		shape.graphics.drawRect(0, 0, Width, Height);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):FlxButton {
		var hint:FlxButton = new FlxButton(X, Y);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));
		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.onDown.callback = hint.onOver.callback = function() {
			if (hint.alpha != ClientPrefs.hitboxAlpha)
				hint.alpha = ClientPrefs.hitboxAlpha;
		}
		hint.onUp.callback = hint.onOut.callback = function() {
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}