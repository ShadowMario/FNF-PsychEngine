package flixel.addons.ui;

#if FLX_MOUSE
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.interfaces.IFlxUIWidget;

class FlxUISlider extends FlxSlider implements IFlxUIWidget
{
	public var name:String;

	public var broadcastToFlxUI:Bool = true;

	public static inline var CHANGE_EVENT:String = "change_slider"; // change in any way

	override public function update(elapsed:Float):Void
	{

		super.update(elapsed);
		
		// Clicking and sound logic
		if (mouseInRect(_bounds))
		{
			if (hoverAlpha != 1)
			{
				alpha = hoverAlpha;
			}

			#if FLX_SOUND_SYSTEM
			if (hoverSound != null && !_justHovered)
			{
				FlxG.sound.play(hoverSound);
			}
			#end

			_justHovered = true;

			if (FlxG.mouse.pressed)
			{
				handle.x = FlxG.mouse.getPositionInCameraView(camera).x;
				updateValue();

				#if FLX_SOUND_SYSTEM
				if (clickSound != null && !_justClicked)
				{
					FlxG.sound.play(clickSound);
					_justClicked = true;
				}
				#end
			}
			if (!FlxG.mouse.pressed)
			{
				_justClicked = false;
			}
		}
		else
		{
			if (hoverAlpha != 1)
			{
				alpha = 1;
			}

			_justHovered = false;
		}

		// Update the target value whenever the slider is being used
		if ((FlxG.mouse.pressed) && (mouseInRect( _bounds)))
		{
			updateValue();
		}

		// Update the value variable
		if ((varString != null) && (Reflect.getProperty(_object, varString) != null))
		{
			value = Reflect.getProperty(_object, varString);
		}

		// Changes to value from outside update the handle pos
		if (handle.x != expectedPos)
		{
			handle.x = expectedPos;
		}

		// Finally, update the valueLabel
		valueLabel.text = Std.string(FlxMath.roundDecimal(value, decimals));


	}

	private function mouseInRect(rect:flixel.math.FlxRect) 
	{
		if (FlxMath.pointInFlxRect(FlxG.mouse.getPositionInCameraView(camera).x,FlxG.mouse.getPositionInCameraView(camera).y,rect)) return true;
		else return false;
	}


}
#end
