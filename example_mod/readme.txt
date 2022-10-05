To make a new mod, you need to create a copy of this example_mod folder, put into the mods folder,
such that there will be mods/<folder_name>/pack.json. This example mod won’t show up in the mod selection
menu, nor be loaded by the engine.

You can either edit files or add entirely new ones here.

ABOUT EDITTING:
It doesn't matter if you want to edit something in assets/shared/images/ or assets/preload/images/,
you will have to put the editted files in mods/images/, it will be handled automatically by the engine.

Bundling the engine:
If you want to bundle the engine with your mod (that is, you also include Psych Engine code, instead of
just the folder with your mod (the one with pack.json)), you can create a file named “disable_mods_menu.txt”
in the same folder that PsychEngine.exe is. This will hide the mod menu. If you need to disable a mod, or
change load order, you can either manually change “modsList.txt”, or temporally remove “disable_mods_menu.txt”.