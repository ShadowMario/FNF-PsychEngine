function onEvent(name, value1, value2)
	if name == 'hud rotate' then
	local defaultNotePos = {}
	local spin = 10 -- how much it moves before going the other direction
		
	function onSongStart()
		for i = 0, 7 do
			defaultNotePos[i] = {
				getPropertyFromGroup('strumLineNotes', i, 'x'),
				getPropertyFromGroup('strumLineNotes', i, 'y')
			}
		end
	end
		
	function onUpdate(elapsed)
		local songPos = getPropertyFromClass('Conductor', 'songPosition') / 439 --How long it will take.
			
			setProperty("camHUD.angle", spin * math.sin(songPos))
		end
    end
end	