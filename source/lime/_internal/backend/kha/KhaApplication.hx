package lime._internal.backend.kha;

import haxe.Timer;
import lime.app.Application;
import lime.app.Config;
import lime.media.AudioManager;
import lime.graphics.RenderContext;
import lime.graphics.Renderer;
import lime.math.Rectangle;
import lime.system.Clipboard;
import lime.system.Display;
import lime.system.DisplayMode;
import lime.system.JNI;
import lime.system.Sensor;
import lime.system.SensorType;
import lime.system.System;
import lime.ui.Gamepad;
import lime.ui.Joystick;
import lime.ui.JoystickHatPosition;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Touch;
import lime.ui.Window;
import openfl._internal.renderer.kha.KhaRenderer;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(haxe.Timer)
@:access(lime.app.Application)
@:access(lime.graphics.Renderer)
@:access(lime.system.Clipboard)
@:access(lime.system.Sensor)
@:access(lime.ui.Gamepad)
@:access(lime.ui.Joystick)
@:access(lime.ui.Window)
class KhaApplication
{
	private var applicationEventInfo = new ApplicationEventInfo(UPDATE);
	private var clipboardEventInfo = new ClipboardEventInfo();
	private var currentTouches = new Map<Int, Touch>();
	private var dropEventInfo = new DropEventInfo();
	private var gamepadEventInfo = new GamepadEventInfo();
	private var joystickEventInfo = new JoystickEventInfo();
	private var keyEventInfo = new KeyEventInfo();
	private var mouseEventInfo = new MouseEventInfo();
	private var renderEventInfo = new RenderEventInfo(RENDER);
	private var sensorEventInfo = new SensorEventInfo();
	private var textEventInfo = new TextEventInfo();
	private var touchEventInfo = new TouchEventInfo();
	private var unusedTouchesPool = new List<Touch>();
	private var windowEventInfo = new WindowEventInfo();

	public var handle:Dynamic;

	private var frameRate:Float;
	private var parent:Application;
	private var toggleFullscreen:Bool;

	private static function __init__() {}

	public function new(parent:Application):Void
	{
		this.parent = parent;
		frameRate = 60;
		toggleFullscreen = true;
	}

	public function create(config:Config):Void {}

	public function exec():Int
	{
		#if !macro
		kha.input.Mouse.get().notify(mouseDown, mouseUp, mouseMove, mouseWheel);

		kha.System.notifyOnRender(function(framebuffer:kha.Framebuffer)
		{
			for (renderer in parent.renderers)
			{
				KhaRenderer.framebuffer = framebuffer;
				renderer.render();
				renderer.onRender.dispatch();

				if (!renderer.onRender.canceled)
				{
					renderer.flip();
				}
			}

			// parent.renderer.render ();
		});
		#end

		return 0;
	}

	private function mouseDown(button:Int, x:Int, y:Int):Void
	{
		var window = parent.__windowByID.get(-1);

		if (window != null)
		{
			window.onMouseDown.dispatch(x, y, button);
		}
	}

	private function mouseUp(button:Int, x:Int, y:Int):Void
	{
		var window = parent.__windowByID.get(-1);

		if (window != null)
		{
			window.onMouseUp.dispatch(x, y, button);
		}
	}

	private function mouseMove(x:Int, y:Int, mx:Int, my:Int):Void
	{
		var window = parent.__windowByID.get(-1);

		if (window != null)
		{
			window.onMouseMove.dispatch(x, y);
			window.onMouseMoveRelative.dispatch(mx, my);
		}
	}

	private function mouseWheel(amount:Int):Void
	{
		var window = parent.__windowByID.get(-1);

		if (window != null)
		{
			window.onMouseWheel.dispatch(0, amount);
		}
	}

	public function exit():Void {}

	public function getFrameRate():Float
	{
		return frameRate;
	}

	private function handleApplicationEvent():Void {}

	private function handleClipboardEvent():Void {}

	private function handleDropEvent():Void {}

	private function handleGamepadEvent():Void {}

	private function handleJoystickEvent():Void {}

	private function handleKeyEvent():Void {}

	private function handleMouseEvent():Void {}

	private function handleRenderEvent():Void {}

	private function handleSensorEvent():Void {}

	private function handleTextEvent():Void {}

	private function handleTouchEvent():Void {}

	private function handleWindowEvent():Void {}

	public function setFrameRate(value:Float):Float
	{
		return frameRate = value;
	}

	private function updateTimer():Void {}
}

private class ApplicationEventInfo
{
	public var deltaTime:Float;
	public var type:ApplicationEventType;

	public function new(type:ApplicationEventType = null, deltaTime:Float = 0)
	{
		this.type = type;
		this.deltaTime = deltaTime;
	}

	public function clone():ApplicationEventInfo
	{
		return new ApplicationEventInfo(type, deltaTime);
	}
}

@:enum private abstract ApplicationEventType(Int)
{
	var UPDATE = 0;
	var EXIT = 1;
}

private class ClipboardEventInfo
{
	public var type:ClipboardEventType;

	public function new(type:ClipboardEventType = null)
	{
		this.type = type;
	}

	public function clone():ClipboardEventInfo
	{
		return new ClipboardEventInfo(type);
	}
}

@:enum private abstract ClipboardEventType(Int)
{
	var UPDATE = 0;
}

private class DropEventInfo
{
	#if hl
	public var file:hl.Bytes;
	#else
	public var file:String;
	#end
	public var type:DropEventType;

	public function new(type:DropEventType = null, file:String = null)
	{
		this.type = type;
		this.file = file;
	}

	public function clone():DropEventInfo
	{
		return new DropEventInfo(type, file);
	}
}

@:enum private abstract DropEventType(Int)
{
	var DROP_FILE = 0;
}

private class GamepadEventInfo
{
	public var axis:Int;
	public var button:Int;
	public var id:Int;
	public var type:GamepadEventType;
	public var value:Float;

	public function new(type:GamepadEventType = null, id:Int = 0, button:Int = 0, axis:Int = 0, value:Float = 0)
	{
		this.type = type;
		this.id = id;
		this.button = button;
		this.axis = axis;
		this.value = value;
	}

	public function clone():GamepadEventInfo
	{
		return new GamepadEventInfo(type, id, button, axis, value);
	}
}

@:enum private abstract GamepadEventType(Int)
{
	var AXIS_MOVE = 0;
	var BUTTON_DOWN = 1;
	var BUTTON_UP = 2;
	var CONNECT = 3;
	var DISCONNECT = 4;
}

private class JoystickEventInfo
{
	public var id:Int;
	public var index:Int;
	public var type:JoystickEventType;
	public var value:Int;
	public var x:Float;
	public var y:Float;

	public function new(type:JoystickEventType = null, id:Int = 0, index:Int = 0, value:Int = 0, x:Float = 0, y:Float = 0)
	{
		this.type = type;
		this.id = id;
		this.index = index;
		this.value = value;
		this.x = x;
		this.y = y;
	}

	public function clone():JoystickEventInfo
	{
		return new JoystickEventInfo(type, id, index, value, x, y);
	}
}

@:enum private abstract JoystickEventType(Int)
{
	var AXIS_MOVE = 0;
	var HAT_MOVE = 1;
	var TRACKBALL_MOVE = 2;
	var BUTTON_DOWN = 3;
	var BUTTON_UP = 4;
	var CONNECT = 5;
	var DISCONNECT = 6;
}

private class KeyEventInfo
{
	public var keyCode:Int;
	public var modifier:Int;
	public var type:KeyEventType;
	public var windowID:Int;

	public function new(type:KeyEventType = null, windowID:Int = 0, keyCode:Int = 0, modifier:Int = 0)
	{
		this.type = type;
		this.windowID = windowID;
		this.keyCode = keyCode;
		this.modifier = modifier;
	}

	public function clone():KeyEventInfo
	{
		return new KeyEventInfo(type, windowID, keyCode, modifier);
	}
}

@:enum private abstract KeyEventType(Int)
{
	var KEY_DOWN = 0;
	var KEY_UP = 1;
}

private class MouseEventInfo
{
	public var button:Int;
	public var movementX:Float;
	public var movementY:Float;
	public var type:MouseEventType;
	public var windowID:Int;
	public var x:Float;
	public var y:Float;

	public function new(type:MouseEventType = null, windowID:Int = 0, x:Float = 0, y:Float = 0, button:Int = 0, movementX:Float = 0, movementY:Float = 0)
	{
		this.type = type;
		this.windowID = 0;
		this.x = x;
		this.y = y;
		this.button = button;
		this.movementX = movementX;
		this.movementY = movementY;
	}

	public function clone():MouseEventInfo
	{
		return new MouseEventInfo(type, windowID, x, y, button, movementX, movementY);
	}
}

@:enum private abstract MouseEventType(Int)
{
	var MOUSE_DOWN = 0;
	var MOUSE_UP = 1;
	var MOUSE_MOVE = 2;
	var MOUSE_WHEEL = 3;
}

private class RenderEventInfo
{
	public var context:RenderContext;
	public var type:RenderEventType;

	public function new(type:RenderEventType = null, context:RenderContext = null)
	{
		this.type = type;
		this.context = context;
	}

	public function clone():RenderEventInfo
	{
		return new RenderEventInfo(type, context);
	}
}

@:enum private abstract RenderEventType(Int)
{
	var RENDER = 0;
	var RENDER_CONTEXT_LOST = 1;
	var RENDER_CONTEXT_RESTORED = 2;
}

private class SensorEventInfo
{
	public var id:Int;
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var type:SensorEventType;

	public function new(type:SensorEventType = null, id:Int = 0, x:Float = 0, y:Float = 0, z:Float = 0)
	{
		this.type = type;
		this.id = id;
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function clone():SensorEventInfo
	{
		return new SensorEventInfo(type, id, x, y, z);
	}
}

@:enum private abstract SensorEventType(Int)
{
	var ACCELEROMETER = 0;
}

private class TextEventInfo
{
	public var id:Int;
	public var length:Int;
	public var start:Int;
	#if hl
	public var text:hl.Bytes;
	#else
	public var text:String;
	#end
	public var type:TextEventType;
	public var windowID:Int;

	public function new(type:TextEventType = null, windowID:Int = 0, text:String = "", start:Int = 0, length:Int = 0)
	{
		this.type = type;
		this.windowID = windowID;
		this.text = text;
		this.start = start;
		this.length = length;
	}

	public function clone():TextEventInfo
	{
		return new TextEventInfo(type, windowID, text, start, length);
	}
}

@:enum private abstract TextEventType(Int)
{
	var TEXT_INPUT = 0;
	var TEXT_EDIT = 1;
}

private class TouchEventInfo
{
	public var device:Int;
	public var dx:Float;
	public var dy:Float;
	public var id:Int;
	public var pressure:Float;
	public var type:TouchEventType;
	public var x:Float;
	public var y:Float;

	public function new(type:TouchEventType = null, x:Float = 0, y:Float = 0, id:Int = 0, dx:Float = 0, dy:Float = 0, pressure:Float = 0, device:Int = 0)
	{
		this.type = type;
		this.x = x;
		this.y = y;
		this.id = id;
		this.dx = dx;
		this.dy = dy;
		this.pressure = pressure;
		this.device = device;
	}

	public function clone():TouchEventInfo
	{
		return new TouchEventInfo(type, x, y, id, dx, dy, pressure, device);
	}
}

@:enum private abstract TouchEventType(Int)
{
	var TOUCH_START = 0;
	var TOUCH_END = 1;
	var TOUCH_MOVE = 2;
}

private class WindowEventInfo
{
	public var height:Int;
	public var type:WindowEventType;
	public var width:Int;
	public var windowID:Int;
	public var x:Int;
	public var y:Int;

	public function new(type:WindowEventType = null, windowID:Int = 0, width:Int = 0, height:Int = 0, x:Int = 0, y:Int = 0)
	{
		this.type = type;
		this.windowID = windowID;
		this.width = width;
		this.height = height;
		this.x = x;
		this.y = y;
	}

	public function clone():WindowEventInfo
	{
		return new WindowEventInfo(type, windowID, width, height, x, y);
	}
}

@:enum private abstract WindowEventType(Int)
{
	var WINDOW_ACTIVATE = 0;
	var WINDOW_CLOSE = 1;
	var WINDOW_DEACTIVATE = 2;
	var WINDOW_ENTER = 3;
	var WINDOW_FOCUS_IN = 4;
	var WINDOW_FOCUS_OUT = 5;
	var WINDOW_LEAVE = 6;
	var WINDOW_MINIMIZE = 7;
	var WINDOW_MOVE = 8;
	var WINDOW_RESIZE = 9;
	var WINDOW_RESTORE = 10;
}
