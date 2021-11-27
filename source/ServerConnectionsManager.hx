package;

import flixel.FlxG;
import haxe.Json;

class ServerConnectionsManager
{
    static var serverIp:String = "localhost";
    static var serverPort:String = "2000";

    public static var finished:Bool = false;
    public static var specialDone:Bool = false;

    // i dont recommend editing this file :)
    // if you do why you would do it

    private static function serverConnection(action:String, data:String, ?contentType:String = "application/json"):Dynamic
    {
        var req = new haxe.Http(serverIp + ':' +  serverPort + '/' + action);
        var resData:Dynamic = {};
        req.setHeader ("Content-type", contentType);
        req.setPostData(data);
        trace(data);
        req.onData = function (res:String)
        {
            var response:Dynamic = Json.parse(res);
            return response;
        }
        req.onError = function (error)
        {
            trace(req);
            trace(error);
            return {success:false,error:"Http error:" + error};
        }
        req.onComplete = function ()
        {
            return resData;
        }
        req.request(true);
    }

    public static var preFinished:Bool = false;

    public static function register(username:String, password:String)
    {
        var req = new haxe.Http(serverIp + ':' +  serverPort + '/' + action);
        var data:Dynamic = {username:username,password:password}
        req.setHeader ("Content-type", contentType);
        req.setPostData(Json.stringify(data));
        req.onData = function (res:String)
        {
            var response:Dynamic = Json.parse(res);
            return response;
        }
        req.onError = function (error)
        {
            trace(req);
            trace(error);
            return {success:false,error:"Http error:" + error};
        }
        req.request(true);
    }

    public static function login(username:String, password:String)
    {
        var data:Dynamic = {username: username, password: password};
        var conn = serverConnection("login", Json.stringify(data));
        return conn;
    }

    public static function publishLevel(level:Dynamic)
    {
        serverConnection("publishLevel", level);
    }
}