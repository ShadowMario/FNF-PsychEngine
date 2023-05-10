package mobile.flixel;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import openfl.utils.Assets;

/**
 * A virtual thumbstick - useful for input on mobile devices.
 *
 * @author Ka Wing Chin
 * @author Mihai Alexandru (M.A. Jigsaw) to work only with touch and to use custom assets
 */
class FlxJoyStick extends FlxSpriteGroup
{
	/**
	 * This function is called when the button is released.
	 */
	public var onUp:Void->Void;

	/**
	 * This function is called when the button is pressed down.
	 */
	public var onDown:Void->Void;

	/**
	 * This function is called when the touch goes over the button.
	 */
	public var onOver:Void->Void;

	/**
	 * This function is called when the button is hold down.
	 */
	public var onPressed:Void->Void;

	/**
	 * Used with public variable status, means not highlighted or pressed.
	 */
	static inline var NORMAL:Int = 0;

	/**
	 * Used with public variable status, means highlighted (usually from touch over).
	 */
	static inline var HIGHLIGHT:Int = 1;

	/**
	 * Used with public variable status, means pressed (usually from touch click).
	 */
	static inline var PRESSED:Int = 2;

	/**
	 * Shows the current state of the button.
	 */
	public var status:Int = NORMAL;

	/**
	 * The background of the joystick, also known as the base.
	 */
	public var base:FlxSprite;

	public var thumb:FlxSprite;

	/**
	 * A list of analogs that are currently active.
	 */
	static var _analogs:Array<FlxJoyStick> = [];

	/**
	 * The current pointer that's active on the analog.
	 */
	var _currentTouch:FlxTouch;

	/**
	 * Helper array for checking touches
	 */
	var _tempTouches:Array<FlxTouch> = [];

	/**
	 * The area which the joystick will react.
	 */
	var _zone:FlxRect = FlxRect.get();

	/**
	 * The radius in which the stick can move.
	 */
	var _radius:Float = 0;

	public var _direction:Float = 0;
	public var _amount:Float = 0;

	/**
	 * The speed of easing when the thumb is released.
	 */
	var _ease:Float;

	/**
	 * Create a virtual thumbstick - useful for input on android devices.
	 *
	 * @param   X            The X-coordinate of the point in space.
	 * @param   Y            The Y-coordinate of the point in space.
	 * @param   Radius       The radius where the thumb can move. If 0, half the base's width will be used.
	 * @param   Ease         Used to smoothly back thumb to center. Must be between 0 and (FlxG.updateFrameRate / 60).
	 */
	public function new(X:Float = 0, Y:Float = 0, Radius:Float = 0, Ease:Float = 0.25)
	{
		super(X, Y);

		_radius = Radius;
		_ease = FlxMath.bound(Ease, 0, 60 / FlxG.updateFramerate);

		_analogs.push(this);

		_point = FlxPoint.get();

		createBase();
		createThumb();
		createZone();

		scrollFactor.set();
		moves = false;
	}

	/**
	 * Creates the background of the analog stick.
	 */
	function createBase():Void
	{
		base = new FlxSprite(0, 0);
		base.loadGraphic(Assets.getBitmapData('assets/mobile/joystick/base.png'));
		base.x += -base.width * 0.5;
		base.y += -base.height * 0.5;
		base.scrollFactor.set();
		base.solid = false;
		base.immovable = true;
		base.alpha = 0.6;
		#if FLX_DEBUG
		base.ignoreDrawDebug = true;
		#end
		add(base);
	}

	/**
	 * Creates the thumb of the analog stick.
	 */
	function createThumb():Void
	{
		thumb = new FlxSprite(0, 0);
		thumb.loadGraphic(Assets.getBitmapData('assets/mobile/joystick/thumb.png'));
		thumb.x += -thumb.width * 0.5;
		thumb.y += -thumb.height * 0.5;
		thumb.scrollFactor.set();
		thumb.solid = false;
		thumb.immovable = true;
		thumb.alpha = 0.6;
		#if FLX_DEBUG
		thumb.ignoreDrawDebug = true;
		#end
		add(thumb);
	}

	/**
	 * Creates the touch zone. It's based on the size of the background.
	 * The thumb will react when the touch is in the zone.
	 */
	public function createZone():Void
	{
		if (base != null && _radius == 0)
			_radius = base.width * 0.5;

		_zone.set(x - _radius, y - _radius, 2 * _radius, 2 * _radius);
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();

		_zone = FlxDestroyUtil.put(_zone);

		_analogs.remove(this);
		onUp = null;
		onDown = null;
		onOver = null;
		onPressed = null;
		thumb = null;
		base = null;

		_currentTouch = null;
		_tempTouches = null;
	}

	/**
	 * Update the behavior.
	 */
	override public function update(elapsed:Float):Void
	{
		var offAll:Bool = true;

		// There is no reason to get into the loop if their is already a pointer on the analog
		if (_currentTouch != null)
			_tempTouches.push(_currentTouch);
		else
		{
			for (touch in FlxG.touches.list)
			{
				var touchInserted:Bool = false;

				for (analog in _analogs)
				{
					// Check whether the pointer is already taken by another analog.
					// TODO: check this place. This line was 'if (analog != this && analog._currentTouch != touch && touchInserted == false)'
					if (analog == this && analog._currentTouch != touch && !touchInserted)
					{
						_tempTouches.push(touch);
						touchInserted = true;
					}
				}
			}
		}

		for (touch in _tempTouches)
		{
			_point.set(touch.screenX, touch.screenY);

			if (!updateAnalog(_point, touch.pressed, touch.justPressed, touch.justReleased, touch))
			{
				offAll = false;
				break;
			}
		}

		if ((status == HIGHLIGHT || status == NORMAL) && _amount != 0)
		{
			_amount -= _amount * _ease * FlxG.updateFramerate / 60;

			if (Math.abs(_amount) < 0.1)
			{
				_amount = 0;
				_direction = 0;
			}
		}

		thumb.x = x + Math.cos(_direction) * _amount * _radius - (thumb.width * 0.5);
		thumb.y = y + Math.sin(_direction) * _amount * _radius - (thumb.height * 0.5);

		if (offAll)
			status = NORMAL;

		_tempTouches.splice(0, _tempTouches.length);

		super.update(elapsed);
	}

	function updateAnalog(TouchPoint:FlxPoint, Pressed:Bool, JustPressed:Bool, JustReleased:Bool, Touch:FlxTouch):Bool
	{
		var offAll:Bool = true;

		if (_zone.containsPoint(TouchPoint) || (status == PRESSED))
		{
			offAll = false;

			if (Pressed)
			{
				if (Touch != null)
					_currentTouch = Touch;

				status = PRESSED;

				if (JustPressed && onDown != null)
					onDown();

				if (status == PRESSED)
				{
					if (onPressed != null)
						onPressed();

					var dx:Float = TouchPoint.x - x;
					var dy:Float = TouchPoint.y - y;

					var dist:Float = Math.sqrt(dx * dx + dy * dy);

					if (dist < 1)
						dist = 0;

					_direction = Math.atan2(dy, dx);
					_amount = Math.min(_radius, dist) / _radius;

					acceleration.x = Math.cos(_direction) * _amount;
					acceleration.y = Math.sin(_direction) * _amount;
				}
			}
			else if (JustReleased && status == PRESSED)
			{
				_currentTouch = null;

				status = HIGHLIGHT;

				if (onUp != null)
					onUp();

				acceleration.set();
			}

			if (status == NORMAL)
			{
				status = HIGHLIGHT;

				if (onOver != null)
					onOver();
			}
		}

		return offAll;
	}

	/**
	 * Returns the angle in degrees.
	 */
	public function getAngle():Float
		return _direction * FlxAngle.TO_DEG;

	/**
	 * Whether the thumb is pressed or not.
	 */
	public var pressed(get, never):Bool;

	inline function get_pressed():Bool
		return status == PRESSED;

	/**
	 * Whether the thumb is just pressed or not.
	 */
	public var justPressed(get, never):Bool;

	function get_justPressed():Bool
	{
		if (_currentTouch != null)
			return _currentTouch.justPressed && status == PRESSED;

		return false;
	}

	/**
	 * Whether the thumb is just released or not.
	 */
	public var justReleased(get, never):Bool;

	function get_justReleased():Bool
	{
		if (_currentTouch != null)
			return _currentTouch.justReleased && status == HIGHLIGHT;

		return false;
	}

	override public function set_x(X:Float):Float
	{
		super.set_x(X);
		createZone();

		return X;
	}

	override public function set_y(Y:Float):Float
	{
		super.set_y(Y);
		createZone();

		return Y;
	}
}
