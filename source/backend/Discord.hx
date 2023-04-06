package backend;

import Sys.sleep;
#if DISCORD_ALLOWED
import discord_rpc.DiscordRpc;
#end

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

class DiscordClient
{
	public static var isInitialized:Bool = false;
	#if DISCORD_ALLOWED
	public static var queue:DiscordPresenceOptions = {
		details: "In the Menus",
		state: null,
		largeImageKey: 'icon',
		largeImageText: "Psych Engine"
	}
	#end

	public function new()
	{
		#if DISCORD_ALLOWED
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
		#end
	}
	
	public static function shutdown()
	{
		#if DISCORD_ALLOWED
		DiscordRpc.shutdown();
		isInitialized = false;
		#end
	}
	
	static function onReady()
	{
		#if DISCORD_ALLOWED
		changePresence(
			queue.details, queue.state, queue.smallImageKey,
			queue.startTimestamp == 1 ? true : false,
			queue.endTimestamp
		);
		#end
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
		#if DISCORD_ALLOWED
		if (ClientPrefs.data.discordRPC != 'Deactivated')
		{
			var DiscordDaemon = sys.thread.Thread.create(() ->
			{
				new DiscordClient();
			});
			trace("Discord Client initialized");
			isInitialized = true;
		}
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		#if DISCORD_ALLOWED
		var startTimestamp:Float = 0;
		if(hasStartTimestamp) startTimestamp = Date.now().getTime();

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		var presence:DiscordPresenceOptions = {
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Engine Version: " + states.MainMenuState.psychEngineVersion,
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		};

		if (ClientPrefs.data.discordRPC == 'Deactivated' || !isInitialized) {
			presence.startTimestamp = if (hasStartTimestamp) 1 else 0;
			presence.endTimestamp = Std.int(endTimestamp);  // It wont be perfectly accurated anymore, whatever, theyre just milliseconds afterall  - Nex
			queue = presence;
		} else {
			if (ClientPrefs.data.discordRPC == 'Hide Infos') {
				presence.details = null;
				presence.state = null;
				presence.smallImageKey = null;
				presence.startTimestamp = 0;
				presence.endTimestamp = 0;
			}
			DiscordRpc.presence(presence);
			//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
		}
		#end
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
		});
	}
	#end
}
