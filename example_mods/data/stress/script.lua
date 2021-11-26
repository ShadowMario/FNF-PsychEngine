local allowCountdown = false
function onCreate()
	makeChart();
end

function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene then --Block the first countdown
		setProperty('inCutscene', true);
		startVideo('stressCutscene');
		allowCountdown = true;
		return Function_Stop;
	end

	characterPlayAnim('gf', 'shoot1-loop', true);
	return Function_Continue;
end

chartTankman = {}
maxTankman = 0;
function makeChart()
	for i = 0, getProperty('eventNotes.length')-1 do
		if getPropertyFromGroup('eventNotes', i, 2) == 'Tankman Note' then
			isRight = true;
			if getPropertyFromGroup('eventNotes', i, 3) == 'left' then
				isRight = false;
			end
			pushTankman({time = getPropertyFromGroup('eventNotes', i, 0), right = isRight});
		end
	end
end

function pushTankman(data)
	chartTankman[maxTankman] = data;
	maxTankman = maxTankman + 1;
end

readingChartNumber = 0;
spawnedChartTankman = {};

tankmenDisappeared = 0;
curTankman = 0;
curSpawnedTankman = 0;

curPicoNote = 0;
function onUpdate(elapsed)
	if getProperty('dad.curCharacter') == 'tankman' then
		if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
			setProperty('dad.holdTimer', 0); --Huh... Pretty Good!
		end
	end

	if readingChartNumber < maxTankman and getSongPosition() >= (chartTankman[readingChartNumber].time - 1500) then
		--debugPrint(chartTankman[readingChartNumber].time);
		makeTankman(chartTankman[readingChartNumber].right);
	end
	
	if curTankman < curSpawnedTankman and spawnedChartTankman[curTankman].time <= getSongPosition() then
		tag = string.format('tankmanRun%i', curTankman);
		luaSpritePlayAnimation(tag, 'shot', true);
		if spawnedChartTankman[curTankman].right then
			animToPlay = 3;
			setProperty(string.format('%s.offset.x', tag), 300);
			setProperty(string.format('%s.offset.y', tag), 200);
		end
		curTankman = curTankman + 1;
	end

	if curPicoNote < maxTankman and chartTankman[curPicoNote].time <= getSongPosition() then
		animToPlay = 1;
		if chartTankman[curPicoNote].right then
			animToPlay = 3;
		end

		math.randomseed(os.time());
		animToPlay = animToPlay + math.random(0, 1);
		characterPlayAnim('gf', string.format('shoot%i', animToPlay), true);
		curPicoNote = curPicoNote + 1;
	end

	if curTankman < curSpawnedTankman then
		for i = curTankman, curSpawnedTankman-1 do
			tag = string.format('tankmanRun%i', i);
			if getProperty(string.format('%s.animation.curAnim.name', tag)) == 'run' then
				speed = (getSongPosition() - spawnedChartTankman[i].time) * spawnedChartTankman[i].speed;
				xTag = string.format('%s.x', tag);
				if spawnedChartTankman[i].right then
					setProperty(xTag, (0.02 * screenWidth - spawnedChartTankman[i].offset) + speed);
				else
					setProperty(xTag, (0.74 * screenWidth + spawnedChartTankman[i].offset) - speed);
				end
			end
		end
	end

	if tankmenDisappeared < curTankman then
		for i = tankmenDisappeared, curTankman-1 do
			tag = string.format('tankmanRun%i', i);
			if getProperty(string.format('%s.animation.curAnim.finished', tag)) then
				removeLuaSprite(tag);
				tankmenDisappeared = tankmenDisappeared + 1;
			end
		end
	end
	--debugPrint(curTankman, ' ', curSpawnedTankman,' ', tankmenDisappeared);
end

function makeTankman(facingRight)
	chance = 16;
	if lowQuality then
		chance = 8;
	end

	math.randomseed(os.time() + curTankman + curPicoNote);
	if math.random(0, 99) < chance then
		-- Prepare sprite
		tag = string.format('tankmanRun%i', curSpawnedTankman);
		makeAnimatedLuaSprite(tag, 'tankmanKilled1', 500, 200 + math.random(50, 100));
		luaSpriteAddAnimationByPrefix(tag, 'run', 'tankman running', 24, true);
		luaSpriteAddAnimationByPrefix(tag, 'shot', string.format('John Shot %i', math.random(1, 2)), 24, false);
		scaleObject(tag, 0.8, 0.8);
		
		-- Random animation frame
		prop = string.format('%s.animation.curAnim.curFrame', tag);
		leng = getProperty(string.format('%s.animation.curAnim.frames.length', tag));
		numGenerated = math.random(0, leng - 1);
		setProperty(prop, numGenerated);
		setProperty(string.format('%s.flipX', tag), facingRight);

		-- Set some properties
		spawnedChartTankman[curSpawnedTankman] = chartTankman[readingChartNumber];
		spawnedChartTankman[curSpawnedTankman].offset = math.random(50, 200);
		spawnedChartTankman[curSpawnedTankman].speed = randomFloat(0.6, 1);

		-- Finally add sprite
		addLuaSprite(tag, false);
		setObjectOrder(tag, getObjectOrder('tankRolling') + 1);
		curSpawnedTankman = curSpawnedTankman + 1;
	end
	readingChartNumber = readingChartNumber + 1
end

function randomFloat(lower, greater)
    return lower + math.random() * (greater - lower);
end