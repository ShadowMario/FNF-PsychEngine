package android;

package android;

#if (!android && !native && macro)
#error 'extension-androidtools is not supported on your current platform'
#end
import lime.system.JNI;

/**
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class FileBrowser
{
	public static final CREATE_DOCUMENT:String = 'android.intent.action.CREATE_DOCUMENT';
	public static final GET_CONTENT:String = 'android.intent.action.GET_CONTENT';

	/**
	 * Open the file browser.
	 */
	public static function open(action:String, type:String = '*/*', requestCode:Int = 1):Void
	{
		if (action == null || (action != CREATE_DOCUMENT && action != GET_CONTENT))
			return;

		JNI.createStaticMethod('org/haxe/extension/Tools', 'openFileBrowser', '(Ljava/lang/String;Ljava/lang/String;I)V')(action, type, requestCode);
	}

	/**
	 * Open the directory picker(SAF).
	 */
	public static function openDirectoryPicker(requestCode:Int = 1):Void
		{
			JNI.createStaticMethod('org/haxe/extension/Tools', 'openDirectoryPicker', '(I)V')(requestCode);
		}
		
	/**
	 * Returns the Directory the user have selected.
	 */
	public static function getSelectedDirectoryPath():String
		{
			var selectedDir:Dynamic = JNI.createStaticMethod('org/haxe/extension/Tools', 'getSelectedDirectoryPath', '')();
			var getAbsolutePath_jni:Dynamic = JNI.createMemberMethod('java/io/File', 'getAbsolutePath', '()Ljava/lang/String;');
			return getAbsolutePath_jni(selectedDir());
		}
}
