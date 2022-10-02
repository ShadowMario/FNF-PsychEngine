-- MULTIPLE KEYS SUPPORT SCRIPT

-- Credits:

-- Code by @BombasticTom#0646!
-- Additional help by @Mayo78#2194 (Code in opponentNoteHit)!
-- SrPerez for reference code (Found in the VS Shaggy git repository)!
-- Thank you @raltyro#1324 for helping with custom key binds!
-- YoShubs for leaving a note position formula in the Forever Engine rewrite git repository!

-- (While crediting, I would appriciate if you could credit all of these cool people too for their contributions)

-- The Actual Code:

local keysArray = {};
local goofyAhhSus = {};

local stupidKeyArray = { -- Change your KeyBinds here:
	[1] = { -- Mania Type (6K)
        {'S', '1'}, -- Primary, Secondary Key
        {'D', '2'},
        {'F', '3'},
        {'J', '4'},
        {'K', '5'},
        {'L', '6'}
    },
	[2] = { -- Mania Type (7K)
        {'S', '1'}, -- Primary, Secondary Key
        {'D', '2'},
        {'F', '3'},
        {'SPACE', '4'},
        {'J', '5'},
        {'K', '6'},
        {'L', '7'}
	},
	[3] = { -- Mania Type (9K)
        {'A', '1'}, -- Primary, Secondary Key
        {'S', '2'},
        {'D', '3'},
        {'F', '4'},
        {'SPACE', '5'},
        {'H', '6'},
        {'J', '7'},
        {'K', '8'},
        {'L', '9'}
	}
};

function returnKeyBinds(mania) -- Gives a list of keys
    return stupidKeyArray[mania];
end

function setupKeyBinds(mania) -- Sets up keybinds

	local stupidVarOMGGGG = { -- basically this converts all haxe flxkeys into lua keys
		['SPACE'] = 32,
		['SEMICOLON'] = 186,
		['BACKSPACE'] = 8,
		['BACKSLASH'] = 220,
		['CAPSLOCK'] = 20,
		['COMMA'] = 188,
		['CONTROL'] = 17,
		['DELETE'] = 46,
		['GRAVEACCENT'] = 192,
		['MINUS'] = 189,
		['PERIOD'] = 190,
		['PLUS'] = 187
	}

	local string = ''

	for number, item in pairs(stupidKeyArray[mania]) do
		string = string .. '['
		for subItem=1, #item do
			local stupidFix = item[subItem];
			if stupidVarOMGGGG[stupidFix] then stupidFix = stupidVarOMGGGG[stupidFix] end

			if type(stupidFix) == 'string' then string = string .. string.byte(stupidFix) -- thanks raltyro!!
			else string = string .. stupidFix end

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

	runHaxeCode([[
		var songData = Song.loadFromJson(game.curSong + CoolUtil.getDifficultyFilePath(), game.curSong);
		var mania = songData.mania;

		if (mania == null || mania == 0) {
			mania = -1;
			return game.setOnLuas('mania', mania);
		}

		game.setOnLuas('mania', mania);
		setVar('songData', songData);

		var maniaNotes = [
			['singLEFT', 'singUP', 'singRIGHT', 'singLEFT', 'singDOWN', 'singRIGHT'],
			['singLEFT', 'singUP', 'singRIGHT', 'singUP', 'singLEFT', 'singDOWN', 'singRIGHT'],
			['singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singUP', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT']
		];

		game.singAnimations = maniaNotes[mania - 1];

		var keyAmounts = [6, 7, 9];
		var noteScales = [0.6, 0.6, 0.46];

		setVar('keyAmount', keyAmounts[mania - 1]);
		setVar('noteScale', noteScales[mania - 1]);
	]])

	if mania ~= nil and (mania > 0) and (mania < 4) then -- this checks if you're playing a multi key chart
		-- The reason we initialize these later is because we don't need these libraries if we're playing a 4k chart
		addHaxeLibrary('Math')
		addHaxeLibrary('Conductor')
		addHaxeLibrary('FlxMath', 'flixel.math')
		addHaxeLibrary('ClientPrefs')
		addHaxeLibrary('FunkinLua')

		setProperty('ratingsData[0].noteSplash', false)
  		setProperty('ratingsData[1].noteSplash', false)
  		setProperty('ratingsData[2].noteSplash', false)
  		setProperty('ratingsData[3].noteSplash', false)

		keysArray = returnKeyBinds(mania);
		for key=1, #keysArray do
			table.insert(goofyAhhSus, false);
		end

		for i=0, getProperty('unspawnNotes.length') - 1 do
			removeFromGroup('unspawnNotes', 0);
		end

		runHaxeCode([[
			var songData = getVar('songData');
			var keyAmount = getVar('keyAmount');
			var noteScale = getVar('noteScale');

			var noteData = songData.notes;
			var mania = songData.mania;

			game.keysArray = [
				]]..setupKeyBinds(mania)..[[
			];

			for (section in noteData)
			{
				for (songNotes in section.sectionNotes)
				{
					var strumTime = songNotes[0];
					var noteData = songNotes[1] % keyAmount;

					var gottaHitNote = section.mustHitSection;

					if (songNotes[1] > keyAmount - 1 && mania != 4)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote = null;
					if (game.unspawnNotes.length > 0)
						oldNote = game.unspawnNotes[game.unspawnNotes.length - 1];

					var swagNote = new Note(strumTime, noteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.gfNote = (section.gfSection && (songNotes[1] < keyAmount));
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

							sustainNote.setGraphicSize(sustainNote.width / 0.7 * noteScale, sustainNote.height);
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

					swagNote.setGraphicSize(swagNote.width / 0.7 * noteScale);
					swagNote.updateHitbox();
				}
			}

			game.unspawnNotes.sort(game.sortByShit);
		]]);

		postAdded();
	end
end

function postAdded() -- Stuff that will happen when the actual strums get added to the game
	destroyStaticArrows();
	generateStaticArrows(0, mania);
	generateStaticArrows(1, mania);

	runHaxeCode([[
		var colorList = [
			['purple', 'green', 'red', 'F', 'blue', 'I'],
			['purple', 'green', 'red', 'white', 'F', 'blue', 'I'],
			['purple', 'blue', 'green', 'red', 'white', 'F', 'G', 'H', 'I'],
		];

		var stupidOffset = [35, 35, 13];
		stupidOffset = stupidOffset[getVar('songData').mania - 1];

		colorList = colorList[]].. mania - 1 ..[[];
			
		for (note in 0...game.unspawnNotes.length)
		{
			var dunceNote = game.unspawnNotes[note];
			if (!dunceNote.isSustainNote) {
				dunceNote.animation.addByPrefix(colorList[dunceNote.noteData] + 'Scroll', colorList[dunceNote.noteData]+'0');
				dunceNote.animation.play(colorList[dunceNote.noteData] + 'Scroll');
			}
			else {
				dunceNote.animation.addByPrefix(colorList[dunceNote.noteData] + 'hold', colorList[dunceNote.noteData] + ' hold piece');
				dunceNote.animation.addByPrefix(colorList[dunceNote.noteData] + 'holdend', colorList[dunceNote.noteData] + ' hold end');

				if (dunceNote.prevNote != null) {
					dunceNote.animation.play(colorList[dunceNote.noteData] + 'holdend');
					if (dunceNote.prevNote.isSustainNote) {
						dunceNote.prevNote.animation.play(colorList[dunceNote.noteData] + 'hold');
					}

					if (dunceNote.noteData > 4) {
						dunceNote.x = dunceNote.parent.x;
					}
				}
			}
		}
	]])
end

function destroyStaticArrows() -- Destroys strums
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

function generateStaticArrows(player, mania) -- Generates strums
	runHaxeCode([[
		var swidths = [160, 140, 140];
		var scales = [0.6, 0.6, 0.46]; // Thanks Perez!

		var stupidList = [
			['left', 'up', 'right', 'F', 'down', 'I'],
			['left', 'up', 'right', 'space', 'F', 'down', 'I'],
			['left', 'down', 'up', 'right', 'space', 'F', 'G', 'H', 'I'],
		];

		var stupidList = stupidList[]].. mania - 1 ..[[];
		var scales = scales[]].. mania - 1 ..[[];
		var swidths = swidths[]].. mania - 1 ..[[];

		for (i in 0...stupidList.length)
		{
			var babyArrow = new StrumNote(40, game.strumLine.y, i, ]]..player..[[);
			var seperation = FlxG.width / 2 + FlxG.width / 4;

			babyArrow.animation.addByPrefix('static', 'arrow' + stupidList[i].toUpperCase());
			babyArrow.animation.addByPrefix('pressed', stupidList[i]+' press', 24, false);
			babyArrow.animation.addByPrefix('confirm', stupidList[i]+' confirm', 24, false);
			babyArrow.setGraphicSize(babyArrow.width / 0.7 * scales);
			babyArrow.updateHitbox();
			
			babyArrow.downScroll = ClientPrefs.downScroll;
			
			game.strumLineNotes.add(babyArrow);
			if (]]..player..[[ == 1) 
			{
				game.playerStrums.add(babyArrow);
			}
			else{
				seperation -= FlxG.width / 2;
				game.opponentStrums.add(babyArrow);
			}

			babyArrow.postAddedToGroup();
			babyArrow.x = seperation - (swidths * scales) / 2 + (i - (getVar('keyAmount') - 1) / 2) * (swidths * scales); // Thanks Shubs!!
		}
	]])
end

function onUpdate(elapsed) -- Sustain Note Hit Detection
	if mania == nil or mania < 1 then return end

	stupidSus = checkKeys();

	for i=0, getProperty('notes.length') - 1 do
		local isSustainNote = getPropertyFromGroup('notes', i, 'isSustainNote');
		local noteData = getPropertyFromGroup('notes', i, 'noteData');
		local mustPress = getPropertyFromGroup('notes', i, 'mustPress');

		if mustPress and stupidSus[noteData + 1] and isSustainNote then
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

function checkKeys() -- Function that registers Key presses
	local keyspressed = {};
	local dumb = {[' '] = 'SPACE'}

	for i, dummy in pairs(keysArray) do
		keyspressed[i] = false;
		for j, dummier in pairs(dummy) do
			if type(dummier) == 'number' and dummier > 9 then
				dummier = string.char(dummier)
				if dumb[dummier] then dummier = dumb[dummier] end
			end

			if keyboardPressed(dummier) == true then
				keyspressed[i] = true;
			end
		end
	end

	return keyspressed; 
end

function opponentNoteHit(id, direction, noteType, isSustainNote) -- Script that fixes Opponent's strums
    if mania > 0 then
        runHaxeCode([[
           for (thing in game.opponentStrums) // Thanks Mayo!!
            {
                if(thing.ID != ]]..direction..[[) {
					if (thing.animation.curAnim.name == 'confirm' && thing.animation.curAnim.curFrame == 0)
                    	thing.playAnim('static', true);
				}
                else {
                    thing.playAnim('confirm', true);
		    		thing.resetAnim = 0.15;
				}
            }
        ]])
    end
end