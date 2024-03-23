package backend;

class Language
{
	public static var defaultLangName:String = 'English (US)'; //en-US
	#if TRANSLATIONS_ALLOWED
	private static var phrases:Map<String, String> = [];
	#end

	public static function reloadPhrases()
	{
		#if TRANSLATIONS_ALLOWED
		var langFile:String = ClientPrefs.data.language;
		var loadedText:Array<String> = Mods.mergeAllTextsNamed('data/$langFile.lang');
		//trace(loadedText);

		phrases.clear();
		var hasPhrases:Bool = false;
		for (num => phrase in loadedText)
		{
			phrase = phrase.trim();
			if(num < 1 && !phrase.contains(':'))
			{
				//First line ignores formatting and shit if the line doesn't have ":" because its language_name
				phrases.set('language_name', phrase.trim());
				continue;
			}

			if(phrase.length < 4 || phrase.startsWith('//')) continue; 

			var n:Int = phrase.indexOf(':');
			if(n < 0) continue;

			var key:String = phrase.substr(0, n).trim().toLowerCase();

			var value:String = phrase.substr(n);
			n = value.indexOf('"');
			if(n < 0) continue;

			//trace("Mapped to " + key);
			phrases.set(key, value.substring(n+1, value.lastIndexOf('"')));
			hasPhrases = true;
		}

		if(!hasPhrases) ClientPrefs.data.language = ClientPrefs.defaultData.language;
		#end
	}

	inline public static function getPhrase(key:String, ?defaultPhrase:String, values:Array<Dynamic> = null):String
	{
		#if TRANSLATIONS_ALLOWED
		//trace(formatKey(key));
		var str:String = phrases.get(formatKey(key));
		if(str == null) str = defaultPhrase;
		#else
		var str:String = defaultPhrase;
		#end

		if(str == null)
			str = key;
		
		if(values != null)
			for (num => value in values)
				str = str.replace('{${num+1}}', value);

		return str;
	}

	// More optimized for file loading
	inline public static function getFileTranslation(key:String)
	{
		var str:String = phrases.get(key.trim().toLowerCase());
		if(str != null) key = str;
		return key;
	}
	
	#if TRANSLATIONS_ALLOWED
	inline static private function formatKey(key:String)
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var key = invalidChars.split(key.replace(' ', '_')).join('');
		key = hideChars.split(key).join("").toLowerCase().trim().replace(':', '');
		return key;
	}
	#end
}