package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import Note;
import StrumNote;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{

	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Opponent Note Splashes',
			"If checked, opponent note hits will show particles.",
			'oppNoteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show NPS',
			'If checked, the game will show your current NPS.',
			'showNPS',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Max Splashes: ',
			"How many note splashes should be allowed on screen at the same time?\n(0 means no limit)",
			'maxSplashLimit',
			'int',
			16);

		option.minValue = 0;
		option.maxValue = 50;
		option.displayFormat = '%v Splashes';
		addOption(option);

		var option:Option = new Option('Opponent Note Alpha:',
			"How visible do you want the opponent's notes to be when Middlescroll is enabled? \n(0% = invisible, 100% = fully visible)",
			'oppNoteAlpha',
			'percent',
			0.65);
		option.scrollSpeed = 1.8;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hide ScoreTxt',
			'If checked, hides the score text. Dunno why you would enable this but eh, alright.',
			'hideScore',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Showcase Mode',
			'If checked, hides all the UI elements except for the time bar and notes\nand enables Botplay.',
			'showcaseMode',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Show Maximum Score',
			'If checked, the score text will show the highest score you can achieve\nif you were to have 100% accuracy throughout the song.',
			'showMaxScore',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Time Text Bounce',
			'If checked, the time bar text will bounce on every beat hit.',
			'timeBounce',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('songLength Intro Animation',
			'If checked, the song length will also have an intro animation.',
			'lengthIntro',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Playback Speed on Time Bar',
			'If checked, the timebar will also show the current Playback Speed you are playing at.',
			'timebarShowSpeed',
			'bool',
			false);
		addOption(option);

		/*
		var option:Option = new Option('Cluttered UI',
			'If checked, the UI will be cluttered with tons of unnecessary gameplay elements.',
			'clutterUI',
			'bool',
			false);
		addOption(option);
		*/

		var option:Option = new Option('Results Screen',
			'If unchecked, the results screen will be skipped.',
			'resultsScreen',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Compact UI Numbers',
			'If checked, Score, combo, misses and NPS will be compact.',
			'compactNumbers',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('ScoreTxt Size: ',
			"Sets the size of scoreTxt. Logically, higher values mean\nthe scoreTxt is bigger. If set to 0, then it will\nuse the default size for each HUD type.",
			'scoreTxtSize',
			'int',
			'0');
		addOption(option);

		option.minValue = 0;
		option.maxValue = 100;
		
		/* ignore this i was just making a joke about fnf's naughtiness option
		var option:Option = new Option('Family Friendly Mode',
			'If checked, makes everything family-friendly. Always remember to watch your Ps and Qs!',
			'family',
			'bool',
			false);
		addOption(option);
		*/

		var option:Option = new Option('Color Quantization',
			'If checked, notes are colored based on their quantization.',
			'colorQuants',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Enable Note Colors',
			'If unchecked, notes won\'t be able to use your currently set colors. \nI think this decreases loading time.',
			'enableColorShader',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Note Movement',
			"If checked, note hits will move the camera depending on which note you hit.",
			'cameraPanning',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Pan Intensity:', //Name
			'Changes how much the camera pans when Camera Note Movement is turned on.', //Description
			'panIntensity', //Save data variable name
			'float', //Variable type
			1); //Default value
		option.scrollSpeed = 2;
		option.minValue = 0.01;
		option.maxValue = 10;
		option.changeValue = 0.1;
		option.displayFormat = '%vX';
		addOption(option);

		var option:Option = new Option('Rating Quotes',
			"What should the rating names display?",
			'rateNameStuff',
			'string',
			'Quotes',
			['Quotes', 'Letters', 'Psych Quotes', 'Shaggyverse Quotes']);
		addOption(option);

		var option:Option = new Option('Golden Sick on MFC/SFC',
			'If checked, your Sick! & Marvelous!! ratings will be golden if your FC rating is better than GFC.',
			'goldSickSFC',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Rating Accuracy Color',
			'If checked, the ratings & combo will be colored based on the actual rating.',
			'colorRatingHit',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Rating FC Colors',
			'If checked, the ratings & combo will be colored based on your FC rating.',
			'colorRatingFC',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Marvelous Rating Color:',
			"What should the Marvelous Rating Color be?",
			'marvRateColor',
			'string',
			'Golden',
			['Golden', 'Rainbow']);
		addOption(option);

		var option:Option = new Option('Health Tweening',
			"If checked, the health will adjust smoothly.",
			'smoothHealth',
			'bool',
			true);
		addOption(option);
		
		var option:Option = new Option('Health Tween Type:',
			"What should the Time Bar display?",
			'smoothHealthType',
			'string',
			'Golden Apple 1.5',
			['Golden Apple 1.5', 'Indie Cross']);
		addOption(option);

		var option:Option = new Option('Double Note Ghosts',
			"If this is checked, hitting a Double Note will show an afterimage, just like in VS Impostor!",
			'doubleGhost',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Double Note Ghost Camera Zoom',
			'If unchecked, Double Note Ghosts will not zoom when they activate during gameplay.',
			'doubleGhostZoom',
			'bool',
			true);
		addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Modern Time', 'Song Name + Time', 'Disabled']);
		addOption(option);

		var option:Option = new Option('HUD Type:',
			"Which HUD would you like?",
			'hudType',
			'string',
			'VS Impostor',
			['VS Impostor', 'Kade Engine', 'Tails Gets Trolled V4', 'Dave and Bambi', 'Doki Doki+', 'Psych Engine', 'Leather Engine', 'Box Funkin', "Mic'd Up", 'JS Engine']);
		addOption(option);

		var option:Option = new Option('Note Style:',
			"How would you like your notes to look like? \n(ANY NOTESTYLE OTHER THAN DEFAULT WILL OVERWRITE CHART SETTINGS AS WELL)",
			'noteStyleThing',
			'string',
			'Default',
			['Default', 'VS Nonsense V2', 'VS AGOTI', 'Doki Doki+', 'TGT V4', 'DNB 3D', 'Pink Circles']);
		addOption(option);

		var option:Option = new Option('BF Icon Style:',
			"How would you like your BF Icon to look like?",
			'bfIconStyle',
			'string',
			'Default',
			['Default', 'VS Nonsense V2', 'Leather Engine', 'Doki Doki+']);
		addOption(option);

		var option:Option = new Option('Rating Style:',
			"Which style for the rating popups would you like?",
			'ratingType',
			'string',
			'Base FNF',
			['Base FNF', 'Kade Engine', 'Tails Gets Trolled V4', 'Doki Doki+']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			"Which icon bounce would you like?",
			'iconBounceType',
			'string',
			'Golden Apple',
			['Golden Apple', 'Dave and Bambi', 'Old Psych', 'New Psych', 'VS Steve', 'Plank Engine', 'Strident Crisis']);
		addOption(option);

		var option:Option = new Option('Note Splash Type:',
			"Which note splash would you like?",
			'splashType',
			'string',
			'Psych Engine',
			['Psych Engine', 'VS Impostor', 'Base Game', 'Doki Doki+', 'TGT V4', 'Indie Cross']);
		addOption(option);

		var option:Option = new Option('long ass health bar',
			"If this is checked, the Health Bar will become LOOOOOONG",
			'longHPBar',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Full FC Rating Name',
			'If checked, the FC ratings will use their full name instead of their abbreviated form (so an SFC will become a Sick Full Combo).',
			'longFCName',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Display Health Remaining',
			"If checked, shows how much health you have remaining.",
			'healthDisplay',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Opponent Note Hit Count',
			"If checked, the rating counter will also show how many notes the opponent has hit.",
			'opponentRateCount',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show MS Popup',
			"If checked, hitting a note will also show how late/early you hit it.",
			'showMS',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Use Wrong Popup Camera',
			'If checked, the popups will use the game world camera instead of the HUD.',
			'wrongCameras',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Song Percentage',
			"If checked, you can see text displaying how much\nof the song you've completed.",
			'songPercentage',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('% Decimals: ',
			"The amount of decimals you want for your Song Percentage. (0 means no decimals)",
			'percentDecimals',
			'int',
			2);
		addOption(option);

		option.minValue = 0;
		option.maxValue = 50;
		option.displayFormat = '%v Decimals';

		var option:Option = new Option('Rating Counter',
			"If checked, you can see how many Sicks, Goods, Bads, etc you've hit on the left.",
			'ratingCounter',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Show Notes',
			"If unchecked, the notes will be invisible. You can still play them though!",
			'showNotes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Lane Underlay',
			"If checked, a black line will appear behind the notes, making them easier to read.",
			'laneUnderlay',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Lane Underlay Transparency',
			'How transparent do you want the lane underlay to be? (0% = transparent, 100% = fully opaque)',
			'laneUnderlayAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option('Random Botplay Text',
			"Uncheck this if you don't want to be insulted when\nyou use Botplay.",
			'randomBotplayText',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Botplay Text Fading',
			"If checked, the botplay text will do cool fading.",
			'botTxtFade',
			'bool',
			true);
		addOption(option);
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
				
		var option:Option = new Option('Menu Song:',
			"What song do you prefer when you're in menus?",
			'daMenuMusic',
			'string',
			'Mashup',
			['Mashup', 'Base Game', 'DDTO+', 'Dave & Bambi', 'Dave & Bambi (Old)', 'VS Impostor', 'VS Nonsense V2']);
		addOption(option);
		option.onChange = onChangeMenuMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show RAM Usage',
			"If checked, the game will show your RAM usage.",
			'showRamUsage',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Peak RAM Usage',
			"If checked, the game will show your maximum RAM usage.",
			'showMaxRamUsage',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Debug Info',
			"If checked, the game will show additional debug info.\nNote: Turn on FPS Counter before using this!",
			'debugInfo',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('NPS with Speed in Mind',
			"If unchecked, the NPS won't have Playback Rate in mind.\n(Pretty dumb option to add, if you ask me!\nThat's why this is in the bottom of the Visuals & UI menu!)",
			'npsWithSpeed',
			'bool',
			true);
		addOption(option);


		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	var menuMusicChanged:Bool = false;
	function onChangeMenuMusic()
	{
			if (ClientPrefs.daMenuMusic != 'Mashup') FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.daMenuMusic));
			if (ClientPrefs.daMenuMusic == 'Mashup') FlxG.sound.playMusic(Paths.music('freakyMenu'));
		menuMusicChanged = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.daMenuMusic));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}
