package options.screens;

import flixel.FlxG;
import flixel.math.FlxMath;
import sys.FileSystem;

using StringTools;

class NotesMenu extends OptionScreen
{
    public function new() {
        super("Options > Customization");
    }
	public override function create()
	{
		options = [
            {
                name: "Customize HUD",
                desc: "Customize HUD Settings such as the Score Bar appearance, or the timer.",
                value: "",
                onSelect: function(spr) {
                    doFlickerAnim(curSelected, function() {FlxG.switchState(new GUIMenu());});
                }
            },
			{
				name: "Glow CPU strums",
				desc: "If enabled, CPU strums will glow when they hit a note, like the player ones.",
				value: "",
				additional: true,
				onCreate: function(e)
				{
					e.check(Settings.engineSettings.data.glowCPUStrums);
				},
				onSelect: function(e)
				{
					e.check(Settings.engineSettings.data.glowCPUStrums = !Settings.engineSettings.data.glowCPUStrums);
				}
			},
			{
				name: "Apply colors on everyone",
				desc: "If enabled, your note colors will be applied on every characters. Defaults to off.",
				value: "",
				additional: true,
				onCreate: function(e)
				{
					e.check(Settings.engineSettings.data.customArrowColors_allChars);
				},
				onSelect: function(e)
				{
					e.check(Settings.engineSettings.data.customArrowColors_allChars = !Settings.engineSettings.data.customArrowColors_allChars);
				}
			},
			{
				name: "Customize Note Colors",
				desc: "Select this to open the Color Customisation Menu.",
				value: "",
				onSelect: function(e)
				{
					doFlickerAnim(curSelected, function()
					{
						FlxG.switchState(new OptionsNotesColors());
					});
				}
			},
			{
				name: "Enable Note Motion Blur",
				desc: "If enabled, a blur effect will be applied to scrolling notes, making them seem smoother, at cost of performance.",
				value: "",
				additional: true,
				onCreate: function(e)
				{
					e.check(Settings.engineSettings.data.noteMotionBlurEnabled);
				},
				onSelect: function(e)
				{
					e.check(Settings.engineSettings.data.noteMotionBlurEnabled = !Settings.engineSettings.data.noteMotionBlurEnabled);
				}
			},
			{
				name: "Blur Multiplier",
				desc: "How blurry the notes should be. Defaults to 1.",
				value: "",
				additional: true,
				onCreate: function(e)
				{
					e.value = '${Settings.engineSettings.data.noteMotionBlurMultiplier}';
				},
				onLeft: function(e)
				{
					e.value = '${Settings.engineSettings.data.noteMotionBlurMultiplier}';
				},
				onUpdate: function(e)
				{
					if (controls.LEFT_P)
						Settings.engineSettings.data.noteMotionBlurMultiplier -= 0.1;
					if (controls.RIGHT_P)
						Settings.engineSettings.data.noteMotionBlurMultiplier += 0.1;
					Settings.engineSettings.data.noteMotionBlurMultiplier = FlxMath.bound(FlxMath.roundDecimal(Settings.engineSettings.data.noteMotionBlurMultiplier,
						1), 0.1, 10);
					e.value = '< ${Settings.engineSettings.data.noteMotionBlurMultiplier} >';
				}
			},
			{
				name: "Enable Splashes",
				desc: "If enabled, will show splashes everytime you hit a Sick! rating, like in Week 7.",
				value: "",
				onCreate: function(e)
				{
					e.check(Settings.engineSettings.data.splashesEnabled);
				},
				onSelect: function(e)
				{
					e.check(Settings.engineSettings.data.splashesEnabled = !Settings.engineSettings.data.splashesEnabled);
				}
			},
			{
				name: "Splashes Opacity",
				desc: "How opaque the splashes should be. 0% means invisible and 100% means fully opaque. Defaults to 80%",
				value: "",
				additional: true,
				onCreate: function(e)
				{
					e.value = '${Settings.engineSettings.data.splashesAlpha * 100}%';
				},
				onLeft: function(e)
				{
					e.value = '${Settings.engineSettings.data.splashesAlpha * 100}%';
				},
				onUpdate: function(e)
				{
					if (controls.LEFT_P)
						Settings.engineSettings.data.splashesAlpha -= 0.1;
					if (controls.RIGHT_P)
						Settings.engineSettings.data.splashesAlpha += 0.1;
					Settings.engineSettings.data.splashesAlpha = FlxMath.bound(FlxMath.roundDecimal(Settings.engineSettings.data.splashesAlpha, 1), 0.1, 1);
					e.value = '< ${Settings.engineSettings.data.splashesAlpha * 100}% >';
				}
			}
		];

		function getSkinName(name:String)
		{
			if (name == "default")
				return "None";
			else
				return name;
		}

		if (sys.FileSystem.exists(Paths.getSkinsPath() + "/notes/"))
		{
			var skins:Array<String> = [];
			skins.insert(0, "default");
			var sPath = Paths.getSkinsPath();
			for (f in FileSystem.readDirectory('$sPath/notes/'))
			{
				if (f.endsWith(".png") && !FileSystem.isDirectory('$sPath/notes/$f'))
				{
					var skinName = f.substr(0, f.length - 4);
					if (FileSystem.exists('$sPath/notes/$skinName.xml'))
					{
						skins.push(skinName);
					}
				}
			}

			if (skins.indexOf(Settings.engineSettings.data.customArrowSkin) == -1)
				Settings.engineSettings.data.customArrowSkin = "default";
			var pos:Int = skins.indexOf(Settings.engineSettings.data.customArrowSkin);

			options.push({
				name: "Note skin",
				desc: "Select a Note skin from your skins folder.",
				onLeft: function(o)
				{
					o.value = getSkinName(Settings.engineSettings.data.customArrowSkin);
				},
				onUpdate: function(o)
				{
					if (controls.RIGHT_P)
						pos++;
					if (controls.LEFT_P)
						pos++;
					pos %= skins.length;
					if (pos < 0)
						pos = skins.length + pos;

					Settings.engineSettings.data.customArrowSkin = skins[pos];
					o.value = '< ${getSkinName(Settings.engineSettings.data.customArrowSkin)} >';
				},
				value: getSkinName(Settings.engineSettings.data.customArrowSkin)
			});
		}

		var bfSkins:Array<String> = [
			for (s in FileSystem.readDirectory(Paths.getSkinsPath() + "/bf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/bf/$s')) s
		];
		bfSkins.insert(0, "default");
		bfSkins.remove("template");

		if (bfSkins.indexOf(Settings.engineSettings.data.customBFSkin) == -1)
			Settings.engineSettings.data.customBFSkin = "default";
		var posBF:Int = bfSkins.indexOf(Settings.engineSettings.data.customBFSkin);
		options.push({
			name: "Boyfriend skin",
			desc: "Select a Boyfriend skin from a mod, or from your skins folder.",
			onLeft: function(o)
			{
				o.value = getSkinName(Settings.engineSettings.data.customBFSkin);
			},
			onUpdate: function(o)
			{
				if (controls.RIGHT_P)
					posBF++;
				if (controls.LEFT_P)
					posBF++;
				posBF %= bfSkins.length;
				if (posBF < 0)
					posBF = bfSkins.length + posBF;

				Settings.engineSettings.data.customBFSkin = bfSkins[posBF];
				o.value = '< ${getSkinName(Settings.engineSettings.data.customBFSkin)} >';
			},
			value: getSkinName(Settings.engineSettings.data.customBFSkin)
		});

		var gfSkins:Array<String> = [
			for (s in sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/gf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/gf/$s')) s
		];
		gfSkins.insert(0, "default");
		gfSkins.remove("template");

		var posGF:Int = gfSkins.indexOf(Settings.engineSettings.data.customGFSkin);

		if (gfSkins.indexOf(Settings.engineSettings.data.customGFSkin) == -1)
			Settings.engineSettings.data.customGFSkin = "default";

		options.push({
			name: "Girlfriend skin",
			desc: "Select a Girlfriend skin from a mod, or from your skins folder.",
			onLeft: function(o)
			{
				o.value = getSkinName(Settings.engineSettings.data.customGFSkin);
			},
			onUpdate: function(o)
			{
				if (controls.RIGHT_P)
					posGF++;
				if (controls.LEFT_P)
					posGF++;
				posGF %= gfSkins.length;
				if (posGF < 0)
					posGF = gfSkins.length + posGF;

				Settings.engineSettings.data.customGFSkin = gfSkins[posGF];
				o.value = '< ${getSkinName(Settings.engineSettings.data.customGFSkin)} >';
			},
			value: getSkinName(Settings.engineSettings.data.customGFSkin)
		});

		super.create();
	}
}
