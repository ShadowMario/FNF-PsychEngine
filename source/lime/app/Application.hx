package lime.app;

import lime.graphics.RenderContext;
import lime.system.System;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.Joystick;
import lime.ui.JoystickHatPosition;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Touch;
import lime.ui.Window;
import lime.ui.WindowAttributes;
import lime.utils.Preloader;

/**
	The Application class forms the foundation for most Lime projects.
	It is common to extend this class in a main class. It is then possible
	to override "on" functions in the class in order to handle standard events
	that are relevant.
**/
@:access(lime.ui.Window)
#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Application extends Module
{
	/**
		The current Application instance that is executing
	**/
	public static var current(default, null):Application;

	/**
		Meta-data values for the application, such as a version or a package name
	**/
	public var meta:Map<String, String>;

	/**
		A list of currently attached Module instances
	**/
	public var modules(default, null):Array<IModule>;

	/**
		Update events are dispatched each frame (usually just before rendering)
	**/
	public var onUpdate = new Event<Int->Void>();

	/**
		Dispatched when a new window has been created by this application
	**/
	public var onCreateWindow = new Event<Window->Void>();

	/**
		The Preloader for the current Application
	**/
	public var preloader(get, null):Preloader;

	/**
		The Window associated with this Application, or the first Window
		if there are multiple Windows active
	**/
	public var window(get, null):Window;

	/**
		A list of active Window instances associated with this Application
	**/
	public var windows(get, null):Array<Window>;

	@:noCompletion private var __backend:ApplicationBackend;
	@:noCompletion private var __preloader:Preloader;
	@:noCompletion private var __window:Window;
	@:noCompletion private var __windowByID:Map<Int, Window>;
	@:noCompletion private var __windows:Array<Window>;

	private static function __init__()
	{
		var _init = ApplicationBackend;
		#if commonjs
		var p = untyped Application.prototype;
		untyped Object.defineProperties(p,
			{
				"preloader": {get: p.get_preloader},
				"window": {get: p.get_window},
				"windows": {get: p.get_windows}
			});
		#end
	}

	/**
		Creates a new Application instance
	**/
	public function new()
	{
		super();

		if (Application.current == null)
		{
			Application.current = this;
		}

		meta = new Map();
		modules = new Array();
		__windowByID = new Map();
		__windows = new Array();

		__backend = new ApplicationBackend(this);

		__registerLimeModule(this);

		__preloader = new Preloader();
		__preloader.onProgress.add(onPreloadProgress);
		__preloader.onComplete.add(onPreloadComplete);
	}

	/**
		Adds a new module to the Application
		@param	module	A module to add
	**/
	public function addModule(module:IModule):Void
	{
		module.__registerLimeModule(this);
		modules.push(module);
	}

	/**
		Creates a new Window and adds it to the Application
		@param	attributes	A set of parameters to initialize the window
	**/
	public function createWindow(attributes:WindowAttributes):Window
	{
		var window = __createWindow(attributes);
		__addWindow(window);
		return window;
	}

	/**
		Execute the Application. On native platforms, this method
		blocks until the application is finished running. On other
		platforms, it will return immediately
		@return	An exit code, 0 if there was no error
	**/
	public function exec():Int
	{
		Application.current = this;

		return __backend.exec();
	}

	/**
		Called when a gamepad axis move event is fired
		@param	gamepad	The current gamepad
		@param	axis	The axis that was moved
		@param	value	The axis value (between 0 and 1)
	**/
	public function onGamepadAxisMove(gamepad:Gamepad, axis:GamepadAxis, value:Float):Void {}

	/**
		Called when a gamepad button down event is fired
		@param	gamepad	The current gamepad
		@param	button	The button that was pressed
	**/
	public function onGamepadButtonDown(gamepad:Gamepad, button:GamepadButton):Void {}

	/**
		Called when a gamepad button up event is fired
		@param	gamepad	The current gamepad
		@param	button	The button that was released
	**/
	public function onGamepadButtonUp(gamepad:Gamepad, button:GamepadButton):Void {}

	/**
		Called when a gamepad is connected
		@param	gamepad	The gamepad that was connected
	**/
	public function onGamepadConnect(gamepad:Gamepad):Void {}

	/**
		Called when a gamepad is disconnected
		@param	gamepad	The gamepad that was disconnected
	**/
	public function onGamepadDisconnect(gamepad:Gamepad):Void {}

	/**
		Called when a joystick axis move event is fired
		@param	joystick	The current joystick
		@param	axis	The axis that was moved
		@param	value	The axis value (between 0 and 1)
	**/
	public function onJoystickAxisMove(joystick:Joystick, axis:Int, value:Float):Void {}

	/**
		Called when a joystick button down event is fired
		@param	joystick	The current joystick
		@param	button	The button that was pressed
	**/
	public function onJoystickButtonDown(joystick:Joystick, button:Int):Void {}

	/**
		Called when a joystick button up event is fired
		@param	joystick	The current joystick
		@param	button	The button that was released
	**/
	public function onJoystickButtonUp(joystick:Joystick, button:Int):Void {}

	/**
		Called when a joystick is connected
		@param	joystick	The joystick that was connected
	**/
	public function onJoystickConnect(joystick:Joystick):Void {}

	/**
		Called when a joystick is disconnected
		@param	joystick	The joystick that was disconnected
	**/
	public function onJoystickDisconnect(joystick:Joystick):Void {}

	/**
		Called when a joystick hat move event is fired
		@param	joystick	The current joystick
		@param	hat	The hat that was moved
		@param	position	The current hat position
	**/
	public function onJoystickHatMove(joystick:Joystick, hat:Int, position:JoystickHatPosition):Void {}

	/**
		Called when a joystick axis move event is fired
		@param	joystick	The current joystick
		@param	trackball	The trackball that was moved
		@param	x	The x movement of the trackball (between 0 and 1)
		@param	y	The y movement of the trackball (between 0 and 1)
	**/
	public function onJoystickTrackballMove(joystick:Joystick, trackball:Int, x:Float, y:Float):Void {}

	/**
		Called when a key down event is fired on the primary window
		@param	keyCode	The code of the key that was pressed
		@param	modifier	The modifier of the key that was pressed
	**/
	public function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void {}

	/**
		Called when a key up event is fired on the primary window
		@param	keyCode	The code of the key that was released
		@param	modifier	The modifier of the key that was released
	**/
	public function onKeyUp(keyCode:KeyCode, modifier:KeyModifier):Void {}

	/**
		Called when the module is exiting
	**/
	public function onModuleExit(code:Int):Void {}

	/**
		Called when a mouse down event is fired on the primary window
		@param	x	The current x coordinate of the mouse
		@param	y	The current y coordinate of the mouse
		@param	button	The ID of the mouse button that was pressed
	**/
	public function onMouseDown(x:Float, y:Float, button:MouseButton):Void {}

	/**
		Called when a mouse move event is fired on the primary window
		@param	x	The current x coordinate of the mouse
		@param	y	The current y coordinate of the mouse
	**/
	public function onMouseMove(x:Float, y:Float):Void {}

	/**
		Called when a mouse move relative event is fired on the primary window
		@param	x	The x movement of the mouse
		@param	y	The y movement of the mouse
	**/
	public function onMouseMoveRelative(x:Float, y:Float):Void {}

	/**
		Called when a mouse up event is fired on the primary window
		@param	x	The current x coordinate of the mouse
		@param	y	The current y coordinate of the mouse
		@param	button	The ID of the button that was released
	**/
	public function onMouseUp(x:Float, y:Float, button:MouseButton):Void {}

	/**
		Called when a mouse wheel event is fired on the primary window
		@param	deltaX	The amount of horizontal scrolling (if applicable)
		@param	deltaY	The amount of vertical scrolling (if applicable)
		@param	deltaMode	The units of measurement used
	**/
	public function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {}

	/**
		Called when a preload complete event is fired
	**/
	public function onPreloadComplete():Void {}

	/**
		Called when a preload progress event is fired
		@param	loaded	The number of items that are loaded
		@param	total	The total number of items will be loaded
	**/
	public function onPreloadProgress(loaded:Int, total:Int):Void {}

	/**
		Called when a render context is lost on the primary window
	**/
	public function onRenderContextLost():Void {}

	/**
		Called when a render context is restored on the primary window
		@param	context	The render context relevant to the event
	**/
	public function onRenderContextRestored(context:RenderContext):Void {}

	/**
		Called when a text edit event is fired on the primary window
		@param	text	The current replacement text
		@param	start	The starting index for the edit
		@param	length	The length of the edit
	**/
	public function onTextEdit(text:String, start:Int, length:Int):Void {}

	/**
		Called when a text input event is fired on the primary window
		@param	text	The current input text
	**/
	public function onTextInput(text:String):Void {}

	/**
		Called when a touch cancel event is fired
		@param	touch	The current touch object
	**/
	public function onTouchCancel(touch:Touch):Void {}

	/**
		Called when a touch end event is fired
		@param	touch	The current touch object
	**/
	public function onTouchEnd(touch:Touch):Void {}

	/**
		Called when a touch move event is fired
		@param	touch	The current touch object
	**/
	public function onTouchMove(touch:Touch):Void {}

	/**
		Called when a touch start event is fired
		@param	touch	The current touch object
	**/
	public function onTouchStart(touch:Touch):Void {}

	/**
		Called when a window activate event is fired on the primary window
	**/
	public function onWindowActivate():Void {}

	/**
		Called when a window close event is fired on the primary window
	**/
	public function onWindowClose():Void {}

	/**
		Called when the primary window is created
	**/
	public function onWindowCreate():Void {}

	/**
		Called when a window deactivate event is fired on the primary window
	**/
	public function onWindowDeactivate():Void {}

	/**
		Called when a window drop file event is fired on the primary window
	**/
	public function onWindowDropFile(file:String):Void {}

	/**
		Called when a window enter event is fired on the primary window
	**/
	public function onWindowEnter():Void {}

	/**
		Called when a window expose event is fired on the primary window
	**/
	public function onWindowExpose():Void {}

	/**
		Called when a window focus in event is fired on the primary window
	**/
	public function onWindowFocusIn():Void {}

	/**
		Called when a window focus out event is fired on the primary window
	**/
	public function onWindowFocusOut():Void {}

	/**
		Called when the primary window enters fullscreen
	**/
	public function onWindowFullscreen():Void {}

	/**
		Called when a window leave event is fired on the primary window
	**/
	public function onWindowLeave():Void {}

	/**
		Called when a window move event is fired on the primary window
		@param	x	The x position of the window in desktop coordinates
		@param	y	The y position of the window in desktop coordinates
	**/
	public function onWindowMove(x:Float, y:Float):Void {}

	/**
		Called when the primary window is minimized
	**/
	public function onWindowMinimize():Void {}

	/**
		Called when a window resize event is fired on the primary window
		@param	width	The width of the window
		@param	height	The height of the window
	**/
	public function onWindowResize(width:Int, height:Int):Void {}

	/**
		Called when the primary window is restored from being minimized or fullscreen
	**/
	public function onWindowRestore():Void {}

	/**
		Removes a module from the Application
		@param	module	A module to remove
	**/
	public function removeModule(module:IModule):Void
	{
		if (module != null)
		{
			module.__unregisterLimeModule(this);
			modules.remove(module);
		}
	}

	/**
		Called when a render event is fired on the primary window
		@param	context	The render context ready to be rendered
	**/
	public function render(context:RenderContext):Void {}

	/**
		Called when an update event is fired on the primary window
		@param	deltaTime	The amount of time in milliseconds that has elapsed since the last update
	**/
	public function update(deltaTime:Float):Void {}

	@:noCompletion private function __addWindow(window:Window):Void
	{
		if (window != null)
		{
			__windows.push(window);
			__windowByID.set(window.id, window);

			window.onClose.add(__onWindowClose.bind(window), false, -10000);

			if (__window == null)
			{
				__window = window;

				window.onActivate.add(onWindowActivate);
				window.onRenderContextLost.add(onRenderContextLost);
				window.onRenderContextRestored.add(onRenderContextRestored);
				window.onDeactivate.add(onWindowDeactivate);
				window.onDropFile.add(onWindowDropFile);
				window.onEnter.add(onWindowEnter);
				window.onExpose.add(onWindowExpose);
				window.onFocusIn.add(onWindowFocusIn);
				window.onFocusOut.add(onWindowFocusOut);
				window.onFullscreen.add(onWindowFullscreen);
				window.onKeyDown.add(onKeyDown);
				window.onKeyUp.add(onKeyUp);
				window.onLeave.add(onWindowLeave);
				window.onMinimize.add(onWindowMinimize);
				window.onMouseDown.add(onMouseDown);
				window.onMouseMove.add(onMouseMove);
				window.onMouseMoveRelative.add(onMouseMoveRelative);
				window.onMouseUp.add(onMouseUp);
				window.onMouseWheel.add(onMouseWheel);
				window.onMove.add(onWindowMove);
				window.onRender.add(render);
				window.onResize.add(onWindowResize);
				window.onRestore.add(onWindowRestore);
				window.onTextEdit.add(onTextEdit);
				window.onTextInput.add(onTextInput);

				onWindowCreate();
			}

			onCreateWindow.dispatch(window);
		}
	}

	@:noCompletion private function __createWindow(attributes:WindowAttributes):Window
	{
		var window = new Window(this, attributes);
		if (window.id == -1) return null;
		return window;
	}

	@:noCompletion private override function __registerLimeModule(application:Application):Void
	{
		application.onUpdate.add(update);
		application.onExit.add(onModuleExit, false, 0);
		application.onExit.add(__onModuleExit, false, 0);

		for (gamepad in Gamepad.devices)
		{
			__onGamepadConnect(gamepad);
		}

		Gamepad.onConnect.add(__onGamepadConnect);

		for (joystick in Joystick.devices)
		{
			__onJoystickConnect(joystick);
		}

		Joystick.onConnect.add(__onJoystickConnect);

		Touch.onCancel.add(onTouchCancel);
		Touch.onStart.add(onTouchStart);
		Touch.onMove.add(onTouchMove);
		Touch.onEnd.add(onTouchEnd);
	}

	@:noCompletion private function __removeWindow(window:Window):Void
	{
		if (window != null && __windowByID.exists(window.id))
		{
			if (__window == window)
			{
				__window = null;
			}

			__windows.remove(window);
			__windowByID.remove(window.id);
			window.close();

			if (__windows.length == 0)
			{
				#if !lime_doc_gen
				System.exit(0);
				#end
			}
		}
	}

	@:noCompletion private function __onGamepadConnect(gamepad:Gamepad):Void
	{
		onGamepadConnect(gamepad);

		gamepad.onAxisMove.add(onGamepadAxisMove.bind(gamepad));
		gamepad.onButtonDown.add(onGamepadButtonDown.bind(gamepad));
		gamepad.onButtonUp.add(onGamepadButtonUp.bind(gamepad));
		gamepad.onDisconnect.add(onGamepadDisconnect.bind(gamepad));
	}

	@:noCompletion private function __onJoystickConnect(joystick:Joystick):Void
	{
		onJoystickConnect(joystick);

		joystick.onAxisMove.add(onJoystickAxisMove.bind(joystick));
		joystick.onButtonDown.add(onJoystickButtonDown.bind(joystick));
		joystick.onButtonUp.add(onJoystickButtonUp.bind(joystick));
		joystick.onDisconnect.add(onJoystickDisconnect.bind(joystick));
		joystick.onHatMove.add(onJoystickHatMove.bind(joystick));
		joystick.onTrackballMove.add(onJoystickTrackballMove.bind(joystick));
	}

	@:noCompletion private function __onModuleExit(code:Int):Void
	{
		__backend.exit();
	}

	@:noCompletion private function __onWindowClose(window:Window):Void
	{
		if (this.window == window)
		{
			onWindowClose();
		}

		__removeWindow(window);
	}

	@:noCompletion private override function __unregisterLimeModule(application:Application):Void
	{
		application.onUpdate.remove(update);
		application.onExit.remove(__onModuleExit);
		application.onExit.remove(onModuleExit);

		Gamepad.onConnect.remove(__onGamepadConnect);
		Joystick.onConnect.remove(__onJoystickConnect);
		Touch.onCancel.remove(onTouchCancel);
		Touch.onStart.remove(onTouchStart);
		Touch.onMove.remove(onTouchMove);
		Touch.onEnd.remove(onTouchEnd);

		onModuleExit(0);
	}

	// Get & Set Methods
	@:noCompletion private inline function get_preloader():Preloader
	{
		return __preloader;
	}

	@:noCompletion private inline function get_window():Window
	{
		return __window;
	}

	@:noCompletion private inline function get_windows():Array<Window>
	{
		return __windows;
	}
}

#if kha
@:noCompletion private typedef ApplicationBackend = lime._internal.backend.kha.KhaApplication;
#elseif air
@:noCompletion private typedef ApplicationBackend = lime._internal.backend.air.AIRApplication;
#elseif flash
@:noCompletion private typedef ApplicationBackend = lime._internal.backend.flash.FlashApplication;
#elseif (js && html5)
@:noCompletion private typedef ApplicationBackend = lime._internal.backend.html5.HTML5Application;
#else
@:noCompletion private typedef ApplicationBackend = lime._internal.backend.native.NativeApplication;
#end
