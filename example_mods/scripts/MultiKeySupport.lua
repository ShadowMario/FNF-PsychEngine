-- Code by @BombasticTom#0646
-- Additional help by @Mayo78#2194
-- Thanks @raltyro#1324 for helping with custom key binds

local keysArray = {};
local goofyAhhSus = {};

local stupidKeyArray = { -- Change your KeyBinds here:
	[1] = { -- Mania Type (6K)
        {'S', 'ONE'}, -- Primary, Secondary Key
        {'D', 'TWO'},
        {'F', 'THREE'},
        {'J', 'FOUR'},
        {'K', 'FIVE'},
        {'L', 'SIX'}
    },
	[2] = { -- Mania Type (7K)
        {'S', 'ONE'}, -- Primary, Secondary Key
        {'D', 'TWO'},
        {'F', 'THREE'},
        {'SPACE', 'FOUR'},
        {'J', 'FIVE'},
        {'K', 'SIX'},
        {'L', 'SEVEN'}
	},
	[3] = { -- Mania Type (9K)
        {'A', 'ONE'}, -- Primary, Secondary Key
        {'S', 'TWO'},
        {'D', 'THREE'},
        {'F', 'FOUR'},
        {'SPACE', 'FIVE'},
        {'H', 'SIX'},
        {'J', 'SEVEN'},
        {'K', 'EIGHT'},
        {'L', 'NINE'}
	},
	[4] = { -- Mania Type (8K) UNSUPPORTED!
        {'A', 'ONE'}, -- Primary, Secondary Key
        {'S', 'TWO'},
        {'D', 'THREE'},
        {'F', 'FOUR'},
        {'H', 'FIVE'},
        {'J', 'SIX'},
        {'K', 'SEVEN'},
        {'L', 'EIGHT'}
	}
};

function returnKeyBinds(mania)
    return stupidKeyArray[mania];
end

function setupKeyBinds(mania)

	local stupidVarOMGGGG = {
		['ONE'] = '1',
		['TWO'] = '2',
		['THREE'] = '3',
		['FOUR'] = '4',
		['FIVE'] = '5',
		['SIX'] = '6',
		['SEVEN'] = '7',
		['EIGHT'] = '8',
		['NINE'] = '9',
		['ZERO'] = '0',
		['SPACE'] = 32
	}

	local string = ''

	for number, item in pairs(stupidKeyArray[mania]) do
		string = string .. '['
		for subItem=1, #item do
			if stupidVarOMGGGG[item[subItem]] then item[subItem] = stupidVarOMGGGG[item[subItem]] end

			if type(item[subItem]) == 'string' then string = string .. string.byte(item[subItem])
			else string = string .. item[subItem] end

			if subItem < #item then 
				string = string .. ', '
			end
		end
		
		string = string .. ']'

		if number < #stupidKeyArray[mania] then 
			string = string .. ', '
		end
	end

	return string;
end

function onCreatePost()

	luaDebugMode = true;

	addHaxeLibrary('Song')
	addHaxeLibrary('CoolUtil')
	addHaxeLibrary('Math')
	addHaxeLibrary('Conductor')
	addHaxeLibrary('FlxMath', 'flixel.math')
	addHaxeLibrary('ClientPrefs')

	runHaxeCode([[
		var shit = '-' + game.storyDifficultyText;
		if (shit == '-Normal' || shit == null)
		{
			shit = '';
		}

		var mania = Song.loadFromJson(']]..songName..[[' + shit, ']]..songName..[[').mania;
		if (mania == null) {
			mania = -1;
		}

		game.setOnLuas('mania', mania);

	]])

	--debugPrint(mania)

	if (mania > 0) and (mania < 4) then -- this checks if you're playing a multi key chart

		setProperty('ratingsData[0].noteSplash', false)
  		setProperty('ratingsData[1].noteSplash', false)
  		setProperty('ratingsData[2].noteSplash', false)
  		setProperty('ratingsData[3].noteSplash', false)

		keysArray = returnKeyBinds(mania);
		for key=1, #keysArray do
			table.insert(goofyAhhSus, false);
		end

		for dingus=0, getProperty('unspawnNotes.length') - 1 do
			removeFromGroup('unspawnNotes', 0);
		end

		runHaxeCode([[

			var maniaNotes = [
				['singLEFT', 'singUP', 'singRIGHT', 'singLEFT', 'singDOWN', 'singRIGHT'],
				['singLEFT', 'singUP', 'singRIGHT', 'singUP', 'singLEFT', 'singDOWN', 'singRIGHT'],
				['singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singUP', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'],
			];

			var noteShit = [6, 7, 9, 8];

			var scales = [0.6, 0.6, 0.46, 0.55];

			var shit = '-' + game.storyDifficultyText;
			if (shit == '-Normal' || shit == null)
			{
				shit = '';
			}

			var songData = Song.loadFromJson(']]..songName..[[' + shit, ']]..songName..[[');
			var currentSong = songData.song;
			var noteData = songData.notes;
			var mania = songData.mania;
			if (mania == null) {
				mania = 0;
			}

			if (mania > 0) {

				game.keysArray = [
					]]..setupKeyBinds(mania)..[[
				];

				game.singAnimations = maniaNotes[mania-1];
			}

			for (section in noteData)
			{
				for (songNotes in section.sectionNotes)
				{
					var strumTime = songNotes[0];
					var noteData = songNotes[1] % noteShit[mania - 1];

					var gottaHitNote = section.mustHitSection;

					if (songNotes[1] > noteShit[mania - 1] - 1 && mania != 4)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote = 0;
					if (game.unspawnNotes.length > 0)
						oldNote = game.unspawnNotes[game.unspawnNotes.length - 1];
					else
						oldNote = null;

					var swagNote = new Note(strumTime, noteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.gfNote = (section.gfSection && (songNotes[1] < noteShit[mania - 1]));
					swagNote.noteType = songNotes[3];

					swagNote.scrollFactor.set();
					var susLength = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					swagNote.ID = game.unspawnNotes.length;
					game.unspawnNotes.push(swagNote);

					var floorSus = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = game.unspawnNotes[game.unspawnNotes.length - 1];
							
							var sustainNote = new Note(strumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(game.songSpeed, 2)), noteData, oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.gfNote = swagNote.gfNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.ID = game.unspawnNotes.length;
							sustainNote.scrollFactor.set();
							swagNote.tail.push(sustainNote);
							sustainNote.parent = swagNote;
							game.unspawnNotes.push(sustainNote);

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
							else if(ClientPrefs.middleScroll)
							{
								sustainNote.x += 310;
								if(noteData > 1) //Up and Right
								{
									sustainNote.x += FlxG.width / 2 + 25;
								}
							}

							sustainNote.setGraphicSize(sustainNote.width / 0.7 * scales[]].. mania-1 ..[[], sustainNote.height);
							sustainNote.updateHitbox();
						}
					}

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else if(ClientPrefs.middleScroll)
					{
						swagNote.x += 310;
						if(noteData > 1) //Up and Right
						{
							swagNote.x += FlxG.width / 2 + 25;
						}
					}

					/*if(!noteTypeMap.exists(swagNote.noteType)) {
						noteTypeMap.set(swagNote.noteType, true);
					}*/

					swagNote.setGraphicSize(swagNote.width / 0.7 * scales[]].. mania - 1 ..[[]);
					swagNote.updateHitbox();
				}
			}

			game.unspawnNotes.sort(game.sortByShit);
		]]);

		postAdded();
	end
end

function postAdded()
		destroyStaticArrows();
		generateStaticArrows(0, mania);
		generateStaticArrows(1, mania);

		runHaxeCode([[
			var stupidAdjusting = [
				'purple', 'blue', 'green', 'red'
			];

			var colorList = [
				['purple', 'green', 'red', 'F', 'blue', 'I'],
				['purple', 'green', 'red', 'white', 'F', 'blue', 'I'],
				['purple', 'blue', 'green', 'red', 'white', 'F', 'G', 'H', 'I'],
				['purple', 'blue', 'green', 'red', 'purple', 'blue', 'green', 'red']
			];

			colorList = colorList[]].. mania - 1 ..[[];

			for (note in 0...game.unspawnNotes.length)
			{
				var dunceNote = game.unspawnNotes[note];
				if (!dunceNote.isSustainNote) {
					if (!stupidAdjusting.contains(colorList[dunceNote.noteData])){
						dunceNote.animation.addByPrefix(colorList[dunceNote.noteData] + 'Scroll', colorList[dunceNote.noteData]+'0');
					}

					dunceNote.animation.play(colorList[dunceNote.noteData] + 'Scroll');
				}else{
					if (!stupidAdjusting.contains(colorList[dunceNote.noteData])){
						dunceNote.animation.addByPrefix(colorList[dunceNote.noteData] + 'hold', colorList[dunceNote.noteData] + ' hold piece');
						dunceNote.animation.addByPrefix(colorList[dunceNote.noteData] + 'holdend', colorList[dunceNote.noteData] + ' hold end');
					}

					if (dunceNote.prevNote != null) {
						dunceNote.animation.play(colorList[dunceNote.noteData] + 'holdend');
						if (dunceNote.prevNote.isSustainNote) {
							dunceNote.prevNote.animation.play(colorList[dunceNote.noteData] + 'hold');
						}

						if (dunceNote.noteData > 3) {
							dunceNote.offsetX += 32;
						}
					}
				}
			}
		]])
end

function destroyStaticArrows()
	runHaxeCode([[
		for (dunceStrum in 0...game.strumLineNotes.length)
		{
			var daStrum = game.strumLineNotes.members[dunceStrum];

			daStrum.kill();
			game.strumLineNotes.remove(daStrum);
			if (daStrum.player == 1) {
				game.playerStrums.remove(daStrum);
			}else
			{
				game.opponentStrums.remove(daStrum);
			}
			daStrum.destroy();
		}
	]]);
end

function generateStaticArrows(player, mania)
		addHaxeLibrary('FlxTween', 'flixel.tweens')
		addHaxeLibrary('FlxEase', 'flixel.tweens')

		runHaxeCode([[
			var swidths = [160, 140, 110, 90];
			var scales = [0.6, 0.6, 0.46, 0.55];
			var posRest = [0, 15, 15, 70];

			var stupidList = [
				['left', 'up', 'right', 'F', 'down', 'I'],
				['left', 'up', 'right', 'space', 'F', 'down', 'I'],
				['left', 'down', 'up', 'right', 'space', 'F', 'G', 'H', 'I'],
				['left', 'down', 'up', 'right', 'space', 'F', 'up', 'right']
			];

			var stupidList = stupidList[]].. mania - 1 ..[[];

			for (i in 0...stupidList.length)
			{
				var babyArrow = new StrumNote(40, game.strumLine.y, i, ]]..player..[[);

				babyArrow.animation.addByPrefix('static', 'arrow' + stupidList[i].toUpperCase());
				babyArrow.animation.addByPrefix('pressed', stupidList[i]+' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', stupidList[i]+' confirm', 24, false);
				babyArrow.setGraphicSize(babyArrow.width / 0.7 * scales[]].. mania - 1 ..[[]);
				babyArrow.updateHitbox();
				
				babyArrow.downScroll = ClientPrefs.downScroll;
				
				game.strumLineNotes.add(babyArrow);
				if (]]..player..[[ == 1) 
				{
					game.playerStrums.add(babyArrow);
				}else
				{
					game.opponentStrums.add(babyArrow);
				}
				babyArrow.postAddedToGroup();

				//babyArrow.alpha = 0;
				//FlxTween.tween(babyArrow, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.07 * i)});

				babyArrow.x = 42 + (swidths[ ]].. mania - 1 ..[[ ] * 0.6 * i) + (FlxG.width / 2) * ]]..player..[[ - posRest[ ]]..mania - 1 ..[[ ];
			}
		]])
end

function onUpdate(elapsed)
	if mania < 1 then return end

	stupidSus = checkKeys();

	for i=0, getProperty('notes.length') - 1 do
		local isSustainNote = getPropertyFromGroup('notes', i, 'isSustainNote');
		local noteData = getPropertyFromGroup('notes', i, 'noteData');
		local mustPress = getPropertyFromGroup('notes', i, 'mustPress');

		if isSustainNote and stupidSus[noteData + 1] and mustPress then
			local canBeHit = getPropertyFromGroup('notes', i, 'canBeHit');
			local strumTime = getPropertyFromGroup('notes', i, 'strumTime');
			local songPosition = getPropertyFromClass('Conductor', 'songPosition');
			local dunceArray = getProperty('singAnimations');
			local prevGoodHit = getPropertyFromGroup('notes', i, 'prevNote.wasGoodHit')

			if (strumTime < songPosition or canBeHit and prevGoodHit) then	
				runHaxeCode([[
					var note = game.notes.members[ ]].. i ..[[ ];
					game.goodNoteHit(note);
				]])
			end
		end
	end
end

function checkKeys()
	local keyspressed = {};
	local dumb = {[' '] = 'SPACE'}

	for i, dummy in pairs(keysArray) do
		keyspressed[i] = false;
		for j, dummier in pairs(dummy) do
			if type(dummier) == 'number' and dummier > 9 then
				dummier = string.char(dummier)
				if dumb[dummier] then dummier = dumb[dummier] end
			end

			if keyboardPressed(tostring(dummier)) == true then
				keyspressed[i] = true;
			end
		end
	end

	return keyspressed; 
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if mania > 0 then
        runHaxeCode([[
            for (thing in game.opponentStrums)
            {
                if(thing.ID != ]]..direction..[[)
                    thing.playAnim('static', true);
                else
                    thing.playAnim('confirm', true);
		    thing.resetAnim = 0.15;
            }
        ]])
    end
end