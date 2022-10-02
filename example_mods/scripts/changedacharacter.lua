---- CONFIG
-- You can edit aspects about the script below

local showSongBF = true -- Whether the chart's BF should be shown as an option, disabling might be useful if you manually registered them and the chart's BF shows wrong


local allowStoryMode = false -- If this script can be used on storymode or not
local song = 'breakfast'; --If you want to have a song play while people are in this menu. Remove this line entirely if you don't want one.
local displayNameX = -200; -- Offset for Display name
local displayNameY = 0; -- Offset for Display name
local customCameraPos = false
local camX = 300
local camY = 300

local characterList = { -- The list of characters
	{
		name = "bf",
		displayName = "Boyfriend",
	},
	{
		name = "bf-car",
		displayName = "Windy Boyfriend",
	},
	{
		name = "bf-christmas",
		displayName = "Festive Boyfriend",
	},
	{
		name = "aumsum",
		displayName = "AumSum",
	},
	{
		name = "aumsum-narrator-new",
		displayName = "AumSum Narrator",
	},
	{
		name = "diego-player",
		displayName = "Diego",
	},
	{
		name = "aumxpunged",
		displayName = "3D AumSum",
	},
}


-- The actual script.

local changedChar = true
local isOnCharMenu = false;
local curCharacter = 1
local shownID = -10000
local befPaused = false
local displayNameY = 0;
local origBF = "";
local LY = 0;


function setupText(name,text,x,y)
	makeLuaText(name, text, x, y, 100);
	setTextSize(name, 48);
	setProperty(name ..'.borderColor', getColorFromHex('000000'));
	setProperty(name ..'.borderSize', 1.2);
end

function onCreate()
	if(not allowStoryMode and isStoryMode)then 
		onStartCountdown = nil;
		onTimerCompleted = nil;
		onPause = nil;
		onUpdate = nil;
		updateCharacter = nil;

		return;
	end -- Close script if in story mode, remove this or n
	--Theres nothing special here just all the extra stuff. Add or edit whatever you want.
	setProperty('inCutscene', true);
	setProperty('generatedMusic', false);
	setProperty('boyfriend.stunned', true);
end

function onStartCountdown()

	if not hasSelectedCharacter and not isOnCharMenu then
		isOnCharMenu = true
		makeLuaText('displayname', characterList[curCharacter].displayName, getProperty("boyfriend.x") + displayNameX, getProperty("boyfriend.y") + displayNameY, 100);
		setProperty('displayname.borderColor', getColorFromHex('000000'));
		setProperty('displayname.borderSize', 1.2);
		setObjectCamera('displayname', 'camGame');
		setTextSize('displayname', 48);
		setTextAlignment("displayName", 'center')
		displayNameY = getProperty("displayname.y")
		addLuaText('displayname');
		cameraSetTarget("boyfriend")
		setupText('leftarrow', "<", 0, 0)
		setupText('rightarrow', ">", 0, 0)
		setObjectCamera('rightarrow', 'camGame');
		setObjectCamera('leftarrow', 'camGame');
		addLuaText('leftarrow', true);
		addLuaText('rightarrow', true);
		playMusic(song, 1, true);
		origBF = getProperty("boyfriend.curCharacter")
		origGF = getProperty("gf.curCharacter")
		origDAD = getProperty("dad.curCharacter")
		if(not customCameraPos) then
			camX = getProperty("camFollow.x")
			camY = getProperty("camFollow.y")
		end

		if(showSongBF) then table.insert(characterList,1,{
			name=origBF,
			displayName="Player skin from Song"}) 
		end
		setProperty('inCutscene', true);
		setProperty('generatedMusic', false);
		setProperty('boyfriend.stunned', true);
		-- hasSelectedCharacter = true
		updateCharacter()
		setProperty('canPause', true);
		befPaused = getProperty('canPause')
		return Function_Stop;
	end
	setProperty('canPause', befPaused);
	setProperty('generatedMusic', true);
	if changedChar then
		characterPlayAnim('boyfriend', 'idle', true);

		if(characterList[curCharacter].opponent) then
			triggerEvent('Change Character', 'dad', characterList[curCharacter].opponent);
		end
		if(characterList[curCharacter].gf) then
			triggerEvent('Change Character', 'gf', characterList[curCharacter].gf);
		end
	end
	setProperty('inCutscene', false);
	setObjectCamera('boyfriend', 'camGame');
	setProperty('boyfriend.stunned', false);
	removeLuaText('leftarrow', true);
	removeLuaText('rightarrow', true);
	removeLuaText('displayname', true);
	pauseSound("music")
	
	playMusic(song, 0, false); --I don't know how to stop music there's nothing in the wiki or source its all just for sounds.\
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'wait' then
		startCountdown()
	end
end

function onPause()
	if(isOnCharMenu) then
		triggerEvent('Change Character', 'bf', origBF);
		isOnCharMenu = false
	end
	return Function_Continue;
end
function onUpdate()
	if(not isOnCharMenu) then return end
	setProperty('boyfriend.stunned', true);
	-- screenCenter('displayname', 'x');
	-- screenCenter('boyfriend', 'xy');
	-- if characterList[curCharacter].y then
	-- 	setProperty("boyfriend.y",getProperty("boyfriend.y") + characterList[curCharacter].y)
	-- end
	-- if characterList[curCharacter].x then
	-- 	setProperty("boyfriend.y",getProperty("boyfriend.x") + characterList[curCharacter].x)
	-- end
	-- scaleObject('boyfriend', 1, 1);
	if(shownID ~= curCharacter) then -- Only change the character if needed
		updateCharacter()
	end
	if keyJustPressed('left') then
		curCharacter = curCharacter - 1
		playSound('scrollMenu', 1);
		setProperty('leftarrow.y',getProperty("leftarrow.y") - 5)
		setProperty('leftarrow.color',0x11aa11)
	
	elseif keyJustPressed('right') then
		curCharacter = curCharacter + 1
		playSound('scrollMenu', 1);
		setProperty('rightarrow.y',getProperty("rightarrow.y") - 5)
		setProperty('rightarrow.color',0x11aa11)

	elseif keyJustPressed('accept') then
		characterPlayAnim('boyfriend', 'hey', false);
		hasSelectedCharacter = true
		for i,v in pairs({"leftarrow","rightarrow","displayname"}) do
			
			doTweenY(v.."-y", v, getProperty(v..".y") - 20, 1, "cubeout")
			doTweenAlpha(v.."-a", v, 0, 0.7, "cubeout")
		end
		runTimer('wait', 1.8, 1);
		playSound('confirmMenu', 1);
		isOnCharMenu = false
	elseif keyJustPressed('back') then
		-- playSound('confirmMenu', 1);
		triggerEvent('Change Character', 'bf', origBF);
		isOnCharMenu = false
		hasSelectedCharacter = true
		changedChar = false
		startCountdown();
	end
	
	if keyPressed('left') then
		-- objectPlayAnimation('leftarrow', 'leftpressed', true);
		setTextSize('leftarrow', 64);
	elseif keyPressed('right') then
		-- objectPlayAnimation('rightarrow', 'rightpressed', true);
		setTextSize('rightarrow', 64);
	end
	
	if keyReleased('left') then
		-- objectPlayAnimation('leftarrow', 'leftunpressed', true);
		setTextSize('leftarrow', 48);
		setProperty('leftarrow.y',LY)
		setProperty('leftarrow.color',0xFFFFFF)
	elseif keyReleased('right') then
		-- objectPlayAnimation('rightarrow', 'rightunpressed', true);
		setTextSize('rightarrow', 48);
		setProperty('rightarrow.y',LY)
		setProperty('rightarrow.color',0xFFFFFF)
	end
	
	if curCharacter > #characterList then
		curCharacter = 1
	elseif curCharacter <= 0 then
		curCharacter = #characterList
	end
	
end

function updateCharacter()
	triggerEvent('Change Character', 'bf', characterList[curCharacter].name);
	local char = characterList[curCharacter]
	setTextString('displayname', char.displayName);
	setTextAlignment("displayName", 'center')

	-- setObjectCamera('boyfriend', 'camOther');
	characterPlayAnim('boyfriend', 'idle', true);
	shownID = curCharacter


	triggerEvent('Change Character', 'dad', char.opponent or origDAD);
	triggerEvent('Change Character', 'gf', char.gf or origGF);
	

	setProperty('displayname.y', displayNameY-(char.displayNameY or 0)); -- Inverted for easier editing
	LY = getProperty('displayname.y')
	-- triggerEvent("Camera Follow Pos",)
	setProperty("camGame.target.y",camY + (char.camY or 0))
	setProperty("camGame.target.x",camX + (char.camX or 0))
	setProperty('leftarrow.y',LY)
	setProperty('rightarrow.y',LY)
	setProperty('leftarrow.x',getProperty("displayname.x"))
	setProperty('rightarrow.x',getProperty("displayname.x") + getProperty("displayname.width"))
end



-- Credits:


-- XpsxExp#4452: Making the script

-- Superpowers04#3887: Reformatting the script and making it cleaner and such
