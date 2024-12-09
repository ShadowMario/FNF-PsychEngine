package backend.ui;

class PsychUIEventHandler
{
	public static function event(id:String, sender:Dynamic)
	{
		var state:Dynamic = cast FlxG.state;
		if(state == null) return;

		while(state.subState != null)
			state = cast state.subState;

		if(state != null && state.UIEvent != null)
			state.UIEvent(id, sender);
	}
}

interface PsychUIEvent {
	public function UIEvent(id:String, sender:Dynamic):Void;
}