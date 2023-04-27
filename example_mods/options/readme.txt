Put your custom json options here
Place them inside folders with the name of the class where you want to use them
(Check Psych Engine's official GitHub for options classes names and for the options variables)
Folder name Example: VisualsUISubState

The variables you could and should use are the same of Psych Engine's normal options
If the option name variable is null, the game will use json file name.

For getting the saved option data on lua, you can use: getOptionSave([Variable Name], [If it's a json Option], [The name of the Mod's Option (Mod's Folder)])
For setting its data: setOptionSave([Variable Name], [Value you'd like to set], [If it's a json Option], [The name of the Mod's Option (Mod's Folder)])
To prevent unloaded saved options prefs (Recommended to do this everytime you use any of these callbacks!!): loadJsonOptions([If you'd like to include the main global mods folder], [The names of the Mods' Options' (Mods' Folder) as array])
After setting an option data, it's recommended to save every settings: saveSettings()
Note that:
[If it's a json Option] as default is false (This means you can use these for Normal Options too)
[The name of the Mod's Option (Mod's Folder)] as default is where the whole mod is stored, if you change this, you have the possibility to check other mods prefs too.
[If you'd like to include the main global mods folder] as default is true
Examples:
getOptionSave('downScroll')
getOptionSave('mechanic', true)
getOptionSave('mechanic', true, 'daModFolder')
setOptionSave('mechanic', false, true)
loadJsonOptions(true, {'daModFolder', 'anotherModFolder'})
loadJsonOptions(false)
loadJsonOptions()
