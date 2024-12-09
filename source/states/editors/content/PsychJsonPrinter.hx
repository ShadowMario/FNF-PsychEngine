package states.editors.content;

import haxe.format.JsonPrinter;

 /**
  *  Used to print V-Slice charts and other things with a bit less characters
  *  This helps with readability in my opinion
  *      -Shadow Mario
  */

class PsychJsonPrinter extends JsonPrinter
{
	var _ignoreTab:Array<String> = [];
	public static function print(o:Dynamic, ?ignoreTab:Array<String>):String
	{
		var printer = new PsychJsonPrinter(null, '\t');
		if(ignoreTab != null) printer._ignoreTab = ignoreTab;
		printer.write("", o);
		return printer.buf.toString();
	}

	var _singleLineCheckNext:Bool = false;
	override function fieldsString(v:Dynamic, fields:Array<String>)
	{
		fieldsStringEx(v, fields);
	}

	function fieldsStringEx(v:Dynamic, fields:Array<String>, ?mapCheck:Bool = false)
	{
		addChar('{'.code);
		var len = fields.length;
		var last = len - 1;

		var hasArrayInsideIt:Bool = false;
		if(_singleLineCheckNext)
		{
			for (subv in Reflect.fields(v))
			{
				switch(Type.typeof(subv))
				{
					case TObject, TClass(Array):
						hasArrayInsideIt = true;
						break;
					default:
				}
			}
		}

		var usedMapCheck:Bool = false;
		var first = true;
		for (i in 0...len) {
			var f = fields[i];
			var value = Reflect.field(v, f);
			if (Reflect.isFunction(value))
				continue;
			if (first)
			{
				nind++;
				first = false;
			}
			else
			{
				addChar(','.code);
				if(_singleLineCheckNext && !hasArrayInsideIt) addChar(' '.code);
			}

			var _mapCheck = mapCheck;
			if(_mapCheck)
			{
				switch(Type.typeof(value))
				{
					case TObject, TClass(Array), TClass(haxe.ds.StringMap):
						usedMapCheck = true;
					default:
						_mapCheck = false;
				}
			}

			if(!_singleLineCheckNext || hasArrayInsideIt || _mapCheck || usedMapCheck)
			{
				newl();
				ipad();
			}
			quote(f);
			addChar(':'.code);
			if (pretty)
				addChar(' '.code);

			var doContain:Bool = _ignoreTab.contains(f);
			if(doContain) _singleLineCheckNext = true;
			write(f, value);
			if(doContain) _singleLineCheckNext = false;

			if (i == last) {
				nind--;
				if(!_singleLineCheckNext)
				{
					newl();
					ipad();
				}
			}
		}
		if(hasArrayInsideIt || usedMapCheck)
		{
			newl();
			ipad();
		}
		addChar('}'.code);
	}

	override function write(k:Dynamic, v:Dynamic) {
		if (replacer != null)
			v = replacer(k, v);
		switch (Type.typeof(v)) {
			case TUnknown:
				add('"???"');
			case TObject:
				objString(v);
			case TInt:
				add(#if (jvm || hl) Std.string(v) #else v #end);
			case TFloat:
				add(Math.isFinite(v) ? Std.string(v) : 'null');
			case TFunction:
				add('"<fun>"');
			case TClass(c):
				if (c == String)
					quote(v);
				else if (c == Array) {
					var v:Array<Dynamic> = v;
					addChar('['.code);

					var len = v.length;
					var last = len - 1;

					var hasArrayInsideIt:Bool = false;
					if(_singleLineCheckNext)
					{
						for (subv in v)
						{
							switch(Type.typeof(subv))
							{
								case TObject, TClass(Array):
									hasArrayInsideIt = true;
									break;
								default:
							}
						}
					}

					for (i in 0...len) {
						if (i > 0)
						{
							addChar(','.code);
							if(_singleLineCheckNext && !hasArrayInsideIt) addChar(' '.code);
						}
						else nind++;

						if(!_singleLineCheckNext || hasArrayInsideIt)
						{
							newl();
							ipad();
						}

						write(i, v[i]);
						if (i == last) {
							nind--;
							if(!_singleLineCheckNext)
							{
								newl();
								ipad();
							}
						}
					}
					if(hasArrayInsideIt)
					{
						newl();
						ipad();
					}
					addChar(']'.code);
				} else if (c == haxe.ds.StringMap) {
					var v:haxe.ds.StringMap<Dynamic> = v;
					var o = {};
					for (k in v.keys())
						Reflect.setField(o, k, v.get(k));
					fieldsStringEx(o, Reflect.fields(o), true);
				} else if (c == Date) {
					var v:Date = v;
					quote(v.toString());
				} else
					classString(v);
			case TEnum(_):
				var i = Type.enumIndex(v);
				add(Std.string(i));
			case TBool:
				add(#if (php || jvm || hl) (v ? 'true' : 'false') #else v #end);
			case TNull:
				add('null');
		}
	}
}