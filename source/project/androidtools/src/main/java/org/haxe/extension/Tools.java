package org.haxe.extension;

import android.app.Activity;
import android.app.UiModeManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Vibrator;
import android.util.ArrayMap;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.File;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

/* 
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.

	You can access additional references from the Extension class,
	depending on your needs:

	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)

	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included 
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.

	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class Tools extends Extension {

    public static final String LOG_TAG = "Tools";
    public static HaxeObject hobject;
    public static Gson gson = new GsonBuilder().setPrettyPrinting().serializeNulls().create();
    public static int CURRENT_REQUEST_CODE;
    public static Uri selectedDirUri;

    public static void openDirectoryPicker(final int requestCode) {
        try {
            CURRENT_REQUEST_CODE = requestCode;
            Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
            Extension.mainActivity.startActivityForResult(intent, requestCode);
        } catch (Exception e) {
            Log.e(LOG_TAG, e.toString());
        }
    }

    /*
     * @Override
     * public static boolean onDirectoryPickerActivityResult(int requestCode, int
     * resultCode, Intent data) {
     * if (requestCode == CURRENT_REQUEST_CODE && resultCode == Activity.RESULT_OK)
     * {
     * if (data != null && data.getData() != null) {
     * selectedDirUri = data.getData();
     * // Handle the selected directory URI
     * }
     * }
     * // ...
     * }
     */

    public static String getSelectedDirectoryPath() {
        // Return the stored Path of the selected directory or null if not selected
        if (selectedDirUri != null) {
            return selectedDirUri.toString();
        } else {
            return null;
        }
    }

    public static String[] getGrantedPermissions() {
        List<String> granted = new ArrayList<String>();

        try {
            PackageInfo info = (PackageInfo) Extension.mainContext.getPackageManager()
                    .getPackageInfo(Extension.packageName, PackageManager.GET_PERMISSIONS);

            for (int i = 0; i < info.requestedPermissions.length; i++) {
                if ((info.requestedPermissionsFlags[i] & PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0) {
                    granted.add(info.requestedPermissions[i]);
                }
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, e.toString());
        }

        return granted.toArray(new String[granted.size()]);
    }

    public static void makeToastText(final String message, final int duration, final int gravity, final int xOffset,
            final int yOffset) {
        Extension.mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast toast = Toast.makeText(Extension.mainContext, message, duration);

                if (gravity >= 0) {
                    toast.setGravity(gravity, xOffset, yOffset);
                }

                toast.show();
            }
        });
    }

    public static void launchPackage(final String packageName, final int requestCode) {
        try {
            Intent intent = Extension.mainActivity.getPackageManager().getLaunchIntentForPackage(packageName);
            Extension.mainActivity.startActivityForResult(intent, requestCode);
        } catch (Exception e) {
            Log.e(LOG_TAG, e.toString());
        }
    }

    public static void openFileBrowser(final String action, final String type, final int requestCode) {
        try {
            Intent intent = new Intent(action);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            intent.setType(type != null ? type : "*/*");
            Extension.mainActivity.startActivityForResult(Intent.createChooser(intent, null), requestCode);
        } catch (Exception e) {
            Log.e(LOG_TAG, e.toString());
        }
    }

    public static boolean isRooted() {
        try {
            // Preform `su` to get root privledges...
            Process execute = Runtime.getRuntime().exec("su");
            execute.waitFor();

            if (execute.exitValue() != 255) {
                return true;
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, e.toString());
        }

        return false;
    }

    public static File getFilesDir() {
        return Extension.mainContext.getFilesDir();
    }

    public static File getExternalFilesDir(final String type) {
        return Extension.mainContext.getExternalFilesDir(type);
    }

    public static File getCacheDir() {
        return Extension.mainContext.getCacheDir();
    }

    public static File getExternalCacheDir() {
        return Extension.mainContext.getExternalCacheDir();
    }

    public static File getObbDir() {
        return Extension.mainContext.getObbDir();
    }

    public static String getStringFromUri(Uri uri) {
        return uri.toString();
    }

    public static void initCallBack(HaxeObject hobject) {
        Tools.hobject = hobject;
    }

    /**
     * Called when an activity you launched exits, giving you the requestCode
     * you started it with, the resultCode it returned, and any additional data
     * from it.
     */
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == CURRENT_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            if (data != null && data.getData() != null) {
                selectedDirUri = data.getData();
            }
        }
        ArrayMap<String, Object> content = new ArrayMap<String, Object>();
        content.put("requestCode", requestCode);
        content.put("resultCode", resultCode);

        if (data != null && data.getData() != null) {
            ArrayMap<String, Object> d = new ArrayMap<String, Object>();
            d.put("uri", data.getData().toString());
            d.put("path", data.getData().getPath());
            content.put("data", d);
        }

        if (hobject != null) {
            hobject.call("onActivityResult", new Object[] {
                    gson.toJson(content)
            });
        }

        return true;
    }

    /**
     * Callback for the result from requesting permissions.
     */
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        ArrayMap<String, Object> content = new ArrayMap<String, Object>();
        content.put("requestCode", requestCode);
        content.put("permissions", permissions);
        content.put("grantResults", grantResults);

        if (hobject != null) {
            hobject.call("onRequestPermissionsResult", new Object[] {
                    gson.toJson(content)
            });
        }

        return true;
    }
}
