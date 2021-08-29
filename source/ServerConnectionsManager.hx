package;

import flixel.FlxG;
import haxe.Json;

class ServerConnectionsManager
{
    var serverIp:String = "localhost";
    var serverPort:String = "2000";

    // i dont recommend editing this file :)
    // if you do why you would do it

    private static function serverConnection(action:String, data:String, ?contentType:String = "application/json"):Dynamic
    {
        var req = new haxe.Http('localhost:2000/' + action);
        req.setHeader ("Content-type", contentType);
        req.setPostData(data);
        trace(data);
        req.onData = function (res:String)
        {
            var response:Dynamic = Json.parse(res);
            return Json.parse(response);
        }
        req.onError = function (error)
        {
            trace(req);
            trace(error);
            return {success:false,error:error};
        }
        req.request(true);
        return {success:false};
    }

    private static function checkTokenValid(token:String):Bool
    {
        if(serverConnection("checkToken", token, "text/plain").valid)
        {
            return true;
        }else
        {
            return false;
        }
    }

    public static function register(username:String, password:String):Dynamic
    {
        var data:Dynamic = {username: username, password: password};
        var connection = serverConnection("register", Json.stringify(data));
        if(connection.success)
        {
            if(connection.token == null)
            {
                return {success:false};
            }else
            {
                var tokenValid:Bool = checkTokenValid(connection.token);
                if(tokenValid)
                {
                    FlxG.save.data.token = connection.token;
                    return {success:true};
                }
                else{
                    return {success:false,error:"Token invalid"};
                }
            }
        }
        return {success:false,error:"Timed out"};
    }

    public static function login(username:String, password:String):Dynamic
    {
        var data:Dynamic = {username: username, password: password};
        var connection = serverConnection("login", Json.stringify(data));
        if(connection.success)
        {
            if(connection.token == null)
            {
                return {success:false,error:connection.error};
            }else
            {
                var tokenValid:Bool = checkTokenValid(connection.token);
                if(tokenValid)
                {
                    FlxG.save.data.token = connection.token;
                    return {success:true};
                }
                else{
                    return {success:false,error:"Token invalid"};
                }
            }
        }
        return {success:false,error:"Timed out"};
    }

    public static function publishLevel(level:Dynamic)
    {
        var connection = serverConnection("publishLevel", level);
    }
}