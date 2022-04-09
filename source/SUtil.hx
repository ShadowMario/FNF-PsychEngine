package;

#if android
import android.AndroidTools;
import android.Permissions;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;

class SUtil
{
    #if android
    private static var aDir:String = null;
    private static var sPath:String = AndroidTools.getExternalStorageDirectory();  
    private static var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions();  
    #end

    static public function getPath():String
    {
    	#if android
        if (aDir != null && aDir.length > 0) 
        {
            return aDir;
        } 
        else 
        {
            aDir = sPath + "/" + "." + Application.current.meta.get("file") + "/files/";         
        }
        return aDir;
        #else
        return "";
        #end
    }

    static public function doTheCheck()
    {
        #if android
        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
                AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
            }  
        }

        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
                SUtil.applicationAlert("Permissions", "If you accepted the permisions for storage, good, you can continue, if you not the game can't run without storage permissions please grant them in app settings" + "\n" + "Press Ok To Close The App");
            } else {
                SUtil.applicationAlert("Permissions", "The Game can't run without storage permissions please grant them in app settings" + "\n" + "Press Ok To Close The App");
            }
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file"))){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file"));
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file") + "/files")){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file") + "/files");
        }

        if (!FileSystem.exists(SUtil.getPath() + "log")){
            FileSystem.createDirectory(SUtil.getPath() + "log");
        }

        if (!FileSystem.exists(SUtil.getPath() + "system-saves")){
            FileSystem.createDirectory(SUtil.getPath() + "system-saves");
        }

        if (!FileSystem.exists(SUtil.getPath() + "assets")){
            SUtil.applicationAlert("Instructions:", "You have to copy assets/assets from apk to your internal storage app directory " + "( here " + SUtil.getPath() + " )" + "if you hadn't have Zarhiver Downloaded, download it and enable the show hidden files option to have the folder visible" + "\n" + "Press Ok To Close The App");
            flash.system.System.exit(0);
        }
        
        if (!FileSystem.exists(SUtil.getPath() + "mods")){
            SUtil.applicationAlert("Instructions:", "You have to copy assets/mods from apk to your internal storage app directory " + "( here " + SUtil.getPath() + " )" + "if you hadn't have Zarhiver Downloaded, download it and enable the show hidden files option to have the folder visible" + "\n" + "Press Ok To Close The App");
            flash.system.System.exit(0);
        }
        #end
    }

    //Thanks Forever Engine
    static public function gameCrashCheck(){
    	Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
    }
     
    static public function onCrash(e:UncaughtErrorEvent):Void {
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        var dateNow:String = Date.now().toString();
        dateNow = StringTools.replace(dateNow, " ", "_");
        dateNow = StringTools.replace(dateNow, ":", "'");
        var path:String = "log/" + "crash_" + dateNow + ".txt";
        var errMsg:String = "";

        for (stackItem in callStack)
        {
            switch (stackItem)
            {
                case FilePos(s, file, line, column):
                    errMsg += file + " (line " + line + ")\n";
                default:
                    Sys.println(stackItem);
            }
        }

        errMsg += e.error;

        if (!FileSystem.exists(SUtil.getPath() + "log")){
            FileSystem.createDirectory(SUtil.getPath() + "log");
        }

        sys.io.File.saveContent(SUtil.getPath() + path, errMsg + "\n");
        
        Sys.println(errMsg);
        Sys.println("Crash dump saved in " + Path.normalize(path));
        Sys.println("Making a simple alert ...");

        SUtil.applicationAlert("Uncaught Error:", errMsg);
        flash.system.System.exit(0);
    }
	
    public static function applicationAlert(title:String, description:String){
        Application.current.window.alert(description, title);
    }

    static public function saveContent(fileName:String = "file", fileExtension:String = ".json", fileData:String = "you forgot something to add in your code"){
        if (!FileSystem.exists(SUtil.getPath() + "system-saves")){
            FileSystem.createDirectory(SUtil.getPath() + "system-saves");
        }

        sys.io.File.saveContent(SUtil.getPath() + "system-saves/" + fileName + fileExtension, fileData);
        SUtil.applicationAlert("", "File Saved Successfully!" + "\n" + "The File is saved here " + SUtil.getPath() + "system-saves/" + fileName + fileExtension);
    }
}
