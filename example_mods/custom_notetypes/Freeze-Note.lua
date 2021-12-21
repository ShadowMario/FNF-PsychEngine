function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
	if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Freeze-Note' then
		setPropertyFromGroup('unspawnNotes', i, 'texture', 'freezenote');
        if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
        end
		end
	end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
if noteType == 'Freeze-Note' then
   debugPrint('frozen')
   setProperty('boyfriend.stunned', true);
   runTimer('frozen', 1);
   end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'frozen' then
	debugPrint('unfrozen')
	setProperty('boyfriend.stunned', false);
	end
end