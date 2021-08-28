package;

import flixel.FlxG;
import haxe.Json;

class ServerConnectionsManager
{
    var serverIp:String = "localhost";
    var serverPort:String = "2000";

    // i dont recommend editing this file :)

    private function serverConnection(action:String, data:String, ?contentType:String = "application/json")
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
            return {success:false, error: error};
        }
        req.request(true);
    }

    private function checkTokenValid(token:String)
    {
        if(serverConnection("checkToken", token, "text/plain").valid)
        {
            return true;
        }else
        {
            return false;
        }
    }

    public function register(username:String, password:String)
    {
        var data:String = {username: username, password: password};
        var connection = serverConnection("register", Json.stringify(data));
        if(connection.success)
        {
            if(connection.token == null)
            {
                return false;
            }else
            {
                return checkTokenValid(connection.token);
            }
        }
    }

    public function login(username:String, password:String)
    {
        var data:String = {username: username, password: password};
        var connection = serverConnection("register", Json.stringify(data));
        if(connection.success)
        {
            if(connection.token == null)
            {
                return false;
            }else
            {
                var tokenValid:Bool = checkTokenValid(connection.token);
                if(tokenValid)
                {
                    FlxG.save.data.token = connection.token;
                }
                return tokenValid;
            }
        }
    }
}