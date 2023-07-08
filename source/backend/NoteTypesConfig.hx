package backend;

import objects.Note;

typedef NoteTypeProperty = {
	property:Array<String>,
	value:Dynamic
}

class NoteTypesConfig
{
	private static var noteTypesData:Map<String, Array<NoteTypeProperty>> = new Map<String, Array<NoteTypeProperty>>();
	public static function clearNoteTypesData()
		noteTypesData.clear();

	public static function loadNoteTypeData(name:String)
	{
		if(noteTypesData.exists(name)) return noteTypesData.get(name);

		var str:String = Paths.getTextFromFile('custom_notetypes/$name.txt');
		if(str == null || !str.contains(':') || !str.contains('=')) noteTypesData.set(name, null);

		var parsed:Array<NoteTypeProperty> = [];
		var lines:Array<String> = CoolUtil.listFromString(str);
		for (line in lines)
		{
			var sep:Int = line.indexOf(':');
			if(sep < 0)
			{
				sep = line.indexOf('=');
				if(sep < 0) continue;
			}

			var arr:Array<String> = line.substr(0, sep).trim().split('.');
			for (i in 0...arr.length) arr[i] = arr[i].trim();

			var newProp:NoteTypeProperty = {
				property: arr,
				value: _interpretValue(line.substr(sep + 1).trim())
			}
			//trace('pushing $newProp');
			parsed.push(newProp);
		}
		noteTypesData.set(name, parsed);
		return parsed;
	}

	public static function applyNoteTypeData(note:Note, name:String)
	{
		var data:Array<NoteTypeProperty> = loadNoteTypeData(name);
		if(data == null || data.length < 1) return;
		
		for (line in data) 
		{
			var obj:Dynamic = note;
			var split:Array<String> = line.property;
			try
			{
				if(split.length <= 1)
				{
					_propCheckArray(obj, split[0], true, line.value);
					continue;
				}

				switch(split[0]) // special cases
				{
					case 'extraData': 
						note.extraData.set(split[1], line.value);
						continue;
					
					case 'noteType':
						continue;
				}

				for (i in 0...split.length-1)
				{
					if(i < split.length-1)
						obj = _propCheckArray(obj, split[i]);
				}
				_propCheckArray(obj, split[split.length-1], true, line.value);
			} catch(e) trace(e);
		}
	}

	private static function _propCheckArray(obj:Dynamic, slice:String, setProp:Bool = false, valueToSet:Dynamic = null)
	{
		var propArray:Array<String> = slice.split('[');
		if(propArray.length > 1)
		{
			for (i in 0...propArray.length)
			{
				var str:Dynamic = propArray[i];
				var id:Int = Std.parseInt(str.substr(0, str.length-1).trim());
				if(i < propArray.length-1) obj = obj[id]; //middles
				else if (setProp) return obj[id] = valueToSet; //last
			}
			return obj;
		}
		else if(setProp)
		{
			//trace('setProp: $slice');
			Reflect.setProperty(obj, slice, valueToSet);
			return valueToSet;
		}
		//trace('getting prop: $slice');
		return Reflect.getProperty(obj, slice);
	}

	private static function _interpretValue(value:String):Any
	{
		if(value.charAt(0) == "'" || value.charAt(0) == '"')
		{
			//is a string
			return value.substring(1, value.length-1);
		}
		
		switch(value)
		{
			case "true":
				return true;
			case "false":
				return false;
			case "null":
				return null;
		}

		if(value.contains('.')) return Std.parseFloat(value);
		return Std.parseInt(value);
	}
}