function onCreatePost()
  for i = 0, getProperty('unspawnNotes.length')-1 do
    if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
      setPropertyFromGroup('unspawnNotes', i, 'hitHealth', 0.004)
    end
  end
end