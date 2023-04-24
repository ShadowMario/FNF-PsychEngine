package options;

class Option
{
	private var child:Alphabet;
	public var text(get, set):String;
	public var onChange:Void->Void = null; //Pressed enter (on Bool type options) or pressed/held left/right (on other types)

	#if MODS_ALLOWED
	public var fromJson:Array<String> = null; //Only used if the option is from a modpack json
	#end

	public var type(get, default):String = 'bool'; //bool, int (or integer), float (or fl), percent, string (or str)
	// Bool will use checkboxes
	// Everything else will use a text

	public var showBoyfriend:Bool = false;
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

	public function new(name:String, description:String = '', variable:String, type:String = 'bool', defaultValue:Dynamic = 'null variable value', ?options:Array<String> = null #if MODS_ALLOWED, ?fromJson:Array<String> = null #end)
	{
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;
		this.options = options;
		#if MODS_ALLOWED
		this.fromJson = fromJson;
		#end

		if(defaultValue == 'null variable value') {
			defaultValue = CoolUtil.getOptionDefVal(type, options);
		}

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
	
			case 'percent':
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;
		}
	}

	public function change()
	{
		//nothing lol
		if(onChange != null) {
			onChange();
		}
	}

	public function getValue():Dynamic
	{
		#if MODS_ALLOWED
		if (fromJson != null) {
			if (ClientPrefs.data.modsOptsSaves.exists(fromJson[0]) && ClientPrefs.data.modsOptsSaves[fromJson[0]].exists(variable)) {
				return ClientPrefs.data.modsOptsSaves[fromJson[0]][variable];
			} else return null;
		}
		#end
		return Reflect.getProperty(ClientPrefs.data, variable);
	}
	public function setValue(value:Dynamic)
	{
		#if MODS_ALLOWED
		if (fromJson != null) {
			if (!ClientPrefs.data.modsOptsSaves.exists(fromJson[0])) ClientPrefs.data.modsOptsSaves.set(fromJson[0], []);
			ClientPrefs.data.modsOptsSaves[fromJson[0]][variable] = value;
		} else #end Reflect.setProperty(ClientPrefs.data, variable, value);
	}

	public function setChild(child:Alphabet)
	{
		this.child = child;
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
			case 'int' | 'float' | 'percent' | 'string': newValue = type;
			case 'integer': newValue = 'int';
			case 'str': newValue = 'string';
			case 'fl': newValue = 'float';
		}
		type = newValue;
		return type;
	}
}