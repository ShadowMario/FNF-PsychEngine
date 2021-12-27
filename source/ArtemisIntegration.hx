package;

import haxe.Json;
#if sys
import haxe.Http;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class ArtemisIntegration {
    // public static inline var ArtemisAPIUrlDirectory:String = "%ProgramData%/Artemis"; // WHAT DO YOU MEAN THIS DOESN'T WORK???????
    public static inline var ArtemisAPIUrlDirectory:String = "C:/ProgramData/Artemis";
    public static inline var ArtemisAPIUrlFile:String = "./webserver.txt";
    public static inline var ArtemisAPIPluginEndpoints:String = "plugins/endpoints";
    public static inline var THETHINGIMADE:String = "plugins/84c5243c-5492-4965-940c-4ce006524c06/";

    public static var artemisApiUrl:String = "http://localhost:9696/";
    public static var artemisAvailable:Bool = false;
    public static var fnfEndpoints:String = "http://localhost:9696/plugins/84c5243c-5492-4965-940c-4ce006524c06/";

    public static function initialize ():Void {
        #if sys
        trace ("attempting to initialize artemis integration...");
        // get the file that says what the local artemis webserver's url is.
        // the file not being there is a pretty good indication that the user doesn't have artemis so if it isn't there just don't enable this integration
        if (sys.FileSystem.exists (ArtemisAPIUrlDirectory) && sys.FileSystem.isDirectory (ArtemisAPIUrlDirectory)) {
            // is this part stupid? i'm not fluent in haxe so i have no clue if this is stupid or not i'm just rolling with what the api says
            var path:String = haxe.io.Path.join ([ArtemisAPIUrlDirectory, ArtemisAPIUrlFile]);
            if (sys.FileSystem.exists (path) && !sys.FileSystem.isDirectory (path)) {
                artemisApiUrl = sys.io.File.getContent (path);

                // we still need to check to make sure artemis, and its webserver, are actually open
                // if this request errors out we'll just do nothing for now
                // TODO: make it retry after a few seconds three or five times??? it might be pointless to do that though
                trace ("pinging artemis api webserver...");
                var endpointsRequest = new haxe.Http (artemisApiUrl + ArtemisAPIPluginEndpoints);

                endpointsRequest.onData = function (data:String) {
                    // do one final check to make sure we didn't just connect to some random ass webserver
                    var r = ~/[\x{200B}-\x{200D}\x{FEFF}]/g;
                    var trimmedData = r.replace (data, ''); // when the web request returns with a zero width space at the start for no fucking reason
                    trace ("recieved response from what i think/hopefully is the artemis webserver:" + trimmedData);
                    try {
                        var response = haxe.Json.parse (trimmedData);

                        trace ("AHA that's a json response, assuming it's artemis");
                        // TODO: probably should add a check to make sure it's an actual artemis server and not just some random ass webserver that happens to match this criteria

                        fnfEndpoints = artemisApiUrl + THETHINGIMADE;
                        artemisAvailable = true;
                    } catch (e) {
                        // yep nope if it's not json then it's definitely not what we're looking for
                        // just assume it's a random ass webserver and don't enable integration
                        trace ("nope nevermind, that's not json. probably not an artemis server (" + e + ")");
                    }
                }

                endpointsRequest.onError = function (data:String) { trace ("nope nevermind, couldn't connect to server. (recieved error " + data + ")"); }

                endpointsRequest.request ();
            } else {
                trace ("nope nevermind, it probably isn't installed (file's not there)");
            }
        } else {
            trace ("nope nevermind, it probably isn't installed (directory's not there)");
        } // none of this is working but it's very obviously something that should be implemented because statistically people are not going to have artemis
        #end
    }

    public static function sendBoyfriendHealth (health:Float) {
        if (artemisAvailable) {
            var request = new haxe.Http (fnfEndpoints + "SetHealth");
            request.setPostData (Std.string (health));
            request.request (true);
        }
    }
}