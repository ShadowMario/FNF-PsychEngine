package;

import lime.utils.Assets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

#if desktop
import Discord.DiscordClient;
#end

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class CreditsState extends MusicBeatState
{
	// Title, Variable, Description, Color
	private static var titles(default, never):Array<Array<String>> = [
		['Credits Sections'],
		['Psych Engine Team',				'psych',			'Developers of Psych Engine',																	'D662EB'],
		["Funkin' Crew",					'funkin',			'The only cool kickers of Friday Night Funkin\'',												'FD40AB'],
		['']
	];

	// Name - Icon name - Description - Link - BG Color
	private static var psych(default, never):Array<Array<String>> = [
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',								'https://twitter.com/Shadow_Mario_',		'444444'],
		['RiverOaken',			'river',			'Main Artist/Animator of Psych Engine',							'https://twitter.com/RiverOaken',			'B42F71'],
		['shubs',				'shubs',			'Additional Programmer of Psych Engine',						'https://twitter.com/yoshubs',				'5E99DF'],
		[''],
		['Former Engine Members'],
		['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',								'https://twitter.com/bbsub3',				'3E813A'],
		[''],
		['Engine Contributors'],
		['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',		'https://twitter.com/flicky_i',				'9E29CF'],
		['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform',	'https://twitter.com/gedehari',				'E1843A'],
		['EliteMasterEric',		'mastereric',		'Runtime Shaders support',										'https://twitter.com/EliteMasterEric',		'FFBD40'],
		['Gabriela',			'gabriela',			'Playback Rate Modifier\nand other PRs',						'https://twitter.com/BeastlyGabi',			'5E99DF'],
		['PolybiusProxy',		'proxy',			'MP4 Video Loader Library (hxCodec)',							'https://twitter.com/polybiusproxy',		'DCD294'],
		['KadeDev',				'kade',				'Fixed some cool stuff on Chart Editor\nand other PRs',			'https://twitter.com/kade0912',				'64A250'],
		['Keoiki',				'keoiki',			'Note Splash Animations',										'https://twitter.com/Keoiki_',				'D2D2D2'],
		['Nebula the Zorua',	'nebula',			'LUA JIT Fork and some Lua reworks',							'https://twitter.com/Nebula_Zorua',			'7D40B2'],
		['Smokey',				'smokey',			'Sprite Atlas Support',											'https://twitter.com/Smokey_5_',			'483D92'],
		['Raltyro',				'raltyro',			'Bunch of lua fixes',											'https://twitter.com/raltyro',				'F3F3F3'],
		['UncertainProd',		'prod',				'Sampler2D in Runtime Shaders',									'https://github.com/UncertainProd',			'D2D2D2'],
		['ACrazyTown',			'acrazytown',		'Optimized PNGs',												'https://twitter.com/acrazytown',			'A03E3D'],
	];

	private static var funkin(default, never):Array<Array<String>> = [
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",							'https://twitter.com/ninja_muffin99',		'F73838'],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",								'https://twitter.com/PhantomArcade3K',		'FFBB1B'],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",								'https://twitter.com/evilsk8r',				'53E52C'],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",								'https://twitter.com/kawaisprite',			'6475F3']
	];
	
	public static var prevSelected:Int = 0;
	public var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var sections:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var descBox:AttachedSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var offsetThing:Float = -75;

	override function create() {
		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (title in titles)
			sections.push(title);

		#if MODS_ALLOWED
		var activeMods = Paths.getActiveModDirectories(true);
		pushModCredits();
		for (mod in activeMods)
			pushModCredits(mod);

		if (modCredits.length > 0) {
			sections.push(['Mod Credits Sections']);
			modSectionsBound = sections.length;
		}
		for (mod in modCredits)
			sections.push(mod);
		#end

		if (curSelected > sections.length || curSelected < 0)
			curSelected = -1;

		for (i in 0...sections.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 335, sections[i][0], true);
			optionText.isMenuItem = true;
			optionText.changeX = false;
			optionText.targetY = i;
			optionText.alignment = CENTERED;
			
			optionText.distancePerItem.y /= 1.2;
			
			if (!isSelectable)
				optionText.startPosition.y -= 47;
			
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable && curSelected == -1)
				curSelected = i;
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);
		
		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume = CoolUtil.boundTo(FlxG.sound.music.volume + (.5 * elapsed), 0, .7);

		if(!quitting)
		{
			if(sections.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (sections[curSelected][1] != null)) {
				if(colorTween != null)
					colorTween.cancel();
				
				CreditSectionState.curCSection = sections[curSelected][1];
				
				#if MODS_ALLOWED
				CreditSectionState.CSectionisMod = modSectionsBound > 0 && curSelected >= modSectionsBound;
				#else
				CreditSectionState.CSectionisMod = false;
				#end
				
				prevSelected = curSelected;
				MusicBeatState.switchState(new CreditSectionState());
				quitting = true;
			}

			if (controls.BACK)
			{
				if(colorTween != null)
					colorTween.cancel();

				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		/*
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
		for (item in grpOptions.members) {
			var lastX:Float = item.x;
			item.screenCenter(X);
			item.x = FlxMath.lerp(lastX, CoolUtil.boundTo(item.x - (item.targetY * (item.targetY / 4) * 100) - 70, -1280, 9999), lerpVal);
			item.forceX = item.x;
		}
		*/

		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = sections.length - 1;
			if (curSelected >= sections.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = sections[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 30;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 45}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private static var modDescription = 'Credits Section for the mod "%s"';
	private var modSectionsBound:Int = -1;

	private var modCredits:Array<Array<String>> = [];
	function pushModCredits(?folder:String = null):Void {
		var creditsFile:String = Paths.mods((folder != null ? folder + '/' : '') + 'data/credits.txt');
		if (!FileSystem.exists(creditsFile)) return;

		var arr:Array<String> = File.getContent(creditsFile).split('\n');
		if (arr.length > 0) {
			var metadata = new ModsMenuState.ModMetadata(folder);
			var name:String = metadata.name;
			var color:FlxColor = metadata.color;
			
			modCredits.push([name, folder, modDescription.replace('%s', name), color.toHexString(false, false)]);
		}
	}
	#end

	function getCurrentBGColor() {
		if (sections.length <= 0 || sections[curSelected] == null || sections[curSelected][3] == null) return 0x0;
		var bgColor:String = sections[curSelected][3];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return sections[num].length <= 1;
	}
}

class CreditSectionState extends MusicBeatState {
	public static var curCSection:String = 'psych';
	public static var CSectionisMod:Bool = false;
	
	var curSelected:Int = -1;
	var prevModDir:String;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end
		prevModDir = Paths.currentModDirectory;
		persistentUpdate = true;

		initializeList();
		if (CSectionisMod) Paths.currentModDirectory = curCSection;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var prefix:String = CSectionisMod ? '' : curCSection + '/';
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.distancePerItem.y /= 1.1;
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
					Paths.currentModDirectory = creditsStuff[i][5];

				var icon:HealthIcon = new HealthIcon(false, true);
				if (!icon.changeIcon(creditsStuff[i][1], curCSection, false))
					icon.changeIcon(creditsStuff[i][1], getSimilarIcon(creditsStuff[i][1]));

				icon.iconOffsets[1] = -30;
				icon.updateHitbox();
				icon.sprTracker = optionText;
				icon.ID = i;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = CSectionisMod ? curCSection : '';

				if(curSelected == -1) curSelected = i;
			}
			else {
				optionText.startPosition.y -= 28;
				optionText.alignment = CENTERED;
			}
			optionText.snapToPosition();
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume = CoolUtil.boundTo(FlxG.sound.music.volume + (.5 * elapsed), 0, .7);

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}

			if(controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				
				var state:CreditsState = new CreditsState();
				state.curSelected = CreditsState.prevSelected;
				MusicBeatState.switchState(state);
				quitting = true;
			}
		}

		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}

		/*
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
		for (item in grpOptions.members) {
			var lastX:Float = item.x;
			item.screenCenter(X);
			item.x = FlxMath.lerp(lastX, CoolUtil.boundTo(item.x - (item.targetY * (item.targetY / 4) * 100) - 70, -1280, 9999), lerpVal);
			item.forceX = item.x;
		}
		*/

		super.update(elapsed);
	}

	override function destroy() {
		Paths.currentModDirectory = prevModDir;
		super.destroy();
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 30;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 45}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function initializeList() {
		#if MODS_ALLOWED
		if (CSectionisMod) initializeModList(curCSection);
		#end

		if (!CSectionisMod) {
			var dyn:Dynamic = Reflect.field(CreditsState, curCSection);
			var field:Array<Array<String>> = null;
			if (Std.isOfType(dyn, Array)) {
				field = cast dyn;
				if (field == null || field.length <= 0 || !Std.isOfType(field[0], Array) || !Std.isOfType(field[0][0], String))
					field = null;
			}

			if (field == null || field.length <= 0) {
				switchToDefaultSection();
				field = cast Reflect.field(CreditsState, curCSection);
			}

			for (v in field)
				creditsStuff.push(v);
		}
	}

	#if MODS_ALLOWED
	function initializeModList(?folder:String = null) {
		var creditsFile:String = Paths.mods((folder != null ? folder + '/' : '') + 'data/credits.txt');
		if (!FileSystem.exists(creditsFile)) return switchToDefaultSection();

		var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
		for (v in firstarray) {
			var arr:Array<String> = v.replace('\\n', '\n').split("::");
			if(arr.length >= 5) arr.push(folder);
			creditsStuff.push(arr);
		}
		if (creditsStuff.length <= 0) return switchToDefaultSection();
	}
	#end

	function switchToDefaultSection() {
		curCSection = 'psych';
		CSectionisMod = false;
	}

	function getSimilarIcon(icon:String):String {
		@:privateAccess var titles = CreditsState.titles;

		var section:Array<String>;
		var v:String;
		for (i in 0...titles.length) {
			section = titles[i];
			if (section.length <= 1 || section[1] == 'mod') continue;

			v = section[1];

			var dyn:Dynamic = Reflect.field(CreditsState, v);
			var field:Array<Array<String>> = null;
			if (Std.isOfType(dyn, Array)) {
				field = cast dyn;
				if (field == null || field.length <= 0 || !Std.isOfType(field[0], Array) || !Std.isOfType(field[0][0], String))
					field = null;
			}
			if (field == null || field.length <= 0) continue;

			for (i in 0...field.length)
				if (icon == field[i][1] && HealthIcon.returnGraphic(icon, v, false, true) != null) return v;
		}

		return null;
	}

	function getCurrentBGColor() {
		if (creditsStuff.length <= 0 || creditsStuff[curSelected] == null || creditsStuff[curSelected][4] == null) return 0x0;
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
