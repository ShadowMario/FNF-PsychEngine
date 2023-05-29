package backend;

import Sys.sleep;
import discord_rpc.DiscordRpc;
import lime.app.Application;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

/*
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				DiscordClient.shutdown();
			});*/

class DiscordClient
{
	public static var isInitialized:Bool = false;
	private static var _defaultID:String = "863222024192262205";
	public static var clientID(default, set):String = _defaultID;

	private static var _options:Dynamic = {
		details: "In the Menus",
		state: null,
		largeImageKey: 'icon',
		largeImageText: "Psych Engine",
		smallImageKey : null,
		startTimestamp : null,
		endTimestamp : null
	};

	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: clientID,
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

	public static function check()
	{
		if(!ClientPrefs.data.discordRPC)
		{
			if(DiscordClient.isInitialized) DiscordClient.shutdown();
			DiscordClient.isInitialized = false;
		}
		else DiscordClient.start();
	}
	
	public static function start()
	{
		if (!DiscordClient.isInitialized && ClientPrefs.data.discordRPC) {
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		}
	}

	public static function resetID()
	{
		if(clientID != _defaultID) clientID = _defaultID;
	}
	
	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}
	
	static function onReady()
	{
		DiscordRpc.presence(_options);
	}

	private static function set_clientID(newID:String)
	{
		clientID = newID;
		if(isInitialized)
		{
			trace('test!');
			DiscordClient.shutdown();
			isInitialized = false;
			start();
		}
		return newID;
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
		var startTimestamp:Float = 0;
		if (hasStartTimestamp) startTimestamp = Date.now().getTime();
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		_options.details = details;
		_options.state = state;
		_options.largeImageKey = 'icon';
		_options.largeImageText = "Engine Version: " + states.MainMenuState.psychEngineVersion;
		_options.smallImageKey = smallImageKey;
		// Obtained times are in milliseconds so they are divided so Discord can use it
		_options.startTimestamp = Std.int(startTimestamp / 1000);
		_options.endTimestamp = Std.int(endTimestamp / 1000);
		DiscordRpc.presence(_options);

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
		});
	}
	#end
}
