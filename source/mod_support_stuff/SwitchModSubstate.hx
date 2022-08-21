package mod_support_stuff;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.utils.Assets;
import flixel.math.FlxMath;

class SwitchModSubstate extends MusicBeatSubstate {
    var mods:Array<SwitchMod> = [];
    var selected:Int = 0;

    var medalsPercentageLerp:Float = 0;
    var unlockedMedals:Int = 0;
    var totalMedals:Int = 0;
    var medalsText:AlphabetOptimized;
    var medalsBG:FlxSprite;
    
    public override function new() {
        super();
    }

    public override function create() {
        super.create();
        cast(add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xAA222222)), FlxSprite).scrollFactor.set(0, 0);

        var i:Int = 0;
        var mds:Array<String> = [];
        for(mod=>e in ModSupport.modConfig) {
            mds.push(mod);
        }
        mds.sort(function(a:String, b:String):Int {
            a = ModSupport.getModName(a).toUpperCase();
            b = ModSupport.getModName(b).toUpperCase();
          
            if (a < b)
              return -1;
            else if (a > b)
              return 1;
            else
              return 0;
        });

        selected = mds.indexOf(Settings.engineSettings.data.selectedMod);
        if (selected < 0) selected = 0;

        for(mod in mds) {
            var config = ModSupport.modConfig[mod];
            var mIcon = Paths.getPath('modIcon.png', IMAGE, 'mods/$mod');
            if (!Assets.exists(mIcon)) mIcon = Paths.image("modEmptyIcon", "preload");
            
            var m = new SwitchMod(0, 0, mod, config.name != null ? config.name : mod, mIcon);
            m.alpha = 0.4; // not selected
            mods.push(m);
            add(m);

            i++;
        }

        medalsBG = new FlxSprite(0, FlxG.height - 40).makeGraphic(FlxG.width, 60, 0xFF000000);
        medalsBG.alpha = 0.75;
        medalsBG.scrollFactor.set();
        add(medalsBG);

        medalsText = new AlphabetOptimized(5, FlxG.height - 40, "No medals? *megamind*", false, 0.5);
        medalsText.scrollFactor.set();
        add(medalsText);

        changeSelection(0);
    }

    public override function update(elapsed) {
        super.update(elapsed);
        for(k=>m in mods) {
            m.x = FlxMath.lerp(m.x, 175 + (k - selected) * 25, CoolUtil.wrapFloat(0.16 * 60 * elapsed, 0, 1));
            m.y = FlxMath.lerp(m.y, ((FlxG.height / 2) + (k - selected) * 185) - 75, CoolUtil.wrapFloat(0.16 * 60 * elapsed, 0, 1));
            m.alpha = FlxMath.lerp(m.alpha, ((k == selected) ? 1 : 0.4), CoolUtil.wrapFloat(0.16 * 60 * elapsed, 0, 1));
            
        }
        if (controls.UP_P) changeSelection(-1);
        if (controls.DOWN_P) changeSelection(1);
        if (controls.ACCEPT) {
            switchMod(mods[selected].modDataName);
            return;
        }
        if (controls.BACK) {
            CoolUtil.playMenuSFX(2);
            close();
        }
        if (totalMedals > 0) {
            medalsPercentageLerp = FlxMath.lerp(medalsPercentageLerp, unlockedMedals / totalMedals * 100, FlxMath.bound(0.25 * 60 * elapsed, 0, 1));
            medalsText.text = 'Medals: ${unlockedMedals}/${totalMedals} (${Math.round(medalsPercentageLerp)}%)';
        } else {
            medalsPercentageLerp = 0;
            medalsText.text = 'No medals';
        }
        if (Settings.engineSettings.data.developerMode) {
            medalsText.text += ' | Folder name: ${mods[selected].modDataName}';
        }
    }

    public static function switchMod(mod:String) {
        if (Std.isOfType(FlxG.state, TitleState)) TitleState.initialized = false;
        if (FlxG.sound.music != null) {
            FlxG.sound.music.fadeOut(0.25, 0);
            FlxG.sound.music.persist = false;
        }
        CoolUtil.playMenuSFX(1);
        Settings.engineSettings.data.selectedMod = mod;
        ModSupport.reloadModsConfig(true, true, true);
        lime.utils.Assets.loggedRequests = [];
        MusicBeatState.doCachingShitNextTime = false;
        FlxG.bitmap.clearCache();
        FlxG.resetState();
    }
    public function changeSelection(am:Int) {
        selected += am;
        if (selected < 0) selected = mods.length - 1;
        if (selected >= mods.length) selected = 0;
        if (am != 0) CoolUtil.playMenuSFX(0);

        var medals = ModSupport.modMedals[mods[selected].modDataName];
        if (medals == null || medals.medals == null)
            unlockedMedals = totalMedals = 0;
        else {
            unlockedMedals = 0;
            totalMedals = medals.medals.length;
            var states = Medals.__getStates(mods[selected].modDataName);
            for(m in medals.medals)
                if (states[m.name] == UNLOCKED)
                    unlockedMedals++;
        }
    }
}