local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene then --Block the first countdown
		setProperty('inCutscene', true);
		startVideo('gunsCutscene');
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end