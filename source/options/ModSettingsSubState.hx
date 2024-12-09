package options;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import objects.Character;

import options.Option.OptionType;

class ModSettingsSubState extends BaseOptionsMenu
{
	var save:Map<String, Dynamic> = new Map<String, Dynamic>();
	var folder:String;
	private var _crashed:Bool = false;
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
			save = saveMap[folder] != null ? saveMap[folder] : [];
		}

		//save = []; //reset for debug purposes
		try
		{
			for (option in options)
			{
				var newOption = new Option(
					option.name != null ? option.name : option.save,
					option.description != null ? option.description : 'No description provided.',
					option.save,
					convertType(option.type),
					option.options,
					option.translation_key
				);

				switch(newOption.type)
				{
					case KEYBIND:
						//Defaulting and error checking
						var keyboardStr:String = option.keyboard;
						var gamepadStr:String = option.gamepad;
						if(keyboardStr == null) keyboardStr = 'NONE';
						if(gamepadStr == null) gamepadStr = 'NONE';

						newOption.defaultKeys.keyboard = keyboardStr;
						newOption.defaultKeys.gamepad = gamepadStr;
						if(save.get(option.save) == null)
						{
							newOption.keys.keyboard = newOption.defaultKeys.keyboard;
							newOption.keys.gamepad = newOption.defaultKeys.gamepad;
							save.set(option.save, newOption.keys);
						}

						// getting inputs and checking
						var keyboardKey:FlxKey = cast FlxKey.fromString(keyboardStr);
						var gamepadKey:FlxGamepadInputID = cast FlxGamepadInputID.fromString(gamepadStr);
						//trace('${keyboardStr}: $keyboardKey, ${gamepadStr}: $gamepadKey');

						@:privateAccess
						{
							newOption.getValue = function() {
								var data = save.get(newOption.variable);
								if(data == null) return 'NONE';
								return !Controls.instance.controllerMode ? data.keyboard : data.gamepad;
							};
							newOption.setValue = function(value:Dynamic) {
								var data = save.get(newOption.variable);
								if(data == null) data = {keyboard: 'NONE', gamepad: 'NONE'};

								if(!controls.controllerMode) data.keyboard = value;
								else data.gamepad = value;
								save.set(newOption.variable, data);
							};
						}

					default:
						if(option.value != null)
							newOption.defaultValue = option.value;

						@:privateAccess
						{
							newOption.getValue = function() return save.get(newOption.variable);
							newOption.setValue = function(value:Dynamic) save.set(newOption.variable, value);
						}
				}

				if(option.type != KEYBIND)
				{
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
						if(newOption.type != KEYBIND) newOption.setValue(myValue);
						else newOption.setValue(!Controls.instance.controllerMode ? myValue.keyboard : myValue.gamepad);
					}
					else
					{
						myValue = newOption.getValue();
						if(myValue == null) myValue = newOption.defaultValue;
					}
	
					switch(newOption.type)
					{
						case STRING:
							var num:Int = newOption.options.indexOf(myValue);
							if(num > -1) newOption.curOption = num;

						default:
					}
	
					save.set(option.save, myValue);
				}
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

			_crashed = true;
			close();
			return;
		}

		super();

		bg.alpha = 0.75;
		bg.color = FlxColor.WHITE;
		reloadCheckboxes();
	}

	private function convertType(str:String):OptionType
	{
		switch(str.toLowerCase().trim())
		{
			case 'bool':
				return BOOL;
			case 'int', 'integer':
				return INT;
			case 'float', 'fl':
				return FLOAT;
			case 'percent':
				return PERCENT;
			case 'string', 'str':
				return STRING;
			case 'keybind', 'key':
				return KEYBIND;
		}
		FlxG.log.error("Could not find option type: " + str);
		return BOOL;
	}

	override public function update(elapsed:Float)
	{
		if(_crashed)
		{
			close();
			return;
		}
		super.update(elapsed);
	}

	override public function close()
	{
		FlxG.save.data.modSettings.set(folder, save);
		FlxG.save.flush();
		super.close();
	}
}