package options;

typedef Keybind = {
	keyboard:String,
	gamepad:String
}

class Option
{
	public var child:Alphabet;
	public var text(get, set):String;
	public var onChange:Void->Void = null; //Pressed enter (on Bool type options) or pressed/held left/right (on other types)

	public var type(get, default):String = 'bool'; //bool, int (or integer), float (or fl), percent, string (or str), keybind (or key)
	// Bool will use checkboxes
	// Everything else will use a text

	public var scrollSpeed:Float = 50; //Only works on int/float, defines how fast it scrolls per second while holding left/right
	private var variable:String = null; //Variable from ClientPrefs.hx
	public var defaultValue:Dynamic = null;

	public var curOption:Int = 0; //Don't change this
	public var options:Array<String> = null; //Only used in string type
	public var changeValue:Dynamic = 1; //Only used in int/float/percent type, how much is changed when you PRESS
	public var minValue:Dynamic = null; //Only used in int/float/percent type
	public var maxValue:Dynamic = null; //Only used in int/float/percent type
	public var decimals:Int = 1; //Only used in float/percent type

	public var displayFormat:String = '%v'; //How String/Float/Percent/Int values are shown, %v = Current value, %d = Default value
	public var description:String = '';
	public var name:String = 'Unknown';

	public var defaultKeys:Keybind = null; //Only used in keybind type
	public var keys:Keybind = null; //Only used in keybind type

	public function new(name:String, description:String = '', variable:String, type:String = 'bool', ?options:Array<String> = null)
	{
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
		this.options = options;

		if(this.type != 'keybind') this.defaultValue = Reflect.getProperty(ClientPrefs.defaultData, variable);
		switch(type)
		{
			case 'bool':
				if(defaultValue == null) defaultValue = false;
			case 'int' | 'float':
				if(defaultValue == null) defaultValue = 0;
			case 'percent':
				if(defaultValue == null) defaultValue = 1;
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;
			case 'string':
				if(defaultValue == null) defaultValue = '';
				if(options.length > 0) {
					defaultValue = options[0];
				}

			case 'keybind':
				defaultValue = '';
				defaultKeys = {gamepad: 'NONE', keyboard: 'NONE'};
				keys = {gamepad: 'NONE', keyboard: 'NONE'};
		}

		try
		{
			if(getValue() == null) {
				setValue(defaultValue);
			}
	
			switch(type)
			{
				case 'string':
					var num:Int = options.indexOf(getValue());
					if(num > -1) {
						curOption = num;
					}
			}
		}
		catch(e) {}
	}

	public function change()
	{
		//nothing lol
		if(onChange != null)
			onChange();
	}

	dynamic public function getValue():Dynamic
	{
		var value = Reflect.getProperty(ClientPrefs.data, variable);
		if(type == 'keybind') return !Controls.instance.controllerMode ? value.keyboard : value.gamepad;
		return value;
	}

	dynamic public function setValue(value:Dynamic)
	{
		if(type == 'keybind')
		{
			var keys = Reflect.getProperty(ClientPrefs.data, variable);
			if(!Controls.instance.controllerMode) keys.keyboard = value;
			else keys.gamepad = value;
			return value;
		}
		return Reflect.setProperty(ClientPrefs.data, variable, value);
	}

	private function get_text()
	{
		if(child != null) {
			return child.text;
		}
		return null;
	}
	private function set_text(newValue:String = '')
	{
		if(child != null) {
			child.text = newValue;
		}
		return null;
	}

	private function get_type()
	{
		var newValue:String = 'bool';
		switch(type.toLowerCase().trim())
		{
			case 'key', 'keybind': newValue = 'keybind';
			case 'int', 'float', 'percent', 'string': newValue = type;
			case 'integer': newValue = 'int';
			case 'str': newValue = 'string';
			case 'fl': newValue = 'float';
		}
		type = newValue;
		return type;
	}
}