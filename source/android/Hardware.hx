package android;

#if (!android && !native && macro)
#error 'extension-androidtools is not supported on your current platform'
#end

#if (openfl < '4.0.0')
import openfl.utils.JNI;
#else
import lime.system.JNI;
#end

/**
 * @author Saw (M.A. Jigsaw)
 */
class Hardware
{
	public static final ORIENTATION_UNSPECIFIED:Int = 0;
	public static final ORIENTATION_PORTRAIT:Int = 1;
	public static final ORIENTATION_LANDSCAPE:Int = 2;

	/**
	 * Makes the Phone vibrate, the time is in miliseconds btw.
	 */
	public static function vibrate(inputValue:Int):Void
	{
		var vibrate_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Hardware', 'vibrate', '(I)V');
		vibrate_jni(inputValue);
	}

	/**
	 * The Name of the function says what it does.
	 */
	public static function wakeUp():Void
	{
		var wakeUp_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Hardware', 'wakeUp', '()V');
		wakeUp_jni();
	}

	/**
	 * Sets the phone brightness, max is 1 and min is 0.
	 */
	public static function setBrightness(brightness:Float):Void
	{
		var setbrightness_set_brightness_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Hardware', 'setBrightness', '(F)V');
		setbrightness_set_brightness_jni(brightness);
	}

	/**
	 * The Name of the function says what it does.
	 */
	public static function setScreenOrientation(screenOrientation:Int):Void
	{
		var setRequestedOrientationNative:Dynamic = JNI.createStaticMethod('org/haxe/extension/Hardware', 'setRequestedOrientation', '(I)V');
		setRequestedOrientationNative(screenOrientation);
	}

	/**
	 * Makes a toast text.
	 */
	public static function toast(text:String, duration:ToastType):Void {
		if (duration != 1 && duration != 2)
			duration = 1;

		var toast_jni = JNI.createStaticMethod('org/haxe/extension/Hardware', 'toast', '(Ljava/lang/String;I)V');
		toast_jni(text, duration);
	}

	/**
	 * Shares a text.
	 */
	public static function shareText(subject:String, text:String):Void {
		var intent_jni = JNI.createStaticMethod('org/haxe/extension/Hardware', 'runIntent', '(Ljava/lang/String;Ljava/lang/String;I)V');
		intent_jni(subject, text, 0);
	}

	/**
	 * Launches a app.
	 */
	public static function launchApp(packageName:String):Void {
		var intent_jni = JNI.createStaticMethod('org/haxe/extension/Hardware', 'runIntent', '(Ljava/lang/String;Ljava/lang/String;I)V');
		intent_jni(packageName, '', 1);
	}

	/**
	 * Runs a intent action.
	 */
	public static function runIntent(action:String, url:String = null):Void {
		var intent_jni = JNI.createStaticMethod('org/haxe/extension/Hardware', 'runIntent', '(Ljava/lang/String;Ljava/lang/String;I)V');
		intent_jni(action, url, 2);
	}

	/**
	 * Returns the full screen width.
	 */
	public static function getScreenWidth():Int
	{
		var get_screen_width_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Hardware', 'getScreenWidth', '()I');
		return get_screen_width_jni();
	}

	/**
	 * Returns the full screen height.
	 */
	public static function getScreenHeight():Int
	{
		var get_screen_height_jni:Dynamic = JNI.createStaticMethod('org/haxe/extension/Hardware', 'getScreenHeight', '()I');
		return get_screen_height_jni();
	}
}

abstract ToastType(Int) to Int from Int
{
	public static final LENGTH_SHORT = 1;
	public static final LENGTH_LONG = 2;
}