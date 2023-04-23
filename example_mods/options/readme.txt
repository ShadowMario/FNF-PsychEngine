Put your custom json options here
Place them inside folders with the name of the class where you want to use them
(Check Psych Engine's official GitHub for options classes names and for the options variables)
Folder name Example: VisualsUISubState

The variables you could and should use are the same of Psych Engine's normal options
If the option name variable is null, the game will use json file name.

For getting the saved option data on lua, you can use: getOptionSave([Variable Name], [If it's a json Option], [The name of the Mod's Option (Mod's Folder)])
For setting its data: setOptionSave([Variable Name], [Value you'd like to set], [If it's a json Option], [The name of the Mod's Option (Mod's Folder)])
Note that:
[If it's a json Option] as default is false (This means you can use these for Normal Options too)
[The name of the Mod's Option (Mod's Folder)] as default is where the whole mod is stored, if you change this, you have the possibility to check other mods prefs too.
Examples:
getOptionSave('downScroll')
getOptionSave('mechanic', true)
getOptionSave('mechanic', true, 'daModFolder')
setOptionSave('mechanic', false, true)
