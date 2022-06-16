package android.flixel;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;

class FlxJoyStick extends FlxSpriteGroup
{
	public var status:Int = NORMAL;

	static inline var NORMAL:Int = 0;
	static inline var HIGHLIGHT:Int = 1;
	static inline var PRESSED:Int = 2;

	public var thumb:FlxSprite;
	public var base:FlxSprite;

	public var onUp:Void->Void;
	public var onDown:Void->Void;
	public var onOver:Void->Void;
	public var onPressed:Void->Void;

	static var _joysticks:Array<FlxJoyStick> = [];

	var _currentTouch:FlxTouch;
	var _tempTouches:Array<FlxTouch> = [];
	var _zone:FlxRect = FlxRect.get();
	var _radius:Float = 0;
	var _direction:Float = 0;
	var _amount:Float = 0;
	var _ease:Float;

	public function new(y:Float = 0, y:Float = 0, radius:Float = 0, ease:Float = 0.25)
	{
		super();

		_radius = radius;
		_ease = FlxMath.bound(ease, 0, 60 / FlxG.updateFramerate);

		_joysticks.push(this);

		_point = FlxPoint.get();

		createBase();
		createThumb();

		this.x = x;
		this.y = y;

		scrollFactor.set();
		moves = false;
	}

	function createBase():Void
	{
		base = new FlxSprite(0, 0);
		base.loadGraphic(FlxGraphic.fromFrame(getFrames().getByName('base')));
		base.resetSizeFromFrame();
		base.x += -base.width * 0.5;
		base.y += -base.height * 0.5;
		base.scrollFactor.set();
		base.solid = false;
		#if FLX_DEBUG
		base.ignoreDrawDebug = true;
		#end
		add(base);
	}

	function createThumb():Void
	{
		thumb = new FlxSprite(0, 0);
		thumb.loadGraphic(FlxGraphic.fromFrame(getFrames().getByName('thumb')));
		thumb.resetSizeFromFrame();
		thumb.scrollFactor.set();
		thumb.solid = false;
		#if FLX_DEBUG
		thumb.ignoreDrawDebug = true;
		#end
		add(thumb);
	}

	public static function getFrames():FlxAtlasFrames
	{
		return Paths.getSparrowAtlas('android/joystick');
	}

	function createZone():Void
	{
		if (base != null && _radius == 0)
			_radius = base.width * 0.5;

		_zone.set(x - _radius, y - _radius, 2 * _radius, 2 * _radius);
	}

	override public function destroy():Void
	{
		super.destroy();

		_zone = FlxDestroyUtil.put(_zone);

		_joysticks.remove(this);
		onUp = null;
		onDown = null;
		onOver = null;
		onPressed = null;
		thumb = null;
		base = null;

		_currentTouch = null;
		_tempTouches = null;
	}

	override public function update(elapsed:Float):Void
	{
		var offAll:Bool = true;

		// There is no reason to get into the loop if their is already a pointer on the joystick
		if (_currentTouch != null)
			_tempTouches.push(_currentTouch);
		else
		{
			for (touch in FlxG.touches.list)
			{
				var touchInserted:Bool = false;

				for (joystick in _joysticks)
				{
					// Check whether the pointer is already taken by another joystick.
					// TODO: check this place. This line was 'if (joystick != this && joystick._currentTouch != touch && touchInserted == false)'
					if (joystick == this && joystick._currentTouch != touch && !touchInserted)
					{
						_tempTouches.push(touch);
						touchInserted = true;
					}
				}
			}
		}

		for (touch in _tempTouches)
		{
			_point = touch.getWorldPosition(FlxG.camera, _point);

			if (!updateJoystick(_point, touch.pressed, touch.justPressed, touch.justReleased, touch))
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

	function updateJoystick(TouchPoint:FlxPoint, Pressed:Bool, JustPressed:Bool, JustReleased:Bool, ?Touch:FlxTouch):Bool
	{
		var offAll:Bool = true;

		// Use the touch to figure out the world position if it's passed in, as
		// the screen coordinates passed in touchPoint are wrong
		// if the control is used in a group, for example.
		if (Touch != null)
			TouchPoint.set(Touch.screenX, Touch.screenY);

		if (_zone.containsPoint(TouchPoint) || (status == PRESSED))
		{
			offAll = false;

			if (Pressed)
			{
				if (Touch != null)
					_currentTouch = Touch;

				status = PRESSED;

				if (JustPressed)
				{
					if (onDown != null)
						onDown();
				}

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

	public function getAngle():Float
	{
		return _direction * FlxAngle.TO_DEG;
	}

	public var pressed(get, never):Bool;

	inline function get_pressed():Bool
	{
		return status == PRESSED;
	}

	public var justPressed(get, never):Bool;

	function get_justPressed():Bool
	{
		if (_currentTouch != null)
			return _currentTouch.justPressed && status == PRESSED;

		return false;
	}

	public var justReleased(get, never):Bool;

	function get_justReleased():Bool
	{
		if (_currentTouch != null)
			return _currentTouch.justReleased && status == HIGHLIGHT;

		return false;
	}

	override function set_x(X:Float):Float
	{
		super.set_x(X);
		createZone();

		return X;
	}

	override function set_y(Y:Float):Float
	{
		super.set_y(Y);
		createZone();

		return Y;
	}
}
