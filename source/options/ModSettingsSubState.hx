package options;

import objects.Character;

class ModSettingsSubState extends BaseOptionsMenu
{
	var save:Map<String, Dynamic> = new Map<String, Dynamic>();
	var folder:String;
	public function new(options:Array<Dynamic>, folder:String, name:String)
	{
		this.folder = folder;

		title = '';
		//title = name;
		rpcTitle = 'Mod Settings ($name)'; //for Discord Rich Presence

		if(FlxG.save.data.modSettings == null) FlxG.save.data.modSettings = new Map<String, Dynamic>();
		else
		{
			var saveMap:Map<String, Dynamic> = FlxG.save.data.modSettings;
			save = saveMap[folder];
		}

		try
		{
			for (option in options)
			{
				var newOption = new Option(
					option.name != null ? option.name : option.save,
					option.description != null ? option.description : 'No description provided.',
					option.save,
					option.type,
					option.options
				);

				@:privateAccess
				{
					newOption.getValue = function() return save.get(option.save);
					newOption.setValue = function(value:Dynamic) save.set(option.save, value);
				}

				if(option.value != null) newOption.defaultValue = option.value;
				if(option.format != null) newOption.displayFormat = option.format;
				if(option.min != null) newOption.minValue = option.min;
				if(option.max != null) newOption.maxValue = option.max;
				if(option.step != null) newOption.changeValue = option.step;

				if(option.scroll != null) newOption.scrollSpeed = option.scroll;
				if(option.decimals != null) newOption.decimals = option.decimals;

				var myValue:Dynamic = null;
				if(save.get(option.save) != null)
				{
					myValue = save.get(option.save);
					newOption.setValue(myValue);
				}
				else
				{
					myValue = newOption.getValue();
					if(myValue == null) myValue = newOption.defaultValue;
				}

				if(newOption.type == 'string')
				{
					var num:Int = newOption.options.indexOf(myValue);
					if(num > -1) newOption.curOption = num;
				}

				save.set(option.save, myValue);
				//trace(newOption.getValue());
				addOption(newOption);
				//updateTextFrom(newOption);
			}
		}
		catch(e:Dynamic)
		{
			var errorTitle = 'Mod name: ' + folder;
			var errorMsg = 'An error occurred: $e';
			#if windows
			lime.app.Application.current.window.alert(errorMsg, errorTitle);
			#end
			trace('$errorTitle - $errorMsg');
			close();
			return;
		}

		super();

		bg.alpha = 0.75;
		bg.color = FlxColor.WHITE;
		reloadCheckboxes();
	}

	override public function close()
	{
		FlxG.save.data.modSettings.set(folder, save);
		FlxG.save.flush();
		super.close();
	}
}