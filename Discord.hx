package;

#if desktop
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

using StringTools;

class DiscordClient
{
	#if desktop
	public static var isInitialized:Bool = false;
	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "863222024192262205",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}
	
	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}
	
	static function onReady()
	{
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Psych Engine"
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Engine Version: " + MainMenuState.psychEngineVersion,
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
		});
	}
	#end
	#end
}
